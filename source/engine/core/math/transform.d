module engine.core.math.transform;

public import engine.core.math.vec;

struct STransform2D {
    SVec2F pos = SVec2F( 1.0f, 0.0f );
    SVec2F size = SVec2F( 1.0f, 1.0f );

    float angle = 0;
}