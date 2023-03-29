Shader "Unity Shaders Book/Chapter 8/Blend Operations" {
    Properties {
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range (0, 1)) = 1
    }

    SubShader {
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

        Pass {
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha, One Zero

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (a2v i) {
                v2f o;

                o.pos = UnityObjectToClipPos (i.vertex);

                // o.uv = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // 等價
                o.uv = TRANSFORM_TEX (i.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 texColor = tex2D (_MainTex, i.uv);
                
                return fixed4 (texColor.rgb * _Color.rgb, texColor.a * _AlphaScale);
            }
            
            ENDCG
        }
    }    

    Fallback "Transparent/VertexLit"
}