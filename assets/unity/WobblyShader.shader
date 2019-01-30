// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/WobblyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 tex : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			sampler2D _NoiseTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
				fixed4 col = tex2Dlod(_NoiseTex, float4(v.uv, 0, 0));
				float d = 1 - (v.uv[1]*v.uv[1] + v.uv[0]*v.uv[0]) + col[0];
                
				o.vertex = UnityObjectToClipPos(v.vertex + 
				             float4(0.0, 0.5*(sin(_Time[2] + d*8) / 2 + 0.5), 
							 0.0, 0.0));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.tex = float4(d,0,0,0);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = float4(0, 0, (sin(_Time[2] + 
				                    i.tex[0]*8)/2 + 0.5), 1);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
