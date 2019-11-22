Shader "Custom/BullshitOcean" {
	Properties {
		_SeaColor ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex ("Normal Map", 2D) = "white" {}
		_DispTex ("Displacement Map", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.7
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Choppiness("Choppiness", Range(0, 1000)) = 100
		_EdgeLength("EdgeLength", Range(1, 128)) = 4
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Ocean fullforwardshadows vertex:vert tessellate:tess
		#pragma target 5.0
		#pragma enable_d3d11_debug_symbols
		#include "Tessellation.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"

		#define _PI 3.1415926f

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float2 coord;
		};

		struct appdata
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		float4 _SeaColor;
		float L;
		float Amplitude;
		float _NormalTexelSize;
		float OceanLevel;
		sampler2D _NormalTex;
		sampler2D _DispTex;
		sampler2D _NoiseTex;
		sampler2D _FresnelLookup;
		float4x4 _RangeMatrix; 
		float _Glossiness;
		float _Metallic;
		float _Choppiness;
		float _EdgeLength;

		half4 LightingOcean(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
			float cosTheta = dot(s.Normal, viewDir);
			float fresnel = tex2D(_FresnelLookup, float2(cosTheta, 0)).r;
            half3 h = normalize(lightDir + viewDir);
            half diff = max(0, dot(s.Normal, lightDir));            
            float nh = max(0, dot(s.Normal, h));
            float spec = pow(nh, 48.0) * s.Gloss;
            half4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec * fresnel) * atten * 2;
            c.a = s.Alpha;
            return c;
        }

		float4 tess (appdata v0, appdata v1, appdata v2)
        {
            return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
        }

		void vert(inout appdata v)
		{
			float4 pos = lerp(lerp(_RangeMatrix[0], _RangeMatrix[1], v.texcoord.x), 
					       lerp(_RangeMatrix[2], _RangeMatrix[3], v.texcoord.x),
						   v.texcoord.y);
			float4 worldPos = mul(unity_ObjectToWorld, pos);
			worldPos.y = OceanLevel;
			float4 revertPos = mul(unity_WorldToObject, worldPos);
			pos = revertPos;
			float2 coord = pos.xz / L;
			float3 displacement = tex2Dlod(_DispTex, float4(coord, 0, 0)).rgb;
			pos.xyz += displacement.rgb * Amplitude * float3(_Choppiness, 1, _Choppiness);
			v.vertex = pos;
			v.texcoord = coord;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			float4 grad = tex2D(_NormalTex, IN.uv_MainTex);
			// make foam more details
			float limit = 0.8f;
			float rnd = tex2D(_NoiseTex, IN.coord * 10).r;
			float k = grad.w * grad.w  * (grad.w > rnd ? 1 : rnd);
			fixed4 c = lerp(_SeaColor, float4(1,1,1,1), k);
			float3 n = normalize(float3(grad.xy, _NormalTexelSize));
			o.Albedo = c;
			o.Normal = n;
			o.Gloss = lerp(_Glossiness, 0, k);
		}
		ENDCG
	}
	FallBack "Diffuse"
}