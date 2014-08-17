package theatrics.geom;

import openfl.geom.Rectangle;

/** A width and height */
class Dimensions {

    /** The width */
    public var width(default, null): Float;

    /** The height */
    public var height(default, null): Float;

    /** Constructor */
    public function new ( width: Float, height: Float ) {
        this.width = width;
        this.height = height;
    }

    /** Creates an instance from a rectangle */
    public static function fromRectangle ( rectangle: Rectangle ): Dimensions {
        return new Dimensions( rectangle.width, rectangle.height );
    }

    /** Returns the width as a rounded int */
    public function widthInt(): Int {
        return Math.round(width);
    }

    /** Returns the height as a rounded int */
    public function heightInt(): Int {
        return Math.round(height);
    }
}

