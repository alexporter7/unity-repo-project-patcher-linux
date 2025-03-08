Shader "Patcher/Shader Graphs_World Space Floor" {
	Properties {
		[NoScaleOffset] _Albedo ("Albedo", 2D) = "white" {}
		_Tiling ("Tiling", Vector) = (0.25,0.25,0,0)
		[NoScaleOffset] _Normal ("Normal", 2D) = "white" {}
		_NormalStrength ("NormalStrength", Float) = 1
		_Smoothness ("Smoothness", Float) = 0.5
		_RotationDegrees ("RotationDegrees", Range(0, 360)) = 0
		[HideInInspector] _BUILTIN_QueueOffset ("Float", Float) = 0
		[HideInInspector] _BUILTIN_QueueControl ("Float", Float) = -1
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		CGPROGRAM
#pragma surface surf Standard
#pragma target 3.0

		sampler2D _Albedo;
		float4 _Tiling;
		sampler2D _Normal;
		float _NormalStrength;
		float _Smoothness;
		float _RotationDegrees;

		struct Input
		{
			float2 uv_Albedo;
			float2 uv_Normal;
		};

		float2 RotateUV(float2 uv, float degrees)
		{
		    float rad = radians(degrees);
		    float cosA = cos(rad);
		    float sinA = sin(rad);

		    // Center UV at (0.5, 0.5)
		    uv -= 0.5;

		    // Apply 2D rotation matrix
		    float2 rotatedUV;
		    rotatedUV.x = cosA * uv.x - sinA * uv.y;
		    rotatedUV.y = sinA * uv.x + cosA * uv.y;

		    // Re-center UV
		    return rotatedUV + 0.5;
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float4 color = tex2D(_Albedo, RotateUV(IN.uv_Albedo / _Tiling, _RotationDegrees));
			o.Albedo = color.rgb;
			o.Alpha = color.a;

			// chatgpt wrote this but it seems to work
			float3 normal = UnpackNormal(tex2D(_Normal, RotateUV(IN.uv_Normal / _Tiling, _RotationDegrees)));
            normal.xy *= _NormalStrength;
            normal = normalize(float3(normal.xy, sqrt(1.0 - saturate(dot(normal.xy, normal.xy)))));
            o.Normal = normal;

			o.Smoothness = _Smoothness;
		}
		ENDCG
	}
	Fallback "Diffuse"
}