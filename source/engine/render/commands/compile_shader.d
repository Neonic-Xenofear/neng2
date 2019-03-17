module engine.render.commands.compile_shader;

import engine.core.utils.envelope;
import engine.render.shader;

struct SRenderCompileShader {
    SEnvelope!CShader shader;
}