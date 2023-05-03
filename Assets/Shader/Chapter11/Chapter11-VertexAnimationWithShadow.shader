Shader "Unity Shaders Book/Chapter 11/Vertex Animation With Shadow" {

	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Magnitude ("Distortion Magnitude", Float) = 1
 		_Frequency ("Distortion Frequency", Float) = 1
 		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
 		_Speed ("Speed", Float) = 0.5
	}

	SubShader {
		// Need to disable batching because of the vertex animation
		Tags { "DisableBatching"="True" }
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			Cull Off
			
			CGPROGRAM  
			#pragma vertex vert 
			#pragma fragment frag
			
			#include "UnityCG.cginc" 
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			struct a2v {
			    float4 pos : POSITION;
			    float4 uv : TEXCOORD0;
			};
			
			struct v2f {
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				offset.x = sin(_Frequency * _Time.y + v.pos.x * _InvWaveLength + v.pos.y * _InvWaveLength + v.pos.z * _InvWaveLength) * _Magnitude;
				
				o.pos = UnityObjectToClipPos(v.pos + offset);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv +=  float2(0.0, _Time.y * _Speed);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				
				return c;
			} 
			
			ENDCG
		}
		
		// Pass to render object as a shadow caster
		Pass {
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_shadowcaster
			
			#include "UnityCG.cginc"
			
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			struct v2f { 
			    V2F_SHADOW_CASTER;
			};
			
			v2f vert(appdata_base v) {
				v2f o;
				
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				v.vertex = v.vertex + offset;

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
			    SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}
		
	}
	
	FallBack "VertexLit"
}