module engine.script;

public:
import engine.script.lib;
import engine.script.attrib;
import engine.script.script;
import engine.script.script_manager;
import engine.script.script_loader;

import engine.core.mod.register_module;

class CScriptSTDModule : ARegisterModule {
    CScriptLoader loader;
    void onLoad( CEngine engine ) {
        getClassDB().registerClass!CScript;

        loader = new CScriptLoader();
        engine.resourceManager.registerResourceLoader!CScript( loader );
    }

    void onUnload( CEngine engine ) {
        getClassDB().unregisterClass!CScript;
    }
}