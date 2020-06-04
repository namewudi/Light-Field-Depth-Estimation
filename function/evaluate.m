function [disp_rgb,disp_gt] = evaluate( filename,data_type,disp,thres )
%computing error map
cutoff=15;
switch data_type
    case 1
        path=['data\new_benchmark\',filename,'\LF.mat'];
        load(path);
        LF_struct = LF;
        disp_gt=LF_struct.disp_lowres;
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
        [S,~,~,~,~]=size(LF);
        UV_center = round(S/2);
        depth = groundtruth(:,:,UV_center,UV_center)';
        disp_gt = (double(dH)*focalLength) ./ depth - double(shift);
        dmin=min(min(disp_gt(cutoff+1:end-cutoff, cutoff+1:end-cutoff,:)));
end

[H,W]=size(disp);
disp_rgb = zeros(H,W,3);
disp_g = (disp-dmin)/(dmax-dmin);
disp_g(abs(disp - disp_gt) > thres)=1 ;
disp_rgb(:,:,1) = disp_g; disp_g(abs(disp - disp_gt) > thres)=0;
disp_rgb(:,:,2:3) = disp_g(:,:,ones(2,1));
disp_rgb=disp_rgb(cutoff+1:end-cutoff, cutoff+1:end-cutoff,:);

end

