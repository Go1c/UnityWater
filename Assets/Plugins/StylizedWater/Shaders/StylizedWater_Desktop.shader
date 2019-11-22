// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StylizedWater/Desktop"
{
	Properties
	{
		[HDR]_WaterColor("Water Color", Color) = (0.1176471,0.6348885,1,0)
		[HDR]_WaterShallowColor("WaterShallowColor", Color) = (0.4191176,0.7596349,1,0)
		_Wavetint("Wave tint", Range( -1 , 1)) = 0.1
		[HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,0.484)
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0.5019608)
		_NormalStrength("NormalStrength", Range( 0 , 1)) = 0.25
		_Transparency("Transparency", Range( 0 , 1)) = 0.75
		_Glossiness("Glossiness", Range( 0 , 1)) = 0.85
		_Fresnelexponent("Fresnel exponent", Float) = 4
		_ReflectionStrength("Reflection Strength", Range( 0 , 1)) = 0
		_ReflectionFresnel("Reflection Fresnel", Range( 2 , 10)) = 5
		_RefractionAmount("Refraction Amount", Range( 0 , 0.2)) = 0.05
		_ReflectionRefraction("ReflectionRefraction", Range( 0 , 0.2)) = 0.05
		[Toggle]_Worldspacetiling("Worldspace tiling", Float) = 1
		_NormalTiling("NormalTiling", Range( 0 , 1)) = 0.9
		_EdgeFade("EdgeFade", Range( 0.01 , 3)) = 0.2448298
		_RimSize("Rim Size", Range( 0 , 20)) = 6
		_Rimfalloff("Rim falloff", Range( 0.1 , 50)) = 10
		_Rimtiling("Rim tiling", Float) = 0.5
		_FoamOpacity("FoamOpacity", Range( -1 , 1)) = 0.05
		_FoamDistortion("FoamDistortion", Range( 0 , 3)) = 0.45
		[IntRange]_UseIntersectionFoam("UseIntersectionFoam", Range( 0 , 1)) = 0
		_FoamSpeed("FoamSpeed", Range( 0 , 1)) = 0.1
		_FoamSize("FoamSize", Float) = 0
		_FoamTiling("FoamTiling", Float) = 0.05
		_Depth("Depth", Range( 0 , 100)) = 15
		_Wavesspeed("Waves speed", Range( 0 , 10)) = 0.75
		_WaveHeight("Wave Height", Range( 0 , 1)) = 0.05
		_WaveFoam("Wave Foam", Range( 0 , 10)) = 0
		_WaveSize("Wave Size", Range( 0 , 10)) = 0.1
		_WaveDirection("WaveDirection", Vector) = (1,0,0,0)
		[NoScaleOffset][Normal]_Normals("Normals", 2D) = "bump" {}
		[NoScaleOffset]_Shadermap("Shadermap", 2D) = "black" {}
		_RimDistortion("RimDistortion", Range( 0 , 0.2)) = 0.1
		[NoScaleOffset]_GradientTex("GradientTex", 2D) = "gray" {}
		_MacroBlendDistance("MacroBlendDistance", Range( 250 , 3000)) = 2000
		[Toggle(_SECONDARY_WAVES_ON)] _SECONDARY_WAVES("SECONDARY_WAVES", Float) = 0
		[Toggle(_MACRO_WAVES_ON)] _MACRO_WAVES("MACRO_WAVES", Float) = 0
		_ENABLE_GRADIENT("_ENABLE_GRADIENT", Range( 0 , 1)) = 0
		[Toggle]_ENABLE_SHADOWS("ENABLE_SHADOWS", Float) = 0
		[Toggle]_ENABLE_VC("ENABLE_VC", Float) = 0
		[Toggle]_Unlit("Unlit", Float) = 0
		[Toggle(_LIGHTING_ON)] _LIGHTING("LIGHTING", Float) = 1
		[Toggle]_USE_VC_INTERSECTION("USE_VC_INTERSECTION", Float) = 0
		_Metallicness("Metallicness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		LOD 200
		Cull Back
		GrabPass{ "_BeforeWater" }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 4.6
		#pragma shader_feature _SECONDARY_WAVES_ON
		#pragma shader_feature _LIGHTING_ON
		#pragma shader_feature _MACRO_WAVES_ON
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float4 vertexColor : COLOR;
			float3 worldRefl;
			INTERNAL_DATA
			float2 uv_texcoord;
			float2 vertexToFrag897;
			float2 vertexToFrag898;
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
		uniform float _WaveHeight;
		uniform float _ENABLE_VC;
		uniform float _Worldspacetiling;
		uniform float _WaveSize;
		uniform float _Wavesspeed;
		uniform float4 _WaveDirection;
		uniform sampler2D_float _CameraDepthTexture;
		uniform float _EdgeFade;
		uniform sampler2D _ShadowMask;
		uniform float _NormalTiling;
		uniform float _MacroBlendDistance;
		uniform float4 _RimColor;
		uniform float _USE_VC_INTERSECTION;
		uniform float _Rimfalloff;
		uniform float _Rimtiling;
		uniform float _RimDistortion;
		uniform float _RimSize;
		uniform float _NormalStrength;
		uniform float _Glossiness;
		uniform float _Unlit;
		uniform sampler2D _BeforeWater;
		uniform float _RefractionAmount;
		uniform float4 _WaterShallowColor;
		uniform float4 _WaterColor;
		uniform float _Depth;
		uniform sampler2D _GradientTex;
		uniform float _ENABLE_GRADIENT;
		uniform float _Transparency;
		uniform sampler2D _ReflectionTex;
		uniform float _ReflectionRefraction;
		uniform float _ReflectionStrength;
		uniform float _ReflectionFresnel;
		uniform float _Wavetint;
		uniform float _FoamOpacity;
		uniform float _FoamSize;
		uniform float _FoamDistortion;
		uniform float _FoamTiling;
		uniform float _FoamSpeed;
		uniform float _UseIntersectionFoam;
		uniform float4 _FresnelColor;
		uniform float _Fresnelexponent;
		uniform float _WaveFoam;
		uniform float _ENABLE_SHADOWS;
		uniform float _Metallicness;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float2 SPSRUVAdjust922( float4 input )
		{
			#if UNITY_SINGLE_PASS_STEREO
						float4 scaleOffset = unity_StereoScaleOffset[unity_StereoEyeIndex];
			    float2 uv = ((input.xy / input.w) - scaleOffset.zw) / scaleOffset.xy;
						#else
						float2 uv = input.xy;
						#endif
						return uv;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 VertexColors810 = lerp(float4( 0,0,0,0 ),v.color,_ENABLE_VC);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 Tiling21 = lerp(( -20.0 * v.texcoord.xy ),( (ase_worldPos).xz * float2( 0.1,0.1 ) ),_Worldspacetiling);
			float2 temp_output_88_0 = ( ( Tiling21 * _WaveSize ) * 0.1 );
			float2 appendResult500 = (float2(_WaveDirection.x , _WaveDirection.z));
			float2 WaveSpeed40 = ( ( ( _Wavesspeed * 0.1 ) * _Time.y ) * appendResult500 );
			float2 temp_output_92_0 = ( WaveSpeed40 * 0.5 );
			float2 HeightmapUV581 = ( temp_output_88_0 + temp_output_92_0 );
			float4 tex2DNode94 = tex2Dlod( _Shadermap, float4( HeightmapUV581, 0, 1.0) );
			#ifdef _SECONDARY_WAVES_ON
				float staticSwitch721 = ( tex2DNode94.g + tex2Dlod( _Shadermap, float4( ( ( temp_output_88_0 * float2( 2,2 ) ) + ( temp_output_92_0 * float2( -0.5,-0.5 ) ) ), 0, 1.0) ).g );
			#else
				float staticSwitch721 = tex2DNode94.g;
			#endif
			float temp_output_95_0 = ( saturate( ( _WaveHeight - (VertexColors810).b ) ) * staticSwitch721 );
			float3 Displacement100 = ( ase_vertexNormal * temp_output_95_0 );
			v.vertex.xyz += Displacement100;
			o.vertexToFrag897 = ( (ase_worldPos).xz * float2( 0.1,0.1 ) );
			o.vertexToFrag898 = ( ( ( _Wavesspeed * 0.1 ) * _Time.y ) * appendResult500 );
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
			float screenDepth966 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth966 =  ( screenDepth966 - LinearEyeDepth( ase_screenPosNorm.z ) ) / (  lerp( 1.0 , ( 1.0 / _ProjectionParams.z ) , unity_OrthoParams.w) );
			#if SHADER_API_MOBILE && UNITY_VERSION >= 20183 //Build only, abs() function causes offset in depth on mobile in 2018.3
			#else
			distanceDepth966 = abs(distanceDepth966);
			#endif
			//End - Stylized Water custom depth
			float DepthTexture494 = distanceDepth966;
			float4 VertexColors810 = lerp(float4( 0,0,0,0 ),i.vertexColor,_ENABLE_VC);
			float temp_output_809_0 = (VertexColors810).g;
			float OpacityFinal814 = saturate( ( saturate( ( DepthTexture494 / _EdgeFade ) ) - temp_output_809_0 ) );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 input922 = ase_grabScreenPosNorm;
			float2 localSPSRUVAdjust922 = SPSRUVAdjust922( input922 );
			float4 tex2DNode833 = tex2D( _ShadowMask, localSPSRUVAdjust922 );
			float ShadowMask944 = tex2DNode833.r;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 Tiling21 = lerp(( -20.0 * i.uv_texcoord ),i.vertexToFrag897,_Worldspacetiling);
			float2 temp_output_732_0 = ( _NormalTiling * Tiling21 );
			float2 WaveSpeed40 = i.vertexToFrag898;
			float3 temp_output_51_0 = BlendNormals( UnpackNormal( tex2D( _Normals, ( temp_output_732_0 + -WaveSpeed40 ) ) ) , UnpackNormal( tex2D( _Normals, ( ( temp_output_732_0 * 0.5 ) + WaveSpeed40 ) ) ) );
			#ifdef _MACRO_WAVES_ON
				float2 staticSwitch946 = ( WaveSpeed40 + ( temp_output_732_0 * 0.1 ) );
			#else
				float2 staticSwitch946 = float2( 0,0 );
			#endif
			#ifdef _MACRO_WAVES_ON
				float3 staticSwitch947 = UnpackNormal( tex2D( _Normals, staticSwitch946 ) );
			#else
				float3 staticSwitch947 = float3( 0,0,0 );
			#endif
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			#ifdef _MACRO_WAVES_ON
				float staticSwitch948 = saturate( ( distance( ase_vertex3Pos , _WorldSpaceCameraPos ) / _MacroBlendDistance ) );
			#else
				float staticSwitch948 = 0.0;
			#endif
			float3 lerpResult674 = lerp( temp_output_51_0 , staticSwitch947 , staticSwitch948);
			#ifdef _MACRO_WAVES_ON
				float3 staticSwitch680 = lerpResult674;
			#else
				float3 staticSwitch680 = temp_output_51_0;
			#endif
			float IntersectionSource776 = lerp(DepthTexture494,( 1.0 - (VertexColors810).r ),_USE_VC_INTERSECTION);
			float2 temp_output_24_0 = ( Tiling21 * _Rimtiling );
			float2 temp_output_88_0 = ( ( Tiling21 * _WaveSize ) * 0.1 );
			float2 temp_output_92_0 = ( WaveSpeed40 * 0.5 );
			float2 HeightmapUV581 = ( temp_output_88_0 + temp_output_92_0 );
			float4 tex2DNode94 = tex2D( _Shadermap, HeightmapUV581 );
			#ifdef _SECONDARY_WAVES_ON
				float staticSwitch721 = ( tex2DNode94.g + tex2D( _Shadermap, ( ( temp_output_88_0 * float2( 2,2 ) ) + ( temp_output_92_0 * float2( -0.5,-0.5 ) ) ) ).g );
			#else
				float staticSwitch721 = tex2DNode94.g;
			#endif
			float Heightmap99 = staticSwitch721;
			float temp_output_30_0 = ( tex2D( _Shadermap, ( ( 0.5 * temp_output_24_0 ) + ( Heightmap99 * _RimDistortion ) ) ).b * tex2D( _Shadermap, ( temp_output_24_0 + WaveSpeed40 ) ).b );
			float Intersection42 = saturate( ( _RimColor.a * ( 1.0 - ( ( ( IntersectionSource776 / _Rimfalloff ) * temp_output_30_0 ) + ( IntersectionSource776 / _RimSize ) ) ) ) );
			float3 lerpResult621 = lerp( float3(0,0,1) , staticSwitch680 , saturate( ( Intersection42 + _NormalStrength ) ));
			float3 NormalMap52 = lerpResult621;
			float dotResult866 = dot( ase_worldlightDir , normalize( WorldReflectionVector( i , NormalMap52 ) ) );
			float GlossinessParam877 = _Glossiness;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 NormalsBlended362 = temp_output_51_0;
			float3 temp_output_359_0 = ( ( _RefractionAmount * NormalsBlended362 ) + float3( localSPSRUVAdjust922 ,  0.0 ) );
			float4 screenColor372 = tex2D( _BeforeWater, temp_output_359_0.xy );
			float4 RefractionResult126 = screenColor372;
			float Depth479 = saturate( ( DepthTexture494 / _Depth ) );
			float4 lerpResult478 = lerp( _WaterShallowColor , _WaterColor , Depth479);
			float2 appendResult661 = (float2(Depth479 , 1.0));
			float4 tex2DNode659 = tex2D( _GradientTex, appendResult661 );
			float4 lerpResult942 = lerp( lerpResult478 , tex2DNode659 , _ENABLE_GRADIENT);
			float lerpResult943 = lerp( _WaterShallowColor.a , tex2DNode659.a , _ENABLE_GRADIENT);
			float Opacity121 = saturate( ( ( _Transparency + Intersection42 ) - ( ( 1.0 - Depth479 ) * ( 1.0 - lerpResult943 ) ) ) );
			float4 lerpResult374 = lerp( RefractionResult126 , lerpResult942 , Opacity121);
			float4 Reflection265 = tex2D( _ReflectionTex, ( float3( localSPSRUVAdjust922 ,  0.0 ) + ( ( NormalsBlended362 + Heightmap99 ) * _ReflectionRefraction ) ).xy );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV508 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode508 = ( 0.0 + _ReflectionFresnel * pow( 1.0 - fresnelNdotV508, 5.0 ) );
			float4 lerpResult297 = lerp( lerpResult374 , Reflection265 , saturate( ( ( Opacity121 * _ReflectionStrength ) * fresnelNode508 ) ));
			float4 WaterColor350 = lerpResult297;
			float4 temp_cast_5 = (( Heightmap99 * _Wavetint )).xxxx;
			float4 RimColor102 = _RimColor;
			float4 lerpResult61 = lerp( ( WaterColor350 - temp_cast_5 ) , ( RimColor102 * 3.0 ) , Intersection42);
			float temp_output_609_0 = ( Heightmap99 * _FoamDistortion );
			float2 temp_output_634_0 = ( WaveSpeed40 * _FoamSpeed );
			float4 tex2DNode67 = tex2D( _Shadermap, ( ( _FoamTiling * ( -temp_output_609_0 + Tiling21 ) ) + temp_output_634_0 ) );
			float lerpResult601 = lerp( step( _FoamSize , ( tex2D( _Shadermap, ( ( ( temp_output_609_0 + ( Tiling21 * 0.5 ) ) * _FoamTiling ) + temp_output_634_0 ) ).r - tex2DNode67.r ) ) , ( 1.0 - tex2DNode67.b ) , _UseIntersectionFoam);
			float Foam73 = ( _FoamOpacity * lerpResult601 );
			float4 FresnelColor206 = _FresnelColor;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float fresnelNdotV199 = dot( ase_vertexNormal, ase_worldViewDir );
			float fresnelNode199 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV199, ( _Fresnelexponent * 100.0 ) ) );
			float clampResult505 = clamp( ( _FresnelColor.a * fresnelNode199 ) , 0.0 , 1.0 );
			float Fresnel205 = clampResult505;
			float4 lerpResult207 = lerp( ( lerpResult61 + Foam73 ) , FresnelColor206 , Fresnel205);
			float4 temp_cast_6 = (2.0).xxxx;
			float FoamTex244 = lerpResult601;
			float WaveFoam221 = saturate( ( ( pow( staticSwitch721 , 2.0 ) * _WaveFoam ) * FoamTex244 ) );
			float4 lerpResult223 = lerp( lerpResult207 , temp_cast_6 , WaveFoam221);
			float4 temp_cast_7 = (1.0).xxxx;
			float4 Shadows834 = lerp(temp_cast_7,saturate( ( unity_AmbientSky / ( 1.0 - tex2DNode833.r ) ) ),_ENABLE_SHADOWS);
			float4 FinalColor114 = ( lerpResult223 * Shadows834 );
			#ifdef _LIGHTING_ON
				float4 staticSwitch952 = float4( 0,0,0,0 );
			#else
				float4 staticSwitch952 = ( ( ShadowMask944 * ( pow( max( 0.0 , dotResult866 ) , ( GlossinessParam877 * 128.0 ) ) * GlossinessParam877 ) ) + lerp(( float4( ase_lightColor.rgb , 0.0 ) * FinalColor114 ),FinalColor114,_Unlit) );
			#endif
			float4 CustomLighting875 = staticSwitch952;
			SurfaceOutputStandard s856 = (SurfaceOutputStandard ) 0;
			s856.Albedo = FinalColor114.rgb;
			s856.Normal = WorldNormalVector( i , NormalMap52 );
			s856.Emission = float3( 0,0,0 );
			s856.Metallic = _Metallicness;
			s856.Smoothness = GlossinessParam877;
			s856.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi856 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g856 = UnityGlossyEnvironmentSetup( s856.Smoothness, data.worldViewDir, s856.Normal, float3(0,0,0));
			gi856 = UnityGlobalIllumination( data, s856.Occlusion, s856.Normal, g856 );
			#endif

			float3 surfResult856 = LightingStandard ( s856, viewDir, gi856 ).rgb;
			surfResult856 += s856.Emission;

			#ifdef UNITY_PASS_FORWARDADD//856
			surfResult856 -= s856.Emission;
			#endif//856
			#ifdef _LIGHTING_ON
				float4 staticSwitch857 = float4( surfResult856 , 0.0 );
			#else
				float4 staticSwitch857 = CustomLighting875;
			#endif
			c.rgb = staticSwitch857.rgb;
			c.a = OpacityFinal814;
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
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=16500
1927;29;1905;1004;-1363.155;671.5211;1.217396;True;True
Node;AmplifyShaderEditor.CommentaryNode;347;-5166.037,-2096.662;Float;False;1721.995;643.8664;Comment;9;21;15;897;733;17;16;13;12;14;UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;348;-4958.323,-1301.456;Float;False;1727.092;700.4691;Comment;10;40;898;337;39;500;36;38;320;37;35;Speed/direction;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;16;-5043.286,-1693.122;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;35;-4908.323,-1251.456;Float;False;Property;_Wavesspeed;Waves speed;26;0;Create;True;0;0;False;0;0.75;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-4815.42,-1135.754;Float;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;17;-4819.443,-1692.566;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;320;-4703.182,-801.9926;Float;False;Property;_WaveDirection;WaveDirection;30;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-5021.96,-2033.505;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;-20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-5078.348,-1934.906;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;38;-4729.622,-1014.753;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;733;-4618.942,-1687.755;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-4585.321,-1204.654;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-4773.858,-1987.168;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-4307.822,-1115.654;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;500;-4443.116,-826.1659;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;897;-4448.945,-1680.654;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;15;-4142.279,-1856.139;Float;False;Property;_Worldspacetiling;Worldspace tiling;13;0;Create;True;0;0;False;0;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-4101.386,-979.6928;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;898;-3859.578,-971.7191;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-3829.854,-1855.9;Float;False;Tiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;629;-4041.018,2886.475;Float;False;1369.069;675.6616;Comment;13;581;344;92;88;90;91;89;301;87;302;715;718;719;Heightmap UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;302;-3991.018,3053.557;Float;False;Property;_WaveSize;Wave Size;29;0;Create;True;0;0;False;0;0.1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-3615.499,-977.6727;Float;False;WaveSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-3884.539,2936.475;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-3619.018,2987.557;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-3644.793,3182.194;Float;False;Constant;_Float4;Float 4;16;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-3904.954,3313.793;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-3883.682,3427.666;Float;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-3402.034,3139.868;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-3660.082,3356.918;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;-3120.789,3268.327;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;719;-3123.191,3390.834;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-3130.565,3078.142;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;407;-2542.945,2823.105;Float;False;2354.97;922.4412;Comment;23;218;100;98;97;95;221;96;230;229;231;219;232;220;99;94;713;714;717;721;961;962;963;964;Heightmap;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;715;-2881.477,3371.601;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;581;-2944.359,3047.844;Float;False;HeightmapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;783;1667.248,-889.3034;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;956;1889.104,-913.8555;Float;False;Property;_ENABLE_VC;ENABLE_VC;46;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;714;-2305.788,3376.499;Float;True;Property;_TextureSample8;Texture Sample 8;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;94;-2422.784,3136.45;Float;True;Property;_TextureSample6;Texture Sample 6;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;817;-2552.624,4419.88;Float;False;1572.862;386.188;Comment;8;812;813;707;495;778;776;751;957;Intersection source;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;717;-1981.195,3326.772;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;810;2173.655,-894.1899;Float;False;VertexColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;382;-2973.885,-2047.095;Float;False;3000.035;1049.284;Comment;28;834;844;833;925;265;126;260;806;801;805;372;804;359;920;361;922;919;266;360;269;494;933;936;938;944;954;955;966;Reflection/Refraction/Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;721;-1719.215,3187.987;Float;False;Property;_SECONDARY_WAVES;SECONDARY_WAVES;38;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;812;-2502.624,4633.996;Float;False;810;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;630;-4266.805,41.43127;Float;False;1022.648;667.8272;Comment;12;22;23;24;618;620;355;354;619;41;356;353;470;Intersection UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SWS_ASEDepthNode;966;-1765.993,-1114.127;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-1212.979,3177.846;Float;False;Heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-4216.805,330.9447;Float;False;Property;_Rimtiling;Rim tiling;18;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-4207.007,203.3786;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;813;-2233.624,4610.996;Float;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;494;-1545.133,-1122.691;Float;False;DepthTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-3941.017,91.43127;Float;False;Constant;_Float13;Float 13;34;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;495;-2073.518,4469.88;Float;False;494;DepthTexture;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;618;-3977.549,352.8728;Float;False;99;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;620;-3989.774,451.9105;Float;False;Property;_RimDistortion;RimDistortion;34;0;Create;True;0;0;False;0;0.1;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-3943.725,233.2731;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;707;-1993.067,4605.6;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;-3679.224,184.7984;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;957;-1728.637,4506.636;Float;False;Property;_USE_VC_INTERSECTION;USE_VC_INTERSECTION;48;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-4079.057,594.128;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;619;-3626.712,328.1283;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;353;-3398.156,378.2869;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;776;-1259.763,4515.605;Float;False;IntersectionSource;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;356;-3456.752,561.9866;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;504;-2189.979,-4525.891;Float;False;1178.949;207.293;Comment;5;104;479;649;648;647;Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;349;-3035.07,-106.9404;Float;False;2778.636;874.3949;Comment;18;42;631;10;102;426;425;420;497;496;3;5;444;222;233;30;29;28;777;Intersection;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;29;-2921.188,498.8604;Float;True;Property;_TextureSample1;Texture Sample 1;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;777;-2310.294,16.25119;Float;False;776;IntersectionSource;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2292.946,183.4473;Float;False;Property;_Rimfalloff;Rim falloff;17;0;Create;True;0;0;False;0;10;0;0.1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;647;-2089.065,-4485.832;Float;False;494;DepthTexture;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-2923.574,303.1307;Float;True;Property;_TextureSample0;Texture Sample 0;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;104;-2144.979,-4406.599;Float;False;Property;_Depth;Depth;25;0;Create;True;0;0;False;0;15;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2295.592,294.0709;Float;False;Property;_RimSize;Rim Size;16;0;Create;True;0;0;False;0;6;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2480.348,451.9202;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;496;-1856.272,39.4246;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;648;-1689.066,-4454.832;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-1527.948,109.6954;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;649;-1473.327,-4452.367;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;497;-1857.762,221.6412;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;381;-4389.646,1945.714;Float;False;1221.636;748.4935;Comment;13;340;341;677;676;681;339;342;47;732;343;18;46;832;Normals UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;479;-1254.026,-4463.973;Float;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;425;-1318.259,161.3658;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;503;-3239.922,-3046.988;Float;False;3588.744;924.0803;Comment;22;350;627;297;298;478;374;509;456;271;377;60;508;106;482;659;661;477;367;660;941;942;943;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-4306.979,2150.852;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-4368.489,2026.414;Float;False;Property;_NormalTiling;NormalTiling;14;0;Create;True;0;0;False;0;0.9;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-1177.329,-24.75855;Float;False;Property;_RimColor;Rim Color;4;1;[HDR];Create;True;0;0;False;0;1,1,1,0.5019608;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;660;-3192.004,-2977.427;Float;False;479;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;426;-1111.437,166.1116;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-4330.297,2263.91;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;343;-4257.239,2383.196;Float;False;Constant;_SecondaryNormalsSize;SecondaryNormalsSize;34;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;732;-3922.19,2041.779;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;444;-876.683,167.2579;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;661;-2960.057,-2973.305;Float;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;340;-3663.783,2084.463;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-3580.232,2251.906;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;341;-3362.5,1990.097;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;-3307.027,2281.321;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;380;-2240.391,-3553.398;Float;False;1788.234;432.6779;Comment;10;117;119;134;149;658;121;487;151;488;480;Opacity GrabPass;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;941;-2700.838,-2789.149;Float;False;Property;_ENABLE_GRADIENT;_ENABLE_GRADIENT;43;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;477;-3101.106,-2794.325;Float;False;Property;_WaterShallowColor;WaterShallowColor;1;1;[HDR];Create;True;0;0;False;0;0.4191176,0.7596349,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;631;-703.0016,166.9194;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;502;-2863.676,1967.415;Float;False;3250.56;699.405;Comment;25;52;621;651;680;622;674;652;678;384;675;128;672;673;669;670;671;362;51;50;45;791;792;891;947;948;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;659;-2774.629,-3002.995;Float;True;Property;_GradientTex;GradientTex;35;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;gray;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-2810.88,2017.415;Float;True;Property;_TextureSample2;Texture Sample 2;31;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;43;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-522.1453,162.7649;Float;False;Intersection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;638;-4830.572,1006.549;Float;False;1534.521;694.0706;Comment;17;608;606;609;628;607;604;63;632;603;633;602;65;634;64;636;637;741;Foam UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;480;-2178.689,-3308.668;Float;False;479;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-2813.676,2244.313;Float;True;Property;_TextureSample3;Texture Sample 3;31;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;43;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;943;-2267.938,-2942.05;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;151;-1962.452,-3305.911;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-2113.75,-3510.547;Float;False;Property;_Transparency;Transparency;6;0;Create;True;0;0;False;0;0.75;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;-4700.512,1126.151;Float;False;99;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;608;-4780.572,1239.085;Float;False;Property;_FoamDistortion;FoamDistortion;20;0;Create;True;0;0;False;0;0.45;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;51;-2369.275,2129.514;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;488;-1955.619,-3200.629;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-2168.003,-3429.059;Float;False;42;Intersection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-2096.469,2013.334;Float;False;NormalsBlended;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-1624.047,-3481.813;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;609;-4444.399,1177.658;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;628;-4650.485,1442.544;Float;False;21;Tiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;487;-1719.653,-3303.475;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-4735.203,1329.265;Float;False;Constant;_FoamSecondarySize;FoamSecondarySize;45;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;604;-4387.599,1324.534;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;-2921.865,-1814;Float;False;362;NormalsBlended;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;607;-4194.862,1355.061;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;266;-2879.02,-1695.303;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;360;-2923.885,-1925.101;Float;False;Property;_RefractionAmount;Refraction Amount;11;0;Create;True;0;0;False;0;0.05;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;149;-1366.83,-3490.881;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;919;-2540.748,-1489.76;Float;False;99;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;361;-2576.684,-1908.101;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;804;-2409.437,-1360.131;Float;False;Property;_ReflectionRefraction;ReflectionRefraction;12;0;Create;True;0;0;False;0;0.05;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;-4051.7,1492.656;Float;False;40;WaveSpeed;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;920;-2266.888,-1507.773;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;658;-881.8892,-3501.806;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;633;-4125.348,1585.619;Float;False;Property;_FoamSpeed;FoamSpeed;22;0;Create;True;0;0;False;0;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;602;-3997.72,1187.874;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;922;-2470.993,-1699.768;Float;False;#if UNITY_SINGLE_PASS_STEREO$			float4 scaleOffset = unity_StereoScaleOffset[unity_StereoEyeIndex]@$$    float2 uv = ((input.xy / input.w) - scaleOffset.zw) / scaleOffset.xy@$			#else$			float2 uv = input.xy@$			#endif$			return uv@;2;False;1;True;input;FLOAT4;0,0,0,0;In;;Float;SPSR UV Adjust;True;False;0;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4125.244,1056.548;Float;False;Property;_FoamTiling;FoamTiling;24;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;603;-3996.973,1362.176;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;-2241.468,-1853.418;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;634;-3729.019,1507.536;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-3736.56,1180.38;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-3727.954,1332.462;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;805;-2053.756,-1508.431;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-683.9272,-3509.705;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;806;-1855.197,-1589.138;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-2214.694,-2376.333;Float;False;Property;_ReflectionFresnel;Reflection Fresnel;10;0;Create;True;0;0;False;0;5;0;2;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;681;-4323.667,2497.885;Float;False;Constant;_MacroWaveSize;MacroWaveSize;42;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;271;-2085.137,-2574.038;Float;False;Property;_ReflectionStrength;Reflection Strength;9;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;482;-3050.427,-2424.127;Float;False;479;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;60;-3099.254,-2605.115;Float;False;Property;_WaterColor;Water Color;0;1;[HDR];Create;True;0;0;False;0;0.1176471,0.6348885,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;636;-3452.454,1185.642;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;311;-3042.07,1036.015;Float;False;2233.037;669.3943;Comment;12;73;624;71;244;599;601;76;70;69;68;66;67;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;377;-1992.655,-2681.265;Float;False;121;Opacity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;637;-3450.053,1332.899;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;372;-1644.772,-2003.788;Float;False;Global;_BeforeWater;BeforeWater;34;0;Create;True;0;0;True;0;Object;-1;True;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;671;-2231.053,2500.014;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;67;-2821.693,1355.126;Float;True;Property;_TextureSample5;Texture Sample 5;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;260;-1670.981,-1589.917;Float;True;Global;_ReflectionTex;_ReflectionTex;33;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;676;-3598.523,2521.657;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;478;-2592.207,-2654.925;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;670;-2162.46,2348.121;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;66;-2841.266,1104.049;Float;True;Property;_TextureSample4;Texture Sample 4;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-995.6839,-2007.753;Float;False;RefractionResult;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;-1716.349,-2592.764;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;508;-1879.431,-2446.224;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2383.988,1116.832;Float;False;Property;_FoamSize;FoamSize;23;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;673;-1836.488,2508.738;Float;False;Property;_MacroBlendDistance;MacroBlendDistance;36;0;Create;True;0;0;False;0;2000;0;250;3000;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;-1682.404,-2904.49;Float;False;126;RefractionResult;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;677;-3376.585,2469;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;-963.0614,-1585.729;Float;False;Reflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;669;-1910.046,2375.321;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;378;-2979.134,-875.097;Float;False;1619.181;563.468;Comment;4;202;211;212;213;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-2383.77,1225.353;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;-1497.831,-2521.865;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;942;-2271.739,-2820.25;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;672;-1483.297,2379.5;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-2886.606,-426.6295;Float;False;Constant;_Float10;Float 10;26;0;Create;True;0;0;False;0;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;-1347.575,-2650.913;Float;False;265;Reflection;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;946;-3055.149,2470.876;Float;False;Property;_MACRO_WAVES;MACRO_WAVES;37;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;627;-1311.818,-2522.715;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;70;-2006.685,1197.789;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-2929.134,-523.7986;Float;False;Property;_Fresnelexponent;Fresnel exponent;8;0;Create;True;0;0;False;0;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-2383.339,1409.216;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;599;-2139.582,1534.473;Float;False;Property;_UseIntersectionFoam;UseIntersectionFoam;21;1;[IntRange];Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;374;-1335.035,-2832.994;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-1633.112,3423.268;Float;False;Constant;_Float7;Float 7;25;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;297;-1013.564,-2686.066;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-2657.407,-573.8296;Float;False;Constant;_Float8;Float 8;26;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;675;-2813.917,2453.232;Float;True;Property;_TextureSample7;Texture Sample 7;31;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Instance;43;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;200;-2688.977,-736.9108;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;601;-1784.093,1380.708;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-2647.807,-476.2287;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;352;-2531.756,5039.974;Float;False;3479.381;469.422;Comment;21;114;223;207;315;224;210;208;625;61;79;475;62;103;141;476;111;351;112;110;842;841;Master lerp;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;678;-1278.932,2380.731;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-1479.289,1467.761;Float;False;FoamTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;947;-1312.879,2137.847;Float;False;Property;_MACRO_WAVES;MACRO_WAVES;39;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-518.9355,-25.5923;Float;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;948;-1105.128,2337.141;Float;False;Property;_MACRO_WAVES;MACRO_WAVES;39;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-744.227,2399.359;Float;False;42;Intersection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;792;-2084.894,2102.18;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;202;-2418.637,-825.0979;Float;False;Property;_FresnelColor;Fresnel Color;3;1;[HDR];Create;True;0;0;False;0;1,1,1,0.484;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2456.803,5196.354;Float;False;99;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-1596.643,3539.543;Float;False;Property;_WaveFoam;Wave Foam;28;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1681.594,1188.393;Float;False;Property;_FoamOpacity;FoamOpacity;19;0;Create;True;0;0;False;0;0.05;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-819.0051,2501.15;Float;False;Property;_NormalStrength;NormalStrength;5;0;Create;True;0;0;False;0;0.25;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;833;-1687.357,-1340.624;Float;True;Global;_ShadowMask;_ShadowMask;41;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;112;-2481.756,5347.619;Float;False;Property;_Wavetint;Wave tint;2;0;Create;True;0;0;False;0;0.1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;350;-746.1934,-2687.191;Float;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;199;-2407.307,-602.4576;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;231;-1402.878,3359.59;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;936;-1310.405,-1304.77;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;925;-1387.237,-1391.446;Float;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;-2143.975,5086.383;Float;False;350;WaterColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;791;-2088.421,2211.539;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-1807.622,5228.012;Float;False;102;RimColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-1115.082,3359.178;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-2100.862,-643.3526;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;652;-449.4679,2421.979;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;674;-1034.972,2077.068;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;624;-1281.735,1281.288;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-2091.691,5185.111;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;476;-1806.812,5326.244;Float;False;Constant;_Float2;Float 2;34;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-1190.064,3502.76;Float;False;244;FoamTex;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;680;-626.8708,2158.984;Float;False;Property;_MACRO_WAVES;MACRO_WAVES;39;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;651;-280.3378,2421.475;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;938;-1030.405,-1297.77;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;-1559.811,5237.244;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;505;-1829.128,-639.2252;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;-886.2871,3371.016;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;622;-603.4515,2007.069;Float;False;Constant;_BlankNormal;BlankNormal;36;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1594.642,5377.148;Float;False;42;Intersection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-1108.678,1277.91;Float;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;141;-1850.961,5102.022;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;61;-1191.52,5105.064;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;933;-738.4048,-1293.77;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;844;-802.162,-1403.361;Float;False;Constant;_BlankShadows;BlankShadows;49;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;713;-697.5031,3375.669;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-1574.954,-663.1936;Float;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;621;-70.79081,2101.524;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;-2087.412,-792.5879;Float;False;FresnelColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1236.098,5380.757;Float;False;73;Foam;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;955;-523.599,-1336.099;Float;False;Property;_ENABLE_SHADOWS;ENABLE_SHADOWS;44;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-817.1887,5245.889;Float;False;206;FresnelColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-804.9016,5371.389;Float;False;205;Fresnel;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;861;-2503.368,5748.755;Float;False;3267.734;909.3911;Comment;18;875;874;873;879;880;872;870;867;869;868;865;866;863;864;862;952;958;965;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;625;-918.1976,5108.235;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;137.1828,2096.77;Float;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-473.3958,3362.905;Float;False;WaveFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;315;-409.6305,5263.034;Float;False;Constant;_Float9;Float 9;32;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;834;-252.7414,-1343.617;Float;False;Shadows;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;862;-2419.75,5971.482;Float;False;52;NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-448.8575,5365.995;Float;False;221;WaveFoam;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;207;-490.7755,5114.316;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;1092.356,-154.0119;Float;False;Property;_Glossiness;Glossiness;7;0;Create;True;0;0;False;0;0.85;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;842;-35.57666,5290.496;Float;False;834;Shadows;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;864;-2453.368,5798.755;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;223;-145.1122,5116.174;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;877;1369.905,-155.3848;Float;False;GlossinessParam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;863;-2159.821,5949.891;Float;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;841;222.4233,5122.496;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;866;-1573.428,5843.252;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;865;-1792.094,6083.037;Float;False;877;GlossinessParam;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;868;-1447.728,6031.199;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;128;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;869;-1382.67,5848.037;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;489.9147,5105.069;Float;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;867;-1953.793,6202.445;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;872;-1232.307,6066.441;Float;False;2;0;FLOAT;0;False;1;FLOAT;512;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;-1980.181,6331.003;Float;False;114;FinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;816;-2210.829,-4204.977;Float;False;1497.175;524.8193;Comment;11;811;809;2;767;489;786;498;770;814;953;968;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;961;-1990.364,3006.862;Float;False;810;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;944;-1286.223,-1201.092;Float;False;ShadowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;962;-1750.217,3005.857;Float;False;FLOAT;2;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2051.6,2897.07;Float;False;Property;_WaveHeight;Wave Height;27;0;Create;True;0;0;False;0;0.05;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;489;-1989.721,-4130.501;Float;False;494;DepthTexture;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;880;-1043.456,6045.647;Float;False;944;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;873;-1733.606,6249.321;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;965;-1056.511,6147.783;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2020.329,-4023.831;Float;False;Property;_EdgeFade;EdgeFade;15;0;Create;True;0;0;False;0;0.2448298;0;0.01;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;811;-2160.829,-3795.161;Float;False;810;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;498;-1683.42,-4134.152;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;879;-737.6326,6146.012;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;958;-1294.083,6253.264;Float;False;Property;_Unlit;Unlit;47;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;963;-1574.378,2927.484;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;964;-1367.39,2952.604;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;953;-1464.076,-4150.181;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;809;-1814.283,-3798.724;Float;False;FLOAT;1;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;874;-537.9039,6197.751;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1180.72,3037.886;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;770;-1253.21,-4109.162;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;97;-1092.285,2871.405;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;952;-326.0397,6182.559;Float;False;Property;_LIGHTING;LIGHTING;42;0;Create;True;0;0;False;0;0;1;0;True;;Toggle;2;Key0;Key1;Create;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-699.1765,2922.915;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;875;-30.66221,6174.183;Float;False;CustomLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;968;-1082.406,-4099.097;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;960;1406.906,-235.855;Float;False;Property;_Metallicness;Metallicness;49;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;1591.158,-314.7101;Float;False;52;NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;878;1592.167,-406.292;Float;False;114;FinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;752;-5574.891,-3090.527;Float;False;1948.029;578.093;Comment;12;763;762;760;761;757;758;759;755;756;754;746;899;World aligned UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-458.0862,2923.397;Float;False;Displacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;818;-2565.035,3966.893;Float;False;1114.328;314.4121;Comment;5;803;765;750;747;748;Mask rendering;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;1888.085,-186.3855;Float;False;875;CustomLighting;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;856;1892.538,-390.7581;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;814;-895.6533,-4107.977;Float;False;OpacityFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;765;-1899.167,4027.458;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;2134.368,-660.9867;Float;True;Property;_Normals;Normals;31;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;803;-2515.035,4073.706;Float;False;763;RT_UV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;751;-1719.943,4635.045;Float;False;748;RT_Intersection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;899;-4199.797,-2876.103;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;470;-3783.626,599.2585;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;758;-4885.567,-2871.485;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;780;2267.755,-129.7532;Float;False;810;VertexColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;27;1721.375,-662.4299;Float;True;Property;_Shadermap;Shadermap;32;1;[NoScaleOffset];Create;True;0;0;True;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;832;-3392.785,2112.124;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;815;2503.023,-10.4965;Float;False;814;OpacityFinal;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;967;2502.397,-143.2566;Float;False;FLOAT;1;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;801;-1669.79,-1831.149;Float;True;Property;_RefractionTex;RefractionTex;39;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;757;-4959.206,-2695.197;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;2508.581,100.8756;Float;False;100;Displacement;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;760;-4652.091,-3014.527;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;857;2256.308,-338.7852;Float;False;Property;_LIGHTING;LIGHTING;48;0;Create;True;0;0;False;0;0;1;0;True;;Toggle;2;Key0;Key1;Create;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-1745.364,628.5925;Float;False;IntersectionTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;233;-2187.434,629.9498;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;750;-1912.674,4160.687;Float;False;RT_Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;747;-2270.168,4056.465;Float;True;Global;_SWS_RENDERTEX;_SWS_RENDERTEX;40;0;Create;True;0;0;False;0;None;;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;759;-5011.091,-3040.527;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;891;-444.5986,2545.656;Float;False;NormalStrengthParam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;786;-1775.255,-3927.708;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;845;1670.167,-88.873;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;746;-5538.337,-2950.295;Float;False;Global;_SWS_RENDERTEX_POS;_SWS_RENDERTEX_POS;46;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;954;-1271.556,-1931.613;Float;False;Property;_RT_REFRACTION;RT_REFRACTION;45;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;755;-5121.796,-2811.783;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;762;-4410.328,-2884.337;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;754;-5194.019,-2688.495;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-714.403,3079.512;Float;False;WaveHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;778;-1434.931,4608.366;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;756;-5195.09,-3039.527;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;767;-2114.376,-3920.345;Float;False;750;RT_Opacity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;748;-1699.322,4018.804;Float;False;RT_Intersection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;763;-3880.106,-2885.667;Float;False;RT_UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;846;1387.167,-67.87299;Float;False;944;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;761;-4655.504,-2875.597;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2800.578,-243.458;Float;False;True;6;Float;;200;0;CustomLighting;StylizedWater/Desktop;False;False;False;False;False;False;False;False;True;False;False;False;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;True;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;1;False;-1;4;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;200;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;16;0
WireConnection;733;0;17;0
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;13;0;14;0
WireConnection;13;1;12;0
WireConnection;39;0;36;0
WireConnection;39;1;38;2
WireConnection;500;0;320;1
WireConnection;500;1;320;3
WireConnection;897;0;733;0
WireConnection;15;0;13;0
WireConnection;15;1;897;0
WireConnection;337;0;39;0
WireConnection;337;1;500;0
WireConnection;898;0;337;0
WireConnection;21;0;15;0
WireConnection;40;0;898;0
WireConnection;301;0;87;0
WireConnection;301;1;302;0
WireConnection;88;0;301;0
WireConnection;88;1;89;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;718;0;88;0
WireConnection;719;0;92;0
WireConnection;344;0;88;0
WireConnection;344;1;92;0
WireConnection;715;0;718;0
WireConnection;715;1;719;0
WireConnection;581;0;344;0
WireConnection;956;1;783;0
WireConnection;714;1;715;0
WireConnection;94;1;581;0
WireConnection;717;0;94;2
WireConnection;717;1;714;2
WireConnection;810;0;956;0
WireConnection;721;1;94;2
WireConnection;721;0;717;0
WireConnection;99;0;721;0
WireConnection;813;0;812;0
WireConnection;494;0;966;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;707;0;813;0
WireConnection;354;0;355;0
WireConnection;354;1;24;0
WireConnection;957;0;495;0
WireConnection;957;1;707;0
WireConnection;619;0;618;0
WireConnection;619;1;620;0
WireConnection;353;0;354;0
WireConnection;353;1;619;0
WireConnection;776;0;957;0
WireConnection;356;0;24;0
WireConnection;356;1;41;0
WireConnection;29;1;356;0
WireConnection;28;1;353;0
WireConnection;30;0;28;3
WireConnection;30;1;29;3
WireConnection;496;0;777;0
WireConnection;496;1;5;0
WireConnection;648;0;647;0
WireConnection;648;1;104;0
WireConnection;420;0;496;0
WireConnection;420;1;30;0
WireConnection;649;0;648;0
WireConnection;497;0;777;0
WireConnection;497;1;3;0
WireConnection;479;0;649;0
WireConnection;425;0;420;0
WireConnection;425;1;497;0
WireConnection;426;0;425;0
WireConnection;732;0;18;0
WireConnection;732;1;46;0
WireConnection;444;0;10;4
WireConnection;444;1;426;0
WireConnection;661;0;660;0
WireConnection;340;0;47;0
WireConnection;342;0;732;0
WireConnection;342;1;343;0
WireConnection;341;0;732;0
WireConnection;341;1;340;0
WireConnection;339;0;342;0
WireConnection;339;1;47;0
WireConnection;631;0;444;0
WireConnection;659;1;661;0
WireConnection;45;1;341;0
WireConnection;42;0;631;0
WireConnection;50;1;339;0
WireConnection;943;0;477;4
WireConnection;943;1;659;4
WireConnection;943;2;941;0
WireConnection;151;0;480;0
WireConnection;51;0;45;0
WireConnection;51;1;50;0
WireConnection;488;0;943;0
WireConnection;362;0;51;0
WireConnection;134;0;117;0
WireConnection;134;1;119;0
WireConnection;609;0;606;0
WireConnection;609;1;608;0
WireConnection;487;0;151;0
WireConnection;487;1;488;0
WireConnection;604;0;628;0
WireConnection;604;1;741;0
WireConnection;607;0;609;0
WireConnection;149;0;134;0
WireConnection;149;1;487;0
WireConnection;361;0;360;0
WireConnection;361;1;269;0
WireConnection;920;0;269;0
WireConnection;920;1;919;0
WireConnection;658;0;149;0
WireConnection;602;0;609;0
WireConnection;602;1;604;0
WireConnection;922;0;266;0
WireConnection;603;0;607;0
WireConnection;603;1;628;0
WireConnection;359;0;361;0
WireConnection;359;1;922;0
WireConnection;634;0;632;0
WireConnection;634;1;633;0
WireConnection;64;0;602;0
WireConnection;64;1;63;0
WireConnection;65;0;63;0
WireConnection;65;1;603;0
WireConnection;805;0;920;0
WireConnection;805;1;804;0
WireConnection;121;0;658;0
WireConnection;806;0;922;0
WireConnection;806;1;805;0
WireConnection;636;0;64;0
WireConnection;636;1;634;0
WireConnection;637;0;65;0
WireConnection;637;1;634;0
WireConnection;372;0;359;0
WireConnection;67;1;637;0
WireConnection;260;1;806;0
WireConnection;676;0;732;0
WireConnection;676;1;681;0
WireConnection;478;0;477;0
WireConnection;478;1;60;0
WireConnection;478;2;482;0
WireConnection;66;1;636;0
WireConnection;126;0;372;0
WireConnection;456;0;377;0
WireConnection;456;1;271;0
WireConnection;508;2;106;0
WireConnection;677;0;47;0
WireConnection;677;1;676;0
WireConnection;265;0;260;0
WireConnection;669;0;670;0
WireConnection;669;1;671;0
WireConnection;68;0;66;1
WireConnection;68;1;67;1
WireConnection;509;0;456;0
WireConnection;509;1;508;0
WireConnection;942;0;478;0
WireConnection;942;1;659;0
WireConnection;942;2;941;0
WireConnection;672;0;669;0
WireConnection;672;1;673;0
WireConnection;946;0;677;0
WireConnection;627;0;509;0
WireConnection;70;0;69;0
WireConnection;70;1;68;0
WireConnection;76;0;67;3
WireConnection;374;0;367;0
WireConnection;374;1;942;0
WireConnection;374;2;377;0
WireConnection;297;0;374;0
WireConnection;297;1;298;0
WireConnection;297;2;627;0
WireConnection;675;1;946;0
WireConnection;601;0;70;0
WireConnection;601;1;76;0
WireConnection;601;2;599;0
WireConnection;212;0;201;0
WireConnection;212;1;213;0
WireConnection;678;0;672;0
WireConnection;244;0;601;0
WireConnection;947;0;675;0
WireConnection;102;0;10;0
WireConnection;948;0;678;0
WireConnection;792;0;51;0
WireConnection;833;1;922;0
WireConnection;350;0;297;0
WireConnection;199;0;200;0
WireConnection;199;2;211;0
WireConnection;199;3;212;0
WireConnection;231;0;721;0
WireConnection;231;1;232;0
WireConnection;936;0;833;1
WireConnection;791;0;51;0
WireConnection;219;0;231;0
WireConnection;219;1;220;0
WireConnection;203;0;202;4
WireConnection;203;1;199;0
WireConnection;652;0;384;0
WireConnection;652;1;128;0
WireConnection;674;0;792;0
WireConnection;674;1;947;0
WireConnection;674;2;948;0
WireConnection;624;0;71;0
WireConnection;624;1;601;0
WireConnection;111;0;110;0
WireConnection;111;1;112;0
WireConnection;680;1;791;0
WireConnection;680;0;674;0
WireConnection;651;0;652;0
WireConnection;938;0;925;0
WireConnection;938;1;936;0
WireConnection;475;0;103;0
WireConnection;475;1;476;0
WireConnection;505;0;203;0
WireConnection;230;0;219;0
WireConnection;230;1;229;0
WireConnection;73;0;624;0
WireConnection;141;0;351;0
WireConnection;141;1;111;0
WireConnection;61;0;141;0
WireConnection;61;1;475;0
WireConnection;61;2;62;0
WireConnection;933;0;938;0
WireConnection;713;0;230;0
WireConnection;205;0;505;0
WireConnection;621;0;622;0
WireConnection;621;1;680;0
WireConnection;621;2;651;0
WireConnection;206;0;202;0
WireConnection;955;0;844;0
WireConnection;955;1;933;0
WireConnection;625;0;61;0
WireConnection;625;1;79;0
WireConnection;52;0;621;0
WireConnection;221;0;713;0
WireConnection;834;0;955;0
WireConnection;207;0;625;0
WireConnection;207;1;210;0
WireConnection;207;2;208;0
WireConnection;223;0;207;0
WireConnection;223;1;315;0
WireConnection;223;2;224;0
WireConnection;877;0;56;0
WireConnection;863;0;862;0
WireConnection;841;0;223;0
WireConnection;841;1;842;0
WireConnection;866;0;864;0
WireConnection;866;1;863;0
WireConnection;868;0;865;0
WireConnection;869;1;866;0
WireConnection;114;0;841;0
WireConnection;872;0;869;0
WireConnection;872;1;868;0
WireConnection;944;0;833;1
WireConnection;962;0;961;0
WireConnection;873;0;867;1
WireConnection;873;1;870;0
WireConnection;965;0;872;0
WireConnection;965;1;865;0
WireConnection;498;0;489;0
WireConnection;498;1;2;0
WireConnection;879;0;880;0
WireConnection;879;1;965;0
WireConnection;958;0;873;0
WireConnection;958;1;870;0
WireConnection;963;0;96;0
WireConnection;963;1;962;0
WireConnection;964;0;963;0
WireConnection;953;0;498;0
WireConnection;809;0;811;0
WireConnection;874;0;879;0
WireConnection;874;1;958;0
WireConnection;95;0;964;0
WireConnection;95;1;721;0
WireConnection;770;0;953;0
WireConnection;770;1;809;0
WireConnection;952;1;874;0
WireConnection;98;0;97;0
WireConnection;98;1;95;0
WireConnection;875;0;952;0
WireConnection;968;0;770;0
WireConnection;100;0;98;0
WireConnection;856;0;878;0
WireConnection;856;1;53;0
WireConnection;856;3;960;0
WireConnection;856;4;877;0
WireConnection;814;0;968;0
WireConnection;765;0;747;1
WireConnection;899;0;762;0
WireConnection;470;0;41;0
WireConnection;758;0;746;1
WireConnection;758;1;755;0
WireConnection;832;0;47;0
WireConnection;967;0;780;0
WireConnection;801;1;359;0
WireConnection;757;0;754;0
WireConnection;760;0;759;0
WireConnection;760;1;746;1
WireConnection;857;1;115;0
WireConnection;857;0;856;0
WireConnection;222;0;233;0
WireConnection;233;0;30;0
WireConnection;750;0;747;2
WireConnection;747;1;803;0
WireConnection;759;0;756;0
WireConnection;891;0;128;0
WireConnection;786;0;767;0
WireConnection;786;1;809;0
WireConnection;845;0;877;0
WireConnection;845;1;846;0
WireConnection;954;0;372;0
WireConnection;954;1;801;0
WireConnection;755;0;746;1
WireConnection;755;1;746;1
WireConnection;762;0;760;0
WireConnection;762;1;761;0
WireConnection;218;0;95;0
WireConnection;778;0;957;0
WireConnection;778;1;751;0
WireConnection;756;0;746;3
WireConnection;756;1;746;4
WireConnection;748;0;765;0
WireConnection;763;0;899;0
WireConnection;761;0;758;0
WireConnection;761;1;757;0
WireConnection;0;9;815;0
WireConnection;0;13;857;0
WireConnection;0;11;101;0
ASEEND*/
//CHKSM=FCBF226D691DEFD4DEC29184E4FAAE23B2F8E81F