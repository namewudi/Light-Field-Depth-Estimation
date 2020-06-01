function [ C ] = local_cost( epi, spo, n_bin)
%LOCAL_COST 此处显示有关此函数的摘要
%   此处显示详细说明
C = zeros(size(epi, 4), size(epi, 2), size(spo, 3));
N = size(epi, 4);
parfor y = 1 : N
    C(y, :, :) = apply_spo(epi(:, :, :, y), spo, n_bin);
end
end

