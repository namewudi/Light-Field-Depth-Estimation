function [ C ] = apply_spo( epi, F, n_bin )
%APPL 此处显示有关此函数的摘要
%   此处显示详细说明
epi_h = size(epi ,1);
cviewIdx = ceil(epi_h/2);
epi_w = size(epi ,2);
channel = size(epi, 3);
n_label = size(F, 3);
cost_i = zeros(epi_w, n_label);
C = zeros(epi_w, n_label);

for c = 1 : channel
    cost_b = zeros(epi_w, n_label);
    for b = 1 : n_bin   
        epi_template = zeros(epi_h, epi_w);
        epi_template((epi(:, :, c) > (b - 1) * 1/n_bin) & (epi(:, :, c) <= b * 1/n_bin)) = 1;
        for i = 1:n_label
            cost = abs(conv2(epi_template, F(:, :, i), 'same'));
            cost_i(:, i) = cost(cviewIdx, :);
        end
        cost_b = cost_b + cost_i.^2;
    end
    C = C + cost_b;
end

end

