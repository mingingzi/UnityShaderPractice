Shader "Unity Shaders Book/Chapter 9/Forward Rendering" {
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
			#pragma multi_compile_fwdbase
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
				//fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz); //only use this for directional light
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldLightDir, worldNormal));

				//view direction, given vertex position in model space
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				// the attenduation of directional light is always 1
				fixed atten = 1.0;

				return fixed4 (ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}

		//Additional Pass
		Pass{
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One

			CGPROGRAM

			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

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
				fixed3 worldNormal = normalize(i.worldNormal);

				//light direction in world space (given position in model space)
				#ifdef USING_DIRECTIONAL_LIGHT
					//fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldLightDir, worldNormal));

				//view direction, given vertex position in model space
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				//attenuation
				#ifdef USING_DIRECTIONAL_LIGHT
					// the attenduation of directional light is always 1
					fixed atten = 1.0;
				#else
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif


				return fixed4 ((diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}
		}
	FallBack "Specular"
}