// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Patcher/Hurtable/Hurtable Alpha Clip"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.15
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
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		AlphaToMask On
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
		uniform float _Cutoff = 0.15;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult8 = (float2(_TilingX , _TilingY));
			float2 appendResult9 = (float2(( _OffsetX - 1.0 ) , ( _OffsetY - 1.0 )));
			float2 uv_TexCoord10 = i.uv_texcoord * appendResult8 + appendResult9;
			float2 TilingOffset12 = uv_TexCoord10;
			float3 tex2DNode16 = UnpackScaleNormal( tex2D( _NormalTexture, TilingOffset12 ), _NormalStrength );
			o.Normal = tex2DNode16;
			float4 temp_output_45_0 = ( _ColorOverlayAmount * _ColorOverlay );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV20 = dot( mul(ase_tangentToWorldFast,tex2DNode16), ase_worldViewDir );
			float fresnelNode20 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV20, _FresnelPower ) );
			float clampResult22 = clamp( fresnelNode20 , 0.0 , 1.0 );
			float4 temp_output_28_0 = ( ( clampResult22 * _FresnelColor ) * _FresnelAmount );
			float4 tex2DNode37 = tex2D( _AlbedoTexture, TilingOffset12 );
			o.Albedo = ( temp_output_45_0 + ( temp_output_28_0 + ( _AlbedoColor * tex2DNode37 ) ) ).rgb;
			o.Emission = ( ( temp_output_45_0 + ( ( _FresnelEmission * temp_output_28_0 ) + float4( 0,0,0,0 ) ) ) + ( ( tex2D( _EmissionTexture, TilingOffset12 ) * _EmissionColor ) * _EmissionColor.a ) ).rgb;
			o.Metallic = ( _Metallic * tex2D( _MetallicTexture, TilingOffset12 ) ).r;
			o.Smoothness = ( _Smoothness * tex2D( _SmoothnessTexture, TilingOffset12 ) ).r;
			o.Alpha = 1;
			clip( tex2DNode37.a - _Cutoff );
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
			AlphaToMask Off
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
0;0;1920;1011;1849.525;814.7916;1.464149;True;True
Node;AmplifyShaderEditor.CommentaryNode;1;-2785.269,236.9098;Inherit;False;969.5999;401.2864;;10;12;10;9;8;7;6;5;4;3;2;Tiling/Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2733.567,529.2766;Inherit;False;Property;_OffsetY;Offset Y;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2733.567,453.6234;Inherit;False;Property;_OffsetX;Offset X;13;1;[Header];Create;True;1;Offset;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2735.269,286.9099;Inherit;False;Property;_TilingX;Tiling X;11;1;[Header];Create;True;1;Tiling;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2734.567,360.2661;Inherit;False;Property;_TilingY;Tiling Y;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-2558.577,530.942;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;-2558.598,438.0038;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-2566.577,319.9832;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-2400.579,470.9832;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2254.16,363.2242;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;11;-2208.329,-608.928;Inherit;False;762.0719;293.3044;;4;55;16;15;13;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-2031.863,357.9704;Inherit;False;TilingOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2158.329,-477.7242;Float;False;Property;_NormalStrength;Normal Strength;6;0;Create;True;0;0;0;False;0;False;0;0;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1734.623,230.8074;Inherit;False;1520.278;418.2269;;13;48;44;34;29;28;24;23;22;21;20;19;18;17;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-1997.577,-558.928;Inherit;False;12;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;16;-1766.257,-545.6238;Inherit;True;Property;_NormalTexture;Normal Texture;5;2;[Header];[SingleLineTexture];Create;True;1;Normal;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1660.823,374.5351;Inherit;False;Property;_FresnelScale;FresnelScale;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1660.023,294.8352;Inherit;False;Property;_FresnelBias;FresnelBias;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1662.788,454.6349;Inherit;False;Property;_FresnelPower;FresnelPower;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;20;-1414.623,280.8074;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-1425.981,462.9588;Inherit;False;Property;_FresnelColor;FresnelColor;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;22;-1204.756,304.0645;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1070.858,384.6272;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1192.431,529.6126;Inherit;False;Property;_FresnelAmount;Fresnel Amount;17;1;[Header];Create;True;1;Fresnel;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1182.588,705.077;Inherit;False;1055.422;491.5441;;5;47;46;33;32;31;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1423.383,-890.7755;Inherit;False;1158.863;484.2018;;6;58;51;43;39;37;30;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1132.588,809.0961;Inherit;False;12;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-927.7765,340.4091;Inherit;False;Property;_FresnelEmission;Fresnel Emission;22;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1381.376,-603.7397;Inherit;False;12;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;27;-761.2446,-286.0049;Inherit;False;551.7241;338.3878;;3;45;40;35;Color Overlay;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-928.4671,439.9489;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-895.5123,984.621;Inherit;False;Property;_EmissionColor;Emission Color;16;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;40;-668.2727,-159.6172;Inherit;False;Property;_ColorOverlay;Color Overlay;1;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;38;-2205.339,-266.9965;Inherit;False;679.6741;368.0007;;4;56;50;49;41;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;39;-1141.087,-818.4922;Inherit;False;Property;_AlbedoColor;Albedo Color;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0.2901961;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-711.2447,-236.005;Float;False;Property;_ColorOverlayAmount;Color Overlay Amount;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-940.8801,774.394;Inherit;True;Property;_EmissionTexture;Emission Texture;15;2;[Header];[SingleLineTexture];Create;True;1;Emission;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-1196.584,-636.5735;Inherit;True;Property;_AlbedoTexture;Albedo Texture;3;2;[Header];[SingleLineTexture];Create;True;1;Albedo;0;0;False;0;False;-1;None;8e1289b12af44ea409a01c7b878dfc5c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;36;-1485.291,-277.3578;Inherit;False;687.3959;385.6776;;4;54;53;52;42;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-666.692,389.9707;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-2155.339,-208.6903;Inherit;False;12;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-371.5206,-157.4628;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1435.291,-226.1338;Inherit;False;12;TilingOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-515.5392,398.7614;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-786.5859,-681.5735;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-539.6733,755.077;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-289.1664,965.053;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-338.8976,364.284;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1956.917,-216.9965;Float;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;53;-1254.851,-121.6802;Inherit;True;Property;_SmoothnessTexture;Smoothness Texture;9;2;[Header];[SingleLineTexture];Create;True;1;Smoothness;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-1247.683,-227.3578;Half;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-1976.187,-128.9958;Inherit;True;Property;_MetallicTexture;Metallic Texture;7;2;[Header];[SingleLineTexture];Create;True;1;Metallic;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-624.4827,-676.201;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-959.8953,-194.143;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-413.8569,-783.5812;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-142.2287,363.9153;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1687.666,-149.2335;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1891.466,-409.673;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-44.22876,-548.3159;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Orton/Hurtable Alpha Clip;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.15;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;2;0
WireConnection;7;0;3;0
WireConnection;8;0;4;0
WireConnection;8;1;5;0
WireConnection;9;0;7;0
WireConnection;9;1;6;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;12;0;10;0
WireConnection;16;1;15;0
WireConnection;16;5;13;0
WireConnection;20;0;16;0
WireConnection;20;1;17;0
WireConnection;20;2;18;0
WireConnection;20;3;19;0
WireConnection;22;0;20;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;28;0;23;0
WireConnection;28;1;24;0
WireConnection;33;1;31;0
WireConnection;37;1;30;0
WireConnection;34;0;29;0
WireConnection;34;1;28;0
WireConnection;45;0;35;0
WireConnection;45;1;40;0
WireConnection;44;0;34;0
WireConnection;43;0;39;0
WireConnection;43;1;37;0
WireConnection;46;0;33;0
WireConnection;46;1;32;0
WireConnection;47;0;46;0
WireConnection;47;1;32;4
WireConnection;48;0;45;0
WireConnection;48;1;44;0
WireConnection;53;1;42;0
WireConnection;50;1;41;0
WireConnection;51;0;28;0
WireConnection;51;1;43;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;58;0;45;0
WireConnection;58;1;51;0
WireConnection;57;0;48;0
WireConnection;57;1;47;0
WireConnection;56;0;49;0
WireConnection;56;1;50;0
WireConnection;55;0;13;0
WireConnection;59;0;39;4
WireConnection;59;1;37;4
WireConnection;0;0;58;0
WireConnection;0;1;16;0
WireConnection;0;2;57;0
WireConnection;0;3;56;0
WireConnection;0;4;54;0
WireConnection;0;10;37;4
ASEEND*/
//CHKSM=11C8EE7B41C2B776435050CFB835BAED85E016D1