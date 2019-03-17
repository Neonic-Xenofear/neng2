module engine.scene.gui.window;

import engine.core.input;
import engine.scene.gui.widget;
import engine.core.resource;
import engine.core.engine.engine : getRender;

class CWindowGUI : CWidget {
protected:
    bool bTitleHovered = false;
    bool bTitleGrabbed = false;
    SVec2I grabPosDelta;

    string title;
    int titleHeigth = 10;

    SResRef!CTexture titleTexture;

public:
    this() {}

    this( CWidget parent, string iTitle ) {
        super();
        title = iTitle;
    }

    override void onDestroy() {
        if ( titleTexture ) {
            titleTexture.removeOwner( this );
        }
    }

    override void onDraw( INodeCamera camera ) {
        rect.pos = cast( SVec2I )getGlobalPos();

        if ( checkResValid( titleTexture ) ) {
            getRender().drawTextureByRect2D(
                titleTexture, 
                rect, 
                transform.angle, 
                modulateColor,
                camera
            );

            getRender().drawTextureByRect2D(
                titleTexture, 
                SRect( rect.pos, rect.width, titleHeigth ), 
                transform.angle, 
                modulateColor,
                camera
            );
        }
    }

    override void onInput( SInputEvent event ) {
        switch ( event.type ) {
        case EInputType.IT_MOUSE_BUTTON:
            if ( event.mButton.button == EMouseButton.MB_LEFT ) {
                if ( bTitleHovered || bTitleGrabbed ) {
                    bTitleGrabbed = event.mButton.isDown();
                    grabPosDelta = getInput().mousePos() - cast( SVec2I )transform.pos;
                }
            }
            break;
        case EInputType.IT_MOUSE_MOTION:
            if ( bTitleGrabbed ) {
                transform.pos = cast( SVec2F )( event.mMotion.pos - grabPosDelta );
            } else {
                bTitleHovered = SRect( rect.pos, rect.width, titleHeigth )
                    .isInRect( event.mMotion.pos ) && !bTitleGrabbed;
            }

            break;

        default:
            break;
        }
    }

    void setTitleTexture( CTexture texture ) {
        if ( titleTexture ) {
            titleTexture.removeOwner( this );
        }

        titleTexture = texture;

        titleTexture.addOwner( this );
    }
}