module engine.core.multithreading.fiber;

public import core.thread : Fiber;

public import engine.app.logger;

alias TFiberFunc = void function();
alias TFiberDelegate = void delegate();

final class CFiber : Fiber {
private:
    Fiber child;

public:
    this( T )( T func )
    if ( is( T == TFiberFunc ) || is( T == TFiberDelegate ) ) {
        super( func );
        initParent();
    }

    void reset( T )( T func )
    if ( is( T == TFiberFunc ) || is( T == TFiberDelegate ) ) {
        super.reset( func );
        initParent();
    }

    void safeCall() {
        if ( auto e = call( Fiber.Rethrow.no ) ) {
            log.error( "Fiber error: " ~ e.toString() );
        }
    }

private:
    void initParent() {
        if ( CFiber parent = cast( CFiber )Fiber.getThis() ) {
            assert( parent.child is null );
            parent.child = this;
        }
    }
}