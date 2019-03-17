module engine.core.utils.singleton;

import std.string;

/**
    Singleton convenience adaptation
*/
abstract class ASingleton( T ) {
protected:
    this() {}

    // Cache instantiation flag in thread-local bool
    // Thread local
    static bool bInstantiated;

    // Thread global
    __gshared T inst;

public:
    static T get() {
        if ( !bInstantiated ) {
            synchronized ( T.classinfo ) {
                if ( !inst ) {
                    inst = new T();
                }

                bInstantiated = true;
            }
        }

        return inst;
    }
    
}

static string singletonImpl( T )() pure {
    string ret = format( "
protected:
    this() {}

    // Cache instantiation flag in thread-local bool
    // Thread local
    static bool bInstantiated;

    // Thread global
    __gshared %1$s inst;

public:
    static %1$s get() {
        if ( !bInstantiated ) {
            synchronized ( %1$s.classinfo ) {
                if ( !inst ) {
                    inst = new %1$s();
                }

                bInstantiated = true;
            }
        }

        return inst;
    }",
    T.stringof
    );

    return ret;
}