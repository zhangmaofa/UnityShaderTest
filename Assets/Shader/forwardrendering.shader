// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Study/forwardrendering"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Gloss("GlossRange",Range(1,200)) = 10					//光的范围
		_SpecularColor("SpecularColor",Color) = (1,1,1,1)
	}
	
	SubShader
	{
		//fowardbase
		Pass
		{
			Tags
			{
				"RenderType" = "ForwardBase"
			}

			CGPROGRAM
		#include "UnityCG.cginc"
#include"lighting.cginc"
#pragma multi_compile_fwdbase
#pragma vertex vert
#pragma fragment frag

		fixed4 _Color;
		float _Gloss;
		fixed4 _SpecularColor;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			
			struct v2f
			{
				float4 position:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
			};
			
			struct f2a
			{
				fixed4 color : SV_Target;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}

			f2a frag(v2f i)
			{
				f2a o;
				
				fixed3 worldNormal = normalize(i.worldNormal);

				//这个算出来的应该是该顶点到灯光的方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//顶点到相机的方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				//到灯光的方向+到视口的方向 = 算出来的是灯光和相机的法线
				//之所以求平均值是因为如果使用灯光的方向或者是摄像机的方向就会出现过高过低的效果，效果看上去很奇怪
				fixed3 halfDir = normalize(worldLightDir+ viewDir);
				
				//法线和平分线点成求一个平方值,_Gloss越大，越是垂直平分线的点越能保留住，剩余的值都在平方运算中变的及其小了。
				float cosValue = pow( max( 0,dot(worldNormal, halfDir) ), _Gloss );
				
				fixed4 albedo = _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir) );
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * cosValue;

				//平行光的atten总是1
				fixed atten = 1.0;
				o.color = fixed4(ambient+(diffuse+ specular)*atten, atten);
				return o;
			}
			
			ENDCG
		}
		
		//foward addtional
		Pass
		{
			Tags
			{
				"RenderType" = "ForwardAdd"
			}
			Blend One One

			CGPROGRAM
#include "AutoLight.cginc"
#include "UnityCG.cginc"
#include"Lighting.cginc"
#pragma multi_compile_fwdadd
#pragma vertex vert
#pragma fragment frag

		fixed4 _Color;
		float _Gloss;
		fixed4 _SpecularColor;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 position:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
			};

			struct f2a
			{
				fixed4 color : SV_TARGET;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}

			f2a frag(v2f i)
			{
				f2a o;
				
				fixed3 worldNormal = normalize(i.worldNormal);

				//这个算出来的应该是该顶点到灯光的方向
#ifdef USING_DIRECTIONAL_LIGHT
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz-i.worldPos.xyz);
#endif
				
				//顶点到相机的方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				//到灯光的方向+到视口的方向 = 算出来的是灯光和相机的法线
				//之所以求平均值是因为如果使用灯光的方向或者是摄像机的方向就会出现过高过低的效果，效果看上去很奇怪
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//法线和平分线点成求一个平方值,_Gloss越大，越是垂直平分线的点越能保留住，剩余的值都在平方运算中变的及其小了。
				float cosValue = pow(max(0,dot(worldNormal, halfDir)), _Gloss);

				fixed4 albedo = _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * cosValue;
				
#ifdef USING_DIRECTIONAL_LIGHT
				//平行光的atten总是1
				fixed atten = 1;
#else			
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				fixed atten = tex2D(_LightTexture0,dot( lightCoord,lightCoord ).rr ).UNITY_ATTEN_CHANNEL;
#endif
				
				o.color = fixed4(ambient + (diffuse + specular)*atten, atten);
				return o;
			}
			
			ENDCG
		}
	}
		FallBack "Specular"
}
