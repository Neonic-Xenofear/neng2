module engine.core.multithreading.fiber_manager;

import engine.core.multithreading.fiber;

struct SFiberManager {
private:
    static CFiber[] fibers;

public:
    static void startFiber( T )( T func )
    if ( is( T == TFiberFunc ) || is( T == TFiberDelegate ) ) {
        TFiberDelegate del;
        if ( is ( T == TFiberFunc ) ) {
            import std.functional;
            del = func.toDelegate();
        } else {
            del = func;
        }

        CFiber nF = findFreeFiber();
        if ( nF ) {
            nF.reset( del );
        } else {
            nF = new CFiber( del );
            fibers ~= nF;
        }

        nF.safeCall();
    }

private:
    static CFiber findFreeFiber() {
        foreach ( f; fibers ) {
            if ( f.state == Fiber.State.TERM ) {
                return f;
            }
        }

        return null;
    }
}