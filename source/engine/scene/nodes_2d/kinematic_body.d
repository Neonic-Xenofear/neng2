module engine.scene.nodes_2d.kinematic_body;

import engine.physics2d;
import engine.scene.nodes_2d.node2d;

@ScriptExport( "CKinematicBody2D" )
class CKinematicBody2D : CNode2D {
    mixin( NODE_REG!() );
protected:
    CPhysKinematicBody2D physBody;

public:
    @ScriptExport( "", MethodType.ctor )
    this() {
        super();
        physBody = new CPhysKinematicBody2D();
        physBody.onPosUpdated.connect( &updatePosFromPhysWorld );
        physBody.initBodyData();
    }

    override void onDestroy() {
        physBody.destroy();
    }

    void setPos( SVec2F newPos ) {
        physBody.setPos( newPos );
    }

    void addShape( CShape2D iShape ) {
        physBody.addShape( iShape );
    }

    void setLinearVelocity( SVec2F vel ) {
        physBody.setLinearVelocity( vel );
    }

    @ScriptExport( "setLinearVelocity", MethodType.method, "", RetType.none )
    void script_serLinearVelocity( SVec2D_Script* vel ) {
        setLinearVelocity( SVec2F( vel.x, vel.y ) );
    }

protected:
    void updatePosFromPhysWorld( SVec2F newPos ) {
        transform.pos = newPos;
    }
}