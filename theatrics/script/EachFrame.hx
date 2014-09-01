package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.util.FrameEnter;

/**
 * A scriptable that calls a method for each frame
 */
class EachFrame implements Scriptable {

    /** The FrameEnter event manager */
    private var frames: FrameEnter;

    /** The method to call */
    private var callback: Int -> (Void -> Void) -> Void;

    /** Constructor */
    public function new (
        frames: FrameEnter,
        callback: Int -> (Void -> Void) -> Void
    ) {
        this.frames = frames;
        this.callback = callback;
    }

    /** {@inheritDoc} */
    public function start (
        onComplete: Null<Void -> Void> = null
    ): Scripterface {
        var control = new Scripterface();
        frames.register(function(elapsed, cancel) {
            if ( control.isStopped ) {
                cancel();
            }
            else {
                callback(elapsed, function() {
                    cancel();
                    if ( onComplete != null ) {
                        onComplete();
                    }
                });
            }
        });
        return control;
    }
}


