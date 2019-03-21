module engine.core.input.input;

import engine.core.mod;
public import engine.core.math.vec;
public import engine.core.input.keyboard;
public import engine.core.input.mouse;

class CInput : IModule {
    @property
    SModuleInfo info() {
        return SModuleInfo( 
            "UNIMPLEMENTED_INPUT",
            "NENG2", 
            "1.0"
        );
    }

    @property
    final EModuleUpdate updateInfo() {
        return EModuleUpdate.MU_NORMAL;
    }

    @property
    final EModuleInitPhase initPhase() {
        return EModuleInitPhase.MIP_UPON_REQUEST;
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