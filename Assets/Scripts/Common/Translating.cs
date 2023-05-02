using UnityEngine;

public class Translating : MonoBehaviour {
	[SerializeField] private float _speed = 10.0f;
	[SerializeField] private Vector3 _startPoint = Vector3.zero;
	[SerializeField] private Vector3 _endPoint = Vector3.zero;
	[SerializeField] private Vector3 _lookAt = Vector3.zero;
	[SerializeField] private bool _pingpong = true;

	private Vector3 curEndPoint = Vector3.zero;

	private void Start () {
		transform.position = _startPoint;
		curEndPoint = _endPoint;
	}

	private void Update () {
		transform.position = Vector3.Slerp (transform.position, curEndPoint, Time.deltaTime * _speed);
		transform.LookAt (_lookAt);
		if (_pingpong) {
			if (Vector3.Distance (transform.position, curEndPoint) < 0.001f) {
				curEndPoint = Vector3.Distance (curEndPoint, _endPoint) < Vector3.Distance (curEndPoint, _startPoint) ? _startPoint : _endPoint;
			}
		}
	}

}
