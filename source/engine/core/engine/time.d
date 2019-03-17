/**
    ORIGINAL SOURCE: https://github.com/Circular-Studios/Dash/blob/master/source/dash/utility/time.d
*/
module engine.core.engine.time;

import std.datetime;

float toSeconds( Duration dur ) {
    return 
        cast( float )dur.total!"hnsecs" / 
        cast( float )1.convert!( "seconds", "hnsecs" );
}

CTime Time;

static this()
{
    Time = new CTime();
}

final class CTime {
private:
    Duration delta;
    Duration total;

public:
    float deltaTime() {
        return delta.toSeconds();
    }

    float totalTime() { 
        return total.toSeconds(); 
    }

    void update() {
        updateTime();
    }

private:
    this() {
        delta = total = Duration.zero;
    }
}

int getFrameCount() {
    return frameCount;
}

private:
StopWatch sw;
TickDuration cur;
TickDuration prev;
Duration delta;
Duration total;
Duration second;
int frameCount;

/**
 * Initialize the time controller with initial values.
 */
static this()
{
    cur = prev = TickDuration.min;
    total = delta = second = Duration.zero;
    frameCount = 0;
}

/**
 * Thread local time update.
 */
void updateTime()
{
    if( !sw.running )
    {
        sw.start();
        cur = prev = sw.peek();
    }

    delta = cast(Duration)( cur - prev );

    prev = cur;
    cur = sw.peek();

    // Pass to values
    Time.total = cast(Duration)cur;
    Time.delta = delta;

    // Update framerate
    ++frameCount;
    second += delta;
    if( second >= 1.seconds )
    {
        second = Duration.zero;
        frameCount = 0;
    }
}