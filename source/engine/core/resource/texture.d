module engine.core.resource.texture;

import engine.core.utils.logger;
import engine.core.engine;
public import engine.core.resource.base.resource;
import engine.core.resource.base.resource_loader;
import engine.core.utils;
import engine.core.ext_data;
import engine.core.utils.envelope;

/**
    Texture object
*/
@RegisterResource( "Texture" )
@ResourceLoadType( EResourceLoadingType.RLT_ASYNC )
class CTexture : AResource {
    mixin( TResourceRegister!() );

    CExtData extData; ///Render data

    int height;
    int width;

    ubyte[] data; ///Data from ITextureFormatLoader
    ubyte* p_data;
    @Serialize
    bool bMipmaps;

public:
    this() {
        super();
        extData = new CExtData();
    }

    ~this() {
        if ( !extData.isNull() ) {
            getRender().destroyTextureData( this );
        }
        
        extData.destroy();
    }

    void genRenderData() {
        getRender().genTextureData( this );
    }

protected:
    override bool isValidImpl() {
        return !extData.isNull();
    }
}

/**
    Abstract texture format loader
*/
interface ITextureFormatLoader {
    void load( CTexture texture, string path );

    /**
        Return avaible file extension
    */
    string ext();
}

/**
    Texture loader
*/
class CTextureLoader : IResourceLoader {
protected:
    ITextureFormatLoader[string] loaders; ///RegisteredLoaders

public:
    /**
        Load texture by VFS path
        Params:
            path - path to texture in VFS
    */
    override void loadByPath( AResource resource, string path ) {
        import std.path : extension;
        import std.string : replace;

        string ext = extension( path ); //Return ext like: ".png"
        if ( ext.startsWith( "." ) ) {
            ext = ext[1..$]; //Remove "." from extension
        }

        if ( auto loader = ext in loaders ) {
            CTexture tex = cast( CTexture )resource;
            loader.load( tex, path );
            tex.genRenderData();
        } else {
            log.error( "Invalid texture file extension: " ~ ext );
        }
    }

    /**
        Register loader for image type.
        Params:
            T - loader class;
    */
    void registerLoader( T )() {
        T loader = new T();
        //Check if already registered
        if ( auto extist = loader.ext() in loaders ) {
            loader.destroy();
            return;
        }

        loaders[loader.ext()] = loader;
        log.info( "Texture format loader registered: " ~ loader.ext() );
    }
}

/**
    Load texture by VFS path
    Params:
        path - path to texture in VFS
*/
CTexture loadTexture( string path ) {
    return getResourceManager().loadResource!CTexture( path );
}

void registerTextureLoader( T )()
if ( is( T : ITextureFormatLoader ) ) {
    ( cast( CTextureLoader )getResourceManager().getResourceLoader!CTexture() ).registerLoader!T;
}