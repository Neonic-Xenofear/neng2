module engine.core.utils.profile;

import engine.core.utils.logger;

void bencFunc( alias func )( lazy string name ) {
    import std.datetime.stopwatch : benchmark;
    import core.time : Duration;

    Duration res = cast( Duration )benchmark!func( 1 );
    log.info( name, " time: ", res );
}