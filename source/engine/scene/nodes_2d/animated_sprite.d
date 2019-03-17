module engine.scene.nodes_2d.animated_sprite;

import engine.core.engine.engine;
import engine.scene.nodes_2d.node2d;
public import engine.core.resource.animated_texture;

@ScriptExport( "CAnimatedSprite" )
class CAnimatedSprite : CNode2D {
    mixin( NODE_REG!() );

    CAnimatedTexture animSprite;

    this() {
        animSprite = new CAnimatedTexture();
    }

    ~this() {
        animSprite.destroy();
    }

    override void onUpdate( float delta ) {
        animSprite.update();
    }

    override void onDraw( INodeCamera camera ) {
        if ( auto texture = animSprite.getCurrentFrame() ) {
            //getRender().drawTexture2D( texture, this, getGlobalPos(), transform.size, transform.angle, camera );
        }
    }

    void setAnimTexture( CAnimatedTexture newAnimTex ) {
        if ( animSprite !is null ) {
            animSprite.destroy();
        }

        animSprite = newAnimTex;
    }
}