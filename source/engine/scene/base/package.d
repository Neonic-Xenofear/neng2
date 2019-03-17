module engine.scene.base;

public:
import engine.scene.base.node;
import engine.scene.base.scene_tree;
import engine.scene.base.scene_tree_serialize;
import engine.scene.base.node_camera;

import engine.core.mod.register_module;

class CNodesBaseModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        getClassDB().registerClass!CNode;
    }

    void onUnload( CEngine engine ) {
        getClassDB().unregisterClass!CNode;
    }
}