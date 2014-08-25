package;

import theatrics.render.Scene;
import theatrics.render.Game;
import theatrics.render.FillEntity;
import theatrics.script.Scriptable;
import theatrics.script.Sequence;
import theatrics.script.Call;
import theatrics.script.Delay;
import theatrics.util.Defer;
import theatrics.util.FrameEnter;


/** The layers in the scene */
enum Layers {
    primary;
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

        var entity = new FillEntity(0x0077ee, 10, 20, 50, 50);

        scene.add( Layers.primary, entity );

        var defer = new Defer();
        var frames = new FrameEnter();

        var sequencer = new Sequencer(frames, defer);

        var changeColor = Call.build(function() {
            entity.setColor( Math.floor( Math.random() * 0xffffff ) );
        });

        sequencer.loop([
            sequencer.repeat(3, [ changeColor, sequencer.delay(250) ]),
            sequencer.percent(500, function (percent) {
                entity.setColor(0xffff00 + Math.round(percent * 255));
            }),
            sequencer.once([
                sequencer.range(10, 100, 500, function (offset) {
                    entity.position( offset, offset * 2);
                }),
                sequencer.range(100, 10, 500, function (offset) {
                    entity.position( offset, offset * 2 );
                })
            ])
        ]).start();
    }
}

