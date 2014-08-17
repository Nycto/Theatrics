package theatrics.util;

import openfl.Lib;
import openfl.events.Event;
import haxe.Timer;

/** A mechanism for dispatching 'onFrameEnter' events that supports pausing */
class FrameEnter {

    /** Returns the current timestamp in milliseconds */
    private static inline function now(): Int {
        return Math.floor( Timer.stamp() * 1000 );
    }

    /** The total amount of time spent paused */
    private var timeSpentPaused: Int = 0;

    /** Whether things are currently paused */
    private var isPaused: Bool = false;

    /** The time of the last pause */
    private var pausedAt: Int;

    /**
     * Registers an event handler.
     * @param handler This handler will be passed an Int which represents the
     *      number of milliseconds that have passed since it was registered.
     *      This number compensates for any pauses. It will also be passed a
     *      method that will let you cancel this handler
     * @return Returns a function that will cancel this handler
     */
    public function register(
        handler: Int -> (Void -> Void) -> Void
    ): Void -> Void {

        // Make a copy of the time paused so far as a baseline. This lets us
        // properly calculate the time lapsed, despite any pauses
        var timeSpentPausedAtRegister = timeSpentPaused;
        var registered = now();

        var cancelled: Bool = false;
        function cancel(){
            cancelled = true;
        }

        // The actual event handler that will get registered
        function realHandler (_) {
            if ( cancelled ) {
                Lib.current.removeEventListener(Event.ENTER_FRAME, realHandler);
                return;
            }

            if ( isPaused ) {
                return;
            }

            var paused = timeSpentPaused - timeSpentPausedAtRegister;
            handler( now() - registered - paused, cancel );
        }

        Lib.current.addEventListener(Event.ENTER_FRAME, realHandler);

        return cancel;
    }

    /** Pauses all handlers */
    public function pause() {
        if ( isPaused ) return;
        pausedAt = now();
        isPaused = true;
    }

    /** Unpauses all handlers */
    public function unpause() {
        if ( !isPaused ) return;
        timeSpentPaused = now() - pausedAt;
        pausedAt = null;
        isPaused = false;
    }
}

