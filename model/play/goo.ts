import * as fs from 'fs';
import * as JSONStream from 'jsonstream';
import {Transform, Writable} from 'stream';

// var src = fs.createReadStream('model/sample.json');
var src = fs.createReadStream('foo.json');
var parser = JSONStream.parse('crew');

var tx = new Transform({
  writableObjectMode: true,
  transform: function(chunk: any, encoding: any, callback: Function) {
    // console.log(JSON.stringify(chunk));
    var ser = JSON.stringify(chunk);
    console.log(ser);
    callback(undefined, 'ser');
    // this.push(ser);
  }
});

var out = require('process').stdout;

// src.pipe(parser).pipe(out);
src.pipe(parser).pipe(tx).pipe(out);
// src.pipe(tx).pipe(out);
