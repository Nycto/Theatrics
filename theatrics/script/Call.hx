package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.util.FrameEnter;

/**
 * A scriptable that just calls a function
 */
class Call implements Scriptable {

    /** The method to call */
    private var call: Null<Void -> Void> -> Void;

    /** Constructor */
    public function new ( call: Null<Void -> Void> -> Void ) {
        this.call = call;
    }

    /** Calls a function and immediately completes this scriptable */
    public static function build( func: Void -> Void ): Call {
        return new Call(function(onComplete) {
            func();
            if ( onComplete != null ) {
                onComplete();
            }
        });
    }

    /** {@inheritDoc} */
    public function start (
        onComplete: Null<Void -> Void> = null
    ): Scripterface {
        var control = new Scripterface();
        call(function () {
            if ( !control.isStopped ) {
                onComplete();
            }
        });
        return control;
    }
}

