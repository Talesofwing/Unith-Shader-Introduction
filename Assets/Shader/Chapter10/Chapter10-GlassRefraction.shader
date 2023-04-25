Shader "Unity Shaders Book/Chapter 10/GlassRefraction" {

    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Cubemap ("Envirnoment Cubemap", Cube) = "_Skybox" {}
        _Distortion ("Distortion", Range (0, 100)) = 10             // 控制折射時圖像的扭曲程度
        _RefractAmount ("Refract Amount", Range (0.0, 1.0)) = 1.0   // 控制折射程度
                                                                    // 當值為0時，該玻璃只包含反射效果，當值為1時，該玻璃只包含折射效果
    }

    SubShader {
        // We mush be transparent, so other objects are drawn before this one.
        Tags {"RenderType" = "Opaque" "Queue" = "Transparent"}

        // This pass grabs the screen behind the object into a texture.
        // We can access the result in the next pass as _RefactionTex
        GrabPass { "_RefractionTex" }

        Pass {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
            float _BumpScale;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

            struct a2v {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4; 
            };

            v2f vert (a2v i) {
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				
				o.scrPos = ComputeGrabScreenPos(o.pos);
				
				o.uv.xy = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(i.uv, _BumpMap);
				
				float3 worldPos = mul(unity_ObjectToWorld, i.pos).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(i.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z); 

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				// Get the normal in tangent space
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));	
				bump.xy *= _BumpScale;
                bump.z = sqrt (1.0 - saturate (dot (bump.xy, bump.xy)));
                bump = normalize (half3 (dot (i.TtoW0.xyz, bump), dot (i.TtoW1.xyz, bump), dot (i.TtoW2.xyz, bump)));

				// Compute the offset in tangent space
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2Dproj(_RefractionTex, i.scrPos).rgb;
                // fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

				// Convert the normal to world space
				bump = normalize (half3 (dot (i.TtoW0.xyz, bump), dot (i.TtoW1.xyz, bump), dot (i.TtoW2.xyz, bump)));
				fixed3 reflDir = reflect(-worldViewDir, bump);
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
				
				fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
				
				return fixed4(finalColor, 1);
            }

            ENDCG

        }

    }

    FallBack "Reflective/VertexLit"
}
