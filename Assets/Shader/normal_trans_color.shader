// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Study/02_normal_trans_color" {
	
	SubShader{
		
		Pass{

		CGPROGRAM


#pragma  vertex ver

#pragma  fragment frag

		struct a2v //application to vertex 好像是应用程序(底层)(会把数据传递过来)传递给操作顶点信息
		{
			float4  position:POSITION; //语义必须要写
			float3  normal : NORMAL;
		};
		
		struct v2f   //顶点数据会传递给片元 - _ - 会用三个顶点和每个像素值进行插值运算,好像每次都要调用调用顶点函数运算一次然后在调用片元函数拿到v2f里的数据后再次进行运算. 
		{
			float4 position:SV_POSITION;
			float3 color:COLOR0;
		};
		
		//顶点函数把法线返回出去给片元函数当颜色用。
		v2f ver(a2v a) //返回类型定义了语意了，所以这边不需要再返回值后面定义语义
		{
			v2f v;
			v.position = UnityObjectToClipPos(a.position);//带入的模型坐标不要直接返回出去，返回出去的的时候要和unity的透视矩阵相乘才可以，如果直接返回出去坐标会导致错误。
			v.color = a.normal;
			return v;
		}
		
		fixed4 frag(v2f v):SV_TARGET	//接收顶点函数的法线坐标当做颜值。
		{
			return fixed4(v.color,1);
		}
		ENDCG

		}
	}

	//FullBack"Diffuse";
}

//随笔笔记：
//shader没办法打印日志，有时候调试的方法就得用颜色的方式来打印。
//把数据当做颜色来输出，显示出来用做调试办法(666的调试办法)
//看到这个就想起来脚本语言，然后就习惯不加";" fuck~~~!!!
//以上都是比较简单的对顶点函数和片元函数交互的操作。

//UNITY_MATRIX_MVP(m:model v:view p:position???)是这样吗猜的，模型空间坐标