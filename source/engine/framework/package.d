module engine.framework;

public:
import engine.framework.console;
import engine.framework.rgui;

void registerFrameworkModules() {
    import engine.core.utils.logger : log;
    CModuleManager.get().add( new CConsole() );

    log.info( "Framework modules registered" );
}