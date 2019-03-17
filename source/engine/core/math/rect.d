module engine.core.math.rect;

public import engine.core.math.vec;

struct SRect {
    SVec2I pos;
    int width;
    int height;
}

bool isInRect( SRect rect, SVec2I pos ) {
    return  pos.x > rect.pos.x &&
            pos.x < rect.pos.x + rect.width &&
            pos.y > rect.pos.y &&
            pos.y < rect.pos.y + rect.height;
}