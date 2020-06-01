function  disp1  = costVolume( LF,dmin,dmax,depth_resolution)
%% Parameters
LF = 255 * LF;
tau = 60;        % tau in Eq.1
sigma = 100;     % sigma in Eq.3

[S, T, H, W, N] = size(LF);
UV_diameter = T;
UV_center = round(UV_diameter/2);
UV_radius = UV_center - 1;
LF_y_size =S*H;
LF_x_size =T*W;

%% image load
img = reshape(permute(LF, [1 3 2 4 5]), [LF_y_size LF_x_size N]);  % the 4D light field image
begin_temp=-dmax;
stop_temp=-dmin;
delta=(stop_temp-begin_temp)/(depth_resolution-1);
central_img=img(5:9:end-4,5:9:end-4,:);
central_lf=zeros(LF_y_size,LF_x_size,3);
central_lf(5:9:end-4,5:9:end-4,:)=central_img;
h_sum_9=81*fspecial('average',[9 9]);
central_lf=imfilter(central_lf,h_sum_9,'symmetric');
Weight=exp(-1*sum((central_lf-img).^2,3)/(sigma^2));
Weight_num=zeros(H,W);
sum_lf_one_channel(double(H),double(W),...
        double(UV_diameter),double(UV_radius),Weight,...
        Weight_num);
IM_Refoc_alpha   = zeros(H,W,3);

E1=zeros(H,W,depth_resolution);
LF_Remap_alpha   = zeros(LF_y_size,LF_x_size,3);
Remap_alpha_var = zeros(W,H);

for index=1:depth_resolution
    alpha = stop_temp+delta-index*delta;
    refocus(double(W),double(H),...
        double(UV_diameter),double(UV_radius),central_lf,...
        LF_Remap_alpha,IM_Refoc_alpha,double(-1*alpha),-4,4,-4,4);
    
    LF_Remap_alpha_var=squeeze(Weight.*min(sum(abs(img-LF_Remap_alpha),3),tau));
    sum_lf_one_channel(double(H),double(W),...
        double(UV_diameter),double(UV_radius),LF_Remap_alpha_var,...
        Remap_alpha_var);
    E1(:,:,index) = Remap_alpha_var./Weight_num;
    
    disp(['Depth processing: ',num2str(index),'/',num2str(depth_resolution)]);
end

param.r = 3;
param.eps = 0.0001;
E2 = CostAgg(E1,central_img,param);
[~,opt_label] =  min(E2,[],3); 
disp1 = (opt_label-1)/(depth_resolution-1)*(dmax-dmin)+dmin;


end
