Shader "Unlit/SSS02"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Divide("Divide",Range(0,60)) = 30
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			//Cull Off
			//BlendOp RevSub
			//Blend SrcColor DstColor
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 sh : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float4 projPos : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.sh = ComputeScreenPos(o.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.projPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				return o;
			}
			
			UNITY_DECLARE_SCREENSPACE_SHADOWMAP(_ShadowMapTexture);
			sampler2D _CameraDepthTexture;
			float _Divide;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 shadow = UNITY_SAMPLE_SCREEN_SHADOW(_ShadowMapTexture,i.sh);
				float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;

				float thick = sceneZ ;
				thick /= _Divide;

				UNITY_APPLY_FOG(i.fogCoord, col);
				return 0.5;
			}
			ENDCG
		}
	}
}
