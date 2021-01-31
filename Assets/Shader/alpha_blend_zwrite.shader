Shader "Study/alpha_blend_zwrite"
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
		
		Pass
		{
			ZWrite On
			ColorMask 0
		}

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
		 	#include "UnityCG.cginc"
			#include"Lighting.cginc"
			
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
				
				o.color = fixed4(ambient+diffuse,texColor.a * _AlphaScale);

				return o;
			}
				
			ENDCG
		}
    }
    FallBack "Transparent/VertexLit"
}
