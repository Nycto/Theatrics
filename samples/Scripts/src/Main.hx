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
import theatrics.util.Ease;


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

        // The animated entity
        var entity = new FillEntity(0x0077ee, 10, 10, 50, 50);
        scene.add( Layers.primary, entity );

        // A sequencer builds scriptable objects of different kinds
        var sequencer = new Sequencer(new FrameEnter(), new Defer());

        // Randomly changes the color of the box
        function changeColor() {
            entity.setColor( Math.floor( Math.random() * 0xffffff ) );
        }

        var script = sequencer.loop([
            sequencer.repeat(3, [
                Call.build(changeColor),
                sequencer.delay(250)
            ]),
            sequencer.percent(500, function (percent) {
                entity.setColor(0xffff00 + Math.round(percent * 255));
            }),
            sequencer.once([
                sequencer.range(10, 100, 500, function (offset) {
                    entity.position( offset, offset);
                }, Ease.quadInOut),
                sequencer.interval(200, function (count, next) {
                    count == 3 ? next() : changeColor();
                }),
                sequencer.range(100, 10, 1000, function (offset) {
                    entity.position( offset, offset );
                }, Ease.elasticInOut)
            ])
        ]).start();

        // Stop button
        var stop = new FillEntity(0xff0000, 300, 100, 100, 50);
        scene.add( Layers.primary, stop );
        stop.onClick(function (_) {
            script.stop();
        });
    }
}

