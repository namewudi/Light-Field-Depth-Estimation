%figure;imshow(squeeze(data(:,:,:,5,5)))
yRes=512;xRes=512;
patch=zeros(9,yRes,9,xRes);
vRes=9;uRes=9;
uv_radius=4;
for y=1:yRes
    for x=1:xRes
        theta = orient(y,x);
        for i=1:9
            for j=1:9
                if orient(y,x) < -100*pi/180+0.1
                    patch(:,y,:,x) = 1;
                elseif (uv_radius-i-sin(theta+pi/2) > (tan(theta) * (j-cos(theta+pi/2)-uv_radius)))
                    patch(j,i) = 1;
                else
                    patch(j,i) = 0;
                end
                %                 if orient(y,x) < -100*pi/180+0.1
                %                     patch(:,y,:,x) = 1;
                %                 elseif(uv_radius-i+sin(theta+pi/2) <(tan(theta) * (j+cos(theta+pi/2)-uv_radius)))
                %                     patch(j,y,i,x) = 1;
                %                 else
                %                     patch(j,y,i,x) = 0;
                %                 end
                
            end
        end
    end
end
figure;imshow(reshape(patch,[yRes*9 xRes*9]))
occ_lf_5D=permute(patch,[1 3 2 4]);
         
