module modules.box2d_phys.utils;

import dbox;
import engine.core.math.vec;

b2Vec2 toB2Vec( SVec2F iVec ) {
    import std.math : isNaN;
    b2Vec2 resVec;

    resVec.x = iVec.x.isNaN() ? 0 : iVec.x;
    resVec.y = iVec.y.isNaN() ? 0 : iVec.y;

    return resVec;
}