module engine.core.hal.input;

public:
import engine.core.mod;
import engine.core.math.vec;
import engine.core.input.keyboard;
import engine.core.input.mouse;

class CInput : IModule {
    SModuleInfo info() {
        return SModuleInfo( 
            "UNIMPLEMENTED_INPUT",
            "NENG2", 
            "1.0",
            EModuleInitPhase.MIP_UPON_REQUEST,
            EModuleDestroyPhase.MDP_NORMAL,
            EModuleUpdate.MU_NORMAL,
        );
    }

    void onLoad( CEngine engine ) {}
    void onUnload( CEngine engine ) {}
    void update( float delta ) {}

    bool isKeyPressed( EKeyboard key ) {
        return false;
    }

    final bool isKeyReleased( EKeyboard key ) {
        return !isKeyPressed( key );
    }

    bool isMouseButtonPressed( EMouseButton button ) {
        return false;
    }

    final bool isMouseButtonReleased( EMouseButton button ) {
        return !isMouseButtonPressed( button );
    }

    SVec2I mousePos() {
        return SVec2I( -1, -1 );
    }
}