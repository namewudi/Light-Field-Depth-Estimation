%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run this code for the calculation of depth for the light field 
% input: a ELSF format lenslet image with angular dimension 9x9 or any
% other odd angular dimension configurations : 5x5, 7x7 etc.
% please mex the file dcCluesEstimate_mex.cpp first before running the code
%
% output: dpOut1, which is the disparity in pixels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

% set input SAI dimensions and angular resolutions
mAngDim= 9; % must be odd number
LF_Remap= imread('ImTest2.png');

% setup final optimization parameters
% this first parameter alpha affects the output the most, 
% try different ones for the best result [0.0001, 0.1]. 
%  eg. ImTest1.png alpha=0.1; ImTest2.png alpha=0.1;
spInfo= [];
spInfo.cwParams.alpha= 0.1; 
spInfo.cwParams.Th_minEstVar= 0.2; % dp variation region supression threshold
spInfo.cwParams.occEdgeEnforce= 5;
spInfo.cwParams.lcwEdgeEnforce= 2;
spInfo.cwParams.Th_lcwEdgEnforce= 0.1;
spInfo.cwParams.Th_textureSupress= 0;

% reshape to more accessible format
for nr=1:mAngDim
    for nc= 1:mAngDim
        SV(:,:,:,nr,nc)= LF_Remap(nr:mAngDim:end,nc:mAngDim:end,:);
    end
end

spInfo.mAngDim= mAngDim;
[spInfo.mRow,spInfo.mCol,spInfo.nCC,~]= size(SV);
spInfo.centralView= SV(:,:,:,(spInfo.mAngDim+1)/2,(spInfo.mAngDim+1)/2);

spInfo.d_max= 3;       % maximum disparity range [-spInfo.d_max,+spInfo.d_max]
spInfo.d_res = 101;    % depth resolution
disp(sprintf('calculating dc clues...'));
[corresp_response, defocus_response] = dcCluesEstimate_mex(spInfo.mCol, spInfo.mRow, ...
        spInfo.mAngDim, double(LF_Remap), -spInfo.d_max, spInfo.d_max, spInfo.d_res);
% load([IN.fileFolder,IN.currFileName,'_dcClues.mat']);

[spInfo.dpIdxSPcor(:,:,1),spInfo.dpWeightSPcor(:,:,1)]= ...
                calPixelwise(corresp_response,defocus_response);
% figure;imshow(spInfo.dpIdxSPcor(:,:,1),[]);figure;imshow(spInfo.dpWeightSPcor(:,:,1),[]);
% dpOut_1 = wls_optimization({spInfo.dpIdxSPcor(:,:,1)}, {spInfo.dpWeightSPcor(:,:,1)} ,spInfo.centralView, 0.01);
% figure;imshow(dpOut_1,[]);

disp(sprintf('calculating SP features...'));
spInfo.spVec= [1,25]; % [1,25,50] for synthetic LF with larger disparities
spInfo.numPar= length(spInfo.spVec);
spInfo.dpRes= 1:(spInfo.d_res);
spInfo= calSPwise(spInfo.centralView,spInfo,corresp_response,spInfo.dpWeightSPcor);
% figure;imshow(spInfo.dpIdxSPcor(:,:,2),[]);
% figure;imshow(spInfo.dpIdxSPrefined(:,:,2),[]);

% final regularization
[dpOut1]= cwManipulate(spInfo); % figure;imshow(dpOut1,[]);
dpOutput= (dpOut1- (spInfo.d_res-1)/2)*(2*spInfo.d_max/(spInfo.d_res-1));
% figure;imshow(dpOutput,[]);
