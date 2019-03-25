module engine.scene.gui.button;

import engine.core.resource;
import engine.scene.gui.widget;
import engine.core.input;
import engine.core.utils.signal;

class CButton : CWidget {
    mixin( NODE_REG!() );
protected:
    bool bPressed = false;
    bool bHovered = false;

    string text;

    SResRef!CTexture normalTexture;

public:
    SSignal!() onPressed;
    SSignal!() onReleased;
    SSignal!() onHovered;
    SSignal!() onUnhovered;

    override void onDestroy() {
        onPressed.disconnectAll();
        onReleased.disconnectAll();
        onHovered.disconnectAll();
        onUnhovered.disconnectAll();

        if ( normalTexture ) {
            normalTexture.removeOwner( this );
        }
    }

    override void onDraw( INodeCamera camera ) {
        if ( margins == [0, 0, 0, 0] ) {
            rect.pos = cast( SVec2I )getGlobalPos();
        } else {
            rect = getGlobalRect();
        }

        if ( text.length > 0 ) {
            SColor4 col = SColor4.white;
            if ( bHovered ) {
                col = SColor4.green;
            }

            if ( bPressed ) {
                col = SColor4.black;
            }

            SVec2I resPos = SVec2I( 
                                cast( int )( rect.pos.x + rect.width / 2 ),
                                cast( int )( rect.pos.y + rect.height / 2 )
                            );

            if ( checkResValid( normalTexture ) ) {
                getRender().drawTextureByRect2D( normalTexture, rect, transform.angle, modulateColor,  camera );
            }

            getRender().drawText( 
                text, 
                resPos,
                col
            );
        }
    }

    override void onInput( SInputEvent event ) {
        if ( event.type == EInputType.IT_MOUSE_MOTION ) {
            SVec2I mPos = event.mMotion.pos;

            //Check if mouse hover button
            bool locHovered = rect.isInRect( mPos );

            if ( locHovered != bHovered ) {
                if ( locHovered ) {
                    onHovered.emit();
                } else {
                    onUnhovered.emit();
                }

                bHovered = locHovered;
            }
        } else if ( event.type == EInputType.IT_MOUSE_BUTTON ) {
            if ( event.mButton.button == EMouseButton.MB_LEFT ) {
                if ( bHovered || bPressed ) {
                    bPressed = event.mButton.isDown();
                }
            }
        }
    }

    void setText( string nText ) {
        text = nText;
    }

    void setNormalTexture( CTexture texture ) {
        if ( normalTexture ) {
            normalTexture.removeOwner( this );
        }

        normalTexture = texture;

        normalTexture.addOwner( this );
    }
}