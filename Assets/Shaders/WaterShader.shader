//-----------------
//计算水面
//-----------------
Shader "Custom/WaterShader"
{
    Properties
    {
        _Specular ("Specular", float) = 0
        _Gloss ("Gloss", float) = 0
        _Refract ("Refract", float) = 0
        _Height ("Height(position, color)", vector) = (0.36, 0, 0, 0)
        _Fresnel ("Fresnel", float) = 3.0
        _BaseColor ("BaseColor", color) = (1, 1, 1, 1)
        _WaterColor ("WaterColor", color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
            
            
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
                float4 proj: TEXCOORD1;
                float4 TW0: TEXCOORD2;
                float4 TW1: TEXCOORD3;
                float4 TW2: TEXCOORD4;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            
            half _Refract;                        //折射系数
            half _Fresnel;                        //菲尼尔系数
            half _Specular;
            half _Gloss;
            float2 _Height;                       //高度系数
            half4 _BaseColor;                     //底色
            half4 _WaterColor;                    //水面颜色
            float4x4 _RangeMatrix; 
            
            sampler2D_float _CameraDepthTexture;  //深度采样图
            sampler2D _WaterHeightMap;            //高度图
            sampler2D _WaterNormalMap;            //法线图
            sampler2D _GrabTexture;               //抓屏图
            sampler2D _WaterReflectMap;           //反射图
            
            
            float DecodeHeight(float4 rgba)
            {
                float d1 = DecodeFloatRG(rgba.rg);
                float d2 = DecodeFloatRG(rgba.ba);
                
                if (d1 >= d2)
                    return d1;
                else
                return - d2;
            }
            half3 WaterColor(float3 refractColor, float3 reflectColor, float3 worldPos, float height, float3 worldNormal, float3 lightDir, float3 viewDir)
            {
                float f = pow(clamp(1.0 - dot(worldNormal, viewDir), 0.0, 1.0), _Fresnel) * 0.65;
                float3 viewDis = -worldPos;
                float3 refraccol = _BaseColor.rgb * refractColor + pow(dot(worldNormal, lightDir) * 0.4 + 0.6, 80.0) * _WaterColor.rgb * 0.12;
                
                float3 color = lerp(refraccol, reflectColor, f);
                
                float atten = max(1.0 - dot(viewDis, viewDis) * 0.001, 0.0);
                color += _WaterColor.rgb * refractColor * (height * _Height.y) * 0.18 * atten;
                
                return color;
            }
            
            v2f vert(appdata_full v)
            {
                
                v2f o;
                float4 pos = lerp(lerp(_RangeMatrix[0], _RangeMatrix[1], v.texcoord.x),
                lerp(_RangeMatrix[2], _RangeMatrix[3], v.texcoord.x),
                v.texcoord.y);
                o.vertex = UnityObjectToClipPos(v.vertex);//计算裁剪空间坐标
                o.proj = ComputeScreenPos(o.vertex); //计算屏幕坐标
                o.uv = v.texcoord;
                COMPUTE_EYEDEPTH(o.proj.z);//计算深度必须计算这一步，计算顶点摄像机空间的深度：距离裁剪平面的距离，线性变化；
                UNITY_TRANSFER_FOG(o, o.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, pos).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 worldBinNormal = cross(worldNormal, worldTangent) * tangentSign;
                o.TW0 = float4(worldTangent.x, worldBinNormal.x, worldNormal.x, worldPos.x);
                o.TW1 = float4(worldTangent.y, worldBinNormal.y, worldNormal.y, worldPos.y);
                o.TW2 = float4(worldTangent.z, worldBinNormal.z, worldNormal.z, worldPos.z);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                float depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.proj)).r);//世界空间
                float deltaDepth = depth - i.proj.z;//视角空间
                
                float3 normal = UnpackNormal(tex2D(_WaterNormalMap, i.uv)); //切线空间下的normal
                float height = DecodeHeight(tex2D(_WaterHeightMap, i.uv));
                
                float3 worldNormal = float3(dot(i.TW0.xyz, normal), dot(i.TW1.xyz, normal), dot(i.TW2.xyz, normal));
                float3 worldPos = float3(i.TW0.w, i.TW1.w, i.TW2.w);
                
                float3 lightDir = UnityWorldSpaceLightDir(worldPos);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                float2 projUV = i.proj.xy / i.proj.w + normal.xy * _Refract;
                
                half4 reflCol = tex2D(_WaterReflectMap, projUV);
                half4 col = tex2D(_GrabTexture, projUV);
                
                col.rgb = WaterColor(col.rgb, reflCol.rgb, worldPos, height, worldNormal, lightDir, viewDir);
                
                float3 hdir = normalize(lightDir + viewDir);
                float ndh = max(0, dot(worldNormal, hdir));
                //col.rgb += internalWorldLightColor.rgb * pow(ndh, _Specular * 128.0) * _Gloss * atten;
                col.rgb += pow(ndh, _Specular * 128.0) * _Gloss ;
                col.a = 1.0;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
}
