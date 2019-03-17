module engine.framework.console.cvar;

import std.variant;

class CVar {
protected:
    string name;
    string description;
    Variant value;
    bool bEditable = true;

public:
    this( T )( string iName, string iDesrc, T iVal, bool bEdit ) {
        name = iName;
        description = iDesrc;
        value = iVal;
        bEditable = bEdit;
    }

    void set( T )( T data ) {
        if ( bEditable ) {
            value = data;
        } else {
            log.error( "CVar is not editable: " ~ name );
        }
    }

    T get( T )() {
        return value.get!T;
    }

    @nogc
    string getName() const {
        return name;
    }

    @nogc
    string getDescription() const {
        return description;
    }

    override string toString() {
        import std.conv : to;

        return  "\nCVar: " ~ name ~ "\n" ~
                "\tDescription: " ~ description ~ "\n" ~
                "\tValue: " ~ get!string ~ "\n" ~
                "\tEditable: " ~ to!string( bEditable );
    }
}