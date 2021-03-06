﻿
Shader "BanMing/Specular-Vertex" {
	Properties{
		_Diffuse("Diffuse Color",Color)=(1,1,1,1)
		_Glass("Glass",Range(8,200))=10
		_SpecularColor("Specular Color",Color)=(1,1,1,1)
	}

	SubShader
	{
		Pass
		{
		Tags{"LightMode"="ForwardBase"}//光照标签
		CGPROGRAM
		float4 _Diffuse;//在Properties中定义了，要在CGPROGAM中使用就需要再次定义
		float4 _SpecularColor;
		half _Glass;
//引入光照文件
#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag

		struct a2v {
			float4 vertex:POSITION;
			fixed3 normal :NORMAL;
		};

		struct v2f{
			float4 position :SV_POSITION;
			float3 color:COLOR;
		};

		v2f vert(a2v v){
			v2f f;			
			f.position=UnityObjectToClipPos(v.vertex);
			fixed3 normalDir=normalize(UnityObjectToWorldDir((float3)v.normal));
			fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.rgb;
			//光照的位置，因为光是平行光所以也是方向
			fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
			//_LightColor0是光照的颜色
			fixed3 reflectDir=normalize(reflect(-lightDir,normalDir));
			fixed3 viewDir=UnityObjectToWorldNormal(_WorldSpaceCameraPos.xyz-v.vertex);		
			fixed3 specular=_LightColor0.rgb*pow(max(dot(reflectDir,viewDir),0),_Glass)*_SpecularColor.rgb;
			fixed3 diffuse =_LightColor0.rgb*max(dot(normalDir,lightDir),0);
			f.color =diffuse*_Diffuse.rgb+ambient+specular;
			return f;
		}

		fixed4 frag (v2f f):SV_TARGET{
			return fixed4(f.color,1);
		}
		ENDCG
		}
	}
		FallBack "Diffuse"
}
