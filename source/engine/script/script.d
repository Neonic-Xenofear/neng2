module engine.script.script;

import engine.scene.base;
import engine.core.ext_data;
import engine.script.script_manager;
import engine.core.engine.engine;
import engine.core.object;
import engine.core.resource;

@RegisterResource( "Script" )
@ScriptExport( "CScript" )
@ResourceLoadType( EResourceLoadingType.RLT_STATIC )
class CScript : AResource {
    mixin( TResourceRegister!() );
protected:
    bool bInstanced = false;
    CExtData extData;

public:
    @Serialize
    string className;

    @ScriptExport( "", MethodType.ctor )
    this() {
        extData = new CExtData();
    }

    void initInstance( T )( T obj = null ) {
        getEngine().scriptManager.getNewScriptObject( className, extData );
        callFunctionWithoutValidation( "init", obj );
        bInstanced = true;
    }

    void callFunction( Args... )( string funcName, Args args ) {
        if ( isValid() ) {
            getEngine().scriptManager.callClassFunction( className, funcName, extData, args );
        }
    }

    void callFunctionWithoutValidation( Args... )( string funcName, Args args ) {
        getEngine().scriptManager.callClassFunction( className, funcName, extData, args );
    }

    @property
    string nativeClassName() {
        return getEngine().scriptManager.nativeClassName( this );
    }

protected:
    override bool isValidImpl() {
        return className != "" && bInstanced && !extData.isNull();
    }
}