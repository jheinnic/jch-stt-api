// Type definitions for through2-reduce 1.1.5
// Project: https://github.com/brycebaril/through2-reduce
// Definitions by: John Heinnickel <https://github.com/jheinnic>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped

/// <reference types="node" />

import through2 = require('through2');
import stream = require('stream');

type ReduceCallback<T> = (previous: T, current: Buffer|string|any, index: number) => T;

interface Through2ReduceOptions extends stream.DuplexOptions {
    wantStrings?: boolean;
}

declare function through2_reduce<T>(options?: Through2ReduceOptions, fn?: ReduceCallback<T>): through2.Through2Constructor;
declare function through2_reduce<T>(fn?: ReduceCallback<T>): through2.Through2Constructor;

declare namespace through2_reduce {
    function ctor<T>(options?: Through2ReduceOptions, fn?: ReduceCallback<T>): through2.Through2Constructor;
    function ctor<T>(fn?: ReduceCallback<T>): through2.Through2Constructor;

    function obj<T>(options?: Through2ReduceOptions, fn?: ReduceCallback<T>): through2.Through2Constructor;
    function obj<T>(fn?: ReduceCallback<T>): through2.Through2Constructor;

    function objCtor<T>(options?: Through2ReduceOptions, fn?: ReduceCallback<T>): through2.Through2Constructor;
    function objCtor<T>(fn?: ReduceCallback<T>): through2.Through2Constructor;
}

export = through2_reduce;
