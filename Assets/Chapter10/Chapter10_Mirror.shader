Shader "Unity Shaders Book/Chapter 10/Mirror" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white"{}
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

		sampler2D _MainTex;
		float _MainTex_ST;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		v2f vert(a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;
			//Mirror needs to flip x
			o.uv.x = 1 - o.uv.x;

			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			return tex2D(_MainTex, i.uv);
		}
		ENDCG
	}
	}
	FallBack "Reflective/VertexLit"
}