// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader"Study/10_single_texture"
{
		Properties
		{
			_FaceColor("FaceColor",Color) = (1,1,1,1)				//物体表面颜色
			_SpecularColor("SpecularColor",Color) = (1,1,1,1)		//镜面高光的颜色
			_BlendTex("BlendTex",2D) = "white"{}					//纹理
			_Gloss("Gloss",Range(5,20)) = 5						//光的强度(光晕的大小)
		}
		
		SubShader{
		Pass{
			CGPROGRAM 
#include"Lighting.cginc"


#pragma vertex vert //定义顶点函数
#pragma fragment frag//定义片元函数
			struct a2v 
			{
				float4 position:POSITION;
				float3 normal:	NORMAL;
				float4 texCoord:TEXCOORD0;
			};
			
			struct v2f
			{
				float4 position:SV_POSITION;		
				float3 worldNormal:TEXCOORD0;		
				float4 worldVertex:TEXCOORD1;		
				float2 uv	      :TEXCOORD2;
			};
			
			struct finish
			{
				fixed4 color:SV_TARGET;
			};
			
			//取到外部变量
			float4 _FaceColor;
			float4 _SpecularColor;
			sampler2D _BlendTex;
			float4 _BlendTex_ST;
			half	_Gloss;

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f f;
				f.position = UnityObjectToClipPos(v.position);		
				f.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				f.worldVertex = mul(unity_ObjectToWorld,v.position);
				
				v.texCoord.xy *= _BlendTex_ST.xy ;
				v.texCoord.xy += _BlendTex_ST.zw;
				
				f.uv = v.texCoord;
				return f;
			}
			
			finish frag(v2f f)
			{
				//漫反射的颜色
				fixed3 normal = f.worldNormal;
				fixed3 lightDir = normalize( WorldSpaceLightDir(f.worldVertex) );

				//纹理的颜色和表面颜色混色 = 反射率???
				fixed3 albedo = tex2D(_BlendTex,f.uv.xy)*_FaceColor.rgb;
				fixed3 diffuse = _LightColor0.rgb*albedo*max(dot(normal, lightDir),0);
				float3 ambient = albedo*UNITY_LIGHTMODEL_AMBIENT.rgb;
				
				//高光颜色
				fixed3 viewDir = normalize( UnityWorldSpaceViewDir( f.worldVertex ) ) ;
				fixed3 halfDir = normalize(( lightDir+viewDir ));

				//cosδ δ=顶点离摄像机的方向和顶点离摄像机方向和顶点到光方向的平分线的夹角 
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow( max( dot(normal,halfDir ),0),_Gloss);
				
				//颜色的相加
				finish fh;
				fixed3 tempColor = diffuse + specular + ambient;
				fh.color = fixed4(tempColor,1);
				return fh;
			}
			ENDCG
		}
	}
	fallBack"Diffuse"
}
