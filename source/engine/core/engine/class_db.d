module engine.core.engine.class_db;

import engine.app.logger;
import engine.core.utils.singleton;
import engine.core.utils.array;
import engine.script.script_manager;
import engine.core.engine.engine;

struct SRegClass {
    TypeInfo_Class classInfo;
}

class CClassDB : ASingleton!CClassDB {
private:
    SRegClass[] registeredClasses;
    CScriptManager scriptManager;

public:
    this() {
        scriptManager = getEngine().scriptManager;
    }

    void registerClass( T )() {
        registerClassWithoutScript!T;
        if ( scriptManager !is null ) {
            scriptManager.registerClass!T;
        }
    }

    void registerClassWithoutScript( T )() {
        foreach ( SRegClass i; registeredClasses ) {
            if ( i.classInfo == T.classinfo ) {
                log.warning( T.stringof ~ " already registered" );
                return;
            }
        }

        SRegClass newClass;
        newClass.classInfo = T.classinfo;

        registeredClasses ~= newClass;
    }

    void unregisterClass( T )() {
        foreach ( SRegClass i; registeredClasses ) {
            if ( i.classInfo == T.classinfo ) {
                removeElement( registeredClasses, i );
            }
        }

        if ( scriptManager !is null ) {
            scriptManager.unregisterClass!T;
        }
    }

    Object newObject( string name ) {
        foreach ( SRegClass i; registeredClasses ) {
            if ( i.classInfo.name.split( "." )[$ - 1] == name ) {
                return i.classInfo.create();
            }
        }

        return null;
    }

    T newObject( T )( string name ) {
        return cast( T )newObject( name );
    }
}

CClassDB getClassDB() {
    return CClassDB.get();
}