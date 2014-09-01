package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.util.FrameEnter;

/**
 * A scriptable that invokes a callback every n milliseconds
 */
class Interval implements Scriptable {

    /** The FrameEnter event manager */
    private var frames: FrameEnter;

    /** How often to invoke the callback */
    private var interval: Int;

    /** The method to call */
    private var callback: Int -> (Void -> Void) -> Void;

    /** Constructor */
    public function new (
        frames: FrameEnter,
        interval: Int,
        callback: Int -> (Void -> Void) -> Void
    ) {
        this.frames = frames;
        this.interval = interval;
        this.callback = callback;
    }

    /** {@inheritDoc} */
    public function start (
        onComplete: Null<Void -> Void> = null
    ): Scripterface {

        // The cancel method. This is a forward declaration. It will get filled
        // in when the frame callback is registered
        var cancel: Null<Void -> Void> = null;

        // This gets passed to the callback to let it complete this script
        function complete() {
            if ( cancel != null ) {
                cancel();
            }
            if ( onComplete != null ) {
                onComplete();
            }
        }

        // The time at which to run the next frame. We're going to immediately
        // run the first frame, so we set the next frame to run after the
        // interval
        var nextFrameAt = interval;

        // The number of times this interval has been called
        var invokation = 0;

        var control = new Scripterface();

        cancel = frames.register(function(elapsed, _) {
            if ( !control.isStopped ) {
                if ( elapsed >= nextFrameAt ) {
                    nextFrameAt = elapsed + interval;
                    invokation++;
                    callback(invokation, complete);
                }
            }
            else if ( cancel != null ) {
                cancel();
            }
        });

        callback(0, complete);

        return control;
    }
}



