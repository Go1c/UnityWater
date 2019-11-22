using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Bullshit))]
public class WaveSpectrum : MonoBehaviour {
    [SerializeField]
    int N = 512;    //傅里叶级数，需为2的N次幂
    [SerializeField]
    float L = 200f; //实际范围
    //波幅常数A
    [SerializeField]
    float amplitude = 0.0002f;
    //风速和风向
    [SerializeField]
    Vector2 windDir = new Vector2(32.0f, 32.0f);
    Vector2 windDir_normal;
    [SerializeField]
    float windVelocity;

    #region Mono
    void Start()
    {
        //统一N
        if (!Mathf.IsPowerOfTwo(N)) N = Mathf.NextPowerOfTwo(N);
        texButterfly = InitButterflyToTexture();
        windDir_normal = windDir.normalized;
        FFTInit();
        SpectrumInit();
        MaterialInit();
        OceanMatInit();
        FresnelInit();
	}
	
	// Update is called once per frame
	void Update () {
        float time = Time.time;
        SpectrumUpdate(time);
        FFTUpdate(bufferSpectrumH, bufferHFinal);
        FFTUpdate(bufferSpectrumDx, bufferDxFinal);
        FFTUpdate(bufferSpectrumDy, bufferDyFinal);
        Combine();
    }

    void LateUpdate()
    {
        OceanLateUpdate();
    }
    #endregion
    #region 菲涅尔预计算
    [SerializeField]
    Texture2D fresnelLookupTex;
    void FresnelInit()
    {
        fresnelLookupTex = new Texture2D(512, 1, TextureFormat.RFloat, false);
        float t = 1 / 511f;
        for (int i = 0; i < 512; i++)
        {
            float cosTheta = i * t;
            float schilick = Schilick(cosTheta);
            fresnelLookupTex.SetPixel(i, 0, new Color(schilick, 0, 0, 1));
        }
        fresnelLookupTex.Apply();
    }

    // Schilick近似:R(\theta)=R(0)+(1-R(0))(1-cos\theta_i)^5
    float Schilick(float cost)
    {
        float water_n = 1.333f;
        float R0 = (1 - water_n) / (1 + water_n);
        R0 *= R0;
        return R0 + (1 - R0) * Mathf.Pow(1 - cost, 5);
    }
    #endregion
    #region 蝶形运算
    [SerializeField]
    Texture2D texButterfly;
    Texture2D InitButterflyToTexture()
    {
        int logN = (int)(Mathf.Log(N, 2));
        var butterflyData = new Vector2[N * logN];
        //offset = 当前层数的偏移量
        //numIterations = 当前层数的总共有几个数据
        int offset = 1, numIterations = N >> 1;
        //逐行填充蝶形运算数据
        for (int row = 0; row < logN; row++)
        {
            int rowStart = row * N;
            //start和end用于记录本次录制的区域，毕竟蝶形操作越往后有效的数据越少
            int start = 0, end = 2 * offset;
            float singlePhase = 2f * Mathf.PI * numIterations / N;
            for (int i = 0; i < numIterations; i++)
            {
                int K = 0;
                for (int k = start; k < end; k += 2)
                {
                    //计算需要用的w^k_n
                    float phase = K * singlePhase;
                    float cos = Mathf.Cos(phase);
                    float sin = Mathf.Sin(phase);
                    int hk = k >> 1;
                    //总之就是随着递归阶段的上升，offset增加
                    butterflyData[rowStart + hk].x = cos;
                    butterflyData[rowStart + hk].y = -sin;
                    butterflyData[rowStart + hk + offset].x = -cos;
                    butterflyData[rowStart + hk + offset].y = sin;
                    K++;
                }
                start += 4 * offset;
                end = start + 2 * offset;
            }
            numIterations >>= 1;
            offset <<= 1;
        }
        //填充进texture2D中，为保证进度，使用16位R和G
        texButterfly = new Texture2D(N, logN, TextureFormat.RGHalf, false);
        for (int y = 0; y < logN; y++)
        {
            for (int x = 0; x < N; x++)
            {
                int idx = y * N + x;
                texButterfly.SetPixel(x, y, new Color(butterflyData[idx].x, butterflyData[idx].y, 0));
            }
        }
        texButterfly.Apply(false, true);
        return texButterfly;
    }
    #endregion
    #region Compute Shader调用
    private ComputeShader shaderSpectrum;
    [SerializeField]
    private RenderTexture bufferSpectrumH0;
    [SerializeField]
    private RenderTexture bufferSpectrumH;
    [SerializeField]
    private RenderTexture bufferSpectrumDx;
    [SerializeField]
    private RenderTexture bufferSpectrumDy;
    private int kernelSpectrumInit;
    private int kernelSpectrumUpdate;

    void SpectrumInit()
    {
        shaderSpectrum = (ComputeShader)Resources.Load("EncinoSpectrum", typeof(ComputeShader));
        kernelSpectrumInit = shaderSpectrum.FindKernel("EncinoSpectrumInit");
        kernelSpectrumUpdate = shaderSpectrum.FindKernel("EncinoSpectrumUpdate");
        //准备h0频谱图
        bufferSpectrumH0 = new RenderTexture(N, N, 0, RenderTextureFormat.ARGBFloat);
        bufferSpectrumH0.enableRandomWrite = true;
        bufferSpectrumH0.Create();
        bufferSpectrumH = CreateSpectrumUAV();
        bufferSpectrumDx = CreateSpectrumUAV();
        bufferSpectrumDy = CreateSpectrumUAV();
    }

    void SpectrumUpdate(float time)
    {
        //第一步，计算h0
        shaderSpectrum.SetInt("N", N);
        shaderSpectrum.SetFloat("L", L);
        shaderSpectrum.SetFloats("windDir_normal", windDir_normal.x, windDir_normal.y);
        shaderSpectrum.SetFloat("windVelocity", windVelocity);
        shaderSpectrum.SetTexture(kernelSpectrumInit, "outputH0", bufferSpectrumH0);
        shaderSpectrum.Dispatch(kernelSpectrumInit, N / 8, N / 8, 1);
        //第二步，根据时间计算h'
        shaderSpectrum.SetFloat("time", time);
        shaderSpectrum.SetTexture(kernelSpectrumUpdate, "inputH0", bufferSpectrumH0);
        shaderSpectrum.SetTexture(kernelSpectrumUpdate, "outputH", bufferSpectrumH);
        shaderSpectrum.SetTexture(kernelSpectrumUpdate, "outputDx", bufferSpectrumDx);
        shaderSpectrum.SetTexture(kernelSpectrumUpdate, "outputDy", bufferSpectrumDy);
        shaderSpectrum.Dispatch(kernelSpectrumUpdate, N / 8, N / 8, 1);
    }

    RenderTexture CreateSpectrumUAV()
    {
        var uav = new RenderTexture(N, N, 0, RenderTextureFormat.ARGBFloat);
        uav.enableRandomWrite = true;
        uav.Create();
        return uav;
    }
    #endregion
    #region FFT调用
    ComputeShader shaderFFT;
    RenderTexture bufferFFTTemp;
    int kernelFFTX = 0;
    int kernelFFTY = 1;
    [SerializeField]
    private RenderTexture bufferHFinal;
    [SerializeField]
    private RenderTexture bufferDxFinal;
    [SerializeField]
    private RenderTexture bufferDyFinal;

    void FFTInit()
    {
        shaderFFT = (ComputeShader)Resources.Load("EncinoFFT", typeof(ComputeShader));
        int log2difference = (int)Mathf.Log(2, N / 256);
        kernelFFTX = log2difference * 2;
        kernelFFTY = kernelFFTX + 1;
        //
        bufferFFTTemp = new RenderTexture(N, N, 0, RenderTextureFormat.RGFloat);
        bufferFFTTemp.enableRandomWrite = true;
        bufferFFTTemp.Create();

        bufferHFinal = CreateFinalTexture();
        bufferDxFinal = CreateFinalTexture();
        bufferDyFinal = CreateFinalTexture();
    }

    void FFTUpdate(RenderTexture spectrum, RenderTexture output)
    {
        shaderFFT.SetTexture(kernelFFTX, "input", spectrum);
        shaderFFT.SetTexture(kernelFFTX, "inputButterfly", texButterfly);
        shaderFFT.SetTexture(kernelFFTX, "output", bufferFFTTemp);
        shaderFFT.Dispatch(kernelFFTX, 1, N, 1);
        shaderFFT.SetTexture(kernelFFTY, "input", bufferFFTTemp);
        shaderFFT.SetTexture(kernelFFTY, "inputButterfly", texButterfly);
        shaderFFT.SetTexture(kernelFFTY, "output", output);
        shaderFFT.Dispatch(kernelFFTY, N, 1, 1);
    }

    RenderTexture CreateFinalTexture()
    {
        var texture = new RenderTexture(N, N, 0, RenderTextureFormat.RFloat);
        texture.enableRandomWrite = true;
        texture.Create();
        return texture;
    }
    #endregion
    #region 计算法线和偏移
    public float choppiness = 2f;
    Material combineMat;
    private RenderTexture bufferDisplacement;
    private RenderTexture bufferGradientFold;
    void MaterialInit()
    {
        combineMat = (Material)Resources.Load("Combine", typeof(Material));
        bufferDisplacement = CreateCombinedTexture();
        bufferGradientFold = CreateCombinedTexture();
    }

    void Combine()
    {
        if (combineMat == null) return;
        combineMat.SetInt("N", N);
        combineMat.SetFloat("L", L);
        combineMat.SetFloat("invL", 1.0f / L);
        combineMat.SetTexture("inputH", bufferHFinal);
        combineMat.SetTexture("inputDx", bufferDxFinal);
        combineMat.SetTexture("inputDy", bufferDyFinal);
        Graphics.SetRenderTarget(new RenderBuffer[] { bufferDisplacement.colorBuffer, bufferGradientFold.colorBuffer }, bufferDisplacement.depthBuffer);
        GL.PushMatrix();
        GL.LoadPixelMatrix(0, N, N, 0);
        GL.Viewport(new Rect(0, 0, N, N));
        combineMat.SetPass(0);
        GL.Begin(GL.QUADS);
        GL.TexCoord2(0, 0);
        GL.Vertex3(0, 0, 0);
        GL.TexCoord2(1, 0);
        GL.Vertex3(N, 0, 0);
        GL.TexCoord2(1, 1);
        GL.Vertex3(N, N, 0);
        GL.TexCoord2(0, 1);
        GL.Vertex3(0, N, 0);
        GL.End();
        GL.PopMatrix();
        Graphics.SetRenderTarget(null);
    }

    RenderTexture CreateCombinedTexture()
    {
        var texture = new RenderTexture(N, N, 0, RenderTextureFormat.ARGBFloat);
        texture.enableRandomWrite = true;
        texture.useMipMap = true;
        texture.autoGenerateMips = true;
        texture.filterMode = FilterMode.Bilinear;
        texture.wrapMode = TextureWrapMode.Repeat;
        texture.Create();
        return texture;
    }
    #endregion
    #region 展示
    Material oceanMat;
    void OceanMatInit()
    {
        oceanMat = (Material)Resources.Load("Ocean", typeof(Material));
    }

    void OceanLateUpdate()
    {
        oceanMat.SetTexture("_NormalTex", bufferGradientFold);
        oceanMat.SetTexture("_DispTex", bufferDisplacement);
        oceanMat.SetFloat("L", L);
        oceanMat.SetFloat("_NormalTexelSize", 2.0f * L / N);
        oceanMat.SetFloat("Amplitude", amplitude);
        oceanMat.SetFloat("OceanLevel", GetComponent<Bullshit>().OceanLevel);
        oceanMat.SetTexture("_FresnelLookup", fresnelLookupTex);
    }
    #endregion
}
