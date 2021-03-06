module engine.framework.console.console;

import engine.core.mod;

import engine.framework.console.cvar;

alias TConsoleFunc = void function( CVar[string] args );

class CConsole : IModule {
protected:
    CVar[string] vars;
    TConsoleFunc[string] funcs;

public:
    SModuleInfo info() {
        return SModuleInfo(
            "CONSOLE", 
            "NENG2_FRAMEWORK", 
            "1.0",
            EModuleInitPhase.MIP_NORMAL,
            EModuleDestroyPhase.MDP_NORMAL,
            EModuleUpdate.MU_NORMAL
        );
    }

    void onLoad( CEngine engine ) {}

    void onUnload( CEngine engine ) {}

    void update( float delta ) {}

    ~this() {
        foreach ( CVar v; vars ) {
            v.destroy();
        }

        funcs.clear();
    }

    void execFunc( string funcName, string[] args ) {
        if ( TConsoleFunc* f = funcName in funcs ) {
            CVar[string] entArgs;
            foreach ( string i; args ) {
                if ( CVar* v = i in vars ) {
                    entArgs[i] = vars[i];
                } else {
                    log.error( "Invalid cvar name: " ~ i );
                    entArgs[i] = null;
                }
            }

            ( *f )( entArgs );
        }
    }

    void registerFunc( TConsoleFunc func, string funcName ) {
        if ( TConsoleFunc* f = funcName in funcs ) {
            log.error( "Console command name registered: " ~ funcName );
            return;
        }

        funcs[funcName] = func;
    }

    void addVar( CVar var ) {
        if ( CVar* v = var.getName() in vars ) {
            log.error( "CVar already registered: " ~ var.getName() );
            return;
        }

        vars[var.getName()] = var;
    }
}

CConsole getConsole() {
    import engine.core.mod.mod_manager : CModuleManager;
    return CModuleManager.get().getModule!CConsole( "CONSOLE" );
}