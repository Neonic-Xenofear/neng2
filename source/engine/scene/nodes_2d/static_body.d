module engine.scene.nodes_2d.static_body;

import engine.physics2d;
import engine.scene.nodes_2d.node2d;

class CStaticBody2D : CNode2D {
protected:
    CPhysStaticBody2D physBody;

public:
    this() {
        super();
        physBody = new CPhysStaticBody2D();
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

protected:
    void updatePosFromPhysWorld( SVec2F newPos ) {
        transform.pos = newPos;
    }
}