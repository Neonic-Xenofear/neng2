module engine.core.serialize.serializer;

import sdlang;

import std.uuid;
import std.traits : isPointer, Unqual, BaseClassesTuple;

import engine.core.object;
import engine.core.utils.uda;
import engine.core.serialize.attribute;
import engine.core.serialize.attribute;

import engine.scene.base;
import engine.core.resource.base;

alias TCustomSerializeFunc( T ) = void function( ref T, ref SSerializer, Tag );

struct SSerializer {
    Tag root;

    UUID[] blacklist;

    mixin genSerializeFunc!serializeMemberWithName;
    
    void serializeObjectMember( T, M )( T obj, string name, ref M member, TCustomSerializeFunc!M func = null )
    if ( is( T : AObject ) ) {
        if ( !root ) {
            root = new Tag();
            root.name = "root";
        }

        serializeTo!( T, M )( obj, name, member, root, func );
    }

    bool isBlacklisted( in UUID id ) {
        import std.algorithm : countUntil;
        return blacklist.countUntil( id ) != -1;
    }

    void serializeMember( T )( T val, Tag parent )
    if ( is( T : AObject ) ) {
        if ( val is null ) {
            return;
        }

        if ( isBlacklisted( val.instanceId ) ) {
            parent.remove();
            return;
        }

        string id = val.instanceId.toString();

        if ( !getInstanceId( id ) ) {
            val.serialize( this );
        }

        parent.add( Value( id ) );
        parent.add( new Attribute( "type", Value( typeid( val ).toString() ) ) ); 
    }

    static void serializeMember( T )( in ref T val, Tag parent )
    if ( is( T == enum ) ) {
        parent.add( Value( cast( int )val ) );
    }

    void serializeMember( T )( T val, Tag parent )
    if ( is( T == struct ) ) {
        iterateAllSerializables!T( val, parent );
    }

    void serializeMember( T )( T val, Tag parent ) 
    if ( isSerializerBaseType!T && !is( T == enum ) && !__traits( isStaticArray, T ) ) {
        static if ( isExactSerializerBaseType!T ) {
            parent.add( Value( val ) );
        } else {
            import std.conv : to;
            parent.add( Value( to!string( val ) ) );
        }
    }

    void serializeMember( T )( T val, Tag parent )
    if ( __traits( isStaticArray, T ) ) {
        foreach ( v; val ) {
            Tag t = new Tag( parent );
            serializeMember( v, t );
        }
    }

    void serializeMember( T )( T[] val, Tag parent )
    if ( ( isSerializerBaseType!T && !is( T : char ) ) ||
    is ( T : CNode ) ) {
        foreach ( v; val ) {
            Tag t = new Tag( parent );
            serializeMember( v, t );
        }
    }

    string toString() {
        auto r = new Tag();
        r.add( root );
        return r.toSDLDocument();
    }

private:
    Tag getInstanceId( string id ) {
        foreach ( o; root.all.tags ) {
            auto attr = o.attributes["id"][0];
            if ( attr.value.get!string == id ) {
                return o;
            }
        }

        return null;
    }

    Tag getTag( string id, string type, Tag parent ) {
        Tag idTag = getInstanceId( id );

        if ( idTag is null ) {
            idTag = new Tag( parent );
            idTag.name = "object";
            idTag.add( new Attribute( "id", Value( id ) ) );
        }

        Tag typeTag;

        if ( !( type in idTag.all.tags ) ) {
            typeTag = new Tag( idTag );
            typeTag.name = type;
        } else {
            typeTag = idTag.all.tags[type][0];
        }

        return typeTag;
    }

    void serializeMemberWithName( T )( T val, Tag tag, string memName ) {
        Tag memberTag = new Tag( tag );
        memberTag.name = memName;

        serializeMember( val, memberTag );
    }

    void serializeTo( T, M )( T val, string name, ref M member, Tag parent, TCustomSerializeFunc!M func = null ) {
        auto compTag = getTag( val.instanceId.toString(), Unqual!( T ).stringof, parent );

        if ( name in compTag.all.tags ) {
            return;
        }

        Tag memTag = new Tag( compTag );
        memTag.name = name;

        if ( func ) {
            func( member, this, memTag );
        } else {
            static if ( __traits( compiles, mixin( "{ serializeMember( member, memTag );  }" ) ) ) {
                serializeMember( member, memTag );
            } else {
                //Strange, but work way for template class || struct
                serializeMember( member.serializeToString(), memTag );
            }
        }
    }
}