module engine.render.commands.draw_texture_rect2d;

import engine.core.math;
public import engine.core.utils.envelope;
import engine.core.resource.texture;
import engine.scene.base;

struct SRenderDrawTextureByRect2D {
    SEnvelope!CTexture texture;
    SRect rect;
    float angle;
    SColor4 modulate = SColor4.white;
    SEnvelope!INodeCamera camera = null;
}