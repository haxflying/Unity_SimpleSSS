Shader "Unlit/RenderDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			
			ZWrite On
			ColorMask 0
			Fog {Mode Off}
		}
	}
}
