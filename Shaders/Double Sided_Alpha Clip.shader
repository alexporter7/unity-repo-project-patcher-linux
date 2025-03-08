Shader "Patcher/Double Sided_Alpha Clip"
{
    Properties
    {
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Albedo ("Albedo", 2D) = "white" { }
        _Cutoff ("Mask Clip Value", Float) = 0.1
        [HideInInspector] _texcoord ("", 2D) = "white" { }
        [HideInInspector] __dirty ("", Float) = 1
    }
SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Cull Off
		CGPROGRAM
#pragma surface surf Standard
#pragma target 3.0

		float _Smoothness;
		float _Metallic;
		sampler2D _Albedo;
		float _Cutoff;

		struct Input
		{
			float2 uv_Albedo;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float3 color = tex2D(_Albedo, IN.uv_Albedo);
			o.Albedo = color;

			o.Smoothness = _Smoothness;
			o.Metallic = _Metallic;
		}
		ENDCG
	}
    FallBack "Diffuse"
}
