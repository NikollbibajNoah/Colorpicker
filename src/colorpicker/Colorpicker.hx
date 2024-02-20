package colorpicker;

import h2d.Object;
import hxd.res.DefaultFont;
import h2d.Text;
import h3d.Vector;
import hxd.Key;
import h2d.Graphics;
import hxsl.Shader;
import h2d.col.Point;
import h2d.Tile;
import h2d.Bitmap;
import colorpicker.shader.*;

using hxd.Math;
using StringTools;


class Colorpicker {

    var hsv = new Vector(360, 100, 100);

    var svMap:Bitmap;
    var svMap_width:Int = 256;
    var svMap_height:Int = 256;
    var svMap_x:Float = 32;
    var svMap_y:Float = 32;
    var svShader:SV;
    var svReady:Bool;

    var hueMap:Bitmap;
    var hueMap_width:Int = 256;
    var hueMap_height:Int = 40;
    var hueMap_x:Float = 32;
    var hueMap_y:Float;
    var hueShader:Shader;
    var hueReady:Bool;

    //Preview
    var g:Graphics;
    var preview_width:Int = 128;
    var preview_height:Int = 128;
    var preview_x:Float;
    var preview_y:Float = 32;

    //Tools
    var svPicker_x:Float;
    var svPicker_y:Float;
    var sv_PickerRadius:Int = 12;

    var huePicker_x:Float;
    var huePickerSize:Float = 10;


    var text:Text;

    var color:Int;

    var scene:Object;

    public function new(scene:Object) {
    
        this.scene = scene;

        init();
    }

    function init():Void {
        svMap = new Bitmap(Tile.fromColor(0, svMap_width, svMap_height), scene);
        svMap.x = svMap_x;
        svMap.y = svMap_y;
        svMap.addShader(svShader = new SV());

        hueMap_y = svMap_y + svMap_height + 16;
        preview_x = svMap_x + svMap_width + 16;

        hueMap = new Bitmap(Tile.fromColor(0, hueMap_width, hueMap_height), scene);
        hueMap.x = hueMap_x;
        hueMap.y = hueMap_y;
        hueMap.addShader(hueShader = new Hue());


        ///Preivew
        g = new Graphics(scene);

        //Tools
        svPicker_x = svMap_x;
        svPicker_y = svMap_y;

        huePicker_x = hueMap_x;

        text = new Text(DefaultFont.get(), scene);
        text.x = preview_x;
        text.y = preview_y + preview_height + 32;
        text.font.resizeTo(18);
        text.text = 'HSV: ${hsv.x}, ${hsv.y}, ${hsv.z}';
    }

    public function update():Void {
        var rgb = Converter.hsvToRgb(hsv.x, hsv.y, hsv.z);
        var hex = Converter.rgbToHex(rgb[0], rgb[1], rgb[2]);
        g.clear();
        g.beginFill(hex);
        g.drawRect(preview_x, preview_y, preview_width, preview_height);
        g.endFill();


        //Draw Picker
        g.beginFill(0x666262, .75);
        g.drawCircle(svPicker_x, svPicker_y, sv_PickerRadius, sv_PickerRadius * 2);
        g.endFill();

        g.beginFill(0xC5BFBF, 1);
        g.drawCircle(svPicker_x, svPicker_y, sv_PickerRadius / 2, sv_PickerRadius);
        g.endFill();

        //Hue
        g.beginFill(0xC5BFBF, 8);
        g.drawRect(huePicker_x, hueMap_y, huePickerSize, hueMap_height);
        g.endFill();

        var prec = 10;
        var rgb = Converter.hsvToRgb(hsv.x, hsv.y, hsv.z);
        var hex = Converter.rgbToHex(rgb[0], rgb[1], rgb[2]).hex();

        text.text = 'HSV: ${Math.round(hsv.x * prec) / prec}, ${Math.round(hsv.y * prec) / prec}, ${Math.round(hsv.z * prec) / prec}\nRGB: ${rgb[0]}, ${rgb[1]}, ${rgb[2]}\nHex: 0x${hex}';


        var mouse = new Point(scene.getScene().mouseX, scene.getScene().mouseY);

        ///SV
        if (Key.isPressed(Key.MOUSE_LEFT) && !svReady && mouse.x > svMap_x && mouse.x < svMap_x + svMap_width && mouse.y > svMap_y && mouse.y < svMap_y + svMap_height) {
            svReady = true;
        }

        if (Key.isDown(Key.MOUSE_LEFT) && svReady) {
            var pos = getAbsPos(svMap_x, svMap_width, svMap_y, svMap_height);

            ///Saturation
            hsv.y = pos[0] * 100;

            ///Value
            hsv.z = pos[1] * 100;


            //Update Picker
            svPicker_x = mouse.x;
            svPicker_y = mouse.y;

            svPicker_x = Math.clamp(svPicker_x, svMap_x, svMap_x + svMap_width);
            svPicker_y = Math.clamp(svPicker_y, svMap_y, svMap_y + svMap_height);
        }

        if (Key.isReleased(Key.MOUSE_LEFT) && svReady) {
            svReady = false;
        }

        
        //Hue
        if (Key.isPressed(Key.MOUSE_LEFT) && !hueReady && mouse.x > hueMap_x && mouse.x < hueMap_x + hueMap_width && mouse.y > hueMap_y && mouse.y < hueMap_y + hueMap_height) {
            hueReady = true;
        }

        if (Key.isDown(Key.MOUSE_LEFT) && hueReady) {
            var pos = getAbsPos(hueMap_x, hueMap_width);

            ///Hue
            var v = pos[0];
            hsv.x = v * 360;

            //Apply Shader
            svShader.hue = v;

            //Update Picker
            huePicker_x = mouse.x - huePickerSize / 2;

            huePicker_x = Math.clamp(huePicker_x, hueMap_x, hueMap_x + hueMap_width - huePickerSize);
        }

        if (Key.isReleased(Key.MOUSE_LEFT) && hueReady) {
            hueReady = false;
        }


        ///Copy Colors
        var x = text.x;
        var y = text.y;
        var width = text.textWidth;
        var height = text.textHeight / 3;

        if (Key.isPressed(Key.MOUSE_LEFT)) {
            if (mouse.x > x && mouse.x < x + width && mouse.y > y && mouse.y < y + height) {
                trace('${Math.round(hsv.x * prec) / prec}, ${Math.round(hsv.y * prec) / prec}, ${Math.round(hsv.z * prec) / prec}');

            }
            else if (mouse.x > x && mouse.x < x + width && mouse.y > y && mouse.y < y + (height * 2)) {
                trace('${rgb[0]}, ${rgb[1]}, ${rgb[2]}');
            }
            else if (mouse.x > x && mouse.x < x + width && mouse.y > y && mouse.y < y + (height * 3)) {
                trace('0x${hex}');   
            }
        }
    }

    function getAbsPos(dx:Float, dw:Int, ?dy:Float, ?dh:Int) {
        var mouse = new Point(scene.getScene().mouseX, scene.getScene().mouseY);

        var w = (mouse.x - dx) / dw;
        var h = (mouse.y - dy) / dh;

        w = Math.clamp(w);
        h = Math.clamp(h);

        return [w, h];
    }  
}