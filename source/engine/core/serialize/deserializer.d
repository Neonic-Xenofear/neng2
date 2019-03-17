module engine.core.serialize.deserializer;

import sdlang;

import std.string : format;
import std.traits : isPointer, Unqual, BaseClassesTuple;

import engine.core.object;
import engine.scene.base : CNode;
import engine.core.serialize.attribute;

alias TCustomDeserializeFunc( T ) = void function( ref T, ref SDeserializer, Tag );

struct SLoadedObject {
    AObject object;
    string id;
}

struct SDeserializer {
    Tag root;
    Tag content;
    SLoadedObject[] loadedObjects;

    this( string data ) {
        root = parseSource( data );
        content = root.all.tags["root"][0];
        assert( content !is null );
    }

    void deserializeObjectMember( T, M )( T obj, string uid, string memName, ref M member, TCustomDeserializeFunc!M customFunc = null )
    if ( is( T : AObject ) ) {
        if ( uid is null || uid.length == 0 ) {
            assert( false );
        } else {
            auto tag = findObject( uid );
            assert( tag, format( "Obj not found: '%s' (%s)", T.stringof, uid ) );

            if ( !findObject( uid ) ) {
                storeLoadedRef( obj, uid );
            }
            
            deserializeFromTag!( T, M )( obj, memName, member, tag, customFunc );
        }
    }

    T deserializeFirst( T )()
    if ( is( T : AObject ) ) {
        auto res = new T();
        storeLoadedRef( res, findFirstID );
        res.deserialize( this, findFirstID );
        return res;
    }

    void deserializeMember( T )( ref T val, Tag parent )
    if ( is( T : AObject ) ) {
        if ( parent.values.length == 0 ) {
            return;
        }

        assert( parent.values.length == 1, format( "[%s] wrong value count %s", T.stringof, parent.values.length ) );

        const uid = parent.values[0].get!string;
        assert( uid.length > 0 );

        auto r = findRef( uid );
        if ( r ) {
            val = cast( T )r;
            assert( val );
        } else {
            auto typename = parent.attributes["type"][0].value.get!string;
            val = cast( T )Object.factory( typename );
            assert( val, format( "Could not create: %s", typename ) );

            storeLoadedRef( val, uid );

            val.deserialize( this, uid );
        }
    }

    static void deserializeMember( T )( ref T val, Tag parent )
    if ( is( T == enum ) ) {
        val = cast( T )parent.values[0].get!int;
    }

    void deserializeMember( T )( ref T val, Tag parent )
    if ( __traits( isStaticArray, T ) ) {
        assert( parent.all.tags.length == T.length );
        size_t idx = 0;
        foreach ( tag; parent.all.tags ) {
            deserializeMember( val[idx++], tag );
        }
    }

    void deserializeMember( T )( ref T[] val, Tag parent )
    if ( ( isSerializerBaseType!T && !is( T : char ) ) ||
    is( T : CNode ) ) {
        val.length = parent.all.tags.length;
        size_t idx = 0;
        foreach ( tag; parent.all.tags ) {
            deserializeMember( val[idx++], tag );
        }
    }

    void deserializeMember( T )( ref T val, Tag parent )
    if ( is( T == struct ) ) {
        iterateAllSerializables( val, parent );
    }

    static void deserializeMember( T )( ref T val, Tag parent )
    if ( isSerializerBaseType!T && !is( T == enum ) && !__traits( isStaticArray, T ) ) {
        if ( parent.values.length > 0 ) {
            assert( 
                parent.values.length == 1, 
                format( "deserializeMember!(%s)('%s'): %s", T.stringof, parent.name, parent.values.length ) 
            );

            static if ( isExactSerializerBaseType!T ) {
                val = parent.values[0].get!T;
            } else {
                import std.conv : to;
                val = to!T( parent.values[0].get!string );
            }
        }
    }

    package AObject findRef( string uid ) {
        return findLoadedRef( uid );
    }

    AObject findLoadedRef( string uid ) {
        alias objArray = loadedObjects;

        foreach ( o; objArray ) {
            if ( o.id == uid ) {
                return o.object;
            }
        }

        return null;
    }

    void storeLoadedRef( AObject obj, string uid ) {
        assert( obj !is null );
        assert( !findRef( uid ) );

        loadedObjects ~= SLoadedObject( obj, uid );
    }

private:
    mixin genSerializeFunc!deserializeFromMemberName;

    string findFirstID() {
        auto contRoot = content.all.tags.front;
        return contRoot.attributes["id"][0].value.get!string;
    }

    void deserializeFromMemberName( T )( ref T val, Tag tag, string memName ) {
        auto memTag = tag.all.tags[memName][0];
        assert( memTag );

        deserializeMember( val, memTag );
    }

    void deserializeFromTag( T, M )( T obj, string memName, ref M member, Tag parent, TCustomDeserializeFunc!M customFunc = null ) {
        auto tags = parent.all.tags[Unqual!( T ).stringof];

        if ( tags.empty ) {
            return;
        }

        auto typeTag = tags[0];

        if ( !( memName in typeTag.all.tags ) ) {
            return;
        }

        auto memTag = typeTag.all.tags[memName];

        if ( memTag.empty ) {
            return;
        }

        if ( customFunc ) {
            customFunc( member, this, memTag[0] );
        } else {
            static if ( __traits( compiles, mixin( "{ deserializeMember( member, memTag[0] );  }" ) ) ) {
                deserializeMember( member, memTag[0] );
            } else {
                //Strange, but work way for template class || struct
                member.deserializeFromString( memTag[0].values[0].get!string );
            }
        }
    }

    Tag findObject( string objId ) {
        auto objs = content.all.tags["object"];
        foreach ( Tag o; objs ) {
            auto uid = o.attributes["id"];
            if ( !uid.empty && uid[0].value == objId ) {
                return o;
            }
        }

        return null;
    }
}