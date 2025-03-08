Shader "Patcher/Hurtable/Hurtable" {
	Properties {
		_ColorOverlay ("Color Overlay", Vector) = (1,0,0,0)
		_ColorOverlayAmount ("Color Overlay Amount", Range(0, 1)) = 0
		[Header(Albedo)] [SingleLineTexture] [NoScaleOffset] _AlbedoTexture ("Albedo Texture", 2D) = "white" {}
		_AlbedoColor ("Albedo Color", Vector) = (1,1,1,0)
		[Header(Normal)] [SingleLineTexture] [NoScaleOffset] [Normal] _NormalTexture ("Normal Texture", 2D) = "white" {}
		_NormalStrength ("Normal Strength", Range(-5, 5)) = 0
		[Header(Metallic)] [SingleLineTexture] [NoScaleOffset] _MetallicTexture ("Metallic Texture", 2D) = "white" {}
		_Metallic ("Metallic", Range(0, 1)) = 0
		[Header(Smoothness)] [SingleLineTexture] [NoScaleOffset] _SmoothnessTexture ("Smoothness Texture", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		[Header(Tiling)] _TilingX ("Tiling X", Float) = 1
		_TilingY ("Tiling Y", Float) = 1
		[Header(Offset)] _OffsetX ("Offset X", Float) = 1
		_OffsetY ("Offset Y", Float) = 1
		[Header(Emission)] [SingleLineTexture] [NoScaleOffset] _EmissionTexture ("Emission Texture", 2D) = "white" {}
		[HDR] _EmissionColor ("Emission Color", Vector) = (0,0,0,1)
		[Header(Fresnel)] _FresnelAmount ("Fresnel Amount", Range(0, 1)) = 0
		_FresnelScale ("Fresnel Scale", Float) = 0
		_FresnelPower ("Fresnel Power", Float) = 0
		_FresnelBias ("Fresnel Bias", Float) = 0
		_FresnelColor ("Fresnel Color", Vector) = (0,0,0,0)
		_FresnelEmission ("Fresnel Emission", Range(0, 1)) = 0
		[HideInInspector] _texcoord ("", 2D) = "white" {}
		[HideInInspector] __dirty ("", Float) = 1
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		CGPROGRAM
#pragma surface surf Standard
#pragma target 3.0

		sampler2D _AlbedoTexture;
		sampler2D _NormalTexture;
		float _NormalStrength;
		sampler2D _MetallicTexture;
		float _Metallic;
		sampler2D _SmoothnessTexture;
		float _Smoothness;

		struct Input
		{
			float2 uv_AlbedoTexture;
			float2 uv_NormalTexture;
            float2 uv_MetallicTexture;
			float2 uv_SmoothnessTexture;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float4 color = tex2D(_AlbedoTexture, IN.uv_AlbedoTexture);
			o.Albedo = color.rgb;
			o.Alpha = color.a;

			// chatgpt wrote this but it seems to work
			float3 normal = UnpackNormal(tex2D(_NormalTexture, IN.uv_NormalTexture));
            normal.xy *= _NormalStrength;
            normal = normalize(float3(normal.xy, sqrt(1.0 - saturate(dot(normal.xy, normal.xy)))));
            o.Normal = normal;

			o.Metallic = tex2D(_MetallicTexture, IN.uv_MetallicTexture).r * _Metallic;
			o.Smoothness = tex2D(_SmoothnessTexture, IN.uv_SmoothnessTexture).r * _Smoothness;
		}
		ENDCG
	}
	Fallback "Diffuse"
}