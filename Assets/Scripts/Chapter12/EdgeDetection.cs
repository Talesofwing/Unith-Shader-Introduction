using UnityEngine;

public class EdgeDetection : PostEffectsBase {
	[SerializeField] private Shader _edgeDetecterShader;
	[Range (0, 1)]
	[SerializeField] private float _edgesOnly = 0.0f;
	[SerializeField] private Color _edgeColor = Color.black;
	[SerializeField] private Color _backgroundColor = Color.white;

	private Material _edgeDetecterMat;
	public Material EdgeDetecterMat {
		get {
			_edgeDetecterMat = CheckShaderAndCreateMaterial (_edgeDetecterShader, _edgeDetecterMat);
			return _edgeDetecterMat;
		}
	}

	private void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (EdgeDetecterMat != null) {
			EdgeDetecterMat.SetFloat ("_EdgeOnly", _edgesOnly);
			EdgeDetecterMat.SetColor ("_EdgeColor", _edgeColor);
			EdgeDetecterMat.SetColor ("_BackgroundColor", _backgroundColor);

			Graphics.Blit (src, dest, EdgeDetecterMat);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
