#!/usr/bin/env node

var util = require('util'),
    fs = require('fs'),
    path = require('path'),
    os = require('os');

init();

function init() {
  // TODO: listen process.uncaughtException event

  initLoading();

  getNodejsDoc();
}

function initLoading() {
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


  var content = 'let g:nodejs_complete_modules = ' + JSON.stringify(vimObject);
  content = '" this file is auto created by "' + __filename + '", please do not edit it yourself!' + os.EOL + content;

  fs.writeFileSync(path.join(__dirname, 'nodejs-doc.vim'), content);
}
