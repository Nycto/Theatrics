package theatrics.render;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import theatrics.render.Entity;

/**
 * An entity that just wraps another sprite
 */
class FillEntity extends SpriteEntity {

    /** Constructor */
    public function new(color: Int, x: Int, y: Int, width: Int, height: Int) {

        var sprite = new Sprite();
        sprite.addChild(
            new Bitmap (new BitmapData(width, height, false, color)));
        sprite.x = x;
        sprite.y = y;
        sprite.width = width;
        sprite.height = height;

        super(sprite);
    }

    /** Sets the color of this fill entity */
    public function setColor( color: Int ) {
        this.sprite.addChild(new Bitmap(new BitmapData(
            Math.floor(this.sprite.width),
            Math.floor(this.sprite.height),
            false, color
        )));

        // Remove afterward to maintain the width and height
        this.sprite.removeChildAt(0);
    }
}

