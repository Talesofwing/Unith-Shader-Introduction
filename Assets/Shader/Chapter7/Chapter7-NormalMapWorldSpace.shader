Shader "Unity Shaders Book/Chapter 7/Normal Map In World Space" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range (8.0, 256)) = 20
        _ScrollX ("Scroll X", Float) = 1.0
    }

    SubShader {
        Pass {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
    
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _ScrollX;
            float _Gloss;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.vertex);
                o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.x += frac (_ScrollX * _Time.y);
                o.uv.zw = i.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                o.uv.z += frac (_ScrollX * _Time.y);
                
                float3 worldPos = mul (unity_ObjectToWorld, i.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(i.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz);
                fixed3 worldBinormal = cross (worldNormal, worldTangent) * i.tangent.w;

                // Compute the matrix that transform directions from tangent space to world space
                // Put the world position in w component for optimization
                o.TtoW0 = float4 (worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4 (worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4 (worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // Get the position in world space
                float3 worldPos = float3 (i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                // Compute the light and view dir in world space
                fixed3 lightDir = normalize (UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize (UnityWorldSpaceViewDir(worldPos));

                // Get the texel in the normal map
                fixed4 packedNormal = tex2D (_BumpMap, i.uv.zw);
                fixed3 bump;
                // If the texture is not marked as "Normal map"
                // bump.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                // bump.z = sqrt (1.0 - saturate (dot (bump.xy, bump.xy)));

                // Or mark the texture as "Normal map", and use the built-in function
                bump = UnpackNormal(packedNormal);
                bump.xy *= (_BumpScale + sin (_Time.y));
                bump.z = sqrt (1.0 - saturate (dot (bump.xy, bump.xy)));

                // Transform the normal from tangent space to world space
                bump = normalize (half3 (dot (i.TtoW0.xyz, bump), dot (i.TtoW1.xyz, bump), dot (i.TtoW2.xyz, bump)));
                
                fixed3 albedo = tex2D (_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot (bump, lightDir));

                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (bump, halfDir)), _Gloss);
                
                return float4 (ambient + diffuse + specular, 1.00f);
            }
            
            ENDCG
        }
    }

    FallBack "Specular"
}