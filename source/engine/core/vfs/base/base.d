module engine.core.vfs.base.base;

import std.string;
import std.file : thisExePath;
import std.path;

abstract class AFSBaseObject {
protected:
    AFSBaseObject _parent;
    string _name;
    string _physPath;

protected:
    final void setPath( string i_name, string i_path ) {
        _name = i_name;
        _physPath = i_path;
    }

public:
    @property
    AFSBaseObject parent() {
        return _parent;
    }

    @property
    @nogc
    final string name() const {
        return _name;
    }

    @property
    string fullPath() {
        return getFullVirtualPath();
    }

    @property
    string physPath() {
        return _physPath;
    }

protected:
    /**
        Used for get virtual path of object, seems like:
            ./info/test1/legend.txt
    */
    string getFullVirtualPath() {
        if ( _parent !is null ) {
            return _parent.getFullVirtualPath ~ "/" ~ name;
        }

        return "./" ~ name;
    }
}