// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Study/13_normalmapInWorldSpace"
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
			/*
				float3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD2;*/
				float4 pos:POSITION;
				float4 uv:TEXCOORD0;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
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
				
				//转换到世界空间去计算的次数会比较多，性能消耗比较大，但是cubemap必须要用到这种算法。
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent);
				float3 worldBiNormal = cross(worldNormal,worldTangent)*v.tangent.w;
				
				o.TtoW0 = float4(worldTangent.x,worldBiNormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBiNormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBiNormal.z,worldNormal.z,worldPos.z);
				return o;
			}

			f2a frag(v2f i)
			{
				f2a o;
				
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				
				fixed3 lightDir = normalize( UnityWorldSpaceLightDir(worldPos) );
				
				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(worldPos) );
				
				//get the tangent space
				//从法线空间[-1,1] 转换到 像素空间[0,1]
				fixed3 bump = UnpackNormal( tex2D(_BumpMap,i.uv.zw) );
				bump.xy *= _BumpScale;
				bump.z = sqrt( 1.0 - saturate( dot(bump.xy,bump.xy) ) );
				
				//transform the normal from tangentspace to worldspace
				bump = normalize( half3(dot(i.TtoW0.xyz,bump),
										dot(i.TtoW1.xyz,bump),
										dot(i.TtoW2.xyz,bump)
										) );
				
				//get texel in normal map 
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				
				//反射光(物体表面的颜色)
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb*_Color;
				
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz *albedo;
				
				//漫反射光
				fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(bump,lightDir) );

				fixed3 halfDir = normalize(lightDir+viewDir);

				//镜面高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb*pow( max(0,dot(bump,halfDir) ),_Gloss );
				
				o.col = fixed4(ambient+diffuse+specular,1);
				return o;
			}
			
			ENDCG
		}
	}
	
	FallBack "Specular"
}
