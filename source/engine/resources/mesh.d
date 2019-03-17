module engine.resources.mesh;

import engine.core.math;
import engine.core.ext_data;
import engine.core.resource;
import engine.core.engine.engine : getRender, getResourceManager;

struct SVertex {
    SVec3F pos;
    SVec3F normal;
    SVec3F texCoords;
}

enum EMeshType {
    MT_STATIC,
    MT_DYNAMIC,
}

@RegisterResource( "Mesh" )
class CMesh : AResource {
    mixin( TResourceRegister!() );
public:
    CExtData extData;
    EMeshType type = EMeshType.MT_STATIC;

    SVertex[] vertices;
    uint[] indices;
    SResRef!CTexture[] textures;

    this() {
        super();
        extData = new CExtData();
    }

    ~this() {
        if ( !extData.isNull() ) {
            getRender().destroyMeshData( this );
        }

        extData.destroy();
    }
}

class CMeshLoader : IResourceLoader {
    override void loadByPath( AResource resource, string path ) {
        CMesh res = cast( CMesh )resource;
        if ( !res ) {
            resource.loadPhase = EResourceLoadPhase.RLP_FAILED;
            return;
        }

        res.vertices ~= SVertex();
        res.indices ~= 0;
        res.textures ~= SResRef!CTexture( loadTexture( "resources/test/textures/test1.png" ) );

        res.loadPhase = EResourceLoadPhase.RLP_SUCCES;
        getRender().genMeshData( res );
    }
}

CMesh loadMesh( string path ) {
    return getResourceManager().loadResource!CMesh( path, false );
}