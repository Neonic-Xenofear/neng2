module modules.png.png;

import std.string;

import imageformats;

public import engine.core.resource.texture;
public import engine.core.vfs.vfs;
import engine.core.utils.logger;
import engine.core.engine.engine;

class CPNGLoader : ITextureFormatLoader {
    override void load( CTexture texture, string path ) {
        AFile file = getVFS().getFile( path );
        if ( file is null ) {
            texture.loadPhase = EResourceLoadPhase.RLP_FAILED;
            return;
        }
        ubyte[] data = file.readRawData();
        IFImage image = read_image_from_mem( data, ColFmt.RGBA );

        texture.path = path;
        texture.width = image.w;
        texture.height = image.h;
        texture.data = data;

        image.destroy;
        texture.loadPhase = EResourceLoadPhase.RLP_SUCCES;
        log.info( "PNG texture loaded: " ~ file.fullPath );
    }

    override string ext() {
        return "png";
    }
}