// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex_Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
	}
	SubShader {
		Pass{
		//to get built-in light parameters
		Tags { "LightMode" = "ForwardBase" }
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"

		fixed4 _Diffuse;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			//could use color : COLOR0 or TEXCOORD0 etc.
			fixed3 color : COLOR;
		};

		v2f vert(a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			//get ambient term
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			//transform normal from model space to world space (reference Page88)
			fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
			//light direction in world space
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
			//C_diffuse = (C_light * M_diffuse) max(0, n * I) (reference Page124) fixed4 _LightColor.rgbi(intensity)
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight, worldNormal));

			o.color = ambient + diffuse;
			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			return fixed4(i.color, 1.0);
		}
		ENDCG
	}
	}
	FallBack "Diffuse"
}
