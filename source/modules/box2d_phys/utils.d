module modules.box2d_phys.utils;

import dbox;
import engine.core.math.vec;

b2Vec2 toB2Vec( SVec2F iVec ) {
    return b2Vec2( iVec.x, iVec.y );
}