package colorpicker;

using StringTools;

class Converter {
    public static function rgbToVec(r:Float, g:Float, b:Float) {
        var vr = r / 255;
        var vg = g / 255;
        var vb = b / 255;

        return [vr, vg, vb];
    }

    public static function vecToRgb(r:Float, g:Float, b:Float) {
        var rgbr = r * 255;
        var rgbg = r * 255;
        var rgbb = r * 255;

        return [rgbr, rgbg, rgbb];
    }

    public static function hsvToRgb(h:Float, s:Float, v:Float) {
		var r:Float = 0, g:Float = 0, b:Float = 0, i:Float, f:Float, p:Float, q:Float, t:Float;
		h %= 360;

		if(v==0) 
		{

			v = 0.01;
		}
		s*=0.01;
		v*=0.01;
		h/=60;
		i = Math.floor(h);
		f = h-i;
		p = v*(1-s);
		q = v*(1-(s*f));
		t = v*(1-(s*(1-f)));
		if (i==0) {r=v; g=t; b=p;}
		else if (i==1) {r=q; g=v; b=p;}
		else if (i==2) {r=p; g=v; b=t;}
		else if (i==3) {r=p; g=q; b=v;}
		else if (i==4) {r=t; g=p; b=v;}
		else if (i==5) {r=v; g=p; b=q;}

		return [cast r * 255, cast g * 255, cast b * 255];
	}

    public static function rgbToHex(r:Int, g:Int, b:Int):Int {
        var r = (r & 0xFF) << 16;
        var g = (g & 0xFF) << 8;
        var b = (b & 0xFF);

        return Std.parseInt('0x' + (r + g + b).hex());
    }
}