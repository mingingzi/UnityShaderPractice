﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel_Level" {
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
			fixed3 worldNormal : TEXCOORD0;
		};

		v2f vert(a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			//transform normal from model space to world space (reference Page88)
			o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			//get ambient term
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
			fixed halfLambert = dot(worldLight, worldNormal) * 0.5 + 0.5;
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

			fixed3 color = ambient + diffuse;
			return fixed4(color, 1.0);
		}
		ENDCG
	}
	}
	FallBack "Diffuse"
}
