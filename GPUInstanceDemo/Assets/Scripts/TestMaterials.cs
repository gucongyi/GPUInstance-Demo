using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMaterials : MonoBehaviour
{
    public GameObject goPrefab;
    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < 10; i++)
        {
            GameObject go = GameObject.Instantiate(goPrefab);
            go.transform.parent = transform;
            go.transform.localPosition = new Vector3(0,i-3f,0);
            int randomInt = i;
            randomInt = Mathf.Clamp(randomInt, 1, 5);
            float r = Random.Range(0.3f,1f);
            float g = Random.Range(0, 1);
            float b = Random.Range(0.5f, 1);
            Color color = new Color(r, g, b);
            //使用MaterialPropertyBlock来修改shader的实例化变化的值
            MaterialPropertyBlock block = new MaterialPropertyBlock();
            int brightnessID = Shader.PropertyToID("_Brightness");
            block.SetFloat(brightnessID, randomInt);
            int colorID = Shader.PropertyToID("_DecalCol");
            block.SetColor(colorID, color);
            go.GetComponent<MeshRenderer>().SetPropertyBlock(block);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
