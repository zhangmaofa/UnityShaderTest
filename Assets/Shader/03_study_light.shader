// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Study/03_study_light"{


	//属性要在SubShader外面.
	Properties
	{
		diffuseColor("Color",Color) = (1,1,1,1)
	}
		
		SubShader
		{
			Pass{
			
			CGPROGRAM
	#include"UnityCG.cginc"
	#include"lighting.cginc" //取得第一个直射光的颜色，_LightColor0 第一个直射光的位置 WorldSpaceLightPos0
	#pragma vertex ver 
	#pragma fragment frag
			uniform fixed4 diffuseColor;					//在CG里面重新声明diffuse 拿到外部的数据，转换成fixed4 类型

			//应用程序传递给顶点着色器的结构
			struct a2v{
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
			v2f ver(a2v verData )
			{
				v2f f;
				
				//模型空间转到的透视空间
				f.position = UnityObjectToClipPos(verData.vertex);//V:在模型空间里的坐标和剪裁空间顶点坐标相乘？？？  还是应该理解成从模型空间转到到剪裁空间？？？
				
				//取到环境的rgb
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//漫反射光 这个可以取rgba,但是用不到a，就不用取了
				
				//法线变换要使用逆转置矩阵，(正常应该使用“unity_ObjectToWorld”对象到世界空间的变换这个矩阵，可是因为要使用逆矩阵所以用“unity_WorldToObject”这个矩阵，
											 //正常应该使用 矩阵*向量，可是要求要转置矩阵，所以调换了一下顺序。因此和产生出来的逆转置矩阵相乘，得到正确的法线方向)
				fixed3 normalDir = normalize(mul(verData.normal, (float3x3)unity_WorldToObject));//
				
				//0号光的方向
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				//最终颜色=0号光的RGB *法线和光方向的点乘*外设的额diffuse颜色
				fixed3 diffuse = _LightColor0.rgb*max( saturate( dot(normalDir, lightDir) ), 0)*diffuseColor.rgb;
				
				//漫反射光rgb和环境光rgb相加
				f.color = diffuse + ambient;
				
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
	//fallback"diffuse"
}


//光照模型就是个公式，使用此公式计算光照效果。
//高光 \/  specular 

//漫反射 ->米 diffuse=直射光颜色*cos(光和法线的夹角) cos0=1 夹角是0度光亮度最强 cos1=0 
//环境光 /\/	
  
//妈耶那个人代码也没给出来。


//floatNxN  n最多是4 这个我试过了

//从模型空间转换到透视空间
//这个反过来意义就完全不一样了mul(UNITY_MATRIX_MVP,verData.vertex);
//所以计算的时候一定要mvp矩阵在前点在后。