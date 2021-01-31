// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Study/14_ramp_texture"
{
	Properties 
	{
		_FaceColor("FaceColor",Color) = (1,1,1,1)
		_RampTex("RampTex",2D) = "white"{}
		_SpecularColor("SpecularColor",Color)=(1,1,1,1)
		_Gloss("Gloss",float) = 1
		_UVXOffset("UVXOffset",float) = 0
	}
	
	SubShader
	{
		pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"
			#include"Lighting.cginc"
			
			fixed4 _FaceColor;
			sampler2D _RampTex;
			fixed4 _RampTex_ST;
			fixed4 _SpecularColor;
			float _Gloss;
			float _UVXOffset;
			 
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
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
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				
				o.uv = v.texcoord.xy * _RampTex_ST.xy + _RampTex_ST.zw;
				
				return o;
			}
			
			
			f2a frag(v2f i)
			{
				f2a o;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(i.worldPos) );
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed halfLambert = dot(worldNormal,worldLightDir)*0.5 + 0.5;
				
				_UVXOffset += 0.1;
				
				fixed uv = fixed2(halfLambert,halfLambert)+ i.uv;
				uv.x += _UVXOffset;

				fixed3 diffuse = _LightColor0.rgb * tex2D(_RampTex,uv).rgb * _FaceColor.rgb;
				
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0,dot(worldNormal,halfDir)),_Gloss );
				
				o.color = fixed4(ambient+diffuse+specular,1);
				return o;
			}

				
			ENDCG
		}
	}
	
	FallBack "Specular"
}
