using UnityEngine;

public class Bloom : PostEffectsBase {
	[SerializeField] private Shader _bloomShader;

	// Blur iterations - larger number means more blur.
	[Range (0, 4)]
	[SerializeField] private int _iterations = 3;

	// Blur spread for each iteration - larger value means more blur
	[Range (0.2f, 3.0f)]
	[SerializeField] private float _blurSpread = 0.6f;

	[Range (1, 8)]
	[SerializeField] private int _downSample = 2;

	[Range (0.0f, 4.0f)]
	public float _luminanceThreshold = 0.6f;

	private Material _bloomMat;
	public Material BloomMat {
		get {
			_bloomMat = CheckShaderAndCreateMaterial (_bloomShader, _bloomMat);
			return _bloomMat;
		}
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (BloomMat != null) {
			BloomMat.SetFloat ("_LuminanceThreshold", _luminanceThreshold);

			int rtW = src.width / _downSample;
			int rtH = src.height / _downSample;

			RenderTexture buffer0 = RenderTexture.GetTemporary (rtW, rtH, 0);
			buffer0.filterMode = FilterMode.Bilinear;

			Graphics.Blit (src, buffer0, BloomMat, 0);

			for (int i = 0; i < _iterations; i++) {
				BloomMat.SetFloat ("_BlurSize", 1.0f + i * _blurSpread);

				RenderTexture buffer1 = RenderTexture.GetTemporary (rtW, rtH, 0);

				// Render the vertical pass
				Graphics.Blit (buffer0, buffer1, BloomMat, 1);

				RenderTexture.ReleaseTemporary (buffer0);
				buffer0 = buffer1;
				buffer1 = RenderTexture.GetTemporary (rtW, rtH, 0);

				// Render the horizontal pass
				Graphics.Blit (buffer0, buffer1, BloomMat, 2);

				RenderTexture.ReleaseTemporary (buffer0);
				buffer0 = buffer1;
			}

			BloomMat.SetTexture ("_Bloom", buffer0);
			Graphics.Blit (src, dest, BloomMat, 3);

			RenderTexture.ReleaseTemporary (buffer0);

		} else {
			Graphics.Blit (src, dest);
		}
	}

}
