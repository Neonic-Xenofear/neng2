module engine.core.vfs.base.dir;

import std.string;

import engine.core.utils.logger;
import engine.core.utils.array;
public import engine.core.vfs.base.file;
public import engine.core.vfs.vfs;;

abstract class ADir : AFSBaseObject {
protected:
    ADir[] dirs;
    AFile[] files;

public:
    abstract ADir makeDir( string i_name, string i_path = "" );
    abstract AFile makeFile( string i_name, string i_path = "", EFileMode i_mode = EFileMode.FM_WRITE );

    this( ADir iParent, string i_name, string i_path ) {
        setPath( i_name, i_path );
        _parent = iParent;
    }

    ADir getDir( string subDirPath ) {
        return recursiveIterateByNames( subDirPath.replace( "\\", "/" ).split( "/" ) );
    }

    ADir getDir( string[] subDirPath ) {
        return recursiveIterateByNames( subDirPath );
    }

    AFile getFile( string filePath, bool bLog = true ) {
        string[] splitPath = filePath.split( "/" );
        ADir resDir = this;
        if ( splitPath.length > 1 ) {
            resDir = getDir( splitPath[0..$-1] );
        }
        
        if ( resDir is null ) {
            if ( bLog ) {
                log.error( "Invalid file path: " ~ fullPath ~ "/" ~ filePath );
            }
            return null;
        }
        
        foreach ( file; resDir.files ) {
            if ( file.name == splitPath[$-1] ) {
                return file;
            }
        }

        if ( bLog ) {
            log.error( "Invalid file path: " ~ fullPath ~ "/" ~ filePath );
        }

        return null;
    }

    ADir getOrMakeDir( string path ) {
        ADir resDir = getDir( path );
        if ( resDir is null ) {
            resDir = makeDir( path );
        }

        return resDir;
    }

    AFile getOrMakeFile( string path ) {
        import std.path : dirName, baseName;

        AFile resFile = getFile( path, false );
        if ( !resFile ) {
            resFile = getOrMakeDir( dirName( path ) ).makeFile( baseName( path ) );
        }

        return resFile;
    }

    void appendDir( ADir i_dir ) {
        assert( i_dir !is null, "Invalid dir to add" );

        //Check if this dir exist in dirs
        if ( countUntil( dirs, i_dir ) == -1 ) {
            dirs ~= i_dir;
        }
    }

    void appendFile( AFile i_file ) {
        assert( i_file !is null, "Invalid file to add" );

        //Check if this file exist in files
        if ( countUntil( files, i_file ) == -1 ) {
            files ~= i_file;
        }
    }

    @property
    ADir[] subDirs() {
        return dirs;
    }

protected:
    ADir recursiveIterateByNames( string[] path ) {
        assert( path.length > 0 );
        
        if ( path[0] == ".." ) {
            if ( parent is null ) {
                return null;
            }

            return ( cast( ADir )parent ).recursiveIterateByNames( path[1..$] );
        }

        foreach ( dir; dirs ) {
            if ( dir.name == path[0] ) {
                if ( path.length > 1 ) {
                    return dir.recursiveIterateByNames( path[1..$] );
                } else {
                    return dir;
                }
            }
        }

        return null;
    }
}