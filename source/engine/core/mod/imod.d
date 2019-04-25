module engine.core.mod.imod;

public import engine.core.engine.engine;

/**
    Module init phase
*/
enum EModuleInitPhase {
    MIP_NORMAL,       ///Init after engine base init
    MIP_PRE,          ///Init befire engine base init
    MIP_POST,         ///Init after normal modules init
    MIP_UPON_REQUEST, ///Init only upon request
}

/**
    Module destroy after engine shutdow time
*/
enum EModuleDestroyPhase {
    MDP_NORMAL,             ///Regular module destroy
    MDP_BEFORE_SCENE_TREE,  ///Destroy module before scene tree
    MDP_BEFORE_RENDER,      ///Destroy module before render
}

/**
    Module update time
*/
enum EModuleUpdate {
    MU_NONE,        ///Never update
    MU_ALWAYS,      ///Update on every iteration, ignore FPS lock
    MU_PRE,         ///Update before main engine update
    MU_NORMAL,      ///Update in main engine update
    MU_POST,        ///Update after main engine update
}

/**
    Module info
*/
struct SModuleInfo {
    string name;
    string author;
    string ver;

    EModuleInitPhase initPhase = EModuleInitPhase.MIP_NORMAL;
    EModuleDestroyPhase destroyPhase = EModuleDestroyPhase.MDP_NORMAL;
    EModuleUpdate updateInfo = EModuleUpdate.MU_NORMAL;

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
    SModuleInfo info();

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