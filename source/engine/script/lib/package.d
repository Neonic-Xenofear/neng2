module engine.script.lib;

public:
import engine.script.lib.math;

import engine.core.mod.register_module;

class CScriptLibModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        engine.scriptManager.registerClass!SVec2D_Script;
        engine.scriptManager.registerClass!SVec3D_Script;
    }

    void onUnload( CEngine engine ) {
        engine.scriptManager.unregisterClass!SVec2D_Script;
        engine.scriptManager.unregisterClass!SVec3D_Script;
    }
}