using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubeMap : ScriptableWizard
{
    public Transform renderPos;
    public Cubemap cubemap;

    [MenuItem("Tools/CreateCubemap")]
    static void CreatCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render Cube", "Create");
    }

    private void OnWizardUpdate()
    {
        helpString = "选择渲染位置并且确定需要设置的Cubemap";
        isValid = renderPos != null && cubemap != null;
    }

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubemapCam");
        Camera camera = go.AddComponent<Camera>();
        go.transform.position = renderPos.position;
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }
}
