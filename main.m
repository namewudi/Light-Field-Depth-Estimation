clearvars;

% data type
% 1 = New benchmark *.mat
% 2 = Old benchmark *.h5
  
data_type = 1;
algo_idx = 1;

depth_resolution = 50;
filename='dino';

%% Generating disparity map
tic;
disp=method(filename,data_type,algo_idx,depth_resolution);
toc;

%% Evaluation
gt=groundTruth(filename,data_type);
figure;imshow((disp-min(disp(:)))/(max(disp(:))-min(disp(:))));
cutoff=15;
MSE = immse(disp(cutoff+1:end-cutoff, cutoff+1:end-cutoff), gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff));
BadPix7 = sum(sum(abs(disp(cutoff+1:end-cutoff, cutoff+1:end-cutoff) - gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff)) > 0.07))...
    ./ numel(gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff));