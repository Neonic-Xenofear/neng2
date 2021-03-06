module engine.core.resource.base.resource;

import std.algorithm : canFind;
import std.uuid;

public import engine.core.vfs.vfs;
import engine.core.object;
import engine.core.serialize;
import engine.core.utils.array : removeElement;

/**
    Resource loading phase
*/
enum EResourceLoadPhase {
    RLP_NONE,       ///Nothing in process
    RLP_LOADING,    ///Resource loading
    RLP_FAILED,     ///Something get wrong
    RLP_SUCCES,     ///Resource loaded normal
}

/**
    How load resource
*/
enum EResourceLoadingType {
    RLT_STATIC,       ///Load in main thread
    RLT_ASYNC,        ///Load in separated thread
}

/**
    Register resource need code
*/
template TResourceRegister() {
    enum TResourceRegister = 
    TRegisterObject!() ~ q{

    import engine.core.utils.uda : getUDA, hasUDA;
    alias T = typeof( this );
    enum hasRegResUDA = hasUDA!( T, RegisterResource );
    enum hasResLoadTypeUDA = hasUDA!( T, ResourceLoadType );

    static assert( hasRegResUDA, "Resource dont have register UDA: " ~ T.stringof );
    static assert( hasResLoadTypeUDA, "Resource dont have loading type UDA: " ~ T.stringof );
    };
}

/**
    Used for associate resource 
    class with resource name
*/
struct RegisterResource {
    string resTypeName;
}

/**
    Used to declare resource loading type
*/
struct ResourceLoadType {
    EResourceLoadingType type;
}

alias TLockResource = TScopeLockObject;

/**
    Engine resource object, used for 
    all loadable files

    Register example: {
        ...
        @RegisterResource( "Texture" )
        class CTexture : AReource {
            mixin( TResourceRegister!() );
        ...
    }
*/
@RegisterResource( "Resource" )
@ResourceLoadType( EResourceLoadingType.RLT_STATIC )
abstract class AResource : AObject {
    mixin( TResourceRegister!() );
public:
    @Serialize {
        string path; ///Full resource path in VFS
    }

    EResourceLoadPhase loadPhase = EResourceLoadPhase.RLP_NONE; ///Loading phase, because loading process in fiber


protected:
    AObject[] owners;

public:
    ///
    this() {
        super();
    }

    ~this() {
        import engine.core.engine.engine : getResourceManager;
        import engine.core.utils.logger : log;

        if ( owners.length > 0 ) {
            log.warning( "Resource is still have owners!" );
        }
    }

    /**
        Add resource owner
        Params:
            own - new owner
    */
    void addOwner( AObject own ) {
        if ( !owners.canFind( own ) ) {
            owners ~= own;
            updateOwners();
        }
    }

    /**
        Remove resource owner and destroy 
        resource if owners.length < 1
        Params:
            own - owner to remove
    */
    void removeOwner( AObject own ) {
        import engine.core.engine.engine : getResourceManager;

        if ( !own ) {
            return;
        }

        if ( owners.canFind( own ) ) {
            owners.removeElement( own );
            updateOwners();

            if ( owners.length < 1 ) {
                getResourceManager().removeResource( this );
                this.queueFree();
            }
        }
    }

    /**
        Returns is resource valid, based 
        on load phase
    */
    bool isValidRaw() {
        return loadPhase == EResourceLoadPhase.RLP_SUCCES;
    }

    /**
        Returns is resource valid
    */
    bool isValid() {
        return isValidRaw() && isValidImpl();
    }

    override bool canBeAddedToQueueFree() {
        import engine.core.engine.engine : getResourceManager;
        return !getResourceManager().isStaticResource( this );
    }

protected:
    /**
        Informate about resource
        specific validation
    */
    bool isValidImpl() {
        return true;
    }

    void updateOwners() {
        import engine.core.utils.logger : log;
        
        foreach ( own; owners ) {
            if ( !own ) {
                log.warning( "Owner was deleted, while still owning a resource" );
                owners.removeElement( own );
            }
        }
    }
}

/**
    Check resource for null and valid
*/
bool checkResValid( AResource res ) {
    if ( !res ) {
        return false;
    }

    return res.isValid();
}