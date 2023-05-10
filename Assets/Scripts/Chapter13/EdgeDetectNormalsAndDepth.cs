using UnityEngine;

public class EdgeDetectNormalsAndDepth : PostEffectsBase {
	[SerializeField] private Shader _edgeDetectionShader;

	[Range (0.0f, 1.0f)]
	[SerializeField] private float _edgesOnly = 0.0f;
	[SerializeField] private Color _edgeColor = Color.black;
	[SerializeField] private Color _backgroundColor = Color.white;
	[SerializeField] private float _sampleDistance = 1.0f;
	[SerializeField] private float _sensitivityDepth = 1.0f;
	[SerializeField] private float _sensitivityNormals = 1.0f;

	private Material _edgeDetectionMat;
	public Material EdgeDetectionMat {
		get {
			_edgeDetectionMat = CheckShaderAndCreateMaterial (_edgeDetectionShader, _edgeDetectionMat);
			return _edgeDetectionMat;
		}
	}

	private void OnEnable () {
		Cam.depthTextureMode |= DepthTextureMode.DepthNormals;
	}

	[ImageEffectOpaque]
	private void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (EdgeDetectionMat != null) {
			EdgeDetectionMat.SetFloat ("_EdgeOnly", _edgesOnly);
			EdgeDetectionMat.SetColor ("_EdgeColor", _edgeColor);
			EdgeDetectionMat.SetColor ("_BackgroundColor", _backgroundColor);
			EdgeDetectionMat.SetFloat ("_SampleDistance", _sampleDistance);
			EdgeDetectionMat.SetVector ("_Sensitivity", new Vector4 (_sensitivityNormals, _sensitivityDepth, 0.0f, 0.0f));

			Graphics.Blit (src, dest, EdgeDetectionMat);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
