Shader "Unity Shaders Book/Chapter 10/Refraction" {

    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_RefractColor ("Refraction Color", Color) = (1, 1, 1, 1)
		_RefractAmount ("Refraction Amount", Range(0, 1)) = 1
        _RefractRatio ("Refraction Ratio", Range (0.1, 1)) = 0.5    // 不同介質之間的折射比
		_Cubemap ("Refraction Cubemap", Cube) = "_Skybox" {}
        // Specular
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }

    SubShader {
        Tags {"RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "../Common/zero.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			fixed _RefractAmount;
            fixed _RefractRatio;
			samplerCUBE _Cubemap;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefr : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.pos);
                o.worldNormal = UnityObjectToWorldNormal (i.normal);
                o.worldPos = mul (unity_ObjectToWorld, i.pos).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir (o.worldPos);       // 在vertex shader中計算入射方向
                // Compute the refract dir in world space
                // 注意入射向量的符號
                // o.worldRefr = refract (-normalize (o.worldViewDir), normalize (o.worldNormal), _RefractRatio);
                o.worldRefr = Refract (-normalize (o.worldViewDir), normalize (o.worldNormal), _RefractRatio);
                TRANSFER_SHADOW (o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 worldNormal = normalize (i.worldNormal);
                fixed3 worldLightDir = normalize (UnityWorldSpaceLightDir (i.worldPos));
                fixed3 worldViewDir = normalize (i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max (0, dot (worldNormal, worldLightDir));

                // 當介質相同時，才會有比例為1的情況
                // 而又因為浮點數精度問題，導致依然會出現一點折射的問題
                // 所以加入這一句來判斷為1時的計算
                fixed3 refraction;
                if (_RefractRatio >= 1.0)
                    refraction = texCUBE(_Cubemap, -worldViewDir).rgb * _RefractColor.rgb;
                else
                    // Use the reflect dir in world space to access the cubemap
                    refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractColor.rgb;

                fixed3 halfDir = normalize (worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (halfDir, worldNormal)), _Gloss);

                UNITY_LIGHT_ATTENUATION (atten, i, i.worldPos);

                fixed3 color = ambient + (lerp (diffuse, refraction, _RefractAmount) + specular) * atten;

                return fixed4 (color, 1.0);
            }

            ENDCG

        }

    }

    FallBack "Reflective/VertexLit"
}
