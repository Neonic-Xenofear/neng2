/**
    Standart supported resource types
*/
module engine.resources;

public:
import engine.resources.sdlang;
import engine.resources.mesh;

import engine.core.mod.register_module;

class CResourcesModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        getResourceManager().registerResourceLoader!CMesh( new CMeshLoader() );
    }

    void onUnload( CEngine engine ) {
    }
}