package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.util.FrameEnter;

/**
 * A scriptable that waits for the given number of milliseconds
 */
class Delay implements Scriptable {

    /** Frame callback manager */
    private var frames: FrameEnter;

    /** The length of time to wait */
    private var delay: Int;

    /** Constructor */
    public function new ( frames: FrameEnter, delay: Int ) {
        this.frames = frames;
        this.delay = delay;
    }

    /** {@inheritDoc} */
    public function start (
        onComplete: Null<Void -> Void> = null
    ): Scripterface {
        var control = new Scripterface();
        frames.register(function (elapsed, cancel) {
            if ( control.isStopped ) {
                cancel();
            }
            else if ( elapsed >= delay ) {
                cancel();
                if ( onComplete != null ) {
                    onComplete();
                }
            }
        });
        return control;
    }
}


