module engine.scene.gui.widget;

import engine.scene.nodes_2d;
import engine.core.math;
import engine.scene.gui.theme;

enum EAnchor {
    A_BEGIN,
    A_END
}

struct SWidgetCache {
    STransform2D transform;
    SVec2I winSize;
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

    SRect rect;

protected:
    CTheme theme;
    bool bFocused;
    bool bMouseFocus;

    SWidgetCache cache;

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

    override void onUpdate( float delta ) {
        updateRect();
    }

    void updateRect() {
        if ( !isCacheValid() && !( isNullMargins() && isBeginAnchors() ) ) {
            updateRectProcess();
        }
    }

    bool isCacheValid() {
        const SVec2I winSize = SVec2I( confGeti( "engine/app/window/width" ), confGeti( "engine/app/window/height" ) );
        return ( cache.transform == transform ) && ( cache.winSize == winSize );
    }

    bool isNullMargins() {
        return margins == [0, 0, 0, 0];
    }

    bool isBeginAnchors() {
        return anchors == [EAnchor.A_BEGIN, EAnchor.A_BEGIN, EAnchor.A_BEGIN, EAnchor.A_BEGIN];
    }

protected:
    void updateRectProcess() {
        if ( CWidget pW = cast( CWidget )parent ) {
            calculateRect( rect, pW.rect, anchors, margins );
        } else {
            calculateRect( rect, SRect.nul, anchors, margins );
        }

        cache.transform = transform;
        cache.winSize = SVec2I( confGeti( "engine/app/window/width" ), confGeti( "engine/app/window/height" ) );

        foreach ( CNode node; children ) {
            if ( CWidget wid = cast( CWidget )node ) {
                wid.updateRectProcess();
            }
        }
    }
}

/**
    Calculate all rect values by anchors and margins
    Params:
        rect - setup rect
        parentRect - parent rect
        anchors - ancrhors
        margins - margins
*/
///TODO: make it readable
void calculateRect( ref SRect rect, SRect parentRect, EAnchor[4] anchors, int[4] margins ) {
    if ( margins[0] != 0 ) {
        if ( anchors[0] == EAnchor.A_BEGIN ) {
            rect.pos.x = parentRect.pos.x + margins[0];
        } else {
            rect.pos.x = parentRect.pos.x + confGeti( "engine/app/window/width" ) - margins[0];
        }
    } else {
        if ( anchors[0] == EAnchor.A_BEGIN ) {
            rect.pos.x = parentRect.pos.x;
        } else {
            rect.pos.x = parentRect.pos.x + parentRect.width;
        }
    }

    if ( margins[1] != 0 ) {
        if ( anchors[1] == EAnchor.A_BEGIN ) {
            rect.pos.y = parentRect.pos.y + margins[1];
        } else {
            rect.pos.x = parentRect.pos.y + confGeti( "engine/app/window/height" ) - margins[1];
        }
    } else {
        if ( anchors[0] == EAnchor.A_BEGIN ) {
            rect.pos.y = parentRect.pos.y;
        } else {
            rect.pos.y = parentRect.pos.y + parentRect.height;
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
        }
    } else if ( parentRect.width != 0 ) {
        if ( anchors[2] == EAnchor.A_BEGIN ) {
            rect.width = parentRect.width;
        } else {
            rect.width = parentRect.width - rect.pos.x;
        }
    } else {
        rect.width = confGeti( "engine/app/window/width" ) - rect.pos.x;
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
        }
    } else if ( parentRect.height != 0 ) {
        if ( anchors[3] == EAnchor.A_BEGIN ) {
            rect.height = parentRect.height;
        } else {
            rect.height = parentRect.height - rect.pos.y;
        }
    } else {
        rect.height = confGeti( "engine/app/window/height" ) - rect.pos.y;
    }

    if ( rect.width < 0 ) {
        rect.width = 0;
    }

    if ( rect.height < 0 ) {
        rect.height = 0;
    }
}