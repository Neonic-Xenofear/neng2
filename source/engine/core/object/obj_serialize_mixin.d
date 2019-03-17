module engine.core.object.obj_serialize_mixin;

mixin template genObjectSerializeFunc( alias func, SerializeType, string serializeFuncName ) {
    private void iterateAllSerializables( T )( T val, ref SerializeType serializer ) {
        import engine.core.utils.uda : getUDA, hasUDA;

        foreach ( m; __traits( derivedMembers, T ) ) {
            enum isMemberVar = is( typeof(() {
                __traits( getMember, val, m ) = __traits( getMember, val, m ).init;
            }) );

            enum isMethod = is( typeof(() {
                __traits( getMember, val, m )();
            }) );

            enum isNonStatic = !is( typeof( &__traits( getMember, T, m ) ) );

            static if ( isMemberVar && isNonStatic && !isMethod ) {
                enum hasSerializeUDA = hasUDA!( __traits( getMember, T, m ), Serialize );
                enum noSerializeUDA = hasUDA!( __traits( getMember, T, m ), NoSerialize );

                static if ( hasSerializeUDA && !noSerializeUDA ) {
                    alias M = typeof( __traits( getMember, val, m ) );
                    
                    enum isClassOrStruct = ( is( M == class ) || is( M == struct ) );

                    //Process CLASS specific serialize logic
                    static if( isClassOrStruct ) {
                        enum classCustomSerialize = hasUDA!( M, CustomSerializer );
                        static if ( classCustomSerialize ) {
                            enum customSerializerUDA = getUDA!( M, CustomSerializer );
                            enum customSerializerTypeName = customSerializerUDA.serializerTypeName;
                            func!( T, M )( 
                                m,
                                __traits( getMember, val, m ), 
                                serializer, 
                                &__traits( getMember, mixin( customSerializerTypeName ), serializeFuncName ) 
                            );
                        } else {//TODO: replace with more elegant realize
                            //Process MEMBER specific serialize logic
                            enum hasCustomSerializerUDA = hasUDA!( __traits( getMember, T, m ), CustomSerializer );

                            static if ( !hasCustomSerializerUDA ) {
                                func!( T, M )( m, __traits( getMember, val, m ), serializer );
                            } else {
                                enum customSerializerUDA = getUDA!( __traits( getMember, T, m ), CustomSerializer );
                                enum customSerializerTypeName = customSerializerUDA.serializerTypeName;
                                func!( T, M )( 
                                    m,
                                    __traits( getMember, val, m ), 
                                    serializer, 
                                    &__traits( getMember, mixin( customSerializerTypeName ), serializeFuncName ) 
                                );
                            }
                        }
                    } else {
                        //Process MEMBER specific serialize logic
                        enum hasCustomSerializerUDA = hasUDA!( __traits( getMember, T, m ), CustomSerializer );

                        static if ( !hasCustomSerializerUDA ) {
                            func!( T, M )( m, __traits( getMember, val, m ), serializer );
                        } else {
                            enum customSerializerUDA = getUDA!( __traits( getMember, T, m ), CustomSerializer );
                            enum customSerializerTypeName = customSerializerUDA.serializerTypeName;
                            func!( T, M )( 
                                m,
                                __traits( getMember, val, m ), 
                                serializer, 
                                &__traits( getMember, mixin( customSerializerTypeName ), serializeFuncName ) 
                            );
                        }
                    }
                }
            }
        }

        
    }
}