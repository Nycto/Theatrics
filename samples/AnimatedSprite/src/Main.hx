package;

import theatrics.render.Scene;
import theatrics.render.Game;
import theatrics.render.SpriteSplitter;
import theatrics.render.FillEntity;
import theatrics.script.Sequence;
import theatrics.util.Defer;
import theatrics.util.FrameEnter;
import theatrics.util.Ease;
import theatrics.geom.Direction;
import theatrics.geom.Rectangle;


/** The layers in the scene */
enum Layers {
    primary;
}

/** Different positions for a character */
enum Actor {
    Walk( dir: Direction );
    Stand( dir: Direction );
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

        // A sequencer builds scriptable objects of different kinds
        var sequencer = new Sequencer(new FrameEnter(), new Defer());

        // Load the sprite and split it into different behaviors
        var animation = SpriteSplitter.load("assets/character.png")
                .addManyRows(new Rectangle(0, 0, 256, 256))
                .addRow( Actor.Walk(Direction.West), 4 )
                .skipRow().skipRow().skipRow()
                .addRow( Actor.Walk(Direction.East), 4 )
                .done()
                .addManyRows(new Rectangle(5 * 256, 0, 256, 256))
                .addRow( Actor.Stand(Direction.West), 1 )
                .skipRow().skipRow().skipRow()
                .addRow( Actor.Stand(Direction.East), 1 )
                .asAnimation( 100 );

        // Create an actual entity from the animation
        var actor = animation.entity();
        actor.position(100, 100);
        scene.get(Layers.primary).add( actor );

        // Create a script that walks the character from left to right and back
        var script = sequencer.loop([
            sequencer.untilFirst([
                sequencer.animateLoop(actor, Actor.Walk(Direction.East)),
                sequencer.range(100, 300, 1500, actor.x)
            ]),
            sequencer.animateOnce(actor, Actor.Stand(Direction.East)),
            sequencer.delay(500),
            sequencer.untilFirst([
                sequencer.animateLoop(actor, Actor.Walk(Direction.West)),
                sequencer.range(300, 100, 1500, actor.x)
            ]),
            sequencer.animateOnce(actor, Actor.Stand(Direction.West)),
            sequencer.delay(500)
        ]).start();

        // Stop button
        var stop = new FillEntity(0xff0000, 300, 100, 100, 50);
        scene.add( Layers.primary, stop );
        stop.onClick(function (_) {
            script.stop();
        });
    }
}

