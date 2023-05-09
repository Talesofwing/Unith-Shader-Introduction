using UnityEngine;

public class FogWithDepthTexture : PostEffectsBase {
	[SerializeField] private Shader _fogWithDepthTextureShader;
	[Range (0.0f, 3.0f)]
	[SerializeField] private float _fogDensity = 1.0f;
	[SerializeField] private Color _fogColor = Color.white;
	[SerializeField] private float _fogStart = 0.0f;
	[SerializeField] private float _fogEnd = 2.0f;

	private Matrix4x4 _previousViewProjectMatrix;

	private RenderTexture _accumulationTexture;

	private Material _fogWithDepthTextureMat;
	public Material FogWithDepthTextureMat {
		get {
			_fogWithDepthTextureMat = CheckShaderAndCreateMaterial (_fogWithDepthTextureShader, _fogWithDepthTextureMat);
			return _fogWithDepthTextureMat;
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
		if (FogWithDepthTextureMat != null) {
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

			FogWithDepthTextureMat.SetMatrix ("_FrustumCornersRay", frustumCorners);

			FogWithDepthTextureMat.SetFloat ("_FogDensity", _fogDensity);
			FogWithDepthTextureMat.SetColor ("_FogColor", _fogColor);
			FogWithDepthTextureMat.SetFloat ("_FogStart", _fogStart);
			FogWithDepthTextureMat.SetFloat ("_FogEnd", _fogEnd);

			Graphics.Blit (src, dest, FogWithDepthTextureMat);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
