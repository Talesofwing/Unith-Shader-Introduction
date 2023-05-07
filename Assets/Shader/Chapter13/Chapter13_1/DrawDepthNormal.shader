Shader "Unity Shaders Book/Chapter 13/Draw Depth Normal" {

    Properties {
        _MainTex ("Main Tex", 2D) = "black"
    }

    SubShader {
        tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
            #include "../../Common/zero.cginc"

            sampler2D _CameraDepthTexture;          // 當使用Depth Normal，不會賦值到這個變量中
            sampler2D _CameraDepthNormalsTexture;

            sampler2D _MainTex;
            fixed _Linear;
            fixed _NormalFactor;

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata_img i) {
                v2f o;

                o.pos = UnityObjectToClipPos (i.vertex);
                o.uv = i.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                //
                // Depth & Normal
                //
                fixed4 col = tex2D (_MainTex, i.uv);
                fixed3 normal = col.xyz;
                fixed d = col.w;
                fixed linear_d = 1 - Linear01DepthValue (d); // 反轉顏色
                fixed final_d = lerp (1 - d, linear_d, _Linear);
                fixed3 color = fixed3 (
                    lerp (final_d, normal.x, _NormalFactor),
                    lerp (final_d, normal.y, _NormalFactor),
                    lerp (final_d, normal.z, _NormalFactor)
                );
                return fixed4 (color, 1.0);

                //
                // ================================
                // |                              |
                // |        Built-in Unity        |
                // |                              |
                // ================================
                

                // Depth
                // fixed4 col = SAMPLE_DEPTH_TEXTURE (_CameraDepthTexture, i.uv);
                // fixed d = col.r;
                // fixed linear_d = 1 - Linear01DepthValue (d); // 反轉顏色
                // fixed final_d = lerp (1 - d, linear_d, _Linear);
                // // d = LinearEyeDepth (d);
                // return fixed4 (final_d, final_d, final_d, 1.0);

                // Depth & Normal
                // float4 enc = tex2D (_CameraDepthNormalsTexture, i.uv); 
                // fixed d;
                // float3 normal;
                // DecodeDepthNormal (enc, d, normal);
                // normal.z = -normal.z;

                // fixed3 color = fixed3 (
                //     lerp (1 - d, normal.x, _NormalFactor),
                //     lerp (1 - d, normal.y, _NormalFactor),
                //     lerp (1 - d, normal.z, _NormalFactor)
                // );
                // return fixed4 (color, 1.0f);
            }

            ENDCG

        }

    }

    Fallback "Specular"
}