using UnityEngine;

public class FogWithNoise : PostEffectsBase {
    [SerializeField] private Shader _fogWithNoiseShader;
    [Range (0.1f, 3.0f)]
    [SerializeField] private float _fogDensity = 1.0f;
    [SerializeField] private Color _fogColor = Color.white;
    [SerializeField] private float _fogStart = 0.0f;
    [SerializeField] private float _fogEnd = 2.0f;
    [Range (-0.5f, 0.5f)]
    [SerializeField] private float _fogXSpeed = 0.1f;
    [Range (-0.5f, 0.5f)]
    [SerializeField] private float _fogYSpeed = 0.1f;
    [Range (0.0f, 3.0f)]
    [SerializeField] private float _noiseAmount = 1.0f;
    [SerializeField] private Texture _noiseTexture;


    private Matrix4x4 _previousViewProjectMatrix;

    private RenderTexture _accumulationTexture;

    private Material _fogWithNoiseMat;
    public Material FogWithNoiseMat {
        get {
            _fogWithNoiseMat = CheckShaderAndCreateMaterial (_fogWithNoiseShader, _fogWithNoiseMat);
            return _fogWithNoiseMat;
        }
    }

    private Transform _cacheCameraTf;
    public Transform CameraTransform {
        get {
            if (_cacheCameraTf == null) {
                _cacheCameraTf = Cam.transform;
            }

            return _cacheCameraTf;
        }
    }

    private void OnEnable () {
        Cam.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage (RenderTexture src, RenderTexture dest) {
        if (FogWithNoiseMat != null) {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = Cam.fieldOfView;
            float near = Cam.nearClipPlane;
            float aspect = Cam.aspect;

            float halfHeight = near * Mathf.Tan (fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;
            Vector3 toTop = CameraTransform.up * halfHeight;

            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize ();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.forward * near + toRight + toTop;
            topRight.Normalize ();
            topRight *= scale;

            Vector3 bottomLeft = CameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize ();
            bottomLeft *= scale;

            Vector3 bottomRight = CameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize ();
            bottomRight *= scale;

            frustumCorners.SetRow (0, bottomLeft);
            frustumCorners.SetRow (1, bottomRight);
            frustumCorners.SetRow (2, topRight);
            frustumCorners.SetRow (3, topLeft);

            FogWithNoiseMat.SetMatrix ("_FrustumCornersRay", frustumCorners);

            FogWithNoiseMat.SetFloat ("_FogDensity", _fogDensity);
            FogWithNoiseMat.SetColor ("_FogColor", _fogColor);
            FogWithNoiseMat.SetFloat ("_FogStart", _fogStart);
            FogWithNoiseMat.SetFloat ("_FogEnd", _fogEnd);
            FogWithNoiseMat.SetTexture ("_NoiseTex", _noiseTexture);
            FogWithNoiseMat.SetFloat ("_FogXSpeed", _fogXSpeed);
            FogWithNoiseMat.SetFloat ("_FogYSpeed", _fogYSpeed);
            FogWithNoiseMat.SetFloat ("_NoiseAmount", _noiseAmount);

            Graphics.Blit (src, dest, FogWithNoiseMat);
        } else {
            Graphics.Blit (src, dest);
        }
    }

}
