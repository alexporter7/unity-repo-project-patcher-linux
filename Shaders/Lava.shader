Shader "Lava" {
	Properties {
		_DiscortScale ("DiscortScale", Float) = 1
		_Scale ("Scale", Float) = 1
		[SingleLineTexture] _Distort ("Distort", 2D) = "white" {}
		[SingleLineTexture] _Tex ("Tex", 2D) = "white" {}
		_DistortScroll ("DistortScroll", Vector) = (0,0,0,0)
		_Scroll ("Scroll", Vector) = (0,0,0,0)
		_DistortStr ("DistortStr", Float) = 0
		[HDR] _Color1 ("Color 1", Vector) = (0,0,0,0)
		[HDR] _Color2 ("Color 2", Vector) = (1,1,1,0)
		[HDR] _EdgeColor ("EdgeColor", Vector) = (0,0,0,0)
		_EdgeWidth ("EdgeWidth", Float) = 0.2
		[HideInInspector] __dirty ("", Float) = 1
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		CGPROGRAM
#pragma surface surf Standard
#pragma target 3.0

		sampler2D _Tex;
		fixed3 _Color1;
		fixed3 _Color2;
		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 value = tex2D(_Tex, IN.uv_MainTex);
			half3 color = lerp(_Color1, _Color2, value);
			o.Albedo = color;
			o.Alpha = value.a;
		}
		ENDCG
	}
	Fallback "Diffuse"
}