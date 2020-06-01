function [ output ] = method( filename,data_type,algo_type, depth_resolution)
%METHOD 此处显示有关此函数的摘要
%   此处显示详细说明
switch data_type
    case 1
        path=['data\new_benchmark\',filename,'\LF.mat'];
        load(path);
        LF_struct = LF;
        LF = LF_struct.LF;
        dmin = LF_struct.parameters.meta.disp_min;
        dmax = LF_struct.parameters.meta.disp_max;
    case 2
        path=['data\old_benchmark\',filename,'\lf.h5'];
        ind = hdf5info(path);
        idx_size = max(size(ind.GroupHierarchy.Attributes));
        shortname = cell(idx_size,1);
        for ids = 1:idx_size
            shortname{ids} =  ind.GroupHierarchy.Attributes(ids).Shortname;
        end
        indexcell = strfind(shortname, 'dH');
        dH_id = find(not(cellfun('isempty', indexcell)));
        indexcell = strfind(shortname, 'focalLength');
        focalLength_id = find(not(cellfun('isempty', indexcell)));
        indexcell = strfind(shortname, 'shift');
        shift_id = find(not(cellfun('isempty', indexcell)));
        dH = ind.GroupHierarchy.Attributes(dH_id).Value;
        focalLength = ind.GroupHierarchy.Attributes(focalLength_id).Value;
        shift = ind.GroupHierarchy.Attributes(shift_id).Value;
        groundtruth = hdf5read(path,'/GT_DEPTH');
        LF_temp = hdf5read(path,'/LF');
        LF = permute(im2double(LF_temp), [5 4 3 2 1]);
        LF=LF(:,end:-1:1,:,:,:);
        [S,~,~,~,~]=size(LF);
        UV_center = round(S/2);
        depth = groundtruth(:,:,UV_center,UV_center)';
        disparity = (double(dH)*focalLength) ./ depth - double(shift);
        dmin=min(disparity(:));
        dmax=max(disparity(:));
end

switch algo_type
    case 1
        addpath(genpath('algorithm/CAE'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/CAE'));
    case 2
        addpath(genpath('algorithm/SPO'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/SPO'));
    case 3
        addpath(genpath('algorithm/IGF'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/IGF'));
    case 4
        addpath(genpath('algorithm/LF_PAC'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/LF_PAC'));
    case 5
        addpath(genpath('algorithm/MBM'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/MBM'));
    case 6
        addpath(genpath('algorithm/POBR'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/POBR'));
    case 7
        addpath(genpath('algorithm/LF'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/LF'));
    case 8
        addpath(genpath('algorithm/LF_DC'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/LF_DC'));
    case 9
        addpath(genpath('algorithm/LF_OCC'));
        output=costVolume(LF,dmin,dmax,depth_resolution);
        rmpath(genpath('algorithm/LF_OCC')); 
end

end

