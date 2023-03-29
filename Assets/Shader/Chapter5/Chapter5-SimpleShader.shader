// Shader : 定義名字
Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
    Properties {
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {
        Pass {
            CGPROGRAM

            // 聲明vertex shader & fragment shader的函數
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _Color;
            sampler2D _MainTex;
            
            // a2v : application to vertex shader
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
                float2 uv : TEXCOORD0;
            };
            
            v2f vert (a2v v) {
                // mul(UNITY_MATRIX_MVP, v): auto replace
                
                v2f o;
                // v.vertex.y = sin(v.vertex.y + _Time.y);
                // v.vertex.z = cos(v.vertex.z + _Time.z);
                o.pos = UnityObjectToClipPos (v.vertex);
                o.color = v.normal * 0.5f + fixed3(0.5f, 0.5f, 0.5f);
                o.uv = v.uv;
                
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                fixed3 c = i.color;
                c *= _Color.rgb;
                fixed4 color = tex2D (_MainTex, i.uv);
                return color * _Color;
                return fixed4 (c, 1.0);
            }

            ENDCG
        }
    }
}