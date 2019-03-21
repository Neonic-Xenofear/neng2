module engine.physics2d;

public:
import engine.physics2d.base_body;
import engine.physics2d.shape;
import engine.physics2d.world;

import engine.core.mod.register_module;

class CPhys2DModule : ARegisterModule {
    void onLoad( CEngine engine ) {
        getClassDB().registerClass!CShape2D;
        getClassDB().registerClass!CBoxShape2D;
    }

    void onUnload( CEngine engine ) {
        getClassDB().unregisterClass!CShape2D;
        getClassDB().unregisterClass!CBoxShape2D;
    }
}