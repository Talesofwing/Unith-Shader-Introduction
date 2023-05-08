using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase {
	[SerializeField] private Shader _motionBlurShader;
	[Range (0.0f, 1.0f)]
	[SerializeField] private float _blurSize = 0.5f;

	private Matrix4x4 _previousViewProjectMatrix;

	private RenderTexture _accumulationTexture;

	private Material _motionBlurMat;
	public Material MotionBlurMat {
		get {
			_motionBlurMat = CheckShaderAndCreateMaterial (_motionBlurShader, _motionBlurMat);
			return _motionBlurMat;
		}
	}

	private void OnEnable () {
		Cam.depthTextureMode |= DepthTextureMode.Depth;

		_previousViewProjectMatrix = Cam.projectionMatrix * Cam.worldToCameraMatrix;
	}

	private void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (MotionBlurMat != null) {
			MotionBlurMat.SetFloat ("_BlurSize", _blurSize);

			MotionBlurMat.SetMatrix ("_PreviousViewProjectionMatrix", _previousViewProjectMatrix);
			Matrix4x4 currentViewProjectMatrix = Cam.projectionMatrix * Cam.worldToCameraMatrix;
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectMatrix.inverse;
			MotionBlurMat.SetMatrix ("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			_previousViewProjectMatrix = currentViewProjectMatrix;

			Graphics.Blit (src, dest, MotionBlurMat);
		} else {
			Graphics.Blit (src, dest);
		}
	}

}
