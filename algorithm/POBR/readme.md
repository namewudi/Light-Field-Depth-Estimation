
run **demo_run.m** for the calculation of disparity for the light field 
> - input: a ELSF format lenslet image with angular dimension 9x9 or any other odd angular dimension configurations : 5x5, 7x7 etc.
> - please mex the file dcCluesEstimate_mex.cpp first before running the code
> - output: dpOut1, which is the disparity in unit of pixels


The disparity error table (measured in percentage of pixels with error larger than 0.1 pixels) for the testing data from the HCI dataset.
<p align="center">
<img src="https://github.com/hotndy/LFDepth_POBR/blob/master/HCI_outputs/DpError0.1.png" width="800px"/>
</p>

Parameters used for these results are listed below:
<p align="center">
<img src="https://github.com/hotndy/LFDepth_POBR/blob/master/HCI_outputs/paramSettings.png" width="600px"/>
</p>

