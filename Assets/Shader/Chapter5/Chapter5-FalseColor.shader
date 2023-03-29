// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader : 定義名字
Shader "Unity Shaders Book/Chapter 5/False Color" {
    SubShader {
        Pass {
            CGPROGRAM

            // 聲明vertex shader & fragment shader的函數
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };
            
            v2f vert (appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);

                // 可視化法線方向
                o.color = fixed4 (v.normal * 0.5 + fixed3 (0.5, 0.5, 0.5), 1.0);

                // 可視化切線方向
                o.color = fixed4 (v.tangent.xyz * 0.5 + fixed3 (0.5, 0.5, 0.5), 1.0);

                // 可視化副切線方向
                // 乘以v.tangent.w確定副切線的方向
                fixed3 binormal = cross (v.normal, v.tangent.xyz) * v.tangent.w;
                o.color = fixed4 (binormal * 0.5 + fixed3 (0.5, 0.5, 0.5), 1.0);

                // 可視化第一組紋理坐標
                o.color = fixed4 (v.texcoord.xy, 0.0, 1.0);

                // 可視化第二組紋理坐標
                o.color = fixed4 (v.texcoord1.xy, 0.0, 1.0);

                // 可視化第一組紋理坐標的小數部分
                o.color = frac (v.texcoord);
                if (any (saturate (v.texcoord) - v.texcoord)) {
                    o.color.b = 0.5;
                }
                o.color.a = 1.0;

                // 可視化第二組紋理坐標的小數部分
                o.color = frac (v.texcoord1);
                if (any (saturate (v.texcoord1) - v.texcoord1)) {
                    o.color.b = 0.5;
                }
                o.color.a = 1.0;

                // 可視化頂點顏色
                o.color = v.color;
                
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                return i.color;
            }

            ENDCG
        }
    }
}