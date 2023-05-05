using UnityEngine;

public class GaussianBlur : PostEffectsBase {
	[SerializeField] private Shader _gussianBlurShader;

	// Blur iterations - larger number means more blur.
	[Range (0, 4)]
	[SerializeField] private int _iterations = 3;

	// Blur spread for each iteration - larger value means more blur
	[Range (0.2f, 3.0f)]
	[SerializeField] private float _blurSpread = 0.6f;

	[Range (1, 8)]
	[SerializeField] private int _downSample = 2;

	private Material _gussianBlurMat;
	public Material GussianBlurMat {
		get {
			_gussianBlurMat = CheckShaderAndCreateMaterial (_gussianBlurShader, _gussianBlurMat);
			return _gussianBlurMat;
		}
	}

	// 1st edition: just apply blur
	// private void OnRenderImage (RenderTexture src, RenderTexture dest) {
	// 	if (GussianBlurMat != null) {
	// 		int rtW = src.width;
	// 		int rtH = src.height;
	// 		RenderTexture buffer = RenderTexture.GetTemporary (rtW, rtH, 0);

	// 		// Render the vertical pass
	// 		Graphics.Blit (src, buffer, GussianBlurMat, 0);
	// 		// Render the horizontal pass
	// 		Graphics.Blit (buffer, dest, GussianBlurMat, 1);

	// 		RenderTexture.ReleaseTemporary (buffer);
	// 	} else {
	// 		Graphics.Blit (src, dest);
	// 	}
	// }

	// 2nd edition: scale the render texture
	// private void OnRenderImage (RenderTexture src, RenderTexture dest) {
	// 	if (GussianBlurMat != null) {
	// 		int rtW = src.width / _downSample;
	// 		int rtH = src.height / _downSample;
	// 		RenderTexture buffer = RenderTexture.GetTemporary (rtW, rtH, 0);
	// 		buffer.filterMode = FilterMode.Bilinear;

	// 		// Render the vertical pass
	// 		Graphics.Blit (src, buffer, GussianBlurMat, 0);
	// 		// Render the horizontal pass
	// 		Graphics.Blit (buffer, dest, GussianBlurMat, 1);

	// 		RenderTexture.ReleaseTemporary (buffer);
	// 	} else {
	// 		Graphics.Blit (src, dest);
	// 	}
	// }

	// 3rd edition: use iterations for larger blur
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (GussianBlurMat != null) {
			int rtW = src.width / _downSample;
			int rtH = src.height / _downSample;

			RenderTexture buffer0 = RenderTexture.GetTemporary (rtW, rtH, 0);
			buffer0.filterMode = FilterMode.Bilinear;

			Graphics.Blit (src, buffer0);

			for (int i = 0; i < _iterations; i++) {
				GussianBlurMat.SetFloat ("_BlurSize", 1.0f + i * _blurSpread);

				RenderTexture buffer1 = RenderTexture.GetTemporary (rtW, rtH, 0);

				// Render the vertical pass
				Graphics.Blit (buffer0, buffer1, GussianBlurMat, 0);

				RenderTexture.ReleaseTemporary (buffer0);
				buffer0 = buffer1;
				buffer1 = RenderTexture.GetTemporary (rtW, rtH, 0);

				// Render the horizontal pass
				Graphics.Blit (buffer0, buffer1, GussianBlurMat, 1);

				RenderTexture.ReleaseTemporary (buffer0);
				buffer0 = buffer1;
			}

			Graphics.Blit (buffer0, dest);
			RenderTexture.ReleaseTemporary (buffer0);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
