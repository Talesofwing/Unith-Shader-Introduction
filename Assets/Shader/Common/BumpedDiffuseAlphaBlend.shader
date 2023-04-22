Shader "Unity Shaders Book/Common/Bumped Diffuse Alpha-Blend" {

    Properties {
        _Color ("Color Tine", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        // bump為Unity內置的法線紋理，當未配置任何法線紋理時，bump對應模型自帶的法線信息
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range (8.0, 256)) = 20
    }

    SubShader {
        tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }

		Pass {
			Tags { "LightMode" = "ShadowCaster"	}

			CGPROGRAM

			#pragma target 3.0

            #include "UnityCG.cginc"

			#pragma multi_compile_shadowcaster

            #pragma vertex vert
            #pragma fragment frag

            struct a2v {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

			v2f vert (a2v i) {
                v2f o;
                o.pos = UnityApplyLinearShadowBias (UnityClipSpaceShadowCasterPos (i.pos.xyz, i.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_TARGET {
                return 0;
            }
			
			ENDCG
		}

        // 1. Base Pass背面
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            // 透明物體的雙面渲染的第一個Pass只渲染背面
            Cull Front

            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS (4)
            };

            v2f vert (a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos (v.vertex);
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _MainTex_ST.zw;

                fixed3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = normalize(mul (v.normal, unity_WorldToObject));
                fixed3 worldTangent = normalize(mul (unity_ObjectToWorld, v.tangent.xyz));
                fixed3 worldBinormal = cross (worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4 (worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4 (worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4 (worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW (o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float3 worldPos = float3 (i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize (_WorldSpaceLightPos0.xyz); 
                fixed3 viewDir = normalize (_WorldSpaceCameraPos.xyz - worldPos);

                fixed3 bump = UnpackNormal (tex2D (_BumpMap, i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt (1.0 - saturate (dot (bump.xy, bump.xy)));
                bump = normalize (half3 (dot (i.TtoW0.xyz, bump), dot (i.TtoW1.xyz, bump), dot (i.TtoW2.xyz, bump)));

                fixed4 albedo = tex2D (_MainTex, i.uv.xy) * _Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot (bump, lightDir));
                fixed3 halfDir = normalize (lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (bump, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION (atten, i, worldPos);

                return fixed4 (ambient + (diffuse + specular) * atten, albedo.a);
            }

            ENDCG

        }


        // 2. Base Pass正面
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            // 透明物體的雙面渲染的第二個Pass只渲染正面
            Cull Back

            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS (4)
            };

            v2f vert (a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos (v.vertex);
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _MainTex_ST.zw;

                fixed3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = normalize(mul (v.normal, unity_WorldToObject));
                fixed3 worldTangent = normalize(mul (unity_ObjectToWorld, v.tangent.xyz));
                fixed3 worldBinormal = cross (worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4 (worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4 (worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4 (worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW (o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float3 worldPos = float3 (i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize (_WorldSpaceLightPos0.xyz); 
                fixed3 viewDir = normalize (_WorldSpaceCameraPos.xyz - worldPos);

                fixed3 bump = UnpackNormal (tex2D (_BumpMap, i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt (1.0 - saturate (dot (bump.xy, bump.xy)));
                bump = normalize (half3 (dot (i.TtoW0.xyz, bump), dot (i.TtoW1.xyz, bump), dot (i.TtoW2.xyz, bump)));

                fixed4 albedo = tex2D (_MainTex, i.uv.xy) * _Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot (bump, lightDir));
                fixed3 halfDir = normalize (lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (bump, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION (atten, i, worldPos);

                return fixed4 (ambient + (diffuse + specular) * atten, albedo.a);
            }

            ENDCG

        }

        Pass {
            Tags { "LightMode" = "ForwardAdd" }

            ZWrite Off
            Blend SrcAlpha One
            Cull Back   // 只照亮前面

            CGPROGRAM

            // #pragma multi_compile_fwdadd
            // Use the line below to add shadows for point and spot lights
            #pragma multi_compile_fwdadd_fullshadows

            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS (4)
            };

            v2f vert (a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos (v.vertex);
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _MainTex_ST.zw;

                fixed3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = normalize(mul (v.normal, unity_WorldToObject));
                fixed3 worldTangent = normalize(mul (unity_ObjectToWorld, v.tangent.xyz));
                fixed3 worldBinormal = cross (worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4 (worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4 (worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4 (worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW (o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float3 worldPos = float3 (i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize (_WorldSpaceLightPos0.xyz);
                fixed3 viewDir = normalize (_WorldSpaceCameraPos.xyz - worldPos);

                fixed3 bump = UnpackNormal (tex2D (_BumpMap, i.uv.zw));
                bump = normalize (half3 (dot (i.TtoW0.xyz, bump), dot (i.TtoW1.xyz, bump), dot (i.TtoW2.xyz, bump)));

                fixed4 albedo = tex2D (_MainTex, i.uv.xy) * _Color;
                fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot (bump, lightDir));
                fixed3 halfDir = normalize (lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (bump, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION (atten, i, worldPos);

                return fixed4 ((diffuse + specular) * atten, 1.0f);
            }

            ENDCG

        }

    }

}