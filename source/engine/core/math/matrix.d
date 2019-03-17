module engine.core.math.matrix;

import std.math,
    std.typetuple,
    std.traits,
    std.string,
    std.typecons,
    std.conv,
    std.meta;

import engine.core.math.vec;

template TupleRange(int from, int to) if (from <= to) {
    static if (from >= to) {
        alias TupleRange = TypeTuple!();
    } else {
        alias TupleRange = TypeTuple!(from, TupleRange!(from + 1, to));
    }
}

/**
    Generic non-resizable matrix
    Params:
        T - type of elemtns
        rows - number of rows
        columns - number of columns
*/
struct SMatrix( T, int rowsNum, int columnsNum ) if ( rowsNum >= 1 && columnsNum >= 1 ) {
    alias _T = T;
    static const int rowsN = rowsNum;
    static const int columnsN = columnsNum;
    
    alias SVec!( T, columnsNum ) TRow;
    alias SVec!( T, rowsNum ) TColumn;

    enum bool isSquared = ( rowsNum == columnsNum );
    
    T[columnsNum][rowsNum] matrix;
    alias matrix this;

    @nogc
    auto opBinary( string op, U )( U x ) pure const nothrow
    if ( U.rowsN == columnsN && op == "*" ) {
        SMatrix!( T, rowsN, columnsN ) res = void;
        for ( int i = 0; i < rowsN; i++ ) {
            for ( int j = 0; j < columnsN; j++ ) {
                T sum = 0;
                for ( int k = 0; k < columnsN; k++ ) {
                    sum += matrix[i][k] * x[k][j];
                }

                res[i][j] = sum;
            }
        }

        return res;
    }

    @property
    auto ptr() const {
        return matrix[0].ptr;
    }

    void clear( T value ) {
        foreach( r; TupleRange!( 0, rowsNum ) ) {
            foreach ( c; TupleRange!( 0, columnsNum ) ) {
                matrix[r][c] = value;
            }
        }
    }

    /**
        Convert elements to string
    */
    string toString() const nothrow {
        try {
            return format( "%s", matrix );
        } catch ( Exception ex ) {
            assert( false );
        }
    }

    /**
        Construct an identityt matrix
        Note: the identity matrix, while only meaningful for square matrices,
        is also defined for non-square ones.
    */
    @nogc
    static SMatrix identity() pure nothrow {
        SMatrix ret;
        ret.clear( 0 );
        /*for ( int i = 0; i < rowsNum; i++ ) {
            for ( int j = 0; j < columnsNum; j++ ) {
                res.matrix[i][j] = ( i == j ) ? 1 : 0;
            }
        }*/

        foreach(r; TupleRange!(0, rowsNum)) {
            ret.matrix[r][r] = 1;
        }

        return ret;
    }

    static if ( isSquared && ( rowsNum == 3 || rowsNum == 4 ) ) {
        @nogc
        static SMatrix rotatedAxis( int i, int j )( float angle ) pure nothrow {
            SMatrix res = identity();
            const float cosa = cos( angle );
            const float sina = sin( angle );

            res.matrix[i][i] = cast( T )cosa;
            res.matrix[i][j] = cast( T )-sina;
            res.matrix[j][i] = cast( T )sina;
            res.matrix[j][j] = cast( T )cosa;

            return res;
        }

        //Rotated along X axis
        alias rotatedAxis!( 1, 2 ) rotatedX;

        //Rotated along Y axis
        alias rotatedAxis!( 2, 0 ) rotatedY;

        //Rotated along Z axis
        alias rotatedAxis!( 1, 0 ) rotatedZ;

        @nogc
        SMatrix rotateAxis( int i, int j )( float angle ) pure nothrow {
            SMatrix res = rotatedAxis!( i, j )( angle );
            this = res * this;
            return this;
        }

        //Rotate along X axis
        alias rotateAxis!( 1, 2 ) rotateX;

        //Rotate along Y axis
        alias rotateAxis!( 2, 0 ) rotateY;

        //Rotate along Z axis
        alias rotateAxis!( 1, 0 ) rotateZ;

        @nogc
        static SMatrix rotate( float iAngle, SVec3F axis ) pure nothrow {
            float angle = iAngle * ( PI / 180 );
            SMatrix ret = void;
            const float cosa = cos( angle );
            const float sina = sin( angle );
            const oneMinCos = 1 - cosa;

            axis.normalize();
            float x = axis.x;
            float y = axis.y;
            float z = axis.z;

            float xy = x * y;
            float yz = y * z;
            float xz = x * z;

            ret.matrix[0][0] = cast( T )( x * x * oneMinCos + cosa );
            ret.matrix[0][1] = cast( T )( x * y * oneMinCos - z * sina );
            ret.matrix[0][2] = cast( T )( x * z * oneMinCos + y * sina );

            ret.matrix[1][0] = cast( T )( y * x * oneMinCos + z * sina );
            ret.matrix[1][1] = cast( T )( y * y * oneMinCos + cosa );
            ret.matrix[1][2] = cast( T )( y * z * oneMinCos - x * sina );

            ret.matrix[2][0] = cast( T )( z * x * oneMinCos - y * sina );
            ret.matrix[2][1] = cast( T )( z * y * oneMinCos + x * sina );
            ret.matrix[2][2] = cast( T )( z * z * oneMinCos + cosa );

            return ret;
        }

        SMatrix translated( SVec3!T vec ) {
            SMatrix ret = identity();

            ret.matrix[0][columnsNum - 1] = vec.x;
            ret.matrix[1][columnsNum - 1] = vec.y;
            ret.matrix[2][columnsNum - 1] = vec.z;

            return ret;
        }

        SMatrix translate( SVec3!T vec ) {
            this = translated( vec ) * this;
            return this;
        }

        static SMatrix scaling( SVec3!T vec ) {
            SMatrix ret = SMatrix.identity();

            ret[0][0] = vec.x;
            ret[1][1] = vec.y;
            ret[2][2] = vec.z;

            return ret;
        }

        SMatrix scale( SVec3!T vec ) {
            this = SMatrix.scaling( vec ) * this;
            return this;
        }
    }

    static if ( isSquared && rowsN > 3 ) {
        static SMatrix ortho( T left, T right, T bottom, T top, T near, T far ) 
        in {
            assert( right - left != 0 );
            assert( top - bottom != 0 );
            assert( far - near != 0 );
        } do {
            SMatrix ret;
            ret.clear( 0 );

            ret[0][0] = 2 / ( right - left );
            ret[0][3] = -( right + left ) / ( right - left );
            ret[1][1] = 2 / ( top - bottom );
            ret[1][3] = -( top + bottom ) / ( top- bottom );
            ret[2][2] = -2 / ( far - near );
            ret[2][3] = -( far + near ) / ( far - near );
            ret[3][3] = 1;

            return ret;
        }
    }
}

template SMat2x2( T ) {
    alias SMatrix!( T, 2, 2 ) SMat2x2;
}

template SMat3x3( T ) {
    alias SMatrix!( T, 3, 3 ) SMat3x3;
}

template SMat4x4( T ) {
    alias SMatrix!( T, 4, 4 ) SMat4x4;
}

alias SMat2 = SMat2x2;
alias SMat3 = SMat3x3;
alias SMat4 = SMat4x4;

alias SMat2B = SMat2!byte;
alias SMat2S = SMat2!short;
alias SMat2I = SMat2!int;
alias SMat2L = SMat2!long;
alias SMat2F = SMat2!float;
alias SMat2D = SMat2!double;

alias SMat3B = SMat3!byte;
alias SMat3S = SMat3!short;
alias SMat3I = SMat3!int;
alias SMat3L = SMat3!long;
alias SMat3F = SMat3!float;
alias SMat3D = SMat3!double;

alias SMat4B = SMat4!byte;
alias SMat4S = SMat4!short;
alias SMat4I = SMat4!int;
alias SMat4L = SMat4!long;
alias SMat4F = SMat4!float;
alias SMat4D = SMat4!double;
