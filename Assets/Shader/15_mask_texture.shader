
Shader "Study/15_mask_texture"
{
	Properties
	{
		_Color("ColorTint",Color)=(1,1,1,1)
		_MainTex("MainTex",2D)="white"{}
		_NormalTex("NormalTex",2D)="bump"{}
		_NormalScale("NormalScale",Float) = 1
		
		_SpecularMask("SpecularMask",2D)="white"{}
		_SpecularScale("SpecularScale",Float) = 1
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(5.0,256)) = 20
	}
	
	Subshader
	{
		Pass
		{
		
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
		 	#include"UnityCG.cginc"
			#include"Lighting.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _NormalTex;
			float4 _NormalTex_ST;

			float _NormalScale;
			
			sampler2D _SpecularMask;
			float _SpecularScale;
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
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};
			
			struct f2a
			{
				fixed4 color:SV_Target;
			};

			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;
				
				//转换到tangent空间下
				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				
				fixed3 tangentNormal = UnpackNormal(tex2D(_NormalTex,i.uv));
				tangentNormal.xy *= _NormalScale;
				tangentNormal.z = sqrt(1.0 -  saturate(dot(tangentNormal.xy,tangentNormal.xy)) );
				
				//表面色 = 纹理颜色*物体表面色
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

				//环境色 = 环境色* 表面色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));
				
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max( 0,dot( tangentNormal,halfDir ) ),_Gloss)*specularMask;
				
				return fixed4(ambient + diffuse + specular,1.0);
			}
			
		ENDCG
			
		}

	}

	//FallBack "Specular"
}	