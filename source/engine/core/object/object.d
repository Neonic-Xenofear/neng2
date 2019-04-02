module engine.core.object.object;

import std.uuid;

import engine.core.utils.singleton;
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

/**
    Used to lock object
*/
struct SObjectLock {
    UUID id;

    void setupID() {
        id = randomUUID();
    }

    @disable this( this );
}

/**
    Lock given object and unlock by exit scope
    Params:
        T - object var
*/
template TLockObject( alias T ) {
    import std.string : format;

    enum TLockObject = 
    format( 
        q{
            //assert( !(%1$s).isLocked(), "Trying to process locked object" );
            SObjectLock lock;
            (%1$s).lock( lock );
            scope( exit ) {
                (%1$s).unlock( lock );
            }
        },
        __traits( identifier, T )
    );
}

/**
    Basic engine object

    Instead of "destroy", use "queueFree"
    Example: {
        ...
        resource.destroy(); //Invalid, resource can be locked
        resource.queueFree(); //Correct, resource will be destroyed at the end of frame
        ...
    }
*/
abstract class AObject {
protected:
    @Serialize
    @CustomSerializer( "SSerializeUUID" )
    UUID instId;

    SObjectLock locker;

public:
    this() {
        genNewInstanceId();
    }

    ~this() {
        import engine.app.logger : log;
        assert( locker.id.empty(), "Delete object while it locked. Perhaps you used \"destroy\" instead \"queueFree\"?" );
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

    /**
        Allow resource delete
    */
    void lock( ref SObjectLock lock ) {
        assert( locker.id.empty(), "Trying to lock already locked resource" );
        lock.setupID();
        locker.id = lock.id;
    }

    /**
        Block resource delete
    */
    void unlock( ref SObjectLock lock ) {
        assert( lock.id == locker.id, "Invalid resource locker" );
        locker.destroy();
    }

    bool isLocked() {
        return locker.id.empty();
    }

    @property
    string typename() {
        return typeof( this ).stringof;
    }

    /**
        Override for custrom logic
    */
    bool canBeAddedToQueueFree() {
        return true;
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

/**
    Objects free queue
*/
class CObjectsQueueFree : ASingleton!CObjectsQueueFree {
protected:
    AObject[] queue;

public:
    ~this() {
        foreach ( AObject obj; queue ) {
            obj.destroy();
        }
    }

    void addObjectToQueue( AObject obj ) {
        import std.algorithm : canFind;
        
        if ( !queue.canFind( obj ) && obj.canBeAddedToQueueFree() ) {
            queue ~= obj;
        }
    }

    void processQueue() {
        import engine.core.utils.array : removeElement;

        foreach ( AObject obj; queue ) {
            if ( !obj.isLocked() ) {
                queue.removeElement( obj );
                obj.destroy();
            }
        }
    }
}

void queueFree( AObject obj ) {
    if ( obj ) {
        CObjectsQueueFree.get().addObjectToQueue( obj );
    }
}