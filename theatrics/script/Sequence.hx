package theatrics.script;

import theatrics.script.EachFrame;
import theatrics.script.Scriptable;
import theatrics.script.Call;
import theatrics.script.Interval;
import theatrics.script.UntilFirst;
import theatrics.script.UntilAll;
import theatrics.util.FrameEnter;
import theatrics.util.Defer;
import theatrics.util.Ease;
import theatrics.render.Animation;

/**
 * A sequence execution session
 */
class SequenceRun {

    /** The session configuration */
    private var sequence: Sequence;

    /** The currently running sub-script */
    private var running: Null<Scripterface> = null;

    /** A method to execute on completion */
    private var onComplete: Null<Void -> Void>;

    /** The next action to perform when the current action finishes */
    private var next: Int = 0;

    /** The execution controller */
    @:allow(theatrics.script.Sequence)
    private var control: Scripterface;

    /** Constructor */
    @:allow(theatrics.script.Sequence)
    private function new (
        sequence: Sequence,
        onComplete: Null<Void -> Void>
    ) {
        this.sequence = sequence;
        this.onComplete = onComplete;
        this.control = new Scripterface(function() {
            if ( running != null ) {
                running.stop();
            }
        });
        doNext();
    }

    /** Executes the next action */
    private function doNext(): Void {

        if ( control.isStopped ) {
            return;
        }

        var isSpent = next >= sequence.actions.length;

        // If this sequence is done and there is no loop
        if ( isSpent && !sequence.loop ) {
            var callback = onComplete;
            this.sequence = null;
            this.onComplete = null;
            if ( callback != null ) {
                callback();
            }
        }

        // If we haven't yet reached the final action
        else if ( !isSpent ) {
            next++;
            this.running = sequence.actions[next - 1].start(function() {
                this.sequence.defer.run(doNext);
            });
        }

        // Otherwise, we are set to loop. Start this iteration over again
        else {
            next = 0;
            doNext();
        }
    }
}

/**
 * A sequence is a set of scriptable actions
 */
class Sequence implements Scriptable {

    /** Deferred executor */
    @:allow(theatrics.script.SequenceRun)
    private var defer: Defer;

    /** Whether to loop infinitely */
    @:allow(theatrics.script.SequenceRun)
    private var loop: Bool;

    /** The list of scriptable actions to perform */
    @:allow(theatrics.script.SequenceRun)
    private var actions: Array<Scriptable>;

    /** Constructor */
    public function new (
        defer: Defer, loop: Bool, actions: Array<Scriptable>
    ) {
        this.defer = defer;
        this.loop = loop;
        this.actions = actions;
    }

    /** {@inheritDoc} */
    public function start (
        onComplete: Null<Void -> Void> = null
    ): Scripterface {
        return new SequenceRun( this, onComplete ).control;
    }
}

/**
 * A sequencer holds the scheduling objects needed to create sequences
 */
class Sequencer {

    /** The FrameEnter event manager */
    private var frames: FrameEnter;

    /** Deferred executor */
    private var defer: Defer;

    /** Constructor */
    public function new ( frames: FrameEnter, defer: Defer ) {
        this.frames = frames;
        this.defer = defer;
    }

    /** Runs a sequence one time through */
    public function once( actions: Array<Scriptable> ): Sequence {
        return new Sequence( defer, false, actions );
    }

    /** Runs a sequence one time through */
    public function loop( actions: Array<Scriptable> ): Sequence {
        return new Sequence( defer, true, actions );
    }

    /** Repeats an action a specific number of times */
    public function repeat( count: Int, actions: Array<Scriptable> ): Sequence {
        var sequence = once(actions);

        var repeated: Array<Scriptable> = [];
        for (i in 0...count) {
            repeated[i] = sequence;
        }

        return once( repeated );
    }

    /** Waits for the given number of milliseconds */
    public function delay( ms: Int ): Delay {
        return new Delay( frames, ms );
    }

    /** Executes a callback every frame until a 'cancel' method is called */
    public function frame(
        callback: Int -> (Void -> Void) -> Void
    ): Scriptable {
        return new EachFrame(frames, callback);
    }

    /** Stretches a function call over the given period of time  */
    public function percent(
        ms: Int,
        callback: Float -> Void,
        easing: EaseFunction = null
    ): Scriptable {
        return frame(function(time, done) {
            var percent = time / ms;
            if ( percent >= 1 ) {
                callback(1);
                done();
            }
            else {
                callback(easing == null ? percent : easing(percent));
            }
        });
    }

    /** Walks from one value to another over a given time span*/
    public function range(
        from: Int,
        to: Int,
        ms: Int,
        callback: Int -> Void,
        easing: EaseFunction = null
    ): Scriptable {
        var delta = to - from;
        return percent(ms, function(percent) {
            callback( from + Math.round(delta * percent) );
        }, easing);
    }

    /** Runs a function every few milliseconds*/
    public function interval(
        msInterval: Int,
        callback: Int -> (Void -> Void) -> Void
    ): Scriptable {
        return new Interval(frames, msInterval, callback);
    }

    /** Starts a bunch of actions and waits for the first to finish */
    public function untilFirst( actions: Array<Scriptable> ): Scriptable {
        return new UntilFirst( actions );
    }

    /** Starts a bunch of actions and waits for them all to finish */
    public function untilAll( actions: Array<Scriptable> ): Scriptable {
        return new UntilAll( actions );
    }

    /** Runs an animation one time through */
    public function animateOnce<T: EnumValue>(
        entity: AnimatedEntity<T>,
        key: T
    ): Scriptable {
        return entity.once( frames, key );
    }

    /** Runs an animation one time through */
    public function animateLoop<T: EnumValue>(
        entity: AnimatedEntity<T>,
        key: T
    ): Scriptable {
        return entity.loop( frames, key );
    }
}


