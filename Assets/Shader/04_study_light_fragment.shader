// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "Study/04_study_light_fragment"{

	//属性要在SubShader外面.
	Properties{
		diffuseColor("Color",Color) = (1,1,1,1)
	}

		SubShader{
			Pass
			{
			CGPROGRAM
	#include"lighting.cginc" //取得第一个直射光的颜色，_LightColor0 第一个直射光的位置 WorldSpaceLightPos0
	#pragma vertex ver 
	#pragma fragment frag
	
	//自定义漫反射光的颜色
			fixed4 diffuseColor;					
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;	 
			};
			
			//顶点传递给片元着色器的结构体
			struct v2f 
			{
				float4 position:SV_POSITION;
				fixed3 worldNormalDir : COLOR0;
			};

			struct f2a 
			{
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
				//环境光(不会对周围的物体发射光线)
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;										
				
				//法线方向
				fixed3 normalDir = f.worldNormalDir;			
				
				//世界灯光的方向
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);								
				//这里整个表达式都是在计算漫反射光. 
				
				fixed3 diffuse = _LightColor0.rgb*max( saturate( dot(normalDir,lightDir) ) ,0)*diffuseColor.rgb;
				//受默认光源、漫反射光、环境光影响。 //
				fixed3 tempColor = diffuse + ambient;//漫反射光+环境光
				f2a a;
				a.color = fixed4(tempColor.rgb,1);
				return a;
			}
		ENDCG
		}
	}
		//如果没有就默认使用系统的漫反射shader
	fallback"Diffuse"
}
