// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Study/alpha_blend_bothsided_with_shadowmat"
{
    Properties
    {
       _Color("MainTint",Color) = (1,1,1,1)
	   _MainTex("MainTex",2D) = "White"{}
	   _AlphaScale("AlphaScale",Range(0,1)) = 0.5
    }
	
    SubShader
    {
		
		//tags放在Pass内和Pass外好像只是一个区域的问题，试了下放在Pass内也没啥问题
		Tags 
		{
			"Queue" = "Transparent"
			"IgnoewProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		ZWrite Off
			
		Pass
		{
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
		 	#include "UnityCG.cginc"
			#include"Lighting.cginc"
#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			#pragma vertex vert
			#pragma fragment frag
			
			struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float2 uv:TEXCOORD2;
				SHADOW_COORDS(3)
			};
			
			struct f2a
			{
				fixed4 color:SV_Target;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				
				TRANSFER_SHADOW(o);

				return o;
			}
			
			f2a frag(v2f i)
			{
				f2a o;

				fixed3 worldNormal = normalize( i.worldNormal );
				
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos) );
				
				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				fixed4 albedo = _Color*texColor;
				
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo.xyz;
				
				float diffuse  = _LightColor0.rgb * albedo * max( 0, dot(worldNormal,worldLightDir) );
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				atten = max(0.5, atten);
				
				o.color = fixed4(ambient+(diffuse*atten),texColor.a * _AlphaScale);

				return o;
			}
				
			ENDCG
		}
		
		Pass
		{
			Cull Back
			//按照书上写的没用啊,只有把 用一个Pass块操作的时候，然后使用 Cull Off 才能开启双面渲染
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
		 	#include "UnityCG.cginc"
			#include"Lighting.cginc"
#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;  
			fixed _AlphaScale;
			
			#pragma vertex vert
			#pragma fragment frag
			
			struct a2v 
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float2 uv:TEXCOORD2;
				SHADOW_COORDS(3)
			};
			
			struct f2a
			{
				fixed4 color:SV_Target;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				
				TRANSFER_SHADOW(o);
				
				return o;
			}
			
			f2a frag(v2f i)
			{
				f2a o;

				fixed3 worldNormal = normalize( i.worldNormal );
				
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos) );
				
				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				fixed4 albedo = _Color*texColor;
				
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo.xyz;
				
				float diffuse  = _LightColor0.rgb * albedo * max( 0, dot(worldNormal,worldLightDir) );
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				atten = max(0.5, atten);

				o.color = fixed4(ambient+(diffuse*atten),texColor.a * _AlphaScale);
				
				return o;
			}
				
			ENDCG
		}
    }
    FallBack "VertexLit"
}
/*
todo:双面渲染不能处理阴影
开不开双面渲染都不会接收阴影啊，。。。。
*/

