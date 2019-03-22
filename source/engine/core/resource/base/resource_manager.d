module engine.core.resource.base.resource_manager;

import engine.core.engine : getVFS;
import engine.app.logger;
import engine.core.multithreading;
import engine.core.serialize;
import engine.core.resource.base.resource;
import engine.core.resource.base.resource_loader;
import engine.core.utils.array : removeElement;

///Meta file append extension
enum FILE_META_EXT = ".meta";

class CResourceManager {
private:
    AResource[] resources;
    IResourceLoader[string] loaders;

public:
    ~this() {
        foreach ( res; resources ) {
            res.destroy();
        }

        foreach ( loader; loaders ) {
            loader.destroy();
        }
    }

    void registerResourceLoader( T )( IResourceLoader loader )
    if ( is( T : AResource ) ) {
        string loadType = getResourceClassType!T;
        if ( IResourceLoader* rl = loadType in loaders ) {
            log.error( "Resource loader type already registered: " ~ loadType );
            return;
        }

        loaders[loadType] = loader;
    }

    IResourceLoader getResourceLoader( T )()
    if ( is( T : AResource ) ) {
        if ( IResourceLoader* loader = getResourceClassType!T in loaders ) {
            return *loader;
        }

        return null;
    }

    T loadResource( T )( string path, bool bGenMeta = true )
    if ( is( T : AResource ) ) {
        if ( containsResource( path ) ) {
            return getResource!T( path );
        }

        //Try to load resource info from meta file
        AFile metaFile = getVFS().getMountedDir( "cache" ).getFile( path ~ FILE_META_EXT, false );
        if ( metaFile ) {
            T nRes = deserializeResourceMeta!T( cast( string )metaFile.readRawData() );
            loadResource( nRes, path );
            return nRes;
        }

        if ( IResourceLoader* resLoader = getResourceClassType!T in loaders ) {
            T nRes = new T();
            nRes.loadPhase = EResourceLoadPhase.RLP_LOADING;

            //Check if resource allow load on fiber
            static if ( allowAsyncLoad!T ) {
                SFiberManager.startFiber( {
                    resLoader.loadByPath( nRes, path );
                    if ( nRes.isValidRaw() ) {
                        addResource( nRes );
                        if ( bGenMeta ) {
                            genMetaFile( nRes );
                        }
                    }
                } );
            } else {
                resLoader.loadByPath( nRes, path );
                if ( nRes.isValidRaw() ) {
                    addResource( nRes );
                    if ( bGenMeta ) {
                        genMetaFile( nRes );
                    }
                }
            }

            return nRes;
        }

        return null;
    }

    void loadResource( T )( T resource, string path )
    if ( is( T : AResource ) ) {
        if ( IResourceLoader* resLoader = getResourceClassType!T in loaders ) {
            resource.loadPhase = EResourceLoadPhase.RLP_LOADING;

            static if ( allowAsyncLoad!T ) {
                SFiberManager.startFiber( {
                    resLoader.loadByPath( resource, path );
                    if ( resource.isValidRaw() ) {
                        addResource( resource );
                        genMetaFile( resource );
                    }
                } );
            } else {
                resLoader.loadByPath( resource, path );
                if ( resource.isValidRaw() ) {
                    addResource( resource );
                    genMetaFile( resource );
                }
            }
        }
    }

    T getResource( T )( string path )
    if ( is( T : AResource ) ) {
        foreach ( res; resources ) {
            if ( res.path == path ) {
                return cast( T )res;
            }
        }

        return null;
    }

    void removeResource( string path ) {
        foreach ( r; resources ) {
            if ( r.path == path ) {
                resources.removeElement( r );
                return;
            }
        }
    }

    void removeResource( AResource res ) {
        removeResource( res.path );
    }

    void addResource( AResource resource ) {
        if ( !containsResource( resource ) ) {
            resources ~= resource;
        }
    }

    bool containsResource( string path ) {
        return canFind!"a.path == b"( resources, path );
    }

    bool containsResource( AResource res ) {
        return canFind( resources, res );
    }

    string serializeResourceMeta( AResource res ) {
        SSerializer serial;
        res.serialize( serial );
        return serial.toString();
    }

private:
    string getResourceClassType( T )()
    if ( is( T : AResource ) ) {
        import engine.core.utils.uda : hasUDA, getUDA;

        enum hasResUDA = hasUDA!( T, RegisterResource );

        static assert( hasResUDA, "Trying to load unregistered resource type: " ~ t.stringof );

        return getUDA!( T, RegisterResource ).resTypeName;
    }

    static bool allowAsyncLoad( T )() {
        import engine.core.utils.uda : hasUDA, getUDA;
        enum hasLoadUDA = hasUDA!( T, ResourceLoadType );
        static if ( hasLoadUDA ) {
            return getUDA!( T, ResourceLoadType ).type == EResourceLoadingType.RLT_ASYNC;
        } else {
            return false;
        }
    }

    void genMetaFile( AResource resource ) {
        getVFS().getMountedDir( "cache" )
            .getOrMakeFile( resource.path ~ FILE_META_EXT )
            .writeRawData( cast( ubyte[] )serializeResourceMeta( resource ) );
    }

    T deserializeResourceMeta( T )( string metaStr ) {
        SDeserializer d = SDeserializer( metaStr );
        return d.deserializeFirst!T();
    }
}