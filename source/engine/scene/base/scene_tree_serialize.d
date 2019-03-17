module engine.scene.base.scene_tree_serialize;

import sdlang;

import engine.core.serialize;
import engine.scene.base.node;

struct SSceneTreeSerializer {
    SSerializer baseSerializer;
    Tag sceneNodesTag;

    alias baseSerializer this;

    void serialize( CNode root, CNode[] blacklistNodes ) {
        if ( !sceneNodesTag ) {
            sceneNodesTag = new Tag();
            sceneNodesTag.name = "nodes";
        }

        baseSerializer.blacklist ~= root.instanceId;

        foreach ( node; blacklistNodes ) {
            baseSerializer.blacklist ~= node.instanceId;
        }

        foreach ( child; root.children ) {
            serializeNode( child );
        }
    }

    string toString() {
        auto root = new Tag();

        root.add( sceneNodesTag );
        root.add( baseSerializer.root );

        return root.toSDLDocument();
    }

private:
    void serializeNode( CNode node ) {
        node.serialize( baseSerializer );
        auto nodeTag = new Tag( sceneNodesTag );
        nodeTag.add( Value( node.instanceId.toString() ) );
    }
}

struct SSceneDeserializer {
    SDeserializer baseDeserializer;
    Tag sceneNodesTag;

    alias baseDeserializer this;

    this( string data ) {
        baseDeserializer = SDeserializer( data );
        
        sceneNodesTag = baseDeserializer.root.all.tags["nodes"][0];
        assert( sceneNodesTag !is null );
    }

    void deserialize( CNode root ) {
        assert( root );

        foreach ( Tag node; sceneNodesTag.all.tags ) {
            auto id = node.values[0].get!string;
            auto sceneNode = cast( CNode )baseDeserializer.findLoadedRef( id );

            if ( sceneNode is null ) {
                sceneNode = new CNode();
                baseDeserializer.storeLoadedRef( sceneNode, id );
                sceneNode.deserialize( this, id );
                assert( sceneNode.parent is null );
                root.addChild( sceneNode );
            } else {
                assert( sceneNode.parent is root || sceneNode.parent is null );
                if ( sceneNode.parent is null ) {
                    root.addChild( sceneNode );
                }
            }
        }

            void recursiveCreate( CNode iNode ) {
                foreach ( child; iNode.children ) {
                    recursiveCreate( child );
                }
            }

            foreach ( Tag node; sceneNodesTag.all.tags ) {
                auto id = node.values[0].get!string;
                auto sceneNode = cast( CNode )baseDeserializer.findLoadedRef( id );
                assert( sceneNode );
                recursiveCreate( sceneNode );
            }

            foreach ( i, lo; baseDeserializer.loadedObjects ) {
                import engine.core.object;
                AObject obj = lo.object;
                assert( obj );
            }

            void val( CNode node, CNode root ) {
                import std.format : format;
                assert( node );

                if ( node !is root ) {
                    assert( node.parent, format( "no parent: %s", node.instanceId ) );
                    assert( node.parent.hasChildNode( node ) );
                }

                foreach ( sn; node.children ) {
                    val( sn, node );
                }
            }

            val( root, root );
    }
}