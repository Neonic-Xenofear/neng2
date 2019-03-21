module modules.box2d_phys.body_data;

import std.exception;

import dbox;

import engine.physics2d;
import modules.box2d_phys.utils;

float PIXELS_IN_METER = 100;

class b2CBodyData {
    b2BodyDef bodyDef;
    b2Body* genBody;
    b2PolygonShape[CShape2D] shapes;
    b2Fixture*[CShape2D] fixtures;
    CBaseBody2D bb2D;

    void setup( CBaseBody2D iBody, b2World* iWorld ) {
        bb2D = iBody;
        switch ( iBody.getType() ) {
        case EPhysBodyType.PBT_STATIC:
            bodyDef.type = b2_staticBody;
            break;
        
        case EPhysBodyType.PBT_DYNAMIC:
            bodyDef.type = b2_dynamicBody;
            break;

        case EPhysBodyType.PBT_KINEMATIC:
            bodyDef.type = b2_kinematicBody;
            break;

        default:
            bodyDef.type = b2_dynamicBody;
            break;
        }

        bodyDef.position.Set( 0, 0 );
        bodyDef.angle = 0;
        genBody = iWorld.CreateBody( &bodyDef );

        genBody.SetUserData( cast( void* )this );
    }

    void addShape( CBaseBody2D iBody, CShape2D newShape ) {
        b2PolygonShape shape = new b2PolygonShape();

        switch ( newShape.type ) {
        case EShapeType.ST_BOX:
            CBoxShape2D boxShape = cast( CBoxShape2D )newShape;
            shape.SetAsBox( boxShape.width / PIXELS_IN_METER, boxShape.heigth / PIXELS_IN_METER );
            break;

        default:
            shape.SetAsBox( 1, 1 );
            break;
        }

        b2Fixture* fixture;

        if ( iBody.getType() != EPhysBodyType.PBT_STATIC ) {
            b2FixtureDef fixtureDef;
            fixtureDef.shape = shape;
            fixtureDef.density = 0.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 0.3f;
            fixture = genBody.CreateFixture( &fixtureDef );
        } else {
            //Static body density need to be 0
            fixture = genBody.CreateFixture( shape, 0.0f );
        }

        shapes[newShape] = shape;
        fixtures[newShape] = fixture;

        newShape.extData = shape;
    }

    void removeShape( CShape2D iShape ) {
        if ( b2Fixture** fix = iShape in fixtures ) {
            genBody.DestroyFixture( *fix );
            shapes.remove( iShape );
            fixtures.remove( iShape );
            ( *fix ).destroy();
        }
    }

    void onCollide( b2CBodyData iBody ) {
        bb2D.onCollide.emit( iBody.bb2D );
    }
}