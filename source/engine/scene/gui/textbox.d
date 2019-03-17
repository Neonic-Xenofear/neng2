module engine.scene.gui.textbox;

import engine.scene.gui.widget;
import engine.core.engine.engine;
import engine.core.engine.timer;

enum EAligment {
    A_LEFT,
    A_CENTER,
    A_RIGHT,
}

class CTextBox : CWidget {
    mixin( NODE_REG!() );
protected:
    bool bEditable = true;
    string value;
    int textPos = 0;

public:
    override void onDraw( INodeCamera camera ) {
        if ( value.length > 0 ) {
            getRender().drawText( value, cast( SVec2I )transform.pos );
        }
    }

    override void onInput( SInputEvent event ) {
        if ( bEditable ) {
            if ( event.type == EInputType.IT_KEY ) {
                if ( event.key.key == EKeyboard.K_BACKSPACE ) {

                    if ( value.length > 0 ) {
                        value = value[0..$-1]; //Remove last char
                    }

                }/* else {
                    if ( event.key.key == EKeyboard.K_RIGHT ) {
                        if ( textPos + 1 < value.length ) {
                            textPos += 1;
                        }
                    } else if ( event.key.key == EKeyboard.K_LEFT ) {
                        if ( textPos - 1 > -1 ) {
                            textPos -= 1;
                        }
                    }
                } */
            } else if ( event.type == EInputType.IT_TEXT ) {
                value ~= event.text.character;//value[0..textPos] ~ event.text.character ~ value[textPos..$];
            }
        }
    }
}