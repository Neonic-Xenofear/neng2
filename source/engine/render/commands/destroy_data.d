module engine.render.commands.destroy_data;

import engine.core.utils.envelope;
import engine.core.resource.texture;

struct SRenderDestroyData {
    SEnvelope!CTexture texture;
}