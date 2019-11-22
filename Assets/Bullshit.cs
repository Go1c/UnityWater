using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Bullshit : MonoBehaviour {
    public Material projectorMat;
    public float OceanLevel = 0;

    Camera cam;

    class FrustrumPoint
    {
        public Vector4 localPos;
        public Vector4 worldPos;
    }

	// Use this for initialization
	void Start () {
        cam = GetComponent<Camera>();
        CreateGrid();
	}
	
	// Update is called once per frame
	void Update () {
        GetCrossPoint();
        MakeRangeMatrix();
        MeshTransformKeep();
	}

    #region 防止裁剪
    void MeshTransformKeep()
    {
        GridTransform.rotation = Quaternion.Euler(Vector3.zero);
    }
    #endregion

    #region 调试用
    void OnDrawGizmos()
    {
        if (cam == null) return;
        Matrix4x4 matrixV = cam.worldToCameraMatrix;
        Matrix4x4 matrixP = cam.projectionMatrix;
        var ivp = (matrixP * matrixV).inverse;
        //foreach (var v in frustrumCorner)
        //{
        //    Gizmos.DrawSphere(cameraToWorld(v), 0.1f);
        //}
        //foreach (var v in crossPoints)
        //{
        //    Gizmos.DrawSphere(v.worldPos, 0.1f);
        //}
        if (crossPoints.Count <= 3) return;
        Vector3 s1 = (Vector3)(crossPoints[1].worldPos - crossPoints[0].worldPos);
        Vector3 s2 = (Vector3)(crossPoints[3].worldPos - crossPoints[1].worldPos);
        Vector3 s3 = (Vector3)(crossPoints[1].worldPos - crossPoints[2].worldPos);
        Vector3 s4 = (Vector3)(crossPoints[3].worldPos - crossPoints[1].worldPos);
        Vector3 d1 = Vector3.Cross(s1, s2);
        Vector3 d2 = Vector3.Cross(s3, s4);
        //if (Vector3.Dot(d1, d2) > 0)
        //{
        //    Gizmos.DrawLine(crossPoints[0].worldPos, crossPoints[2].worldPos);
        //    Gizmos.DrawLine(crossPoints[1].worldPos, crossPoints[3].worldPos);
        //    Gizmos.DrawLine(crossPoints[0].worldPos, crossPoints[1].worldPos);
        //    Gizmos.DrawLine(crossPoints[2].worldPos, crossPoints[3].worldPos);
        //}
        //else
        //{
        //    Gizmos.DrawLine(crossPoints[0].worldPos, crossPoints[3].worldPos);
        //    Gizmos.DrawLine(crossPoints[1].worldPos, crossPoints[2].worldPos);
        //    Gizmos.DrawLine(crossPoints[0].worldPos, crossPoints[1].worldPos);
        //    Gizmos.DrawLine(crossPoints[2].worldPos, crossPoints[3].worldPos);
        //}
        //for (int i = 0; i < crossPoints.Count - 1; i++)
        //{
        //    Gizmos.DrawLine(crossPoints[i].worldPos, crossPoints[i + 1].worldPos);
        //}
        //Gizmos.DrawLine(crossPoints[crossPoints.Count - 1].worldPos, crossPoints[0].worldPos);
        Gizmos.color = Color.red;
        Gizmos.DrawLine(crossPoints[0].worldPos, crossPoints[1].worldPos);

        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(crossPoints[1].worldPos, crossPoints[2].worldPos);

        Gizmos.color = Color.green;
        Gizmos.DrawLine(crossPoints[2].worldPos, crossPoints[3].worldPos);

        Gizmos.color = Color.blue;
        Gizmos.DrawLine(crossPoints[3].worldPos, crossPoints[0].worldPos);
    }
    #endregion

    #region 遍历交点，传入矩阵
    Matrix4x4 matrixR;
    void MakeRangeMatrix()
    {
        matrixR = Matrix4x4.zero;
        if (crossPoints.Count < 3)
            return;
        if (crossPoints.Count == 3)
        {
            Vector3 t1 = (Vector3)(crossPoints[1].worldPos - crossPoints[0].worldPos);
            Vector3 t2 = (Vector3)(crossPoints[2].worldPos - crossPoints[1].worldPos);
            if (Vector3.Cross(t1, t2).y > 0)
            {
                matrixR.SetRow(2, crossPoints[0].worldPos);
                matrixR.SetRow(0, crossPoints[0].worldPos);
                matrixR.SetRow(3, crossPoints[1].worldPos);
                matrixR.SetRow(1, crossPoints[2].worldPos);
            }
            else
            {
                matrixR.SetRow(0, crossPoints[0].worldPos);
                matrixR.SetRow(2, crossPoints[0].worldPos);
                matrixR.SetRow(1, crossPoints[1].worldPos);
                matrixR.SetRow(3, crossPoints[2].worldPos);
            }
            projectorMat.SetMatrix("_RangeMatrix", matrixR);
            return;
        }
        // 0    1
        //
        // 3    2
        Resort4Point(ref crossPoints);
        matrixR.SetRow(0, crossPoints[0].worldPos);
        matrixR.SetRow(1, crossPoints[3].worldPos);
        matrixR.SetRow(2, crossPoints[1].worldPos);
        matrixR.SetRow(3, crossPoints[2].worldPos);
        projectorMat.SetMatrix("_RangeMatrix", matrixR);
    }

    void Resort4Point(ref List<FrustrumPoint> list)
    {
        Vector3 s1 = (Vector3)(crossPoints[1].worldPos - crossPoints[0].worldPos);
        Vector3 s2 = (Vector3)(crossPoints[2].worldPos - crossPoints[1].worldPos);
        Vector3 d1 = Vector3.Cross(s1, s2);
        //第一次交换，保证前3点次序
        if (d1.y < 0)
        {
            FrustrumPoint t = crossPoints[1];
            crossPoints[1] = crossPoints[2];
            crossPoints[2] = t;
        }
        s1 = (Vector3)(crossPoints[2].worldPos - crossPoints[1].worldPos);
        s2 = (Vector3)(crossPoints[3].worldPos - crossPoints[2].worldPos);
        Vector3 s3 = (Vector3)(crossPoints[0].worldPos - crossPoints[3].worldPos);
        Vector3 s4 = (Vector3)(crossPoints[1].worldPos - crossPoints[0].worldPos);
        d1 = Vector3.Cross(s1, s2);
        Vector3 d2 = Vector3.Cross(s2, s3);
        Vector3 d3 = Vector3.Cross(s3, s4);
        //第二次交换，保证4点次序
        if (d1.y * d2.y < 0)
        {
            FrustrumPoint t = crossPoints[2];
            crossPoints[2] = crossPoints[1];
            crossPoints[1] = t;
        }
        else if (d2.y * d3.y < 0)
        {
            FrustrumPoint t = crossPoints[3];
            crossPoints[3] = crossPoints[2];
            crossPoints[2] = t;
        }
        //最后判断是否正面朝上
        s1 = (Vector3)(crossPoints[2].worldPos - crossPoints[1].worldPos);
        s2 = (Vector3)(crossPoints[3].worldPos - crossPoints[2].worldPos);
        d1 = Vector3.Cross(s1, s2);
        if (d1.y < 0)
        {
            FrustrumPoint t = crossPoints[3];
            crossPoints[3] = crossPoints[0];
            crossPoints[0] = t;
            t = crossPoints[2];
            crossPoints[2] = crossPoints[1];
            crossPoints[1] = t;
        }
    }
    #endregion

    #region 交点计算
    [SerializeField]
    float outScale = 0.1f;
    readonly Vector4[] frustrumCorner = new Vector4[]{
        // near
        new Vector4(-1, -1, -1, 1), 
        new Vector4( 1, -1, -1, 1), 
        new Vector4( 1,  1, -1, 1),  
        new Vector4(-1,  1, -1, 1),
        // far
        new Vector4(-1, -1, 1, 1),	
        new Vector4( 1, -1, 1, 1),	
        new Vector4( 1,  1, 1, 1),  
        new Vector4(-1,  1, 1, 1)
    };

    readonly static int[,] segments = {
        {0,1}, {1,2}, {2,3}, {3,0}, 
        {4,5}, {5,6}, {6,7}, {7,4},
        {0,4}, {1,5}, {2,6}, {3,7}
    };

    List<FrustrumPoint> crossPoints;
    Matrix4x4 Matrix_I_VP;
    Matrix4x4 Matrix_VP;

    void GetCrossPoint()
    {
        if (crossPoints == null)
            crossPoints = new List<FrustrumPoint>();
        crossPoints.Clear();
        Matrix_VP = cam.projectionMatrix * cam.worldToCameraMatrix;
        Matrix_I_VP = Matrix_VP.inverse;
        for (int i = 0; i < 12; i++)
        {
            FrustrumPoint crossPoint = new FrustrumPoint();
            if (IsSegmentIntersectOcean(segments[i, 0], segments[i, 1], OceanLevel, ref crossPoint))
            {
                crossPoints.Add(crossPoint);
            }
        }
        //为了留出裕度，统统向外扩张5%
        Vector4 middle = Vector4.zero;
        foreach (var p in crossPoints)
        {
            middle += p.worldPos;
        }
        middle /= crossPoints.Count;
        for (int i = 0; i < crossPoints.Count; i++)
        {
            crossPoints[i].worldPos = (crossPoints[i].worldPos - middle) * (1 + outScale) + middle;
        }
    }

    Vector4 cameraToWorld(Vector4 localPos)
    {
        Vector4 res = Matrix_I_VP * localPos;
        res /= res.w;
        return res;
    }

    Vector4 worldToCamera(Vector4 worldSpace)
    {
        Vector4 res = Matrix_VP * worldSpace;
        res /= res.w;
        return res;
    }

    private bool IsSegmentIntersectOcean(int p1, int p2, float OceanLevel, ref FrustrumPoint crossPoint)
    {
        Vector4 a = cameraToWorld(frustrumCorner[p1]);
        Vector4 b = cameraToWorld(frustrumCorner[p2]);
        if ((a.y - OceanLevel) * (b.y - OceanLevel) > 0) return false;    //同侧无交点
        var p = (OceanLevel - a.y) / (b.y - a.y);
        crossPoint = new FrustrumPoint();
        crossPoint.worldPos = new Vector4(
            a.x + p * (b.x - a.x),
            OceanLevel,
            a.z + p * (b.z - a.z),
            1);
        crossPoint.localPos = worldToCamera(crossPoint.worldPos);
        return true;
    }

    #endregion

    #region 网格创建
    readonly int MaxVerticeCount = 65000;
    int tDivide;
    Transform GridTransform;
    void CreateGrid()
    {
        int w = Screen.width, h = Screen.height;
        tDivide = 1;
        do
        {
            w = Screen.width / tDivide;
            h = Screen.height / tDivide;
            tDivide++;
        }
        while (w * h > MaxVerticeCount);
        Mesh mesh = MakeMesh(w, h);
        GameObject grid = new GameObject("ProjectedOceanMesh");
        grid.transform.SetParent(transform);
        //扔在视锥体前方，防止被裁剪
        grid.transform.localPosition = new Vector3(0, 0, 10);
        MeshFilter mf = grid.AddComponent<MeshFilter>();
        MeshRenderer mr = grid.AddComponent<MeshRenderer>();

        mf.sharedMesh = mesh;
        //mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        //mr.receiveShadows = false;
        //mr.motionVectorGenerationMode = MotionVectorGenerationMode.ForceNoMotion;
        mr.sharedMaterial = projectorMat;
        GridTransform = grid.transform;
    }


    // Make Mesh with given width and given height
    Mesh MakeMesh(int W, int H)
    {
        Vector3[] vertices = new Vector3[W * H];
        Vector2[] texcoords = new Vector2[W * H];
        int[] indices = new int[(W - 1) * (H - 1) * 6];

        for (int x = 0; x < W; x++)
        {
            for (int y = 0; y < H; y++)
            {
                Vector2 uv = new Vector3((float)x / (float)(W - 1), (float)y / (float)(H - 1));
                Vector3 pos = new Vector3(x, 0, y) * 0.00001f;
                texcoords[x + y * W] = uv;
                vertices[x + y * W] = pos;
            }
        }
        int num = 0;
        for (int x = 0; x < W - 1; x++)
        {
            for (int y = 0; y < H - 1; y++)
            {
                indices[num++] = x + y * W;
                indices[num++] = x + (y + 1) * W;
                indices[num++] = (x + 1) + y * W;

                indices[num++] = x + (y + 1) * W;
                indices[num++] = (x + 1) + (y + 1) * W;
                indices[num++] = (x + 1) + y * W;
            }
        }
        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.uv = texcoords;
        mesh.triangles = indices;
        mesh.UploadMeshData(false);
        mesh.RecalculateNormals();
        return mesh;
    }
    #endregion
}
