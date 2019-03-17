module engine.render.render;

import engine.core.mod.imod;
import engine.app.window;

public import engine.core.resource.texture;
public import engine.resources;
public import engine.core.math.vec;
public import engine.core.math.color;
public import engine.scene.base;
public import engine.render.shader;

abstract class ARender : IModule {
    @property
    final EModuleUpdate updateInfo() {
        return EModuleUpdate.MU_NORMAL;
    }

    @property
    final EModuleInitPhase initPhase() {
        return EModuleInitPhase.MIP_UPON_REQUEST;
    }

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

    void compileShader( CShader shader );
    void bindShader( CShader shader );
}