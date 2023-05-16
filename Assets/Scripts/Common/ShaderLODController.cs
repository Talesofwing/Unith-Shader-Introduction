using UnityEngine;

public class ShaderLODController : MonoBehaviour {
    [SerializeField] private int _lod = 400;

    private void Start () {
        Shader.globalMaximumLOD = _lod;
    }

}
