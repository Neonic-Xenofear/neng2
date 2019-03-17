module engine.core.object.object;

import std.uuid;

import engine.core.serialize;
import engine.core.object.obj_serialize_mixin;
import engine.core.object.obj_serialize;

static struct SSerializeUUID {
    import sdlang;

private:
    static void serialize( ref UUID v, ref SSerializer serializer, Tag parent ) {
        serializer.serializeMember( v.toString(), parent );
    }

    static void deserialize( ref UUID v, ref SDeserializer serializer, Tag parent ) {
        string uuidStr;
        serializer.deserializeMember(uuidStr, parent);
        v = UUID( uuidStr );
    }
}

template TRegisterObject() {
    enum TRegisterObject = 
        TObjectSerialize!()
        ~ q{
            @property
            override string typename() {
                return typeof( this ).stringof;
            }
        };
}

abstract class AObject {
protected:
    @Serialize
    @CustomSerializer( "SSerializeUUID" )
    UUID instId;

public:

    this() {
        genNewInstanceId();
    }

    UUID instanceId() const {
        return instId;
    }

    void genNewInstanceId() {
        instId = randomUUID();
    }

    void serialize( ref SSerializer serializer ) {
        iterateAllSerializables!AObject( this, serializer );
    }

    void deserialize( ref SDeserializer deserializer, string uid = null ) {
        if ( uid != null ) {
            instId = UUID( uid );
        }

        iterateAllSerializables!AObject( this, deserializer );
    }

    @property
    string typename() {
        return typeof( this ).stringof;
    }

private:
    mixin genObjectSerializeFunc!( serializeMember, SSerializer, "serialize" );
    mixin genObjectSerializeFunc!( deserializeMember, SDeserializer, "deserialize" );

    void serializeMember( T, M )( string m, ref M member, ref SSerializer serializer, TCustomSerializeFunc!M func = null ) {
        serializer.serializeObjectMember!( T, M )( this, m, member, func );
    }

    void deserializeMember( T, M )( string m, ref M member, ref SDeserializer deserializer, TCustomDeserializeFunc!M customFunc = null ) {
        string uid = null;

        if ( instId != UUID.init ) {
            uid = instId.toString();
        }

        deserializer.deserializeObjectMember!( T, M )( this, uid, m, member, customFunc );
    }
}