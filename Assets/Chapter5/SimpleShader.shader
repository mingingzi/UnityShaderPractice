// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/SimpleShader" {
	Properties{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			//a2v = appdata = application to vertex shader
			struct a2v {
				//POSITION : model space position
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				//SV_POSITION : clip space position
				float4 post : SV_POSITION;
				fixed3 color : COLOR0;
			};


			v2f vert(a2v v) {
				v2f o;
				o.post = UnityObjectToClipPos (v.vertex);
				//v.normal is between [-1, 1]. Map it to [0.0, 1.0]
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
				return o;
			}

			//SV_TARGET : save the output color into a render target (pixel color)
			fixed4 frag(v2f i) : SV_Target {
			fixed3 c = i.color;
			c *= _Color.rgb;
			return fixed4(c, 1.0);
			}
		ENDCG
		}
	}
}
