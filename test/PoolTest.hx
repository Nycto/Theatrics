package;

import massive.munit.Assert;
import theatrics.util.Pool;

class PoolTest {

    @Test
    public function checkout(): Void {
        var pool = new Pool<{ value: Int }, { inc: Int }>( 2,
            function(conf) { return { value: conf.inc }; }
        );

        Assert.areEqual( 20, pool.checkout({ inc: 20 }).value );
        Assert.areEqual( 20, pool.checkout({ inc: 20 }).value );
        Assert.areEqual( 20, pool.checkout({ inc: 20 }).value );
    }

    @Test
    public function checkin(): Void {
        var pool = new Pool<{ value: Int }, { inc: Int }>(
            1,
            function(conf) { return { value: conf.inc }; },
            function(obj, conf) { obj.value = obj.value + conf.inc; }
        );

        var value = pool.checkout({ inc: 20 });
        Assert.areEqual( 20, value.value );

        pool.checkin(value);

        Assert.areEqual( 25, pool.checkout({ inc: 5 }).value );
    }
}
