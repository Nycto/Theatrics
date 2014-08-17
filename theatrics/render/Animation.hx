package theatrics.render;

import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;

import theatrics.geom.Dimensions;
import theatrics.util.FrameEnter;
import theatrics.render.Entity;

/**
 * All the data needed to create an animated sprite
 */
class Animation<T: EnumValue> {

    /** The dimensions of this sprite */
    private var dimens: Dimensions;

    /** Maps a group identifier to a list of sprite rectangles */
    @:allow(theatrics.render.AnimatedEntity)
    private var frames: Map<T, Array<BitmapData>>;

    /** The number of milliseconds per frame */
    @:allow(theatrics.render.AnimatedEntity)
    private var speed: Int;

    /** Constructor */
    private function new (
        dimens: Dimensions,
        frames: Map<T, Array<BitmapData>>,
        speed: Int
    ){
        this.dimens = dimens;
        this.frames = frames;
        this.speed = speed;
    }

    /** Given a bitmap and a map of frames, this creates a map of frames */
    @:allow(theatrics.render.SpriteSplitter)
    public static function build<T: EnumValue>(
        data: BitmapData,
        dimens: Dimensions,
        groups: Map<T, List<Rectangle>>,
        speed: Int
    ): Animation<T> {
        var frames = new Map<T, Array<BitmapData>>();

        for ( group in groups.keys() ) {
            var frameList = new Array<BitmapData>();
            for ( rectangle in groups.get(group) ) {
                var frame = new BitmapData(
                    dimens.widthInt(),dimens.heightInt());
                frame.copyPixels(data, rectangle, new Point(0, 0));
                frameList.push( frame );
            }
            frames.set( group, frameList );
        }

        return new Animation( dimens, frames, speed );
    }

    /** Creates a new entity */
    public function entity( frameEnter: FrameEnter ): AnimatedEntity<T> {
        return new AnimatedEntity<T>(this, frameEnter);
    }
}

/**
 * Bundles up data about the currently displayed animation
 */
class AnimationBehavior {

    /** The current animation being displayed */
    private var frames: Array<BitmapData>;

    /** The frame being rendered */
    private var frame: Int = 0;

    /** Constructr */
    private function new ( frames: Array<BitmapData> ) {
        this.frames = frames;
    }

    /** Builds a map of behaviors from a map of frame arrays */
    @:allow(theatrics.render.AnimatedEntity)
    private static function build<T: EnumValue>(
        input: Map<T, Array<BitmapData>>
    ): Map<T, AnimationBehavior> {
        var out = new Map<T, AnimationBehavior>();
        for ( key in input.keys() ) {
            out.set(key, new AnimationBehavior(input.get(key)));
        }
        return out;
    }

    /** Returns whether this behavior actually requires animation */
    @:allow(theatrics.render.AnimatedEntity)
    private inline function isAnimated(): Bool {
        return frames.length != 1;
    }

    /** Starts animating this set of frames */
    @:allow(theatrics.render.AnimatedEntity)
    private inline function start( sprite: Bitmap ) {
        frame = 0;
        sprite.bitmapData = frames[0];
    }

    /** Displays the next frame */
    @:allow(theatrics.render.AnimatedEntity)
    private inline function next( sprite: Bitmap ) {
        frame++;
        if ( frame >= frames.length ) {
            frame = 0;
        }
        sprite.bitmapData = frames[frame];
    }
}

/**
 * An animated entity
 */
class AnimatedEntity<T: EnumValue> implements Entity {

    /** Maps a group identifier to a list of sprite rectangles */
    private var behaviors: Map<T, AnimationBehavior>;

    /** The number of milliseconds per frame */
    private var speed: Int;

    /** Lets you register a handler for the animations */
    private var frameEnter: FrameEnter;

    /** The underlying sprite associated with this entity */
    private var sprite = new Bitmap();

    /** Cancels the frame enter event handler */
    private var cancel: Void -> Void = null;

    /** The currently running animation */
    private var running: AnimationBehavior;

    /** The time at which to run the next frame */
    private var nextFrameAt: Int;

    /** Constructr */
    public function new ( data: Animation<T>, frameEnter: FrameEnter ) {
        this.behaviors = AnimationBehavior.build(data.frames);
        this.speed = data.speed;
        this.frameEnter = frameEnter;
    }

    /** The sprite that represents entity */
    public function getDisplayObject(): DisplayObject {
        return sprite;
    }

    /** Cancels the animation if it is currently running */
    public function stop(): AnimatedEntity<T> {
        if ( cancel != null ) {
            cancel();
            cancel = null;
        }
        return this;
    }

    /** Shows a specific animation */
    public function repeat( key: T ): Void {
        running = behaviors.get(key);
        if ( running == null ) {
            throw "Animation is not defined: " + key;
        }

        running.start( sprite );

        // For single frame animations, there really is no animation. Cancel
        // the handler so we aren't spinning our wheels.
        if ( !running.isAnimated() ) {
            stop();
        }
        // If the event handler is already registered, we can just use
        // the existing version.
        else if ( cancel == null ) {
            nextFrameAt = speed;
            cancel = frameEnter.register(function(time, _) {
                if ( time >= nextFrameAt ) {
                    running.next( sprite );
                    nextFrameAt = time + speed;
                }
            });
        }
    }
}

