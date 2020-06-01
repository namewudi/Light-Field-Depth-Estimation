function  weight  = integral_guided_filter( LF,dmin,dmax ,sigma_w)

[vRes,uRes,yRes,xRes,~]=size(LF);
UV_diameter = uRes;
UV_center = round(UV_diameter/2);
UV_radius = UV_center - 1;
central_img=squeeze(LF(UV_center,UV_center,:,:,:));
central_img_gray=rgb2gray(central_img);
LF_y_size = yRes * vRes;
LF_x_size = xRes * uRes;

window_radius=ceil((dmax-dmin)*4);
window_size=window_radius*2+1;
weight_o=zeros(yRes,xRes,window_size,window_size);
central_img_gary_paded = padarray(central_img_gray,[window_radius,window_radius],'symmetric');
for y=1:yRes
    for x=1:xRes
        weight_o(y,x,:,:)=(central_img_gary_paded(y:y+window_size-1,x:x+window_size-1)-central_img_gray(y,x)).^2;
    end
end
weight_o=permute(imresize(permute(weight_o,[3 4 1 2]),9/window_size,'bilinear'),[3 4 1 2]);
weight_a=zeros(size(weight_o));
symbol_y1=ones(UV_diameter,1);symbol_y1(UV_radius+1)=0;symbol_y1(1:symbol_y1)=-1;
symbol_x1=symbol_y1;
for y=1:yRes
    for x=1:xRes
        
        for y1=-UV_radius:UV_radius
            for x1=-UV_radius:UV_radius

                    temp=weight_o(y,x,UV_radius+1:symbol_y1(y1+UV_radius+1):y1+UV_radius+1,UV_radius+1:symbol_x1(x1+UV_radius+1):x1+UV_radius+1);
                    weight_a(y,x,y1+UV_radius+1,x1+UV_radius+1)=sum(temp(:));
            
%                 for y2=0:abs(y1)
%                     for x2=0:abs(x1)
%                         weight_a(y,x,y1+window_radius+1,x1+window_radius+1)=weight_a(y,x,y1+window_radius+1,x1+window_radius+1)...
%                                                                            +weight_o(y,x,y2*symbol_y1+window_radius+1,x2*symbol_x1+window_radius+1);
%                     end
%                 end
            end
        end
    end
end
weight=exp(-weight_a/(sigma_w^2));
weight=reshape(permute(weight,[3 1 4 2]),[LF_y_size,LF_x_size]);
weight_sum=zeros(yRes,xRes);
sum_lf_one_channel(double(xRes),double(yRes),...
        double(UV_diameter),double(UV_radius),weight,...
        weight_sum);
weight=vRes*uRes*weight./reshape(permute(reshape(repmat(weight_sum,[vRes uRes]),[yRes vRes xRes uRes]),[2 1 4 3]),[LF_y_size,LF_x_size]);
end

