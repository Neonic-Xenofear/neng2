module modules.render.opengl.render;

import std.string;
import core.stdc.stdlib;
import std.conv;

import derelict.opengl;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import engine.core.hal.window;
import engine.render.render;
import engine.core.utils.path;

const VERTEX_DEFAULT = "resources/shaders/opengl_render/vertex.glsl";
const FRAGMENT_DEFAULT = "resources/shaders/opengl_render/fragment.glsl";

GLuint[] indices = [
    0, 1, 3,
    1, 2, 3
];

GLfloat[] vertices = [
    1.0f,  0.0f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,
    1.0f,  1.0f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,
    0.0f,  1.0f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    0.0f,  0.0f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f
];

GLfloat[] pos = [
    0, 0, 0.0f,
    0, 0, 0.0f,
    0, 0, 0.0f,
];

class CMeshExtData {
    GLuint VAO;
    GLuint VBO;
    GLuint EBO;
}

class COpenGLRender : ARender {
private:
    GLuint VAO;
    GLuint lineVAO;
    GLuint lineVBO;
    CWindow window;

    SColor4 clearColor;
    CShader mainShader;
    CShader lineShader;
    TTF_Font* textFont;
    int[2] currWinSize;

public:
    SModuleInfo info() {
        return SModuleInfo(
            "OPENGL_RENDER",
            "NENG2_CORE", 
            "1.0",
            EModuleInitPhase.MIP_UPON_REQUEST,
            EModuleDestroyPhase.MDP_NORMAL,
            EModuleUpdate.MU_NORMAL,
        );
    }
    
    void onLoad( CEngine engine ) {
        DerelictGL3.load();

        window = engine.window;
        window.createRenderContext( ERenderContext.RC_OPENGL );

        //Reload opengl for all funtions
        DerelictGL3.reload();

        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
        //glEnable( GL_CULL_FACE );
        glFrontFace( GL_CCW );
        glEnable( GL_BLEND );
        glDisable( GL_DEPTH_TEST );
        glDisable( GL_SCISSOR_TEST );

        mainShader = new CShader( VERTEX_DEFAULT, FRAGMENT_DEFAULT );
        lineShader = new CShader( VERTEX_DEFAULT, "resources/shaders/opengl_render/line_fragment.glsl" );
        compileShader( mainShader );
        compileShader( lineShader );

        AFile fontFile = getVFS().getFile( "resources/fonts/OpenSans-Regular.ttf" );
        if ( fontFile !is null ) {
            textFont = TTF_OpenFont( 
                toStringz( fontFile.corrPath ), 
                15
            );
        }

        GLuint VBO;
        GLuint EBO;

        glGenVertexArrays( 1, &VAO );
        glGenBuffers( 1, &VBO );
        glGenBuffers( 1, &EBO );

        glBindVertexArray( VAO );
            glBindBuffer( GL_ARRAY_BUFFER, VBO );
            glBufferData( GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW );

            glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, EBO );
            glBufferData( GL_ELEMENT_ARRAY_BUFFER, indices.length * GLuint.sizeof, indices.ptr, GL_STATIC_DRAW );

            glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast( void* )0 );
            glEnableVertexAttribArray( 0 ); 
            glVertexAttribPointer( 2, 2, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast( GLvoid* )( 6 * GLfloat.sizeof ) );
            glEnableVertexAttribArray( 2 );

            glBindBuffer( GL_ARRAY_BUFFER, 0 );
        glBindVertexArray( 0 );

        glGenVertexArrays( 1, &lineVAO );
        glGenBuffers( 1, &lineVBO );

        glBindVertexArray( lineVAO );
            glBindBuffer( GL_ARRAY_BUFFER, lineVBO );
            glBufferData( GL_ARRAY_BUFFER, pos.length * float.sizeof, pos.ptr, GL_DYNAMIC_DRAW );
            glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast( void* )0 );
            glEnableVertexAttribArray( 0 );
            glBindBuffer( GL_ARRAY_BUFFER, 0 );
        glBindVertexArray( 0 );

        clearColor = SColor4( confGets( "engine/modules/render/clearColor" ) );
    }

    void onUnload( CEngine engine ) {
        TTF_CloseFont( textFont );

        glDeleteVertexArrays( 1, &VAO );

        SDL_Quit();
        IMG_Quit();
        TTF_Quit();

        DerelictGL3.unload();
    }

    void update( float delta ) {
    }

    override void clearScreen() {
        //Convert color to 0..1 range
        glClearColor( 
            clearColor.r / 255.0f, 
            clearColor.g / 255.0f, 
            clearColor.b / 255.0f, 
            clearColor.a / 255.0f 
        );
        glClear( GL_COLOR_BUFFER_BIT );

        SMat4F proj = SMat4F.identity();
        proj = proj.ortho( 
            0.0f, 
            confGeti( "engine/app/window/width" ), 
            confGeti( "engine/app/window/height" ), 
            0.0f, 
            -1.0f, 
            1.0f 
        );

        if ( mainShader !is null ) {
            GLint projLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "projection" );
            glUniformMatrix4fv( projLoc, 1, GL_TRUE, proj[0].ptr );
        }

        int[2] newWinSize;
        newWinSize[0] = confGeti( "engine/app/window/width" );
        newWinSize[1] = confGeti( "engine/app/window/height" );

        if ( currWinSize[0] != newWinSize[0] || currWinSize[1] != newWinSize[1] ) {
            glViewport( 0, 0, newWinSize[0], newWinSize[1] );
            currWinSize = newWinSize;
        }
    }

    override void renderEnd() {
        window.swapBuffers();
    }

    override void genTextureData( CTexture texture ) {
        SDL_Surface* surf;

        SDL_RWops* rw = SDL_RWFromMem( texture.data.ptr, cast( int )( texture.data.length * ubyte.sizeof ) );
        if ( !rw ) {
            return;
        }

        surf = IMG_Load_RW( rw, 1 );

        if ( surf is null ) {
            log.error( "IMG_Load_RW: " ~ to!string( IMG_GetError() ) ~ "\n\t" ~ texture.path );
            return;
        }

        texture.width = surf.w;
        texture.height = surf.h;

        GLuint textureID;

        glGenTextures( 1, &textureID );
        glBindTexture( GL_TEXTURE_2D, textureID );

        int mode = GL_RGB;
        if ( surf.format.BytesPerPixel == 4 ) {
            mode = GL_RGBA;
        }

        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            mode,
            texture.width,
            texture.height,
            0,
            mode,
            GL_UNSIGNED_BYTE,
            surf.pixels
        );

        if ( texture.bMipmaps ) {
            glGenerateMipmap( GL_TEXTURE_2D );
        }

        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

        glBindTexture( GL_TEXTURE_2D, 0 );

        texture.extData = textureID;
        SDL_FreeSurface( surf );

        log.info( "Render texture data generated " ~ texture.path );
    }

    override void destroyTextureData( CTexture texture ) {
        GLuint tex = texture.extData.as!GLuint;
        glDeleteTextures( 1, &tex );
        log.info( "Texture data destroyed: " ~ texture.path );
    }

    override void drawTexture2D( CTexture texture, SVec2F pos, SVec2F size, float angle, SColor4 modulate, INodeCamera camera ) {
        GLuint textureID = texture.extData.as!GLuint;

        bindShader( mainShader ); //Bind main draw shader
            SMat4F mat = SMat4F.identity();
            mat.scale( SVec3F( size.x, size.y, 0.0f ) );

            mat.translate( SVec3F( -0.5f * size.x, -0.5f * size.y, 0.0f ) );
            mat.rotateZ( angle );
            mat.translate( SVec3F( 0.5f * size.x, 0.5f * size.y, 0.0f ) );

            mat.translate( SVec3F( pos.x, pos.y, 0.0f ) );

            if ( mainShader !is null ) {
                GLint transformLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "model" );
                glUniformMatrix4fv( transformLoc, 1, GL_TRUE, mat[0].ptr );

                GLint modulateLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "modulateColor" );
                glUniform4fv( modulateLoc, 1, modulate.getAsRGBANormalized().ptr );
            }
        glBindVertexArray( VAO ); //Bind VAO
            glBindTexture( GL_TEXTURE_2D, textureID ); //Bind used texture
            glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast( GLvoid* )0 );
            glBindTexture( GL_TEXTURE_2D, 0 );
        glBindVertexArray( 0 );
    }

    override void drawTextureByRect2D( CTexture texture, SRect rect, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null ) {
        GLuint textureID = texture.extData.as!GLuint;

        bindShader( mainShader ); //Bind main draw shader
            SMat4F mat = SMat4F.identity();
            mat.scale( SVec3F( rect.width, rect.height, 0.0f ) );

            mat.translate( SVec3F( -0.5f * rect.width, -0.5f * rect.height, 0.0f ) );
            mat.rotateZ( angle );
            mat.translate( SVec3F( 0.5f * rect.width, 0.5f * rect.height, 0.0f ) );

            mat.translate( SVec3F( rect.pos.x, rect.pos.y, 0.0f ) );

            if ( mainShader !is null ) {
                GLint transformLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "model" );
                glUniformMatrix4fv( transformLoc, 1, GL_TRUE, mat[0].ptr );

                GLint modulateLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "modulateColor" );
                glUniform4fv( modulateLoc, 1, modulate.getAsRGBANormalized().ptr );
            }
        glBindVertexArray( VAO ); //Bind VAO
            glBindTexture( GL_TEXTURE_2D, textureID ); //Bind used texture
            glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast( GLvoid* )0 );
            glBindTexture( GL_TEXTURE_2D, 0 );
        glBindVertexArray( 0 );
    }

    override void drawText( string text, SVec2I pos, SColor4 color ) {
        if ( textFont is null ) {
            log.info( "TTF_Error: " ~ to!string( TTF_GetError() ) );
            return;
        }

        ubyte[4] col = color.getAsRGBA();
        SDL_Color resColor = { col[0], col[1], col[2], col[3] };
        SDL_Surface* surfaceMessage = TTF_RenderText_Blended( textFont, toStringz( text ), resColor );

        GLuint textureID;

        glGenTextures( 1, &textureID );
        glBindTexture( GL_TEXTURE_2D, textureID );

        int mode = GL_RGB;
        if ( surfaceMessage.format.BytesPerPixel == 4 ) {
            mode = GL_RGBA;
        }

        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            mode,
            surfaceMessage.w,
            surfaceMessage.h,
            0,
            mode,
            GL_UNSIGNED_BYTE,
            surfaceMessage.pixels
        );

        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glBindTexture( GL_TEXTURE_2D, 0 );

        bindShader( mainShader ); //Bind main draw shader

        SMat4F mat = SMat4F.identity();
        mat.scale( SVec3F( surfaceMessage.w, surfaceMessage.h, 0.0f ) );
        mat.translate( SVec3F( pos.x, pos.y, 0.0f ) );

        if ( mainShader !is null ) {
            GLint projLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "projection" );
            glUniformMatrix4fv( projLoc, 1, GL_TRUE, 
                SMat4F.identity().ortho( 
                    0.0f, 
                    confGeti( "engine/app/window/width" ), 
                    confGeti( "engine/app/window/height" ), 
                    0.0f, 
                    -1.0f, 
                    1.0f 
                )[0].ptr );

            GLint transformLoc = glGetUniformLocation( mainShader.extData.as!GLuint, "model" );
            glUniformMatrix4fv( transformLoc, 1, GL_TRUE, mat[0].ptr );
        }
        glBindVertexArray( VAO ); //Bind VAO
            glBindTexture( GL_TEXTURE_2D, textureID ); //Bind used texture
            glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, null );
            glBindTexture( GL_TEXTURE_2D, 0 );
        glBindVertexArray( 0 );
        bindShader( null );

        glDeleteTextures( 1, &textureID );
        SDL_FreeSurface( surfaceMessage );
    }

    override void drawLine2D( SVec2F start, SVec2F end, INodeCamera camera ) {
        GLfloat[] _pos = [];
        if ( camera )  {
            _pos = [
                start.x - camera.getPos().x, start.y - camera.getPos().y, 0.0f,
                end.x - camera.getPos().x, end.y - camera.getPos().y, 0.0f,
                start.x - camera.getPos().x, start.y - camera.getPos().y, 0.0f,
            ];
        } else {
            _pos = [
                start.x, start.y, 0.0f,
                end.x, end.y, 0.0f,
                start.x, start.y, 0.0f,
            ];
        }

        SMat4F mat = SMat4F.identity();
        mat.scale( SVec3F( 1, 1, 0.0f ) );
        mat.translate( SVec3F( 0, 0, 0.0f ) );

        bindShader( lineShader );
        GLint projLoc = glGetUniformLocation( lineShader.extData.as!GLuint, "projection" );
            glUniformMatrix4fv( projLoc, 1, GL_TRUE, 
                SMat4F.identity().ortho( 
                    0.0f, 
                    confGeti( "engine/app/window/width" ), 
                    confGeti( "engine/app/window/height" ), 
                    0.0f, 
                    -1.0f, 
                    1.0f 
                )[0].ptr );

        GLint transformLoc = glGetUniformLocation( lineShader.extData.as!GLuint, "model" );
        glUniformMatrix4fv( transformLoc, 1, GL_TRUE, mat[0].ptr );


        glBindBuffer( GL_ARRAY_BUFFER, lineVBO );
            glBufferData( GL_ARRAY_BUFFER, _pos.length * float.sizeof, _pos.ptr, GL_DYNAMIC_DRAW );
        glBindBuffer( GL_ARRAY_BUFFER, 0 );
        glBindVertexArray( lineVAO );
            glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
            glDrawArrays( GL_TRIANGLES, 0, 3 );
            glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
        glBindVertexArray( 0 );
    }

    override void drawPoint2D( SVec2F pos, float radius, INodeCamera camera ) {

    }

    override void genMeshData( CMesh mesh ) {
        CMeshExtData extData = new CMeshExtData();

        glGenVertexArrays( 1, &extData.VAO );
        glGenBuffers( 1, &extData.VBO );
        glGenBuffers( 1, &extData.EBO );
        
        glBindVertexArray( extData.VAO );
        glBindBuffer( GL_ARRAY_BUFFER, extData.VBO );
            if ( mesh.type == EMeshType.MT_STATIC ) {
                glBufferData( GL_ARRAY_BUFFER, mesh.vertices.length * SVertex.sizeof, &mesh.vertices[0], GL_STATIC_DRAW );
            } else {
                glBufferData( GL_ARRAY_BUFFER, mesh.vertices.length * SVertex.sizeof, &mesh.vertices[0], GL_DYNAMIC_DRAW );
            }

            glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, extData.EBO );
            if ( mesh.type == EMeshType.MT_STATIC ) {
                glBufferData( GL_ELEMENT_ARRAY_BUFFER, mesh.indices.length * uint.sizeof, &mesh.indices[0], GL_STATIC_DRAW ); 
            } else {
                glBufferData( GL_ELEMENT_ARRAY_BUFFER, mesh.indices.length * uint.sizeof, &mesh.indices[0], GL_DYNAMIC_DRAW ); 
            }

            glEnableVertexAttribArray( 0 );
            glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, SVertex.sizeof, cast( GLvoid* )0 );
            glEnableVertexAttribArray( 1 );
            glVertexAttribPointer( 1, 3, GL_FLOAT, GL_FALSE, SVertex.sizeof, cast( GLvoid* )SVertex.normal.offsetof );
            glEnableVertexAttribArray( 2 );
            glVertexAttribPointer( 2, 2, GL_FLOAT, GL_FALSE, SVertex.sizeof, cast( GLvoid* )SVertex.texCoords.offsetof );
        glBindVertexArray( 0 );

        mesh.extData = extData;
    }

    override void destroyMeshData( CMesh mesh ) {
        CMeshExtData extData = cast( CMeshExtData )mesh.extData;

        if ( !extData ) {
            return;
        }

        glDeleteBuffers( 1, &extData.VBO );
        glDeleteBuffers( 1, &extData.EBO );
        glDeleteVertexArrays( 1, &extData.VAO );

        extData.destroy();
    }

    override void setDrawColor( SColor4 color ) {

    }

    override void compileShader( CShader shader ) {
        GLuint sVert;
        GLuint sFrag;

        sVert = glCreateShader( GL_VERTEX_SHADER );
        sFrag = glCreateShader( GL_FRAGMENT_SHADER );

        if ( shader.vertex.code != "" ) {
            if ( !locCompileShader( shader.vertex.code, shader.vertex.path, sVert ) ) {
                glDeleteShader( sVert );
                glDeleteShader( sFrag );
                shader.loadPhase = EResourceLoadPhase.RLP_FAILED;
            }
        }

        if ( shader.fragment.code != "" ) {
            if ( !locCompileShader( shader.fragment.code, shader.fragment.path, sFrag ) ) {
                glDeleteShader( sVert );
                glDeleteShader( sFrag );
                shader.loadPhase = EResourceLoadPhase.RLP_FAILED;
            }
        }

        GLuint program = glCreateProgram();
        glAttachShader( program, sVert );
        glAttachShader( program, sFrag );
        glLinkProgram( program );

        glDeleteShader( sVert );
        glDeleteShader( sFrag );

        GLint linked;
        glGetProgramiv( program, GL_LINK_STATUS, &linked );
        if ( linked == GL_FALSE ) {
            shader.loadPhase = EResourceLoadPhase.RLP_FAILED;
            log.error( "Could not link shader program" );
        }

        shader.extData = program;
        shader.bCompiled = true;
        shader.loadPhase = EResourceLoadPhase.RLP_SUCCES;

        log.info( "Shader compiled: " ~ "\n\t" ~ shader.vertex.path ~ "\n\t" ~ shader.fragment.path );
    }

    override void bindShader( CShader shader ) {
        if ( !checkResValid( shader ) ) {
            glUseProgram( 0 );
            return;
        }

        glUseProgram( shader.extData.as!GLuint );
    }

    override void genRenderTarget( CRenderTarget rt ) {
        GLuint rtName = 0;
        glGenFramebuffers( 1, &rtName );
        glBindFramebuffer( GL_FRAMEBUFFER, rtName );

            GLuint renderTexture;
            glGenTextures( 1, &renderTexture );
                glBindTexture( GL_TEXTURE_2D, renderTexture );
                glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, rt.width, rt.height, 0, GL_RGB, GL_UNSIGNED_INT, cast( const( void )* )0 );
                glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
                glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
            glBindTexture( GL_TEXTURE_2D, 0 );

            glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderTexture, 0 );

        glBindFramebuffer( GL_FRAMEBUFFER, 0 );

        rt.extData = [rtName, renderTexture];
    }

    override void destroyRenderTarget( CRenderTarget rt ) {
        GLuint[2] extData = rt.extData.as!( GLuint[2] );
        glDeleteFramebuffers( 1, &extData[0] );
        rt.extData = extData;
    }

    override void bindRenderTarget( CRenderTarget rt ) {
        if ( rt ) {
            if ( rt.extData.isNull() ) {
                throw new Exception( "Trying to bind none generated render target" );
            }

            glBindFramebuffer( GL_FRAMEBUFFER, ( rt.extData.as!( GLuint[2] ) )[0] );
        } else {
            glBindFramebuffer( GL_FRAMEBUFFER, 0 );
        }
    }

private:
    /**
        Compile single shader from code
        Params:
            code - shader code
            path - file path, only for error information
            shader - result shader code
    */
    bool locCompileShader( string code, string path, GLuint shader ) {
        int len = cast( int )code.length;
        const( char* ) src = toStringz( code );
        glShaderSource( shader, 1, &src, &len );
        glCompileShader( shader );

        GLint status;
        glGetShaderiv( shader, GL_COMPILE_STATUS, &status );

        //Print error, if something went wrong
        if ( status == GL_FALSE ) {
            int infoLogLength;
            glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &infoLogLength );
            char* infoLog = cast( char* )malloc( ( char* ).sizeof * infoLogLength );
            glGetShaderInfoLog( shader, infoLogLength, &infoLogLength, infoLog );
            log.error( "Could not compile shader: " ~ path ~ "\n", to!string( infoLog ) );
            free( infoLog );
            return false;
        }

        return true;
    }
}