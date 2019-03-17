module engine.core.serialize.attribute;

struct Serialize {}
struct NoSerialize {}

struct CustomSerializer {
    string serializerTypeName;
}

enum isSerializerBaseType( T ) = 
    is( T : bool ) ||
    is( T : string ) ||
    is( T : dchar ) ||
    is( T : int ) ||
    is( T : long ) ||
    is( T : double ) ||
    is( T : real ) ||
    is( T : ubyte[] );

enum isExactSerializerBaseType(T) = 
    is( T == bool ) ||
    is( T == string ) ||
    is( T == dchar ) ||
    is( T == int ) ||
    is( T == long ) ||
    is( T == double ) ||
    is( T == real ) ||
    is( T == ubyte[] );

mixin template genSerializeFunc( alias func ) {
    void iterateAllSerializables( T )( ref T val, Tag tag ) {
        foreach ( m; __traits( derivedMembers, T ) ) {
            enum isMemberVar = is( typeof(() {
                __traits( getMember, val, m ) = __traits( getMember, val, m ).init;
            }) );

            enum isMethod = is( typeof(() {
                __traits( getMember, val, m )();
            }) );

            enum isNonStatic = !is( typeof( mixin( "&T." ~ m ) ) );

            static if ( isMemberVar && isNonStatic && !isMethod ) {
                import engine.core.utils.uda : hasUDA, getUDA;
                enum isPublic = __traits( getProtection, __traits( getMember, val, m ) ) == "public";
                enum hasSerializeUDA = hasUDA!( mixin( "T." ~ m ), Serialize );
                enum noSerializeUDA = hasUDA!( mixin( "T." ~ m ), NoSerialize );

                static if ( ( isPublic || hasSerializeUDA ) && !noSerializeUDA ) {
                    func( __traits( getMember, val, m ), tag, m );
                }
            }
        }
    }
}