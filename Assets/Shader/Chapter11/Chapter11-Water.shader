Shader "Unity Shaders Book/Chapter 11/Water" {

    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Distortion Frequency", Float) = 1
        _InvWaveLength ("Distorition Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }

    SubShader {
        // Need to disable batching because of the vertex animation
        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" "DisableBatching" = "True" }

        Pass {
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (a2v i) {
                v2f o;

                float4 offset;
                offset.yzw = float3 (0.0, 0.0, 0.0);
                offset.x = sin (i.pos.x * _InvWaveLength + i.pos.y * _InvWaveLength + i.pos.z * _InvWaveLength + _Frequency * _Time.y) * _Magnitude;

                o.pos = UnityObjectToClipPos (i.pos + offset);
                o.uv = TRANSFORM_TEX (i.uv, _MainTex);
                o.uv += float2 (0.0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
 				fixed4 c = tex2D (_MainTex, i.uv);
                c *= _Color;    
				
				return c;
            }

            ENDCG

        }

    }

    FallBack "VertexLit"
}