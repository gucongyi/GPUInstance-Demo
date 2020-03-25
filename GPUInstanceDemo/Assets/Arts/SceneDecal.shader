// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "MyShader/SceneDecal"
{
    Properties
    {
        _MianCol("MainColor",color)=(1,1,1,1)
        _Brightness("Brightness",Range(1,5))=5
        [Toggle] _Gray("Gray",float)=0
        [Toggle] _Sketch("Sketch",float)=0
        _GrayColor("GrayColor",color)=(1,1,1,1)
        _SketchColor("SketchColor",color)=(0,0,0,1)
        _MainTex ("Texture", 2D) = "white" {}
        _DecalTex("DecalTex",2D)="white"{}
        _DecalCol("DecalCol",Color)=(1,1,1,1)
        _Snow("SnowPow",Range(0,0.5))=0
        [Toggle] _ShineSwitch("ShineSwitch",float)=1         //shine
        _ShineSpeed("ShineSpeed", Float) = 5                 //shine
		_ShineColor("ShineColor", Color) = (0,0,0,0)         //shine
        _Transition("Transition",range(0,1)) = 0
        _TransitionColor("TransitionColor",color)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
			#pragma multi_compile_instancing //这里,第一步

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2:TEXCOORD1;
                float3 normal:NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID //这里,第二步
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
                float3 color:COLOR;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
				float4 worldpos : TEXCOORD3;        //shine
				UNITY_VERTEX_INPUT_INSTANCE_ID //这里,第二步
            };

			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(float, _Brightness)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _DecalCol)
			UNITY_INSTANCING_BUFFER_END(Props)
			
			fixed4 _MianCol;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DecalTex;
            float4 _DecalTex_ST;

            fixed _Gray;
            fixed4 _GrayColor;
            fixed _Sketch;
            fixed4 _SketchColor;

            //fixed4 _DecalCol;
            fixed _Snow;

            fixed _ShineSwitch;        //shine
            fixed4 _ShineColor;        //shine
			fixed _ShineSpeed;         //shine
            fixed _Transition;
            fixed4 _TransitionColor;

            v2f vert (appdata v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v); //这里第三步
                UNITY_TRANSFER_INSTANCE_ID(v,o); //第三步
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float3 worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;        //shine
				o.worldpos.xyz = worldpos;                                       //shine
                o.normal = v.normal;                                             //shine
                o.worldpos.w = 0;                                                //shine
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2=TRANSFORM_TEX(v.uv2,_DecalTex);

                o.worldNormal=normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
				//调用使用UNITY_ACCESS_INSTANCED_PROP(Props, 属性名)
                o.color=_MianCol*UNITY_ACCESS_INSTANCED_PROP(Props, _Brightness)*saturate(dot(o.worldNormal,worldLightDir))*0.5+0.5+ambient;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				UNITY_SETUP_INSTANCE_ID(i); //最后一步
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2=tex2D(_DecalTex,i.uv2);
                half normalDir=dot(col2.rgb*i.worldNormal,fixed3(0,1,0));
                half snow=saturate((normalDir-lerp(1,-1,_Snow))/0.001);

                fixed3 finalColor=col.rgb*i.color;
                finalColor+=normalDir*UNITY_ACCESS_INSTANCED_PROP(Props, _DecalCol).rgb+snow*fixed3(1,1,1);

                fixed gray=0.2125*finalColor.r+0.7154*finalColor.g+0.0721*finalColor.b;
                fixed3 grayColor=fixed3(gray,gray,gray)*_GrayColor.rgb;

                finalColor=lerp(finalColor,grayColor,_Gray);
                finalColor=lerp(finalColor,_SketchColor.rgb,_Sketch);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                float ShineTime = sin(_Time.y * _ShineSpeed);                                               //shine
                float3 worldpos = i.worldpos.xyz;                                                           //shine
				float3 worldViewDir = UnityWorldSpaceViewDir(worldpos);                                     //shine
				worldViewDir = normalize(worldViewDir);                                                     //shine
				float NdotV = dot( i.normal, worldViewDir );                                                //shine
                float3 shinefinalColor = ( ( _ShineColor * ShineTime ) * ( 1.0 - NdotV ) ).rgb;             //shine
                float3 finalfinalColor = lerp(finalColor,finalColor + shinefinalColor,_ShineSwitch);        //shine
                float3 finalfinalfinalColor = lerp(finalfinalColor,_TransitionColor.rgb,_Transition);
                return fixed4(finalfinalfinalColor,1);
            }
            ENDCG
        }
    }
}
