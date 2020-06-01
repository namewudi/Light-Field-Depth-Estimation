function  disp  = costVolume( LF,dmin,dmax,depth_resolution)

param.r = 5; 
param.eps = 0.0001;
sigma=0.01;

[S,T,H,W,N] = size(LF);

%% Cost computation
disp=lf_pac(LF,dmax,dmin,H,W,S,T,N,depth_resolution,sigma,param);
end