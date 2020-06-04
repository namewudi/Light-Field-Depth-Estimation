function pfmwrite(D, filename)
% assert(size(D, 3) == 1 & (isa(D, 'single') ));
 
[rows, cols] = size(D);
%scale = -1.0/ max(max(D));
scale = -1;
fid = fopen(filename, 'wb');
 
fprintf(fid, 'Pf\n');
fprintf(fid, '%d %d\n', cols, rows);
fprintf(fid, '%f\n', scale);
%fscanf(fid, '%c', 1);
 
fwrite(fid, D(end:-1:1, :)', 'single');
fclose(fid);
end
%pfmwrite(disp, 'boxes.pfm');