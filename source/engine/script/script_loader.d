module engine.script.script_loader;

import engine.core.resource;
import engine.script;

class CScriptLoader : IResourceLoader {
    void loadByPath( AResource resource, string path ) {
        import engine.core.engine.engine : getVFS, getEngine;
        CScript scr = cast( CScript )resource;

        if ( !scr ) {
            log.error( "Invalid input resource type!" );
            return;
        }

        AFile file = getVFS().getFile( path );

        if ( file is null ) {
            log.info( "Trying to load null file!" );
            return;
        }
        scr.path = path;
        getEngine().scriptManager.processFile( file );

        resource.loadPhase = EResourceLoadPhase.RLP_SUCCES;
    }
}

CScript loadScript( string path ) {
    import engine.core.engine.engine : getResourceManager;
    return getResourceManager().loadResource!CScript( path );
}