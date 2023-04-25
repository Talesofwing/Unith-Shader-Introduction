Shader "Unity Shaders Book/Chapter 10/Empricial" {

    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
        // Specular
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
        // Empricial
        _Bias ("Bias", Range(0, 1)) = 0.5
        _EmpricialScale ("Empricial Scale", Range (0, 1)) = 0.5
        _Power ("Power", Range (0, 5)) = 1
    }

    SubShader {
        Tags {"RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			samplerCUBE _Cubemap;
            fixed4 _Specular;
            float _Gloss;
            fixed _Bias;
            fixed _EmpricialScale;
            float _Power;

            struct a2v {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.pos);
                o.worldNormal = UnityObjectToWorldNormal (i.normal);
                o.worldPos = mul (unity_ObjectToWorld, i.pos).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir (o.worldPos);       
                o.worldRefl = reflect (-o.worldViewDir, o.worldNormal);    
                TRANSFER_SHADOW (o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 worldNormal = normalize (i.worldNormal);
                fixed3 worldLightDir = normalize (UnityWorldSpaceLightDir (i.worldPos));
                fixed3 worldViewDir = normalize (i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max (0, dot (worldNormal, worldLightDir));

                // Use the reflect dir in world space to access the cubemap
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;

                // Specular
                fixed3 halfDir = normalize (worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (halfDir, worldNormal)), _Gloss);

                // Compute empricial
                fixed empricial = max (0.0, min (1.0, _Bias + _EmpricialScale * pow (1.0 - dot (worldNormal, worldViewDir), _Power)));

                UNITY_LIGHT_ATTENUATION (atten, i, i.worldPos);

                fixed3 color = ambient + (lerp (diffuse, reflection, saturate (empricial)) + specular) * atten;

                return fixed4 (color, 1.0);
            }

            ENDCG

        }

    }

    FallBack "Reflective/VertexLit"
}
