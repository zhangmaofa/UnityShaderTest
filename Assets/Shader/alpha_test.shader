Shader "Study/alpha_test"
{
    Properties
    {
       _Color("MainTint",Color) = (1,1,1,1)
	   _MainTex("MainTex",2D) = "White"{}
	   _AlphaCutValue("AlphaCutValue",Range(0,1)) = 0.5
    }
	
    SubShader
    {
		//tags放在Pass内和Pass外好像只是一个区域的问题，试了下放在Pass内也没啥问题
		Tags 
		{
			"Queue" = "AlphaTest" 
			"IgnreProjection" = "True" 
			"RenderType"="TransparentCutout" 
		}
		
		Pass
		{
			CGPROGRAM
		 	#include "UnityCG.cginc"
			#include"Lighting.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			sampler2D _MainTex; 
			fixed4 _MainTex_ST;
			float _AlphaCutValue;
			
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
				
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				return o;
			}

			f2a frag(v2f i)
			{
				f2a o;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos) );
				
				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				//表面颜色
				fixed3 albedo  = texColor.rgb *_Color;
				
				//环境光 = 表面颜色*光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				//漫反射= 灯光颜色*表面颜色 * 角度
				fixed3 diffuse = _LightColor0.rgb * albedo * max( 0, dot(worldNormal,worldLightDir) );

				o.color = fixed4(ambient + diffuse,1);
				
				clip(texColor.a - _AlphaCutValue);

				return o;
			}
			
				
			ENDCG
		}
    }
    FallBack "Transparent/Cutout/VertexLit"
}
