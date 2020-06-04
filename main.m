clearvars;
addpath('function/');
% data type
% 1 = New benchmark *.mat
% 2 = Old benchmark *.h5
  
data_type = 1;
algo_idx = 5;

depth_resolution = 75;
filename='boxes';

%% Generating disparity map
tic;
[disp1,output_path]=method(filename,data_type,algo_idx,depth_resolution);
toc;

%% Evaluation
mkdir(output_path);
pfmwrite(disp1,[output_path,filename,'.pfm']); 
[bpmap,gt]=evaluate(filename,data_type,disp1,0.07);%0.07 badpix threshold
imwrite(bpmap,[output_path,filename,'.png']);
figure;imshow((disp1-min(disp1(:)))/(max(disp1(:))-min(disp1(:))));
cutoff=15;
MSE = immse(disp1(cutoff+1:end-cutoff, cutoff+1:end-cutoff), gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff));
BadPix7 = sum(sum(abs(disp1(cutoff+1:end-cutoff, cutoff+1:end-cutoff) - gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff)) > 0.07))...
    ./ numel(gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff));