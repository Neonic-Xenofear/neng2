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
class CShape2D {
    CExtData extData;
    EShapeType type;

    this() {
        extData = new CExtData();
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