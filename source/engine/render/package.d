module engine.render;

public:
import engine.render.render;
import engine.render.render_thread;
import engine.render.commands;
import engine.render.shader;

import engine.core.mod.register_module;

class CRenderModule : ARegisterModule {
    CShaderLoader loader;
    void onLoad( CEngine engine ) {
        loader = new CShaderLoader();
        engine.resourceManager.registerResourceLoader!CShader( loader );
    }

    void onUnload( CEngine engine ) {
    }
}