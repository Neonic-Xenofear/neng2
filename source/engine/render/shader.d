module engine.render.shader;

import engine.core.engine.engine;
import engine.core.ext_data;
import engine.core.resource.base;

enum EShaderType {
    ST_VERTEX,
    ST_FRAGMENT,
    ST_GEOMETRY,
}

struct SShaderCodeFile {
    string code;
    string path;
    EShaderType type;
}

@RegisterResource( "Shader" )
@ResourceLoadType( EResourceLoadingType.RLT_ASYNC )
class CShader : AResource {
    mixin( TResourceRegister!() );
    CExtData extData;
    
    bool bCompiled = false;

    @Serialize {
        SShaderCodeFile vertex;
        SShaderCodeFile fragment;
    }

    this( string pathVertex, string pathFragment ) {
        extData = new CExtData();

        if ( AFile file = getVFS().getFile( pathVertex ) ) {
            vertex.code = cast( string )file.readRawData();
            vertex.path = pathVertex;
            vertex.type = EShaderType.ST_VERTEX;
        }

        if ( AFile file = getVFS().getFile( pathFragment ) ) {
            fragment.code = cast( string )file.readRawData();
            fragment.path = pathFragment;
            fragment.type = EShaderType.ST_FRAGMENT;
        }
    }

    void compile() {
        getRender.compileShader( this );
    }

protected:
    override bool isValidImpl() {
        return !extData.isNull() && bCompiled;
    }
}


class CShaderLoader : IResourceLoader {
    override void loadByPath( AResource resource, string path ) {
        ( cast( CShader )resource ).compile();
    }
}