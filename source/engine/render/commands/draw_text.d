module engine.render.commands.draw_text;

import engine.core.math;

struct SRenderDrawText {
    string text;
    SVec2I pos = SVec2I( 0, 0 );
    SColor4 color = SColor4.white;
}