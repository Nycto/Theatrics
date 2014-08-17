package theatrics.render;

import openfl.display.Sprite;
import openfl.display.DisplayObject;
import theatrics.render.Entity;

/**
 * Layers contain a list of entities
 */
class Layer implements Entity {

    /** The sprite that represents this scene */
    private var sprite(default, never) = new Sprite();

    /** Constructor */
    public function new() {}

    /** The sprite that represents entity */
    public function getDisplayObject(): DisplayObject {
        return sprite;
    }

    /** Adds an entity to this layer */
    public function add( entity: Entity ): Layer {
        sprite.addChild( entity.getDisplayObject() );
        return this;
    }
}


