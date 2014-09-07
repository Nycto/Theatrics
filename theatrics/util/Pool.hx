package theatrics.util;

/**
 * A pool of objects
 */
class Pool<T, P> {

    /** The maximum number of objects to store */
    private var max: Int;

    /** The function for building new instances */
    private var builder: P -> T;

    /** Takes an existing object and "re-instantiates" it */
    private var reset: Null<T -> P -> Void>;

    /** The available objects */
    private var pool = new Array<T>();

    /** Constructor */
    public function new (
        max: Int,
        builder: P -> T,
        reset: T -> P -> Void = null
    ) {
        this.max = max;
        this.builder = builder;
        this.reset = reset;
    }

    /** Gets a new object from the pool */
    public function checkout( conf: P ): T {
        if ( pool.length > 0 ) {
            var obj = pool.pop();
            if ( reset != null ) {
                reset(obj, conf);
            }
            return obj;
        }
        else {
            return builder(conf);
        }
    }

    /** Returns an object to the pool */
    public function checkin( obj: T ) {
        if ( pool.length < max ) {
            pool.push( obj );
        }
    }
}

