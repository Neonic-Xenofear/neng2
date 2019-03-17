module engine.core.vfs.vfs;

import std.string;
import std.algorithm.searching;

import engine.app.logger;
import engine.core.utils.singleton;
public import engine.core.vfs.base.dir;
public import engine.core.vfs.base.file;

class CVFS : ASingleton!CVFS {
protected:
    ADir[string] _mountedDirs;

public:
    void mount( ADir i_dir ) {
        assert( i_dir !is null, "Trying to mount null dir!" );
        _mountedDirs[i_dir.name] = i_dir;
        CLogger.get().info( "Mounted dir: " ~ i_dir.name );
    }

    ADir getMountedDir( string i_name ) {
        return _mountedDirs[i_name];
    }

    ADir getRootDir() {
        return getMountedDir( "root" );
    }

    ADir getDir( string path, string mountFS = "root" ) {
        ADir mDir = getMountedDir( mountFS );
        if ( mDir !is null ) {
            return mDir.getDir( path );
        }

        return null;
    }

    AFile getFile( string path, string mountFS = "root" ) {
        ADir mDir = getMountedDir( mountFS );
        if ( mDir !is null ) {
            return mDir.getFile( path );
        }

        return null;
    }

    ADir makeDir( string name, string path = "", string mountFS = "root" ) {
        ADir mDir = getMountedDir( mountFS );
        if ( mDir ) {
            return mDir.makeDir( name, path );
        }

        return null;
    }

    AFile makeFile( string name, string path = "", EFileMode fileMode = EFileMode.FM_WRITE, string mountFS = "root" ) {
        ADir mDir = getMountedDir( mountFS );
        if ( mDir ) {
            return mDir.makeFile( name, path, fileMode );
        }

        return null;
    }

    ubyte[] getFileRawData( string path, string mountFS = "root" ) {
        if ( ADir mDir = getMountedDir( mountFS ) ) {
            if ( AFile resFile = mDir.getFile( path ) ) {
                resFile.readRawData();
            }
        }

        return null;
    }
}