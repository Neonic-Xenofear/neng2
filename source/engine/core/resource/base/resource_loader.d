module engine.core.resource.base.resource_loader;

import engine.core.resource.base.resource;

/**
    Just interface for all resource loaders
*/
interface IResourceLoader {
    /**
        Load resource from VFS file data
        Params:
            resource - created resource file
            path - VFS file path 
    */
    void loadByPath( AResource resource, string path );
}