module engine.core.utils.envelope;

struct SEnvelope( T ) if ( is( T == class ) || is( T == interface ) ) {
protected:
    shared( T )[] obj;

public:
    this( T o ) {
        this.obj = cast( shared )[o];
    }

    T get() @property nothrow @nogc {
        return cast()obj[0];
    }
}