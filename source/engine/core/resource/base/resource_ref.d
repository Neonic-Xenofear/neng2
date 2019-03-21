module engine.core.resource.base.resource_ref;

import engine.core.resource.base.resource;
import engine.core.serialize;
import engine.core.engine;
import engine.core.utils.signal;

/**
    Used for serialize resources on scene,
    by meta file path
*/
struct SResRef( T )
if ( is( T : AResource ) ) {
protected:
    string metaFilePath;

public:
    T resource; ///Resource instance
    alias resource this;

    SSignal!() onDeserialized;

    this( T res ) {
        resource = res;
    }

    ~this() {}

    void opAssign( T res ) {
        resource = res;
    }

    T get() {
        return resource;
    }

    string serializeToString() {
        if ( !resource ) {
            return "";
        }

        if ( metaFilePath != "" ) {
            return metaFilePath;
        } else {
            import engine.core.resource.base.resource_manager;

            getVFS().getMountedDir( "cache" ).getOrMakeFile( resource.path ~ FILE_META_EXT ).writeRawData(
                cast( ubyte[] )getResourceManager.serializeResourceMeta( resource )
            );


            return resource.path ~ FILE_META_EXT;
        }
    }

    void deserializeFromString( string serializeStr ) {
        import engine.app.logger : log;

        //Null resource ignore
        if ( serializeStr == "" ) {
            return;
        }

        metaFilePath = serializeStr;
        AFile file = getVFS().getFile( metaFilePath, "cache" );
        if ( !file ) {
            log.error( "Invalid meta resource file path: " ~ serializeStr );
            return;
        }

        SDeserializer des = SDeserializer( cast( string )file.readRawData() );
        resource = new T();
        resource.deserialize( des, des.content.all.tags.front.attributes["id"][0].value.get!string );
        getResourceManager().loadResource( resource, resource.path );

        onDeserialized.emit();
        onDeserialized.disconnectAll();
    }

    /**
        Validate resource ref
    */
    bool isValidRef() {
        return resource !is null;
    }
}

/**
    Check some type is resource ref
    Params:
        S - check type
*/
template isResRef( alias S ) {
    void check( alias T )( SResRef!T val ) { }
    enum isResRef = __traits( compiles, check( S ) );
}