#!/usr/bin/env node

/**
 * @author: Lin Zhang ( myhere.2009 AT gmail DOT com )
 * @fileoverview: This script for auto-generate nodejs-doc.vim 
 */

var util = require('util'),
    fs = require('fs'),
    path = require('path'),
    os = require('os'),
    emitter = new (require('events')).EventEmitter();

init();

function init() {
  initEvents();

  initLoading();

  getNodejsDoc();
}

function initEvents() {
  // uncatched exception
  process.on('uncaughtException', function(err) {
    clearLoading();

    console.error('Error: ' + err);
  });

  emitter.on('vimscript/done', function(message) {
    clearLoading();
    console.log(message);
    console.log('Done!');
  });
}

function initLoading() {
  var chars = [
    '-',
    '\\',
    '|',
    '/'
  ];

  var index = 0,
      total = chars.length;

  initLoading.timer = setInterval(function() {
    index = ++index % total;

    var c = chars[index];

    // clear console
    // @see: https://groups.google.com/forum/?fromgroups#!topic/nodejs/i-oqYFVty5I
    process.stdout.write('\033[2J\033[0;0H');
    console.log('please wait:');
    console.log(c);
  }, 200);
}
function clearLoading() {
  clearInterval(initLoading.timer);
}

function getNodejsDoc() {
  var http = require('http');

  var req = http.get('http://nodejs.org/api/all.json', function(res){
      var chunks = [];

      res.on('data', function(chunk) {
        chunks.push(chunk);
      });

      res.on('end', function() {
        var buf = Buffer.concat(chunks),
            body = buf.toString('utf-8');

        write2VimScript(body);
      });
  }).on('error', function(e) {
    console.error('problem with request: ' + e.message);
  });
}

function write2VimScript(body) {
  // for debug
  // fs.writeFileSync('./nodejs-doc-all.json', body);
  var json = JSON.parse(body),
      modules = json.modules,
      vimObject = {};


  modules.forEach(function(mod) {
    var list = [];

    // methods
    var methods = mod.methods || [];
    methods.forEach(function(method) {
      var item = {};
      if (method.type == 'method') {
        item.word = method.name + '(';
        item.info = method.textRaw;

        list.push(item);
      }
    });

    // properties
    var properties = mod.properties || [];
    properties.forEach(function(property) {
      var item = {};
      item.word = property.name;

      list.push(item);
    });

    // if empty
    if (list.length == 0) {
      return;
    }

    // sort items
    list = list.sort(function(a, b) {
      var a_w = a.word.toLowerCase(),
          b_w = b.word.toLowerCase();

      return a_w < b_w ? -1 : (a_w > b_w ? 1 : 0);
    });


    // module name
    var mod_name = mod.name;
    // invalid module name like 'tls_(ssl)'
    // then guess the module name from textRaw 'TLS (SSL)'
    if ((/[^_a-z\d\$]/i).test(mod_name)) {
      var textRaw = mod.textRaw;
      var matched = textRaw.match(/^[_a-z\d\$]+/i);
      if (matched) {
        var mod_name_len = matched[0].length;
        mod_name = mod_name.substr(0, mod_name_len);
      }
    }

    vimObject[mod_name] = list;
  });



  var filename = path.join(__dirname, 'nodejs-doc.vim'); 
  var content = 'let g:nodejs_complete_modules = ' + JSON.stringify(vimObject),
      comment = '" this file is auto created by "' + __filename + '", please do not edit it yourself!';
  content = comment  + os.EOL + content;

  fs.writeFile(filename, content, function(err) {
    emitter.emit('vimscript/done', 'write file to "' + filename + '" complete.');
  });

  // for debug
  // fs.writeFileSync(filename + '.js', JSON.stringify(vimObject, null, 2));
}
