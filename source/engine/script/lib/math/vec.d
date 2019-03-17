module engine.script.lib.math.vec;

import engine.script;

@ScriptExport( "SVec2D" )
class SVec2D_Script {
    float x;
    float y;

    @ScriptExport( "", MethodType.ctor )
    this() {}

    @ScriptExport( "", MethodType.ctor )
    this( float iX, float iY ) {
        x = iX;
        y = iY;
    }

    @ScriptExport( "X", MethodType.method, "", RetType.number )
    float X() {
        return x;
    }

    @ScriptExport( "setX", MethodType.method, "", RetType.number )
    void setX( float val ) {
        x = val;
    }

    @ScriptExport( "Y", MethodType.method, "", RetType.number )
    float Y() {
        return y;
    }

    @ScriptExport( "setY", MethodType.method, "", RetType.number )
    void setY( float val ) {
        y = val;
    }
}

@ScriptExport( "SVec3D" )
class SVec3D_Script : SVec2D_Script {
    float z;

    @ScriptExport( "", MethodType.ctor )
    this() {}

    @ScriptExport( "", MethodType.ctor )
    this( float iX, float iY, float iZ ) {
        x = iX;
        y = iY;
        z = iZ;
    }

    @ScriptExport( "Z", MethodType.method, "", RetType.number )
    float Z() {
        return z;
    }

    @ScriptExport( "setZ", MethodType.func, "", RetType.none )
    void setZ( float val ) {
        z = val;
    }
}