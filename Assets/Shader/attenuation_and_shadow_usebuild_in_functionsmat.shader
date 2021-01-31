// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Study/attenuation_and_shadow_usebuild_in_functionsmat"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Gloss("GlossRange",Range(1,200)) = 10					//光的范围
		_SpecularColor("SpecularColor",Color) = (1,1,1,1)
	}

		SubShader
	{
		Pass
		{
			Tags
			{
				"RenderType" = "ForwardBase"
			}

			CGPROGRAM
		
#include "AutoLight.cginc"
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
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				SHADOW_COORDS(2)
			};
			
			struct f2a
			{
				fixed4 color : SV_Target;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				TRANSFER_SHADOW(o)
				
				return o;
			}
			
			f2a frag(v2f i)
			{
				f2a o;

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				fixed3 halfDir = normalize(worldLightDir + viewDir);

				float cosValue = pow(max(0,dot(worldNormal, halfDir)), _Gloss);
				
				fixed4 albedo = _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * cosValue;
				
				//fixed atten = 1.0;
				//计算shadow的光照衰减
				//fixed shadow = SHADOW_ATTENUATION(i);
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				
				o.color = fixed4(ambient + (diffuse + specular)*atten, atten);
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
//#pragma multi_compile_fwdadd
//addtional pass 里的逐像素渲染好像没起到作用。。BasePass里的光照和阴影去掉之后这里就没阴影了。
#pragma multi_compile_fwdadd_fullshadows
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
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				SHADOW_COORDS(2)
			};

			struct f2a
			{
				fixed4 color : SV_TARGET;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				
				TRANSFER_SHADOW(o);

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
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
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
				fixed atten = 1;
#else			
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
#endif
				o.color = fixed4(ambient + (diffuse + specular)*atten, atten);
				return o;
			}

			ENDCG
		}
	}
		FallBack "Specular"
}
