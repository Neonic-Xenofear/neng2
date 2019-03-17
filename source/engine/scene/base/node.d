module engine.scene.base.node;

import std.algorithm;
import std.string;

import engine.script.lib;
import engine.core.object;
public import engine.core.serialize;
public import engine.core.input;
import engine.core.engine.engine;
public import engine.scene.base.node_camera;
public import engine.script;

/**
    Node needed for work code
*/
template NODE_REG() {
    import std.string : format;
    import std.conv : to;
    
    enum NODE_REG = 
    TRegisterObject!() ~
    q{
        //Need to override this, because 'typeof( this )' without it always == 'CNode'
        public override void setScript( CScript scr ) {
            import engine.core.utils.uda;
            alias T = typeof( this );
            
            static if ( hasUDA!( T, ScriptExport ) ) {
                if ( !scr.isValidRaw() ) {
                    return;
                }
                
                if ( scr.nativeClassName != typeof( this ).stringof ) {
                    log.error( "Invalid script native class: " ~ scr.nativeClassName ~ " != " ~ typeof( this ).stringof );
                    return;
                }

                script = scr;
                script.initInstance( this );
            }
        }
    };
}

/**
    Base scene node
*/
@ScriptExport( "CNode" )
class CNode : AObject {
    mixin( TRegisterObject!() );
public:
    @Serialize
    bool bVisible = true;
    @Serialize
    string name;

    @Serialize
    CNode parent;
    @Serialize
    CNode[] children;

    SColor4 modulateColor = SColor4.white; 

protected:
    @Serialize
    SResRef!CScript script;

public:
    @ScriptExport( "", MethodType.ctor )
    this() {
        script.onDeserialized.connect( &onScriptDeserialized );
    }

    this( CNode parent ) {
        parent.addChild( this );
    }

    /**
        Please implement onDestroy instead of destructor
    */
    final ~this() {
        //Clear this branch of the scene tree
        destroyAllChildren();
        onDestroy();
    }

    /**
        Called when node enter tree
    */
    void onEnterTree() {}

    /**
        Called every tick
        Params:
            delta - delta time
    */
    void onUpdate( float delta ) {}

    /**
        Draw node instruction
        Params:
            camera - current camera
    */
    void onDraw( INodeCamera camera ) {}

    /**
        Called when input changed
        Params:
            event - input info
    */
    void onInput( SInputEvent event ) {}

    /**
        Implements instead of destructor
    */
    void onDestroy() {}

    /**
        Update current node and children
        Params:
            delta - delta time
    */
    void fullUpdate( float delta ) {
        onUpdate( delta );
        
        if ( checkResValid( script ) ) {
            script.callFunction( "update", delta );
        }

        foreach ( CNode node; children ) {
            node.fullUpdate( delta );
        }
    }

    /**
        Draw current node and children
        Params:
            camera - current camera
    */
    void fullDraw( INodeCamera camera ) {
        if ( !bVisible ) {
            return;
        }

        onDraw( camera );

        foreach ( CNode node; children ) {
            node.fullDraw( camera );
        }
    }

    /**
        Process input current node and children
        Params:
            event - input info
    */
    void fullInput( SInputEvent event ) {
        onInput( event );

        foreach ( CNode node; children ) {
            node.fullInput( event );
        }
    }

    /**
        Destroy current node and children. 
        Fisrt destroyed childrens
    */
    void fullDestroy() {
        foreach ( CNode node; children ) {
            node.destroy();
        }

        this.destroy();
    }

    /**
        Set node script
        Params:
            scr - script
    */
    void setScript( CScript scr ) {
        if ( scr.nativeClassName != typeof( this ).stringof ) {
            log.error( "Invalid script native class: " ~ scr.nativeClassName ~ " != " ~ typeof( this ).stringof );
            return;
        }

        script = scr;
        script.initInstance( this );
    }

    /**
        Load script from VFS file
        Params:
            path - file path in VFS
            className - load class from script
    */
    @ScriptExport( "loadScript", MethodType.method, "", RetType.userdat )
    void loadScript( string path, string className ) {
        import engine.script.script_loader : loadScript;
        script = engine.script.script_loader.loadScript( path );
        script.className = className;
        
        setScript( script );
    }

    /**
        Get node by path
        Params:
            path - path to search node from current node
    */
    @ScriptExport( "getNode", MethodType.method, "", RetType.userdat )
    CNode getNode( string path ) {
        return recursiveIterateByNames( path.replace( "//", "/" ).replace( "\\", "/" ).split( "/" ) );
    }

    /**
        Check if contains node by path
        Params:
            path - path to search node from current node
    */
    bool hasNode( string path ) {
        return getNode( path ) !is null;
    }

    /**
        Check if contains node
        Params:
            node - check node
    */
    bool hasChildNode( CNode node ) {
        foreach ( CNode n; children ) {
            if ( node is n ) {
                return true;
            }
        }

        return false;
    }

    /**
        Get node as type
        Params:
            path - path to search node from current node
    */
    CNode getNodeAs( T : CNode )( string path ) {
        return cast( T )getNode( path );
    }

    /**
        Add child node
        Params:
            node - node to add
    */
    void addChild( CNode node ) {
        if ( node.parent == this ) {
            log.warning( "Trying to add node ", node.name, " to itself" );
            return;
        } else if ( node.parent ) {
            node.parent.removeChild( node );
        }

        children ~= node;
        node.parent = this;
    }

    /**
        Remove child node
        Params:
            node - node to remove
            bDestroyAfterRemove - destroy after remove
    */
    void removeChild( CNode node, bool bDestroyAfterRemove = false ) {
        children = children.remove( children.countUntil( node ) );

        node.parent = null;
        if ( bDestroyAfterRemove ) {
            node.destroy();
        }
    }

    /**
        Destroy all node children
    */
    void destroyAllChildren() {
        foreach ( CNode node; children ) {
            node.destroy();
        }
    }

protected:
    /**
        Process nodes search in getNode( ... )
        Params:
            names - splited names for search
    */
    CNode recursiveIterateByNames( string[] names ) {
        assert( names.length > 0 );

        //Go to parent node
        if ( names[0] == ".." ) {
            if ( parent is null ) {
                return null;
            }
            
            return parent.recursiveIterateByNames( names[1..$] );
        }

        foreach ( CNode node; children ) {
            if ( node.name == names[0] ) {
                if ( names.length > 1 ) {
                    return node.recursiveIterateByNames( names[1..$] );
                } else {
                    return node;
                }
            }
        }

        return null;
    }

private:
    void onScriptDeserialized() {
        setScript( script );
    }

public:
    /*================SCRIPT_REGISTRY================*/
    
    @ScriptExport( "getName", MethodType.method, "", RetType.str )
    string script_getName() {
        return name;
    }

    @ScriptExport( "setName", MethodType.method, "", RetType.none )
    void script_setName( string newName ) {
        name = newName;
    }

    @ScriptExport( "getParent", MethodType.method, "", RetType.userdat )
    CNode script_getParent() {
        return parent;
    }

    @ScriptExport( "addChild", MethodType.method, "", RetType.none )
    void script_addChild( CNode* node ) {
        if ( node !is null ) {
            addChild( *node );
        }
    }

    @ScriptExport( "setScript", MethodType.method, "", RetType.none )
    void script_setScript( CScript* scr, string className ) {
        if ( scr !is null ) {
            scr.className = className;
            setScript( *scr );
        }
    }

    @ScriptExport( "isKeyPressed", MethodType.method, "", RetType.userdat )
    final bool script_isKeyPressed( double key ) {
        return getInput().isKeyPressed( cast( EKeyboard )( cast( int )key ) );
    }

    @ScriptExport( "isKeyReleased", MethodType.method, "", RetType.userdat )
    final bool script_isKeyReleased( double key ) {
        return !script_isKeyPressed( key );
    }

    @ScriptExport( "mousePos", MethodType.method, "", RetType.userdat )
    final SVec2D_Script script_mousePos() {
        SVec2I mPos = getInput().mousePos();
        return new SVec2D_Script( mPos.x, mPos.y );
    }
}