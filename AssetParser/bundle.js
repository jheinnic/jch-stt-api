(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.png = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict'

exports.byteLength = byteLength
exports.toByteArray = toByteArray
exports.fromByteArray = fromByteArray

var lookup = []
var revLookup = []
var Arr = typeof Uint8Array !== 'undefined' ? Uint8Array : Array

var code = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
for (var i = 0, len = code.length; i < len; ++i) {
  lookup[i] = code[i]
  revLookup[code.charCodeAt(i)] = i
}

revLookup['-'.charCodeAt(0)] = 62
revLookup['_'.charCodeAt(0)] = 63

function placeHoldersCount (b64) {
  var len = b64.length
  if (len % 4 > 0) {
    throw new Error('Invalid string. Length must be a multiple of 4')
  }

  // the number of equal signs (place holders)
  // if there are two placeholders, than the two characters before it
  // represent one byte
  // if there is only one, then the three characters before it represent 2 bytes
  // this is just a cheap hack to not do indexOf twice
  return b64[len - 2] === '=' ? 2 : b64[len - 1] === '=' ? 1 : 0
}

function byteLength (b64) {
  // base64 is 4/3 + up to two characters of the original data
  return (b64.length * 3 / 4) - placeHoldersCount(b64)
}

function toByteArray (b64) {
  var i, l, tmp, placeHolders, arr
  var len = b64.length
  placeHolders = placeHoldersCount(b64)

  arr = new Arr((len * 3 / 4) - placeHolders)

  // if there are placeholders, only get up to the last complete 4 chars
  l = placeHolders > 0 ? len - 4 : len

  var L = 0

  for (i = 0; i < l; i += 4) {
    tmp = (revLookup[b64.charCodeAt(i)] << 18) | (revLookup[b64.charCodeAt(i + 1)] << 12) | (revLookup[b64.charCodeAt(i + 2)] << 6) | revLookup[b64.charCodeAt(i + 3)]
    arr[L++] = (tmp >> 16) & 0xFF
    arr[L++] = (tmp >> 8) & 0xFF
    arr[L++] = tmp & 0xFF
  }

  if (placeHolders === 2) {
    tmp = (revLookup[b64.charCodeAt(i)] << 2) | (revLookup[b64.charCodeAt(i + 1)] >> 4)
    arr[L++] = tmp & 0xFF
  } else if (placeHolders === 1) {
    tmp = (revLookup[b64.charCodeAt(i)] << 10) | (revLookup[b64.charCodeAt(i + 1)] << 4) | (revLookup[b64.charCodeAt(i + 2)] >> 2)
    arr[L++] = (tmp >> 8) & 0xFF
    arr[L++] = tmp & 0xFF
  }

  return arr
}

function tripletToBase64 (num) {
  return lookup[num >> 18 & 0x3F] + lookup[num >> 12 & 0x3F] + lookup[num >> 6 & 0x3F] + lookup[num & 0x3F]
}

function encodeChunk (uint8, start, end) {
  var tmp
  var output = []
  for (var i = start; i < end; i += 3) {
    tmp = (uint8[i] << 16) + (uint8[i + 1] << 8) + (uint8[i + 2])
    output.push(tripletToBase64(tmp))
  }
  return output.join('')
}

function fromByteArray (uint8) {
  var tmp
  var len = uint8.length
  var extraBytes = len % 3 // if we have 1 byte left, pad 2 bytes
  var output = ''
  var parts = []
  var maxChunkLength = 16383 // must be multiple of 3

  // go through the array every three bytes, we'll deal with trailing stuff later
  for (var i = 0, len2 = len - extraBytes; i < len2; i += maxChunkLength) {
    parts.push(encodeChunk(uint8, i, (i + maxChunkLength) > len2 ? len2 : (i + maxChunkLength)))
  }

  // pad the end with zeros, but make sure to not forget the extra bytes
  if (extraBytes === 1) {
    tmp = uint8[len - 1]
    output += lookup[tmp >> 2]
    output += lookup[(tmp << 4) & 0x3F]
    output += '=='
  } else if (extraBytes === 2) {
    tmp = (uint8[len - 2] << 8) + (uint8[len - 1])
    output += lookup[tmp >> 10]
    output += lookup[(tmp >> 4) & 0x3F]
    output += lookup[(tmp << 2) & 0x3F]
    output += '='
  }

  parts.push(output)

  return parts.join('')
}

},{}],2:[function(require,module,exports){
//========================================================================================
// Globals
//========================================================================================

var Context = require("./context").Context;

var PRIMITIVE_TYPES = {
    'UInt8'    : 1,
    'UInt16LE' : 2,
    'UInt16BE' : 2,
    'UInt32LE' : 4,
    'UInt32BE' : 4,
    'Int8'     : 1,
    'Int16LE'  : 2,
    'Int16BE'  : 2,
    'Int32LE'  : 4,
    'Int32BE'  : 4,
    'FloatLE'  : 4,
    'FloatBE'  : 4,
    'DoubleLE' : 8,
    'DoubleBE' : 8
};

var SPECIAL_TYPES = {
    'String'   : null,
    'Buffer'   : null,
    'Array'    : null,
    'Skip'     : null,
    'Choice'   : null,
    'Nest'     : null,
    'Bit'      : null
};

var aliasRegistry = {};
var FUNCTION_PREFIX = '___parser_';

var BIT_RANGE = [];
(function() {
    var i;
    for (i = 1; i <= 32; i++) {
        BIT_RANGE.push(i);
    }
})();

// Converts Parser's method names to internal type names
var NAME_MAP = {};
Object.keys(PRIMITIVE_TYPES)
    .concat(Object.keys(SPECIAL_TYPES))
    .forEach(function(type) {
        NAME_MAP[type.toLowerCase()] = type;
    });

//========================================================================================
// class Parser
//========================================================================================

//----------------------------------------------------------------------------------------
// constructor
//----------------------------------------------------------------------------------------

var Parser = function() {
    this.varName = '';
    this.type = '';
    this.options = {};
    this.next = null;
    this.head = null;
    this.compiled = null;
    this.endian = 'be';
    this.constructorFn = null;
    this.alias = null;
};

//----------------------------------------------------------------------------------------
// public methods
//----------------------------------------------------------------------------------------

Parser.start = function() {
    return new Parser();
};

Object.keys(PRIMITIVE_TYPES)
    .forEach(function(type) {
        Parser.prototype[type.toLowerCase()] = function(varName, options) {
            return this.setNextParser(type.toLowerCase(), varName, options);
        };

        var typeWithoutEndian = type.replace(/BE|LE/, '').toLowerCase();
        if (!(typeWithoutEndian in Parser.prototype)) {
            Parser.prototype[typeWithoutEndian] = function(varName, options) {
                return this[typeWithoutEndian + this.endian](varName, options);
            };
        }
    });

BIT_RANGE.forEach(function(i) {
    Parser.prototype['bit' + i.toString()] = function(varName, options) {
        if (!options) {
            options = {};
        }
        options.length = i;
        return this.setNextParser('bit', varName, options);
    };
});

Parser.prototype.namely = function(alias) {
    aliasRegistry[alias] = this;
    this.alias = alias;
    return this;
}

Parser.prototype.skip = function(length, options) {
    if (options && options.assert) {
        throw new Error('assert option on skip is not allowed.');
    }

    return this.setNextParser('skip', '', {length: length});
};

Parser.prototype.string = function(varName, options) {
    if (!options.zeroTerminated && !options.length && !options.greedy) {
        throw new Error('Neither length, zeroTerminated, nor greedy is defined for string.');
    }
    if ((options.zeroTerminated || options.length) && options.greedy) {
        throw new Error('greedy is mutually exclusive with length and zeroTerminated for string.');
    }
    if (options.stripNull && !(options.length || options.greedy)) {
        throw new Error('Length or greedy must be defined if stripNull is defined.');
    }
    options.encoding = options.encoding || 'utf8';

    return this.setNextParser('string', varName, options);
};

Parser.prototype.buffer = function(varName, options) {
    if (!options.length && !options.readUntil) {
        throw new Error('Length nor readUntil is defined in buffer parser');
    }

    return this.setNextParser('buffer', varName, options);
};

Parser.prototype.array = function(varName, options) {
    if (!options.readUntil && !options.length && !options.lengthInBytes) {
        throw new Error('Length option of array is not defined.');
    }
    if (!options.type) {
        throw new Error('Type option of array is not defined.');
    }
    if ((typeof options.type === 'string') && !aliasRegistry[options.type]
        && Object.keys(PRIMITIVE_TYPES).indexOf(NAME_MAP[options.type]) < 0) {
        throw new Error('Specified primitive type "' + options.type + '" is not supported.');
    }

    return this.setNextParser('array', varName, options);
};

Parser.prototype.choice = function(varName, options) {
    if (!options.tag) {
        throw new Error('Tag option of array is not defined.');
    }
    if (!options.choices) {
        throw new Error('Choices option of array is not defined.');
    }
    Object.keys(options.choices).forEach(function(key) {
        if (isNaN(parseInt(key, 10))) {
            throw new Error('Key of choices must be a number.');
        }
        if (!options.choices[key]) {
            throw new Error('Choice Case ' + key + ' of ' + varName + ' is not valid.');
        }

        if ((typeof options.choices[key] === 'string') && !aliasRegistry[options.choices[key]]
            && (Object.keys(PRIMITIVE_TYPES).indexOf(NAME_MAP[options.choices[key]]) < 0)) {
            throw new Error('Specified primitive type "' +  options.choices[key] + '" is not supported.');
        }
    }, this);

    return this.setNextParser('choice', varName, options);
};

Parser.prototype.nest = function(varName, options) {
    if (!options.type) {
        throw new Error('Type option of nest is not defined.');
    }

    if (!(options.type instanceof Parser) && !aliasRegistry[options.type]) {
        throw new Error('Type option of nest must be a Parser object.');
    }

    return this.setNextParser('nest', varName, options);
};

Parser.prototype.endianess = function(endianess) {
    switch (endianess.toLowerCase()) {
    case 'little':
        this.endian = 'le';
        break;
    case 'big':
        this.endian = 'be';
        break;
    default:
        throw new Error('Invalid endianess: ' + endianess);
    }

    return this;
};

Parser.prototype.create = function(constructorFn) {
    if (!(constructorFn instanceof Function)) {
        throw new Error('Constructor must be a Function object.');
    }

    this.constructorFn = constructorFn;

    return this;
};

Parser.prototype.getCode = function() {
    var ctx = new Context();

    ctx.pushCode('if (!Buffer.isBuffer(buffer)) {');
    ctx.generateError('"argument buffer is not a Buffer object"');
    ctx.pushCode('}');

    if (!this.alias) {
        this.addRawCode(ctx);
    } else {
        this.addAliasedCode(ctx);
    }

    if (this.alias) {
        ctx.pushCode('return {0}(0).result;', FUNCTION_PREFIX + this.alias);
    } else {
        ctx.pushCode('return vars;');
    }

    return ctx.code;
};

Parser.prototype.addRawCode = function(ctx) {
    ctx.pushCode('var offset = 0;');

    if (this.constructorFn) {
        ctx.pushCode('var vars = new constructorFn();');
    } else {
        ctx.pushCode('var vars = {};');
    }

    this.generate(ctx);

    this.resolveReferences(ctx);

    ctx.pushCode('return vars;');
};

Parser.prototype.addAliasedCode = function(ctx) {
    ctx.pushCode('function {0}(offset) {', FUNCTION_PREFIX + this.alias);

    if (this.constructorFn) {
        ctx.pushCode('var vars = new constructorFn();');
    } else {
        ctx.pushCode('var vars = {};');
    }

    this.generate(ctx);

    ctx.markResolved(this.alias);
    this.resolveReferences(ctx);

    ctx.pushCode('return { offset: offset, result: vars };');
    ctx.pushCode('}');

    return ctx;
};

Parser.prototype.resolveReferences = function(ctx) {
    var references = ctx.getUnresolvedReferences();
    ctx.markRequested(references);
    references.forEach(function(alias) {
        var parser = aliasRegistry[alias];
        parser.addAliasedCode(ctx);
    });
};

Parser.prototype.compile = function() {
    this.compiled = new Function('buffer', 'callback', 'constructorFn', this.getCode());
};

Parser.prototype.sizeOf = function() {
    var size = NaN;

    if (Object.keys(PRIMITIVE_TYPES).indexOf(this.type) >= 0) {
        size = PRIMITIVE_TYPES[this.type];

    // if this is a fixed length string
    } else if (this.type === 'String' && typeof this.options.length === 'number') {
        size = this.options.length;

    // if this is a fixed length buffer
    } else if (this.type === 'Buffer' && typeof this.options.length === 'number') {
        size = this.options.length;

    // if this is a fixed length array
    } else if (this.type === 'Array' && typeof this.options.length === 'number') {
        var elementSize = NaN;
        if (typeof this.options.type === 'string'){
            elementSize = PRIMITIVE_TYPES[NAME_MAP[this.options.type]];
        } else if (this.options.type instanceof Parser) {
            elementSize = this.options.type.sizeOf();
        }
        size = this.options.length * elementSize;

    // if this a skip
    } else if (this.type === 'Skip') {
        size = this.options.length;

    // if this is a nested parser
    } else if (this.type === 'Nest') {
        size = this.options.type.sizeOf();
    } else if (!this.type) {
        size = 0;
    }

    if (this.next) {
        size += this.next.sizeOf();
    }

    return size;
};

// Follow the parser chain till the root and start parsing from there
Parser.prototype.parse = function(buffer, callback) {
    if (!this.compiled) {
        this.compile();
    }

    return this.compiled(buffer, callback, this.constructorFn);
};

//----------------------------------------------------------------------------------------
// private methods
//----------------------------------------------------------------------------------------

Parser.prototype.setNextParser = function(type, varName, options) {
    var parser = new Parser();

    parser.type = NAME_MAP[type];
    parser.varName = varName;
    parser.options = options || parser.options;
    parser.endian = this.endian;

    if (this.head) {
        this.head.next = parser;
    } else {
        this.next = parser;
    }
    this.head = parser;

    return this;
};

// Call code generator for this parser
Parser.prototype.generate = function(ctx) {
    if (this.type) {
        this['generate' + this.type](ctx);
        this.generateAssert(ctx);
    }

    var varName = ctx.generateVariable(this.varName);
    if (this.options.formatter) {
        this.generateFormatter(ctx, varName, this.options.formatter);
    }

    return this.generateNext(ctx);
};

Parser.prototype.generateAssert = function(ctx) {
    if (!this.options.assert) {
        return;
    }

    var varName = ctx.generateVariable(this.varName);

    switch (typeof this.options.assert) {
        case 'function':
            ctx.pushCode('if (!({0}).call(vars, {1})) {', this.options.assert, varName);
        break;
        case 'number':
            ctx.pushCode('if ({0} !== {1}) {', this.options.assert, varName);
        break;
        case 'string':
            ctx.pushCode('if ("{0}" !== {1}) {', this.options.assert, varName);
        break;
        default:
            throw new Error('Assert option supports only strings, numbers and assert functions.');
    }
    ctx.generateError('"Assert error: {0} is " + {0}', varName);
    ctx.pushCode('}');
};

// Recursively call code generators and append results
Parser.prototype.generateNext = function(ctx) {
    if (this.next) {
        ctx = this.next.generate(ctx);
    }

    return ctx;
};

Object.keys(PRIMITIVE_TYPES).forEach(function(type) {
    Parser.prototype['generate' + type] = function(ctx) {
        ctx.pushCode('{0} = buffer.read{1}(offset);', ctx.generateVariable(this.varName), type);
        ctx.pushCode('offset += {0};', PRIMITIVE_TYPES[type]);
    };
});

Parser.prototype.generateBit = function(ctx) {
    // TODO find better method to handle nested bit fields
    var parser = JSON.parse(JSON.stringify(this));
    parser.varName = ctx.generateVariable(parser.varName);
    ctx.bitFields.push(parser);

    if (!this.next || (this.next && ['Bit', 'Nest'].indexOf(this.next.type) < 0)) {
        var sum = 0;
        ctx.bitFields.forEach(function(parser) {
            sum += parser.options.length;
        });

        var val = ctx.generateTmpVariable();

        if (sum <= 8) {
            ctx.pushCode('var {0} = buffer.readUInt8(offset);', val);
            sum = 8;
        } else if (sum <= 16) {
            ctx.pushCode('var {0} = buffer.readUInt16BE(offset);', val);
            sum = 16;
        } else if (sum <= 24) {
            var val1 = ctx.generateTmpVariable();
            var val2 = ctx.generateTmpVariable();
            ctx.pushCode('var {0} = buffer.readUInt16BE(offset);', val1);
            ctx.pushCode('var {0} = buffer.readUInt8(offset + 2);', val2);
            ctx.pushCode('var {2} = ({0} << 8) | {1};', val1, val2, val);
            sum = 24;
        } else if (sum <= 32) {
            ctx.pushCode('var {0} = buffer.readUInt32BE(offset);', val);
            sum = 32;
        } else {
            throw new Error('Currently, bit field sequence longer than 4-bytes is not supported.');
        }
        ctx.pushCode('offset += {0};', sum / 8);

        var bitOffset = 0;
        var isBigEndian = this.endian === 'be';
        ctx.bitFields.forEach(function(parser) {
            ctx.pushCode('{0} = {1} >> {2} & {3};',
                parser.varName,
                val,
                isBigEndian ? sum - bitOffset - parser.options.length : bitOffset,
                (1 << parser.options.length) - 1
            );
            bitOffset += parser.options.length;
        });

        ctx.bitFields = [];
    }
};

Parser.prototype.generateSkip = function(ctx) {
    var length = ctx.generateOption(this.options.length);
    ctx.pushCode('offset += {0};', length);
};

Parser.prototype.generateString = function(ctx) {
    var name = ctx.generateVariable(this.varName);
    var start = ctx.generateTmpVariable();

    if (this.options.length && this.options.zeroTerminated) {
        ctx.pushCode('var {0} = offset;', start);
        ctx.pushCode('while(buffer.readUInt8(offset++) !== 0 && offset - {0}  < {1});',
            start,
            this.options.length
        );
        ctx.pushCode('{0} = buffer.toString(\'{1}\', {2}, offset - {2} < {3} ? offset - 1 : offset);',
            name,
            this.options.encoding,
            start,
            this.options.length
        );
    } else if(this.options.length) {
        ctx.pushCode('{0} = buffer.toString(\'{1}\', offset, offset + {2});',
                            name,
                            this.options.encoding,
                            ctx.generateOption(this.options.length)
                        );
        ctx.pushCode('offset += {0};', ctx.generateOption(this.options.length));
    } else if (this.options.zeroTerminated) {
        ctx.pushCode('var {0} = offset;', start);
        ctx.pushCode('while(buffer.readUInt8(offset++) !== 0);');
        ctx.pushCode('{0} = buffer.toString(\'{1}\', {2}, offset - 1);',
            name,
            this.options.encoding,
            start
        );
    } else if (this.options.greedy) {
        ctx.pushCode('var {0} = offset;', start);
        ctx.pushCode('while(buffer.length > offset++);');
        ctx.pushCode('{0} = buffer.toString(\'{1}\', {2}, offset);',
            name,
            this.options.encoding,
            start
        );
    }
    if(this.options.stripNull) {
        ctx.pushCode('{0} = {0}.replace(/\\x00+$/g, \'\')', name);
    }
};

Parser.prototype.generateBuffer = function(ctx) {
    if (this.options.readUntil === 'eof') {
        ctx.pushCode('{0} = buffer.slice(offset);',
            ctx.generateVariable(this.varName)
            );
    } else {
        ctx.pushCode('{0} = buffer.slice(offset, offset + {1});',
            ctx.generateVariable(this.varName),
            ctx.generateOption(this.options.length)
            );
        ctx.pushCode('offset += {0};', ctx.generateOption(this.options.length));
    }

    if (this.options.clone) {
        var buf = ctx.generateTmpVariable();

        ctx.pushCode('var {0} = new Buffer({1}.length);', buf, ctx.generateVariable(this.varName));
        ctx.pushCode('{0}.copy({1});', ctx.generateVariable(this.varName), buf);
        ctx.pushCode('{0} = {1}', ctx.generateVariable(this.varName), buf);
    }
};

Parser.prototype.generateArray = function(ctx) {
    var length = ctx.generateOption(this.options.length);
    var lengthInBytes = ctx.generateOption(this.options.lengthInBytes);
    var type = this.options.type;
    var counter = ctx.generateTmpVariable();
    var lhs = ctx.generateVariable(this.varName);
    var item = ctx.generateTmpVariable();
    var key = this.options.key;
    var isHash = typeof key === 'string';

    if (isHash) {
        ctx.pushCode('{0} = {};', lhs);
    } else {
        ctx.pushCode('{0} = [];', lhs);
    }
    if (typeof this.options.readUntil === 'function') {
        ctx.pushCode('do {');
    } else if (this.options.readUntil === 'eof') {
        ctx.pushCode('for (var {0} = 0; offset < buffer.length; {0}++) {', counter);
    } else if (lengthInBytes !== undefined) {
        ctx.pushCode('for (var {0} = offset; offset - {0} < {1}; ) {', counter, lengthInBytes);
    } else {
        ctx.pushCode('for (var {0} = 0; {0} < {1}; {0}++) {', counter, length);
    }

    if (typeof type === 'string') {
        if (!aliasRegistry[type]) {
            ctx.pushCode('var {0} = buffer.read{1}(offset);', item, NAME_MAP[type]);
            ctx.pushCode('offset += {0};', PRIMITIVE_TYPES[NAME_MAP[type]]);
        } else {
            var tempVar = ctx.generateTmpVariable();
            ctx.pushCode('var {0} = {1}(offset);', tempVar, FUNCTION_PREFIX + type);
            ctx.pushCode('var {0} = {1}.result; offset = {1}.offset;', item, tempVar);
            if (type !== this.alias) ctx.addReference(type);
        }
    } else if (type instanceof Parser) {
        ctx.pushCode('var {0} = {};', item);

        ctx.pushScope(item);
        type.generate(ctx);
        ctx.popScope();
    }

    if (isHash) {
        ctx.pushCode('{0}[{2}.{1}] = {2};', lhs, key, item);
    } else {
        ctx.pushCode('{0}.push({1});', lhs, item);
    }

    ctx.pushCode('}');

    if (typeof this.options.readUntil === 'function') {
        ctx.pushCode(' while (!({0}).call(this, {1}, buffer.slice(offset)));', this.options.readUntil, item);
    }
};

Parser.prototype.generateChoiceCase = function(ctx, varName, type) {
    if (typeof type === 'string') {
        if (!aliasRegistry[type]) {
            ctx.pushCode('{0} = buffer.read{1}(offset);', ctx.generateVariable(this.varName), NAME_MAP[type]);
            ctx.pushCode('offset += {0};', PRIMITIVE_TYPES[NAME_MAP[type]]);
        } else {
            var tempVar = ctx.generateTmpVariable();
            ctx.pushCode('var {0} = {1}(offset);', tempVar, FUNCTION_PREFIX + type);
            ctx.pushCode('{0} = {1}.result; offset = {1}.offset;', ctx.generateVariable(this.varName), tempVar);
            if (type !== this.alias) ctx.addReference(type);
        }
    } else if (type instanceof Parser) {
        ctx.pushPath(varName);
        type.generate(ctx);
        ctx.popPath(varName);
    }
};

Parser.prototype.generateChoice = function(ctx) {
    var tag = ctx.generateOption(this.options.tag);
    if (this.varName)
    {
        ctx.pushCode('{0} = {};', ctx.generateVariable(this.varName));
    }
    ctx.pushCode('switch({0}) {', tag);
    Object.keys(this.options.choices).forEach(function(tag) {
        var type = this.options.choices[tag];

        ctx.pushCode('case {0}:', tag);
        this.generateChoiceCase(ctx, this.varName, type);
        ctx.pushCode('break;');
    }, this);
    ctx.pushCode('default:');
    if (this.options.defaultChoice) {
        this.generateChoiceCase(ctx, this.varName, this.options.defaultChoice);
    } else {
        ctx.generateError('"Met undefined tag value " + {0} + " at choice"', tag);
    }
    ctx.pushCode('}');
};

Parser.prototype.generateNest = function(ctx) {
    var nestVar = ctx.generateVariable(this.varName);
    if (this.options.type instanceof Parser) {
        ctx.pushCode('{0} = {};', nestVar);
        ctx.pushPath(this.varName);
        this.options.type.generate(ctx);
        ctx.popPath(this.varName);
    } else if (aliasRegistry[this.options.type]) {
        var tempVar = ctx.generateTmpVariable();
        ctx.pushCode('var {0} = {1}(offset);', tempVar, FUNCTION_PREFIX + this.options.type);
        ctx.pushCode('{0} = {1}.result; offset = {1}.offset;', nestVar, tempVar);
        if (this.options.type !== this.alias) ctx.addReference(this.options.type);
    }
};

Parser.prototype.generateFormatter = function(ctx, varName, formatter) {
    if (typeof formatter === 'function') {
        ctx.pushCode('{0} = ({1}).call(this, {0});', varName, formatter);
    }
};

Parser.prototype.isInteger = function() {
    return !!this.type.match(/U?Int[8|16|32][BE|LE]?|Bit\d+/);
};

//========================================================================================
// Exports
//========================================================================================

exports.Parser = Parser;

},{"./context":3}],3:[function(require,module,exports){
//========================================================================================
// class Context
//========================================================================================

//----------------------------------------------------------------------------------------
// constructor
//----------------------------------------------------------------------------------------

var Context = function() {
    this.code = '';
    this.scopes = [['vars']];
    this.isAsync = false;
    this.bitFields = [];
    this.tmpVariableCount = 0;
    this.references = {};
};

//----------------------------------------------------------------------------------------
// public methods
//----------------------------------------------------------------------------------------

Context.prototype.generateVariable = function(name) {
    var arr = [];

    Array.prototype.push.apply(arr, this.scopes[this.scopes.length - 1]);
    if (name) {
        arr.push(name);
    }

    return arr.join('.');
};

Context.prototype.generateOption = function(val) {
    switch(typeof val) {
        case 'number':
            return val.toString();
        case 'string':
            return this.generateVariable(val);
        case 'function':
            return '(' + val + ').call(' + this.generateVariable() + ', vars)';
    }
};

Context.prototype.generateError = function() {
    var args = Array.prototype.slice.call(arguments);
    var err = Context.interpolate.apply(this, args);

    if (this.isAsync) {
        this.pushCode('return process.nextTick(function() { callback(new Error(' + err + '), vars); });');
    } else {
        this.pushCode('throw new Error(' + err + ');');
    }
};

Context.prototype.generateTmpVariable = function() {
    return '$tmp' + (this.tmpVariableCount++);
};

Context.prototype.pushCode = function() {
    var args = Array.prototype.slice.call(arguments);

    this.code += Context.interpolate.apply(this, args) + '\n';
};

Context.prototype.pushPath = function(name) {
    if (name)
    {
    	this.scopes[this.scopes.length - 1].push(name);
    }
};

Context.prototype.popPath = function(name) {
    if (name)
   { 
   	this.scopes[this.scopes.length - 1].pop();
   }
};

Context.prototype.pushScope = function(name) {
    this.scopes.push([name]);
};

Context.prototype.popScope = function() {
    this.scopes.pop();
};

Context.prototype.addReference = function(alias) {
    if (this.references[alias]) return;
    this.references[alias] = { resolved: false, requested: false };
};

Context.prototype.markResolved = function(alias) {
    this.references[alias].resolved = true;
};

Context.prototype.markRequested = function(aliasList) {
    aliasList.forEach(function(alias) {
        this.references[alias].requested = true;
    }.bind(this));
};

Context.prototype.getUnresolvedReferences = function() {
    var references = this.references;
    return Object.keys(this.references).filter(function(alias) {
        return !references[alias].resolved && !references[alias].requested;
    });
};

//----------------------------------------------------------------------------------------
// private methods
//----------------------------------------------------------------------------------------

Context.interpolate = function(s) {
    var re = /{\d+}/g;
    var matches = s.match(re);
    var params = Array.prototype.slice.call(arguments, 1);

    if (matches) {
        matches.forEach(function(match) {
            var index = parseInt(match.substr(1, match.length - 2), 10);
            s = s.replace(match, params[index].toString());
        });
    }

    return s;
};

exports.Context = Context;

},{}],4:[function(require,module,exports){
/*!
 * The buffer module from node.js, for the browser.
 *
 * @author   Feross Aboukhadijeh <https://feross.org>
 * @license  MIT
 */
/* eslint-disable no-proto */

'use strict'

var base64 = require('base64-js')
var ieee754 = require('ieee754')

exports.Buffer = Buffer
exports.SlowBuffer = SlowBuffer
exports.INSPECT_MAX_BYTES = 50

var K_MAX_LENGTH = 0x7fffffff
exports.kMaxLength = K_MAX_LENGTH

/**
 * If `Buffer.TYPED_ARRAY_SUPPORT`:
 *   === true    Use Uint8Array implementation (fastest)
 *   === false   Print warning and recommend using `buffer` v4.x which has an Object
 *               implementation (most compatible, even IE6)
 *
 * Browsers that support typed arrays are IE 10+, Firefox 4+, Chrome 7+, Safari 5.1+,
 * Opera 11.6+, iOS 4.2+.
 *
 * We report that the browser does not support typed arrays if the are not subclassable
 * using __proto__. Firefox 4-29 lacks support for adding new properties to `Uint8Array`
 * (See: https://bugzilla.mozilla.org/show_bug.cgi?id=695438). IE 10 lacks support
 * for __proto__ and has a buggy typed array implementation.
 */
Buffer.TYPED_ARRAY_SUPPORT = typedArraySupport()

if (!Buffer.TYPED_ARRAY_SUPPORT && typeof console !== 'undefined' &&
    typeof console.error === 'function') {
  console.error(
    'This browser lacks typed array (Uint8Array) support which is required by ' +
    '`buffer` v5.x. Use `buffer` v4.x if you require old browser support.'
  )
}

function typedArraySupport () {
  // Can typed array instances can be augmented?
  try {
    var arr = new Uint8Array(1)
    arr.__proto__ = {__proto__: Uint8Array.prototype, foo: function () { return 42 }}
    return arr.foo() === 42
  } catch (e) {
    return false
  }
}

function createBuffer (length) {
  if (length > K_MAX_LENGTH) {
    throw new RangeError('Invalid typed array length')
  }
  // Return an augmented `Uint8Array` instance
  var buf = new Uint8Array(length)
  buf.__proto__ = Buffer.prototype
  return buf
}

/**
 * The Buffer constructor returns instances of `Uint8Array` that have their
 * prototype changed to `Buffer.prototype`. Furthermore, `Buffer` is a subclass of
 * `Uint8Array`, so the returned instances will have all the node `Buffer` methods
 * and the `Uint8Array` methods. Square bracket notation works as expected -- it
 * returns a single octet.
 *
 * The `Uint8Array` prototype remains unmodified.
 */

function Buffer (arg, encodingOrOffset, length) {
  // Common case.
  if (typeof arg === 'number') {
    if (typeof encodingOrOffset === 'string') {
      throw new Error(
        'If encoding is specified then the first argument must be a string'
      )
    }
    return allocUnsafe(arg)
  }
  return from(arg, encodingOrOffset, length)
}

// Fix subarray() in ES2016. See: https://github.com/feross/buffer/pull/97
if (typeof Symbol !== 'undefined' && Symbol.species &&
    Buffer[Symbol.species] === Buffer) {
  Object.defineProperty(Buffer, Symbol.species, {
    value: null,
    configurable: true,
    enumerable: false,
    writable: false
  })
}

Buffer.poolSize = 8192 // not used by this implementation

function from (value, encodingOrOffset, length) {
  if (typeof value === 'number') {
    throw new TypeError('"value" argument must not be a number')
  }

  if (isArrayBuffer(value)) {
    return fromArrayBuffer(value, encodingOrOffset, length)
  }

  if (typeof value === 'string') {
    return fromString(value, encodingOrOffset)
  }

  return fromObject(value)
}

/**
 * Functionally equivalent to Buffer(arg, encoding) but throws a TypeError
 * if value is a number.
 * Buffer.from(str[, encoding])
 * Buffer.from(array)
 * Buffer.from(buffer)
 * Buffer.from(arrayBuffer[, byteOffset[, length]])
 **/
Buffer.from = function (value, encodingOrOffset, length) {
  return from(value, encodingOrOffset, length)
}

// Note: Change prototype *after* Buffer.from is defined to workaround Chrome bug:
// https://github.com/feross/buffer/pull/148
Buffer.prototype.__proto__ = Uint8Array.prototype
Buffer.__proto__ = Uint8Array

function assertSize (size) {
  if (typeof size !== 'number') {
    throw new TypeError('"size" argument must be a number')
  } else if (size < 0) {
    throw new RangeError('"size" argument must not be negative')
  }
}

function alloc (size, fill, encoding) {
  assertSize(size)
  if (size <= 0) {
    return createBuffer(size)
  }
  if (fill !== undefined) {
    // Only pay attention to encoding if it's a string. This
    // prevents accidentally sending in a number that would
    // be interpretted as a start offset.
    return typeof encoding === 'string'
      ? createBuffer(size).fill(fill, encoding)
      : createBuffer(size).fill(fill)
  }
  return createBuffer(size)
}

/**
 * Creates a new filled Buffer instance.
 * alloc(size[, fill[, encoding]])
 **/
Buffer.alloc = function (size, fill, encoding) {
  return alloc(size, fill, encoding)
}

function allocUnsafe (size) {
  assertSize(size)
  return createBuffer(size < 0 ? 0 : checked(size) | 0)
}

/**
 * Equivalent to Buffer(num), by default creates a non-zero-filled Buffer instance.
 * */
Buffer.allocUnsafe = function (size) {
  return allocUnsafe(size)
}
/**
 * Equivalent to SlowBuffer(num), by default creates a non-zero-filled Buffer instance.
 */
Buffer.allocUnsafeSlow = function (size) {
  return allocUnsafe(size)
}

function fromString (string, encoding) {
  if (typeof encoding !== 'string' || encoding === '') {
    encoding = 'utf8'
  }

  if (!Buffer.isEncoding(encoding)) {
    throw new TypeError('"encoding" must be a valid string encoding')
  }

  var length = byteLength(string, encoding) | 0
  var buf = createBuffer(length)

  var actual = buf.write(string, encoding)

  if (actual !== length) {
    // Writing a hex string, for example, that contains invalid characters will
    // cause everything after the first invalid character to be ignored. (e.g.
    // 'abxxcd' will be treated as 'ab')
    buf = buf.slice(0, actual)
  }

  return buf
}

function fromArrayLike (array) {
  var length = array.length < 0 ? 0 : checked(array.length) | 0
  var buf = createBuffer(length)
  for (var i = 0; i < length; i += 1) {
    buf[i] = array[i] & 255
  }
  return buf
}

function fromArrayBuffer (array, byteOffset, length) {
  if (byteOffset < 0 || array.byteLength < byteOffset) {
    throw new RangeError('\'offset\' is out of bounds')
  }

  if (array.byteLength < byteOffset + (length || 0)) {
    throw new RangeError('\'length\' is out of bounds')
  }

  var buf
  if (byteOffset === undefined && length === undefined) {
    buf = new Uint8Array(array)
  } else if (length === undefined) {
    buf = new Uint8Array(array, byteOffset)
  } else {
    buf = new Uint8Array(array, byteOffset, length)
  }

  // Return an augmented `Uint8Array` instance
  buf.__proto__ = Buffer.prototype
  return buf
}

function fromObject (obj) {
  if (Buffer.isBuffer(obj)) {
    var len = checked(obj.length) | 0
    var buf = createBuffer(len)

    if (buf.length === 0) {
      return buf
    }

    obj.copy(buf, 0, 0, len)
    return buf
  }

  if (obj) {
    if (isArrayBufferView(obj) || 'length' in obj) {
      if (typeof obj.length !== 'number' || numberIsNaN(obj.length)) {
        return createBuffer(0)
      }
      return fromArrayLike(obj)
    }

    if (obj.type === 'Buffer' && Array.isArray(obj.data)) {
      return fromArrayLike(obj.data)
    }
  }

  throw new TypeError('First argument must be a string, Buffer, ArrayBuffer, Array, or array-like object.')
}

function checked (length) {
  // Note: cannot use `length < K_MAX_LENGTH` here because that fails when
  // length is NaN (which is otherwise coerced to zero.)
  if (length >= K_MAX_LENGTH) {
    throw new RangeError('Attempt to allocate Buffer larger than maximum ' +
                         'size: 0x' + K_MAX_LENGTH.toString(16) + ' bytes')
  }
  return length | 0
}

function SlowBuffer (length) {
  if (+length != length) { // eslint-disable-line eqeqeq
    length = 0
  }
  return Buffer.alloc(+length)
}

Buffer.isBuffer = function isBuffer (b) {
  return b != null && b._isBuffer === true
}

Buffer.compare = function compare (a, b) {
  if (!Buffer.isBuffer(a) || !Buffer.isBuffer(b)) {
    throw new TypeError('Arguments must be Buffers')
  }

  if (a === b) return 0

  var x = a.length
  var y = b.length

  for (var i = 0, len = Math.min(x, y); i < len; ++i) {
    if (a[i] !== b[i]) {
      x = a[i]
      y = b[i]
      break
    }
  }

  if (x < y) return -1
  if (y < x) return 1
  return 0
}

Buffer.isEncoding = function isEncoding (encoding) {
  switch (String(encoding).toLowerCase()) {
    case 'hex':
    case 'utf8':
    case 'utf-8':
    case 'ascii':
    case 'latin1':
    case 'binary':
    case 'base64':
    case 'ucs2':
    case 'ucs-2':
    case 'utf16le':
    case 'utf-16le':
      return true
    default:
      return false
  }
}

Buffer.concat = function concat (list, length) {
  if (!Array.isArray(list)) {
    throw new TypeError('"list" argument must be an Array of Buffers')
  }

  if (list.length === 0) {
    return Buffer.alloc(0)
  }

  var i
  if (length === undefined) {
    length = 0
    for (i = 0; i < list.length; ++i) {
      length += list[i].length
    }
  }

  var buffer = Buffer.allocUnsafe(length)
  var pos = 0
  for (i = 0; i < list.length; ++i) {
    var buf = list[i]
    if (!Buffer.isBuffer(buf)) {
      throw new TypeError('"list" argument must be an Array of Buffers')
    }
    buf.copy(buffer, pos)
    pos += buf.length
  }
  return buffer
}

function byteLength (string, encoding) {
  if (Buffer.isBuffer(string)) {
    return string.length
  }
  if (isArrayBufferView(string) || isArrayBuffer(string)) {
    return string.byteLength
  }
  if (typeof string !== 'string') {
    string = '' + string
  }

  var len = string.length
  if (len === 0) return 0

  // Use a for loop to avoid recursion
  var loweredCase = false
  for (;;) {
    switch (encoding) {
      case 'ascii':
      case 'latin1':
      case 'binary':
        return len
      case 'utf8':
      case 'utf-8':
      case undefined:
        return utf8ToBytes(string).length
      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return len * 2
      case 'hex':
        return len >>> 1
      case 'base64':
        return base64ToBytes(string).length
      default:
        if (loweredCase) return utf8ToBytes(string).length // assume utf8
        encoding = ('' + encoding).toLowerCase()
        loweredCase = true
    }
  }
}
Buffer.byteLength = byteLength

function slowToString (encoding, start, end) {
  var loweredCase = false

  // No need to verify that "this.length <= MAX_UINT32" since it's a read-only
  // property of a typed array.

  // This behaves neither like String nor Uint8Array in that we set start/end
  // to their upper/lower bounds if the value passed is out of range.
  // undefined is handled specially as per ECMA-262 6th Edition,
  // Section 13.3.3.7 Runtime Semantics: KeyedBindingInitialization.
  if (start === undefined || start < 0) {
    start = 0
  }
  // Return early if start > this.length. Done here to prevent potential uint32
  // coercion fail below.
  if (start > this.length) {
    return ''
  }

  if (end === undefined || end > this.length) {
    end = this.length
  }

  if (end <= 0) {
    return ''
  }

  // Force coersion to uint32. This will also coerce falsey/NaN values to 0.
  end >>>= 0
  start >>>= 0

  if (end <= start) {
    return ''
  }

  if (!encoding) encoding = 'utf8'

  while (true) {
    switch (encoding) {
      case 'hex':
        return hexSlice(this, start, end)

      case 'utf8':
      case 'utf-8':
        return utf8Slice(this, start, end)

      case 'ascii':
        return asciiSlice(this, start, end)

      case 'latin1':
      case 'binary':
        return latin1Slice(this, start, end)

      case 'base64':
        return base64Slice(this, start, end)

      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return utf16leSlice(this, start, end)

      default:
        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
        encoding = (encoding + '').toLowerCase()
        loweredCase = true
    }
  }
}

// This property is used by `Buffer.isBuffer` (and the `is-buffer` npm package)
// to detect a Buffer instance. It's not possible to use `instanceof Buffer`
// reliably in a browserify context because there could be multiple different
// copies of the 'buffer' package in use. This method works even for Buffer
// instances that were created from another copy of the `buffer` package.
// See: https://github.com/feross/buffer/issues/154
Buffer.prototype._isBuffer = true

function swap (b, n, m) {
  var i = b[n]
  b[n] = b[m]
  b[m] = i
}

Buffer.prototype.swap16 = function swap16 () {
  var len = this.length
  if (len % 2 !== 0) {
    throw new RangeError('Buffer size must be a multiple of 16-bits')
  }
  for (var i = 0; i < len; i += 2) {
    swap(this, i, i + 1)
  }
  return this
}

Buffer.prototype.swap32 = function swap32 () {
  var len = this.length
  if (len % 4 !== 0) {
    throw new RangeError('Buffer size must be a multiple of 32-bits')
  }
  for (var i = 0; i < len; i += 4) {
    swap(this, i, i + 3)
    swap(this, i + 1, i + 2)
  }
  return this
}

Buffer.prototype.swap64 = function swap64 () {
  var len = this.length
  if (len % 8 !== 0) {
    throw new RangeError('Buffer size must be a multiple of 64-bits')
  }
  for (var i = 0; i < len; i += 8) {
    swap(this, i, i + 7)
    swap(this, i + 1, i + 6)
    swap(this, i + 2, i + 5)
    swap(this, i + 3, i + 4)
  }
  return this
}

Buffer.prototype.toString = function toString () {
  var length = this.length
  if (length === 0) return ''
  if (arguments.length === 0) return utf8Slice(this, 0, length)
  return slowToString.apply(this, arguments)
}

Buffer.prototype.equals = function equals (b) {
  if (!Buffer.isBuffer(b)) throw new TypeError('Argument must be a Buffer')
  if (this === b) return true
  return Buffer.compare(this, b) === 0
}

Buffer.prototype.inspect = function inspect () {
  var str = ''
  var max = exports.INSPECT_MAX_BYTES
  if (this.length > 0) {
    str = this.toString('hex', 0, max).match(/.{2}/g).join(' ')
    if (this.length > max) str += ' ... '
  }
  return '<Buffer ' + str + '>'
}

Buffer.prototype.compare = function compare (target, start, end, thisStart, thisEnd) {
  if (!Buffer.isBuffer(target)) {
    throw new TypeError('Argument must be a Buffer')
  }

  if (start === undefined) {
    start = 0
  }
  if (end === undefined) {
    end = target ? target.length : 0
  }
  if (thisStart === undefined) {
    thisStart = 0
  }
  if (thisEnd === undefined) {
    thisEnd = this.length
  }

  if (start < 0 || end > target.length || thisStart < 0 || thisEnd > this.length) {
    throw new RangeError('out of range index')
  }

  if (thisStart >= thisEnd && start >= end) {
    return 0
  }
  if (thisStart >= thisEnd) {
    return -1
  }
  if (start >= end) {
    return 1
  }

  start >>>= 0
  end >>>= 0
  thisStart >>>= 0
  thisEnd >>>= 0

  if (this === target) return 0

  var x = thisEnd - thisStart
  var y = end - start
  var len = Math.min(x, y)

  var thisCopy = this.slice(thisStart, thisEnd)
  var targetCopy = target.slice(start, end)

  for (var i = 0; i < len; ++i) {
    if (thisCopy[i] !== targetCopy[i]) {
      x = thisCopy[i]
      y = targetCopy[i]
      break
    }
  }

  if (x < y) return -1
  if (y < x) return 1
  return 0
}

// Finds either the first index of `val` in `buffer` at offset >= `byteOffset`,
// OR the last index of `val` in `buffer` at offset <= `byteOffset`.
//
// Arguments:
// - buffer - a Buffer to search
// - val - a string, Buffer, or number
// - byteOffset - an index into `buffer`; will be clamped to an int32
// - encoding - an optional encoding, relevant is val is a string
// - dir - true for indexOf, false for lastIndexOf
function bidirectionalIndexOf (buffer, val, byteOffset, encoding, dir) {
  // Empty buffer means no match
  if (buffer.length === 0) return -1

  // Normalize byteOffset
  if (typeof byteOffset === 'string') {
    encoding = byteOffset
    byteOffset = 0
  } else if (byteOffset > 0x7fffffff) {
    byteOffset = 0x7fffffff
  } else if (byteOffset < -0x80000000) {
    byteOffset = -0x80000000
  }
  byteOffset = +byteOffset  // Coerce to Number.
  if (numberIsNaN(byteOffset)) {
    // byteOffset: it it's undefined, null, NaN, "foo", etc, search whole buffer
    byteOffset = dir ? 0 : (buffer.length - 1)
  }

  // Normalize byteOffset: negative offsets start from the end of the buffer
  if (byteOffset < 0) byteOffset = buffer.length + byteOffset
  if (byteOffset >= buffer.length) {
    if (dir) return -1
    else byteOffset = buffer.length - 1
  } else if (byteOffset < 0) {
    if (dir) byteOffset = 0
    else return -1
  }

  // Normalize val
  if (typeof val === 'string') {
    val = Buffer.from(val, encoding)
  }

  // Finally, search either indexOf (if dir is true) or lastIndexOf
  if (Buffer.isBuffer(val)) {
    // Special case: looking for empty string/buffer always fails
    if (val.length === 0) {
      return -1
    }
    return arrayIndexOf(buffer, val, byteOffset, encoding, dir)
  } else if (typeof val === 'number') {
    val = val & 0xFF // Search for a byte value [0-255]
    if (typeof Uint8Array.prototype.indexOf === 'function') {
      if (dir) {
        return Uint8Array.prototype.indexOf.call(buffer, val, byteOffset)
      } else {
        return Uint8Array.prototype.lastIndexOf.call(buffer, val, byteOffset)
      }
    }
    return arrayIndexOf(buffer, [ val ], byteOffset, encoding, dir)
  }

  throw new TypeError('val must be string, number or Buffer')
}

function arrayIndexOf (arr, val, byteOffset, encoding, dir) {
  var indexSize = 1
  var arrLength = arr.length
  var valLength = val.length

  if (encoding !== undefined) {
    encoding = String(encoding).toLowerCase()
    if (encoding === 'ucs2' || encoding === 'ucs-2' ||
        encoding === 'utf16le' || encoding === 'utf-16le') {
      if (arr.length < 2 || val.length < 2) {
        return -1
      }
      indexSize = 2
      arrLength /= 2
      valLength /= 2
      byteOffset /= 2
    }
  }

  function read (buf, i) {
    if (indexSize === 1) {
      return buf[i]
    } else {
      return buf.readUInt16BE(i * indexSize)
    }
  }

  var i
  if (dir) {
    var foundIndex = -1
    for (i = byteOffset; i < arrLength; i++) {
      if (read(arr, i) === read(val, foundIndex === -1 ? 0 : i - foundIndex)) {
        if (foundIndex === -1) foundIndex = i
        if (i - foundIndex + 1 === valLength) return foundIndex * indexSize
      } else {
        if (foundIndex !== -1) i -= i - foundIndex
        foundIndex = -1
      }
    }
  } else {
    if (byteOffset + valLength > arrLength) byteOffset = arrLength - valLength
    for (i = byteOffset; i >= 0; i--) {
      var found = true
      for (var j = 0; j < valLength; j++) {
        if (read(arr, i + j) !== read(val, j)) {
          found = false
          break
        }
      }
      if (found) return i
    }
  }

  return -1
}

Buffer.prototype.includes = function includes (val, byteOffset, encoding) {
  return this.indexOf(val, byteOffset, encoding) !== -1
}

Buffer.prototype.indexOf = function indexOf (val, byteOffset, encoding) {
  return bidirectionalIndexOf(this, val, byteOffset, encoding, true)
}

Buffer.prototype.lastIndexOf = function lastIndexOf (val, byteOffset, encoding) {
  return bidirectionalIndexOf(this, val, byteOffset, encoding, false)
}

function hexWrite (buf, string, offset, length) {
  offset = Number(offset) || 0
  var remaining = buf.length - offset
  if (!length) {
    length = remaining
  } else {
    length = Number(length)
    if (length > remaining) {
      length = remaining
    }
  }

  // must be an even number of digits
  var strLen = string.length
  if (strLen % 2 !== 0) throw new TypeError('Invalid hex string')

  if (length > strLen / 2) {
    length = strLen / 2
  }
  for (var i = 0; i < length; ++i) {
    var parsed = parseInt(string.substr(i * 2, 2), 16)
    if (numberIsNaN(parsed)) return i
    buf[offset + i] = parsed
  }
  return i
}

function utf8Write (buf, string, offset, length) {
  return blitBuffer(utf8ToBytes(string, buf.length - offset), buf, offset, length)
}

function asciiWrite (buf, string, offset, length) {
  return blitBuffer(asciiToBytes(string), buf, offset, length)
}

function latin1Write (buf, string, offset, length) {
  return asciiWrite(buf, string, offset, length)
}

function base64Write (buf, string, offset, length) {
  return blitBuffer(base64ToBytes(string), buf, offset, length)
}

function ucs2Write (buf, string, offset, length) {
  return blitBuffer(utf16leToBytes(string, buf.length - offset), buf, offset, length)
}

Buffer.prototype.write = function write (string, offset, length, encoding) {
  // Buffer#write(string)
  if (offset === undefined) {
    encoding = 'utf8'
    length = this.length
    offset = 0
  // Buffer#write(string, encoding)
  } else if (length === undefined && typeof offset === 'string') {
    encoding = offset
    length = this.length
    offset = 0
  // Buffer#write(string, offset[, length][, encoding])
  } else if (isFinite(offset)) {
    offset = offset >>> 0
    if (isFinite(length)) {
      length = length >>> 0
      if (encoding === undefined) encoding = 'utf8'
    } else {
      encoding = length
      length = undefined
    }
  } else {
    throw new Error(
      'Buffer.write(string, encoding, offset[, length]) is no longer supported'
    )
  }

  var remaining = this.length - offset
  if (length === undefined || length > remaining) length = remaining

  if ((string.length > 0 && (length < 0 || offset < 0)) || offset > this.length) {
    throw new RangeError('Attempt to write outside buffer bounds')
  }

  if (!encoding) encoding = 'utf8'

  var loweredCase = false
  for (;;) {
    switch (encoding) {
      case 'hex':
        return hexWrite(this, string, offset, length)

      case 'utf8':
      case 'utf-8':
        return utf8Write(this, string, offset, length)

      case 'ascii':
        return asciiWrite(this, string, offset, length)

      case 'latin1':
      case 'binary':
        return latin1Write(this, string, offset, length)

      case 'base64':
        // Warning: maxLength not taken into account in base64Write
        return base64Write(this, string, offset, length)

      case 'ucs2':
      case 'ucs-2':
      case 'utf16le':
      case 'utf-16le':
        return ucs2Write(this, string, offset, length)

      default:
        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
        encoding = ('' + encoding).toLowerCase()
        loweredCase = true
    }
  }
}

Buffer.prototype.toJSON = function toJSON () {
  return {
    type: 'Buffer',
    data: Array.prototype.slice.call(this._arr || this, 0)
  }
}

function base64Slice (buf, start, end) {
  if (start === 0 && end === buf.length) {
    return base64.fromByteArray(buf)
  } else {
    return base64.fromByteArray(buf.slice(start, end))
  }
}

function utf8Slice (buf, start, end) {
  end = Math.min(buf.length, end)
  var res = []

  var i = start
  while (i < end) {
    var firstByte = buf[i]
    var codePoint = null
    var bytesPerSequence = (firstByte > 0xEF) ? 4
      : (firstByte > 0xDF) ? 3
      : (firstByte > 0xBF) ? 2
      : 1

    if (i + bytesPerSequence <= end) {
      var secondByte, thirdByte, fourthByte, tempCodePoint

      switch (bytesPerSequence) {
        case 1:
          if (firstByte < 0x80) {
            codePoint = firstByte
          }
          break
        case 2:
          secondByte = buf[i + 1]
          if ((secondByte & 0xC0) === 0x80) {
            tempCodePoint = (firstByte & 0x1F) << 0x6 | (secondByte & 0x3F)
            if (tempCodePoint > 0x7F) {
              codePoint = tempCodePoint
            }
          }
          break
        case 3:
          secondByte = buf[i + 1]
          thirdByte = buf[i + 2]
          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80) {
            tempCodePoint = (firstByte & 0xF) << 0xC | (secondByte & 0x3F) << 0x6 | (thirdByte & 0x3F)
            if (tempCodePoint > 0x7FF && (tempCodePoint < 0xD800 || tempCodePoint > 0xDFFF)) {
              codePoint = tempCodePoint
            }
          }
          break
        case 4:
          secondByte = buf[i + 1]
          thirdByte = buf[i + 2]
          fourthByte = buf[i + 3]
          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80 && (fourthByte & 0xC0) === 0x80) {
            tempCodePoint = (firstByte & 0xF) << 0x12 | (secondByte & 0x3F) << 0xC | (thirdByte & 0x3F) << 0x6 | (fourthByte & 0x3F)
            if (tempCodePoint > 0xFFFF && tempCodePoint < 0x110000) {
              codePoint = tempCodePoint
            }
          }
      }
    }

    if (codePoint === null) {
      // we did not generate a valid codePoint so insert a
      // replacement char (U+FFFD) and advance only 1 byte
      codePoint = 0xFFFD
      bytesPerSequence = 1
    } else if (codePoint > 0xFFFF) {
      // encode to utf16 (surrogate pair dance)
      codePoint -= 0x10000
      res.push(codePoint >>> 10 & 0x3FF | 0xD800)
      codePoint = 0xDC00 | codePoint & 0x3FF
    }

    res.push(codePoint)
    i += bytesPerSequence
  }

  return decodeCodePointsArray(res)
}

// Based on http://stackoverflow.com/a/22747272/680742, the browser with
// the lowest limit is Chrome, with 0x10000 args.
// We go 1 magnitude less, for safety
var MAX_ARGUMENTS_LENGTH = 0x1000

function decodeCodePointsArray (codePoints) {
  var len = codePoints.length
  if (len <= MAX_ARGUMENTS_LENGTH) {
    return String.fromCharCode.apply(String, codePoints) // avoid extra slice()
  }

  // Decode in chunks to avoid "call stack size exceeded".
  var res = ''
  var i = 0
  while (i < len) {
    res += String.fromCharCode.apply(
      String,
      codePoints.slice(i, i += MAX_ARGUMENTS_LENGTH)
    )
  }
  return res
}

function asciiSlice (buf, start, end) {
  var ret = ''
  end = Math.min(buf.length, end)

  for (var i = start; i < end; ++i) {
    ret += String.fromCharCode(buf[i] & 0x7F)
  }
  return ret
}

function latin1Slice (buf, start, end) {
  var ret = ''
  end = Math.min(buf.length, end)

  for (var i = start; i < end; ++i) {
    ret += String.fromCharCode(buf[i])
  }
  return ret
}

function hexSlice (buf, start, end) {
  var len = buf.length

  if (!start || start < 0) start = 0
  if (!end || end < 0 || end > len) end = len

  var out = ''
  for (var i = start; i < end; ++i) {
    out += toHex(buf[i])
  }
  return out
}

function utf16leSlice (buf, start, end) {
  var bytes = buf.slice(start, end)
  var res = ''
  for (var i = 0; i < bytes.length; i += 2) {
    res += String.fromCharCode(bytes[i] + (bytes[i + 1] * 256))
  }
  return res
}

Buffer.prototype.slice = function slice (start, end) {
  var len = this.length
  start = ~~start
  end = end === undefined ? len : ~~end

  if (start < 0) {
    start += len
    if (start < 0) start = 0
  } else if (start > len) {
    start = len
  }

  if (end < 0) {
    end += len
    if (end < 0) end = 0
  } else if (end > len) {
    end = len
  }

  if (end < start) end = start

  var newBuf = this.subarray(start, end)
  // Return an augmented `Uint8Array` instance
  newBuf.__proto__ = Buffer.prototype
  return newBuf
}

/*
 * Need to make sure that buffer isn't trying to write out of bounds.
 */
function checkOffset (offset, ext, length) {
  if ((offset % 1) !== 0 || offset < 0) throw new RangeError('offset is not uint')
  if (offset + ext > length) throw new RangeError('Trying to access beyond buffer length')
}

Buffer.prototype.readUIntLE = function readUIntLE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) checkOffset(offset, byteLength, this.length)

  var val = this[offset]
  var mul = 1
  var i = 0
  while (++i < byteLength && (mul *= 0x100)) {
    val += this[offset + i] * mul
  }

  return val
}

Buffer.prototype.readUIntBE = function readUIntBE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) {
    checkOffset(offset, byteLength, this.length)
  }

  var val = this[offset + --byteLength]
  var mul = 1
  while (byteLength > 0 && (mul *= 0x100)) {
    val += this[offset + --byteLength] * mul
  }

  return val
}

Buffer.prototype.readUInt8 = function readUInt8 (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 1, this.length)
  return this[offset]
}

Buffer.prototype.readUInt16LE = function readUInt16LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  return this[offset] | (this[offset + 1] << 8)
}

Buffer.prototype.readUInt16BE = function readUInt16BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  return (this[offset] << 8) | this[offset + 1]
}

Buffer.prototype.readUInt32LE = function readUInt32LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return ((this[offset]) |
      (this[offset + 1] << 8) |
      (this[offset + 2] << 16)) +
      (this[offset + 3] * 0x1000000)
}

Buffer.prototype.readUInt32BE = function readUInt32BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return (this[offset] * 0x1000000) +
    ((this[offset + 1] << 16) |
    (this[offset + 2] << 8) |
    this[offset + 3])
}

Buffer.prototype.readIntLE = function readIntLE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) checkOffset(offset, byteLength, this.length)

  var val = this[offset]
  var mul = 1
  var i = 0
  while (++i < byteLength && (mul *= 0x100)) {
    val += this[offset + i] * mul
  }
  mul *= 0x80

  if (val >= mul) val -= Math.pow(2, 8 * byteLength)

  return val
}

Buffer.prototype.readIntBE = function readIntBE (offset, byteLength, noAssert) {
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) checkOffset(offset, byteLength, this.length)

  var i = byteLength
  var mul = 1
  var val = this[offset + --i]
  while (i > 0 && (mul *= 0x100)) {
    val += this[offset + --i] * mul
  }
  mul *= 0x80

  if (val >= mul) val -= Math.pow(2, 8 * byteLength)

  return val
}

Buffer.prototype.readInt8 = function readInt8 (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 1, this.length)
  if (!(this[offset] & 0x80)) return (this[offset])
  return ((0xff - this[offset] + 1) * -1)
}

Buffer.prototype.readInt16LE = function readInt16LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  var val = this[offset] | (this[offset + 1] << 8)
  return (val & 0x8000) ? val | 0xFFFF0000 : val
}

Buffer.prototype.readInt16BE = function readInt16BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 2, this.length)
  var val = this[offset + 1] | (this[offset] << 8)
  return (val & 0x8000) ? val | 0xFFFF0000 : val
}

Buffer.prototype.readInt32LE = function readInt32LE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return (this[offset]) |
    (this[offset + 1] << 8) |
    (this[offset + 2] << 16) |
    (this[offset + 3] << 24)
}

Buffer.prototype.readInt32BE = function readInt32BE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)

  return (this[offset] << 24) |
    (this[offset + 1] << 16) |
    (this[offset + 2] << 8) |
    (this[offset + 3])
}

Buffer.prototype.readFloatLE = function readFloatLE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)
  return ieee754.read(this, offset, true, 23, 4)
}

Buffer.prototype.readFloatBE = function readFloatBE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 4, this.length)
  return ieee754.read(this, offset, false, 23, 4)
}

Buffer.prototype.readDoubleLE = function readDoubleLE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 8, this.length)
  return ieee754.read(this, offset, true, 52, 8)
}

Buffer.prototype.readDoubleBE = function readDoubleBE (offset, noAssert) {
  offset = offset >>> 0
  if (!noAssert) checkOffset(offset, 8, this.length)
  return ieee754.read(this, offset, false, 52, 8)
}

function checkInt (buf, value, offset, ext, max, min) {
  if (!Buffer.isBuffer(buf)) throw new TypeError('"buffer" argument must be a Buffer instance')
  if (value > max || value < min) throw new RangeError('"value" argument is out of bounds')
  if (offset + ext > buf.length) throw new RangeError('Index out of range')
}

Buffer.prototype.writeUIntLE = function writeUIntLE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) {
    var maxBytes = Math.pow(2, 8 * byteLength) - 1
    checkInt(this, value, offset, byteLength, maxBytes, 0)
  }

  var mul = 1
  var i = 0
  this[offset] = value & 0xFF
  while (++i < byteLength && (mul *= 0x100)) {
    this[offset + i] = (value / mul) & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeUIntBE = function writeUIntBE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  byteLength = byteLength >>> 0
  if (!noAssert) {
    var maxBytes = Math.pow(2, 8 * byteLength) - 1
    checkInt(this, value, offset, byteLength, maxBytes, 0)
  }

  var i = byteLength - 1
  var mul = 1
  this[offset + i] = value & 0xFF
  while (--i >= 0 && (mul *= 0x100)) {
    this[offset + i] = (value / mul) & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeUInt8 = function writeUInt8 (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 1, 0xff, 0)
  this[offset] = (value & 0xff)
  return offset + 1
}

Buffer.prototype.writeUInt16LE = function writeUInt16LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
  this[offset] = (value & 0xff)
  this[offset + 1] = (value >>> 8)
  return offset + 2
}

Buffer.prototype.writeUInt16BE = function writeUInt16BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
  this[offset] = (value >>> 8)
  this[offset + 1] = (value & 0xff)
  return offset + 2
}

Buffer.prototype.writeUInt32LE = function writeUInt32LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
  this[offset + 3] = (value >>> 24)
  this[offset + 2] = (value >>> 16)
  this[offset + 1] = (value >>> 8)
  this[offset] = (value & 0xff)
  return offset + 4
}

Buffer.prototype.writeUInt32BE = function writeUInt32BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
  this[offset] = (value >>> 24)
  this[offset + 1] = (value >>> 16)
  this[offset + 2] = (value >>> 8)
  this[offset + 3] = (value & 0xff)
  return offset + 4
}

Buffer.prototype.writeIntLE = function writeIntLE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    var limit = Math.pow(2, (8 * byteLength) - 1)

    checkInt(this, value, offset, byteLength, limit - 1, -limit)
  }

  var i = 0
  var mul = 1
  var sub = 0
  this[offset] = value & 0xFF
  while (++i < byteLength && (mul *= 0x100)) {
    if (value < 0 && sub === 0 && this[offset + i - 1] !== 0) {
      sub = 1
    }
    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeIntBE = function writeIntBE (value, offset, byteLength, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    var limit = Math.pow(2, (8 * byteLength) - 1)

    checkInt(this, value, offset, byteLength, limit - 1, -limit)
  }

  var i = byteLength - 1
  var mul = 1
  var sub = 0
  this[offset + i] = value & 0xFF
  while (--i >= 0 && (mul *= 0x100)) {
    if (value < 0 && sub === 0 && this[offset + i + 1] !== 0) {
      sub = 1
    }
    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
  }

  return offset + byteLength
}

Buffer.prototype.writeInt8 = function writeInt8 (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 1, 0x7f, -0x80)
  if (value < 0) value = 0xff + value + 1
  this[offset] = (value & 0xff)
  return offset + 1
}

Buffer.prototype.writeInt16LE = function writeInt16LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
  this[offset] = (value & 0xff)
  this[offset + 1] = (value >>> 8)
  return offset + 2
}

Buffer.prototype.writeInt16BE = function writeInt16BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
  this[offset] = (value >>> 8)
  this[offset + 1] = (value & 0xff)
  return offset + 2
}

Buffer.prototype.writeInt32LE = function writeInt32LE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
  this[offset] = (value & 0xff)
  this[offset + 1] = (value >>> 8)
  this[offset + 2] = (value >>> 16)
  this[offset + 3] = (value >>> 24)
  return offset + 4
}

Buffer.prototype.writeInt32BE = function writeInt32BE (value, offset, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
  if (value < 0) value = 0xffffffff + value + 1
  this[offset] = (value >>> 24)
  this[offset + 1] = (value >>> 16)
  this[offset + 2] = (value >>> 8)
  this[offset + 3] = (value & 0xff)
  return offset + 4
}

function checkIEEE754 (buf, value, offset, ext, max, min) {
  if (offset + ext > buf.length) throw new RangeError('Index out of range')
  if (offset < 0) throw new RangeError('Index out of range')
}

function writeFloat (buf, value, offset, littleEndian, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    checkIEEE754(buf, value, offset, 4, 3.4028234663852886e+38, -3.4028234663852886e+38)
  }
  ieee754.write(buf, value, offset, littleEndian, 23, 4)
  return offset + 4
}

Buffer.prototype.writeFloatLE = function writeFloatLE (value, offset, noAssert) {
  return writeFloat(this, value, offset, true, noAssert)
}

Buffer.prototype.writeFloatBE = function writeFloatBE (value, offset, noAssert) {
  return writeFloat(this, value, offset, false, noAssert)
}

function writeDouble (buf, value, offset, littleEndian, noAssert) {
  value = +value
  offset = offset >>> 0
  if (!noAssert) {
    checkIEEE754(buf, value, offset, 8, 1.7976931348623157E+308, -1.7976931348623157E+308)
  }
  ieee754.write(buf, value, offset, littleEndian, 52, 8)
  return offset + 8
}

Buffer.prototype.writeDoubleLE = function writeDoubleLE (value, offset, noAssert) {
  return writeDouble(this, value, offset, true, noAssert)
}

Buffer.prototype.writeDoubleBE = function writeDoubleBE (value, offset, noAssert) {
  return writeDouble(this, value, offset, false, noAssert)
}

// copy(targetBuffer, targetStart=0, sourceStart=0, sourceEnd=buffer.length)
Buffer.prototype.copy = function copy (target, targetStart, start, end) {
  if (!start) start = 0
  if (!end && end !== 0) end = this.length
  if (targetStart >= target.length) targetStart = target.length
  if (!targetStart) targetStart = 0
  if (end > 0 && end < start) end = start

  // Copy 0 bytes; we're done
  if (end === start) return 0
  if (target.length === 0 || this.length === 0) return 0

  // Fatal error conditions
  if (targetStart < 0) {
    throw new RangeError('targetStart out of bounds')
  }
  if (start < 0 || start >= this.length) throw new RangeError('sourceStart out of bounds')
  if (end < 0) throw new RangeError('sourceEnd out of bounds')

  // Are we oob?
  if (end > this.length) end = this.length
  if (target.length - targetStart < end - start) {
    end = target.length - targetStart + start
  }

  var len = end - start
  var i

  if (this === target && start < targetStart && targetStart < end) {
    // descending copy from end
    for (i = len - 1; i >= 0; --i) {
      target[i + targetStart] = this[i + start]
    }
  } else if (len < 1000) {
    // ascending copy from start
    for (i = 0; i < len; ++i) {
      target[i + targetStart] = this[i + start]
    }
  } else {
    Uint8Array.prototype.set.call(
      target,
      this.subarray(start, start + len),
      targetStart
    )
  }

  return len
}

// Usage:
//    buffer.fill(number[, offset[, end]])
//    buffer.fill(buffer[, offset[, end]])
//    buffer.fill(string[, offset[, end]][, encoding])
Buffer.prototype.fill = function fill (val, start, end, encoding) {
  // Handle string cases:
  if (typeof val === 'string') {
    if (typeof start === 'string') {
      encoding = start
      start = 0
      end = this.length
    } else if (typeof end === 'string') {
      encoding = end
      end = this.length
    }
    if (val.length === 1) {
      var code = val.charCodeAt(0)
      if (code < 256) {
        val = code
      }
    }
    if (encoding !== undefined && typeof encoding !== 'string') {
      throw new TypeError('encoding must be a string')
    }
    if (typeof encoding === 'string' && !Buffer.isEncoding(encoding)) {
      throw new TypeError('Unknown encoding: ' + encoding)
    }
  } else if (typeof val === 'number') {
    val = val & 255
  }

  // Invalid ranges are not set to a default, so can range check early.
  if (start < 0 || this.length < start || this.length < end) {
    throw new RangeError('Out of range index')
  }

  if (end <= start) {
    return this
  }

  start = start >>> 0
  end = end === undefined ? this.length : end >>> 0

  if (!val) val = 0

  var i
  if (typeof val === 'number') {
    for (i = start; i < end; ++i) {
      this[i] = val
    }
  } else {
    var bytes = Buffer.isBuffer(val)
      ? val
      : new Buffer(val, encoding)
    var len = bytes.length
    for (i = 0; i < end - start; ++i) {
      this[i + start] = bytes[i % len]
    }
  }

  return this
}

// HELPER FUNCTIONS
// ================

var INVALID_BASE64_RE = /[^+/0-9A-Za-z-_]/g

function base64clean (str) {
  // Node strips out invalid characters like \n and \t from the string, base64-js does not
  str = str.trim().replace(INVALID_BASE64_RE, '')
  // Node converts strings with length < 2 to ''
  if (str.length < 2) return ''
  // Node allows for non-padded base64 strings (missing trailing ===), base64-js does not
  while (str.length % 4 !== 0) {
    str = str + '='
  }
  return str
}

function toHex (n) {
  if (n < 16) return '0' + n.toString(16)
  return n.toString(16)
}

function utf8ToBytes (string, units) {
  units = units || Infinity
  var codePoint
  var length = string.length
  var leadSurrogate = null
  var bytes = []

  for (var i = 0; i < length; ++i) {
    codePoint = string.charCodeAt(i)

    // is surrogate component
    if (codePoint > 0xD7FF && codePoint < 0xE000) {
      // last char was a lead
      if (!leadSurrogate) {
        // no lead yet
        if (codePoint > 0xDBFF) {
          // unexpected trail
          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
          continue
        } else if (i + 1 === length) {
          // unpaired lead
          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
          continue
        }

        // valid lead
        leadSurrogate = codePoint

        continue
      }

      // 2 leads in a row
      if (codePoint < 0xDC00) {
        if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
        leadSurrogate = codePoint
        continue
      }

      // valid surrogate pair
      codePoint = (leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00) + 0x10000
    } else if (leadSurrogate) {
      // valid bmp char, but last char was a lead
      if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
    }

    leadSurrogate = null

    // encode utf8
    if (codePoint < 0x80) {
      if ((units -= 1) < 0) break
      bytes.push(codePoint)
    } else if (codePoint < 0x800) {
      if ((units -= 2) < 0) break
      bytes.push(
        codePoint >> 0x6 | 0xC0,
        codePoint & 0x3F | 0x80
      )
    } else if (codePoint < 0x10000) {
      if ((units -= 3) < 0) break
      bytes.push(
        codePoint >> 0xC | 0xE0,
        codePoint >> 0x6 & 0x3F | 0x80,
        codePoint & 0x3F | 0x80
      )
    } else if (codePoint < 0x110000) {
      if ((units -= 4) < 0) break
      bytes.push(
        codePoint >> 0x12 | 0xF0,
        codePoint >> 0xC & 0x3F | 0x80,
        codePoint >> 0x6 & 0x3F | 0x80,
        codePoint & 0x3F | 0x80
      )
    } else {
      throw new Error('Invalid code point')
    }
  }

  return bytes
}

function asciiToBytes (str) {
  var byteArray = []
  for (var i = 0; i < str.length; ++i) {
    // Node's code seems to be doing this and not & 0x7F..
    byteArray.push(str.charCodeAt(i) & 0xFF)
  }
  return byteArray
}

function utf16leToBytes (str, units) {
  var c, hi, lo
  var byteArray = []
  for (var i = 0; i < str.length; ++i) {
    if ((units -= 2) < 0) break

    c = str.charCodeAt(i)
    hi = c >> 8
    lo = c % 256
    byteArray.push(lo)
    byteArray.push(hi)
  }

  return byteArray
}

function base64ToBytes (str) {
  return base64.toByteArray(base64clean(str))
}

function blitBuffer (src, dst, offset, length) {
  for (var i = 0; i < length; ++i) {
    if ((i + offset >= dst.length) || (i >= src.length)) break
    dst[i + offset] = src[i]
  }
  return i
}

// ArrayBuffers from another context (i.e. an iframe) do not pass the `instanceof` check
// but they should be treated as valid. See: https://github.com/feross/buffer/issues/166
function isArrayBuffer (obj) {
  return obj instanceof ArrayBuffer ||
    (obj != null && obj.constructor != null && obj.constructor.name === 'ArrayBuffer' &&
      typeof obj.byteLength === 'number')
}

// Node 0.10 supports `ArrayBuffer` but lacks `ArrayBuffer.isView`
function isArrayBufferView (obj) {
  return (typeof ArrayBuffer.isView === 'function') && ArrayBuffer.isView(obj)
}

function numberIsNaN (obj) {
  return obj !== obj // eslint-disable-line no-self-compare
}

},{"base64-js":1,"ieee754":5}],5:[function(require,module,exports){
exports.read = function (buffer, offset, isLE, mLen, nBytes) {
  var e, m
  var eLen = nBytes * 8 - mLen - 1
  var eMax = (1 << eLen) - 1
  var eBias = eMax >> 1
  var nBits = -7
  var i = isLE ? (nBytes - 1) : 0
  var d = isLE ? -1 : 1
  var s = buffer[offset + i]

  i += d

  e = s & ((1 << (-nBits)) - 1)
  s >>= (-nBits)
  nBits += eLen
  for (; nBits > 0; e = e * 256 + buffer[offset + i], i += d, nBits -= 8) {}

  m = e & ((1 << (-nBits)) - 1)
  e >>= (-nBits)
  nBits += mLen
  for (; nBits > 0; m = m * 256 + buffer[offset + i], i += d, nBits -= 8) {}

  if (e === 0) {
    e = 1 - eBias
  } else if (e === eMax) {
    return m ? NaN : ((s ? -1 : 1) * Infinity)
  } else {
    m = m + Math.pow(2, mLen)
    e = e - eBias
  }
  return (s ? -1 : 1) * m * Math.pow(2, e - mLen)
}

exports.write = function (buffer, value, offset, isLE, mLen, nBytes) {
  var e, m, c
  var eLen = nBytes * 8 - mLen - 1
  var eMax = (1 << eLen) - 1
  var eBias = eMax >> 1
  var rt = (mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0)
  var i = isLE ? 0 : (nBytes - 1)
  var d = isLE ? 1 : -1
  var s = value < 0 || (value === 0 && 1 / value < 0) ? 1 : 0

  value = Math.abs(value)

  if (isNaN(value) || value === Infinity) {
    m = isNaN(value) ? 1 : 0
    e = eMax
  } else {
    e = Math.floor(Math.log(value) / Math.LN2)
    if (value * (c = Math.pow(2, -e)) < 1) {
      e--
      c *= 2
    }
    if (e + eBias >= 1) {
      value += rt / c
    } else {
      value += rt * Math.pow(2, 1 - eBias)
    }
    if (value * c >= 2) {
      e++
      c /= 2
    }

    if (e + eBias >= eMax) {
      m = 0
      e = eMax
    } else if (e + eBias >= 1) {
      m = (value * c - 1) * Math.pow(2, mLen)
      e = e + eBias
    } else {
      m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen)
      e = 0
    }
  }

  for (; mLen >= 8; buffer[offset + i] = m & 0xff, i += d, m /= 256, mLen -= 8) {}

  e = (e << mLen) | m
  eLen += mLen
  for (; eLen > 0; buffer[offset + i] = e & 0xff, i += d, e /= 256, eLen -= 8) {}

  buffer[offset + i - d] |= s * 128
}

},{}],6:[function(require,module,exports){
// lz4.js - An implementation of Lz4 in plain JavaScript.
//
// TODO:
// - Unify header parsing/writing.
// - Support options (block size, checksums)
// - Support streams
// - Better error handling (handle bad offset, etc.)
// - HC support (better search algorithm)
// - Tests/benchmarking

var xxhash = require('./xxh32.js');
var util = require('./util.js');

// Constants
// --

// Compression format parameters/constants.
var minMatch = 4;
var minLength = 13;
var searchLimit = 5;
var skipTrigger = 6;
var hashSize = 1 << 16;

// Token constants.
var mlBits = 4;
var mlMask = (1 << mlBits) - 1;
var runBits = 4;
var runMask = (1 << runBits) - 1;

// Shared buffers
var blockBuf = makeBuffer(5 << 20);
var hashTable = makeHashTable();

// Frame constants.
var magicNum = 0x184D2204;

// Frame descriptor flags.
var fdContentChksum = 0x4;
var fdContentSize = 0x8;
var fdBlockChksum = 0x10;
// var fdBlockIndep = 0x20;
var fdVersion = 0x40;
var fdVersionMask = 0xC0;

// Block sizes.
var bsUncompressed = 0x80000000;
var bsDefault = 7;
var bsShift = 4;
var bsMask = 7;
var bsMap = {
  4: 0x10000,
  5: 0x40000,
  6: 0x100000,
  7: 0x400000
};

// Utility functions/primitives
// --

// Makes our hashtable. On older browsers, may return a plain array.
function makeHashTable () {
  try {
    return new Uint32Array(hashSize);
  } catch (error) {
    var hashTable = new Array(hashSize);

    for (var i = 0; i < hashSize; i++) {
      hashTable[i] = 0;
    }

    return hashTable;
  }
}

// Clear hashtable.
function clearHashTable (table) {
  for (var i = 0; i < hashSize; i++) {
    hashTable[i] = 0;
  }
}

// Makes a byte buffer. On older browsers, may return a plain array.
function makeBuffer (size) {
  try {
    return new Uint8Array(size);
  } catch (error) {
    var buf = new Array(size);

    for (var i = 0; i < size; i++) {
      buf[i] = 0;
    }

    return buf;
  }
}

function sliceArray (array, start, end) {
  if (typeof array.buffer !== undefined) {
    if (Uint8Array.prototype.slice) {
      return array.slice(start, end);
    } else {
      // Uint8Array#slice polyfill.
      var len = array.length;

      // Calculate start.
      start = start | 0;
      start = (start < 0) ? Math.max(len + start, 0) : Math.min(start, len);

      // Calculate end.
      end = (end === undefined) ? len : end | 0;
      end = (end < 0) ? Math.max(len + end, 0) : Math.min(end, len);

      // Copy into new array.
      var arraySlice = new Uint8Array(end - start);
      for (var i = start, n = 0; i < end;) {
        arraySlice[n++] = array[i++];
      }

      return arraySlice;
    }
  } else {
    // Assume normal array.
    return array.slice(start, end);
  }
}

// Implementation
// --

// Calculates an upper bound for lz4 compression.
exports.compressBound = function compressBound (n) {
  return (n + (n / 255) + 16) | 0;
};

// Calculates an upper bound for lz4 decompression, by reading the data.
exports.decompressBound = function decompressBound (src) {
  var sIndex = 0;

  // Read magic number
  if (util.readU32(src, sIndex) !== magicNum) {
    throw new Error('invalid magic number');
  }

  sIndex += 4;

  // Read descriptor
  var descriptor = src[sIndex++];

  // Check version
  if ((descriptor & fdVersionMask) !== fdVersion) {
    throw new Error('incompatible descriptor version ' + (descriptor & fdVersionMask));
  }

  // Read flags
  var useBlockSum = (descriptor & fdBlockChksum) !== 0;
  var useContentSize = (descriptor & fdContentSize) !== 0;

  // Read block size
  var bsIdx = (src[sIndex++] >> bsShift) & bsMask;

  if (bsMap[bsIdx] === undefined) {
    throw new Error('invalid block size ' + bsIdx);
  }

  var maxBlockSize = bsMap[bsIdx];

  // Get content size
  if (useContentSize) {
    return util.readU64(src, sIndex);
  }

  // Checksum
  sIndex++;

  // Read blocks.
  var maxSize = 0;
  while (true) {
    var blockSize = util.readU32(src, sIndex);
    sIndex += 4;

    if (blockSize & bsUncompressed) {
      blockSize &= ~bsUncompressed;
      maxSize += blockSize;
    } else {
      maxSize += maxBlockSize;
    }

    if (blockSize === 0) {
      return maxSize;
    }

    if (useBlockSum) {
      sIndex += 4;
    }

    sIndex += blockSize;
  }
};

// Creates a buffer of a given byte-size, falling back to plain arrays.
exports.makeBuffer = makeBuffer;

// Decompresses a block of Lz4.
exports.decompressBlock = function decompressBlock (src, dst, sIndex, sLength, dIndex) {
  var mLength, mOffset, sEnd, n, i;

  // Setup initial state.
  sEnd = sIndex + sLength;

  // Consume entire input block.
  while (sIndex < sEnd) {
    var token = src[sIndex++];

    // Copy literals.
    var literalCount = (token >> 4);
    if (literalCount > 0) {
      // Parse length.
      if (literalCount === 0xf) {
        while (true) {
          literalCount += src[sIndex];
          if (src[sIndex++] !== 0xff) {
            break;
          }
        }
      }

      // Copy literals
      for (n = sIndex + literalCount; sIndex < n;) {
        dst[dIndex++] = src[sIndex++];
      }
    }

    if (sIndex >= sEnd) {
      break;
    }

    // Copy match.
    mLength = (token & 0xf);

    // Parse offset.
    mOffset = src[sIndex++] | (src[sIndex++] << 8);

    // Parse length.
    if (mLength === 0xf) {
      while (true) {
        mLength += src[sIndex];
        if (src[sIndex++] !== 0xff) {
          break;
        }
      }
    }

    mLength += minMatch;

    // Copy match.
    for (i = dIndex - mOffset, n = i + mLength; i < n;) {
      dst[dIndex++] = dst[i++] | 0;
    }
  }

  return dIndex;
};

// Compresses a block with Lz4.
exports.compressBlock = function compressBlock (src, dst, sIndex, sLength, hashTable) {
  var mIndex, mAnchor, mLength, mOffset, mStep;
  var literalCount, dIndex, sEnd, n;

  // Setup initial state.
  dIndex = 0;
  sEnd = sLength + sIndex;
  mAnchor = sIndex;

  // Process only if block is large enough.
  if (sLength >= minLength) {
    var searchMatchCount = (1 << skipTrigger) + 3;

    // Consume until last n literals (Lz4 spec limitation.)
    while (sIndex + minMatch < sEnd - searchLimit) {
      var seq = util.readU32(src, sIndex);
      var hash = util.hashU32(seq) >>> 0;

      // Crush hash to 16 bits.
      hash = ((hash >> 16) ^ hash) >>> 0 & 0xffff;

      // Look for a match in the hashtable. NOTE: remove one; see below.
      mIndex = hashTable[hash] - 1;

      // Put pos in hash table. NOTE: add one so that zero = invalid.
      hashTable[hash] = sIndex + 1;

      // Determine if there is a match (within range.)
      if (mIndex < 0 || ((sIndex - mIndex) >>> 16) > 0 || util.readU32(src, mIndex) !== seq) {
        mStep = searchMatchCount++ >> skipTrigger;
        sIndex += mStep;
        continue;
      }

      searchMatchCount = (1 << skipTrigger) + 3;

      // Calculate literal count and offset.
      literalCount = sIndex - mAnchor;
      mOffset = sIndex - mIndex;

      // We've already matched one word, so get that out of the way.
      sIndex += minMatch;
      mIndex += minMatch;

      // Determine match length.
      // N.B.: mLength does not include minMatch, Lz4 adds it back
      // in decoding.
      mLength = sIndex;
      while (sIndex < sEnd - searchLimit && src[sIndex] === src[mIndex]) {
        sIndex++;
        mIndex++;
      }
      mLength = sIndex - mLength;

      // Write token + literal count.
      var token = mLength < mlMask ? mLength : mlMask;
      if (literalCount >= runMask) {
        dst[dIndex++] = (runMask << mlBits) + token;
        for (n = literalCount - runMask; n >= 0xff; n -= 0xff) {
          dst[dIndex++] = 0xff;
        }
        dst[dIndex++] = n;
      } else {
        dst[dIndex++] = (literalCount << mlBits) + token;
      }

      // Write literals.
      for (var i = 0; i < literalCount; i++) {
        dst[dIndex++] = src[mAnchor + i];
      }

      // Write offset.
      dst[dIndex++] = mOffset;
      dst[dIndex++] = (mOffset >> 8);

      // Write match length.
      if (mLength >= mlMask) {
        for (n = mLength - mlMask; n >= 0xff; n -= 0xff) {
          dst[dIndex++] = 0xff;
        }
        dst[dIndex++] = n;
      }

      // Move the anchor.
      mAnchor = sIndex;
    }
  }

  // Nothing was encoded.
  if (mAnchor === 0) {
    return 0;
  }

  // Write remaining literals.
  // Write literal token+count.
  literalCount = sEnd - mAnchor;
  if (literalCount >= runMask) {
    dst[dIndex++] = (runMask << mlBits);
    for (n = literalCount - runMask; n >= 0xff; n -= 0xff) {
      dst[dIndex++] = 0xff;
    }
    dst[dIndex++] = n;
  } else {
    dst[dIndex++] = (literalCount << mlBits);
  }

  // Write literals.
  sIndex = mAnchor;
  while (sIndex < sEnd) {
    dst[dIndex++] = src[sIndex++];
  }

  return dIndex;
};

// Decompresses a frame of Lz4 data.
exports.decompressFrame = function decompressFrame (src, dst) {
  var useBlockSum, useContentSum, useContentSize, descriptor;
  var sIndex = 0;
  var dIndex = 0;

  // Read magic number
  if (util.readU32(src, sIndex) !== magicNum) {
    throw new Error('invalid magic number');
  }

  sIndex += 4;

  // Read descriptor
  descriptor = src[sIndex++];

  // Check version
  if ((descriptor & fdVersionMask) !== fdVersion) {
    throw new Error('incompatible descriptor version');
  }

  // Read flags
  useBlockSum = (descriptor & fdBlockChksum) !== 0;
  useContentSum = (descriptor & fdContentChksum) !== 0;
  useContentSize = (descriptor & fdContentSize) !== 0;

  // Read block size
  var bsIdx = (src[sIndex++] >> bsShift) & bsMask;

  if (bsMap[bsIdx] === undefined) {
    throw new Error('invalid block size');
  }

  if (useContentSize) {
    // TODO: read content size
    sIndex += 8;
  }

  sIndex++;

  // Read blocks.
  while (true) {
    var compSize;

    compSize = util.readU32(src, sIndex);
    sIndex += 4;

    if (compSize === 0) {
      break;
    }

    if (useBlockSum) {
      // TODO: read block checksum
      sIndex += 4;
    }

    // Check if block is compressed
    if ((compSize & bsUncompressed) !== 0) {
      // Mask off the 'uncompressed' bit
      compSize &= ~bsUncompressed;

      // Copy uncompressed data into destination buffer.
      for (var j = 0; j < compSize; j++) {
        dst[dIndex++] = src[sIndex++];
      }
    } else {
      // Decompress into blockBuf
      dIndex = exports.decompressBlock(src, dst, sIndex, compSize, dIndex);
      sIndex += compSize;
    }
  }

  if (useContentSum) {
    // TODO: read content checksum
    sIndex += 4;
  }

  return dIndex;
};

// Compresses data to an Lz4 frame.
exports.compressFrame = function compressFrame (src, dst) {
  var dIndex = 0;

  // Write magic number.
  util.writeU32(dst, dIndex, magicNum);
  dIndex += 4;

  // Descriptor flags.
  dst[dIndex++] = fdVersion;
  dst[dIndex++] = bsDefault << bsShift;

  // Descriptor checksum.
  dst[dIndex] = xxhash.hash(0, dst, 4, dIndex - 4) >> 8;
  dIndex++;

  // Write blocks.
  var maxBlockSize = bsMap[bsDefault];
  var remaining = src.length;
  var sIndex = 0;

  // Clear the hashtable.
  clearHashTable(hashTable);

  // Split input into blocks and write.
  while (remaining > 0) {
    var compSize = 0;
    var blockSize = remaining > maxBlockSize ? maxBlockSize : remaining;

    compSize = exports.compressBlock(src, blockBuf, sIndex, blockSize, hashTable);

    if (compSize > blockSize || compSize === 0) {
      // Output uncompressed.
      util.writeU32(dst, dIndex, 0x80000000 | blockSize);
      dIndex += 4;

      for (var z = sIndex + blockSize; sIndex < z;) {
        dst[dIndex++] = src[sIndex++];
      }

      remaining -= blockSize;
    } else {
      // Output compressed.
      util.writeU32(dst, dIndex, compSize);
      dIndex += 4;

      for (var j = 0; j < compSize;) {
        dst[dIndex++] = blockBuf[j++];
      }

      sIndex += blockSize;
      remaining -= blockSize;
    }
  }

  // Write blank end block.
  util.writeU32(dst, dIndex, 0);
  dIndex += 4;

  return dIndex;
};

// Decompresses a buffer containing an Lz4 frame. maxSize is optional; if not
// provided, a maximum size will be determined by examining the data. The
// buffer returned will always be perfectly-sized.
exports.decompress = function decompress (src, maxSize) {
  var dst, size;

  if (maxSize === undefined) {
    maxSize = exports.decompressBound(src);
  }

  dst = exports.makeBuffer(maxSize);
  size = exports.decompressFrame(src, dst);

  if (size !== maxSize) {
    dst = sliceArray(dst, 0, size);
  }

  return dst;
};

// Compresses a buffer to an Lz4 frame. maxSize is optional; if not provided,
// a buffer will be created based on the theoretical worst output size for a
// given input size. The buffer returned will always be perfectly-sized.
exports.compress = function compress (src, maxSize) {
  var dst, size;

  if (maxSize === undefined) {
    maxSize = exports.compressBound(src.length);
  }

  dst = exports.makeBuffer(maxSize);
  size = exports.compressFrame(src, dst);

  if (size !== maxSize) {
    dst = sliceArray(dst, 0, size);
  }

  return dst;
};

},{"./util.js":7,"./xxh32.js":8}],7:[function(require,module,exports){
// Simple hash function, from: http://burtleburtle.net/bob/hash/integer.html.
// Chosen because it doesn't use multiply and achieves full avalanche.
exports.hashU32 = function hashU32 (a) {
  a = a | 0;
  a = a + 2127912214 + (a << 12) | 0;
  a = a ^ -949894596 ^ a >>> 19;
  a = a + 374761393 + (a << 5) | 0;
  a = a + -744332180 ^ a << 9;
  a = a + -42973499 + (a << 3) | 0;
  return a ^ -1252372727 ^ a >>> 16 | 0;
};

// Reads a 64-bit little-endian integer from an array.
exports.readU64 = function readU64 (b, n) {
  var x = 0;
  x |= b[n++] << 0;
  x |= b[n++] << 8;
  x |= b[n++] << 16;
  x |= b[n++] << 24;
  x |= b[n++] << 32;
  x |= b[n++] << 40;
  x |= b[n++] << 48;
  x |= b[n++] << 56;
  return x;
};

// Reads a 32-bit little-endian integer from an array.
exports.readU32 = function readU32 (b, n) {
  var x = 0;
  x |= b[n++] << 0;
  x |= b[n++] << 8;
  x |= b[n++] << 16;
  x |= b[n++] << 24;
  return x;
};

// Writes a 32-bit little-endian integer from an array.
exports.writeU32 = function writeU32 (b, n, x) {
  b[n++] = (x >> 0) & 0xff;
  b[n++] = (x >> 8) & 0xff;
  b[n++] = (x >> 16) & 0xff;
  b[n++] = (x >> 24) & 0xff;
};

// Multiplies two numbers using 32-bit integer multiplication.
// Algorithm from Emscripten.
exports.imul = function imul (a, b) {
  var ah = a >>> 16;
  var al = a & 65535;
  var bh = b >>> 16;
  var bl = b & 65535;

  return al * bl + (ah * bl + al * bh << 16) | 0;
};

},{}],8:[function(require,module,exports){
// xxh32.js - implementation of xxhash32 in plain JavaScript
var util = require('./util.js');

// xxhash32 primes
var prime1 = 0x9e3779b1;
var prime2 = 0x85ebca77;
var prime3 = 0xc2b2ae3d;
var prime4 = 0x27d4eb2f;
var prime5 = 0x165667b1;

// Utility functions/primitives
// --

function rotl32 (x, r) {
  x = x | 0;
  r = r | 0;

  return x >>> (32 - r | 0) | x << r | 0;
}

function rotmul32 (h, r, m) {
  h = h | 0;
  r = r | 0;
  m = m | 0;

  return util.imul(h >>> (32 - r | 0) | h << r, m) | 0;
}

function shiftxor32 (h, s) {
  h = h | 0;
  s = s | 0;

  return h >>> s ^ h | 0;
}

// Implementation
// --

function xxhapply (h, src, m0, s, m1) {
  return rotmul32(util.imul(src, m0) + h, s, m1);
}

function xxh1 (h, src, index) {
  return rotmul32((h + util.imul(src[index], prime5)), 11, prime1);
}

function xxh4 (h, src, index) {
  return xxhapply(h, util.readU32(src, index), prime3, 17, prime4);
}

function xxh16 (h, src, index) {
  return [
    xxhapply(h[0], util.readU32(src, index + 0), prime2, 13, prime1),
    xxhapply(h[1], util.readU32(src, index + 4), prime2, 13, prime1),
    xxhapply(h[2], util.readU32(src, index + 8), prime2, 13, prime1),
    xxhapply(h[3], util.readU32(src, index + 12), prime2, 13, prime1)
  ];
}

function xxh32 (seed, src, index, len) {
  var h, l;
  l = len;
  if (len >= 16) {
    h = [
      seed + prime1 + prime2,
      seed + prime2,
      seed,
      seed - prime1
    ];

    while (len >= 16) {
      h = xxh16(h, src, index);

      index += 16;
      len -= 16;
    }

    h = rotl32(h[0], 1) + rotl32(h[1], 7) + rotl32(h[2], 12) + rotl32(h[3], 18) + l;
  } else {
    h = (seed + prime5 + len) >>> 0;
  }

  while (len >= 4) {
    h = xxh4(h, src, index);

    index += 4;
    len -= 4;
  }

  while (len > 0) {
    h = xxh1(h, src, index);

    index++;
    len--;
  }

  h = shiftxor32(util.imul(shiftxor32(util.imul(shiftxor32(h, 15), prime2), 13), prime3), 16);

  return h >>> 0;
}

exports.hash = xxh32;

},{"./util.js":7}],9:[function(require,module,exports){
(function (global){
// "polyfill" Buffer
var self = (typeof global !== 'undefined' ? global : (typeof window !== 'undefined' ? window : this));
self.Buffer = self.Buffer ? self.Buffer : require('buffer/').Buffer;
var Buffer = self.Buffer;

// Adapted from https://github.com/jangxx/node-s3tc
function decodeDXT5(in_buf, pos, buffer, width, height, currentY, currentX) {
    var alpha0 = in_buf.readUInt8(pos + 0, true);
    var alpha1 = in_buf.readUInt8(pos + 1, true);
    var a_raw = [in_buf.readUInt8(pos + 2, true), in_buf.readUInt8(pos + 3, true), in_buf.readUInt8(pos + 4, true), in_buf.readUInt8(pos + 5, true), in_buf.readUInt8(pos + 6, true), in_buf.readUInt8(pos + 7, true)];
    var color0 = RGB565_to_RGB888(in_buf.readInt16LE(pos + 8, true));
    var color1 = RGB565_to_RGB888(in_buf.readInt16LE(pos + 10, true));
    var c = [in_buf.readUInt8(pos + 12, true), in_buf.readUInt8(pos + 13, true), in_buf.readUInt8(pos + 14, true), in_buf.readUInt8(pos + 15, true)];

    var a = [
        0x7 & (a_raw[0] >> 0),
        0x7 & (a_raw[0] >> 3),
        0x7 & (((0x1 & a_raw[1]) << 2) + (a_raw[0] >> 6)),
        0x7 & (a_raw[1] >> 1),
        0x7 & (a_raw[1] >> 4),
        0x7 & (((0x3 & a_raw[2]) << 1) + (a_raw[1] >> 7)),
        0x7 & (a_raw[2] >> 2),
        0x7 & (a_raw[2] >> 5),
        0x7 & (a_raw[3] >> 0),
        0x7 & (a_raw[3] >> 3),
        0x7 & (((0x1 & a_raw[4]) << 2) + (a_raw[3] >> 6)),
        0x7 & (a_raw[4] >> 1),
        0x7 & (a_raw[4] >> 4),
        0x7 & (((0x3 & a_raw[5]) << 1) + (a_raw[4] >> 7)),
        0x7 & (a_raw[5] >> 2),
        0x7 & (a_raw[5] >> 5)
    ];

    for (var i = 0; i < 16; i++) {
        var e = Math.floor(i / 4); //current element

        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 0] = c2value(3 & c[e], color0.r, color1.r); //red
        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 1] = c2value(3 & c[e], color0.g, color1.g); //green
        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 2] = c2value(3 & c[e], color0.b, color1.b); //blue
        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 3] = a2value(a[i]); //alpha

        c[e] = c[e] >> 2;
    }

    function c2value(code, color0, color1) {
        switch (code) {
            case 0: return color0;
            case 1: return color1;
            case 2: return (color0 + color1 + 1) >> 1;
            case 3: return (color0 + color1 + 1) >> 1;
        }
    }

    function a2value(code) {
        if (alpha0 > alpha1) {
            switch (code) {
                case 0: return alpha0;
                case 1: return alpha1;
                case 2: return (6 * alpha0 + 1 * alpha1) / 7;
                case 3: return (5 * alpha0 + 2 * alpha1) / 7;
                case 4: return (4 * alpha0 + 3 * alpha1) / 7;
                case 5: return (3 * alpha0 + 4 * alpha1) / 7;
                case 6: return (2 * alpha0 + 5 * alpha1) / 7;
                case 7: return (1 * alpha0 + 6 * alpha1) / 7;
                default: console.log(code);
            }
        } else {
            switch (code) {
                case 0: return alpha0;
                case 1: return alpha1;
                case 2: return (4 * alpha0 + 1 * alpha1) / 5;
                case 3: return (3 * alpha0 + 2 * alpha1) / 5;
                case 4: return (2 * alpha0 + 3 * alpha1) / 5;
                case 5: return (1 * alpha0 + 4 * alpha1) / 5;
                case 6: return 0;
                case 7: return 255; //why, what, WHY???
                default: console.log(code);
            }
        }
    }
}

function decodeDXT1(in_buf, pos, buffer, width, height, currentY, currentX) {
    var color0 = RGB565_to_RGB888(in_buf.readInt16LE(pos + 0));
    var color1 = RGB565_to_RGB888(in_buf.readInt16LE(pos + 2));
    var c = [in_buf.readUInt8(pos + 4), in_buf.readUInt8(pos + 5), in_buf.readUInt8(pos + 6), in_buf.readUInt8(pos + 7)];

    for (var i = 0; i < 16; i++) {
        var e = Math.floor(i / 4); //current element

        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 0] = c2value(3 & c[e], color0.r, color1.r); //red
        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 1] = c2value(3 & c[e], color0.g, color1.g); //green
        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 2] = c2value(3 & c[e], color0.b, color1.b); //blue
        buffer[width * 4 * (height - 1 - currentY - e) + 4 * currentX + ((i - (e * 4)) * 4) + 3] = 255; //alpha

        c[e] = c[e] >> 2;
    }

    function c2value(code, color0, color1) {
        if (color0 > color1) {
            switch (code) {
                case 0: return color0;
                case 1: return color1;
                case 2: return (2 * color0 + color1) / 3;
                case 3: return (color0 + 2 * color1) / 3;
            }
        } else {
            switch (code) {
                case 0: return color0;
                case 1: return color1;
                case 2: return (color0 + color1 + 1) >> 1;
                case 3: return (color0 + color1 + 1) >> 1;
            }
        }
    }
}

function DXTDecoder(chunk, width, height, chunkDecoder, chunkSize) {
    var buffer = Buffer.allocUnsafe(width * height * 4);
    var currentX = 0;
    var currentY = 0;

    var pos = 0;
    while (pos < chunk.length) {
        if (currentX == width && currentY == height) break;

        chunkDecoder(chunk, pos, buffer, width, height, currentY, currentX);

        currentX += 4;
        if (currentX + 4 > width) {
            currentX = 0;
            currentY += 4;
        }

        pos += chunkSize;
    }

    return buffer;
}

function DXT5Decoder(chunk, width, height) {
    return DXTDecoder(chunk, width, height, decodeDXT5, 16);
}

function DXT1Decoder(chunk, width, height) {
    return DXTDecoder(chunk, width, height, decodeDXT1, 8);
}

module.exports = { DXT1Decoder, DXT5Decoder };

function RGB565_to_RGB888(rgb) {
    return {
        r: ((rgb & 0b1111100000000000) >> 11) * 8,
        g: ((rgb & 0b0000011111100000) >> 5) * 4,
        b: (rgb & 0b0000000000011111) * 8
    };
} 
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"buffer/":4}],10:[function(require,module,exports){
(function (global){
var Parser = require('binary-parser').Parser;
const lz4js = require('lz4js');
const dxt = require('./dxt');

// "polyfill" Buffer
var self = (typeof global !== 'undefined' ? global : (typeof window !== 'undefined' ? window : this));
self.Buffer = self.Buffer ? self.Buffer : require('buffer/').Buffer;
var Buffer = self.Buffer;

var assetBundle = new Parser()
	.endianess('big')
	.string('signature', {
		zeroTerminated: true
	})
	.int32('format_version')
	.string('unity_version', {
		zeroTerminated: true
	})
	.string('generator_version', {
		zeroTerminated: true
	})
	.int32('file_size1')
	.int32('file_size2')
	.uint32('ciblock_size')
	.uint32('uiblock_size')
	.uint32('flags')
	.array('compressedBlk', {
		type: "uint8",
		length: 'ciblock_size'
	})
	.array('assets', {
		type: "uint8",
		readUntil: 'eof'
	});

var blockList = new Parser()
	.endianess('big')
	.skip(16)
	.int32('num_blocks')
	.array('blocks', {
		type: Parser.start()
			.int32('busize')
			.int32('bcsize')
			.int16('bflags'),
		length: 'num_blocks'
	})
	.int32('num_nodes')
	.array('nodes', {
		type: Parser.start()
			.int32('ofs1')
			.int32('ofs2')
			.int32('size1')
			.int32('size2')
			.int32('status')
			.string('name', {
				zeroTerminated: true
			}),
		length: 'num_nodes'
	});

var typeParser = new Parser()
	.endianess('little')
	.int16('version')
	.uint8('depth')
	.uint8('is_array')
	.int32('typeOffset')
	.int32('nameOffset')
	.int32('size')
	.uint32('index')
	.int32('flags');

var typeTreeParser = new Parser()
	.endianess('little')
	.int32('class_id')
	.skip(function () { return (this.class_id < 0) ? 0x20 : 0x10; })
	.uint32('num_nodes')
	.uint32('buffer_bytes')
	.array('node_data', {
		type: typeParser,
		length: 'num_nodes'
	})
	.array('buffer_data', {
		type: 'uint8',
		length: 'buffer_bytes'
	});

var typeStructParser = new Parser()
	.endianess('little')
	.string('generator_version', {
		zeroTerminated: true
	})
	.uint32('target_platform')
	.uint8('has_type_trees')
	.int32('num_types')
	.array('types', {
		type: typeTreeParser,
		length: 'num_types'
	});

var assetParser = new Parser()
	.endianess('big')
	.uint32('metadata_size')
	.uint32('file_size')
	.uint32('format')
	.uint32('data_offset') // Hard-coded assume format > 9
	.uint32('endianness', { assert: 0 })
	.endianess('little')
	.nest('typeStruct', { type: typeStructParser })
	.uint32('num_objects')
	.array('objects', {
		type: Parser.start()
			.endianess('little')
			.skip(3) // TODO: Align at 4-byte instead of hardcode
			.int32('path_id1')
			.int32('path_id2')
			.uint32('data_offset')
			.uint32('size')
			.int32('type_id')
			.int16('class_id')
			.int16('unk1')
			.int8('unk2')
		,
		length: 'num_objects'
	})
	.uint32('num_adds', { assert: 0 })
	.uint32('num_refs', { assert: 0 })
	.string('unk_string', {
		zeroTerminated: true
	});

function alignOff(offset) {
	return (offset + 3) & -4;
}

function read_value(object, type, objectBuffer, offset) {
	let t = type.type;
	let align = false;
	let result;
	if (t == "bool") {
		result = objectBuffer.readUInt8(offset);
		offset += 1;
	}
	else if (t == "SInt8") {
		result = objectBuffer.readInt8(offset);
		offset += 1;
	}
	else if (t == "UInt8") {
		result = objectBuffer.readUInt8(offset);
		offset += 1;
	}
	else if (t == "SInt16") {
		result = objectBuffer.readInt16LE(offset);
		offset += 2;
	}
	else if (t == "UInt16") {
		result = objectBuffer.readUInt16LE(offset);
		offset += 2;
	}
	else if (t == "SInt64") {
		result = objectBuffer.readInt32LE(offset);
		let result2 = objectBuffer.readInt32LE(offset + 4);
		offset += 8;
	}
	else if (t == "UInt64") {
		result = objectBuffer.readUInt32LE(offset);
		let result2 = objectBuffer.readUInt32LE(offset + 4);
		offset += 8;
	}
	else if ((t == "UInt32") || (t == "unsigned") || (t == "unsigned int")) {
		result = objectBuffer.readUInt32LE(offset);
		offset += 4;
	}
	else if ((t == "SInt32") || (t == "int")) {
		result = objectBuffer.readInt32LE(offset);
		offset += 4;
	}
	else if (t == "float") {
		offset = alignOff(offset);
		result = objectBuffer.readFloatLE(offset);
		offset += 4;
	}
	else if (t == "string") {
		let size = objectBuffer.readUInt32LE(offset);
		offset += 4;
		result = String.fromCharCode.apply(null, objectBuffer.slice(offset, offset + size));

		if (size > 500)
			throw new RangeError('offset out of range');

		offset += size;
		align = type.children[0].post_align;
	}
	else {
		let first_child = (type.children.length > 0) ? type.children[0] : undefined;
		if (type.is_array) {
			first_child = type;
		}

		if (t.startsWith("PPtr<")) {
			result = {};

			result.file_id = objectBuffer.readInt32LE(offset);
			offset += 4;

			result.path_id = objectBuffer.readUInt32LE(offset);
			let resultpathid2 = objectBuffer.readUInt32LE(offset + 4);
			offset += 8;
		}
		else if (first_child && first_child.is_array) {
			align = first_child.post_align;
			let size = objectBuffer.readUInt32LE(offset);
			offset += 4;

			let array_type = first_child.children[1];
			if ((array_type.type == "char") || (array_type.type == "UInt8")) {
				result = objectBuffer.slice(offset, offset + size);
				offset += size;
			}
			else {
				result = [];
				for (let i = 0; i < size; i++) {
					let rVal = read_value(object, array_type, objectBuffer, offset);
					result.push(rVal.result);
					offset = rVal.offset;
				}
			}
		}
		else if (t == "pair") {
			console.assert(type.children.length == 2);
			first = read_value(object, type.children[0], objectBuffer, offset);
			offset = first.offset;
			second = read_value(object, type.children[1], objectBuffer, offset);
			offset = second.offset;
			result = { first: first.result, second: second.result };
		}
		else {
			// A dictionary
			result = {};

			type.children.forEach(child => {
				let rVal = read_value(object, child, objectBuffer, offset);
				result[child.name] = rVal.result;
				offset = rVal.offset;
			});

			if (t == "StreamedResource") {
				result.asset = result.source; // resolve_streaming_asset(result.source)
			}
			else if (t == "StreamingInfo") {
				result.asset = result.path; // resolve_streaming_asset(result.path)
			}
		}
	}

	if (align || type.post_align) {
		offset = alignOff(offset);
	}

	return { result, offset };
}

function parseAssetBundle(data) {
	var bundle = assetBundle.parse(new Buffer(data));

	var decompressed = new Buffer(bundle.uiblock_size);
	lz4js.decompressBlock(bundle.compressedBlk, decompressed, 0, bundle.ciblock_size, 0);
	var bundleBlocks = blockList.parse(decompressed);

	var asset = assetParser.parse(Buffer.from(bundle.assets));

	const strings = "AABB AnimationClip AnimationCurve AnimationState Array Base BitField bitset bool char ColorRGBA Component data deque double dynamic_array FastPropertyName first float Font GameObject Generic Mono GradientNEW GUID GUIStyle int list long long map Matrix4x4f MdFour MonoBehaviour MonoScript m_ByteSize m_Curve m_EditorClassIdentifier m_EditorHideFlags m_Enabled m_ExtensionPtr m_GameObject m_Index m_IsArray m_IsStatic m_MetaFlag m_Name m_ObjectHideFlags m_PrefabInternal m_PrefabParentObject m_Script m_StaticEditorFlags m_Type m_Version Object pair PPtr<Component> PPtr<GameObject> PPtr<Material> PPtr<MonoBehaviour> PPtr<MonoScript> PPtr<Object> PPtr<Prefab> PPtr<Sprite> PPtr<TextAsset> PPtr<Texture> PPtr<Texture2D> PPtr<Transform> Prefab Quaternionf Rectf RectInt RectOffset second set short size SInt16 SInt32 SInt64 SInt8 staticvector string TextAsset TextMesh Texture Texture2D Transform TypelessData UInt16 UInt32 UInt64 UInt8 unsigned int unsigned long long unsigned short vector Vector2f Vector3f Vector4f m_ScriptingClassIdentifier Gradient ";

	let getString = (offset, type) => {
		if (offset < 0) {
			offset &= 0x7fffffff;
			return strings.substring(offset, strings.indexOf(' ', offset));
		}
		else if (offset < type.buffer_bytes) {
			let tmp = type.buffer_data.slice(offset, type.buffer_data.indexOf(0, offset));
			return String.fromCharCode.apply(null, tmp);
		}
		else {
			return undefined;
		}
	};

	let buildTypeTree = (type) => {
		// This makes assumptions about the order in which the nodes are serialized
		var parents = [type.node_data[0]];
		var curr;

		type.node_data.forEach((node) => {
			node.type = getString(node.typeOffset, type);
			node.name = getString(node.nameOffset, type);
			node.children = [];
			node.post_align = node.flags & 0x4000;

			if (node.depth == 0) {
				curr = node;
			}
			else {
				while (parents.length > node.depth) {
					parents.pop();
				}
				curr = node;
				parents[parents.length - 1].children.push(curr);
				parents.push(curr);
			}
		});
	};

	asset.typeStruct.types.forEach((type) => { buildTypeTree(type); });

	// Read the standard / built-in typetrees (not really needed for images)
	/*var standardTypes = typeStructParser.parse(fs.readFileSync('structs.dat'));
	standardTypes.types.forEach((type) => { buildTypeTree(type); });*/

	let parsedObjects = [];
	asset.objects.forEach((object, index) => {
		var objectBuffer = new Buffer(bundle.assets.slice(asset.data_offset + object.data_offset, asset.data_offset + object.data_offset + object.size));

		var type_tree = asset.typeStruct.types.find((type) => type.class_id == object.type_id);
		if (!type_tree) {
			type_tree = asset.typeStruct.types.find((type) => type.class_id == object.class_id);
			if (!type_tree) {
				//type_tree = standardTypes.types.find((type) => type.class_id == object.class_id);
				if (!type_tree) {
					console.error("Type tree not found for object " + index + "; class id: " + object.type_id);
					return;
				}
			}
		}

		let parsedObject = read_value(object, type_tree.node_data[0], objectBuffer, 0).result;
		parsedObject.type = type_tree.node_data[0].type;

		parsedObjects.push(parsedObject);
	});

	// DONE parsing, now on to images

	let imageTexture = undefined;
	let hasSprites = false;
	parsedObjects.forEach(object => {
		if (object.type == 'Texture2D') {
			if ((object.m_TextureFormat != 10) && (object.m_TextureFormat != 12)) {
				console.error("Only supports DXT1 / DXT5 formats for images!");
				return;
			}

			if (object.m_TextureFormat == 12) {
				object.rawBitmap = dxt.DXT5Decoder(object['image data'], object.m_Width, object.m_Height);
			}
			else {
				object.rawBitmap = dxt.DXT1Decoder(object['image data'], object.m_Width, object.m_Height);
			}
			delete object['image data'];
			console.assert(object.rawBitmap.length % 4 == 0);
			imageTexture = object;
		}
		if (object.type == 'Sprite') {
			hasSprites = true;
		}
	});

	if (!imageTexture) {
		console.log("No image in this asset bundle");
		console.log(parsedObjects);
		return;
	}

	var result = {
		imageName: imageTexture.m_Name,
		imageBitmap: {
			data: imageTexture.rawBitmap,
			width: imageTexture.m_Width,
			height: imageTexture.m_Height
		},
		sprites: []
	};

	if (hasSprites) {
		parsedObjects.forEach(object => {
			if (object.type == 'Sprite') {
				console.assert(!object.m_IsPolygon, "Doesn't support polygonal sprites!");
				console.assert(object.m_Rect.x + object.m_Rect.width <= imageTexture.m_Width);
				console.assert(object.m_Rect.y + object.m_Rect.height <= imageTexture.m_Height);

				let spriteBitmap = Buffer.allocUnsafe(object.m_Rect.width * object.m_Rect.height * 4);
				for (let column = object.m_Rect.x; column < object.m_Rect.x + object.m_Rect.width; column++) {
					for (let row = object.m_Rect.y; row < object.m_Rect.y + object.m_Rect.height; row++) {
						let pixelLocation = (imageTexture.m_Height - 1 - row) * imageTexture.m_Width + column;
						imageTexture.rawBitmap.copy(spriteBitmap, ((object.m_Rect.height - 1 - row + object.m_Rect.y) * object.m_Rect.width + (column - object.m_Rect.x)) * 4, pixelLocation * 4, (pixelLocation + 1) * 4);
					}
				}

				result.sprites.push({
					spriteName: object.m_Name,
					spriteBitmap: {
						data: spriteBitmap,
						width: object.m_Rect.width,
						height: object.m_Rect.height,
					}
				});
			}
		});
	}

	return result;
}

module.exports = { parseAssetBundle };
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./dxt":9,"binary-parser":2,"buffer/":4,"lz4js":6}]},{},[10])(10)
});