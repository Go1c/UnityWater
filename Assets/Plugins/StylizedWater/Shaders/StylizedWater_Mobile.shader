// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StylizedWater/Mobile"
{
	Properties
	{
		[HDR]_WaterColor("Water Color", Color) = (0.1176471,0.6348885,1,0)
		[HDR]_WaterShallowColor("WaterShallowColor", Color) = (0.4191176,0.7596349,1,0)
		_Wavetint("Wave tint", Range( -1 , 1)) = 0
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0.5019608)
		_NormalStrength("NormalStrength", Range( 0 , 1)) = 0.25
		_Transparency("Transparency", Range( 0 , 1)) = 0.75
		_Glossiness("Glossiness", Range( 0 , 1)) = 0.85
		[Toggle]_Worldspacetiling("Worldspace tiling", Float) = 1
		_NormalTiling("NormalTiling", Range( 0 , 1)) = 0.9
		_EdgeFade("EdgeFade", Range( 0.01 , 3)) = 0.2448298
		_RimSize("Rim Size", Range( 0 , 20)) = 5
		_Rimfalloff("Rim falloff", Range( 0.1 , 50)) = 3
		_Rimtiling("Rim tiling", Float) = 0.5
		_FoamOpacity("FoamOpacity", Range( -1 , 1)) = 0.05
		_FoamSpeed("FoamSpeed", Range( 0 , 1)) = 0.1
		_FoamSize("FoamSize", Float) = 0
		_FoamTiling("FoamTiling", Float) = 0.05
		_Depth("Depth", Range( 0 , 100)) = 30
		_Wavesspeed("Waves speed", Range( 0 , 10)) = 0.75
		_WaveHeight("Wave Height", Range( 0 , 1)) = 0.5366272
		_WaveFoam("Wave Foam", Range( 0 , 10)) = 0
		_WaveSize("Wave Size", Range( 0 , 10)) = 0.1
		_WaveDirection("WaveDirection", Vector) = (1,0,0,0)
		[NoScaleOffset][Normal]_Normals("Normals", 2D) = "bump" {}
		[NoScaleOffset]_Shadermap("Shadermap", 2D) = "black" {}
		[Toggle(_USEINTERSECTIONFOAM_ON)] _UseIntersectionFoam("UseIntersectionFoam", Float) = 0
		[Toggle(_LIGHTING_ON)] _LIGHTING("LIGHTING", Float) = 0
		[Toggle]_ENABLE_VC("ENABLE_VC", Float) = 0
		[Toggle]_Unlit("Unlit", Float) = 0
		_Metallicness("Metallicness", Range( 0 , 1)) = 0
		[Toggle(_NORMAL_MAP_ON)] _NORMAL_MAP("NORMAL_MAP", Float) = 0
		[Toggle]_USE_VC_INTERSECTION("USE_VC_INTERSECTION", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		LOD 200
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma multi_compile __ _LIGHTING_ON
		#pragma multi_compile __ _NORMAL_MAP_ON
		#pragma shader_feature _USEINTERSECTIONFOAM_ON
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow nolightmap  nodynlightmap nodirlightmap nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float4 vertexColor : COLOR;
			float2 vertexToFrag713;
			float2 vertexToFrag714;
			float3 worldRefl;
			INTERNAL_DATA
			float3 vertexToFrag746;
			float3 worldNormal;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Shadermap;
		uniform sampler2D _Normals;
		uniform half _WaveHeight;
		uniform float _ENABLE_VC;
		uniform float _Worldspacetiling;
		uniform float _WaveSize;
		uniform float _Wavesspeed;
		uniform float4 _WaveDirection;
		uniform sampler2D_float _CameraDepthTexture;
		uniform half _EdgeFade;
		uniform half _Transparency;
		uniform float _Depth;
		uniform half4 _WaterShallowColor;
		uniform float4 _RimColor;
		uniform float _USE_VC_INTERSECTION;
		uniform half _Rimfalloff;
		uniform float _Rimtiling;
		uniform half _RimSize;
		uniform float _NormalTiling;
		uniform half _NormalStrength;
		uniform half _Glossiness;
		uniform float _Unlit;
		uniform half4 _WaterColor;
		uniform half _Wavetint;
		uniform half _FoamOpacity;
		uniform float _FoamTiling;
		uniform float _FoamSpeed;
		uniform half _FoamSize;
		uniform float _WaveFoam;
		uniform float _Metallicness;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 VertexColors729 = lerp(float4( 0,0,0,0 ),v.color,_ENABLE_VC);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 Tiling21 = lerp(( -20.0 * v.texcoord.xy ),( (ase_worldPos).xz * float2( 0.1,0.1 ) ),_Worldspacetiling);
			float2 appendResult500 = (float2(_WaveDirection.x , _WaveDirection.z));
			float2 WaveSpeed40 = ( ( _Wavesspeed * _Time.x ) * appendResult500 );
			float2 HeightmapUV581 = ( ( ( Tiling21 * _WaveSize ) * float2( 0.1,0.1 ) ) + ( WaveSpeed40 * float2( 0.5,0.5 ) ) );
			float4 tex2DNode94 = tex2Dlod( _Shadermap, float4( HeightmapUV581, 0, 1.0) );
			float temp_output_95_0 = ( saturate( ( _WaveHeight - (VertexColors729).b ) ) * tex2DNode94.g );
			float3 Displacement100 = ( ase_vertexNormal * temp_output_95_0 );
			v.vertex.xyz += Displacement100;
			o.vertexToFrag713 = lerp(( -20.0 * v.texcoord.xy ),( (ase_worldPos).xz * float2( 0.1,0.1 ) ),_Worldspacetiling);
			o.vertexToFrag714 = ( ( _Wavesspeed * _Time.x ) * appendResult500 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			o.vertexToFrag746 = ase_lightColor.rgb;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			//Start - Stylized Water custom depth
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth795 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth795 =  ( screenDepth795 - LinearEyeDepth( ase_screenPosNorm.z ) ) / (  lerp( 1.0 , ( 1.0 / _ProjectionParams.z ) , unity_OrthoParams.w) );
			#if SHADER_API_MOBILE && UNITY_VERSION >= 20183 //Build only, abs() function causes offset in depth on mobile in 2018.3
			#else
			distanceDepth795 = abs(distanceDepth795);
			#endif
			//End - Stylized Water custom depth
			float DepthTexture494 = distanceDepth795;
			float Depth479 = saturate( ( DepthTexture494 / _Depth ) );
			float4 VertexColors729 = lerp(float4( 0,0,0,0 ),i.vertexColor,_ENABLE_VC);
			float2 Tiling21 = i.vertexToFrag713;
			float2 temp_output_24_0 = ( Tiling21 * _Rimtiling );
			float2 WaveSpeed40 = i.vertexToFrag714;
			float temp_output_30_0 = ( tex2D( _Shadermap, ( ( 0.5 * temp_output_24_0 ) + WaveSpeed40 ) ).b * tex2D( _Shadermap, ( temp_output_24_0 + ( 1.0 - WaveSpeed40 ) ) ).b );
			float Intersection42 = saturate( ( _RimColor.a * ( 1.0 - ( ( ( lerp(DepthTexture494,( 1.0 - (VertexColors729).r ),_USE_VC_INTERSECTION) / _Rimfalloff ) * temp_output_30_0 ) + ( lerp(DepthTexture494,( 1.0 - (VertexColors729).r ),_USE_VC_INTERSECTION) / _RimSize ) ) ) ) );
			float Opacity121 = saturate( ( ( saturate( ( DepthTexture494 / _EdgeFade ) ) * saturate( ( ( _Transparency * saturate( ( Depth479 + _WaterShallowColor.a ) ) ) + Intersection42 ) ) ) - (VertexColors729).g ) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half3 _BlankNormal = half3(0,0,1);
			float2 temp_output_705_0 = ( _NormalTiling * Tiling21 );
			#ifdef _NORMAL_MAP_ON
				float2 staticSwitch760 = ( ( float2( 0.25,0.25 ) * temp_output_705_0 ) + WaveSpeed40 );
			#else
				float2 staticSwitch760 = float2( 0,0 );
			#endif
			#ifdef _NORMAL_MAP_ON
				float2 staticSwitch761 = ( temp_output_705_0 + ( 1.0 - WaveSpeed40 ) );
			#else
				float2 staticSwitch761 = float2( 0,0 );
			#endif
			#ifdef _NORMAL_MAP_ON
				float3 staticSwitch763 = ( ( UnpackNormal( tex2D( _Normals, staticSwitch760 ) ) + UnpackNormal( tex2D( _Normals, staticSwitch761 ) ) ) / float3( 2,2,2 ) );
			#else
				float3 staticSwitch763 = _BlankNormal;
			#endif
			float3 lerpResult621 = lerp( _BlankNormal , staticSwitch763 , _NormalStrength);
			float3 NormalMap52 = lerpResult621;
			float dotResult741 = dot( ase_worldlightDir , normalize( WorldReflectionVector( i , NormalMap52 ) ) );
			float GlossParam754 = _Glossiness;
			float3 lerpResult478 = lerp( (_WaterShallowColor).rgb , (_WaterColor).rgb , Depth479);
			float3 WaterColor350 = lerpResult478;
			float2 HeightmapUV581 = ( ( ( Tiling21 * _WaveSize ) * float2( 0.1,0.1 ) ) + ( WaveSpeed40 * float2( 0.5,0.5 ) ) );
			float4 tex2DNode94 = tex2D( _Shadermap, HeightmapUV581 );
			float Heightmap99 = tex2DNode94.g;
			float3 temp_cast_0 = (( Heightmap99 * _Wavetint )).xxx;
			float3 RimColor102 = (_RimColor).rgb;
			float3 lerpResult61 = lerp( ( WaterColor350 - temp_cast_0 ) , ( RimColor102 * 3.0 ) , Intersection42);
			float2 temp_output_634_0 = ( WaveSpeed40 * _FoamSpeed );
			float4 tex2DNode67 = tex2D( _Shadermap, ( ( _FoamTiling * Tiling21 ) + temp_output_634_0 + ( Heightmap99 * 0.1 ) ) );
			#ifdef _USEINTERSECTIONFOAM_ON
				float staticSwitch725 = ( 1.0 - tex2DNode67.b );
			#else
				float staticSwitch725 = saturate( ( 1000.0 * ( ( tex2D( _Shadermap, ( ( _FoamTiling * ( Tiling21 * float2( 0.5,0.5 ) ) ) + temp_output_634_0 ) ).r - tex2DNode67.r ) - _FoamSize ) ) );
			#endif
			float Foam73 = ( _FoamOpacity * staticSwitch725 );
			float3 temp_cast_1 = (2.0).xxx;
			float FoamTex244 = staticSwitch725;
			float WaveFoam221 = saturate( ( pow( ( tex2DNode94.g * _WaveFoam ) , 2.0 ) * FoamTex244 ) );
			float3 lerpResult223 = lerp( ( lerpResult61 + Foam73 ) , temp_cast_1 , WaveFoam221);
			float3 FinalColor114 = lerpResult223;
			#ifdef _LIGHTING_ON
				float3 staticSwitch769 = float3( 0,0,0 );
			#else
				float3 staticSwitch769 = ( saturate( ( pow( max( 0.0 , dotResult741 ) , ( GlossParam754 * 128.0 ) ) * GlossParam754 ) ) + lerp(( i.vertexToFrag746 * FinalColor114 ),FinalColor114,_Unlit) );
			#endif
			float3 CustomLighting753 = staticSwitch769;
			SurfaceOutputStandard s733 = (SurfaceOutputStandard ) 0;
			s733.Albedo = FinalColor114;
			s733.Normal = WorldNormalVector( i , NormalMap52 );
			s733.Emission = float3( 0,0,0 );
			s733.Metallic = _Metallicness;
			s733.Smoothness = GlossParam754;
			s733.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi733 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g733 = UnityGlossyEnvironmentSetup( s733.Smoothness, data.worldViewDir, s733.Normal, float3(0,0,0));
			gi733 = UnityGlobalIllumination( data, s733.Occlusion, s733.Normal, g733 );
			#endif

			float3 surfResult733 = LightingStandard ( s733, viewDir, gi733 ).rgb;
			surfResult733 += s733.Emission;

			#ifdef UNITY_PASS_FORWARDADD//733
			surfResult733 -= s733.Emission;
			#endif//733
			#ifdef _LIGHTING_ON
				float3 staticSwitch734 = surfResult733;
			#else
				float3 staticSwitch734 = CustomLighting753;
			#endif
			c.rgb = staticSwitch734;
			c.a = Opacity121;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=16500
1927;29;1905;1004;3789.391;-2526.962;2.65417;True;True
Node;AmplifyShaderEditor.CommentaryNode;347;-5301.821,-2139.555;Float;False;1499.929;585.7002;Comment;9;21;713;15;703;13;12;17;14;16;UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;16;-5223.622,-1759.556;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-5251.821,-1963.256;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;348;-5266.808,-1271.853;Float;False;1410.655;586.9989;Comment;8;40;337;39;500;38;35;320;714;Speed/direction;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-5214.021,-2089.556;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;-20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;17;-4998.623,-1765.556;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TimeNode;38;-5156.112,-1095.253;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-5216.808,-1221.853;Float;False;Property;_Wavesspeed;Waves speed;18;0;Create;True;0;0;False;0;0.75;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;320;-5140.667,-905.3926;Float;False;Property;_WaveDirection;WaveDirection;22;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-4959.623,-1992.955;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;703;-4807.515,-1705.867;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;500;-4905.578,-869.3902;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-4869.8,-1148.653;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;15;-4610.623,-1842.556;Float;False;Property;_Worldspacetiling;Worldspace tiling;7;0;Create;True;0;0;False;0;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;713;-4304.266,-1836.105;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-4663.672,-1020.493;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-4051.474,-1840.346;Float;False;Tiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;629;-4041.018,2886.475;Float;False;1369.069;675.6616;Comment;8;581;344;92;88;90;301;87;302;Heightmap UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexToFragmentNode;714;-4435.124,-1031.767;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-4175.821,-1024.427;Float;False;WaveSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;302;-3991.018,3053.557;Float;False;Property;_WaveSize;Wave Size;21;0;Create;True;0;0;False;0;0.1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-3884.539,2936.475;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-3633.135,3269.07;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-3619.018,2987.557;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-3377.135,3292.07;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-3379.885,3068.508;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-3149.219,3179.451;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;581;-2994.683,3182.493;Float;False;HeightmapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;407;-2542.945,2823.105;Float;False;1786.026;846.3284;Comment;20;218;100;98;95;97;221;96;230;231;229;232;219;220;99;94;652;785;786;787;788;Heightmap;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;723;1747.2,-1162.643;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;630;-4266.805,41.43127;Float;False;1022.648;667.8272;Comment;9;22;23;24;355;354;41;356;648;649;Intersection UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;94;-2468.452,3199.244;Float;True;Property;_TextureSample6;Texture Sample 6;24;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;638;-4682.635,1006.549;Float;False;1529.241;677.0369;Comment;12;637;636;64;634;65;604;632;63;633;628;676;677;SF UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-4189.418,265.4469;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-4163.003,367.1515;Float;False;Property;_Rimtiling;Rim tiling;12;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;628;-4633.827,1214.088;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-1934.15,3240.64;Float;False;Heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;770;2060.751,-1229.551;Float;False;Property;_ENABLE_VC;ENABLE_VC;28;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;504;-3030.266,-1050.05;Float;False;1001.34;484.8032;Comment;7;494;479;642;646;104;647;795;Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-3937.519,289.1349;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-3957.068,164.5515;Float;False;Constant;_Float13;Float 13;34;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-3984.751,510.3699;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4337.898,1065.557;Float;False;Property;_FoamTiling;FoamTiling;16;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;633;-4103.035,1443.05;Float;False;Property;_FoamSpeed;FoamSpeed;14;0;Create;True;0;0;False;0;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;604;-4228.341,1181.917;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;676;-4038.467,1535.054;Float;False;99;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;349;-3035.07,-106.9404;Float;False;2778.636;874.3949;Comment;24;42;10;102;426;425;420;497;496;3;5;495;444;222;233;30;29;28;686;709;712;732;731;767;773;Intersection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;729;2354.973,-1172.303;Float;False;VertexColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;-4045.489,1354.466;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;-3670.949,251.0045;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;677;-3741.903,1541.684;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;381;-3964.163,1959.834;Float;False;966.723;492.0804;Comment;8;47;659;342;46;341;339;705;18;Normals UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-3755.193,1130.693;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;634;-3756.968,1370.898;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-3751.245,1242.404;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SWS_ASEDepthNode;795;-2510.664,-720.717;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;649;-3675.09,515.2559;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;731;-2991.032,81.64807;Float;False;729;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-3919.359,2134.635;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;494;-2324.962,-728.4429;Float;False;DepthTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3930.826,2023.59;Float;False;Property;_NormalTiling;NormalTiling;8;0;Create;True;0;0;False;0;0.9;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;311;-3042.07,1036.015;Float;False;2790.748;696.8248;Comment;13;73;624;244;71;721;673;720;670;69;66;67;722;725;Surface highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;732;-2756.032,80.64807;Float;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;636;-3447.636,1134.132;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;356;-3443.304,466.8142;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;648;-3438.396,309.2903;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;637;-3439.664,1376.837;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;66;-2897.47,1109.127;Float;True;Property;_TextureSample4;Texture Sample 4;24;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;67;-2910.186,1325.706;Float;True;Property;_TextureSample5;Texture Sample 5;24;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;47;-3930.563,2316.432;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;705;-3544.359,2132.163;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-2923.574,303.1307;Float;True;Property;_TextureSample0;Texture Sample 0;24;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;712;-2596.796,86.3121;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-2921.188,498.8604;Float;True;Property;_TextureSample1;Texture Sample 1;24;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;495;-2833.993,-44.65842;Float;False;494;DepthTexture;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-3346.247,2027.306;Float;False;2;2;0;FLOAT2;0.25,0.25;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;670;-2475.899,1133.251;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2333.595,101.7485;Half;False;Property;_Rimfalloff;Rim falloff;11;0;Create;True;0;0;False;0;3;0;0.1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2480.348,451.9202;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;647;-2935.302,-939.4899;Float;False;494;DepthTexture;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2428.874,1251.174;Half;False;Property;_FoamSize;FoamSize;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;773;-2345.309,-37.46405;Float;False;Property;_USE_VC_INTERSECTION;USE_VC_INTERSECTION;31;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;659;-3495.744,2325.258;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-2985.575,-825.7819;Float;False;Property;_Depth;Depth;17;0;Create;True;0;0;False;0;30;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2338.022,229.7638;Half;False;Property;_RimSize;Rim Size;10;0;Create;True;0;0;False;0;5;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;646;-2667.876,-898.7989;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;341;-3170.445,2110.015;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;496;-1931.477,76.0475;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;720;-2171.777,1140.326;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;-3176.647,2251.115;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;709;-1801.515,319.9915;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;502;-2522.438,1980.171;Float;False;1882.752;558.178;Comment;9;52;621;128;622;661;660;50;45;763;Small Wave Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;503;-3059.798,-1737.311;Float;False;939.0676;526.2443;Comment;7;350;478;477;482;60;765;766;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;761;-2913.921,2233.657;Float;False;Property;_NORMAL_MAP;NORMAL_MAP;27;0;Create;True;0;0;False;0;1;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;760;-2883.452,2038.439;Float;False;Property;_NORMAL_MAP;NORMAL_MAP;27;0;Create;True;0;0;False;0;1;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;497;-1923.585,198.9694;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;721;-1963.777,1116.389;Float;False;2;2;0;FLOAT;1000;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-1688.83,85.64011;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;642;-2494.417,-898.4079;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;673;-2429.768,1384.268;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;60;-2998.926,-1491.732;Half;False;Property;_WaterColor;Water Color;0;1;[HDR];Create;True;0;0;False;0;0.1176471,0.6348885,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;477;-3009.798,-1687.31;Half;False;Property;_WaterShallowColor;WaterShallowColor;1;1;[HDR];Create;True;0;0;False;0;0.4191176,0.7596349,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-2469.642,2030.171;Float;True;Property;_TextureSample2;Texture Sample 2;23;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;43;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;425;-1474.603,154.4005;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;722;-1764.92,1139.873;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-2472.438,2257.07;Float;True;Property;_TextureSample3;Texture Sample 3;23;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;43;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;479;-2302.576,-901.9539;Float;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;766;-2751.609,-1528.693;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-2340.323,3450.925;Float;False;Property;_WaveFoam;Wave Foam;20;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-1177.727,-39.95768;Float;False;Property;_RimColor;Rim Color;3;1;[HDR];Create;True;0;0;False;0;1,1,1,0.5019608;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;660;-2075.106,2186.271;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;482;-2974.599,-1316.611;Float;False;479;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;765;-2776.609,-1673.693;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;725;-1505.115,1302.903;Float;False;Property;_UseIntersectionFoam;UseIntersectionFoam;25;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;426;-1174.303,160.3223;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;622;-1807.969,2028.126;Half;False;Constant;_BlankNormal;BlankNormal;36;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;478;-2544.895,-1559.009;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;661;-1896.977,2185.114;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;2,2,2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;352;-3067.381,4011.095;Float;False;2891.381;468.422;Comment;16;114;223;315;224;625;79;61;475;141;62;476;103;111;351;112;110;Master lerp;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;767;-844.6658,-30.29321;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-1983.623,3559.724;Half;False;Constant;_Float7;Float 7;25;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;444;-874.3505,111.0203;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-980.6179,1365.102;Float;False;FoamTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-1985.122,3368.425;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;763;-1554.723,2176.267;Float;False;Property;_NORMAL_MAP;NORMAL_MAP;30;0;Create;True;0;0;False;0;1;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1795.855,2332.987;Half;False;Property;_NormalStrength;NormalStrength;4;0;Create;True;0;0;False;0;0.25;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2992.428,4167.476;Float;False;99;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-1768.523,3546.525;Float;False;244;FoamTex;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-3017.381,4318.741;Half;False;Property;_Wavetint;Wave tint;2;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1334.413,1109.331;Half;False;Property;_FoamOpacity;FoamOpacity;13;0;Create;True;0;0;False;0;0.05;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;350;-2341.23,-1551.045;Float;False;WaterColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;686;-683.2039,105.8938;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;231;-1778.023,3372.025;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-516.3961,-52.14754;Float;False;RimColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-2627.316,4156.233;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;476;-2342.437,4297.366;Half;False;Constant;_Float2;Float 2;34;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;624;-958.9775,1155.225;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;621;-1211.594,2132.534;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-504.6126,92.63463;Float;False;Intersection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;-1449.523,3376.724;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-2343.248,4199.134;Float;False;102;RimColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;-2662.558,4061.095;Float;False;350;WaterColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;652;-1253.644,3383.992;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-907.3911,2119.4;Float;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-2130.268,4348.27;Float;False;42;Intersection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;141;-2386.586,4073.144;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-735.7233,1163.7;Float;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;-2095.437,4208.366;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;764;-3072.667,4644.836;Float;False;2470.806;768.7534;Comment;19;753;769;751;771;748;749;745;744;746;747;741;755;742;740;738;758;792;793;794;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;758;-3011.549,4852.261;Float;False;52;NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;380;-3073.8,-2416.792;Float;False;2409.427;576.6013;Comment;18;121;730;778;777;779;783;498;2;489;775;776;119;702;117;480;695;694;784;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-1029.021,3376.225;Float;False;WaveFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1771.724,4351.879;Float;False;73;Foam;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;1110.652,-149.9698;Half;False;Property;_Glossiness;Glossiness;6;0;Create;True;0;0;False;0;0.85;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;61;-1727.146,4076.186;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;480;-2868.522,-2008.105;Float;False;479;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-1341.485,4376.117;Float;False;221;WaveFoam;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;625;-1453.824,4079.357;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;754;1418.436,-148.6733;Float;False;GlossParam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;315;-1297.257,4235.156;Half;False;Constant;_Float9;Float 9;32;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;740;-2755.321,4828.072;Float;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;738;-3022.667,4694.836;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;694;-2680.013,-2002.087;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;223;-971.7388,4078.296;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;741;-2492.403,4744.969;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;755;-2559.593,5041.157;Float;False;754;GlossParam;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;742;-2993.092,5172.526;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;-2307.534,4978.774;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;128;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;695;-2526.013,-2013.087;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-771.7118,4072.191;Float;False;FinalColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;745;-2333.309,4722.092;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-2672.478,-2210.025;Half;False;Property;_Transparency;Transparency;5;0;Create;True;0;0;False;0;0.75;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2034.957,-2256.988;Half;False;Property;_EdgeFade;EdgeFade;9;0;Create;True;0;0;False;0;0.2448298;0;0.01;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;746;-2780.771,5184.248;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;785;-2528.156,3018.541;Float;False;729;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;748;-2103.552,4965.965;Float;False;2;0;FLOAT;0;False;1;FLOAT;512;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-2278.493,-1976.562;Float;False;42;Intersection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;747;-2774.481,5288.084;Float;False;114;FinalColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;702;-2315.732,-2122.005;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;489;-2004.549,-2343.989;Float;False;494;DepthTexture;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;794;-1922.133,5020.831;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;498;-1684.502,-2309.521;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;786;-2314.156,3022.541;Float;False;FLOAT;2;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;776;-2022.713,-2113.869;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;749;-2518.679,5208.56;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2463.252,2899.544;Half;False;Property;_WaveHeight;Wave Height;19;0;Create;True;0;0;False;0;0.5366272;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;792;-1700.592,5039.654;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;783;-1544.434,-2299.611;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;771;-2180.579,5222.121;Float;False;Property;_Unlit;Unlit;29;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;787;-2143.156,2971.541;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;730;-1620.244,-2021.371;Float;False;729;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;775;-1841.447,-2117.71;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;779;-1351.082,-2169.813;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;788;-1970.156,3006.541;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;778;-1386.173,-2028.066;Float;False;FLOAT;1;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;751;-1541.879,5088.087;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;769;-1310.933,5068.452;Float;False;Property;_LIGHTING;LIGHTING;26;0;Create;True;0;0;False;0;1;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;777;-1144.66,-2118.536;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;97;-1805.996,2891.624;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1808.653,3074.04;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;1430.341,-340.943;Float;False;52;NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;753;-1053.025,5078.608;Float;False;CustomLighting;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;784;-975.7791,-2116.862;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-1490.751,2940.04;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;756;1436.547,-425.2564;Float;False;114;FinalColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;774;1311.729,-241.8026;Float;False;Property;_Metallicness;Metallicness;30;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;733;1795.785,-370.4509;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-1057.476,2932.911;Float;False;Displacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;1801.9,-156.475;Float;False;753;CustomLighting;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-817.0809,-2129.525;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-1968.1,563.5;Float;False;IntersectionTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;639;2210.688,-19.91757;Float;False;121;Opacity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;734;2124.471,-267.5607;Float;False;Property;_LIGHTING;LIGHTING;28;0;Create;True;0;0;False;0;1;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;27;1820.076,-971.6935;Float;True;Property;_Shadermap;Shadermap;24;1;[NoScaleOffset];Create;True;0;0;True;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;101;2193.883,299.4911;Float;False;100;Displacement;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;43;2233.069,-970.2504;Float;True;Property;_Normals;Normals;23;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-1561.298,3137.152;Float;False;WaveHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;793;-2136.133,5105.831;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;233;-2231.797,587.783;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2580.9,-255;Float;False;True;2;Float;;200;0;CustomLighting;StylizedWater/Mobile;False;False;False;False;False;False;True;True;True;False;True;True;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;False;True;True;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;200;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;1;Pragma;fragmentoption ARB_precision_hint_fastest;False;;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;16;0
WireConnection;13;0;14;0
WireConnection;13;1;12;0
WireConnection;703;0;17;0
WireConnection;500;0;320;1
WireConnection;500;1;320;3
WireConnection;39;0;35;0
WireConnection;39;1;38;1
WireConnection;15;0;13;0
WireConnection;15;1;703;0
WireConnection;713;0;15;0
WireConnection;337;0;39;0
WireConnection;337;1;500;0
WireConnection;21;0;713;0
WireConnection;714;0;337;0
WireConnection;40;0;714;0
WireConnection;301;0;87;0
WireConnection;301;1;302;0
WireConnection;92;0;90;0
WireConnection;88;0;301;0
WireConnection;344;0;88;0
WireConnection;344;1;92;0
WireConnection;581;0;344;0
WireConnection;94;1;581;0
WireConnection;99;0;94;2
WireConnection;770;1;723;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;604;0;628;0
WireConnection;729;0;770;0
WireConnection;354;0;355;0
WireConnection;354;1;24;0
WireConnection;677;0;676;0
WireConnection;64;0;63;0
WireConnection;64;1;604;0
WireConnection;634;0;632;0
WireConnection;634;1;633;0
WireConnection;65;0;63;0
WireConnection;65;1;628;0
WireConnection;649;0;41;0
WireConnection;494;0;795;0
WireConnection;732;0;731;0
WireConnection;636;0;64;0
WireConnection;636;1;634;0
WireConnection;356;0;24;0
WireConnection;356;1;649;0
WireConnection;648;0;354;0
WireConnection;648;1;41;0
WireConnection;637;0;65;0
WireConnection;637;1;634;0
WireConnection;637;2;677;0
WireConnection;66;1;636;0
WireConnection;67;1;637;0
WireConnection;705;0;18;0
WireConnection;705;1;46;0
WireConnection;28;1;648;0
WireConnection;712;0;732;0
WireConnection;29;1;356;0
WireConnection;342;1;705;0
WireConnection;670;0;66;1
WireConnection;670;1;67;1
WireConnection;30;0;28;3
WireConnection;30;1;29;3
WireConnection;773;0;495;0
WireConnection;773;1;712;0
WireConnection;659;0;47;0
WireConnection;646;0;647;0
WireConnection;646;1;104;0
WireConnection;341;0;342;0
WireConnection;341;1;47;0
WireConnection;496;0;773;0
WireConnection;496;1;5;0
WireConnection;720;0;670;0
WireConnection;720;1;69;0
WireConnection;339;0;705;0
WireConnection;339;1;659;0
WireConnection;709;0;30;0
WireConnection;761;0;339;0
WireConnection;760;0;341;0
WireConnection;497;0;773;0
WireConnection;497;1;3;0
WireConnection;721;1;720;0
WireConnection;420;0;496;0
WireConnection;420;1;709;0
WireConnection;642;0;646;0
WireConnection;673;0;67;3
WireConnection;45;1;760;0
WireConnection;425;0;420;0
WireConnection;425;1;497;0
WireConnection;722;0;721;0
WireConnection;50;1;761;0
WireConnection;479;0;642;0
WireConnection;766;0;60;0
WireConnection;660;0;45;0
WireConnection;660;1;50;0
WireConnection;765;0;477;0
WireConnection;725;1;722;0
WireConnection;725;0;673;0
WireConnection;426;0;425;0
WireConnection;478;0;765;0
WireConnection;478;1;766;0
WireConnection;478;2;482;0
WireConnection;661;0;660;0
WireConnection;767;0;10;0
WireConnection;444;0;10;4
WireConnection;444;1;426;0
WireConnection;244;0;725;0
WireConnection;219;0;94;2
WireConnection;219;1;220;0
WireConnection;763;1;622;0
WireConnection;763;0;661;0
WireConnection;350;0;478;0
WireConnection;686;0;444;0
WireConnection;231;0;219;0
WireConnection;231;1;232;0
WireConnection;102;0;767;0
WireConnection;111;0;110;0
WireConnection;111;1;112;0
WireConnection;624;0;71;0
WireConnection;624;1;725;0
WireConnection;621;0;622;0
WireConnection;621;1;763;0
WireConnection;621;2;128;0
WireConnection;42;0;686;0
WireConnection;230;0;231;0
WireConnection;230;1;229;0
WireConnection;652;0;230;0
WireConnection;52;0;621;0
WireConnection;141;0;351;0
WireConnection;141;1;111;0
WireConnection;73;0;624;0
WireConnection;475;0;103;0
WireConnection;475;1;476;0
WireConnection;221;0;652;0
WireConnection;61;0;141;0
WireConnection;61;1;475;0
WireConnection;61;2;62;0
WireConnection;625;0;61;0
WireConnection;625;1;79;0
WireConnection;754;0;56;0
WireConnection;740;0;758;0
WireConnection;694;0;480;0
WireConnection;694;1;477;4
WireConnection;223;0;625;0
WireConnection;223;1;315;0
WireConnection;223;2;224;0
WireConnection;741;0;738;0
WireConnection;741;1;740;0
WireConnection;744;0;755;0
WireConnection;695;0;694;0
WireConnection;114;0;223;0
WireConnection;745;1;741;0
WireConnection;746;0;742;1
WireConnection;748;0;745;0
WireConnection;748;1;744;0
WireConnection;702;0;117;0
WireConnection;702;1;695;0
WireConnection;794;0;748;0
WireConnection;794;1;755;0
WireConnection;498;0;489;0
WireConnection;498;1;2;0
WireConnection;786;0;785;0
WireConnection;776;0;702;0
WireConnection;776;1;119;0
WireConnection;749;0;746;0
WireConnection;749;1;747;0
WireConnection;792;0;794;0
WireConnection;783;0;498;0
WireConnection;771;0;749;0
WireConnection;771;1;747;0
WireConnection;787;0;96;0
WireConnection;787;1;786;0
WireConnection;775;0;776;0
WireConnection;779;0;783;0
WireConnection;779;1;775;0
WireConnection;788;0;787;0
WireConnection;778;0;730;0
WireConnection;751;0;792;0
WireConnection;751;1;771;0
WireConnection;769;1;751;0
WireConnection;777;0;779;0
WireConnection;777;1;778;0
WireConnection;95;0;788;0
WireConnection;95;1;94;2
WireConnection;753;0;769;0
WireConnection;784;0;777;0
WireConnection;98;0;97;0
WireConnection;98;1;95;0
WireConnection;733;0;756;0
WireConnection;733;1;53;0
WireConnection;733;3;774;0
WireConnection;733;4;754;0
WireConnection;100;0;98;0
WireConnection;121;0;784;0
WireConnection;222;0;233;0
WireConnection;734;1;115;0
WireConnection;734;0;733;0
WireConnection;218;0;95;0
WireConnection;793;0;755;0
WireConnection;233;0;30;0
WireConnection;0;9;639;0
WireConnection;0;13;734;0
WireConnection;0;11;101;0
ASEEND*/
//CHKSM=DB7C072A1E59D5B2B75B5082B50CD047D4D5EE34