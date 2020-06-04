function disp1=lf_pac(LF,dmax,dmin,H,W,S,T,N,depth_resolution,sigma,param)
%% paramater preprocess
begin_temp=-dmax;
stop_temp=-dmin;
delta=(stop_temp-begin_temp)/(depth_resolution-1);
yRes=H;xRes=W;vRes=S;uRes=T;
UV_diameter = T;
UV_center = round(UV_diameter/2);
UV_radius = UV_center - 1;
LF_y_size = vRes*yRes;
LF_x_size = uRes*xRes;

LF_Remap    = reshape(permute(LF, [1 3 2 4 5]), [LF_y_size LF_x_size N]); 
central_img=squeeze(LF(5,5,:,:,:));

%% depth estimation

IM_Refoc_alpha   = zeros(yRes,xRes,3);
E1=zeros(yRes,xRes,depth_resolution);
LF_Remap_alpha= zeros(LF_y_size,LF_x_size,3);

LF_Remap_alpha_mean=repelem(central_img,vRes,uRes);


Mask=zeros(S,T,5);
for i=1:S
        Mask(i,i,1)=1/S;
end
Mask(:,:,5)=ones(S,T)/(S*T);
EPI_num=4;
for index=2:EPI_num
    angle=180/EPI_num*(index-1);
    Mask(:,:,index) = imrotate(Mask(:,:,1),angle,'nearest','crop');
    
end
Mask=repmat(Mask,[H,W]);
sum_cost=zeros(yRes,xRes);

for index=1:depth_resolution
    alpha = stop_temp+delta-index*delta;
    refocus(double(xRes),double(yRes),...
        double(UV_diameter),double(UV_radius),LF_Remap,...
        LF_Remap_alpha,IM_Refoc_alpha,double(alpha),-4,4,-4,4);
    LF_gray=mean(LF_Remap_alpha-LF_Remap_alpha_mean,3);
    LF_gray=LF_gray.^2;
    temp=LF_gray.*Mask(:,:,5);
        sum_lf_one_channel(double(xRes),double(yRes),...
        double(UV_diameter),double(UV_radius),temp,...
        sum_cost);
        Res_LF_Remap=sum_cost;
    for i=1:EPI_num
        temp=LF_gray.*Mask(:,:,i);
        sum_lf_one_channel(double(xRes),double(yRes),...
        double(UV_diameter),double(UV_radius),temp,...
        sum_cost);
        Res_LF_Remap=min(sum_cost,Res_LF_Remap);
    end
    E1(:,:,index)=1-exp(-1*Res_LF_Remap/(2*(sigma^2)));
    disp(['Depth processing: ',num2str(index),'/',num2str(depth_resolution)]);
end

%% optimization
E1 = (E1-min(E1(:))) ./ (max(E1(:))-min(E1(:)));
E2 = CostAgg(E1,central_img,param);

[~,opt_label] =  min(E2,[],3); 
disp1 = (opt_label-1)/(depth_resolution-1)*(dmax-dmin)+dmin;

end
