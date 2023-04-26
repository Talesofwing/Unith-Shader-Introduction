using UnityEngine;

public class SetPropertyAttribute : PropertyAttribute {
	public string Name { get; private set; }
	public bool IsDirty { get; set; }       // 是否有更新

	public SetPropertyAttribute (string name) {
		this.Name = name;
	}

}