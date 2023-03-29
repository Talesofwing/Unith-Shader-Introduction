Shader "Unity Shaders Book/Chapter 7/Single Texture" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range (8.0, 256)) = 20
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
            float4 _MainTex_ST;        // 固定的寫法
                                       // xy: Tiling; zw: Offset
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.vertex);
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul (unity_ObjectToWorld, i.vertex).xyz;
                o.uv = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // 等價
                // o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float3 n = normalize(i.worldNormal);
                float3 lightDir = normalize (UnityWorldSpaceLightDir(i.worldPos));
                
                fixed3 albedo = tex2D (_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot (n, lightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (max (0, dot (n, halfDir)), _Gloss);
                
                return float4 (ambient + diffuse + specular, 1.0f);
            }
            
            ENDCG
        }
    }

    FallBack "Specular"
}