# **Light Field depth estimation**

This implement  contain some light field depth estimation method.

## How to use

 [dataset download link](https://drive.google.com/file/d/1IE5EBewV1K1qs01JSomGFBCKwCNKryEL/view?usp=sharing)

Run main.m 

(This software is tested using Matlab 2016a with Windows 10 64bit environment)

### parameter *data_type* select dataset.

*data_type*= 1 New benchmark dataset

```Paper to cite
Honauer, Katrin, Ole Johannsen, Daniel Kondermann and Bastian Goldluecke. A Dataset and Evaluation Methodology for Depth Estimation on 4D Light Fields[C]// Asian Conference on Computer Vision. Springer, Cham, 2016: 19-34.
```

*data_type* = 2 Old benchmark dataset

```Paper to cite
Wanner, Sven, Stephan Meister and Bastian Goldluecke. Datasets and Benchmarks for Dens-ely Sampled 4D Light Fields [C] // Proceedings of the 18th International Workshop on Vision, Modeling and Visualization. Lugamo Switzerland: The Eurographics Association, 2013: 225-226.
```

### parameter *algo_idx* select the method to operate.

*algo_idx* = 1 CAE

```Paper to cite
Robust Light Field Depth Estimation for Noisy Scene with Occlusion, CVPR 2016
Robust Light Field Depth Estimation using Occlusion-Noise Aware Data Costs, PAMI 2017
```

​					2 SPO          Code written by me

```Paper to cite
Shuo Zhang, Hao Sheng, Chao Li, Jun Zhang and Zhang Xiong.  
Robust depth estimation for light field via spinning parallelogram operator, 
Computer Vision and Image Understanding, 2016, 145(C), 148-159
```

​					3 IGF            Code written by me

```Paper to cite
Sheng, Hao, et al. "Geometric occlusion analysis in depth estimation using integral guided filter for light-field image." IEEE Transactions on Image Processing 26.12 (2017): 5758-5771.
```

​					4 LF_PAC     Code written by me	

```Paper to cite
Guo Zhenghua, Junlong Wu, Xianfeng Chen, Shuai Ma, Licheng Zhu, Ping Yang and Bing Xu. Accurate Light Field Depth Estimation Using Multi-Orientation Partial Angular Coherence[J]// IEEE Access 7 2019: 169123-169132.	
```

​					5 MBM         Code written by me

```Paper to cite
Shuo Zhang, Hao Sheng, Da Yang, Jun Zhang and Zhang Xiong,
Micro-lens-based Matching for Scene Recovery in Lenslet Cameras, 
IEEE Transactions on Image Processing, 2018, 27(3), 1060-1075
```

​					6 POBR

```Paper to cite
J. Chen, J. Hou, Y. Ni, and  L.-P. Chau, Accurate light field depth estimation with superpixel regularization over partially occluded regions. IEEE Transactions on Image Processing.
```

​					7 LF 

```Paper to cite
Accurate Depth Map Estimation from a Lenslet Light Field Camera, CVPR 2015
```

​					8 LF_DC

```Paper to cite
Michael W. Tao, Sunil Hadap, Jitendra Malik, and Ravi Ramamoorthi. Depth
from Combining Defocus and Correspondence Using Light-Field Cameras. In Proceedings of International Conference on Computer Vision (ICCV), 2013.
```

​					9 LF_OCC

```Paper to cite
Ting-Chun Wang, Alexei A. Efros, and Ravi Ramamoorthi.
Occlusion-aware depth estimation using light-field cameras. 
In Proceedings of International Conference on Computer Vision (ICCV), 2015.
```

## Note

This package also includes part of following softwares
gco-v3.0: Multi-label optimization (http://vision.csd.uwo.ca/code/)
Fast cost volume filtering: (https://www.ims.tuwien.ac.at/publications/tuw-210567)
Fast weighted median filter: (http://www.cse.cuhk.edu.hk/~leojia/projects/fastwmedian/index.htm)



