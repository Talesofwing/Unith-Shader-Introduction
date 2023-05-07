Shader "Unity Shaders Book/Chapter 13/Depth Normal" {

    Properties {
    }

    SubShader {
        tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Cull Off

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct a2v {
                float4 pos : POSITION;
                fixed3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 normal : TEXCOORD0;
            };

            v2f vert (a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos (i.pos);
                o.normal = mul (i.normal, unity_WorldToObject);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float d = i.pos.z;
                fixed3 normal = i.normal;
                // normal.x = normal.x * 0.5 + 0.5;
                // normal.y = normal.y * 0.5 + 0.5;
                // normal.z = normal.z * 0.5 + 0.5;
                normal = normalize (normal);

                return fixed4 (normal.x, normal.y, normal.z, d);
            }

            ENDCG

        }

    }

    Fallback "Diffuse"
}