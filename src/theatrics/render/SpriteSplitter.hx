package theatrics.render;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import theatrics.geom.Dimensions;
import theatrics.render.Tiler;
import theatrics.render.Animation;

/**
 * A sprite splitter makes it easy to take a bitmap and cut it in pieces
 */
class SpriteSplitter<T: EnumValue> {

    /** The raw data */
    private var data: BitmapData;

    /** Maps a group identifier to a list of sprite rectangles */
    private var groups(default, never) = new Map<T, List<Rectangle>>();

    /** Constructor */
    public function new ( data: BitmapData ) {
        this.data = data;
    }

    /** Returns the rectangles for a group */
    private function getRectangles( group: T ): List<Rectangle> {
        var list = groups.get(group);

        if ( list != null ) {
            return list;
        }
        else {
            var newList = new List<Rectangle>();
            groups.set( group, newList );
            return newList;
        }
    }

    /** Adds a rectangle to a an image group */
    public function add ( group: T, area: Rectangle ): SpriteSplitter<T> {
        getRectangles(group).add( area );
        return this;
    }

    /** Automatically splits this sprite */
    public function auto(
        group: T, total: Int, perRow: Int
    ): SpriteSplitter<T> {

        var rows = Math.ceil(total / perRow);

        var width = Math.floor(data.width / perRow);
        var height = Math.floor(data.height / rows);

        for(y in 0...rows) {
            for(x in 0...perRow) {
                if ( (y * perRow) + x <= total ) {
                    add(group, new Rectangle(
                        x * width, y * height,
                        width, height
                    ));
                }
            }
        }

        return this;
    }

    /** Adds a row based on an initial rectangle */
    public function addRow(
        group: T, count: Int, prototype: Rectangle
    ): SpriteSplitter<T> {
        for(i in 0...count) {
            var offset = i * prototype.width;
            var copy = prototype.clone();
            copy.x = prototype.x + offset;
            add(group, copy);
        }

        return this;
    }

    /** Adds a row based on an initial rectangle */
    public function addManyRows(
        prototype: Rectangle
    ): SpriteSplitRowAdder<T> {
        return new SpriteSplitRowAdder( prototype, this );
    }

    /**
     * Generates a tiler. Tiler are useful when you want to draw onto an entity
     * multiple times from the same source.
     */
    public function asTiler( transform: TilerTransform = null ): Tiler<T> {
        return Tiler.build( data, groups, transform );
    }

    /** Generates an animation */
    public function asAnimation(
        dimentions: Dimensions, speed: Int
    ): Animation<T> {
        return Animation.build( data, dimentions, groups, speed );
    }
}

/**
 * A helper class for adding many rows from a sprite
 */
class SpriteSplitRowAdder<T> {

    /** The prototype rectangle */
    private var prototype: Rectangle;

    /** Adds a row */
    private var splitter: SpriteSplitter<T>;

    /** The current row */
    private var rowOffset: Int = 0;

    /** Constructor */
    @:allow(theatrics.render.SpriteSplitter)
    private function new(
        prototype: Rectangle,
        splitter: SpriteSplitter<T>
    ) {
        this.prototype = prototype;
        this.splitter = splitter;
    }

    /** Adds a row and increments the internal row offset */
    public function addRow( group: T, count: Int ): SpriteSplitRowAdder<T> {
        var copy = prototype.clone();
        copy.y = rowOffset * prototype.height;
        splitter.addRow( group, count, copy );
        rowOffset++;
        return this;
    }

    /** Returns back to the sprite splitter that was modified */
    public function done(): SpriteSplitter<T> {
        return splitter;
    }

    /** Generates an animation */
    public function asAnimation( speed: Int ): Animation<T> {
        return splitter.asAnimation(
            Dimensions.fromRectangle(prototype),
            speed
        );
    }
}


