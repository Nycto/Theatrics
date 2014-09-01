package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.script.Call;
import theatrics.util.FrameEnter;

/**
 * A scriptable that runs a bunch of other scriptables until they all finish
 */
class UntilAll implements Scriptable {

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

        var control = new Scripterface(function() {
            if ( subcontrols != null ) {
                for (i in 0...subcontrols.length) {
                    subcontrols[i].stop();
                }
                subcontrols = null;
            }
        });

        var completed: Int = 0;
        function actionDone() {
            if ( subcontrols != null ) {
                completed++;
                if ( completed == actions.length && onComplete != null ) {
                    onComplete();
                }
            }
        }

        for (i in 0...actions.length) {
            subcontrols[i] = actions[i].start(actionDone);
        }

        return control;
    }
}


