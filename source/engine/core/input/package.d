module engine.core.input;

public:
import engine.core.input.action;
import engine.core.input.input_type;
import engine.core.input.mod_keys;
import engine.core.input.input_event;
import engine.core.input.keyboard;
import engine.core.input.mouse;
import engine.core.input.input;

import engine.core.mod.register_module;

class CInputModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        //engine.scriptManager.registerClass!CInput;
    }

    void onUnload( CEngine engine ) {
        //engine.scriptManager.unregisterClass!CInput;
    }
}