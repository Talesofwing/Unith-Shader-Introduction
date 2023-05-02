// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 11/Billboard" {

    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)

        // 當為0時，上方向固定為(0, 1, 0)，當為1時，法線方向固定為視角方向
        // 當為0時，繞Y軸旋轉
        _VerticalBillboarding ("Vertical Restraints", Range (0, 1)) = 1
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
            float _VerticalBillboarding;

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

                // Suppose the center in object space is fixed
                float3 center = float3 (0, 0, 0);
                float3 viewer = mul (unity_WorldToObject, float4 (_WorldSpaceCameraPos, 1));  // 變換到模型空間

                float3 normalDir = viewer - center;
                // If _VerticalBillboarding equals 1, we use the desired view dir as the normal dir
                // Which means the normal dir is fixed
                // Or if _VerticalBillboarding equals 0, the y of normal is 0
                // Which means the up dir is fixed
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize (normalDir); 

                // Get the approximate up dir
                // If normal dir is already towards up, then the up dir is towards front
                float3 upDir = abs (normalDir.y) > 0.999 ? float3 (0, 0, 1) : float3 (0, 1, 0);
                float3 rightDir = normalize (cross (normalDir, upDir));
                upDir = normalize (cross (rightDir, normalDir));

                float3 centerOffs = i.pos.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos (localPos);
                o.uv = i.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 c = tex2D (_MainTex, i.uv);
                c.rgb *= _Color.rgb;
				
				return c;
            }

            ENDCG

        }

    }

    FallBack "Transparent/VertexLit"
}