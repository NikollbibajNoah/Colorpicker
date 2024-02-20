package colorpicker.shader;

import hxsl.Shader;
import h3d.shader.Base2d;

class Hue extends Shader {
    
    static var SRC = {

        @:import Base2d;

        function fragment():Void {
            var hue = calculatedUV.x * 360 / 360;

            var c = hsv2rgb(vec3(hue, 1, 1));

            pixelColor = vec4(c.x, c.y, c.z, 1);
        }

        function hsv2rgb(c:Vec3):Vec3 {
            c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
            var K:Vec4 = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            var p:Vec3 = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
          }
    }
}