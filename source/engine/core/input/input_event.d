module engine.core.input.input_event;

public import engine.core.input.input_type;
public import engine.core.input.mod_keys;
public import engine.core.input.keyboard;
public import engine.core.input.mouse;

struct SInputEvent {
    enum EAction {
        A_DOWN,
        A_UP,
        A_REPEATE,
    }

    struct SKeyEvent {
        EKeyboard key;
        EAction action = EAction.A_UP;
        SInputModKeys mods;

        @property
        bool isDown() const {
            return action == EAction.A_DOWN;
        }

        @property
        bool isUp() const {
            return !isDown();
        }
    }

    struct STextEvent {
        dchar character;
        SInputModKeys mods;
    }

    struct SMouseButtonEvent {
        EMouseButton button;
        EAction action = EAction.A_UP;
        SInputModKeys mods;

        @property
        bool isDown() const {
            return action == EAction.A_DOWN;
        }

        @property
        bool isUp() const {
            return !isDown();
        }
    }

    struct SMouseMotionEvent {
        import engine.core.math.vec : SVec2I;
        SVec2I pos;
    }

    EInputType type;
    SKeyEvent key;
    SMouseButtonEvent mButton;
    SMouseMotionEvent mMotion;
    STextEvent text;
}