package shaders;

import flixel.system.FlxAssets.FlxShader;

class IconTransition extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform sampler2D icon;
        uniform float scale;

        void main()
        {
            vec2 uv = openfl_TextureCoordv;

            vec2 centered = uv - vec2(0.5);
            centered /= scale;
            vec2 newUV = centered + vec2(0.5);

            if (newUV.x < 0.0 || newUV.x > 1.0 || newUV.y < 0.0 || newUV.y > 1.0)
            {
                gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
                return;
            }

            vec4 tex = texture2D(icon, newUV);

            // THIS is the FUCKING KEY LINE:
            if (tex.a < 0.1)
            {
                gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            }
            else
            {
                gl_FragColor = vec4(0.0);
            }
        }
    ')
    
    public function new()
    {
        super();
    }
}