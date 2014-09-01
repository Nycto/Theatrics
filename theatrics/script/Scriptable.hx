package theatrics.script;

import theatrics.util.FrameEnter;

/**
 * A control for a scriptable component
 */
class Scripterface {

    /** Whether this script has been stopped */
    public var isStopped(default, null): Bool = false;

    /** A callback to invoke when stopped */
    private var onStop: Null<Void -> Void>;

    /** Constructor */
    public function new( onStop: Void -> Void = null ) {
        this.onStop = onStop;
    }

    /** Stops and destroys a running script */
    public function stop(): Void {
        if ( !isStopped ) {
            isStopped = true;
            if ( this.onStop != null ) {
                this.onStop();
                this.onStop = null;
            }
        }
    }
}

/**
 * Represents an action that can be executed
 */
interface Scriptable {

    /** Starts this scriptable action */
    function start ( onComplete: Null<Void -> Void> = null ): Scripterface;
}

