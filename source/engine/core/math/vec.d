module engine.core.math.vec;

import std.traits : isNumeric;
private import std.math;
private import std.traits;

import engine.core.utils.compile_templ;
import engine.core.serialize.attribute;

enum VECTOR_ELEMENTS_NAMES = ["x", "y", "z", "w"];

struct SVec( T, int size )
    if ( size > 1 && isNumeric!T ) 
{
private:
    alias _T = T;
    enum _size = size;

    template isConvertible( T ) {
         enum bool isConvertible = ( !is( T : SVec ) )
            && is( typeof( {
                    T x;
                    SVec v = x;
            }() ) );
    }
public:
    union {
        @NoSerialize
        T[size] data;
        
        static if( size < 5 ) {
            struct { mixin( elementsGen( VECTOR_ELEMENTS_NAMES, 'T', size ) ); }
        }
    }


    this( T[] array ) {
        if ( array.length >= size ) {
            foreach ( i; 0..size ) {
                data[i] = cast( T )array[i];
            }
        } else {
            foreach ( i; 0..array.length ) {
                data[i] = cast( T )array[i];
            }
        }
    }

    @nogc
    this( Args... )( Args args ) pure nothrow {
        static if ( args.length == 1 ) {
            // Construct a Vector from a single value.
            opAssign!( Args[0] )( args[0] );
        } else {
            // validate the total argument count across scalars and vectors
            template argCount(T...) {
                static if(T.length == 0)
                    enum argCount = 0; // done recursing
                else static if(isVector!(T[0]))
                    enum argCount = T[0]._N + argCount!( T[1..$] );
                else
                    enum argCount = 1 + argCount!( T[1..$] );
            }

            static assert( argCount!Args <= size, "Too many arguments in vector constructor" );

            int index = 0;
            foreach( arg; args ) {
                static if ( isAssignable!( T, typeof( arg ) ) ) {
                    data[index] = arg;
                    index++; // has to be on its own line (DMD 2.068)
                } else static if ( isVector!( typeof( arg ) ) && isAssignable!( T, arg._T ) ) {
                    mixin( generateLoopCode!( "data[index + @] = arg[@];", arg._size )() );
                    index += arg._size;
                } else {
                    static assert( false, "Unrecognized argument in Vector constructor" );
                }
            }
            assert( index == size, "Bad arguments in Vector constructor" );
        }
    }

    @nogc
    bool opEquals( U )( U other ) pure const nothrow
    if ( is( U : SVec ) ) 
    {
        for ( int i = 0; i < size; ++i ) {
            if ( data[i] != other.data[i] ) {
                return false;
            }
        }
        return true;
    }

    @nogc
    bool opEquals( U )( U other ) pure const nothrow
    if ( isConvertible!U ) {

        SVec conv = other;
        return opEquals( conv );
    }

    @nogc
    ref SVec opAssign( U )( U x ) pure nothrow 
    if ( isAssignable!( T, U ) ) {

        mixin( generateLoopCode!( "data[@] = x;", size )()); // copy to each component
        return this;
    }

    @nogc
    ref SVec opAssign( U )( U vec ) pure nothrow 
    if ( isVector!U ) {

        data[] = vec.data[];
        return this;
    }

    @nogc
    ref SVec opAssign( U )( U vec ) pure nothrow 
    if ( isVector!U && 
         isAssignable!( T, U._T ))// && 
         //( _size == U._size ) )
    {
        mixin( generateLoopCode!( "data[@] = vec.data[@];", size )() );
        return this;
    }

    @nogc
    SVec opUnary( string op )() pure const nothrow
    if ( op == "+" || op == "-" || op == "~" || op == "!" ) {
        
        SVec res = void;
        mixin( generateLoopCode!( "res.data[@] = " ~ op ~ " data[@];", size )() );
        return res;
    }

    @nogc
    ref SVec opOpAssign( string op, U )( U operand ) pure nothrow
    if ( is( U : SVec ) ) {

        mixin( generateLoopCode!( "data[@] " ~ op ~ "= operand.data[@];", size )() );
        return this;
    }

    @nogc
    ref SVec opOpAssign(string op, U)(U operand) pure nothrow 
    if ( isConvertible!U ) {
        SVec conv = operand;
        return opOpAssign!op( conv );
    }

    @nogc
    SVec opBinary( string op, U )( U operand ) pure const nothrow
    if ( is( U: SVec ) || ( isConvertible!U ) ) {

        SVec result = void;
        static if ( is( U: T ) ) {
            mixin( generateLoopCode!( "result.data[@] = cast( T )( data[@] " ~ op ~ " operand );", size )());
        } else {
            SVec other = operand;
            mixin( generateLoopCode!( "result.data[@] = cast( T )( data[@] " ~ op ~ " other.data[@] );", size )() );
        }

        return result;
    }

    @nogc
    SVec opBinaryRight( string op, U)( U operand ) pure const nothrow 
    if ( isConvertible!U ) {
        SVec result = void;
        static if ( is ( U: T ) ) {
            mixin( generateLoopCode!( "result.data[@] = cast( T )( operand " ~ op ~ " data[@] );", size )() );
        } else {
            SVec other = operand;
            mixin( generateLoopCode!( "result.data[@] = cast( T )( other.data[@] " ~ op ~ " data[@]);", size )() );
        }
        return result;
    }

    @nogc
    U opCast( U )() pure const nothrow
    if ( isVector!U && ( U._size == size ) ) {
        U res = void;
        mixin( generateLoopCode!( "res.data[@] = cast( U._T )data[@];", size )() );
        return res;
    }

    @property
    T length() const {
        return cast( T )sqrt( cast( float )lengthSqrt() );
    }

    @property
    T lengthSqrt() const {
        T val = 0;
        foreach ( i; 0..size ) {
            val += data[i] * data[i];
        }

        return val;
    }

    @nogc
    T distranceTo( SVec otherVec ) pure const nothrow {
        return ( this - otherVec ).length;
    }

    @nogc
    T squaredMagnitude() pure const nothrow {
        T sum = 0;
        mixin( generateLoopCode!( "sum += data[@] + data[@];", size )() );
        return sum;
    }

    @nogc
    T inverseMagnitude() pure const nothrow {
        return cast( T )( 1.0F / sqrt( cast( double )squaredMagnitude() ) );
    }

    /**
        In-place normalize
    */
    @nogc
    void normalize() pure nothrow {
        auto invMagn = inverseMagnitude();
        mixin( generateLoopCode!( "data[@] *= invMagn;", size )() );
    }

    /**
        Returns a normalized copy of this Vector
    */
    @nogc
    SVec normalized() pure const nothrow {
        SVec ret = this;
        ret.normalize();
        return ret;
    }

    string toString() {
        import std.conv : to;

        string resStr;
        
        for ( int i = 0; i < data.length; i++ ) {
            if ( i < VECTOR_ELEMENTS_NAMES.length ) {
                if ( i != 0 ) {
                    resStr ~= "; ";
                }

                resStr ~= VECTOR_ELEMENTS_NAMES[i] ~": " ~ to!string( data[i] );
            }
        }

        return resStr;
    }
}

@nogc
SVec2F cross2D( const SVec2F vec, float val ) pure nothrow {
    return SVec2F( val * vec.y, -val * vec.x );
}

@nogc
SVec!( T, 2 ) normal2D( T )( const SVec!( T, 2 ) vec ) pure nothrow {
    return SVec!( T, 2 )( -vec.y, vec.x );
}

@nogc
T dot( T, int size )( const SVec!( T, size ) a, const SVec!( T, size ) b ) pure nothrow {
    T sum = 0;
    mixin( generateLoopCode!( "sum += a.data[@] * b.data[@];", size )() );
    return sum;
}

@nogc
SVec!( T, size ) projection( T, int size )( const SVec!( T, size ) a, const SVec!( T, size ) b ) pure nothrow {
    return b * ( a.dot( b ) / b.squaredMagnitude() );
}

SVec2F rotate( SVec2F vec, float angle ) {
    float theta = angle * ( PI / 180 );
    float cosa = cos( angle );
    float sina = sin( angle ); 

    SVec2F ret;
    ret.x = vec.x * cosa - vec.y * sina;
    ret.y = vec.y * sina - vec.y * cosa;

    return ret;
}

@nogc
float cross2D( SVec2F vec1, SVec2F vec2 ) pure nothrow {
    return vec1.x * vec2.y - vec1.y * vec2.x;
}

/// True if `T` is some kind of `SVec`
enum isVector( T ) = is( T : SVec!U, U... );

template SVec2( T ) {
    alias SVec2 = SVec!( T, 2 );
}

template SVec3( T ) {
    alias SVec3 = SVec!( T, 3 );
}

template SVec4( T ) {
    alias SVec4 = SVec!( T, 4 );
}

alias SVec2I = SVec2!( int );
alias SVec2U = SVec2!( uint );
alias SVec2D = SVec2!( double );
alias SVec2L = SVec2!( long );
alias SVec2F = SVec2!( float );

alias SVec3I = SVec3!( int );
alias SVec3U = SVec3!( uint );
alias SVec3D = SVec3!( double );
alias SVec3L = SVec3!( long );
alias SVec3F = SVec3!( float );

alias SVec4I = SVec4!( int );
alias SVec4U = SVec4!( uint );
alias SVec4D = SVec4!( double );
alias SVec4L = SVec4!( long );
alias SVec4F = SVec4!( float );