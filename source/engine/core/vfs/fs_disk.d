module engine.core.vfs.fs_disk;

import std.file;
import std.path;
import std.string;
import std.algorithm;

import engine.app.logger;
import engine.core.utils.array;
public import engine.core.vfs.base.dir;
public import engine.core.utils.path;

class CDiskDir : ADir {
protected:
    string[] ignorePhysDirs;

public:
    this( string i_name, string i_physPath, ADir i_parent = null ) {
        super( i_parent, i_name, i_physPath );
    }

    override ADir makeDir( string name, string path ) {
        return deepCreateDir( name );
    }

    override AFile makeFile( string i_name, string i_path, EFileMode i_mode = EFileMode.FM_WRITE ) {
        const resPath = physPath ~ "/" ~ i_path;

        CDiskFile nFile = new CDiskFile( i_name, resPath, i_mode, this );
        nFile.create();
        appendFile( nFile );

        log.info( ( "Created file: " ~ resPath ~ i_name ).replace( r"\", "/" ) );

        return nFile;
    }

    void updatePhysSubDirs( bool i_bDeepGet = false ) {
        removeDeletedPhysDirs();

        foreach ( ADir dir; getPhysDirs( i_bDeepGet ) ) {
            appendDir( dir );
        }
    }

    void updatePhysFiles() {
        foreach ( AFile file; getPhysFiles() ) {
            appendFile( file );
        }

        foreach ( ADir dir; dirs ) {
            ( cast( CDiskDir )dir ).updatePhysFiles();
        }
    }

protected:
    void removeDeletedPhysDirs() {
        foreach ( ADir dir; dirs ) {
            
            if ( !exists( dir.physPath ) ) {
                removeElement( dirs, dir );
                dir.destroy();
            }
        }
    }

    ADir[] getPhysDirs( bool i_bDeepGet = false ) {
        CDiskDir[] ret;

        foreach ( DirEntry ent; dirEntries( physPath, SpanMode.shallow ) ) {
            if ( !ent.isDir() ) {
                continue;
            }
            
            auto name = ent.name;
            name.skipOver( physPath );
            name.skipOver( "/" );
            name.skipOver( "\\" );

            if ( name != ".cache" ) {
                ret ~= new CDiskDir( name, ent.name, this );
            }
        }

        if ( i_bDeepGet ) {
            foreach ( dir; ret ) {
                dir.updatePhysSubDirs( true );
            }
        }

        return cast( ADir[] )ret;
    }

    AFile[] getPhysFiles() {
        CDiskFile[] ret;

        foreach ( DirEntry ent; dirEntries( physPath, SpanMode.shallow ) ) {
            if ( !ent.isFile() ) {
                continue;
            }

            auto name = ent.name;
            name.skipOver( physPath );
            name.skipOver( "/" );
            name.skipOver( "\\" );

            ret ~= new CDiskFile( name, ent.name, EFileMode.FM_READ, this );
        }

        return cast( AFile[] )ret;
    }

    ADir baseMakeDir( string i_name, string i_path ) {
        const resPath = i_path == "" ? i_name : i_path;

        if ( !exists( resPath ) ) {
            try {
                mkdir( resPath );
            } catch ( FileException e ) {
                throw e;
            }
        }

        CDiskDir nDir = new CDiskDir( i_name, resPath, this );
        appendDir( nDir );

        CLogger.get().info( "Created dir: " ~ resPath );

        return nDir;
    }

    CDiskDir deepCreateDir( string path ) {
        CDiskDir iterDir = this;
        string[] deepDirs = path.split( "/" );
        string currPath = physPath;

        foreach ( string pName; deepDirs ) {
            currPath = currPath ~ "/"~ pName;
            iterDir = cast( CDiskDir )iterDir.baseMakeDir( pName, currPath );
        }

        return iterDir;
    }

}

class CDiskFile : AFile {
public:
    this( string i_name, string i_path, EFileMode i_mode = EFileMode.FM_READ, ADir i_parent = null ) {
        super( i_name, i_path, i_mode, i_parent );
    }

    override void create() {
        if ( !exists( correctPath ) ) {
            try {
                write( correctPath, "" );
            } catch ( FileException e ) {
                throw e;
            }
        }
    }

    override ubyte[] readRawData() {
        assert( exists( correctPath ), "Trying to read invalid file!" );
        return cast( ubyte[] )correctPath.read();
    }

    override void writeRawData( ubyte[] data ) {
        assert( exists( correctPath ), "Trying to write invalid file!" );
        correctPath.write( data );
    }
}