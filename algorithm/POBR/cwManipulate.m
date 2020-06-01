function [dpOut1]= cwManipulate(spInfo)

spInfo.cwParams.lcwEdgeEnforce= 2;
spInfo.cwParams.Th_textureSupress= 0;

cw= spInfo.dpWeightSPcor(:,:,1);
centralView= im2double(spInfo.centralView);

% 1. low confidence occlusion border shrinkage
dpDiff= spInfo.dpIdxSPcor(:,:,1)-spInfo.dpIdxSPrefined(:,:,2); % figure;imshow(dpDiff);
dpStretch= (dpDiff<0)*2./(1+exp(-dpDiff))+ (dpDiff>=0);
% figure;imshow(dpStretch);

% 2. high confidece intricate structure preservation
hcMask= spInfo.dpWeightSPcor(:,:,1)>0.5; 
x= (~imopen(hcMask,strel('square',5))).*hcMask; % figure;imshow(x);
dpStretch= (~x).*dpStretch+ x; % figure;imshow(dpStretch);

% 3. high est. variation region supression
estVar = stdfilt(spInfo.dpIdxSPcor(:,:,1)/spInfo.d_res,ones(3,3));
estVar= estVar/min(max(estVar(:)),10*median(estVar(:)));
Th_minEstVar= spInfo.cwParams.Th_minEstVar; % 0.1, 0.2
stimes= 10000; % stimes=10000;
estVarStretch= (estVar<=Th_minEstVar)+ (estVar>Th_minEstVar)*2./(1+exp(stimes*(estVar- Th_minEstVar))); 
% figure;imshow(estVarStretch);

cwn= cw.*dpStretch.*estVarStretch;


%% edge confidence manipulation
occEdgeShrinkage= ones(size(cw,1),size(cw,2));
% Th_minResp= 1.5;
% occEdgeShrinkage= (spInfo.minResp<Th_minResp)*2./(1+exp(-1*(spInfo.minResp-Th_minResp)))+ (spInfo.minResp>=Th_minResp);
occEdgeEnforce= spInfo.cwParams.occEdgeEnforce; %5
lcwEdgeEnforce= spInfo.cwParams.lcwEdgeEnforce; % 2;
occEdgeShrinkage= occEdgeShrinkage.*(dpStretch<1).*(1+occEdgeEnforce*cos(pi*dpStretch/2))+...
                    occEdgeShrinkage.*(dpStretch>=1);
                
Th_lcwEdgEnforce= spInfo.cwParams.Th_lcwEdgEnforce; % 0.1
occEdgeShrinkage= occEdgeShrinkage.*(cw<Th_lcwEdgEnforce).*(1+lcwEdgeEnforce*cos(pi*cw/2))+...
                    occEdgeShrinkage.*(cw>=Th_lcwEdgEnforce);
spInfo.occEdge= occEdgeShrinkage; 
% figure; imshow(occEdgeShrinkage);
% figure; imshow(spInfo.occEdge/5);

% % figure;imshow(dataIn/301)

Th_textureSupress= spInfo.cwParams.Th_textureSupress; %0;
[dpOut1,gradIn] = wls_optimization({spInfo.dpIdxSPcor(:,:,1)}, {cwn} ,...
        centralView, spInfo.cwParams.alpha, spInfo.occEdge, Th_textureSupress);
dpOut1(dpOut1>length(spInfo.dpRes))=length(spInfo.dpRes);
dpOut1(dpOut1<0)=0;
% figure;imshow([gradIn,gradIn.*spInfo.occEdge]);

end