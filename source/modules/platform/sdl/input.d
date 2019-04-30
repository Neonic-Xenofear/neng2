module modules.platform.sdl.input;

import derelict.sdl2.sdl;

public import engine.core.hal.input;

class CSDLInput : CInput {
    int[EKeyboard] SDLKeyboard;
    EKeyboard[int] engineKeyboard;

    @property
    override SModuleInfo info() {
        return SModuleInfo( 
            "SDL_INPUT",
            "NENG2", 
            "1.0",
            EModuleInitPhase.MIP_UPON_REQUEST,
            EModuleDestroyPhase.MDP_NORMAL,
            EModuleUpdate.MU_NORMAL
        );
    }

    override void onLoad( CEngine engine ) {
        SDLKeyboard[EKeyboard.K_0] = SDL_Scancode.SDL_SCANCODE_0;
        SDLKeyboard[EKeyboard.K_1] = SDL_Scancode.SDL_SCANCODE_1;
        SDLKeyboard[EKeyboard.K_2] = SDL_Scancode.SDL_SCANCODE_2;
        SDLKeyboard[EKeyboard.K_3] = SDL_Scancode.SDL_SCANCODE_3;
        SDLKeyboard[EKeyboard.K_4] = SDL_Scancode.SDL_SCANCODE_4;
        SDLKeyboard[EKeyboard.K_5] = SDL_Scancode.SDL_SCANCODE_5;
        SDLKeyboard[EKeyboard.K_6] = SDL_Scancode.SDL_SCANCODE_6;
        SDLKeyboard[EKeyboard.K_7] = SDL_Scancode.SDL_SCANCODE_7;
        SDLKeyboard[EKeyboard.K_8] = SDL_Scancode.SDL_SCANCODE_8;
        SDLKeyboard[EKeyboard.K_9] = SDL_Scancode.SDL_SCANCODE_9;

        SDLKeyboard[EKeyboard.K_F1] = SDL_Scancode.SDL_SCANCODE_F1;
        SDLKeyboard[EKeyboard.K_F2] = SDL_Scancode.SDL_SCANCODE_F2;
        SDLKeyboard[EKeyboard.K_F3] = SDL_Scancode.SDL_SCANCODE_F3;
        SDLKeyboard[EKeyboard.K_F4] = SDL_Scancode.SDL_SCANCODE_F4;
        SDLKeyboard[EKeyboard.K_F5] = SDL_Scancode.SDL_SCANCODE_F5;
        SDLKeyboard[EKeyboard.K_F6] = SDL_Scancode.SDL_SCANCODE_F6;
        SDLKeyboard[EKeyboard.K_F7] = SDL_Scancode.SDL_SCANCODE_F7;
        SDLKeyboard[EKeyboard.K_F8] = SDL_Scancode.SDL_SCANCODE_F8;
        SDLKeyboard[EKeyboard.K_F9] = SDL_Scancode.SDL_SCANCODE_F9;
        SDLKeyboard[EKeyboard.K_F10] = SDL_Scancode.SDL_SCANCODE_F10;
        SDLKeyboard[EKeyboard.K_F11] = SDL_Scancode.SDL_SCANCODE_F11;
        SDLKeyboard[EKeyboard.K_F12] = SDL_Scancode.SDL_SCANCODE_F12;

        SDLKeyboard[EKeyboard.K_A] = SDL_Scancode.SDL_SCANCODE_A;
        SDLKeyboard[EKeyboard.K_B] = SDL_Scancode.SDL_SCANCODE_B;
        SDLKeyboard[EKeyboard.K_C] = SDL_Scancode.SDL_SCANCODE_C;
        SDLKeyboard[EKeyboard.K_D] = SDL_Scancode.SDL_SCANCODE_D;
        SDLKeyboard[EKeyboard.K_E] = SDL_Scancode.SDL_SCANCODE_E;
        SDLKeyboard[EKeyboard.K_F] = SDL_Scancode.SDL_SCANCODE_F;
        SDLKeyboard[EKeyboard.K_G] = SDL_Scancode.SDL_SCANCODE_G;
        SDLKeyboard[EKeyboard.K_H] = SDL_Scancode.SDL_SCANCODE_H;
        SDLKeyboard[EKeyboard.K_I] = SDL_Scancode.SDL_SCANCODE_I;
        SDLKeyboard[EKeyboard.K_J] = SDL_Scancode.SDL_SCANCODE_J;
        SDLKeyboard[EKeyboard.K_K] = SDL_Scancode.SDL_SCANCODE_K;
        SDLKeyboard[EKeyboard.K_L] = SDL_Scancode.SDL_SCANCODE_L;
        SDLKeyboard[EKeyboard.K_M] = SDL_Scancode.SDL_SCANCODE_M;
        SDLKeyboard[EKeyboard.K_N] = SDL_Scancode.SDL_SCANCODE_N;
        SDLKeyboard[EKeyboard.K_O] = SDL_Scancode.SDL_SCANCODE_O;
        SDLKeyboard[EKeyboard.K_P] = SDL_Scancode.SDL_SCANCODE_P;
        SDLKeyboard[EKeyboard.K_Q] = SDL_Scancode.SDL_SCANCODE_Q;
        SDLKeyboard[EKeyboard.K_R] = SDL_Scancode.SDL_SCANCODE_R;
        SDLKeyboard[EKeyboard.K_S] = SDL_Scancode.SDL_SCANCODE_S;
        SDLKeyboard[EKeyboard.K_T] = SDL_Scancode.SDL_SCANCODE_T;
        SDLKeyboard[EKeyboard.K_U] = SDL_Scancode.SDL_SCANCODE_U;
        SDLKeyboard[EKeyboard.K_V] = SDL_Scancode.SDL_SCANCODE_V;
        SDLKeyboard[EKeyboard.K_W] = SDL_Scancode.SDL_SCANCODE_W;
        SDLKeyboard[EKeyboard.K_X] = SDL_Scancode.SDL_SCANCODE_X;
        SDLKeyboard[EKeyboard.K_Y] = SDL_Scancode.SDL_SCANCODE_Y;
        SDLKeyboard[EKeyboard.K_Z] = SDL_Scancode.SDL_SCANCODE_Z;

        SDLKeyboard[EKeyboard.K_SPACE] = SDL_Scancode.SDL_SCANCODE_SPACE;
        SDLKeyboard[EKeyboard.K_ESCAPE] = SDL_Scancode.SDL_SCANCODE_ESCAPE;
        SDLKeyboard[EKeyboard.K_SHIFT] = SDL_Scancode.SDL_SCANCODE_LSHIFT;
        SDLKeyboard[EKeyboard.K_TAB] = SDL_Scancode.SDL_SCANCODE_TAB;
        //SDLKeyboard[EKeyboard.K_ALT] = SDL_Scancode.SDL_SCANCODE_ALTERASE;
        SDLKeyboard[EKeyboard.K_ESCAPE] = SDL_Scancode.SDL_SCANCODE_ESCAPE;
        SDLKeyboard[EKeyboard.K_BACKSPACE] = SDL_Scancode.SDL_SCANCODE_BACKSPACE;
        SDLKeyboard[EKeyboard.K_BACKSLASH] = SDL_Scancode.SDL_SCANCODE_BACKSLASH;
        SDLKeyboard[EKeyboard.K_MINUS] = SDL_Scancode.SDL_SCANCODE_MINUS;

        SDLKeyboard[EKeyboard.K_UP] = SDL_Scancode.SDL_SCANCODE_UP;
        SDLKeyboard[EKeyboard.K_DOWN] = SDL_Scancode.SDL_SCANCODE_DOWN;
        SDLKeyboard[EKeyboard.K_LEFT] = SDL_Scancode.SDL_SCANCODE_LEFT;
        SDLKeyboard[EKeyboard.K_RIGHT] = SDL_Scancode.SDL_SCANCODE_RIGHT;

        //Keypad
        SDLKeyboard[EKeyboard.K_KP_0] = SDL_Scancode.SDL_SCANCODE_KP_0;
        SDLKeyboard[EKeyboard.K_KP_1] = SDL_Scancode.SDL_SCANCODE_KP_1;
        SDLKeyboard[EKeyboard.K_KP_2] = SDL_Scancode.SDL_SCANCODE_KP_2;
        SDLKeyboard[EKeyboard.K_KP_3] = SDL_Scancode.SDL_SCANCODE_KP_3;
        SDLKeyboard[EKeyboard.K_KP_4] = SDL_Scancode.SDL_SCANCODE_KP_4;
        SDLKeyboard[EKeyboard.K_KP_5] = SDL_Scancode.SDL_SCANCODE_KP_5;
        SDLKeyboard[EKeyboard.K_KP_6] = SDL_Scancode.SDL_SCANCODE_KP_6;
        SDLKeyboard[EKeyboard.K_KP_7] = SDL_Scancode.SDL_SCANCODE_KP_7;
        SDLKeyboard[EKeyboard.K_KP_8] = SDL_Scancode.SDL_SCANCODE_KP_8;
        SDLKeyboard[EKeyboard.K_KP_9] = SDL_Scancode.SDL_SCANCODE_KP_9;
        SDLKeyboard[EKeyboard.K_KP_ADD] = SDL_Scancode.SDL_SCANCODE_KP_PLUS;
        SDLKeyboard[EKeyboard.K_KP_SUBTRACT] = SDL_Scancode.SDL_SCANCODE_KP_MINUS;

        foreach ( key, val; SDLKeyboard ) {
            engineKeyboard[val] = key;
        }
    }

    override void update( float delta ) {
        void processMods( ref SInputModKeys process, Uint32 mod ) {
            process = SInputModKeys( 
                cast( bool )( mod & SDL_Keymod.KMOD_SHIFT ),
                cast( bool )( mod & SDL_Keymod.KMOD_CTRL ),
                cast( bool )( mod & SDL_Keymod.KMOD_ALT ),
                cast( bool )( mod & SDL_Keymod.KMOD_GUI ) 
            );
        }

        SDL_Event event;
        SDL_StartTextInput();
        while ( SDL_PollEvent( &event ) ) {
            SInputEvent inpEvent;

            if ( event.type == SDL_QUIT ) {
                getEngine().bWork = false;
            } else if ( event.type == SDL_WINDOWEVENT ) {
                switch ( event.window.event ) {
                    case SDL_WindowEventID.SDL_WINDOWEVENT_RESIZED:
                        getEngine().window.resize( event.window.data1, event.window.data2 );
                        break;

                    default:
                        break;
                }
            } else {
                switch ( event.type ) {
                    case SDL_EventType.SDL_TEXTINPUT:
                        inpEvent.type = EInputType.IT_TEXT;
                        inpEvent.text.character = event.text.text[0];
                        break;

                    case SDL_EventType.SDL_KEYDOWN:
                        inpEvent.type = EInputType.IT_KEY;
                        inpEvent.key.action = SInputEvent.EAction.A_DOWN;

                        if ( auto key = event.button.button in engineKeyboard ) {
                            inpEvent.key.key = *key;
                        } else {
                            inpEvent.key.key = EKeyboard.K_INVALID;
                        }

                        processMods( inpEvent.key.mods, event.key.keysym.mod );
                        break;

                    case SDL_EventType.SDL_KEYUP:
                        inpEvent.type = EInputType.IT_KEY;
                        inpEvent.key.action = SInputEvent.EAction.A_UP;

                        if ( auto key = event.button.button in engineKeyboard ) {
                            inpEvent.key.key = *key;
                        } else {
                            inpEvent.key.key = EKeyboard.K_INVALID;
                        }

                        processMods( inpEvent.key.mods, event.key.keysym.mod );
                        break;

                    case SDL_EventType.SDL_MOUSEBUTTONDOWN:
                        inpEvent.type = EInputType.IT_MOUSE_BUTTON;
                        if ( event.button.button == SDL_BUTTON_LEFT ) {
                            inpEvent.mButton.button = EMouseButton.MB_LEFT;
                            inpEvent.mButton.action = SInputEvent.EAction.A_DOWN;
                        } else {
                            inpEvent.mButton.button = EMouseButton.MB_RIGHT;
                            inpEvent.mButton.action = SInputEvent.EAction.A_DOWN;
                        }

                        processMods( inpEvent.key.mods, event.key.keysym.mod );
                        break;
                    
                    case SDL_EventType.SDL_MOUSEBUTTONUP:
                    inpEvent.type = EInputType.IT_MOUSE_BUTTON;
                        if ( event.button.button == SDL_BUTTON_LEFT ) {
                            inpEvent.mButton.button = EMouseButton.MB_LEFT;
                            inpEvent.mButton.action = SInputEvent.EAction.A_UP;
                        } else {
                            inpEvent.mButton.button = EMouseButton.MB_RIGHT;
                            inpEvent.mButton.action = SInputEvent.EAction.A_UP;
                        }

                        processMods( inpEvent.key.mods, event.key.keysym.mod );
                        break;

                    case SDL_EventType.SDL_MOUSEMOTION:
                        inpEvent.type = EInputType.IT_MOUSE_MOTION;
                        inpEvent.mMotion.pos = SVec2I( event.motion.x, event.motion.y );
                        break;

                    default:
                        break;
                }
            }

            getEngine().sceneTree.input( inpEvent );
        }
        SDL_StopTextInput();
    }

    override bool isKeyPressed( EKeyboard key ) {
        const Uint8* state = SDL_GetKeyboardState( null );
        return cast( bool )state[SDLKeyboard[key]];
    }
    
    override SVec2I mousePos() {
        int x;
        int y;
        SDL_GetMouseState( &x, &y );
        return SVec2I( x, y );
    }
}