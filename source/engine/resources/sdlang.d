module engine.resources.sdlang;

public import sdlang;

import engine.app.logger;
import engine.core.resource.base.resource;
import engine.core.engine.config;

@RegisterResource( "SDLang" )
@ResourceLoadType( EResourceLoadingType.RLT_STATIC )
class CSDLang : AResource {
    mixin( TResourceRegister!() );
private:
    Tag root = null;

public:
    void parseFile( AFile iFile ) {
        if ( iFile is null ) {
            return;
        }

        root = parseSource( cast( string )( iFile.readRawData() ) );
    }

    Tag getTag( string name ) {
        return root.getTag( name );
    }

    T getTagValue( T )( string name, T invalidRet ) {
        root.getTagValue!T( name, invalidRet );
        return invalidRet;
    }

    Tag getRootTag() {
        return root;
    }

    CConfig toConfig() {
        assert( root );

        CConfig conf = new CConfig();

        foreach ( tag; root.all.tags ) {
            reqIterateAllTags( tag, "engine", conf );
        }

        return conf;
    }

protected:
    void reqIterateAllTags( Tag tag, string lastPath, CConfig config ) {
        import std.conv : to;

        foreach ( t; tag.all.tags ) {
            if ( t.values.length != 0 ) {
                config.set( lastPath ~ "/" ~ t.name, to!string( t.values[0] ) );
            }

            reqIterateAllTags( t, lastPath ~ "/" ~ t.name, config );
        }
    }
}