module engine.render.render_thread;

import std.concurrency;
import std.exception;

import engine.render;

/**
    Used to infomate main thread
    thah the rendering has ended.
*/
struct SRenderingEnd {}


/**
    Informate about init end.
*/
struct SRenderInitEnd {}

/**
    Basic realization of render "mailbox".
    Params:
        ownerId - id of main thread.
*/
void basicRenderFunc( Tid ownerId ) {
    bool bWork = true;
    ARender render;

    while( bWork ) {
        receive(
        ( SRenderInitThread com ) {
            render = CModuleManager.get().getModule!ARender( com.renderModuleName );
            log.info( "Render thread initialized" );
            send( ownerId, SRenderInitEnd() );
        },
        ( SRenderClearScreen com ) {
            render.clearScreen();
        },
        ( SRenderRenderEnd com ) {
            render.renderEnd();
            send( ownerId, SRenderingEnd() );
        },
        ( SRenderGenerateData com ) {
            render.genTextureData( com.texture.get() );
        },
        ( SRenderDestroyData com ) {
            render.destroyTextureData( com.texture.get() );
            send( ownerId, SRenderDestroyDataEnd() );
        },
        ( SRenderCompileShader com ) {
            render.compileShader( com.shader.get() );
        },
        ( SRenderDrawText com ) {
            render.drawText( com.text, com.pos, com.color );
        },
        ( SRenderDrawTexture2D com ) {
            render.drawTexture2D( com.texture.get(), com.pos, com.size, com.angle, com.modulate, com.camera.get() );
        },
        ( SRenderDrawTextureByRect2D com ) {
            render.drawTextureByRect2D( com.texture.get(), com.rect, com.angle, com.modulate, com.camera.get() );
        },
        ( SRenderDrawLine2D com ) {
            render.drawLine2D( com.begin, com.end );
        },

        /*   3D RENDER   */
        ( SRenderGenMeshData com ) {
            render.genMeshData( com.mesh.get() );
        },
        ( SRenderDestroyMeshData com ) {
            render.destroyMeshData( com.mesh.get() );
            send( ownerId, SRenderDestroyMeshDataEnd() );
        },

        ( SRenderShutdown com ) {
            bWork = false;
            CModuleManager.get().removeModule( render );
            render.destroy();
            log.info( "Render thread shutdowned" );
            send( ownerId, SRenderingEnd() );
        }
        );
    }
}

/**
    Rendering thread
*/
class CRenderThread {
protected:
    Tid threadId; ///Rendering thread ID
    string associateName; ///Name, used for threads registry

public:
    /**
        Initize render thread.
        Params:
            renderModuleName - rendering module name.
            iName - name in thread registry.
    */
    void startThread( string renderModuleName, string iName ) {
        threadId = spawn( &basicRenderFunc, thisTid );
        associateName = iName;

        register( associateName, threadId );
        send( SRenderInitThread( renderModuleName ) );
        waitUntil!SRenderInitEnd;
    }

    /**
        Suspends the main thread until the render 
        reports completion.
    */
    void waitUntilRenderEnd() {
        waitUntil!SRenderingEnd;
    }

    /**
        Wait for event.
        Returns:
            Result of receive
    */
    auto waitUntil( T )() {
        return receiveOnly!T;
    }

    /**
        Shutdown rendering thread and stop main 
        thread until render end work.
    */
    void endThread() {
        getEngine().window.close();
        send( SRenderShutdown() );
        waitUntilRenderEnd(); //Allow thread end work

        unregister( associateName );
    }

    /**
        Send message to thread.
        Params:
            message - send message
    */
    void send( T )( T message ) {
        std.concurrency.send( threadId, message );
    }
}


/**
    Mutltithreaded render
*/
class CMTRender : ARender {
    CRenderThread thread;

    @property
    SModuleInfo info() {
        return SModuleInfo(
            "MULTITHREADED_RENDER",
            "NENG2_CORE", 
            "1.0"
        );
    }

    void onLoad( CEngine engine ) {}
    void onUnload( CEngine engine ) {}
    void update( float delta ) {}

    this() {
        thread = new CRenderThread();
        thread.startThread(
            confGets( "engine/modules/render" ), 
            confGets( "engine/modules/render/thread/name" )
        );
    }

    ~this() {
        thread.endThread();
    }

    override void clearScreen() {
        thread.send( SRenderClearScreen() );
    }

    override void renderEnd() {
        thread.send( SRenderRenderEnd() );
        thread.waitUntilRenderEnd();
    }

    override void genTextureData( CTexture texture ) {
        thread.send( SRenderGenerateData( SEnvelope!CTexture( texture ) ) );
    }

    override void destroyTextureData( CTexture texture ) {
        thread.send( SRenderDestroyData( SEnvelope!CTexture( texture ) ) );
        thread.waitUntil!SRenderDestroyDataEnd(); //Wait until data destroyed, it may take time
    }

    override void genMeshData( CMesh mesh ) {
        thread.send( SRenderGenMeshData( SEnvelope!CMesh( mesh ) ) );
    }

    override void destroyMeshData( CMesh mesh ) {
        thread.send( SRenderDestroyMeshData( SEnvelope!CMesh( mesh ) ) );
        thread.waitUntil!SRenderDestroyMeshDataEnd();
    }

    override void drawTexture2D( CTexture texture, SVec2F pos, SVec2F size, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null ) {
        thread.send( 
            SRenderDrawTexture2D( 
                SEnvelope!CTexture( texture ), 
                pos, 
                size, 
                angle, 
                modulate,
                SEnvelope!INodeCamera( camera ) 
            ) 
        );
    }

    override void drawTextureByRect2D( CTexture texture, SRect rect, float angle, SColor4 modulate = SColor4.white, INodeCamera camera = null ) {
        thread.send( 
            SRenderDrawTextureByRect2D( 
                SEnvelope!CTexture( texture ), 
                rect,
                angle, 
                modulate,
                SEnvelope!INodeCamera( camera ) 
            ) 
        );
    }

    override void drawText( string text, SVec2I pos = SVec2I( 0, 0 ), SColor4 color = SColor4.white ) {
        thread.send( SRenderDrawText( text, pos, color ) );
    }

    override void drawLine2D( SVec2F start, SVec2F end, INodeCamera camera = null ) {
        thread.send( SRenderDrawLine2D( start, end ) );
    }

    override void drawPoint2D( SVec2F pos, float radius, INodeCamera camera = null ) {

    }

    override void setDrawColor( SColor4 color ) {

    }

    override void compileShader( CShader shader ) {
        thread.send( SRenderCompileShader( SEnvelope!CShader( shader ) ) );
    }

    override void bindShader( CShader shader ) {
        
    }
}