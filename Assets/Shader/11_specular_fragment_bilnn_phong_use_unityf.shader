// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//05以前的版本其实都是在计算漫反射光
//高光反射(镜面光)
//specular = 直射光*pow( max(cosδ,0),10 ) δ:是反射光方向和视野方向的夹角

Shader "Study/11_specular_fragment_bilnn_phong_use_unityf"{

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
				float3 worldNormal:TEXCOORD0;//在世界坐标上的法线
				float3 worldVertex:TEXCOORD1;//在世界坐标上的顶点 
			};

			struct f2a {
				fixed4 color:SV_TARGET;
			};

			//逐顶点着色器
			v2f ver(a2v verData)
			{
				v2f f;
				f.position = UnityObjectToClipPos(verData.vertex);//V:在模型空间里的坐标和剪裁空间顶点坐标相乘？？？  还是应该理解成从模型空间转到到剪裁空间？？？
				//f.worldNormal = mul(verData.normal,(float3x3)unity_WorldToObject);//算出来的法线是世界法线吗
				
				f.worldNormal = UnityObjectToWorldNormal(verData.normal);
				
				f.worldVertex = mul(unity_ObjectToWorld,verData.vertex).xyz;
				//算出来的是没单位化的
				
				return f;
			}
			
			//逐片元着色器
			f2a frag(v2f v)
			{
				f2a f;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				fixed3 normalDir =normalize(v.worldNormal);
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				//漫反射光的lambert模型，范围在0-1
				float diffuseHalfLambert = dot(normalDir,lightDir)*0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb*diffuseHalfLambert*diffuseColor.rgb; //漫反射光的颜色
				
				//  把光线入射方向和顶点法线方向带入reflect计算出来的是出射向量。
				fixed3 specularDir = normalize(reflect(-lightDir, normalDir));
				//相机位置				
				
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(v.worldVertex));//
				//镜面光颜色
				
				//blinn-phong光照模型
				//使用blinn-phong光照模型计算出来的光照顶点更大更圆润，实际项目中用这个的比较多
				fixed3 bisectorLineDir = normalize(lightDir+viewDir) ;//平行光和视野方向的平分线
				float cosValue = max(dot(normalDir,bisectorLineDir),0);
				fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow(cosValue,_Gloss);
				fixed3 tempColor = diffuse + ambient + specularColor;
				
				//传入世界坐标返回世界坐标相对于光的方向，但是返回出来的都是(0,1,0)
				float3 relativeWorldLightDir = UnityWorldSpaceLightDir(v.position);
				
				f.color = fixed4(tempColor.rgb,1);
				return f;
			}
		ENDCG
		}
	}
}
/*s
	blinn光照模型:Specular=直射光* pow(max(cosδ,0),10) δ:反射光方向和视野方向的夹角
	blinn-phong光照模型：Specular=直射光颜色 * pow(max(cosδ,0),10) δ:是法线和X的夹角 X=平行光和视野方向的平分线
	dot==cos???等于吗
*/