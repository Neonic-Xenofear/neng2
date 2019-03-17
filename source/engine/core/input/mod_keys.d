module engine.core.input.mod_keys;

struct SInputModKeys {
private:
    bool bShift = false;
    bool bControl = false;
    bool bAlt = false;
    bool bSuper = false; //Win on windows

public:
    @property
    bool isShift() const {
        return bShift;
    }

    @property
    bool isControl() const {
        return bControl;
    }

    @property
    bool isAlt() const {
        return bAlt;
    }

    @property
    bool isSuper() const {
        return bSuper;
    }
}