Shader "Unity Shaders Book/Chapter 9/Shadow" {

    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }

    SubShader {

        // ForwardBase handles only one directional light.
        Pass {
            // Pass for ambient light & first pixel light (only directional light)
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            // Apparently need to add this declaration
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.worldNormal = UnityObjectToWorldNormal (v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                // Pass shadow coordinates to pixel shader
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 worldNormal = normalize (i.worldNormal);
                fixed3 worldLightDir = normalize (_WorldSpaceLightPos0.xyz);

                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                // Compute diffuse term
                fixed3 diffuse = _LightColor0 * _Diffuse.rgb * max (0, dot (worldNormal, worldLightDir));

                // Compute specular term
                fixed3 viewDir = normalize (_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize (worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (worldNormal, halfDir)), _Gloss);

                // The attenuation of directional light is always 1
                fixed atten = 1.0;

                fixed shadow = SHADOW_ATTENUATION(i);

                return fixed4 (ambient + (diffuse + specular) * atten * shadow, 1.0);
            }

            ENDCG
        }

        Pass {
            // Pass for other pixel lights
            Tags { "LightMode" = "ForwardAdd" }

            Blend One One

            CGPROGRAM

            // Apparently need to add this declaration
            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.worldNormal = UnityObjectToWorldNormal (v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 worldNormal = normalize (i.worldNormal);

                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize (_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize (_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                // Get ambient term，
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                // Compute diffuse term
                fixed3 diffuse = _LightColor0 * _Diffuse.rgb * max (0, dot (worldNormal, worldLightDir));

                // Compute specular term
                fixed3 viewDir = normalize (_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize (worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (worldNormal, halfDir)), _Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                    // The attenuation of directional light is always 1
                    fixed atten = 1.0;
                #else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                        // 與點光源不同，由於聚光燈有更多的角度等要求，因此為了得到衰減值，除了需要對衰減紋理采樣外，還需要對聚光燈的範圍、張角和方向進行判斷
                        // 此時衰減紋理存儲到了_LightTextureB0中，這張紋理和點光源中的_LightTexture0是等價的
                        // 聚光燈的_LightTexture0存儲的不再是基於距離的衰減紋理，而是一張基於張角範圍的衰減紋理
                        // lightCoord.z > 0 的判斷可以刪除
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
                #endif

                return fixed4 ((diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }

    }

    FallBack "Specular"
}
