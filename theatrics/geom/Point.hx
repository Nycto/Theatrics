package theatrics.geom;

/**
 * An immutable point
 */
abstract Point({x: Float, y: Float}) {

    /** Constructor */
    public inline function new ( x: Float, y: Float ) {
        this = { x: x, y: y };
    }

    /** Convert to an openfl point */
    @:to public function toOpenFLPoint(): openfl.geom.Point {
        return new openfl.geom.Point(this.x, this.y);
    }
}

