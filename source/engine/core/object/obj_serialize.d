module engine.core.object.obj_serialize;

template TObjectSerialize() {
    enum TObjectSerialize = q{
        import engine.core.object.obj_serialize_mixin;
        import engine.core.serialize;

        private {
            mixin genObjectSerializeFunc!( serializeMember, SSerializer, "serialize" );
            mixin genObjectSerializeFunc!( deserializeMember, SDeserializer, "deserialize" );

            void serializeMember( T, M )( string m, ref M member, ref SSerializer serializer, TCustomSerializeFunc!M customFunc = null ) {
                serializer.serializeObjectMember!( T, M )( this, m, member, customFunc );
            }

            void deserializeMember( T, M )( string m, ref M member, ref SDeserializer deserializer, TCustomDeserializeFunc!M customFunc = null ) {
                deserializer.deserializeObjectMember!( T, M )( this, this.instanceId.toString(), m, member, customFunc );
            }
        }

        public override void serialize( ref SSerializer serializer ) {
            alias T = typeof( this );

            iterateAllSerializables!T( this, serializer );
            super.serialize( serializer );
        }

        public override void deserialize( ref SDeserializer deserializer, string uid = null )  {
            super.deserialize( deserializer, uid );
            
            alias T = typeof( this );

            iterateAllSerializables!T( this, deserializer );
        }
    };
}