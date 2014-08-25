package theatrics.script;

import theatrics.script.Scriptable;
import theatrics.util.FrameEnter;
import theatrics.util.Defer;
import theatrics.util.Ease;

/**
 * A sequence execution session
 */
class SequenceRun {

    /** The session configuration */
    private var sequence: Sequence;

    /** A method to execute on completion */
    private var onComplete: Null<Void -> Void>;

    /** The next action to perform when the current action finishes */
    private var next: Int = 0;

    /** Constructor */
    @:allow(theatrics.script.Sequence)
    private function new (
        sequence: Sequence,
        onComplete: Null<Void -> Void>
    ) {
        this.sequence = sequence;
        this.onComplete = onComplete;
        doNext();
    }

    /** Executes the next action */
    private function doNext(): Void {

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
            sequence.actions[next - 1].start(function() {
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
    public function start ( onComplete: Null<Void -> Void> = null ): Void {
        new SequenceRun( this, onComplete );
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
        return new Call(function(next) {
            frames.register(function(elapsed, cancel) {
                callback(elapsed, function() {
                    cancel();
                    next();
                });
            });
        });
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
}


