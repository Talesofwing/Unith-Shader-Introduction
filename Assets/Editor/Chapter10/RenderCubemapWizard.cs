using UnityEditor;
using UnityEngine;

public class RenderCubemapWizard : ScriptableWizard {
	[SerializeField] private Transform _renderFromPosition;
	[SerializeField] private Cubemap _cubemap;

	private void OnWizardUpdate () {
		helpString = "Select transform to render from and cubemap to render into";
		isValid = (_renderFromPosition != null) && (_cubemap != null);
	}

	private void OnWizardCreate () {
		// create temporary camera for rendering
		GameObject go = new GameObject ("CubemapCamera");
		go.AddComponent<Camera> ();
		// place it on the object
		go.transform.position = _renderFromPosition.position;
		// render into cubemap		
		go.GetComponent<Camera> ().RenderToCubemap (_cubemap);

		// destroy temporary camera
		DestroyImmediate (go);
	}

	[MenuItem ("GameObject/Render into Cubemap")]
	private static void RenderCubemap () {
		ScriptableWizard.DisplayWizard<RenderCubemapWizard> ("Render cubemap", "Render!");
	}

}