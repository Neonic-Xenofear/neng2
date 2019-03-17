module modules.box2d_phys.collision_listener;

import dbox;

import engine.app.logger;

import modules.box2d_phys.body_data;

class b2CCollisionListener : b2ContactListener {
    override void BeginContact( b2Contact contact ) {
        b2CBodyData bodyUD1 = cast( b2CBodyData )contact.GetFixtureA().GetBody().GetUserData();
        if ( !bodyUD1 ) {
            log.error( "Invalid body data" );
            return;
        }

        b2CBodyData bodyUD2 = cast( b2CBodyData )contact.GetFixtureA().GetBody().GetUserData();
        if ( !bodyUD2 ) {
            log.error( "Invalid body data" );
            return;
        }

        bodyUD1.onCollide( bodyUD2 );
        bodyUD2.onCollide( bodyUD1 );
    }
}