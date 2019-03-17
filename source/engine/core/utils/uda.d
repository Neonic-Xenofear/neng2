module engine.core.utils.uda;

alias aliasHelper( alias T ) = T;
alias aliasHelper( T ) = T;

private template getUDAIndex( alias UDA, Attr... ) {
    template findUDA( int i ) {
        static if ( Attr.length == 0 ) {
            enum findUDA = -1;
        } else static if ( i >= Attr.length ) {
            enum findUDA = -1;
        } else {
            static if ( is( aliasHelper!( Attr[i] ) == UDA ) || is( typeof( Attr[i] ) == UDA ) ) {
                enum findUDA = i;
            } else {
                enum findUDA = findUDA!( i + 1 );
            }
        }
    }

    enum getUDAIndex = findUDA!( 0 );
}

template hasUDA( alias T, alias UDA ) {
    enum hasUDA = getUDAIndex!( UDA, __traits( getAttributes, T ) ) != -1;
}

template getUDA( alias T, alias UDA ) {
    template findUDA( ATTR... ) {
        static if( hasUDA!( T, UDA ) ) {
            enum findUDA = ATTR[getUDAIndex!( UDA, ATTR )];
        } else {
            import std.string:format;
            static assert( 0, format( "UDA '%s' not found for Type '%s'", UDA.stringof, T.stringof ) );
        }
    }
    enum getUDA = findUDA!( __traits( getAttributes, T ) );
}