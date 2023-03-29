Shader "Unity Shaders Book/Chapter 7/Texture Properties" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
    }

    SubShader {
        Pass {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
    
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;        // 固定的寫法
                                       // xy: Tiling; zw: Offset

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD2;
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.vertex);
                o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 albedo = tex2D (_MainTex, i.uv).rgb;
                
                return float4 (albedo, 1.0f);
            }
            
            ENDCG
        }
    }

    FallBack "Specular"
}