function [spInfo]= calSPwise(Iv, spInfo, corResp, cw)

[mWid, mLen, nCC]= size(Iv);
spInfo.dpIdxSP= zeros(mWid,mLen,spInfo.numPar);
spInfo.dpValSP= zeros(mWid,mLen,spInfo.numPar);

spNumVec= round((mWid*mLen)./spInfo.spVec);

dpIdxSPcor_t= zeros(1,mWid*mLen);
dpValSPcor_t= zeros(1,mWid*mLen);
dpWeightSPcor_t= zeros(1,mWid*mLen);
% dpIdxSPdef_t= zeros(1,mWid*mLen);
% dpValSPdef_t= zeros(1,mWid*mLen);
% dpWeightSPdef_t= zeros(1,mWid*mLen);

% corResp= corResp.*repmat(cw,1,1,length(spInfo.dpRes));
% defResp= defResp.*repmat(dw,1,1,length(spInfo.dpRes));
IdxPelpCor= spInfo.dpIdxSPcor(:,:,1);
WeightPelpCor= spInfo.dpWeightSPcor(:,:,1);

ScorePelpCor= reshape(corResp,[],length(spInfo.dpRes));
% ScorePelpDef= reshape(defResp,[],length(spInfo.dpRes));

% fprintf('\nCalculating initial SP estimates: ');
showCount= 0;
% msg= sprintf('Preparing particles.');
% h= waitbar(0, msg);

% im_edge = edge(Iv(:,:,1), 'canny') | edge(Iv(:,:,2), 'canny') | edge(Iv(:,:,3), 'canny');
% dpEdge = edge(spInfo.dpIdxSPcor(:,:,1), 'canny');
[Gx,Gy]= gradient(double(spInfo.dpIdxSPcor(:,:,1)));
dpSurface= ((Gx.^2+Gy.^2)<10);
chosenSP= zeros(mWid,mLen);

for nx= 2:spInfo.numPar    
    
    [spInfo.spIm(:,:,nx),spInfo.numSP(nx)]= slicmex(im2uint8(Iv),spNumVec(nx),15);
    
    [Gx,Gy]= gradient(double(spInfo.spIm(:,:,nx)));
    spBondary= ((Gx.^2+Gy.^2)~=0);
    
%     bondaryPixels= (~spBondary).*dpEdge;
    
    for np=1:spInfo.numSP(nx)

        currIdxSP= find(spInfo.spIm(:,:,nx)==(np-1));
        % correspondence clues
        highConfIdx= find(cw(currIdxSP)>0.95); % high conf pixels to be used for depth calculation
        if(length(highConfIdx)==0)
            [maxConfVal,highConfIdx]= max(cw(currIdxSP));
        end
        % currResp= med(ScorePelpCor(currIdxSP(maxConfIdx),:),1);
        % [confVal1,dpIdx]= min(currResp);
        dpIdx= median(IdxPelpCor(currIdxSP(highConfIdx)));
        dpIdxSPcor_t(currIdxSP)=dpIdx;
        dpWeightSPcor_t(currIdxSP)= median(WeightPelpCor(currIdxSP(highConfIdx)));
        % dpWeightSPcor_t(currIdxSP)=min(1,max(0,confVal2./confVal1- minPeakRatio)*(1- minScaled)/...
        %                       (maxPeakRatio-minPeakRatio)+ minScaled); 
        currDpAlt=(abs(IdxPelpCor(currIdxSP)- dpIdx)>(0.3*length(spInfo.dpRes)));
        errAltNum= length(find(dpSurface(currIdxSP).*currDpAlt)); % altered depth that shouldn't have happened over smooth regions
        
        chosenSP(currIdxSP)=errAltNum;
        if(errAltNum>(0.1*length(currIdxSP)))            
            dpIdxSPcor_t(currIdxSP)= IdxPelpCor(currIdxSP);
            dpWeightSPcor_t(currIdxSP)= 1; % WeightPelpCor(currIdxSP);
        end
        
        numSPshow= round(0.1*spInfo.numSP(nx));
        if(double(np)/double(numSPshow)== floor(double(np)/double(numSPshow)))
            % waitbar(double(np)/double(spInfo.numSP(nx)),h,msg);
            fprintf(repmat('\b',[1,showCount]));
            showCount= fprintf('Calculating initial SP estimates: %.0f%%',100*double(np)/double(spInfo.numSP(nx)));
        end
           
        % fprintf(repmat('\b',[1,showCount]));
        % showCount= fprintf('Calculating initial SP estimates: %.1f%%',100*np/spInfo.numSP(nx));
        % msg= sprintf('Preparing particle %d/%d...',nx,spInfo.numPar);
        % waitbar(np/spInfo.numSP(nx),h,msg);
    end
    spInfo.dpIdxSPcor(:,:,nx)= reshape(dpIdxSPcor_t,mWid,mLen); 
    spInfo.dpWeightSPcor(:,:,nx)= reshape(dpWeightSPcor_t,mWid,mLen);
    
 end
% delete(h);
fprintf(repmat('\b',[1,showCount]));
showCount= 0;

% refine SP via neighborhood connections
spInfo= calSPrefine(Iv, spInfo);


end



function spInfo= calSPrefine(Iv, spInfo, lambda)

small_num = 0.00001;

if ~exist('lambda','var') || isempty(lambda), lambda = 0.05; end

if(max(Iv(:))>1)
    Iv= double(Iv)/255;
end
[mWid, mLen, nCC]= size(Iv);

% msg= sprintf('Preparing particles.');
% h= waitbar(0, msg);

% Compute affinities between adjacent pixels based on gradients of guidance
% hsv= rgb2hsv(Iv);
% Iv(:,:,3)= Iv(hsv(:,:,3));
[Gx,Gy]= gradient(rgb2gray(Iv));
% [Gx,Gy]= gradient(spInfo.dpIdxSPcor(:,:,1)/length(spInfo.dpRes));
dxy = -lambda./(sum(Gx.^2+ Gy.^2,3) + small_num);

data_weight= spInfo.dpWeightSPcor(:,:,1);
Adata= spdiags(data_weight(:),0, mWid*mLen, mWid*mLen);
% Adata= spdiags(ones(mWid*mLen,1),0, mWid*mLen, mWid*mLen);

spInfo.dpIdxSPrefined(:,:,1)= spInfo.dpIdxSPcor(:,:,1);
in= spInfo.dpIdxSPcor(:,:,1);

for nx= 2:spInfo.numPar 
    % msg= sprintf('Preparing particles: Level %d/%d',nx,spInfo.numPar);    
    % waitbar(0,h,msg);
    
    currSpIm= double(spInfo.spIm(:,:,nx));
    [Gx,Gy]= gradient(double(currSpIm));
    spBondary= ((Gx.^2+Gy.^2)~=0);
    
    % figure;imshow(~spBondary.*double(spInfo.spIm(:,:,nx)));
    % figure;imshow(repmat(~spBondary,1,1,3).*Iv);
    % figure;imshow(~spBondary.*spInfo.dpIdxSPcor(:,:,nx)/101);
    % figure;imshow(~spBondary.*spInfo.dpIdxSPcor(:,:,1)/101);
    
    Asmoothness= sparse(double(spInfo.numSP(nx)),double(spInfo.numSP(nx)));
    Qdata= sparse(mWid*mLen,double(spInfo.numSP(nx)));
    dpIdxSP_t= zeros(mWid,mLen);
    
    showCount= 0;   
    for np=1:spInfo.numSP(nx)
%         if(np== 969+1)
%             np= 969+1;
%         end
        currMask= (currSpIm==(np-1));
        currIdxSP= find(currSpIm==(np-1));
        currMaskEx= imdilate(currMask,strel('square',3)); % dilated by one pixel
               
        %% accumarray method
        currNbMask= currMaskEx.*(1+currSpIm).*(~currMask);
        currNbLoc= find(currNbMask~=0);            
        edgeItensityVec= accumarray(currNbMask(currNbLoc),dxy(currNbLoc),[spInfo.numSP(nx),1]);        
        Asmoothness(np,:)= edgeItensityVec;
        Asmoothness(np,np)= Asmoothness(np,np)- sum(edgeItensityVec);               
        %{ 
        %% Exhaustive method
        spNbIdx= unique(currSpIm(find((~currMask).*currMaskEx))); 
        for nb= 1:length(spNbIdx)
            % find the border location. 
            currNbIdx=find((currSpIm== spNbIdx(nb)).*currMaskEx);
            currEdgeIntensity= sum(dxy(currNbIdx));
            % for a certain SP (row of Asmoothness), the edge influence
            % from other SPs (cols fo Asmoothness).
            Asmoothness(np,np)= Asmoothness(np,np)- currEdgeIntensity; % positive for the current center SP
            Asmoothness(np,spNbIdx(nb)+1)= currEdgeIntensity;
        end
        %}        
        Qdata(currIdxSP,np)=1;
              
        numSPshow= round(0.1*spInfo.numSP(nx));
        if(double(np)/double(numSPshow)== floor(double(np)/double(numSPshow)))
            % waitbar(double(np)/double(spInfo.numSP(nx)),h,msg);
            fprintf(repmat('\b',[1,showCount]));
            showCount= fprintf('Reuglarizing SP neighborhood: %.0f%%',100*double(np)/double(spInfo.numSP(nx)));

        end
    end
    
%     in= spInfo.dpIdxSPcor(:,:,nx);
%     Adata= spdiags(reshape(spInfo.dpWeightSPajust(:,:,nx),[],1),0, mWid*mLen, mWid*mLen);
%     Adata= spdiags(ones(mWid*mLen,1),0, mWid*mLen, mWid*mLen);

    % At= 0.001*Asmoothness./double(mWid*mLen/spInfo.numSP(nx));
    At= Asmoothness./double(mWid*mLen);
    A = Qdata'*Adata*Qdata +  At; % Asmoothness;
    b = Qdata'*Adata*in(:);
    
    Id= A\b;
    
    for np=1:spInfo.numSP(nx)
        currIdxSP= find(currSpIm==(np-1));
        dpIdxSP_t(currIdxSP)= Id(np);        
    end
    spInfo.dpIdxSPrefined(:,:,nx)= dpIdxSP_t;
    % figure;imshow(spInfo.dpIdxSPrefined(:,:,nx),[]);
    % figure;imshow(spInfo.dpIdxSPcor(:,:,nx),[]);
end
% delete(h);
fprintf(repmat('\b',[1,showCount]));

end