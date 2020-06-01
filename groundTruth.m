function output = groundTruth( filename,data_type )
%extracting gt disparity map
switch data_type
    case 1
        path=['data\new_benchmark\',filename,'\LF.mat'];
        load(path);
        LF_struct = LF;
        LF = LF_struct.LF;
        output=LF_struct.disp_lowres;
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
        output = (double(dH)*focalLength) ./ depth - double(shift);
end



end

