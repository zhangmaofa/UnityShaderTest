// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Study/01_TestShader" {
	//
		SubShader{
			Pass {
			CGPROGRAM

			//#include"Lighting.cginc"
			#include"UnityCG.cginc"
										//这连个函数是unity自己调用的? #pragma感觉就相当于是一个函数啊。
										//能正确的加载模型是把正确的模型空间转换到了剪裁空间    
#pragma vertex vert						//顶点着色器对所有的顶点进行了操作---完成模型空间到剪裁空间的转换
#pragma fragment frag					//片元着色器对所有片面的像素进行操作 返回每一个像素值
#pragma enable_d3d11_debug_symbols

			struct v2f
			{
				fixed4 position:SV_POSITION;
				fixed4 color:COLOR;
			};
			struct finish
			{
				fixed4 color:SV_TARGET;//
			};
			
			//可以带入参数和返回值(shaderLab中形参和返回值都不是固定的)	
			//返回类型 函数名(上面定义的) [传入的参数类型:需要系统给我的参数] [返回的参数类型:需要保存出去的类型(演示里保存顶点的position信息)] 
			v2f vert(appdata_full afull)
			{
				v2f _v2f;
				_v2f.position = UnityObjectToClipPos(afull.vertex);
				
				//法线
				//_v2f.color = fixed4( afull.normal*0.5 + fixed3(0.5,0.5,0.5) ,1.0);
				
				//切线
				//_v2f.color = fixed4( afull.tangent*0.5 + fixed3(0.5,0.5,0.5) ,1.0);
				
				//第一纹理坐标
				_v2f.color = fixed4( afull.texcoord.xy,0,1.0);
				
				/*
				_v2f.tangent = fixed4(afull.):
				_v2f.normal = fixed4(afull.):
				_v2f.texcoord = fixed4(afull.):
				*/
				return _v2f;
			}
			
			finish frag(v2f _v2f)
			{
				finish fn;
				fn.color = _v2f.color;
				return fn;
			}
		    ENDCG
		}
	}
	FallBack "vertexlit"
}

//unity中参数类型
	//SV_POSITION	坐标信息
	//SV_Target		有点类似于DX里的获取COLOR的接口 写了这个就不需要往括号里带形参
	
	
//unity中的矩阵
	//UNITY_MATRIX_MVP  把模型空间转换到剪裁空间
	//


//unity内置的计算矩阵和float4的函数
	//mul(mul)


/*
语法
属性
Properties { Property [Property ...] }

数字和滑动条
name ("display name", Range (min, max)) = number
name ("display name", Float) = number
name ("display name", Int) = number

颜色和向量
name ("display name", Color) = number
name ("display name", vector2) = number
name ("display name", vector3) = number
name ("display name", vecto4) = number

name ("display name", 2D) = "defaulttexture" {}
name ("display name", Cube) = "defaulttexture" {}
name ("display name", 3D) = "defaulttexture" {}

*/