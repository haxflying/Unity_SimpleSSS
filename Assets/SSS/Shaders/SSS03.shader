Shader "Unlit/SSS03"
{
	Properties
	{
		_Color("Base Color",Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_ThickTex("Thick Tex", 2D) = "white" {}
		_DiffuseWeiggt("Diffuse Weight", Range(0,1)) = 0.3
		_ScatteringWeiggt("_ScatteringWeiggt Weight", Range(0,1)) = 0.9
		_sigma("Sigma",Float) = -30
		_Gloss("Gloss",Float) = 40
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 wnormal : TEXCOORD2;
			};

			sampler2D _MainTex, _ThickTex;
			float4 _MainTex_ST;
			float4x4 _C_V,_C_P;
			float4 _DepthCamPos;
			float _DiffuseWeiggt,_sigma,_ScatteringWeiggt,_Gloss;
			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.wnormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				float3 N = normalize(i.wnormal);
				float3 L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
				float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				float3 H = normalize(L + V);
				fixed4 col = tex2D(_MainTex, i.uv);

				float4 depthCamViewPos = mul(_C_V, float4(i.worldPos, 1));
				float4 depthCamProjPos = mul(_C_P, depthCamViewPos);
				float2 depthCamViewPortPos = depthCamProjPos.xy/depthCamProjPos.w * 0.5 + 0.5;
				float3 partDepth = length(_DepthCamPos - i.worldPos)/40.0;

				fixed thickness = tex2D(_ThickTex, float2(1,1) - depthCamViewPortPos);

				thickness = saturate(abs(partDepth - thickness) * 3);
				//thickness = 1 - thickness;

				fixed3 diffuse = saturate(dot(N,L)) * col.rgb;
				fixed3 specular = pow(saturate(dot(H,N)),_Gloss);
				fixed intensity = exp(-_sigma * thickness);

				col = fixed4(_DiffuseWeiggt * diffuse * _Color + intensity * _ScatteringWeiggt * _Color + specular, 1.0);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
