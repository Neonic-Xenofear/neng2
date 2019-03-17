module engine.core.utils.path;

import std.string;
import std.file : thisExePath;
import std.path;

/**
    Return full path, apppends exec folder,
    and 
    normalize( resolve symbols like: "." && ".." )
    Params:
        append - append path
*/
string appExePathAndNorm( string append ) {
    return buildNormalizedPath( dirName( thisExePath() ), append ).replace( "\\", r"/" );
}