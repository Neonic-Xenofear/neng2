module engine.core.engine.config;

import std.conv;
import std.variant;

enum CONFIG_PATH_DECL = "(__path)";

class CConfig {
private:
    string[string] data;
    Variant[string] variantData;

public:
    string[string] getData() {
        return data;
    }

    void setData( string[string] newData ) {
        data = newData;
    }

    CConfig set( const string name, const string val ) {
        import std.string : replace, startsWith;
        import engine.core.utils.path : appExePathAndNorm;

        //Process file path declarations
        if ( val.replace( " ", "" ).startsWith( CONFIG_PATH_DECL ) ) {
            string subVal = val;
            
            subVal = subVal.replace( CONFIG_PATH_DECL, "" );
            data[name] = appExePathAndNorm( subVal );

            return this;
        }

        data[name] = val;
        return this;
    }

    CConfig set( const string name, const int val ) {
        set( name, to!string( val ) );
        return this;
    }

    CConfig set( const string name, const bool val ) {
        set( name, to!string( val ) );
        return this;
    }

    CConfig set( const string name, const float val ) {
        set( name, to!string( val ) );
        return this;
    }

    string gets( const string name ) {
        if ( string* res = name in data ) {
            return *res;
        }

        return "";
    }

    int geti( const string name ) {
        if ( string* res = name in data ) {
            return to!int( *res );
        }

        return int.min;
    }

    bool getb( const string name ) {
        if ( string* res = name in data ) {
            return to!bool( *res );
        }

        return false;
    }

    float getf( const string name ) {
        if ( string* res = name in data ) {
            return to!float( *res );
        }

        return float.min_normal;
    }


    //Variant values process
    CConfig setV( T )( const string name, T val ) {
        variantData[name] = Variant( val );
        return this;
    }

    Variant getV( const string name ) {
        if ( Variant* res = name in variantData ) {
            return *res;
        }

        return Variant( null );
    }
}