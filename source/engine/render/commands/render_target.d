module engine.render.commands.render_target;

import engine.render.buffer.render_target;
import engine.core.utils.envelope;

struct SRenderGenRenderTarget {
    SEnvelope!CRenderTarget rt;
}

struct SRenderDestroyRenderTarget {
    SEnvelope!CRenderTarget rt;
}

struct SRenderDestroyRenderTargetEnd {}

struct SRenderBindRenderTarget {
    SEnvelope!CRenderTarget rt;
}