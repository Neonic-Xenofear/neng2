module engine.render.commands.draw_texture2d;

import engine.core.math;
public import engine.core.utils.envelope;
import engine.core.resource.texture;
import engine.scene.base;

struct SRenderDrawTexture2D {
    SEnvelope!CTexture texture;
    SVec2F pos;
    SVec2F size;
    float angle;
    SColor4 modulate = SColor4.white;
    SEnvelope!INodeCamera camera = null;
}