module engine.core.mod.register_module;

import engine.core.mod.imod;
public import engine.core.engine.engine;
public import engine.core.engine.class_db;

/**
    Used to register script types
*/
abstract class ARegisterModule : IModule {
    @property
	final SModuleInfo info() {
        import std.string;
		return SModuleInfo( 
			this.classinfo.name.split( "." )[$ - 1], 
			"NENG2", 
			"1.0"
		);
	}

    @property
    final EModuleUpdate updateInfo() {
        return EModuleUpdate.MU_NONE;
    }
    
    @property
    final EModuleInitPhase initPhase() {
        return EModuleInitPhase.MIP_NORMAL;
    }

    final void update( float delta ) {}
}