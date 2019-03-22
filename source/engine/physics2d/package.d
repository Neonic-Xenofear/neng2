module engine.physics2d;

public:
import engine.physics2d.base_body;
import engine.physics2d.shape;
import engine.physics2d.world;
import engine.physics2d.raycast_result;

import engine.core.mod.register_module;

class CPhys2DModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        getClassDB().registerClass!CShape2D;
        getClassDB().registerClass!CBoxShape2D;

        getClassDB().registerClass!CBaseBody2D;
    }

    void onUnload( CEngine engine ) {
        getClassDB().unregisterClass!CShape2D;
        getClassDB().unregisterClass!CBoxShape2D;
    
        getClassDB().unregisterClass!CBaseBody2D;
    }
}