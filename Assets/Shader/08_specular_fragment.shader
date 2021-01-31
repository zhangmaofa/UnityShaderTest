// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


//高光也叫做Phong光照模型

Shader "Study/08_specular_fragmeng"{
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
				//剪裁空间中的坐标
				float4 position:SV_POSITION;

				//世界坐标中的法线
				float3 worldNormal:TEXCOORD0;

				//世界空间中的坐标
				float3 worldVertex:TEXCOORD1;
			};
			
			struct f2a {
				fixed4 color:SV_TARGET;
			};

			//逐顶点着色器
			v2f ver(a2v verData)
			{
				v2f f;
				f.position = UnityObjectToClipPos(verData.vertex);
				
				f.worldNormal = mul(verData.normal,(float3x3)unity_WorldToObject);
				
				f.worldVertex = mul(unity_ObjectToWorld,verData.vertex).xyz;
				return f;
			}
			
			//逐片元着色器
			f2a frag(v2f v)
			{
				f2a f;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//漫反射光 这个可以取rgba,但是用不到a，就不用取了
				fixed3 normalDir =normalize(v.worldNormal);//顶点法线和什么相乘？？？得到了新的法线(world2Object是什么？？？)
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				//漫反射光的lambert模型，范围在0-1
				float diffuseHalfLambert = dot(normalDir,lightDir)*0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb*diffuseHalfLambert*diffuseColor.rgb; //漫反射光的颜色
				
				//计算出射向量
				//fixed3 r = 2*dot(normalDir,-lightDir)*normalDir-(-lightDir);
				fixed3 specularDir = normalize(reflect(-lightDir, normalDir));
				
				//相机位置														
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - v.worldVertex);
				//镜面光颜色
				
				//blinn光照模型(模拟金属材质) 
				//出射角·视口方向，角度大眼睛是看不到折射出的光线的。
				float specularHalfLambert = dot(specularDir,viewDir)*0.5 + 0.5;
				
				fixed3 specularColor = _LightColor0.rgb* _SpecularColor.rgb * pow(specularHalfLambert,_Gloss);
				
				fixed3 tempColor = diffuse + ambient + specularColor;
				
				f.color = fixed4(tempColor,1);
				
				return f;
			}
		ENDCG
		}
	}
}

/*
	blinn光照模型:Specular=直射光* pow(max(cosδ,0),10) δ:反射光方向和视野方向的夹角
	bilnn-phong光照模型：Specular=直射光颜色 * pow(max(cosδ,0),10) δ:是法线和X的夹角 X=平行光和视野方向的平分线

*/