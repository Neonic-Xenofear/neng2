module engine.core.mod.mod_manager;

import std.algorithm : canFind;
import engine.core.engine.class_db;
public import engine.core.mod.imod;
public import engine.core.mod.lib_module;
import engine.core.utils.singleton;
import engine.app.logger;
import engine.core.engine.engine;
public import engine.core.vfs.vfs;

/**
    Module adapter in CModuleManager
*/
class CValidModule {
    IModule inst; ///Module instance
    bool bInitialized = false; ///If initialized
}

/**
    Modules manager singleton
*/
class CModuleManager : ASingleton!CModuleManager {
protected:
    CValidModule[] modules; ///Loaded modules

public:
    /**
        Add module to registry.
        Params:
            mod - module
    */
    void add( T : IModule )( T mod ) {
        assert( mod !is null, "Trying to add invalid module!" );

        if ( isContains( mod ) ) {
            log.error( "Module '" ~ mod.info.name ~ "' is already registered!" );
            return;
        }

        CValidModule res = new CValidModule();
        res.inst = mod;

        log.info( "Module added: ", mod.info.name );
        modules ~= res;

        getClassDB().registerClassWithoutScript!T;
    }

    /**
        Gets module from registry.
        Params:
            T - returns module as type.
            name - module name.
    */
    T getModule( T : IModule )( string name ) {
        foreach ( CValidModule mod; modules ) {
            if ( mod.inst.info.name == name ) {
                if ( mod.inst.initPhase == EModuleInitPhase.MIP_UPON_REQUEST && !mod.bInitialized ) {
                    mod.inst.onLoad( getEngine() );
                    mod.bInitialized = true;
                }

                return cast( T )mod.inst;
            }
        }

        return null;
    }

    /**
        Remove module.
        Params:
            mod - module.
    */
    void removeModule( T : IModule )( T mod ) {
        import engine.core.utils.array : removeElement;

        if ( !mod ) {
            return;
        }

        foreach ( CValidModule i; modules ) {
            if ( i.inst.info.name == mod.info.name ) {
                mod.onUnload( getEngine() );
                removeElement( modules, i );
                log.info( "Module unloaded: ", i.inst.info.name );
                i.destroy();
                return;
            }
        }

        log.error( "Invalid remove module: " ~ mod.info.name );
    }

    /**
        Gets if a module is contained in this registry.
        Params:
            mod - check module.
    */
    bool isContains( IModule mod ) {
        foreach ( CValidModule itMod; modules ) {
            if ( itMod.inst == mod || itMod.inst.info.name == mod.info.name ) {
                return true;
            }
        }

        return false;
    }

    /**
        Load modules by given phase.
        Params:
            phase- loading phase.
    */
    void loadModules( EModuleInitPhase phase ) {
        foreach ( CValidModule mod; modules ) {
            if ( mod.bInitialized || mod.inst.initPhase != phase ) {
                continue;
            }

            mod.inst.onLoad( getEngine() );
            mod.bInitialized = true;
        }
    }

    /**
        Unload and destroy all modules.
    */
    void unloadModules() {
        foreach ( CValidModule mod; modules ) {
            //Just skip all invalid modules
            if ( !mod ) {
                continue;
            }

            if ( !mod.inst ) {
                log.info( "Invlaid instance module unloaded" );
                mod.destroy();
                continue;
            }

            mod.inst.onUnload( getEngine );
            log.info( "Module unloaded: ", mod.inst.info.name );

            mod.inst.destroy();
            mod.destroy();
        }
    }

    /**
        Runs updates for all module update types.
        Params:
            updateInfo - update phase.
            delta - delta time.
    */
    void update( EModuleUpdate updateInfo, float delta ) {
        foreach ( CValidModule mod; modules ) {
            if ( mod.inst.updateInfo == EModuleUpdate.MU_ALWAYS ) {
                mod.inst.update( delta );
                continue;
            }

            if ( mod.inst.updateInfo == updateInfo && mod.bInitialized ) {
                mod.inst.update( delta );
            }
        }
    }
}