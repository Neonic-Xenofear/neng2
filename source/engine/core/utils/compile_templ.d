module engine.core.utils.compile_templ;

import std.meta : anySatisfy;
import std.traits : RepresentationTypeTuple;
import std.conv;
import std.string;

template isShared( T ) {
    enum bool isShared = is( T == shared );
}

template isConst( T ) {
    enum bool isConst =  is( T == const );
}

template hasConst( T ) {
    enum bool hasConst = anySatisfy!( isConst, RepresentationTypeTuple!C );
}

template isStructOrUnion( T ) {
    enum bool isStructOrUnion = is( T == struct ) || is( T == union );
}

template isEnum( T ) {
    enum bool isEnum = is( T == enum );
}

template isClass( T ) {
    enum bool isClass = is( T == class );
}

/**
    Generate elements for class
*/
static string elementsGen( string[] elems, char tempChar, int size ) {
    string resElems;

    foreach ( i; 0..size ) {
        resElems ~= tempChar ~ " " ~ elems[i] ~ "; ";
    }

    return resElems;
}

/**
    Speed-up CTFE conversions
*/
static string ctIntToString( int n ) pure nothrow {
    static immutable string[16] table = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

    if ( n < 10 ) {
        return table[n];
    } else {
        return to!string( n );
    }
}

static string generateLoopCode( string formatString, int N )() pure nothrow {
    string result;

    for ( int i = 0; i < N; ++i ) {
        string index = ctIntToString( i );
        // replace all @ by indices
        result ~= formatString.replace( "@", index );
    }

    return result;
}