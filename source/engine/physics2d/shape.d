module engine.physics2d.shape;

import engine.script;
import engine.core.ext_data;

/**
    Shape type.
*/
enum EShapeType {
    ST_BOX,
    ST_CIRCLE,
}

/**
    Basic phys body shape. 
*/
@ScriptExport( "CShape2D" )
class CShape2D {
    CExtData extData;
    EShapeType type;
    CBaseBody2D parent;

protected:
    bool bIsTrigger = false;

public:
    @ScriptExport( "", MethodType.ctor )
    this() {
        extData = new CExtData();
    }

    void move( SVec2F m ) {
        getPhysWorld2D().moveBodyShape( parent, this, m );
    }

    @property
    bool isTrigger() {
        return bIsTrigger;
    }

    @property
    void isTrigger( bool bVal ) {
        if ( bIsTrigger != bVal ) {
            bIsTrigger = bVal;
            getPhysWorld2D().setShapeIsTrigger( parent, this, bIsTrigger );
        }
    }

    @ScriptExport( "move", MethodType.method, "", RetType.none )
    void script_move( SVec2D_Script* m ) {
        if ( m ) {
            move( SVec2F( m.x, m.y ) );
        }
    }

    @ScriptExport( "setIsTrigger", MethodType.method, "", RetType.none )
    void script_setIsTrigger( bool bVal ) {
        isTrigger( bVal );
    }

    @ScriptExport( "getIsTrigger", MethodType.method, "", RetType.number )
    bool script_getIsTrigger() {
        return bIsTrigger;
    }
}

/**
    Body phys body shape.
*/
@ScriptExport( "CBoxShape2D" )
class CBoxShape2D : CShape2D {
    int width;
    int heigth;

public:
    @ScriptExport( "", MethodType.ctor )
    this( int iWidth, int iHeigth ) {
        type = EShapeType.ST_BOX;
        width = iWidth;
        heigth = iHeigth;
    }

    @ScriptExport( "getWidth", MethodType.method, "", RetType.userdat )
    int getWidth() {
        return width;
    }

    @ScriptExport( "getHeigth", MethodType.method, "", RetType.userdat )
    int getHeigth() {
        return heigth;
    }
}