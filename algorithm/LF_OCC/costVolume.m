function  disp1  = costVolume( LF,dmin,dmax,depth_resolution)
%% Input: 5D double array of size [h x w x 3 x v x u]
% [h w 3] is spatial image size, and [v u] is angular size

data=255*permute(LF,[3 4 5 1 2]);

% % read our data
% hinfo_data = hdf5info('input/livingroom.h5');
% data = double(hdf5read(hinfo_data.GroupHierarchy.Datasets(3)));
% data = permute(LF, [3 4 5 1 2]); %%test

depth_output = computeDepth(data,dmax,dmin,depth_resolution);
disp1 = depth_output*(dmax-dmin)+dmin;
end