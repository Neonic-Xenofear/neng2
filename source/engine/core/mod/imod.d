module engine.core.mod.imod;

public import engine.core.engine.engine;

/**
    Module init phase
*/
enum EModuleInitPhase {
    MIP_NORMAL,
    MIP_PRE,
    MIP_POST,
    MIP_UPON_REQUEST,
}

/**
    Module update time
*/
enum EModuleUpdate {
    MU_NONE = 0,
    MU_ALWAYS,
    MU_PRE,
    MU_NORMAL,
    MU_POST,
}

/**
    Module info
*/
struct SModuleInfo {
    string name;
    string author;
    string ver;

    string toString() {
        return  "\tName: " ~ name ~
                "\n\tAuthor: " ~ author ~ 
                "\n\tVersion: " ~ ver;
    }
}

/**
    Module interface
*/
interface IModule {
public:
    /**
        Module info
    */
    @property
    SModuleInfo info();

    @property
    EModuleUpdate updateInfo();

    @property
    EModuleInitPhase initPhase();

    /**
        Called when module loaded
    */
    void onLoad( CEngine engine );

    /**
        Called when module unloaded
    */
    void onUnload( CEngine engine );

    /**
        Called when module update
    */
    void update( float delta );
}