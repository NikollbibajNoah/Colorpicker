package;

import colorpicker.*;

class Main extends hxd.App {

    var colorpicker:Colorpicker;

    static function main() {
        new Main();
    }

    override function init():Void {
        engine.backgroundColor = 0x141414;

        colorpicker = new Colorpicker(s2d);
    }

    override function update(dt:Float):Void {
        
        colorpicker.update();
    }
}