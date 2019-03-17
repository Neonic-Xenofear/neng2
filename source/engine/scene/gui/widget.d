module engine.scene.gui.widget;

import engine.scene.nodes_2d;
import engine.core.math;
import engine.scene.gui.theme;

/**
    Base class of all widgets
*/
@ScriptExport( "CWidget" )
class CWidget : CNode2D {
    mixin( NODE_REG!() );
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
}