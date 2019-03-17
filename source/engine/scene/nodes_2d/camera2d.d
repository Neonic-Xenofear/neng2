module engine.scene.nodes_2d.camera2d;

import engine.core.engine.engine;
import engine.scene.base.node_camera;
import engine.scene.nodes_2d.node2d;

/**
    Camera 2D
*/
@ScriptExport( "CCamera2D" )
class CCamera2D : CNode2D, INodeCamera {
    mixin( NODE_REG!() );

    bool bCurrent = false;
    SVec2F deadZone;
    SVec2I viewSize;
    CNode2D followNode = null;

    @Serialize
    SAABB aabb;

    @ScriptExport( "", MethodType.ctor )
    this() {
        aabb.min.x = 0;
        aabb.min.y = confGeti( "engine/app/window/height" );

        aabb.max.x = confGeti( "engine/app/window/width" );
        aabb.max.y = 0;   

        //bAllowWorkWithoutRender - with this parametr window not exist
        if ( getEngine().window ) {
            getEngine().window.onResized.connect( &onWindowResized );
        }
    }

    override void onDestroy() {
        getEngine.window.onResized.disconnect( &onWindowResized );
    }

    override void onUpdate( float delta ) {
        import std.math : abs;

        if ( followNode !is null ) {
            if ( deadZone != SVec2F( 0, 0 ) ) {
                float dx = followNode.transform.pos.x - transform.pos.x;
                float dy = followNode.transform.pos.y - transform.pos.y;

                if ( abs( dx ) >= deadZone.x ) {
                    transform.pos.x = followNode.transform.pos.x + ( deadZone.x * ( -dx / abs( dx ) ) );
                }

                if ( abs( dy ) >= deadZone.y ) {
                    transform.pos.y = followNode.transform.pos.y + ( deadZone.y * ( -dy / abs( dy ) ) );
                }
            } else {
                transform.pos.x = confGeti( "engine/app/window/width" ) / 2 - followNode.transform.pos.x;
                transform.pos.y = confGeti( "engine/app/window/height" ) / 2 - followNode.transform.pos.y;
            }
        }
    }

    SVec3F getPos() {
        return SVec3F( transform.pos.x, transform.pos.y, 0.0f );
    }

    bool inView( SAABB object ) {
        return aabb.isIntersection( object );
    }

    void onWindowResized( int iWidth, int iHeight ) {
        aabb.min.y = iHeight;
        aabb.max.x = iWidth;
    }
}