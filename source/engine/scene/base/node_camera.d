module engine.scene.base.node_camera;

public import engine.core.math;

/**
    Used to cut off the nodes in the render and 
    determine their position relative to the camera
*/
interface INodeCamera {
    /**
        Return camera world postion
    */
    SVec3F getPos();

    /**
        Chek if object in camera view
        Params:
            object - object AABB
    */
    bool inView( SAABB object );
}