// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//05以前的版本其实都是在计算漫反射光

Shader "Study/05_study_light_fragment_half_lambert"{
	
	//属性要在SubShader外面.
	Properties{
		diffuseColor("Color",Color) = (1,1,1,1)
	}
	
		SubShader{
			Pass{
			CGPROGRAM
	#include"lighting.cginc" //取得第一个直射光的颜色，_LightColor0 第一个直射光的位置 WorldSpaceLightPos0
	#pragma vertex ver 
	#pragma fragment frag
			fixed4 diffuseColor;					
			
			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;	 
			};
			
			//顶点传递给片元着色器的结构体
			struct v2f {
				float4 position:SV_POSITION;
				fixed3 worldNormalDir : COLOR0;
			};

			struct f2a {
				fixed4 color : SV_TARGET;
			};
			
			//逐顶点着色器
			v2f ver(a2v verData)
			{
				v2f f;
				//保存模型空间坐标
				f.position = UnityObjectToClipPos(verData.vertex);
				
				//得到法线坐标
				f.worldNormalDir = mul(verData.normal, (float3x3)unity_WorldToObject);
				return f;
			}
			
			//逐片元着色器
			f2a frag(v2f f)
			{
				//环境光
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;										
				fixed3 normalDir = f.worldNormalDir;												
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);								
				
				//等于0：两个向量相互垂直
				//大于0：两个向量的夹角范围[0,90)
				//小于0：两个向量的夹角范围(90,180]
				fixed halfLambert = dot(normalDir, lightDir)*0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb*diffuseColor.rgb*halfLambert;
				fixed3 tempColor = diffuse + ambient;
				f2a a;
				a.color = fixed4(tempColor,1);
				return a;
			}
		ENDCG
		}
	}
	
	fallback"Diffuse"
}
