// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//05以前的版本其实都是在计算漫反射光
//高光反射(镜面光)
//specular = 直射光*pow( max(cosδ,0),10 ) δ:是反射光方向和视野方向的夹角

Shader "Study/07_study_specular"{
	
	//属性要在SubShader外面.
	Properties{	
		diffuseColor("Color",Color) = (1,1,1,1)					//漫反射的颜色(可以理解成身上的颜色)
		_Gloss("glossRange",Range(1,200)) = 10					//光的范围
		_SpecularColor("specularColor",Color) = (1,1,1,1)		//漫反射光的颜色(反射出去的颜色)
		
	}
		SubShader{
			Pass{
				CGPROGRAM
	#include"lighting.cginc" //取得第一个直射光的颜色，_LightColor0 第一个直射光的位置 WorldSpaceLightPos0
	#pragma vertex ver 
	#pragma fragment frag
			fixed4 diffuseColor;					//在CG里面重新声明diffuse 拿到外部的数据，转换成fixed4 类型
	half _Gloss;
	fixed4 _SpecularColor;
			
			//应用程序传递给顶点着色器的结构
			struct a2v {
				float4 vertex:POSITION; //虽然后一个数据没用，但是坐标要和matrix相乘还得用float4
				float3 normal:NORMAL;	  //顶点法线
			};
				
			//顶点传递给片元着色器的结构体
			struct v2f {
				float4 position:SV_POSITION;
				fixed3 color : COLOR0;
			};
				
			struct f2a {
				fixed4 color : SV_TARGET;
			};
				
			//逐顶点着色器
			v2f ver(a2v verData)
			{
				v2f f;
				f.position = UnityObjectToClipPos(verData.vertex);//V:在模型空间里的坐标和剪裁空间顶点坐标相乘？？？  还是应该理解成从模型空间转到到剪裁空间？？？
				
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//漫反射光 这个可以取rgba,但是用不到a，就不用取了
				
				fixed3 normalDir = normalize(mul(verData.normal, (float3x3)unity_WorldToObject));//顶点法线和什么相乘？？？得到了新的法线(world2Object是什么？？？)
				
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 diffuse = _LightColor0.rgb*max(dot(normalDir, lightDir), 0)*diffuseColor.rgb; //漫反射光的颜色
				
				//感觉计算出来的镜面光有问题啊，为什么是一块长方形的...
				//计算镜面光需要的参数//根据逐顶点shader改过来的
				//镜面光方向=-光的方向*法线向量的单位
				//镜面光颜色
				//NOTE:
				// \ | / 
				//  \|/ 
				//  把光线入射方向和顶点法线方向带入reflect计算出来的是出射向量。
				fixed3 specularDir = normalize(reflect(-lightDir, normalDir));
				
				//相机位置											//从模型空间转换到世界空间			应该是摄像机到这个顶点的向量					
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(verData.vertex, unity_WorldToObject).xyz);

				//镜面光颜色
				fixed3 specularColor = _LightColor0.rgb* pow( max(dot(specularDir, viewDir),0), _Gloss)*_SpecularColor.rgb;
				
				f.color = diffuse + ambient+ specularColor;

				return f;
			}

			//逐片元着色器
			f2a frag(v2f v)
			{
				f2a f;
				f.color = fixed4(v.color, 1);
				return f;
			}
		ENDCG
		}
	}
		//如果没有就默认使用系统的漫反射shader
	fallback"Diffuse"
}
