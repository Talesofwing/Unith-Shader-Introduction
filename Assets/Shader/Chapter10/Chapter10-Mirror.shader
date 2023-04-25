Shader "Unity Shaders Book/Chapter 10/Mirror" {

    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
    }

    SubShader {
        Tags {"RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
            fixed4 _MainTex_ST;

            struct a2v {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.pos);
                o.uv = i.uv;
                // Mirror needs to flip x
                o.uv.x = 1 - o.uv.x;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                return tex2D (_MainTex, i.uv);
            }

            ENDCG

        }

    }

    FallBack "Reflective/VertexLit"
}
