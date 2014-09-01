package theatrics.render;

import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl.geom.Point;

import theatrics.geom.Dimensions;
import theatrics.util.FrameEnter;
import theatrics.render.Entity;
import theatrics.script.Interval;
import theatrics.script.Scriptable;
import theatrics.script.Call;

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
    public function entity(): AnimatedEntity<T> {
        return new AnimatedEntity<T>(this);
    }
}

/**
 * An animated entity
 */
class AnimatedEntity<T: EnumValue> extends SpriteEntity {

    /** Maps a group identifier to a list of sprite rectangles */
    private var animation: Animation<T>;

    /** The underlying sprite associated with this entity */
    private var bitmap = new Bitmap();

    /** Constructr */
    public function new ( data: Animation<T> ) {
        var sprite = new Sprite();
        sprite.addChild( bitmap );
        super(sprite);

        this.animation = data;
    }

    /** Returns the frames for a specific animation */
    private inline function getFrames( key: T ): Array<BitmapData> {
        var frames = animation.frames.get(key);
        if ( frames == null ) {
            throw "Animation is not defined: " + key;
        }
        return frames;
    }

    /** Returns a script for a single frame animation */
    private function oneFrame( frame: BitmapData ): Scriptable {
        return Call.build(function () {
            bitmap.bitmapData = frame;
        });
    }

    /** Runs a specific animation one time through */
    public function once( frameEnter: FrameEnter, key: T ): Scriptable {
        var frames = getFrames(key);

        if ( frames.length == 1 ) {
            return oneFrame( frames[0] );
        }
        else {
            return new Interval(
                frameEnter,
                animation.speed,
                function(frame, done) {
                    if ( frame >= frames.length ) {
                        done();
                    }
                    else {
                        bitmap.bitmapData = frames[frame];
                    }
                }
            );
        }
    }

    /** Runs a specific animation on loop */
    public function loop( frameEnter: FrameEnter, key: T ): Scriptable {
        var frames = getFrames(key);

        if ( frames.length == 1 ) {
            return oneFrame( frames[0] );
        }
        else {
            return new Interval(
                frameEnter,
                animation.speed,
                function(frame, _) {
                    bitmap.bitmapData = frames[frame % frames.length];
                }
            );
        }
    }
}

