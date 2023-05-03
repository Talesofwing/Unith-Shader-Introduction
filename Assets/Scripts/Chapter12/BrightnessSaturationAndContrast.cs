using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase {
	[SerializeField] private Shader _bscShader;
	[Range (0.0f, 3.0f)]
	[SerializeField] private float _brightness = 1.0f;
	[Range (0.0f, 3.0f)]
	[SerializeField] private float _saturation = 1.0f;
	[Range (0.0f, 3.0f)]
	[SerializeField] private float _contrast = 1.0f;

	private Material _bscMat;
	public Material BscMat {
		get {
			_bscMat = CheckShaderAndCreateMaterial (_bscShader, _bscMat);
			return _bscMat;
		}
	}

	private void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (BscMat != null) {
			BscMat.SetFloat ("_Brightness", _brightness);
			BscMat.SetFloat ("_Saturation", _saturation);
			BscMat.SetFloat ("_Contrast", _contrast);

			Graphics.Blit (src, dest, BscMat);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
