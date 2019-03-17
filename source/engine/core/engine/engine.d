module engine.core.engine.engine;

import std.datetime;
import core.thread;
import std.conv;

import engine.core.utils.singleton;
public import engine.render;
import engine.app.window;
public import engine.app.logger;
public import engine.scene.base.scene_tree;
public import engine.core.mod.mod_manager;
public import engine.core.vfs.vfs;
public import engine.core.engine.time;
public import engine.script;
public import engine.core.engine.config;
public import engine.physics2d.world;
public import engine.core.resource;

final class CEngine : ASingleton!CEngine {
private:
    float secTick = 0;
    long countedFrames;
    int currFPS = 0;

    int framesPerSecond;
    float period;
    int milliPeriod;

    bool bRestrictFPS = true;
    float lastTickTime;
    float lastFPSCheckTime;
    
public:
    ARender render;
    CWindow window;
    CSceneTree sceneTree;
    APhysWorld2D physWorld;
    CInput input;
    CVFS vfs;
    CScriptManager scriptManager;
    CResourceManager resourceManager;

    CConfig config;

    bool bWork = true;

    this() {
        sceneTree = new CSceneTree();
        vfs = new CVFS();
        scriptManager = new CScriptManager();
        config = new CConfig();
        
        resourceManager = new CResourceManager();

        lastTickTime = lastFPSCheckTime = Time.totalTime();
    }

    ~this() {
        resourceManager.destroy();
    }

    void initWindow() {
        if ( !window ) {
            window = getClassDB().newObject!CWindow( confGets( "engine/app/window/class" ) );
            assert( window, "Invalid native window class: " ~ confGets( "engine/app/window/class" ) );
            window.setup( 
                confGets( "engine/app/window/title" ), 
                confGeti( "engine/app/window/width" ), 
                confGeti( "engine/app/window/height" ) 
            );

            setFramePerSecond( confGeti( "engine/modules/render/fpsLock" ) );
        }
    }

    void updateModules() {
        physWorld = CModuleManager.get().getModule!APhysWorld2D( confGets( "engine/modules/physics" ) );
        input = CModuleManager.get().getModule!CInput( confGets( "engine/modules/input" ) );

        if ( input is null ) {
            log.error( "Invalid input module: " ~ config.gets( "engine/modules/input" ) );
        }
    }

    void initMainLoopThread() {
        mainLoop();
    }

    void mainLoop() {
        while ( bWork ) {
            if ( ( bRestrictFPS && lastTickTime < Time.totalTime - period ) || !bRestrictFPS ) {
                immutable( double ) delta = ( Time.totalTime - lastTickTime );

                CModuleManager.get().update( EModuleUpdate.MU_PRE, delta );
                updateProcess( delta );
                CModuleManager.get().update( EModuleUpdate.MU_POST, delta );

                countedFrames++; 
                lastTickTime = Time.totalTime();
            }

            //Calculate FPS
            if ( lastFPSCheckTime < Time.totalTime() - 1 ) {
                lastFPSCheckTime = Time.totalTime();
                currFPS = cast( int )countedFrames;
                countedFrames = 0;
            }

            resourceManager.processQueueFree();
            Time.update();
        }
    }

    void drawInfo( double delta ) {
        import std.conv : to;
        render.drawText( "FPS: " ~ std.conv.to!string( currFPS ) );
        render.drawText( "frameTime: " ~ std.conv.to!string( delta ), SVec2I( 0, 15 ) );
    }

    void updateProcess( float delta ) {
        render.clearScreen();

        sceneTree.update( delta );
        
        debug drawInfo( delta );

        CModuleManager.get().update( EModuleUpdate.MU_NORMAL, delta );

        render.renderEnd();
        window.swapBuffers();
    }

    void setFramePerSecond( int val ) {
        bRestrictFPS = ( val != -1 );

        framesPerSecond = val;
        period = ( 1.0f / framesPerSecond );
        milliPeriod = cast( int )period;
    }
}

CEngine getEngine() {
    return CEngine.get();
}

ARender getRender() {
    if ( getEngine().render is null && !confGetb( "engine/modules/rules/bAllowWorkWithoutRender" ) ) {
        log.error( "Invalid render module: " ~ getConfig().gets( "engine/modules/render" ) );
    }

    return getEngine().render;
}

CVFS getVFS() {
    return getEngine().vfs;
}

APhysWorld2D getPhysWorld2D() {
    return getEngine().physWorld;
}

CInput getInput() {
    if ( getEngine().input is null ) {
        log.error( "Invalid input module: " ~ getConfig().gets( "engine/modules/input" ) );
    }

    return getEngine().input;
}

CResourceManager getResourceManager() {
    return getEngine().resourceManager;
}

CConfig getConfig() {
    return getEngine().config;
}

CConfig confSet( T )( string name, T val ) {
    return getConfig().set( name, val );
}

string confGets( string name ) {
    return getConfig().gets( name );
}

int confGeti( string name ) {
    return getConfig().geti( name );
}

bool confGetb( string name ) {
    return getConfig().getb( name );
}

float confGetf( string name ) {
    return getConfig().getf( name );
}

string RESOURCES_PATH() {
    return getConfig().gets( "engine/paths/RESOURCES_PATH" );
}

string BIN_PATH() {
    return getConfig().gets( "engine/paths/BIN_PATH" );
}