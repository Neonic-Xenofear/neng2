module engine.render.commands.gen_data;

import engine.core.utils.envelope;
import engine.core.resource.texture;

struct SRenderGenerateData {
    SEnvelope!CTexture texture;
}

struct SRenderGenerateDataEnd {}