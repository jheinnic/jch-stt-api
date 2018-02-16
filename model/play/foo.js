var JSONStream = require('JSONStream');
var stream = require('stream');
var fs = require('fs');

var src = fs.createReadStream('./temp.json');
// var src = fs.createReadStream('model/sample.json');
// var src = fs.createReadStream('foo.json');
var parser = JSONStream.parse('player.character.crew.*');

var tx = new stream.Transform({
  writableObjectMode: true,
  transform: function(chunk, encoding, callback) {
    // console.log(JSON.stringify(chunk));
    var ser = JSON.stringify(chunk);
    // console.log(ser);
    callback(undefined, ser);
    // this.push(ser);
  }
});

var out = require('process').stdout;

// src.pipe(parser).pipe(out);
src.pipe(parser).pipe(tx).pipe(out);
// src.pipe(tx).pipe(out);
