module engine.scene.base.scene_tree;

import std.algorithm;

import engine.core.math;
import engine.core.engine.engine;
import engine.core.serialize;
import engine.core.object;
import engine.scene.base;
import engine.scene.gui;
import engine.core.input;

/**
    Scene tree
*/
class CSceneTree : AObject {
    mixin( TRegisterObject!() );
private:
    @Serialize
    CNode[] rootNodes; ///Root nodes
    CNode[] scriptNodes; ///Nodes blacklisted from serialize
    INodeCamera currentCamera; ///Main camera, sends to render

public:
    ~this() {
        foreach ( CNode node; rootNodes ) {
            node.fullDestroy();
        }

        log.info( "Scene tree destroyed" );
    }

    /**
        Update all nodes on scene
        Params:
            delta - delta time
    */
    void update( float delta ) {
        if ( rootNodes.length == 0 ) {
            return;
        }

        foreach ( CNode node; rootNodes ) {
            if ( !node ) {
                continue;
            }

            node.fullUpdate( delta );
            node.fullDraw( currentCamera );
        }
    }

    /**
        Process nodes input
        Params:
            event - input event
    */
    void input( SInputEvent event ) {
        foreach ( CNode node; rootNodes ) {
            if ( !node ) {
                continue;
            }
            
            node.fullInput( event );
        }
    }

    /**
        Add new root node
        Params:
            node - node to add
    */
    void addRootNode( CNode node ) {
        if ( node is null ) {
            CLogger.get().error( "Trying to add invalid node instance to root nodes!" );
            return;
        }

        if ( !rootNodes.canFind( node ) ) {
            rootNodes ~= node;
            node.onEnterTree();
        }
    }

    void addScriptNode( CNode node ) {
        if ( !scriptNodes.canFind( node ) ) {
            scriptNodes ~= node;
        }
    }

    CNode[] getScriptNodes() {
        return scriptNodes;
    }

    /**
        Set main scene camera
        Params:
            camera - set camera
    */
    void setCamera( INodeCamera camera ) {
        currentCamera = camera;
    }
    
    /**
        Returns all root nodes
    */
    CNode[] getRootNodes() {
        return rootNodes;
    }
}