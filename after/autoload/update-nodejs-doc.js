#!/usr/bin/env node

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
  // fs.writeFileSync('./tmp.txt', body);
  var json = JSON.parse(body),
      modules = json.modules,
      vimObject = {};


  modules.forEach(function(mod) {
    var methods = mod.methods;
    if (!util.isArray(methods)) {
      return;
    }

    var mod_name = mod.name;

    var list = [];
    methods.forEach(function(method) {
      var item = {};
      if (method.type == 'method') {
        item.word = method.name + '(';
        item.info = method.textRaw;

        list.push(item);
      }
    });

    vimObject[mod_name] = list;
  });


  var content = 'let g:nodejs_complete_modules = ' + JSON.stringify(vimObject),
      comment = '" this file is auto created by "' + __filename + '", please do not edit it yourself!';
  content = comment  + os.EOL + content;

  var filename = path.join(__dirname, 'nodejs-doc.vim'); 
  fs.writeFile(filename, content, function(err) {
    emitter.emit('vimscript/done', 'write file to "' + filename + '" complete.');
  });
}
