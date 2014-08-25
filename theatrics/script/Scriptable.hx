package theatrics.script;

import theatrics.util.FrameEnter;

/**
 * Represents an action that can be executed
 */
interface Scriptable {

    /** Starts this scriptable action */
    function start ( onComplete: Null<Void -> Void> = null ): Void;
}

