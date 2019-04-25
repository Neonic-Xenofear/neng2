module modules.platform.sdl.window;

import std.string;
import std.conv : to;

import derelict.opengl;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import engine.app.window;
import engine.core.engine.engine;

import engine.core.utils;
class CSDLWindow : CWindow {
    SDL_Window* appWin;

protected:
    override void setupImpl( string name, int iWidth, int iHeight ) {
        //Load all lib's
        version( Windows ) {
            DerelictSDL2.load( appExePathAndNorm( "../../libs/win/SDL2.dll" ) );
            DerelictSDL2Image.load( appExePathAndNorm( "../../libs/win/SDL2_image.dll" ) );
            DerelictSDL2TTF.load( appExePathAndNorm( "../../libs/win/SDL2_ttf.dll" ) );
        } else {
            DerelictSDL2.load( appExePathAndNorm( "../../libs/linux/libSDL2-2.0.so.0.9.0" ) );
            DerelictSDL2Image.load(/* appExePathAndNorm( "../../libs/linux/libSDL2_image-2.0.so.0.2.2" ) */);
            DerelictSDL2TTF.load( appExePathAndNorm( "../../libs/linux/libSDL2_ttf-2.0.so.0.14.1" ) );
        }

        //Init SDL
        if ( SDL_Init( SDL_INIT_VIDEO ) < 0 ) {
            log.error( "SDL_Error:" ~ to!string( SDL_GetError() ) );
            log.error( "Failed to init SDL!" );
            return;
        }

        log.info( "SDL initialized" );

        if ( IMG_Init( IMG_INIT_PNG ) < 0 ) {
            log.error( "IMG_Error:" ~ to!string( IMG_GetError() ) );
            log.error( "Failed to init IMG_ttf!" );
            return;
        }

        log.info( "SDL_img initialized" );

        if ( TTF_Init() != 0 ) {
            log.error( "TTF_Error:" ~ to!string( TTF_GetError() ) );
            log.error( "Failed to init SDL_ttf!" );
            return;
        }

        log.info( "SDL_ttf initialized" );

        appWin = SDL_CreateWindow(
            toStringz( name ),
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            iWidth,
            iHeight,
            SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE
        );

        if ( appWin is null ) {
            log.error( "SDL_CreateWindow: ", SDL_GetError() );
            log.error( "Failed to create window!" );
            return;
        }

        log.info( "Window initialized" );
    }

    override void setTitleImpl( string newTitle ) {
        SDL_SetWindowTitle( appWin, toStringz( newTitle ) );
    }

    override void resizeImpl( int iWidth, int iHeight ) {}

    override void setIcon( AFile file ) {
        if ( !file ) {
            log.error( "Invalid window icon path!" );
            return;
        }
    }

public:
    override void close() {
        SDL_DestroyWindow( appWin );

        DerelictSDL2TTF.unload();
        DerelictSDL2Image.unload();
        DerelictSDL2.unload();
    }

    override void swapBuffers() {
        SDL_GL_SwapWindow( appWin );
    }

    override void* createRenderContext( ERenderContext renderContext ) {
        if ( renderContext == ERenderContext.RC_OPENGL ) {
            SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE ); //OpenGL core profile
            SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 ); //OpenGL 3+
            SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 3 ); //OpenGL 3.3

            SDL_GL_SetSwapInterval( 0 );
            return cast( void* )SDL_GL_CreateContext( appWin );
        }

        return null;
    }

    override void setVSync( bool bVal ) {
        SDL_GL_SetSwapInterval( cast( int )bVal );
    }
}