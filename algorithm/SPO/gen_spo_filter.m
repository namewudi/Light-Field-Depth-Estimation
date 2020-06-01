function [ F ] = gen_spo_filter( dmin, dmax, S, N, alpha)
%SPO_FILTER 生成n个平行四边形算子
%   此处显示详细说明
filter_w = ceil(ceil(max(abs(dmax), abs(dmin)) * (S - 1))/2) * 2 + 11;
filter_h = S;
filter_cw = ceil(filter_w/2);
filter_ch = ceil(filter_h/2);
F = zeros(filter_h, filter_w, N);
delta = (dmax - dmin)/(N - 1);
for n = 1 : N
    for i = 1 : filter_w
        for j = 1 : filter_h     
            d = i - (filter_cw + (filter_ch - j) * (dmin + (n - 1) * delta));
            F(j, i, n) = d * exp(-d^2/(2 * alpha));       
        end
    end
end

end

