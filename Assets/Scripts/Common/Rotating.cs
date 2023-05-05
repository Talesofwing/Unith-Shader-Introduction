using UnityEngine;

public class Rotating : MonoBehaviour {
	[SerializeField] private float speed = 10.0f;

	private void Update () {
		float angle = Time.deltaTime * speed;
		transform.Rotate (new Vector3 (angle, angle, angle));
	}

}
