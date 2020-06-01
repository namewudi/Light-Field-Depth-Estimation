function  disp  = costVolume( LF,dmin,dmax,depth_resolution)
sigma_w=0.5;
sigma_c=0.24;

[~, T, ~, ~, ~] = size(LF);
UV_diameter = T;
UV_center = round(UV_diameter/2);
central_img=squeeze(LF(UV_center,UV_center,:,:,:));

weight=integral_guided_filter(LF,dmin,dmax,sigma_w);
E1=cost_function(LF,weight,depth_resolution,dmin,dmax,sigma_c);

E1=(E1-min(E1(:)))/(max(E1(:)-min(E1(:))));

param.r = 7;            
param.eps = 0.0001;
E2 = CostAgg(E1,central_img,param);
[~,label]=min(E2,[],3);
disp = (label-1)/(depth_resolution-1)*(dmax-dmin)+dmin;

end
