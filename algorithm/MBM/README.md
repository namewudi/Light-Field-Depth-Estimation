# Micro-lens-based-Matching-for-Scene-Recovery
Micro-lens-based Matching for Scene Recovery in Lenslet Cameras 

CONTACT: [Shuo Zhang](https://shuozh.github.io/)  
(zhangshuo@bjtu.edu.cn or shuo.zhang@buaa.edu.cn)

Any scientific work that makes use of our code should appropriately
mention this in the text and cite our TIP2019 paper. For commercial
use, please contact us.

### PAPER TO CITE:

Shuo Zhang, Hao Sheng, Da Yang, Jun Zhang and Zhang Xiong,
Micro-lens-based Matching for Scene Recovery in Lenslet Cameras, 
IEEE Transactions on Image Processing, 2018, 27(3), 1060-1075

### BIBTEX TO CITE:

  @article{Zhang2016Robust,  
    title={Micro-lens-based Matching for Scene Recovery in Lenslet Cameras},  
    author={Zhang, Shuo and Sheng, Hao and Yang, Da and Zhang, Jun and Xiong, 
 		  Zhang},  
    journal={IEEE Transactions on Image Processing},  
    volume={27},  
    pages={1060-1075},  
    year={2018},  
    } 

### Note:

This package also includes part of following softwares  
[Fast cost volume filtering](https://www.ims.tuwien.ac.at/publications/tuw-210567)

### How to use:

Run demo.m  
(This software is tested using Matlab 2013a with Windows 7 64bit environment)

input: Complete light field image, where x,y changes in the angular domain firstly and the spatial domain secondly.

The image pre-processing calculation method for CVIA dataset input is provided. Other example input images from [HCI 4D Light Field Dataset](http://lightfieldgroup.iwr.uni-heidelberg.de/?page_id=713) and [4D Light Field Dataset (CVIA Konstanz & HCI Heidelberg)](http://hci-lightfield.iwr.uni-heidelberg.de/) can be found at: https://drive.google.com/drive/folders/0B5JdDRk-RkPXTEJDdmhuRWUyVkU?usp=sharing 

### Instructions for depth_opt.m: 
opts.NumView : Angular Resolution of Light Field

opts.Dmin : Minimum disparity between two adjacent view × (opts.NumView-1)/2; If unknown，opts.Dmin can be set as -1.5×(opts.NumView-1)/2 for Lytro images;

opts.Dmax—— Maximum disparity between two adjacent view × (opts.NumView-1)/2; If unknown，opts.Dmax can be set as 1.5×(opts.NumView-1)/2 for Lytro images;

### Time log:

2019.04.08 The package released.
