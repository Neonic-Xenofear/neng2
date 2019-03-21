module engine.scene.nodes_2d.dynamic_body;

import engine.physics2d;
import engine.scene.nodes_2d.node2d;

@ScriptExport( "CDynamicBody2D" )
class CDynamicBody2D : CNode2D {
    mixin( NODE_REG!() );
protected:
    CPhysDynamicBody2D physBody;

public:
    @ScriptExport( "", MethodType.ctor )
    this() {
        super();
        physBody = new CPhysDynamicBody2D();
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
    void script_setLinearVelocity( float vX, float vY ) {
        setLinearVelocity( SVec2F( vX, vY ) );
    }

    @ScriptExport( "addShape", MethodType.method, "", RetType.none )
    void script_addShape( CShape2D* shape ) {
        if ( shape ) {
            addShape( *shape );
        }
    }

protected:
    void updatePosFromPhysWorld( SVec2F newPos ) {
        transform.pos = newPos;
    }
}