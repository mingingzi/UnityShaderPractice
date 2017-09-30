Shader "Unity Shaders Book/Chapter 7/Mask Texture" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("MainTex", 2D) = "white" {}
		_BumpTex("BumpTex", 2D) = "white" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask("SpecularMask", 2D) = "white" {}
		_SpecularScale("Specular Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20.0
	}
	SubShader {
	Pass{
		Tags { "LightMode"="ForwardBase" }
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpTex;
		float4 _BumpTex_ST;
		float _BumpScale;
		sampler2D _SpecularMask;
		float4 _SpecularMask_ST;
		float _SpecularScale;
		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;
			float4 TtoW0 : TEXCOORD1;
			float4 TtoW1 : TEXCOORD2;
			float4 TtoW2 : TEXCOORD3;
		};

		v2f vert(a2v v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			//transform texture coord of vertex to uv coord
			o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).rgb;
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

			o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			//vertex Pos in world space
			float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
			//fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

			//get normal in tangent space
			fixed3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
			bump.xy *= _BumpScale;
			bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
			bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump),dot(i.TtoW2.xyz, bump)));

			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldLightDir, bump));


			fixed3 halfDir = normalize(worldLightDir + viewDir);

			fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss) * specularMask;

			return fixed4 (ambient + diffuse + specular, 1.0);
		}
		ENDCG
	}
	}
	FallBack "Specular"
}
