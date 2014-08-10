package theatrics.render;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import theatrics.render.Tiler;

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

    /**
     * Generates a tiler. Tiler are useful when you want to draw onto an entity
     * multiple times from the same source.
     */
    public function asTiler( transform: TilerTransform = null ): Tiler<T> {
        return Tiler.build( data, groups, transform );
    }
}


