// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Patcher/Hurtable/Hurtable"
{
	Properties
	{
		_ColorOverlay("Color Overlay", Color) = (1,0,0,0)
		_ColorOverlayAmount("Color Overlay Amount", Range( 0 , 1)) = 0
		[Header(Albedo)][SingleLineTexture]_AlbedoTexture("Albedo Texture", 2D) = "white" {}
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		[Header(Normal)][SingleLineTexture]_NormalTexture("Normal Texture", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range( -5 , 5)) = 0
		[Header(Metallic)][SingleLineTexture]_MetallicTexture("Metallic Texture", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[Header(Smoothness)][SingleLineTexture]_SmoothnessTexture("Smoothness Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[Header(Tiling)]_TilingX("Tiling X", Float) = 1
		_TilingY("Tiling Y", Float) = 1
		[Header(Offset)]_OffsetX("Offset X", Float) = 1
		_OffsetY("Offset Y", Float) = 1
		[Header(Emission)][SingleLineTexture]_EmissionTexture("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		[Header(Fresnel)]_FresnelAmount("Fresnel Amount", Range( 0 , 1)) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_FresnelPower("FresnelPower", Float) = 0
		_FresnelBias("FresnelBias", Float) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelEmission("Fresnel Emission", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			INTERNAL_DATA
			float3 worldNormal;
		};

		uniform sampler2D _NormalTexture;
		uniform float _TilingX;
		uniform float _TilingY;
		uniform float _OffsetX;
		uniform float _OffsetY;
		uniform float _NormalStrength;
		uniform float _ColorOverlayAmount;
		uniform float4 _ColorOverlay;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _FresnelAmount;
		uniform float4 _AlbedoColor;
		uniform sampler2D _AlbedoTexture;
		uniform float _FresnelEmission;
		uniform sampler2D _EmissionTexture;
		uniform float4 _EmissionColor;
		uniform float _Metallic;
		uniform sampler2D _MetallicTexture;
		uniform half _Smoothness;
		uniform sampler2D _SmoothnessTexture;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult45 = (float2(_TilingX , _TilingY));
			float2 appendResult46 = (float2(( _OffsetX - 1.0 ) , ( _OffsetY - 1.0 )));
			float2 uv_TexCoord43 = i.uv_texcoord * appendResult45 + appendResult46;
			float2 TilingOffset51 = uv_TexCoord43;
			float3 tex2DNode15 = UnpackScaleNormal( tex2D( _NormalTexture, TilingOffset51 ), _NormalStrength );
			o.Normal = tex2DNode15;
			float4 temp_output_20_0 = ( _ColorOverlayAmount * _ColorOverlay );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV1 = dot( mul(ase_tangentToWorldFast,tex2DNode15), ase_worldViewDir );
			float fresnelNode1 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV1, _FresnelPower ) );
			float clampResult36 = clamp( fresnelNode1 , 0.0 , 1.0 );
			float4 temp_output_29_0 = ( ( clampResult36 * _FresnelColor ) * _FresnelAmount );
			o.Albedo = ( temp_output_20_0 + ( temp_output_29_0 + ( _AlbedoColor * tex2D( _AlbedoTexture, TilingOffset51 ) ) ) ).rgb;
			o.Emission = ( ( temp_output_20_0 + ( ( _FresnelEmission * temp_output_29_0 ) + float4( 0,0,0,0 ) ) ) + ( ( tex2D( _EmissionTexture, TilingOffset51 ) * _EmissionColor ) * _EmissionColor.a ) ).rgb;
			o.Metallic = ( _Metallic * tex2D( _MetallicTexture, TilingOffset51 ) ).r;
			o.Smoothness = ( _Smoothness * tex2D( _SmoothnessTexture, TilingOffset51 ) ).r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;0;1920;1011;2626.526;656.4497;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;50;-2750.525,607.2338;Inherit;False;969.5999;401.2864;;10;51;43;45;42;39;40;41;48;46;49;Tiling/Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2698.823,899.6005;Inherit;False;Property;_OffsetY;Offset Y;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2698.823,823.9473;Inherit;False;Property;_OffsetX;Offset X;12;1;[Header];Create;True;1;Offset;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2700.525,657.2338;Inherit;False;Property;_TilingX;Tiling X;10;1;[Header];Create;True;1;Tiling;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2699.823,730.5901;Inherit;False;Property;_TilingY;Tiling Y;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-2523.833,901.2659;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-2523.854,808.3278;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;45;-2531.833,690.3071;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-2365.835,841.3071;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-2219.416,733.5482;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;64;-2173.585,-238.6041;Inherit;False;762.0719;293.3044;;4;5;61;55;15;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1997.119,728.2944;Inherit;False;TilingOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2123.585,-107.4002;Float;False;Property;_NormalStrength;Normal Strength;5;0;Create;True;0;0;0;False;0;False;0;-0.5;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1699.879,601.1314;Inherit;False;1520.278;418.2269;;12;23;25;24;35;28;29;26;27;3;36;2;1;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-1962.833,-188.6041;Inherit;False;51;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;15;-1731.513,-175.2998;Inherit;True;Property;_NormalTexture;Normal Texture;4;2;[Header];[SingleLineTexture];Create;True;1;Normal;0;0;False;0;False;-1;None;24d0b17c5bc396c4ba4451deaad2ec9c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-1625.279,665.1592;Inherit;False;Property;_FresnelBias;FresnelBias;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1626.079,744.8591;Inherit;False;Property;_FresnelScale;FresnelScale;17;0;Create;True;0;0;0;False;0;False;0;21.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1628.044,824.9589;Inherit;False;Property;_FresnelPower;FresnelPower;18;0;Create;True;0;0;0;False;0;False;0;9.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-1379.879,651.1314;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1391.237,833.2828;Inherit;False;Property;_FresnelColor;FresnelColor;20;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.05724907,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;36;-1170.012,674.3884;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1036.114,754.9512;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1157.687,899.9366;Inherit;False;Property;_FresnelAmount;Fresnel Amount;16;1;[Header];Create;True;1;Fresnel;0;0;False;0;False;0;0.576;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;-1147.844,1075.401;Inherit;False;1055.422;491.5441;;5;56;33;31;34;68;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-1388.639,-520.4515;Inherit;False;1158.863;484.2018;;6;22;30;7;8;17;54;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-893.7227,810.2728;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1346.632,-233.4157;Inherit;False;51;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;67;-726.5002,84.31904;Inherit;False;551.7241;338.3878;;3;16;20;6;Color Overlay;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-1097.844,1179.42;Inherit;False;51;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-893.0321,710.7331;Inherit;False;Property;_FresnelEmission;Fresnel Emission;21;0;Create;True;0;0;0;False;0;False;0;0.396;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-860.7679,1354.945;Inherit;False;Property;_EmissionColor;Emission Color;15;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-906.1357,1144.718;Inherit;True;Property;_EmissionTexture;Emission Texture;14;2;[Header];[SingleLineTexture];Create;True;1;Emission;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-631.9476,760.2947;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-676.5003,134.319;Float;False;Property;_ColorOverlayAmount;Color Overlay Amount;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1450.547,92.9662;Inherit;False;687.3959;385.6776;;4;53;9;19;10;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;8;-1161.84,-266.2496;Inherit;True;Property;_AlbedoTexture;Albedo Texture;2;2;[Header];[SingleLineTexture];Create;True;1;Albedo;0;0;False;0;False;-1;None;eabea3aa18fab8a47bfdf8b590346c0f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;63;-2170.595,103.3275;Inherit;False;679.6741;368.0007;;4;52;18;4;11;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;17;-1106.343,-448.1682;Inherit;False;Property;_AlbedoColor;Albedo Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;16;-633.5283,210.7068;Inherit;False;Property;_ColorOverlay;Color Overlay;0;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;53;-1400.547,144.1902;Inherit;False;51;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-751.8415,-311.2495;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2120.595,161.6337;Inherit;False;51;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-504.929,1125.401;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-480.7948,769.0853;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-336.7762,212.8612;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-254.422,1335.377;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-304.1532,734.608;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1922.173,153.3275;Float;False;Property;_Metallic;Metallic;7;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-1941.443,241.3282;Inherit;True;Property;_MetallicTexture;Metallic Texture;6;2;[Header];[SingleLineTexture];Create;True;1;Metallic;0;0;False;0;False;-1;None;9bd1179d3835d3846b7d65e4ec02163d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-589.7383,-305.877;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1212.939,142.9662;Half;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;0;False;0;False;0;0.505;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-1220.107,248.6438;Inherit;True;Property;_SmoothnessTexture;Smoothness Texture;8;2;[Header];[SingleLineTexture];Create;True;1;Smoothness;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-925.1509,176.181;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-379.1125,-413.2572;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1856.722,-39.34904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-107.4844,734.2393;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1652.922,221.0905;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Orton/Hurtable;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;Diffuse;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;42;0
WireConnection;48;0;41;0
WireConnection;45;0;39;0
WireConnection;45;1;40;0
WireConnection;46;0;48;0
WireConnection;46;1;49;0
WireConnection;43;0;45;0
WireConnection;43;1;46;0
WireConnection;51;0;43;0
WireConnection;15;1;55;0
WireConnection;15;5;5;0
WireConnection;1;0;15;0
WireConnection;1;1;23;0
WireConnection;1;2;24;0
WireConnection;1;3;25;0
WireConnection;36;0;1;0
WireConnection;3;0;36;0
WireConnection;3;1;2;0
WireConnection;29;0;3;0
WireConnection;29;1;27;0
WireConnection;33;1;56;0
WireConnection;28;0;26;0
WireConnection;28;1;29;0
WireConnection;8;1;54;0
WireConnection;7;0;17;0
WireConnection;7;1;8;0
WireConnection;34;0;33;0
WireConnection;34;1;31;0
WireConnection;35;0;28;0
WireConnection;20;0;6;0
WireConnection;20;1;16;0
WireConnection;68;0;34;0
WireConnection;68;1;31;4
WireConnection;65;0;20;0
WireConnection;65;1;35;0
WireConnection;18;1;52;0
WireConnection;30;0;29;0
WireConnection;30;1;7;0
WireConnection;19;1;53;0
WireConnection;10;0;9;0
WireConnection;10;1;19;0
WireConnection;22;0;20;0
WireConnection;22;1;30;0
WireConnection;61;0;5;0
WireConnection;69;0;65;0
WireConnection;69;1;68;0
WireConnection;11;0;4;0
WireConnection;11;1;18;0
WireConnection;0;0;22;0
WireConnection;0;1;15;0
WireConnection;0;2;69;0
WireConnection;0;3;11;0
WireConnection;0;4;10;0
ASEEND*/
//CHKSM=23FEE18413C9F0A5C971E99F46163434CCD6F205