using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterInteraction : MonoBehaviour
{
    public float height;//水面高度
    public float swipeSize;
    public Water water;
    public Mesh swipeMesh; //鼠标点击时的mesh（球体）
    private float dragPlane; //碰撞距离
    public GameObject dragTarget; //交互物体
    private Camera cam;
    private Vector4 swipePlane; //接触面
    private Vector4 DragWorldPlane; //世界坐标
    private Vector3 Offset; //偏移距离
    private bool isBeginDrag;  //是否碰撞
    RaycastHit hit;

    void Start()
    {
        cam = gameObject.GetComponent<Camera>();
        swipePlane = new Vector4(0, 1, 0, Vector3.Dot(Vector3.up, new Vector3(0, height, 0)));
    }
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Ray ray = cam.ScreenPointToRay(Input.mousePosition);
            if (!isBeginDrag)
            {
                if (Physics.Raycast(ray, out hit))
                {
                    if (hit.collider.gameObject == dragTarget)
                    {
                        if (!isBeginDrag)
                        {
                            isBeginDrag = true;
                            Vector3 viewPos = cam.transform.worldToLocalMatrix.MultiplyPoint(hit.collider.transform.position);
                            dragPlane = viewPos.z;
                            Offset = hit.point - hit.collider.transform.position;
                            DragWorldPlane = new Vector4(0, 1, 0, Vector3.Dot(Vector3.up, hit.point));
                        }
                    }
                    else if (hit.collider.gameObject == water.gameObject)
                    {
                        if (!isBeginDrag)
                        {
                            float t = (swipePlane.w -
                                       Vector3.Dot(ray.origin,
                                           new Vector3(swipePlane.x, swipePlane.y, swipePlane.z))) /
                                      Vector3.Dot(ray.direction,
                                          new Vector3(swipePlane.x, swipePlane.y, swipePlane.z));
                            Vector3 hitpos = ray.origin + ray.direction * t;
                            Matrix4x4 matrix = Matrix4x4.TRS(hitpos, Quaternion.identity, Vector3.one * swipeSize);
                            Debug.Log(111);
                            water.DrawMesh(swipeMesh, matrix);
                        }
                    }
                }
            }
            else
            {
                if (cam.transform.eulerAngles.x > 45)
                {
                    float t = (DragWorldPlane.w -
                               Vector3.Dot(ray.origin,
                                   new Vector3(DragWorldPlane.x, DragWorldPlane.y, DragWorldPlane.z))) /
                              Vector3.Dot(ray.direction,
                                  new Vector3(DragWorldPlane.x, DragWorldPlane.y, DragWorldPlane.z));
                    Vector3 hitpos = ray.origin + ray.direction * t;

                    dragTarget.transform.position = hitpos - Offset;
                }
                else
                {
                    float tan = Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
                    float height = dragPlane * tan;
                    float width = height * cam.aspect;

                    float x = (Input.mousePosition.x / Screen.width) * 2 - 1;
                    float y = (Input.mousePosition.y / Screen.height) * 2 - 1;
                    Vector3 viewPos = new Vector3(x * width, y * height, dragPlane);
                    Vector3 pos = cam.transform.localToWorldMatrix.MultiplyPoint(viewPos);
                    dragTarget.transform.position = pos - Offset;
                }
            }
        }
    }
}
