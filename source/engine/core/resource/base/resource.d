module engine.core.resource.base.resource;

import std.algorithm : canFind;

public import engine.core.vfs.vfs;
import engine.core.object;
import engine.core.serialize;
import engine.core.utils.array : removeElement;

enum EResourceLoadPhase {
    RLP_NONE,
    RLP_LOADING,
    RLP_FAILED,
    RLP_SUCCES,
}

/**
    Register resource need code
*/
template TResourceRegister() {
    enum TResourceRegister = 
    TRegisterObject!();
}

/**
    Used for associate resource 
    class with resource name
*/
struct RegisterResource {
    string resTypeName;
}

enum AllowLoadOnFiber;


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

    Instead of "destroy", use "queueFree"
    Example: {
        ...
        resource.destroy(); //Invalid, resource can be locked
        resource.queueFree(); //Correct, resource will be destroyed at the end of frame
        ...
    }
*/
abstract class AResource : AObject {
    mixin( TResourceRegister!() );
public:
    @Serialize {
        string path; ///Full resource path in VFS
    }

    EResourceLoadPhase loadPhase = EResourceLoadPhase.RLP_NONE; ///Loading phase, because loading process in fiber


protected:
    AObject[] owners;

    bool bLocked = false;

public:
    ///
    this() {
        super();
    }

    ~this() {
        import engine.app.logger : log;
        assert( !bLocked, "Delete resource while it locked. Perhaps you used \"destroy\" instead \"queueFree\"?" );

        if ( owners.length > 0 ) {
            log.warning( "Resource is still have owners!" );
        }
    }

    /**
        Block resource delete
    */
    void lock() {
        bLocked = true;
    }

    /**
        Allow resource delete
    */
    void unlock() {
        bLocked = false;
    }

    bool isLocked() {
        return bLocked;
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
                this.destroy();
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

protected:
    /**
        Informate about resource
        specific validation
    */
    bool isValidImpl() {
        return true;
    }

    void updateOwners() {
        import engine.app.logger : log;
        
        foreach ( own; owners ) {
            if ( !own ) {
                log.warning( "Owner was deleted, while still owning a resource" );
                owners.removeElement( own );
            }
        }
    }
}

void queueFree( AResource resource ) {
    import engine.core.engine.engine : getResourceManager;

    if ( resource ) {
        getResourceManager().addResourceToFreeQueue( resource );
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