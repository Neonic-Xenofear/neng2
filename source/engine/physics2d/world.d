module engine.physics2d.world;

public import engine.core.math;

public import engine.core.mod.imod;
public import engine.physics2d.base_body;

/**
    Phys world or phys server for manipulate phys bodies.
*/
abstract class APhysWorld2D : IModule {
    @property
    final EModuleUpdate updateInfo() {
        return EModuleUpdate.MU_NORMAL;
    }

    @property
    final EModuleInitPhase initPhase() {
        return EModuleInitPhase.MIP_UPON_REQUEST;
    }

    /**
        Generate basic body data.
        Params:
            iBody - gen body.
    */
    void genBodyData( CBaseBody2D iBody );

    /**
        Destroy generated data.
        Params:
            iBody - gen body.
    */
    void destroyBodyData( CBaseBody2D iBody );


    /**
        Set body pos syncronize.
        Params:
            iBody - body.
            newPos - new world position
    */
    void setBodyPos( CBaseBody2D iBody, SVec2F newPos );


    /**
        Attach new shape to body.
        Params:
            iBody - body.
            addShape - attach shape
    */
    void addBodyShape( CBaseBody2D iBody, CShape2D addShape );

    /**
        Remove shape from body.
        Params:
            iBody - body.
            removeShape - remove shape
    */
    void removeBodyShape( CBaseBody2D iBody, CShape2D removeShape );


    /**
        Set body linear velocity.
        Params:
            iBody - body.
            vel - linear velocity.
    */
    void setBodyLinearVelocity( CBaseBody2D iBody, SVec2F vel );


    /**
        Move given body shape.
        Params:
            iBody - body.
            shape - move shape.
            move - move vector.
    */
    void moveBodyShape( CBaseBody2D iBody, CShape2D shape, SVec2F move );
}