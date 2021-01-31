// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Study/12_normalmapInTangentSpace"
{
	Properties 
	{
		_Color("FaceColor",Color) = (1,1,1,1)
		_MainTex ("MainTex",2D) = "white"{}
		_BumpMap ("NormalMap",2D) = "bump"{}
		_BumpScale("BumpScale",float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(5.0,256)) = 20
	}
	
	SubShader
	{
		pass
		{
			//Tags {"RendeMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include"UnityCG.cginc"
			#include"Lighting.cginc"
			
			float4 _Color;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			
			float _BumpScale;
			float4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:POSITION;
				float4 uv:TEXCOORD1;
				float3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD2;
			};

			struct f2a
			{
				fixed4 col:SV_Target;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				//compute binormal 
				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			f2a frag(v2f i)
			{
				f2a o;
				
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				
				//get texel in normal map 
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				
				//from uvspace convert to normalspace
				fixed3 tangentNormal;
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;

				//反射光(物体表面的颜色)
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb*_Color;
				
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz *albedo;
				
				//漫反射光
				fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir) );

				fixed3 halfDir = normalize(tangentLightDir+tangentViewDir);

				//镜面高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb*pow( max(0,dot(tangentNormal,halfDir) ),_Gloss );
				
				o.col = fixed4(ambient+diffuse+specular,1);
				return o;
			}
			
			ENDCG
		}
	}
	
	FallBack "Specular"
}
