module engine.scene.nodes_2d;

public:
import engine.scene.nodes_2d.node2d;
import engine.scene.nodes_2d.sprite;
import engine.scene.nodes_2d.animated_sprite;
import engine.scene.nodes_2d.camera2d;
import engine.scene.nodes_2d.static_body;
import engine.scene.nodes_2d.dynamic_body;
import engine.scene.nodes_2d.kinematic_body;

import engine.core.mod.register_module;

class CNodes2DModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        getClassDB().registerClass!CNode2D;
        getClassDB().registerClass!CSprite;
        getClassDB().registerClass!CCamera2D;
        getClassDB().registerClass!CKinematicBody2D;
        getClassDB().registerClass!CDynamicBody2D;
    }

    void onUnload( CEngine engine ) {
        getClassDB().unregisterClass!CNode2D;
        getClassDB().unregisterClass!CSprite;
        getClassDB().unregisterClass!CCamera2D;
        getClassDB().unregisterClass!CKinematicBody2D;
        getClassDB().unregisterClass!CDynamicBody2D;
    }
}