using UnityEngine;

[RequireComponent (typeof (Camera))]
public class DepthNormalRenderer : PostEffectsBase {
	[SerializeField] private Shader _depthNormalShader;
	[SerializeField] private bool _linearDepthValue = true;
	[SerializeField] private bool _displayNormal = false;

	private Camera _camera;

	private Material _material;
	public Material Mat {
		get {
			_material = CheckShaderAndCreateMaterial (_depthNormalShader, _material);
			return _material;
		}
	}

	private void Awake () {
		_camera = GetComponent<Camera> ();

		// _camera.depthTextureMode |= DepthTextureMode.Depth;
		_camera.depthTextureMode |= DepthTextureMode.DepthNormals;
	}

	private void OnRenderImage (RenderTexture src, RenderTexture dest) {
		// DepthNormal.shader將場景的深度&法線渲染出來後的紋理處理
		if (Mat != null) {
			Mat.SetFloat ("_Linear", _linearDepthValue ? 1 : 0);
			Mat.SetFloat ("_NormalFactor", _displayNormal ? 1 : 0);
			Graphics.Blit (src, dest, Mat);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
