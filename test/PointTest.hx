package;

import massive.munit.Assert;
import theatrics.geom.Point;

class PointTest {

    @Test
    public function pointsAreCastableToOpenFLPoints ():Void {
        var point: openfl.geom.Point = new Point(5, 20);

        Assert.areEqual( 5, point.x );
        Assert.areEqual( 20, point.y );
    }
}
