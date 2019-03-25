module engine.scene.gui.widget;

import engine.scene.nodes_2d;
import engine.core.math;
import engine.scene.gui.theme;

enum EAnchor {
    A_BEGIN,
    A_END
}

/**
    Base class of all widgets
*/
@ScriptExport( "CWidget" )
class CWidget : CNode2D {
    mixin( NODE_REG!() );
public:
    @Serialize {
        EAnchor[4] anchors; ///Left, top, right, bottom
        int[4] margins = [0, 0, 0, 0];
    }

protected:
    CTheme theme;
    bool bFocused;
    bool bMouseFocus;
    SRect rect;

public:
    @ScriptExport( "", MethodType.ctor )
    this() {}

    /**
        Set theme to widget and all childrens
        Params:
            newTheme - theme to set
    */
    @property
    void setTheme( CTheme newTheme ) {
        if ( newTheme == theme ) {
            return;
        }

        theme = newTheme;

        foreach ( CNode node; children ) {
            if ( CWidget wid = cast( CWidget )node ) {       
                wid.setTheme( theme );
            }
        }
    }

    void setRect( SRect nRect ) {
        rect = nRect;
    }

    SRect getRect() {
        return rect;
    }

    void setRectWidth( int width ) {
        rect.width = width;
    }

    void setRectHeight( int height ) {
        rect.height = height;
    }

    SRect getGlobalRect() {
        if ( CWidget pW = cast( CWidget )parent ) {
            updateRectByAnchorsAndMargins( rect, pW.getGlobalRect(), anchors, margins );
            return rect;
        }

        updateRectByAnchorsAndMargins( rect, SRect( SVec2I( 0, 0 ), 0, 0 ), anchors, margins );
        return rect;
    }
}

void updateRectByAnchorsAndMargins( ref SRect rect, SRect parentRect, EAnchor[4] anchors, int[4] margins ) {
    if ( margins[0] != 0 ) {
        if ( anchors[0] == EAnchor.A_BEGIN ) {
            rect.pos.x = parentRect.pos.x + margins[0];
        } else {
            rect.pos.x = parentRect.pos.x + confGeti( "engine/app/window/width" ) - margins[0];
        }
    }

    if ( margins[1] != 0 ) {
        if ( anchors[1] == EAnchor.A_BEGIN ) {
            rect.pos.y = parentRect.pos.y + margins[1];
        } else {
            rect.pos.x = parentRect.pos.y + confGeti( "engine/app/window/height" ) - margins[1];
        }
    }

    if ( margins[2] != 0 ) {
        if ( anchors[2] == EAnchor.A_BEGIN ) {
            rect.width = margins[2] - parentRect.width;
        } else {
            if ( parentRect.width == 0 ) {
                rect.width = confGeti( "engine/app/window/width" ) - margins[2] - parentRect.width - rect.pos.x;
            } else {
                rect.width = parentRect.width - margins[2] - rect.pos.x;
            }

            if ( rect.width < 0 ) {
                rect.width = 0;
            }
        }
    }

    if ( margins[3] != 0 ) {
        if ( anchors[3] == EAnchor.A_BEGIN ) {
            rect.height = margins[3] - parentRect.height;
        } else {
            if ( parentRect.height == 0 ) {
                rect.height = confGeti( "engine/app/window/height" ) - margins[3] - parentRect.height - rect.pos.y;
            } else {
                rect.height = parentRect.height - margins[3] - rect.pos.y;
            }

            if ( rect.height < 0 ) {
                rect.height = 0;
            }
        }
    }
}