using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BurnHelper : MonoBehaviour {
    [SerializeField] private Material _material;
    [Range (0.01f, 1.0f)]
    [SerializeField] private float _burnSpeed = 0.3f;
    [SerializeField] private float _burnAmount = 0.0f;

    private void Start () {
        if (_material == null) {
            Renderer renderer = gameObject.GetComponentInChildren<Renderer> ();
            if (renderer != null) {
                _material = renderer.material;
            }
        }

        if (_material == null) {
            this.enabled = false;
        } else {
            _material.SetFloat ("_BurnAmount", 0.0f);
        }
    }

    private void Update () {
        _burnAmount = Mathf.Repeat (Time.time * _burnSpeed, 1.0f);
        _material.SetFloat ("_BurnAmount", _burnAmount);
    }

}
