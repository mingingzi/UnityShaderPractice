﻿Shader "Unity Shaders Book/Chapter 6/BlinnPhongUseBuildInFunction" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
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
		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			fixed3 worldNormal : TEXCOORD0;
			fixed3 worldPos : TEXCOORD1;
		};

		v2f vert(a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).rgb;
			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			fixed3 worldNormal = normalize(i.worldNormal);
			//light direction in world space (given position in model space)
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldLightDir, worldNormal));

			//view direction, given vertex position in model space
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 halfDir = normalize(worldLightDir + viewDir);

			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

			return fixed4 (ambient + diffuse + specular, 1.0);
		}
		ENDCG
	}
	}
	FallBack "Specular"
}