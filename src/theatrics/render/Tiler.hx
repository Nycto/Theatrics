package theatrics.render;

import openfl.display.Tilesheet;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.geom.Rectangle;
import theatrics.render.Entity;

/** A method used to construct an array of tilesheet instructions */
typedef InstructionPusher<T> =
    Float -> Float -> T -> Float -> Float -> Float -> Void;

/** Transforms a tiler draw operation */
class TilerTransform {

    /** The X coordinate */
    public var x(default, null): Float;

    /** The Y coordinate */
    public var y(default, null): Float;

    /** The scaling factor */
    public var scale(default, null): Float;

    /** The alpha transparency */
    public var alpha(default, null): Float;

    /** The rotation */
    public var rotate(default, null): Float;

    /** Constructor */
    public function new (
        x: Float = 0, y: Float = 0,
        scale: Float = 1, alpha: Float = 1, rotate: Float = 0
    ) {
        this.x = x;
        this.y = y;
        this.scale = scale;
        this.alpha = alpha;
        this.rotate = rotate;
    }

    /** Transforms a tiler draw instruction according to these rules */
    public function transform<T>( other: TilerDraw<T> ): TilerDraw<T> {
        return new TilerDraw<T>(
            other.tile,
            other.x + this.x,
            other.y + this.y,
            other.scale * this.scale,
            other.alpha * this.alpha,
            other.rotate + this.rotate
        );
    }

    /** Pushes this instruction onto an instruction set array */
    @:allow(theatrics.render.Tiler)
    private function transformPusher<T>(
        push: InstructionPusher<T>
    ): InstructionPusher<T> {
        // [ x, y, tileID, scale, rotation, red, green, blue, alpha ]
        return function(
            _x: Float, _y: Float, _tile: T,
            _scale: Float, _rotate: Float, _alpha: Float
        ) {
            push(
                x + _x, y + _y, _tile,
                scale * _scale, rotate + _rotate, alpha * _alpha
            );
        };
    }
}

/** A single draw instruction */
class TilerDraw<T: EnumValue> {

    /** The tile to draw */
    public var tile(default, null): T;

    /** The X coordinate */
    public var x(default, null): Float;

    /** The Y coordinate */
    public var y(default, null): Float;

    /** The scaling factor */
    public var scale(default, null): Float;

    /** The alpha transparency */
    public var alpha(default, null): Float;

    /** The rotation */
    public var rotate(default, null): Float;

    /** Constructor */
    public function new (
        tile: T,
        x: Float = 0,
        y: Float = 0,
        scale: Float = 1,
        alpha: Float = 1,
        rotate: Float = 0
    ) {
        this.tile = tile;
        this.x = x;
        this.y = y;
        this.scale = scale;
        this.alpha = alpha;
        this.rotate = rotate;
    }

    /** Pushes this instruction onto an instruction set array */
    @:allow(theatrics.render.Tiler)
    private function append( push: InstructionPusher<T> ): Void {
        // [ x, y, tileID, scale, rotation, red, green, blue, alpha ]
        push( x, y, tile, scale, rotate, alpha );
    }
}

/** An instruction set for where to draw tiles */
class TilerInstructions<T: EnumValue> {

    /** The array of instructions */
    @:allow(theatrics.render.Tiler)
    private var instructions = new List<TilerDraw<T>>();

    /** Default values to apply to all tiles */
    @:allow(theatrics.render.Tiler)
    private var defaults: TilerTransform;

    /** Constructor */
    public function new( defaults: TilerTransform = null ) {
        this.defaults = defaults;
    }

    /** Flags that a tile should be drawn at the given location */
    public function draw( instruction: TilerDraw<T> ): TilerInstructions<T> {
        instructions.push( instruction );
        return this;
    }

    /** Flags that a tile should be drawn at the given location */
    public function drawAt(
        tile: T, x: Float, y: Float
    ): TilerInstructions<T> {
        return draw(new TilerDraw<T>(tile, x, y));
    }
}

/** Allows a set of tile draw instructions to be applied to an entity */
class TilerApply {

    /** The tilesheet */
    private var sheet: Tilesheet;

    /** The instructions */
    private var instructions: Array<Float>;

    /** Constructor */
    @:allow(theatrics.render.Tiler)
    private function new ( sheet: Tilesheet, instr: Array<Float> ) {
        this.sheet = sheet;
        this.instructions = instr;
    }

    /** Draws these instructions on a sprite */
    public function drawOnGraphics( graphics: Graphics ): Void {
        sheet.drawTiles(
            graphics,
            instructions,
            false,
            Tilesheet.TILE_SCALE | Tilesheet.TILE_ALPHA
                | Tilesheet.TILE_ROTATION
        );
    }

    /** Draws these instructions on a sprite */
    public function drawOnSprite( sprite: Sprite ): Void {
        drawOnGraphics( sprite.graphics );
    }

    /** Draws these instructions on a sprite */
    public function drawOnEntity( entity: SpriteEntity ): Void {
        drawOnSprite( entity.sprite );
    }

    /** Draws these instructions on a sprite */
    public function entity(): SpriteEntity {
        var sprite = new Sprite();
        drawOnSprite( sprite );
        return new SpriteEntity( sprite );
    }
}

/**
 * A tiler lets you efficiently draw onto a sprite. You can build one of these
 * using a SpriteSplitter
 */
class Tiler<T: EnumValue> {

    /** The tilesheet */
    private var sheet: Tilesheet;

    /** The map of group keys to tilesheet ranges */
    private var groups = new Map<T, { low: Int, high: Int }>();

    /** Default values to apply to all tiles */
    private var defaults: TilerTransform;

    /** Constructs a new instance */
    private function new (
        sheet: Tilesheet,
        groups: Map<T, { low: Int, high: Int }>,
        defaults: TilerTransform
    ) {
        this.sheet = sheet;
        this.groups = groups;
        this.defaults = defaults;
    }

    /** Created from a sprite splitter */
    @:allow(theatrics.render.SpriteSplitter)
    private static function build<T: EnumValue> (
        data: BitmapData,
        rectangles: Map<T, List<Rectangle>>,
        defaults: TilerTransform = null
    ): Tiler<T> {
        var sheet = new Tilesheet(data);
        var groups = new Map<T, { low: Int, high: Int }>();

        for ( group in rectangles.keys() ) {
            var first: Int = null;
            var mostRecent: Int = null;
            for ( rectangle in rectangles.get(group) ) {
                mostRecent = sheet.addTileRect(rectangle);
                if ( first == null ) {
                    first = mostRecent;
                }
            }
            groups.set(group, { "low": first, "high": mostRecent });
        }

        return new Tiler( sheet, groups, defaults );
    }

    /** Sets the scaling factor for this instance */
    public function withScalingOf ( scale: Float ): Tiler<T> {
        if ( defaults == null ) {
            return new Tiler( sheet, groups, new TilerTransform(0, 0, scale) );
        }
        else {
            return new Tiler(
                sheet, groups,
                new TilerTransform(
                    defaults.x, defaults.y,
                    scale, defaults.alpha, defaults.rotate
                )
            );
        }
    }

    /**
     * Returns an index for a tile group. Selects a random index if there is
     * more than one index in the group
     */
    private function getIndex( group: T ): Int {
        var range = groups.get(group);
        if ( range == null ) throw "Group has no sprites: " + group;

        var delta = range.high - range.low + 1;
        if ( delta == 1 ) {
            return range.low;
        }
        else {
            return range.low + Math.floor( Math.random() * delta );
        }
    }

    /** Draws a set of tiling instructions onto a sprite */
    public function apply( instructions: TilerInstructions<T> ): TilerApply {
        var drawset = new Array<Float>();

        // [ x, y, tileID, scale, rotation, red, green, blue, alpha ]
        var push: InstructionPusher<T> = function push(
            x: Float, y: Float, tile: T,
            scale: Float, rotate: Float, alpha: Float
        ) {
            drawset.push(x);
            drawset.push(y);
            drawset.push( getIndex(tile) );
            drawset.push( scale );
            drawset.push( rotate );
            drawset.push( alpha );
        }

        if ( defaults != null ) {
            push = defaults.transformPusher(push);
        }

        if ( instructions.defaults != null ) {
            push = instructions.defaults.transformPusher(push);
        }

        for( op in instructions.instructions ) {
            op.append( push );
        }

        return new TilerApply( sheet, drawset );
    }
}

