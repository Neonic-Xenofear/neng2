module modules.png;

public:
import modules.png.png;

import engine.core.mod.register_module;

class CPNGLoaderModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        import engine.core.resource.texture;
        registerTextureLoader!CPNGLoader();
    }

    void onUnload( CEngine engine ) {

    }
}