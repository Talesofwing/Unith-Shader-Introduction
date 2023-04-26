using System;
using System.Collections;
using System.Reflection;

using UnityEngine;
using UnityEditor;

[CustomPropertyDrawer (typeof (SetPropertyAttribute))]
public class SetPropertyDrawer : PropertyDrawer {

	public override void OnGUI (Rect position, SerializedProperty property, GUIContent label) {
		EditorGUI.BeginChangeCheck ();
		EditorGUI.PropertyField (position, property, label);

		SetPropertyAttribute setProperty = attribute as SetPropertyAttribute;
		if (EditorGUI.EndChangeCheck ()) {
			// 修改SerializedProperty時，實際字段還沒有設置為當前值
			// 直到此OnGUI調用完成。所以需要設置一個Dirty變量
			// 標記SerizliaedProperty發生了變化
			setProperty.IsDirty = true;
		} else if (setProperty.IsDirty) {
			object parent = GetParentObjectOfProperty (property.propertyPath, property.serializedObject.targetObject);
			Type type = parent.GetType ();
			PropertyInfo pi = type.GetProperty (setProperty.Name);
			if (pi == null) {
				Debug.LogError ("Invalied property name: " + setProperty.Name + "\nCheck your [SetProperty] attribute");
			} else {
				pi.SetValue (parent, fieldInfo.GetValue (parent), null);
			}
			setProperty.IsDirty = false;
		}
	}

	private object GetParentObjectOfProperty (string path, object obj) {
		string[] fields = path.Split ('.');

		if (fields.Length == 1) {
			return obj;
		}

		FieldInfo fi = obj.GetType ().GetField (fields[0], BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
		obj = fi.GetValue (obj);

		return GetParentObjectOfProperty (string.Join (".", fields, 1, fields.Length - 1), obj);
	}

}
