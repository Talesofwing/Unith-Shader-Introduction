using UnityEngine;

public class MotionBlur : PostEffectsBase {
	[SerializeField] private Shader _motionBlurShader;
	[Range (0.0f, 0.9f)]
	[SerializeField] private float _BlurAmount = 0.5f;

	private RenderTexture _accumulationTexture;

	private void OnDisable () {
		DestroyImmediate (_accumulationTexture);
	}

	private Material _motionBlurMat;
	public Material MotionBlurMat {
		get {
			_motionBlurMat = CheckShaderAndCreateMaterial (_motionBlurShader, _motionBlurMat);
			return _motionBlurMat;
		}
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (MotionBlurMat != null) {
			// Create the accumulation texture
			if (_accumulationTexture == null || _accumulationTexture.width != src.width || _accumulationTexture.height != src.height) {
				DestroyImmediate (_accumulationTexture);
				_accumulationTexture = new RenderTexture (src.width, src.height, 0);
				_accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
				Graphics.Blit (src, _accumulationTexture);
			}

			// We are accumulating motion over frames without clear/discard
			// by design, so silence any performance warnings from Unity
			// _accumulationTexture.MarkRestoreExpected ();

			MotionBlurMat.SetFloat ("_BlurAmount", 1.0f - _BlurAmount);

			Graphics.Blit (src, _accumulationTexture, MotionBlurMat);
			Graphics.Blit (_accumulationTexture, dest);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
