Shader "Custom/CartoonShader_NoDepthAlpha"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _WaterShallowColor ("WaterShallowColor", Color) = (1, 1, 1, 1)   //深色
        _WaterDeepColor ("WaterDeepColor", Color) = (1, 1, 1, 1)         //浅色
        _TranAmount ("TranAmount", Range(0, 1)) = 0.5                    //透明度
        _DepthRanger ("DepthRanger", float) = 1                          //深度范围
        _NormalTex ("Normal", 2D) = "bump" { }                           //法线贴图
        _WaterSpeed ("WaterSpeed", float) = 0.02                         //水流动速度
        _Refract ("Refract", float) = 0.5                                //折射
        _Specular ("Specular", float) = 1                                //高光
        _Gloss ("Gloss", float) = 0.5                                    //高光范围
        _SpecularColor ("SpeculaColor", Color) = (1, 1, 1, 1)                   //高光颜色
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        ZWrite Off
        LOD 200
        
        CGPROGRAM
        
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf WaterLight vertex:vert alpha noshadow
        
        
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        
        sampler2D _MainTex;
        //深度图中记录的深度值：深度纹理中每个像素所记录的深度值是从0 到1 非线性分布的。
        //精度通常是 24 位或16 位，这主要取决于所使用的深度缓冲区。
        //加_float 提高精度
        sampler2D_float _CameraDepthTexture;
        
        sampler2D _NormalTex;
        
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _WaterShallowColor;
        fixed4 _WaterDeepColor;
        half _TranAmount;
        float _DepthRanger;
        half _WaterSpeed;
        float _Refract;
        half _Specular;
        fixed4 _SpecularColor;
        half _Gloss;
        
        struct Input
        {
            float2 uv_MainTex;
            float4 proj;
            float2 uv_NormalTex;
        };
        
        UNITY_INSTANCING_BUFFER_START(Props)
        
        UNITY_INSTANCING_BUFFER_END(Props)
        
        
        fixed4 LightingWaterLight(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            float diffuseFactor = max(0, dot(lightDir, s.Normal));
            half3 halfDir = normalize(lightDir + viewDir);
            float ndh = max(0, dot(halfDir, s.Normal));
            float specular = pow(ndh, s.Specular * 128) * s.Gloss;
            fixed4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * diffuseFactor + _SpecularColor.rgb * specular * _LightColor0.rgb) * atten;
            c.a = s.Alpha + specular * _SpecularColor.a;
            return c;
        }
        void vert(inout appdata_full v, out Input i)
        {
            UNITY_INITIALIZE_OUTPUT(Input, i);
            
            i.proj = ComputeScreenPos(UnityObjectToClipPos(v.vertex));//转裁剪空间 再转屏幕空间
            COMPUTE_EYEDEPTH(i.proj.z); // -UnityObjectToviewpos(v.vertex).z   z值转到屏幕空间
        }
        void surf(Input IN, inout SurfaceOutput o)
        {
            //---------------------------采样深度
            //采样屏幕空间深度图  uv是当前模型也是屏幕坐标uv  tex2Dproj会在对纹理采样前除以w分量
            float depth = tex2Dproj(_CameraDepthTexture, IN.proj).r;
            //第二种写法采样深度
            //float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.proj));
            //float linear01Depth = Linear01Depth(depth);   //转换成[0,1]内的线性变化深度值 世界空间
            float linearEyeDepth = LinearEyeDepth(depth); //转换到摄像机空间线性深度值
            float deltaDepth = linearEyeDepth - IN.proj.z; //计算差值 是为了计算 水面渲染深度
            //--------------------------采样normal    共采样4次 实现水流动效果
            float4 bumpOffset1 = tex2D(_NormalTex, IN.uv_NormalTex + float2(_WaterSpeed * _Time.y, 0));
            float4 bumpOffset2 = tex2D(_NormalTex, float2(1 - IN.uv_NormalTex.y, IN.uv_NormalTex.x) + float2(_WaterSpeed * _Time.y, 0));  //翻转uv
            float4 offsetColor = (bumpOffset1 + bumpOffset2) * 0.5;
            float2 offset = UnpackNormal(offsetColor).xy * _Refract;
            float4 bumpColor1 = tex2D(_NormalTex, IN.uv_NormalTex + offset +float2(_WaterSpeed * _Time.y, 0));
            float4 bumpColor2 = tex2D(_NormalTex, float2(1 - IN.uv_NormalTex.y, IN.uv_NormalTex.x) + offset +float2(_WaterSpeed * _Time.y, 0));
            //--------------------------根据深度lerp颜色
            fixed4 c = lerp(_WaterShallowColor, _WaterDeepColor, min(_DepthRanger, deltaDepth) / _DepthRanger);
            
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal((bumpColor1 + bumpColor2) * 0.5);
            o.Gloss=_Gloss;
            o.Specular = _Specular;
            o.Alpha = c.a * _TranAmount;
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
