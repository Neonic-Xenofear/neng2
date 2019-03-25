module engine.main;

import engine;
import modules;

void main() {
    log.info( "ENGINE INIT START" );
        bencFunc!( { 
            initFS();
        } )( "INIT FS" );

        bencFunc!( { 
            registerEngineModules();
            registerFrameworkModules();
            registerModules();
        } )( "MODULES_REGISTER" );

        bencFunc!( { CModuleManager.get().loadModules( EModuleInitPhase.MIP_PRE ); } )( "MODULES_PRE_INIT" );
        loadEngineConfig( getVFS().getFile( "resources/configs/engine.sdl" ) );
        bencFunc!( { CModuleManager.get().loadModules( EModuleInitPhase.MIP_NORMAL ); } )( "MODULES_NORMAL_INIT" );
        getEngine().updateModules();
        bencFunc!( { CModuleManager.get().loadModules( EModuleInitPhase.MIP_POST ); } )( "MODULES_POST_INIT" );
        getEngine().initWindow();
        getEngine().render = new CMTRender();
    log.info( "ENGINE INIT END" );

    log.info( "ENGINE START MAIN LOOP" );
        test();
        getEngine().initMainLoopThread();
    log.info( "ENGINE END MAIN LOOP" );

    //Engine shutdown
        getEngine().destroy();
    log.info( "ENGINE SHUTDOWN" );
}

private void initFS() {
    CDiskDir diskDir = 
    new CDiskDir( "root", appExePathAndNorm( "../" ) );
	diskDir.updatePhysSubDirs( true );
	diskDir.updatePhysFiles();

    //Make cache dir if not exist
    diskDir.getOrMakeDir( ".cache" );

    CDiskDir cacheFS = new CDiskDir( "cache", appExePathAndNorm( "../.cache" ) );
    cacheFS.updatePhysSubDirs( true );
	cacheFS.updatePhysFiles();

    getVFS().mount( diskDir );
    getVFS().mount( cacheFS );
}

private void loadEngineConfig( AFile iFile ) {
    if ( iFile is null ) {
        log.error( "Invalid config file!" );
        return;
    }

    CSDLang cF = new CSDLang();
    cF.parseFile( iFile );
    CConfig conf = cF.toConfig();
    getConfig().setData( conf.getData() );

    conf.destroy();
    cF.destroy();

    log.info( "Config loaded" );
}

private void test() {
    CCamera2D camera = new CCamera2D();
    CScript scr = loadScript( "resources/test/script/test.lua" );
    scr.className = "CTest";
    camera.setScript( scr );
    getEngine().sceneTree.addRootNode( camera );
    getEngine().sceneTree.currentCamera = camera;

    CStaticBody2D stat = new CStaticBody2D();
    stat.addShape( new CBoxShape2D( 500, 10 ) );
    stat.setPos( SVec2F( 0, 600 ) );

    getEngine().sceneTree.addRootNode( stat );

    {
        CButton textbox = new CButton();
        textbox.transform.pos = SVec2F( 400, 100 );
        textbox.setText( "test" );
        textbox.setRectWidth( 100 );
        textbox.setRectHeight( 100 );
        textbox.setNormalTexture( loadTexture( "resources/test/textures/test1.png" ) );
        textbox.margins = [20, 20, 20, 20];
        textbox.anchors = [EAnchor.A_BEGIN, EAnchor.A_BEGIN, EAnchor.A_END, EAnchor.A_END];
        getEngine().sceneTree.addRootNode( textbox );

        CButton t = new CButton();
        t.transform.pos = SVec2F( 400, 100 );
        t.setText( "HELLLOOOOOOOO" );
        t.setRectWidth( 100 );
        t.setRectHeight( 100 );
        t.setNormalTexture( loadTexture( "resources/test/textures/test1.png" ) );
        t.margins = [50, 50, 50, 50];
        t.anchors = [EAnchor.A_BEGIN, EAnchor.A_BEGIN, EAnchor.A_END, EAnchor.A_END];
        textbox.addChild( t );
    }



    CWindowGUI win = new CWindowGUI();
    win.setTitleTexture( loadTexture( "resources/test/textures/test1.png" ) );
    win.transform.pos = SVec2F( 100, 200 );
    win.setRectWidth( 200 );
    win.setRectHeight( 400 );
    getEngine().sceneTree.addRootNode( win );

    SSceneTreeSerializer serializer;
    CNode node = new CNode();
    foreach ( CNode n; getEngine().sceneTree.getRootNodes() ) {
        node.addChild( n );
    }
    serializer.serialize( node, getEngine().sceneTree.getScriptNodes() );
    getVFS().getRootDir().getFile( "debug/test_refl.sdl" ).writeRawData( cast( ubyte[] )serializer.toString() );

    CMesh mesh = loadMesh( "" );
    mesh.queueFree();

    /*CNode resNode = new CNode();
    SSceneDeserializer des = SSceneDeserializer( cast( string )getVFS().getRootDir().getFile( "debug/test_refl.sdl" ).readRawData( ) );
    des.deserialize( resNode );
    getEngine().sceneTree.addRootNode( resNode );*/
}