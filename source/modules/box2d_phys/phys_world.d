module modules.box2d_phys.phys_world;

import dbox;
import std.exception;

import engine.physics2d.world;
import engine.core.math;
import engine.core.utils.array : removeElement;

import modules.box2d_phys.utils;
import modules.box2d_phys.body_data;
import modules.box2d_phys.collision_listener;

enum PIXELS_IN_METER = 10;

class b2CPhysWorld2D : APhysWorld2D {
private:
    b2Vec2 gravity = b2Vec2( 0.0f, 0.0f );
    b2World* world;
    b2CBodyData[] objs;
    b2CCollisionListener listener;

public:
    this() {
        world = new b2World( gravity );
        listener = new b2CCollisionListener();
        world.SetContactListener( listener );
    }

    ~this() {
        listener.destroy();
    }

    @property
    SModuleInfo info() {
        return SModuleInfo(
            "BOX2D",
            "MAPLE_CORE", 
            "1.0"
        );
    }

    void onLoad( CEngine engine ) {}

    void onUnload( CEngine engine ) {
        foreach ( b2CBodyData data; objs ) {
            world.DestroyBody( data.genBody );
            data.destroy();
        }
    }

    void update( float delta ) {
        world.Step( delta, 6, 2 );

        foreach ( b2CBodyData data; objs ) {
            //Set positon without call "setBodyPos" with server synchronize
            data.bb2D.setPosRaw( SVec2F( data.genBody.GetPosition().x * PIXELS_IN_METER, data.genBody.GetPosition().y * PIXELS_IN_METER ) );

            for ( b2Fixture* fix = data.genBody.GetFixtureList(); fix; fix = fix.GetNext() ) {
                SVec2F corrPos = SVec2F( data.genBody.GetPosition().x * PIXELS_IN_METER, data.genBody.GetPosition().y * PIXELS_IN_METER );
                switch ( fix.GetType() ) {
                    case b2Shape.Type.e_polygon:
                        b2PolygonShape shape = cast( b2PolygonShape )fix.GetShape();
                        SVec2F prevPos = SVec2F( shape.GetVertex( 0 ).x * PIXELS_IN_METER, shape.GetVertex( 0 ).y * PIXELS_IN_METER );
                        for ( int i = 1; i < shape.GetVertexCount(); ++i ) {
                            getRender().drawLine2D( 
                                corrPos + prevPos, 
                                corrPos + SVec2F( shape.GetVertex( i ).x * PIXELS_IN_METER, shape.GetVertex( i ).y * PIXELS_IN_METER )
                            );
                            prevPos = SVec2F( shape.GetVertex( i ).x * PIXELS_IN_METER, shape.GetVertex( i ).y * PIXELS_IN_METER );
                        }
                        getRender().drawLine2D( 
                            corrPos + prevPos, 
                            corrPos + SVec2F( shape.GetVertex( 0 ).x * PIXELS_IN_METER, shape.GetVertex( 0 ).y * PIXELS_IN_METER )
                        );
                        break;
                    
                    default:
                        break;
                }
            }
        }
    }

    override void genBodyData( CBaseBody2D iBody ) {
        b2CBodyData data = new b2CBodyData();
        data.setup( iBody, world );

        iBody.extData = data;
        objs ~= data;
    }

    override void destroyBodyData( CBaseBody2D iBody ) {
        if ( !iBody ) {
            return;
        }

        if ( iBody.extData.isNull() ) {
            return;
        }

        b2CBodyData data = iBody.extData.as!b2CBodyData;
        if ( data ) {
            objs.removeElement( data );
            world.DestroyBody( data.genBody );
            data.destroy();
        }
    }

    override void setBodyPos( CBaseBody2D iBody, SVec2F newPos ) {
        if ( !iBody ) {
            return;
        }

        if ( iBody.extData.isNull() ) {
            return;
        }

        b2CBodyData data = iBody.extData.as!b2CBodyData;
        if ( data ) {
            data.genBody.SetTransform( b2Vec2( newPos.x / PIXELS_IN_METER, newPos.y / PIXELS_IN_METER ), data.genBody.GetAngle() );
            iBody.setPosRaw( newPos, false );
        }
    }

    override void addBodyShape( CBaseBody2D iBody, CShape2D addShape ) {
        if ( !iBody ) {
            return;
        }

        if ( iBody.extData.isNull() ) {
            return;
        }

        b2CBodyData data = iBody.extData.as!b2CBodyData;
        if ( data ) {
            data.addShape( iBody, addShape );
        }
    }

    override void removeBodyShape( CBaseBody2D iBody, CShape2D removeShape ) {
        if ( !iBody ) {
            return;
        }

        if ( iBody.extData.isNull() ) {
            return;
        }

        b2CBodyData data = iBody.extData.as!b2CBodyData;
        if ( data ) {
            data.removeShape( removeShape );
        }
    }

    override void setBodyLinearVelocity( CBaseBody2D iBody, SVec2F vel ) {
        if ( !iBody ) {
            return;
        }

        if ( iBody.extData.isNull() ) {
            return;
        }

        b2CBodyData data = iBody.extData.as!b2CBodyData;
        if ( data ) {
            data.genBody.SetLinearVelocity( vel.toB2Vec() );
        }
    }

    override void moveBodyShape( CBaseBody2D iBody, CShape2D shape, SVec2F move ) {
        if ( !iBody ) {
            return;
        }

        if ( iBody.extData.isNull() ) {
            return;
        }

        b2CBodyData data = iBody.extData.as!b2CBodyData;
        if ( data ) {
            if ( b2Fixture** fix = shape in data.fixtures ) {
                b2PolygonShape ps = cast( b2PolygonShape )( ( *fix ).GetShape() );
                ps.move( ( move / SVec2F( PIXELS_IN_METER, PIXELS_IN_METER ) ).toB2Vec() );
                bool bActive = data.genBody.IsActive();
                data.genBody.ResetMassData();
                data.genBody.SetActive(!bActive);
                data.genBody.SetActive(bActive);
            }
        }
    }
}