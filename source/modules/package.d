module modules;

import engine.core.mod;

public:
import modules.platform;
import modules.render;

import modules.box2d_phys;
import modules.png;

void registerModules() {
    import engine.app.logger : log;

    CModuleManager.get().add( new CSDLInput() );
    CModuleManager.get().add( new COpenGLRender() );
    getClassDB().registerClassWithoutScript!CSDLWindow;

    CModuleManager.get().add( new b2CPhysWorld2D() );

    CModuleManager.get().add( new CPNGLoaderModule() );

    log.info( "Dynamic modules registered" );
}
