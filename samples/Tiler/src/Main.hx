package;

import theatrics.render.Scene;
import theatrics.render.Game;
import theatrics.render.SpriteSplitter;
import theatrics.render.Tiler;
import theatrics.geom.Rectangle;

/** The layers in the scene */
enum Layers {
    primary;
}

/** The different parts of the sprite */
enum Floor {
    stone;
    sand;
}

class Main {

    static function main() {

        // A game is the anchor for the different scenes
        var game = new Game(openfl.Lib.current.stage).noScale().topLeft();

        // A scene is a collection of layers
        var scene = new SceneBuilder<Layers>()
            .add(Layers.primary)
            .build();

        // Tell the game which scene to use
        game.use(scene);

        // Take a sprite and split it up into different rows
        // A tiler allows you quickly draw static images onto a sprite
        var tiles = SpriteSplitter.load("assets/tiles.png")
            .addRow( Floor.stone, 6, new Rectangle(0, 0,  50, 50) )
            .addRow( Floor.sand, 6,  new Rectangle(0, 50, 50, 50) )
            .asTiler();

        // A set of re-usable instructions for drawing the desired pattern
        var instructions = new TilerInstructions<Floor>()
            .drawAt(Floor.stone, 0, 0)
            .drawAt(Floor.stone, 50, 0)
            .drawAt(Floor.stone, 100, 0)
            .drawAt(Floor.stone, 0, 50)
            .drawAt(Floor.stone, 0, 100)
            .drawAt(Floor.stone, 50, 100)
            .drawAt(Floor.stone, 100, 100)
            .drawAt(Floor.stone, 100, 50)
            .drawAt(Floor.sand, 50, 50);

        // Finally, generate an entity and add it to the scene
        scene.add( Layers.primary, tiles.apply(instructions).entity() );
    }
}

