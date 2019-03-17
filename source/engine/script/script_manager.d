module engine.script.script_manager;

import core.thread;

import engine.core.ext_data;
import engine.script.script;
import engine.script.lua.state;
import engine.app.logger;
import engine.core.vfs.vfs;
import engine.core.utils.path;

class CScriptManager {
    State machine;

    this() {
        machine = new State();
        machine.addPath( appExePathAndNorm( ".." ) );
    }

    ~this() {
        machine.destroy();
    }

    void registerClass( T )() {
        machine.registerClass!T();
    }

    void unregisterClass( T )() {
        machine.unregisterClass!T();
    }

    void callClassFunction( Args... )( string className, string func, CExtData objectData, Args args ) {
        machine.callClassFunction( className, func, objectData, args );
    }

    void getNewScriptObject( string className, CExtData data ) {
        return machine.getNewScriptObject( className, data );
    }

    void processFile( AFile file ) {
        if ( file is null ) {
            log.error( "Trying to process invalid file!" );
            return;
        }

        log.info( "Process script file: " ~ "\n\t" ~ file.fullPath );
        machine.doString( cast( string )file.readRawData() );
    }

    string nativeClassName( CScript script ) {
        if ( script.className != "" ) {
            return machine.getNativeClassName( script.className );
        } else {
            return "";
        }
    }
}