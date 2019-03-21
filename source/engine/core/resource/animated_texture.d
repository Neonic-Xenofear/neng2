module engine.core.resource.animated_texture;

import engine.core.engine.engine;
import engine.core.resource.texture;
import engine.core.engine.timer;
import engine.core.utils.signal;

/*
alias CTextureArray = CTexture[];

class CFrames {
private:
    CTextureArray frames;

public:
    bool bLoop = false;
    float speed = 1.0f;

    void addFrame( CTexture frame ) {
        if ( frame !is null ) {
            frames ~= frame;
        }
    }

    void addFrame( string path ) {
        addFrame( loadTexture( path ) );
    }
}
*/
@RegisterResource( "AnimatedTexture" )
@ResourceLoadType( EResourceLoadingType.RLT_ASYNC )
class CAnimatedTexture : AResource {
    mixin( TResourceRegister!() );
    
    bool bPlay = false;
    bool bLoop = false;
    float speed = 1.0f;

    CTexture[] frames;
    uint currentFrame = 0;

    CTimer timer;

    SSignal!( CTexture ) onFrameUpdated;

    this() {
        timer = new CTimer();
        timer.setup( speed, &frameUpdate );
    }

    ~this() {
        timer.stop();
        timer.destroy();
        onFrameUpdated.disconnectAll();
    }

    void play() {
        frameUpdate();
    }

    void addFrame( CTexture frame ) {
        if ( frame !is null ) {
            frames ~= frame;
        }
    }

    /*void addFrame( string path ) {
        addFrame( loadTexture( path ) );
    }*/

    void update() {
        timer.update();
    }

    CTexture getCurrentFrame() {
        if ( currentFrame < frames.length ) {
            return frames[currentFrame];
        }

        return null;
    }

private:
    void frameUpdate() {
        if ( currentFrame + 1 > frames.length - 1 ) {
            if ( bLoop ) {
                currentFrame = 0;
                frameNext();
            }
        } else {
            currentFrame += 1;
            frameNext();
        }
    }

    void frameNext() {
        onFrameUpdated.emit( frames[currentFrame] );
        timer.start();
    }
}