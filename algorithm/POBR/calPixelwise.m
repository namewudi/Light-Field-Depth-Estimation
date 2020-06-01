function [dpCorIdx,cw]= calPixelwise(corresp_response,defocus_response)

[mRow,mCol,~]= size(corresp_response);

[~,dpCorIdx]= min(corresp_response,[],3); % figure;imshow(dpCorIdx,[]);
% [~,dpDefIdx]= min(defocus_response,[],3); % figure;imshow(dpDefIdx/101);

tmpVal= reshape(corresp_response,mRow*mCol,[]);
[confVal1,~] = min(tmpVal,[],2);
minResp= reshape(confVal1,mRow,mCol); 
confVal2= mean(tmpVal,2);
meanResp= reshape(confVal2,mRow,mCol); 
corWeight= meanResp./minResp; % figure;imshow(corWeight/10);
nanIdx= find(isnan(corWeight));
corWeight(nanIdx)= 0.00001;

% tmpVal= reshape(defocus_response,mRow*mCol,[]);
% [confVal1,~] = min(tmpVal,[],2);
% confVal2= mean(tmpVal,2);
% defWeight= reshape(confVal2./confVal1,mRow,mCol); % figure;imshow(defWeight/10);

confMaxVal= max(min(max(corWeight(:)),5*median(corWeight(:)))); % ,...
% min(max(defWeight(:)),5*median(defWeight(:))));

cw= corWeight/confMaxVal;
cw(cw>1)= 1; % figure;imshow(cw);
% dw= defWeight/confMaxVal;
% dw(dw>1)=1; % figure;imshow(dw);

end