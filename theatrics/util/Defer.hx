package theatrics.util;

import openfl.Lib;
import openfl.events.Event;
import haxe.Timer;

/**
 * Manages a queue of functions that should eventually be run
 */
class Defer {

    /** Returns the current timestamp in milliseconds */
    private static inline function now(): Float {
        return Timer.stamp() * 1000;
    }

    /** The list of functions to execute */
    private var queue(default, never) = new List<Void -> Void>();

    /** Constructor */
    public function new () {

        // On instantiation, hook in a frame listener to make sure we keep
        // executing queued functions, even if they throw
        Lib.current.addEventListener(Event.ENTER_FRAME, function(_) {

            // Track when we started so we can short circuit if it takes
            // too long to run all these functions
            var start = now();

            while ( queue.length > 0 && now() - start < 20 ) {
                var toRun = queue.pop();
                if ( toRun != null ) {
                    toRun();
                }
            }
        });
    }

    /** Pushes a function onto the queue to be executed */
    public function run ( func: Void -> Void ): Void {
        queue.add( func );
    }
}

