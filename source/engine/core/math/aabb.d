module engine.core.math.aabb;

import engine.core.math.vec;

struct SAABB {
    SVec2F min;
    SVec2F max;

    this( SVec2F iMin, SVec2F iMax ) {
        min = iMin;
        max = iMax;
    }

    bool isIntersection( SAABB iAABB ) {
        if ( max.x < iAABB.min.x || min.x > iAABB.max.x ) {
            return false;
        }

        //We use inverted Y coordinate
        import engine.core.utils.logger;
        if ( max.y > iAABB.min.y || min.y < iAABB.max.y ) {
            return false;
        }

        return true;
    }
}

bool isIntersection( SAABB first, SAABB second ) {
    return first.isIntersection( second );
}