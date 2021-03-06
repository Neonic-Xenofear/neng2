module engine.framework.rgui.rgui;

public import engine.core.mod.imod;

interface IRuntimeGUI : IModule {
    void newFrame();
    void endFrame();

    bool treeNode( string text );
    bool checkBox( string label, ref bool val );

    bool beginMainMenuBar();
    void endMainMenuBar();
    bool beginMenu( string label );
    void endMenu();
    bool menuItem( string label );

    void separator();
}

IRuntimeGUI RGUI() {
    import engine.core.mod.mod_manager : CModuleManager;
    return CModuleManager.get().getModule!IRuntimeGUI( confGets( "engine/framework/rgui" ) );
}