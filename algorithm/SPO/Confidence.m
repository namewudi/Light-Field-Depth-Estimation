function [ weight_cost ] = Confidence( local_cost_T, local_cost_S, sigma, depth_resolution )
%CONFIDENCE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
N = depth_resolution;
max_T = squeeze(max(local_cost_T, [], 3));
max_S = squeeze(max(local_cost_S, [], 3));
mean_T = squeeze(mean(local_cost_T, 3));
mean_S = squeeze(mean(local_cost_S, 3));
weight_cost = zeros(size(local_cost_T));

for n = 1 : N
    weight_cost(:, :, n) = exp(-mean_T./(max_T * sigma)).* local_cost_T(:, :, n)...
        + exp(-mean_S./(max_S * sigma)).* local_cost_S(:, :, n);
end

end

