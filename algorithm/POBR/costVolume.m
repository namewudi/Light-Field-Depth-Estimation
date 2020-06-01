function  disp1  = costVolume( LF,dmin,dmax,depth_resolution)

[S, T, H, W, N]=size(LF);

LF_Remap = reshape(permute(LF, [1 3 2 4 5]), [S*H T*W N]);

%% 2. Set LF angular dimension 
mParams.mAngDim= 9; % angular dimension, must be odd number
% disparity range and resolutions
% recommended setting: 
% For outputs from Lytro Illum: (3,101)
% For dataset with larger resolution such as HCI: (3,301)
mParams.d_max= dmax;
mParams.d_min= dmin;
mParams.d_res = depth_resolution; % depth resolution

% calculate SP clues
spInfo= lfDepthSP(LF_Remap, mParams);


%================
%% Suggestion
% a. You can set up a breakpint here, and try out different cwParams 
% configurations for the best outputs. 
% b. You don't need to re-run the whole program to test different cwParams,
% since "lfDepthSP" is the most time consuming. 
% c. Just "play with" different cwParams, and run from here. You'll find he
% pattern after a few trys.
%================
% 3. setup WLS regularization parameters
% this first parameter alpha affects the output the most, 
% try different ones for the best result [0.0001, 0.1]. 
%  eg. ImTest1.png alpha=0.1; ImTest2.png alpha=0.1;
spInfo.cwParams.alpha= 0.001; 
spInfo.cwParams.Th_minEstVar= 0.4; % dp variation region supression threshold
spInfo.cwParams.occEdgeEnforce= 5;
% spInfo.cwParams.lcwEdgeEnforce= 2;
spInfo.cwParams.Th_lcwEdgEnforce= 0.4;
% spInfo.cwParams.Th_textureSupress= 0;

% final regularization
[dpOut1]= cwManipulate(spInfo);figure;imshow(dpOut1,[]);
disp1 = (dpOut1-1)/(spInfo.d_res-1)*(mParams.d_max-mParams.d_min)+mParams.d_min;

end