package shaders;

import flixel.system.FlxAssets.FlxShader;

class IconTransition extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        // this sucks, completely, this just sucks
        void main()
        {
            vec4 tex = flixel_texture2D(bitmap,openfl_TextureCoordv);

            gl_FragColor = vec4(mix(tex.rgb, vec3(0.0), 1.0), 1.0 - tex.a);
        }
    ')
    
    public function new()
    {
        super();
    }
}