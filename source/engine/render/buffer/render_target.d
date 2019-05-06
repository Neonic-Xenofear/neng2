module engine.render.buffer.render_target;

import engine.core.ext_data;
import engine.core.object;

protected import engine.core.engine.engine : getRender;

class CRenderTarget : AObject {
    mixin( TRegisterObject!() );
public:
    CExtData extData;

    uint width;
    uint height;

    this( uint iWidth, uint iHeight ) {
        import engine.core.engine.engine : getRender;

        extData = new CExtData();

        width = iWidth;
        height = iHeight;
    
        getRender().genRenderTarget( this );
    }

    ~this() {
        getRender().destroyRenderTarget( this );
    }

    void bind() {
        getRender().bindRenderTarget( this );
    }

    void unbind() {
        getRender.bindRenderTarget( null );
    }
}