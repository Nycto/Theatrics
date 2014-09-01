package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.util.FrameEnter;

/**
 * A scriptable that runs a bunch of other scriptabls at the same time until
 * the first one finishes
 */
class UntilFirst implements Scriptable {

    /** The list of actions */
    private var actions: Array<Scriptable>;

    /** Constructor */
    public function new ( actions: Array<Scriptable> ) {
        this.actions = actions;
    }

    /** {@inheritDoc} */
    public function start (
        onComplete: Null<Void -> Void> = null
    ): Scripterface {

        var subcontrols = new Array<Scripterface>();

        function stop ( except: Null<Int> ) {
            if ( subcontrols != null ) {
                for (i in 0...subcontrols.length) {
                    if ( i != except ) {
                        subcontrols[i].stop();
                    }
                }
                subcontrols = null;
            }
        }

        var control = new Scripterface(stop.bind(null));

        function actionDone( offset: Int ) {
            if ( subcontrols != null ) {
                stop(offset);
                if ( onComplete != null ) {
                    onComplete();
                }
            }
        }

        for (i in 0...actions.length) {
            subcontrols[i] = actions[i].start( actionDone.bind(i) );
        }

        return control;
    }
}




