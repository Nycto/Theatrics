package theatrics.render;

import openfl.display.Sprite;
import openfl.display.DisplayObject;
import openfl.events.MouseEvent;

/**
 * A renderable object
 */
interface Entity {

    /** The sprite that represents entity */
    function getDisplayObject(): DisplayObject;
}

/**
 * An entity that just wraps another sprite
 */
class SpriteEntity implements Entity {

    /** The sprite that represents entity */
    public var sprite(default, null): Sprite;

    /** Entity */
    public function new( sprite: Sprite ) {
        this.sprite = sprite;
    }

    /** The sprite that represents entity */
    public function getDisplayObject(): DisplayObject {
        return sprite;
    }

    /** Positions this entity */
    public function position( x: Int, y: Int ): SpriteEntity {
        sprite.x = x;
        sprite.y = y;
        return this;
    }

    /** Positions this entity */
    public function x( x: Int ): SpriteEntity {
        sprite.x = x;
        return this;
    }

    /** Positions this entity */
    public function y( y: Int ): SpriteEntity {
        sprite.y = y;
        return this;
    }

    /** Changes the dimensions of this entity */
    public function dimensions( width: Int, height: Int ): SpriteEntity {
        sprite.width = width;
        sprite.height = height;
        return this;
    }

    /** Hooks up a click event handler */
    public function onClick(handler: MouseEvent -> Void): Void {
        sprite.addEventListener("click", function ( event: Dynamic ) {
            cast(event, MouseEvent);
            handler(event);
        });
    }
}


