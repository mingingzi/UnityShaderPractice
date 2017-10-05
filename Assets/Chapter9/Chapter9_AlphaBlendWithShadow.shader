
Shader "Unity Shaders Book/Chapter 9/AlphaBlendWithShadow" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		//Transparent shadow using dither mask
		Pass{
		    Name "ShadowCaster"
		    Tags{ "LightMode" = "ShadowCaster" }

		    ZWrite On ZTest LEqual

		    CGPROGRAM
		    #pragma target 3.0

		    #pragma vertex vert
		    #pragma fragment frag

		    #pragma multi_compile_shadowcaster

		    #define UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
		    #define UNITY_STANDARD_USE_DITHER_MASK
		    #define UNITY_STANDARD_USE_SHADOW_UVS

		    #include "UnityStandardShadow.cginc"

		    fixed _AlphaScale;

		    struct VertexOutput
		    {
		        V2F_SHADOW_CASTER_NOPOS
		        float2 tex : TEXCOORD1;
		    };

		    void vert(VertexInput v, out VertexOutput o, out float4 opos : SV_POSITION)
		    {
		        TRANSFER_SHADOW_CASTER_NOPOS(o,opos)
		        o.tex = v.uv0;
		    }

		    half4 frag(VertexOutput i, UNITY_VPOS_TYPE vpos : VPOS) : SV_Target
		    {
		        half alpha = tex2D(_MainTex, i.tex).a * _AlphaScale;

		        half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy*0.25,alpha*0.9375)).a;
		        clip(alphaRef - 0.01);

		        SHADOW_CASTER_FRAGMENT(i)
		    }

		    ENDCG
		}

		Pass{
			Tags { "LightMode"="ForwardBase" }

			//First pass render only back faces
			Cull Front

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).rgb;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4 (ambient + diffuse * atten, texColor.a * _AlphaScale);
			}
			ENDCG
		}
		Pass{
			Tags { "LightMode"="ForwardBase" }

			//Second pass render only front faces
			Cull Back

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).rgb;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4 (ambient + diffuse * atten, texColor.a * _AlphaScale);
			}
			ENDCG
		}
	}
	//Fallback "VertexLit"
}
