module engine.render.render;

import engine.core.mod.imod;
import engine.core.hal.window;

public import engine.core.resource.texture;
public import engine.resources;
public import engine.core.math.vec;
public import engine.core.math.color;
public import engine.scene.base;
public import engine.render.shader;
public import engine.render.buffer;

abstract class ARender : IModule {
    void clearScreen();
    void renderEnd();

    /*   2D RENDERING   */
    void genTextureData( CTexture texture );
    void destroyTextureData( CTexture texture );

    void drawTexture2D( CTexture texture, SVec2F pos, SVec2F size, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null );
    void drawTextureByRect2D( CTexture texture, SRect rect, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null );
    void drawText( string text, SVec2I pos = SVec2I( 0, 0 ), SColor4 color = SColor4.white );
    void drawLine2D( SVec2F start, SVec2F end, INodeCamera camera = null );
    void drawPoint2D( SVec2F pos, float radius, INodeCamera camera = null );

    /*   3D RENDERING   */
    void genMeshData( CMesh mesh );
    void destroyMeshData( CMesh mesh );

    void setDrawColor( SColor4 color );

    /*  SHADERS   */
    void compileShader( CShader shader );
    void bindShader( CShader shader );

    /*  RENDER TARGET   */
    void genRenderTarget( CRenderTarget rt );
    void destroyRenderTarget( CRenderTarget rt );
    /**
        Bind render target
        Params:
            rt - render target, if null - bind default render target
    */
    void bindRenderTarget( CRenderTarget rt );
}

abstract class AProtectRender : ARender {
    override void clearScreen() {
        clearScreenImpl();
    }

    override void renderEnd() {
        renderEndImpl();
    }

    override void genTextureData( CTexture texture ) {
        if ( texture is null ) {
            throw new Exception( "Trying to generate null texture" );
        }

        mixin( TLockResource!( texture ) );

        if ( !texture.extData.isNull() ) {
            throw new Exception( "Trying to generate null texture" );
        }

        genTextureDataImpl( texture );
    }

    override void destroyTextureData( CTexture texture ) {
        if ( texture is null ) {
            throw new Exception( "Trying to destroy null texture" );
        }

        mixin( TLockResource!( texture ) );
        
        if ( texture.extData.isNull() ) {
            throw new Exception( "Trying destroy none generated texture" );
        }

        destroyTextureDataImpl( texture );
    }

    override void drawTexture2D( CTexture texture, SVec2F pos, SVec2F size, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null ) {
        //Ignore null size
        if ( size.x == 0 || size.y == 0 ) {
            return;
        }

        if ( texture is null ) {
            throw new Exception( "Trying to draw null texture" );
        }

        mixin( TLockResource!( texture ) );

        if ( texture.extData.isNull() ) {
            throw new Exception( "Invalid texture render data" );
        }

        SVec2F resPos = pos;
        SVec2F resSize = SVec2F( texture.width * size.x, texture.height * size.y );

        //Convert position from world to screen coords
        if ( camera ) {
            resPos -= SVec2F( camera.getPos().x, camera.getPos().y );
        }

        //AABB clipping for not visible objects
        {
            SAABB textureAABB = SAABB(
                SVec2F( resPos.x, resPos.y + resSize.y ),
                SVec2F( resPos.x + resSize.x, resPos.y )
            );
    
            if ( camera !is null ) {
                if ( !camera.inView( textureAABB ) ) {
                    return;
                }
            }
        }

        drawTexture2DImpl( texture, resPos, resSize, angle, modulate, camera );
    }

    override void drawTextureByRect2D( CTexture texture, SRect rect, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null ) {
        //Ignore null size
        if ( rect.width == 0 || rect.height == 0 ) {
            return;
        }

        if ( texture is null ) {
            throw new Exception( "Trying to draw null texture" );
        }

        mixin( TLockResource!( texture ) );

        if ( texture.extData.isNull() ) {
            throw new Exception( "Invalid texture render data" );
        }

        SVec2F resPos = cast( SVec2F )rect.pos;
        SVec2F resSize = SVec2F( rect.width, rect.height );

        //Convert position from world to screen coords
        if ( camera ) {
            resPos -= SVec2F( camera.getPos().x, camera.getPos().y );
        }

        //AABB clipping for not visible objects
        {
            SAABB textureAABB = SAABB(
                SVec2F( resPos.x, resPos.y + resSize.y ),
                SVec2F( resPos.x + resSize.x, resPos.y )
            );
    
            if ( camera !is null ) {
                if ( !camera.inView( textureAABB ) ) {
                    return;
                }
            }
        }

        rect.pos = cast( SVec2I )resPos;

        drawTextureByRect2DImpl( texture, rect, angle, modulate, camera );
    }

    override void drawText( string text, SVec2I pos, SColor4 color ) {
        drawTextImpl( text, pos, color );
    }

    override void drawLine2D( SVec2F start, SVec2F end, INodeCamera camera ) {
        drawLine2DImpl( start, end, camera );
    }

    override void drawPoint2D( SVec2F pos, float radius, INodeCamera camera ) {
        drawPoint2DImpl( pos, radius, camera );
    }

    override void genMeshData( CMesh mesh ) {
        if ( mesh is null ) {
            throw new Exception( "Trying to gen invalid mesh" );
        }

        mixin( TLockResource!( mesh ) );

        if ( !mesh.extData.isNull() ) {
            throw new Exception( "Mesh data already generated" );
        }

        genMeshDataImpl( mesh );
    }

    override void destroyMeshData( CMesh mesh ) {
        if ( mesh is null ) {
            throw new Exception( "Trying to destroy invalid mesh" );
        }

        mixin( TLockResource!( mesh ) );

        if ( mesh.extData.isNull() ) {
            throw new Exception( "Mesh data already destroyed" );
        }

        destroyMeshDataImpl( mesh );
    }

    override void setDrawColor( SColor4 color ) {
        setDrawColorImpl( color );
    }

    override void compileShader( CShader shader ) {
        if ( shader ) {
            mixin( TLockResource!( shader ) );
        }

        compileShaderImpl( shader );
    }

    override void bindShader( CShader shader ) {
        if ( !checkResValid( shader ) ) {
            return;
        }

        bindShaderImpl( shader );
    }

    override void genRenderTarget( CRenderTarget rt ) {
        if ( !rt ) {
            throw new Exception( "Trying to gen null render target" );
        }

        mixin( TScopeLockObject!( rt ) );

        if ( !rt.extData.isNull() ) {
            throw new Exception( "Trying to gen already generated render target" );
        }

        genRenderTargetImpl( rt );
    }

    override void destroyRenderTarget( CRenderTarget rt ) {
        if ( !rt ) {
            throw new Exception( "Trying to destroy null render target" );
        }

        mixin( TScopeLockObject!( rt ) );

        if ( rt.extData.isNull() ) {
            throw new Exception( "Trying to destroy none generated render target" );
        }

        destroyRenderTargetImpl( rt );
    }

    override void bindRenderTarget( CRenderTarget rt ) {
        mixin( TScopeLockObject!( rt ) );
        bindRenderTargetImpl( rt );
    }

    void clearScreenImpl();
    void renderEndImpl();

    void genTextureDataImpl( CTexture texture );
    void destroyTextureDataImpl( CTexture texture );
    void drawTexture2DImpl( CTexture texture, SVec2F pos, SVec2F size, float angle, SColor4 modulate, INodeCamera camera );
    void drawTextureByRect2DImpl( CTexture texture, SRect rect, float angle, SColor4 modulate, INodeCamera camera );

    void drawTextImpl( string text, SVec2I pos, SColor4 color );
    void drawLine2DImpl( SVec2F start, SVec2F end, INodeCamera camera );
    void drawPoint2DImpl( SVec2F pos, float radius, INodeCamera camera );

    /*   3D RENDERING   */
    void genMeshDataImpl( CMesh mesh );
    void destroyMeshDataImpl( CMesh mesh );

    void setDrawColorImpl( SColor4 color );

    void compileShaderImpl( CShader shader );
    void bindShaderImpl( CShader shader );

    void genRenderTargetImpl( CRenderTarget rt );
    void destroyRenderTargetImpl( CRenderTarget rt );
    void bindRenderTargetImpl( CRenderTarget rt );
}