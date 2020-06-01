function  disp  = costVolume( LF,dmin,dmax,depth_resolution)

n_bin = 64;
alpha = 0.8;
sigma = 0.26; 
param.r = 3; 
param.eps = 0.0001;

[S, T, H, W, N] = size(LF);

cviewIdx = ceil(S/2);
central_img = squeeze(LF(cviewIdx, cviewIdx, :, :, :));
epi_T = permute(squeeze(LF(cviewIdx, :, :, :, :)), [1 3 4 2]);
epi_S = permute(squeeze(LF(:, cviewIdx, :, :, :)), [1 2 4 3]);

spo_filter = gen_spo_filter(dmin, dmax, S, depth_resolution, alpha);

local_cost_T = local_cost(epi_T, spo_filter, n_bin);
local_cost_S = permute(local_cost(epi_S, spo_filter, n_bin), [2 1 3]);

weight_cost = Confidence(local_cost_T, local_cost_S, sigma, depth_resolution);

E3 = CostAgg(weight_cost, central_img, param);
[~, opt_label] =  max(E3, [], 3);
disp = (opt_label - 1)/(depth_resolution - 1) * (dmax - dmin) + dmin;

end