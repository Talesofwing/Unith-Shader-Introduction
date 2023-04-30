Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation" {

    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount ("Horizaontal Amount", Float) = 4
        _VerticalAmount ("Vertical Amount", Float) = 4
        _Speed ("Speed", Range (1, 100)) = 30
    }

    SubShader {
        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }

        Pass {
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
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
                o.pos = UnityObjectToClipPos (i.pos);
                o.uv = TRANSFORM_TEX (i.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float time = floor (_Time.y * _Speed);
                float row = floor (time / _HorizontalAmount);
                float column = time - row * _HorizontalAmount;

                // 控制「取樣格」。
                // 原點在左下且Texture為Repeat，所以向下移動相當於回到第一行
                half2 uv = i.uv + half2 (column, -row);     
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                fixed4 c = tex2D (_MainTex, uv);
                c.rgb *= _Color;

                return c;
            }
            ENDCG

        }

    }

    FallBack "Transparent/VertexLit"
}