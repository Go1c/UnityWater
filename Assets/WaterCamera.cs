using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
/// <summary>
/// 水体采样
/// </summary>
public class WaterCamera : MonoBehaviour
{

    public Camera GetCamera
    {
        get { return m_Camera; }
    }


    private Camera m_Camera;

    private RenderTexture m_CurTexture;//当前RT
    private RenderTexture m_PreTexture;//之前RT
    private RenderTexture m_HeightMap;//深度RT
    private RenderTexture m_NormalMap;//法线RT

    private Material m_WaveMat;//shader根据二次波方程计算当前高度
    private Material m_NormalMat;
    private Material m_ForceMaterial;

    private CommandBuffer m_CommandBuffer;


    public void Init(float width, float height, int texSize)
    {
        m_Camera = gameObject.AddComponent<Camera>();
        m_Camera.aspect = width / height;//宽高比
        m_Camera.backgroundColor = Color.black;
        m_Camera.cullingMask = 0;
        m_Camera.depth = 0;
        m_Camera.allowHDR = false;

        m_CommandBuffer = new CommandBuffer();
        m_Camera.AddCommandBuffer(CameraEvent.AfterImageEffectsOpaque, m_CommandBuffer);

        m_CurTexture = RenderTexture.GetTemporary(texSize, texSize, 16);
        m_CurTexture.name = "CurTexture";
        m_PreTexture = RenderTexture.GetTemporary(texSize, texSize, 16);
        m_PreTexture.name = "PreTexture";
        m_HeightMap = RenderTexture.GetTemporary(texSize, texSize, 16);
        m_HeightMap.name = "HeightMap";
        m_NormalMap = RenderTexture.GetTemporary(texSize, texSize, 16);
        m_NormalMap.name = "NormalMap";
        m_NormalMap.anisoLevel = 1;//纹理各项异性滤波 1-9  1为没有任何滤波

        RenderTexture tmpRT = RenderTexture.active;
        RenderTexture.active = m_CurTexture;
        GL.Clear(false, true, new Color(0, 0, 0, 0));
        RenderTexture.active = m_PreTexture;
        GL.Clear(false, true, new Color(0, 0, 0, 0));
        RenderTexture.active = m_HeightMap;
        GL.Clear(false, true, new Color(0, 0, 0, 0));

        RenderTexture.active = tmpRT;
        m_Camera.targetTexture = m_CurTexture;

        m_WaveMat = new Material(Shader.Find("Hidden/WaveEquationGen"));
        //m_WaveMat.SetTexture("_Mask", mask);
        m_NormalMat = new Material(Shader.Find("Hidden/NormalGen"));
        m_ForceMaterial = new Material(Shader.Find("Hidden/Force"));

        //m_WaveMat.SetVector("_WaveParams", m_WaveParams);
    }
    private void OnPostRender()
    {
        m_CommandBuffer.Clear();
        m_CommandBuffer.ClearRenderTarget(true, false, Color.black);
        m_CommandBuffer.SetRenderTarget(m_CurTexture);

        Shader.SetGlobalTexture("_WaterHeightMap", m_HeightMap);
        Shader.SetGlobalTexture("_WaterNormalMap", m_NormalMap);
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //传入上一张高度渲染结果,已在shader中根据二位波方程计算当前高度
        m_WaveMat.SetTexture("_PreTex", m_PreTexture);
        Graphics.Blit(src, dest, m_WaveMat);
        Graphics.Blit(dest, m_HeightMap);
        Graphics.Blit(m_HeightMap, m_NormalMap, m_NormalMat);
        Graphics.Blit(src, m_PreTexture);
    }
    public void ForceDrawMesh(Mesh mesh, Matrix4x4 matrix)
    {
        if (!mesh)
            return;
        //if (IsBoundsInCamera(mesh.bounds, m_Camera))
        m_CommandBuffer.DrawMesh(mesh, matrix, m_ForceMaterial);
    }

}
