module engine;

public:
import engine.app;
import engine.core;
import engine.framework;
import engine.physics2d;
import engine.render;
import engine.resources;
import engine.scene;
import engine.script;

void registerEngineModules() {
    CModuleManager.get().add( new CScriptLibModule() );
    CModuleManager.get().add( new CCoreResourcesModule() );
    CModuleManager.get().add( new CNodesBaseModule() );
    CModuleManager.get().add( new CNodes2DModule() );

    CModuleManager.get().add( new CResourcesModule() );
    CModuleManager.get().add( new CInputModule() );
    CModuleManager.get().add( new CScriptSTDModule() );
    CModuleManager.get().add( new CPhys2DModule() );
    CModuleManager.get().add( new CRenderModule() );

    log.info( "Engine modules registered" );
}