package theatrics.util;

/**
 * Lazy loads an object
 */
class Lazy<T> {

    /** The builder */
    private var builder: Void -> T;

    /** The built value */
    private var data: T;

    /** Constructor */
    public function new( builder: Void -> T ) {
        this.builder = builder;
    }

    /** Returns the data */
    public function get(): T {
        if ( this.data == null ) {
            this.data = this.builder();
            this.builder = null;
        }
        return this.data;
    }
}
