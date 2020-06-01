%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run this code for the calculation of depth for the light field 
% input: a ELSF format lenslet image with angular dimension 9x9 or any
% other odd angular dimension configurations : 5x5, 7x7 etc.
% please mex the file dcCluesEstimate_mex.cpp first before running the code
%
% output: dpOut1, which is the disparity in pixels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [spInfo]= lfdepthSP(LF_Remap,mParams)

spInfo= [];
spInfo= mParams;
clear mParams;

% reshape to more accessible format
for nr=1:spInfo.mAngDim
    for nc= 1:spInfo.mAngDim
        SV(:,:,:,nr,nc)= LF_Remap(nr:spInfo.mAngDim:end,nc:spInfo.mAngDim:end,:);
    end
end

[spInfo.mRow,spInfo.mCol,spInfo.nCC,~]= size(SV);
spInfo.centralView= SV(:,:,:,(spInfo.mAngDim+1)/2,(spInfo.mAngDim+1)/2);

%spInfo.d_max= 3;       % maximum disparity range [-spInfo.d_max,+spInfo.d_max]
%spInfo.d_res = 75;    % depth resolution
disp(sprintf('calculating dc clues...'));
[corresp_response, defocus_response] = dcCluesEstimate_mex(spInfo.mCol, spInfo.mRow, ...
        spInfo.mAngDim, double(LF_Remap), spInfo.d_min, spInfo.d_max, spInfo.d_res);
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

end