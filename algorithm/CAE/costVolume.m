function  disp  = costVolume( LF,dmin,dmax,depth_resolution)

% datacost type
% 1 = constrained adaptive defocus cost [Williem PAMI2017]
% 2 = constrained angular entropy cost [Williem PAMI2017]
% 3 = angular entropy cost [Williem CVPR2016]
% 4 = adaptive defocus cost [Williem CVPR2016]
datacost_type = 2;

[uRes,vRes,yRes,xRes,~]=size(LF);

UV_diameter = uRes;
UV_center = round(UV_diameter/2);
UV_radius = UV_center - 1;
UV_size = UV_diameter^2;
LF_y_size = yRes * vRes;
LF_x_size = xRes * uRes;
        
LF_parameters       = struct('LF_x_size',LF_x_size,...
                             'LF_y_size',LF_y_size,...
                             'xRes',xRes,...
                             'yRes',yRes,...
                             'UV_radius',double(UV_radius),...
                             'UV_diameter',double(UV_diameter),...
                             'UV_size',double(UV_size),...
                             'UV_center',UV_center,...
                             'depth_resolution',depth_resolution...
                             );
                                   
LF_Remap_alpha   = zeros(LF_y_size,LF_x_size,3);
E1 = (zeros(yRes,xRes,depth_resolution));

LF_Remap    = 255*reshape(permute(LF, [1 3 2 4 5]), [LF_y_size LF_x_size 3]);     
IM_Pinhole = squeeze(LF(UV_center,UV_center,:,:,1:3)); 

begin_temp=-dmax;
stop_temp=-dmin;
delta=(stop_temp-begin_temp)/(depth_resolution-1);

for index = 1:depth_resolution    

    alpha = stop_temp+delta-index*delta;

    IM_Refoc_alpha   = zeros(yRes,xRes,3);

        REMAP2REFOCUS_mex(double(xRes),double(yRes),...
                            double(UV_diameter),double(UV_radius),double(LF_Remap),...
                            LF_Remap_alpha,IM_Refoc_alpha,double(alpha));

    switch datacost_type
        case 1
            small_radius = 3;
            large_radius = small_radius*2+1;
            gamma = 0.07;
            E1(:,:,index) = DEFOCUS_COST_PAMI2017(IM_Refoc_alpha,IM_Pinhole,LF_parameters,small_radius,large_radius,gamma);

        case 2
            sigma = 10;
            E1(:,:,index) = CORRESP_COST_PAMI2017(LF_Remap_alpha,LF_parameters,sigma);

        case 3

            E1(:,:,index) = CORRESP_COST_CVPR2016(LF_Remap_alpha,LF_parameters);

        case 4            

            defocus_radius = 15;
            small_radius = 5;
            gamma = 0.1;
            E1(:,:,index) = DEFOCUS_COST_CVPR2016(IM_Refoc_alpha,IM_Pinhole,LF_parameters,defocus_radius,small_radius,gamma);

    end
    msg = sprintf('Processing: %d/%d done!\n',index,depth_resolution);
    fprintf(msg);                                       
end  

E1 = (E1-min(E1(:))) ./ (max(E1(:))-min(E1(:)));

% Edge preserving filtering
param.r = 7;
param.eps = 0.0001;
E3 = CostAgg(E1,IM_Pinhole,param);
% Edge preserving filtering + Graph cut
param.data = 5;
param.smooth = 2;
param.neigh = 0.005;
depth_E4 = double(GraphCuts(E3, IM_Pinhole, param));
disp=(1/(depth_resolution-1))*(depth_E4-1);
disp=disp*(dmax-dmin)+dmin;

end