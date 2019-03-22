module engine.physics2d.base_body;

import engine.core.math;
import engine.core.ext_data;
public import engine.physics2d.shape;
import engine.core.engine.engine;
import engine.core.utils.signal;

/**
    Phys body type.
*/
enum EPhysBodyType {
    PBT_STATIC,
    PBT_DYNAMIC,
    PBT_KINEMATIC,
}

/**
    Basic 2D physics body.
*/
@ScriptExport( "CBaseBody2D" )
class CBaseBody2D {
protected:
    CShape2D[] shapes; ///Attached shaped

    STransform2D transform;
    EPhysBodyType type; ///Body type

public:
    uint contanctsNum = 0;

    CExtData extData; ///Server gen data

    SSignal!( SVec2F ) onPosUpdated; ///Called when postion updated
    SSignal!( CBaseBody2D ) onCollide; ///Called when collide with other object

    @ScriptExport( "", MethodType.ctor )
    this() {
        extData = new CExtData();
    }

    ~this() {
        onPosUpdated.disconnectAll();
        onCollide.disconnectAll();

        foreach ( CShape2D sh; shapes ) {
            removeShape( sh );
        }
    }

    /**
        Initialize server body data.
    */
    void initBodyData() {
        getPhysWorld2D().genBodyData( this );
    }

    /**
        Return phys body type.
    */
    @nogc
    @property
    EPhysBodyType getType() const pure nothrow {
        return type;
    }

    /**
        Setting the position with contacting the server.
        Params:
            newPos - new position.
    */
    void setPos( SVec2F newPos ) {
        getPhysWorld2D().setBodyPos( this, newPos );
        onPosUpdated.emit( newPos );
    }

    /**
        Setting the position without contacting the server.
        Params:
            newPos - new position.
    */
    void setPosRaw( SVec2F newPos, bool bEmitPosUpdate = true ) {
        transform.pos = newPos;
        if ( bEmitPosUpdate ) {
            onPosUpdated.emit( newPos );
        }
    }

    /**
        Set body linear velocity.
        Params:
            vel - linear velocity.
    */
    void setLinearVelocity( SVec2F vel ) {
        getPhysWorld2D().setBodyLinearVelocity( this, vel );
    }

    SVec2F getPos() {
        return transform.pos;
    }

    /**
        Add shape to body.
        Params:
            newShape - attach shape.
    */
    void addShape( CShape2D newShape ) {
        if ( !shapes.canFind( newShape ) ) {
            getPhysWorld2D().addBodyShape( this, newShape );
            newShape.parent = this;
            shapes ~= newShape;
        }
    }

    /**
        Remove shape.
        Params:
            iShape - remove shape.
    */
    void removeShape( CShape2D iShape ) {
        import engine.core.utils.array : removeElement;
        if ( shapes.canFind( iShape ) ) {
            getPhysWorld2D().removeBodyShape( this, iShape );
            removeElement( shapes, iShape );
            iShape.parent = null;
        }
    }

    /**
        Return all attached shapes.
    */
    CShape2D[] getShapes() {
        return shapes;
    }

    @ScriptExport( "isCollide", MethodType.method, "", RetType.number )
    bool isCollide() {
        return contanctsNum > 0;
    }
}

/**
    Static phys body.
*/
class CPhysStaticBody2D : CBaseBody2D {
    this() {
        type = EPhysBodyType.PBT_STATIC;
    }
}


/**
    Dynamic phys body.
*/
class CPhysDynamicBody2D : CBaseBody2D {
    this() {
        type = EPhysBodyType.PBT_DYNAMIC;
    }
}


/**
    Kinematic phys body.
*/
class CPhysKinematicBody2D : CBaseBody2D {
    this() {
        type = EPhysBodyType.PBT_KINEMATIC;
    }
}