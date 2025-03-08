Shader "Hurtable/Hurtable" {
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
		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 c = tex2D(_AlbedoTexture, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	Fallback "Diffuse"
}