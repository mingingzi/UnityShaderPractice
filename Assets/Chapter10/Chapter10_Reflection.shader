Shader "Unity Shaders Book/Chapter 10/Reflection" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_ReflectColor ("Reflection Color", Color) = (1,1,1,1)
		_ReflectAmount ("Reflect Amount", Range(0, 1)) = 1
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox"{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		Pass{
		//to get built-in light parameters
		Tags { "LightMode" = "ForwardBase" }
		
		CGPROGRAM
		#pragma multi_compile_fwdbase
		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"
		#include "AutoLight.cginc"

		fixed4 _Color;
		fixed4 _ReflectColor;
		float _ReflectAmount;
		samplerCUBE _Cubemap;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			fixed3 worldNormal : TEXCOORD0;
			fixed3 worldPos : TEXCOORD1;
			fixed3 worldRefl : TEXCOORD2;
			SHADOW_COORDS(3)
		};

		v2f vert(a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).rgb;
			fixed3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
			o.worldRefl = reflect(-worldViewDir, o.worldNormal);

			TRANSFER_SHADOW(o);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			fixed3 worldNormal = normalize(i.worldNormal);
			//light direction in world space (given position in model space)
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed3 diffuse = _LightColor0.rgb * _Color * saturate(dot(worldLightDir, worldNormal));

			fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
			return fixed4 (color, 1.0);
		}
		ENDCG
	}
	}
	FallBack "Reflective/VertexLit"
}