package theatrics.render;

import theatrics.render.Scene;

import openfl.display.Stage;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;

/**
 * Contols which scene is currently in use
 */
class Game {

    /** The stage being performed on */
    private var stage: Stage;

    /** The current primary scene */
    private var currentScene: Scene<EnumValue>;

    /** Constructor */
    public function new( stage: Stage ){
        this.stage = stage;
    }

    /** Aligns the stage to the top left */
    public function topLeft(): Game {
        stage.align = StageAlign.TOP_LEFT;
        return this;
    }

    /** Turns off scaling */
    public function noScale(): Game {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        return this;
    }

    /** Switches over to this scene */
    public function use<T: EnumValue>( scene: Scene<T> ) {
        if ( currentScene != null ) {
            stage.removeChild( currentScene.sprite );
        }

        // Ugh. Haxe's type system isn't powerful enough to model this properly
        // without an explicit cast
        var enumScene = cast scene;

        currentScene = enumScene;
        stage.addChild( currentScene.sprite );
    }
}


