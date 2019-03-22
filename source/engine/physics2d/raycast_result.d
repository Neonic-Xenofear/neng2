module engine.physics2d.raycast_result;

import engine.core.math;

struct SRayCastResult {
    SVec2F start;
    SVec2F end;
    SVec2F hit;
}

struct SRayCastOutput {
    bool bHit;
    SRayCastResult info;
}