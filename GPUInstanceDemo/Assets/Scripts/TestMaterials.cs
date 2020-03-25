using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMaterials : MonoBehaviour
{
    public GameObject goPrefab;
    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < 10000; i++)
        {
            GameObject go = GameObject.Instantiate(goPrefab);
            go.transform.parent = transform;
            int randomInt = i;
            randomInt = Mathf.Clamp(randomInt, 1, 5);
            //使用MaterialPropertyBlock来修改shader的实例化变化的值
            MaterialPropertyBlock block = new MaterialPropertyBlock();
            int brightnessID = Shader.PropertyToID("_Brightness");
            block.SetFloat(brightnessID, randomInt);
            go.GetComponent<MeshRenderer>().SetPropertyBlock(block);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
