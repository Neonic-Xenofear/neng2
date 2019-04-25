module engine.core.mod.lib_module;

public import engine.core.mod.imod;
import derelict.util.sharedlib;

alias TGetModuleImpl = extern(C) nothrow IModule function();
enum MODULE_IMPL_NAME = "getModule";

/**

*/
class CLibModule {
    SharedLib lib;
    IModule mod;
    TGetModuleImpl loadImpl;

    void loadFromFile( string path, string loadFuncName = MODULE_IMPL_NAME ) {
        lib.load( [path] );
        
	    loadImpl = cast( TGetModuleImpl )lib.loadSymbol( loadFuncName );
        if ( loadImpl ) {
	        mod = loadImpl();
        } else {
            log.error( "Invalid shared lib module file: " ~ path );
        }
    }

    void unloadLib() {
        lib.unload();
    }
}

template TImplementModule( T ) {
    import std.string : format;
 
	enum TImplementModule = format(
		q{
        import engine.core.mod.imod;

		extern(C)
        export nothrow IModule %2$s() {
            import core.memory;
            %1$s inst = new %1$s;
            GC.addRoot( cast( void* )inst );
            return inst;
        }

        version( Windows )
        extern( Windows ) bool DllMain( void* hInstance, uint ulReason, void* ) {
            import core.sys.windows.windows;
            import core.sys.windows.dll;
            switch ( ulReason ) {
            default: 
                assert( 0 );
            
            case DLL_PROCESS_ATTACH:
                dll_process_attach( hInstance, true );
                break;

            case DLL_PROCESS_DETACH:
                dll_process_detach( hInstance, true );
                break;

            case DLL_THREAD_ATTACH:
                dll_thread_attach( true, true );
                break;

            case DLL_THREAD_DETACH:
                dll_thread_detach( true, true );
                break;
            }
            return true;
        }
        },
		T.stringof,
        MODULE_IMPL_NAME
    );
}