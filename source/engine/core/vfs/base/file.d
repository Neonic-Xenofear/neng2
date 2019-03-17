module engine.core.vfs.base.file;

public import engine.core.vfs.base.base;
import engine.core.vfs.base.dir;

enum EFileMode {
    FM_NONE,    //Or closed
    FM_READ,
    FM_WRITE,
    FM_RW,      //Read-write
}

abstract class AFile : AFSBaseObject {
protected:
    EFileMode fileMode = EFileMode.FM_NONE;
    string correctPath;

public:
    /**
        Create file if not exists
    */
    abstract void create();
    abstract ubyte[] readRawData();
    abstract void writeRawData( ubyte[] data );

    string corrPath() const {
        return correctPath;
    }

public:
    this( string iName, string i_path, EFileMode mode = EFileMode.FM_READ, ADir i_parent = null ) {
        setPath( iName, i_path );
        fileMode = mode;
        _parent = i_parent;

        import std.string : endsWith, replace;
        if ( _physPath.endsWith( name ) ) {
            correctPath = _physPath;
            _physPath = _physPath.replace( r"\", "/" ).replace( "/" ~ name, "" );
        } else {
            _physPath = _physPath.replace( r"\", "/" );
            correctPath = _physPath ~ "/" ~ _name;
        }
    }
}