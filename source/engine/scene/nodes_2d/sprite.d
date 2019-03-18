module engine.scene.nodes_2d.sprite;

public import engine.scene.nodes_2d.node2d;
public import engine.core.resource.texture;
public import engine.core.engine.engine;
import engine.render.commands;

import engine.core.ext_data;

/**
    Sprite node
*/
@ScriptExport( "CSprite" )
class CSprite : CNode2D {
    mixin( NODE_REG!() );

private:
    @Serialize
    SResRef!CTexture texture; ///Draw texture

public:
    @ScriptExport( "", MethodType.ctor )
    this() {
        super();
    }

    @ScriptExport( "", MethodType.ctor )
    this( string path ) {
        super();
        loadTexture( path );
    }

    override void onDestroy() {
        texture.removeOwner( this );
    }

    override void onDraw( INodeCamera camera ) {
        if ( !checkResValid( texture ) ) {
            return;
        }

        getRender().drawTexture2D( texture, getGlobalPos(), transform.size, transform.angle, modulateColor, camera );
    }

    /**
        Load texture.
        Params:
            path - path to texture in VFS.
    */
    @ScriptExport( "loadTexture", MethodType.method, "", RetType.none )
    void loadTexture( string path ) {
        texture = engine.core.resource.texture.loadTexture( path );
        texture.addOwner( this );
    }
}