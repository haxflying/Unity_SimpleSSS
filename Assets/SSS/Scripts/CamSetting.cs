using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CamSetting : MonoBehaviour {
    GameObject depthCamera = null;
    public Shader replacementShader = null;
    [Range(0,60)]
    public float D = 15;
    // Use this for initialization
    void Start()
    {
        GetComponent<Camera>().SetReplacementShader(replacementShader, "");

    }

    private void Update()
    {
        Shader.SetGlobalFloat("_D", D);
        Shader.SetGlobalVector("_DepthCamPos", transform.position);
        Shader.SetGlobalMatrix("_C_V", transform.worldToLocalMatrix);
        Shader.SetGlobalMatrix("_C_P", GetComponent<Camera>().projectionMatrix);
    }
}
