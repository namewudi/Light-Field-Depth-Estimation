function  E1  = cost_function( LF,weight,depth_resolution,dmin,dmax,sigma_c )

begin_temp=-dmax;
stop_temp=-dmin;
delta=(stop_temp-begin_temp)/(depth_resolution-1);
[vRes,uRes,yRes,xRes,N]=size(LF);
LF_y_size = yRes * vRes;
LF_x_size = xRes * uRes;
UV_diameter = uRes;
UV_center = round(UV_diameter/2);
UV_radius = UV_center - 1;
central_img=squeeze(LF(UV_center,UV_center,:,:,:));
LF_central_img=reshape(permute(reshape(repmat(central_img,[vRes uRes]),[yRes,vRes,xRes,uRes,N]),[2 1 4 3 5]),[LF_y_size,LF_x_size,N]);
LF_Remap    = reshape(permute(LF, [1 3 2 4 5]), [LF_y_size LF_x_size N]);
IM_Refoc_alpha   = zeros(yRes,xRes,3);
LF_Remap_alpha= zeros(LF_y_size,LF_x_size,N);
Res_sum=zeros(yRes,xRes);
E1=zeros(yRes,xRes,depth_resolution);

for index=1:depth_resolution
    alpha = stop_temp+delta-index*delta;
    refocus(double(xRes),double(yRes),...
        double(UV_diameter),double(UV_radius),LF_Remap,...
        LF_Remap_alpha,IM_Refoc_alpha,double(alpha),-4,4,-4,4);
    Res_LF_Remap=weight.*(1-exp(-(mean(abs(LF_Remap_alpha-LF_central_img),3))/(sigma_c^2)));
    sum_lf_one_channel(double(xRes),double(yRes),...
        double(UV_diameter),double(UV_radius),Res_LF_Remap,...
        Res_sum);
    E1(:,:,index)=Res_sum;
    disp(['Depth processing: ',num2str(index),'/',num2str(depth_resolution)]);
end

end

