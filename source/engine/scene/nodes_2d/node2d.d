module engine.scene.nodes_2d.node2d;

import engine.core.engine.engine;
import engine.script.lib;
public import engine.scene.base.node;
public import engine.core.math.transform;

/**
    Basic 2d node
*/
@ScriptExport( "CNode2D" )
class CNode2D : CNode {
    mixin( NODE_REG!() );

    @Serialize
    STransform2D transform; ///Node transform

public:
    @ScriptExport( "", MethodType.ctor )
    this() {
        super();
        //TODO: Fix vector set
        transform.pos.x = 0;
        transform.pos.y = 0;

        transform.size.x = 1.0f;
        transform.size.y = 1.0f;
    }

    /**
        Get global world position
    */
    SVec2F getGlobalPos() {
        CNode2D par = cast( CNode2D )parent;

        if ( par !is null ) {
            return par.getGlobalPos() + transform.pos;
        }

        return transform.pos;
    }

    /*================SCRIPT_REGISTRY================*/

    @ScriptExport( "getPos", MethodType.method, "", RetType.userdat )
    SVec2D_Script script_getPos() {
        return new SVec2D_Script( transform.pos.x, transform.pos.y );
    }

    @ScriptExport( "setPosVec", MethodType.method, "", RetType.none )
    void script_setPosVec( SVec2D_Script* newPos ) {
        if ( newPos is null ) {
            return;
        }

        transform.pos.x = ( *newPos ).x;
        transform.pos.y = ( *newPos ).y;
    }

    @ScriptExport( "setPos", MethodType.method, "", RetType.none )
    void script_setPos( float newPosX, float newPosY ) {
        script_setPosX( newPosX );
        script_setPosY( newPosY );
    }

    @ScriptExport( "setPosX", MethodType.method, "", RetType.none )
    void script_setPosX( float newPos ) {
        transform.pos.x = newPos;
    }

    @ScriptExport( "setPosY", MethodType.method, "", RetType.none )
    void script_setPosY( float newPos ) {
        transform.pos.y = newPos;
    }

    @ScriptExport( "getSize", MethodType.method, "", RetType.userdat )
    SVec2D_Script script_getSize() {
        return new SVec2D_Script( transform.size.x, transform.size.y );
    }

    @ScriptExport( "setSizeVec", MethodType.method, "", RetType.none )
    void script_setSizeVec( SVec2D_Script* newSize ) {
        if ( newSize is null ) {
            return;
        }

        transform.size.x = ( *newSize ).x;
        transform.size.y = ( *newSize ).y;
    }

    @ScriptExport( "setSize", MethodType.method, "", RetType.none )
    void script_setSize( float newSizeX, float newSizeY ) {
        script_setSizeX( newSizeX );
        script_setSizeY( newSizeY );
    }

    @ScriptExport( "setSizeX", MethodType.method, "", RetType.none )
    void script_setSizeX( float newSize ) {
        transform.size.x = newSize;
    }

    @ScriptExport( "setSizeY", MethodType.method, "", RetType.none )
    void script_setSizeY( float newSize ) {
        transform.size.y = newSize;
    }

    @ScriptExport( "setAngle", MethodType.method, "", RetType.none )
    void script_setAngle( float newAngle ) {
        transform.angle = newAngle;
    }

    @ScriptExport( "getAngle", MethodType.method, "", RetType.number )
    float script_getAngle() {
        return transform.angle;
    }
}