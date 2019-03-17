module engine.core.resource;

public:
import engine.core.resource.base;

import engine.core.resource.texture;
import engine.core.resource.animated_texture;

protected import engine.core.mod.register_module;

class CCoreResourcesModule : ARegisterModule {
    CTextureLoader loader;
    void onLoad( CEngine engine ) {
        loader = new CTextureLoader();
        engine.resourceManager.registerResourceLoader!CTexture( loader );
    }

    void onUnload( CEngine engine ) {
        //engine.scriptManager.unregisterClass!ATexture;
    }
}