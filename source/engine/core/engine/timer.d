module engine.core.engine.timer;

import engine.core.engine.engine;

enum ETimerState {
	TS_STOP,
	TS_PROCESS,
	TS_PAUSED,
	TS_END,
}

class CTimer {
    ETimerState timerState = ETimerState.TS_STOP;

    float startTicks;
	float pausedTicks;
	float currentTick;

	float waitTime = 0.0f;
	void delegate() callback = null;
	void delegate( float ) valCallback = null;

public:
	this() {
	}

	void update() {
		if( timerState == ETimerState.TS_PROCESS ) {
			currentTick = Time.totalTime() - startTicks;
			float outTime = currentTick;

			if ( valCallback !is null ) {
				float val = outTime / waitTime;

				if ( val <= 1.0f ) {
					valCallback( val );
				}
			}
			
			if( outTime >= waitTime ) {
				timerState = ETimerState.TS_STOP;

				if ( callback !is null ) {
					callback();
				}

				if ( valCallback !is null ) {
					valCallback( 1.0f );
				}
			}
		}
	}

	void start() {
		timerState = ETimerState.TS_PROCESS;
		startTicks = Time.totalTime;
	}

	void stop() {
        timerState = ETimerState.TS_STOP;
	}

	void setWaitTime( float iWaitTime ) {
		if( timerState != ETimerState.TS_PROCESS ) {
			waitTime = iWaitTime;
		}
	}

	void setCallback( void delegate() func ) {
		callback = func;
	}

	void setValueCallback( void delegate( float ) func ) {
		valCallback = func;
	}

	void setup( float iWaitTime, void delegate() func ) {
		setWaitTime( iWaitTime );
		setCallback( func );
	}

	void setup( float iWaitTime, void delegate( float ) func ) {
		setWaitTime( iWaitTime );
		setValueCallback( func );
	}

	void pause() {
		if ( timerState == ETimerState.TS_PROCESS ) {
			timerState = ETimerState.TS_PAUSED;

			pausedTicks = Time.totalTime() - startTicks;
			startTicks = 0;
		}
	}

	void unpause() {
		if ( timerState == ETimerState.TS_PAUSED ) {
			timerState = ETimerState.TS_PROCESS;
			startTicks = Time.totalTime() - pausedTicks;
			pausedTicks = 0;
		}
	}
}