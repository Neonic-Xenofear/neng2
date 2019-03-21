module engine.app.window;

import engine.core.math.aabb;
import engine.core.engine.engine;
import engine.core.utils.array;
import engine.core.utils.signal;

enum ERenderContext {
    RC_OPENGL,
    RC_VULCAN,
    RC_DIRECTX,
    RC_PROGRAM,
}

class CWindow {
protected:
    bool bVSync = false;
    int width;
    int height;
    float aspRatio = -1;

    string title;

public:
    SSignal!( int, int ) onResized;

    ~this() {
        onResized.disconnectAll();
    }

    void setup( string name, int iWidth, int iHeight ) {        
        setupImpl( name, iWidth, iHeight );
        resize( iWidth, iHeight );
    }

    void resize( int iWidth, int iHeight ) {
        width = iWidth;
        height = iHeight;
        aspRatio = cast( float )width / height;

        getConfig()
            .set( "engine/app/window/width", width )
            .set( "engine/app/window/height", height )
            .set( "engine/app/window/aspRatio", aspRatio );
        
        resizeImpl( width, height );
        onResized.emit( width, height );
    }

    void setTitle( string newTitle ) {
        title = newTitle;
        confSet( "engine/app/window/title", title );
        setTitleImpl( title );
    }

    abstract void close();
    abstract void swapBuffers();
    abstract void* createRenderContext( ERenderContext renderContext );

    abstract void setVSync( bool bVal );

protected:
    abstract void setupImpl( string name, int width, int height );
    abstract void setTitleImpl( string newTitle );
    abstract void resizeImpl( int iWidth, int iHeight );
}