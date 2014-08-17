package theatrics.render;

import openfl.display.Sprite;

/**
 * Builds a new scene
 */
class SceneBuilder<T: EnumValue> {

    /** A Set of layers that have already been referenced */
    private var used(default, never): Map<T, Bool> = new Map<T, Bool>();

    /** A list of layers in the order they should be applied */
    private var order(default, never) = new List<T>();

    /** Constructor */
    public function new() {}

    /** Adds a layer */
    public function add ( layer: T ): SceneBuilder<T> {
        if ( used.exists(layer) ) throw "Layer already defined: " + layer;
        used.set(layer, true);
        order.push(layer);
        return this;
    }

    /** Builds a scene */
    public function build(): Scene<T> {
        return new Scene<T>( order );
    }
}

/**
 * Contains all the layers and entities for rendering a single scene
 */
class Scene<T: EnumValue> {

    /** The sprite that represents this scene */
    @:allow(theatrics.render.Game)
    private var sprite(default, never) = new Sprite();

    /** A Set of layers that have already been referenced */
    private var layers(default, never): Map<T, Layer> = new Map<T, Layer>();

    /** Constructor */
    @:allow(theatrics.render.SceneBuilder)
    private function new( layers: List<T> ) {
        for ( key in layers ) {
            var layer = new Layer();
            sprite.addChild( layer.getDisplayObject() );
            this.layers.set( key, layer );
        }
    }

    /** Returns the layer for a given key */
    public function get( key: T ): Layer {
        var value = layers.get(key);
        if ( value == null ) throw "Layer does not exist: " + key;
        return value;
    }

    /** Adds an entity to a layer */
    public function add( layer: T, entity: Entity ): Scene<T> {
        get(layer).add(entity);
        return this;
    }
}

