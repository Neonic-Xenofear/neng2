module engine.core.utils.array;

public import std.algorithm;
public import std.string;

/**
    Remove element from array
*/
static void removeElement( T )( ref T[] i_arr, T i_elem ) {
    auto index = countUntil( i_arr, i_elem );

    if ( index != -1 ) {
        i_arr = remove( i_arr, index );
    }
}

/**
    Return string from array of bytes or void*
*/
static string toStringFromArray( T )( T[] i_data ) {
    return ( cast( immutable( char )* )i_data )[0..i_data.length];
}

static string makeSingleString( string[] elems, string delim = "" ) {
    string resStr = "";
    foreach ( string iter; elems ) {
        resStr ~= iter ~ delim;
    }
    
    return resStr;
}