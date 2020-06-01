function [out,gradIn] = wls_optimization(in, data_weight, guidance, lambda, varargin)
%Weighted Least Squares optimization solver.
% Given an input image IN, we seek a new image OUT, which, on the one hand,
% is as close as possible to IN, and, at the same time, is as smooth as
% possible everywhere, except across significant gradients in the hazy image.
%
%  Input arguments:
%  ----------------
%  in             - Input image (2-D, double, N-by-M matrix).   
%  data_weight    - High values indicate it is accurate, small values
%                   indicate it's not.
%  guidance       - Source image for the affinity matrix. Same dimensions
%                   as the input image IN. Default: log(IN)
%  lambda         - Balances between the data term and the smoothness
%                   term. Increasing lambda will produce smoother images.
%                   Default value is 0.05 
%
% This function is based on the implementation of the WLS Filer by Farbman,
% Fattal, Lischinski and Szeliski, "Edge-Preserving Decompositions for 
% Multi-Scale Tone and Detail Manipulation", ACM Transactions on Graphics, 2008
% The original function can be downloaded from: 
% http://www.cs.huji.ac.il/~danix/epd/wlsFilter.m


small_num = 0.00001;

if ~exist('lambda','var') || isempty(lambda), lambda = 0.05; end

[h,w,nc] = size(guidance);
k = h*w;
% guidance = rgb2hsv(guidance);
% tmpVal= rgb2hsv(guidance);
% guidance= tmpVal(:,:,3);
% guidance = edge(guidance(:,:,1), 'canny') | edge(guidance(:,:,2), 'canny') | edge(guidance(:,:,3), 'canny');


% Compute affinities between adjacent pixels based on gradients of guidance
if(nc==3)
    hsv= rgb2hsv(guidance);
    guidance(:,:,3)= histeq(hsv(:,:,3));
end
dy = diff(guidance, 1, 1); 
% Jake
dyt= sqrt(sum(abs(dy).^2,3));
gy= dyt; gy = padarray(gy, [1 0], 'post'); 
if(length(varargin)>=1)
    dyt= dyt.*varargin{1}(1:end-1,:);     
end
if(length(varargin)>=2)
    Th_textureSupress= varargin{2};
    dyt= dyt.*((dyt>Th_textureSupress)+ (dyt<=Th_textureSupress).*2./(1+exp(-5*(dyt-Th_textureSupress))));
end
dy = -lambda./(dyt.^2 + small_num);
% Jake
% dy = -lambda./(sum(abs(dy).^2,3) + small_num);
dy = padarray(dy, [1 0], 'post');
dy = dy(:);

dx = diff(guidance, 1, 2); 
% Jake
dxt= sqrt(sum(abs(dx).^2,3));
gx= dxt; gx = padarray(gx, [0 1], 'post');
if(length(varargin)>=1)
    dxt= dxt.*varargin{1}(:,1:end-1);
end
if(length(varargin)>=2)
    Th_textureSupress= varargin{2};
    dxt= dxt.*((dxt>Th_textureSupress)+ (dxt<=Th_textureSupress).*2./(1+exp(-5*(dxt-Th_textureSupress))));
end
dx = -lambda./(dxt.^2 + small_num);
% Jake
% dx = -lambda./(sum(abs(dx).^2,3) + small_num);
dx = padarray(dx, [0 1], 'post');
dx = dx(:);


% Construct a five-point spatially inhomogeneous Laplacian matrix
B = [dx, dy];
d = [-h,-1];
tmp = spdiags(B,d,k,k);

ea = dx;
we = padarray(dx, h, 'pre'); we = we(1:end-h);
so = dy;
no = padarray(dy, 1, 'pre'); no = no(1:end-1);

D = -(ea+we+so+no);
Asmoothness = tmp + tmp' + spdiags(D, 0, k, k);

% The data terms will be different for different inputs and resp. weights
numElem= numel(in);
if(numel(data_weight)~= numElem)
    disp('wrong input dimension for data and weights.');
    return;
end

A= sparse(k,k); b= sparse(k,1);
for ne= 1:numElem
    currdw= data_weight{ne};
    currIn= in{ne};
    
    % Normalize data weight
    currdw = currdw - min(currdw(:)) ;
    currdw = 1.*currdw./(max(currdw(:))+small_num);

    % Make sure we have a boundary condition for the top line:
    % It will be the minimum of the transmission in each column
    % With reliability 0.8
%     reliability_mask = currdw(1,:) < 0.6; % find missing boundary condition
%     in_row1 = min( currIn,[], 1);
%     currdw(1,reliability_mask) = 0.8;
%     currIn(1,reliability_mask) = in_row1(reliability_mask);

    Adata = spdiags(currdw(:), 0, k, k);

    A = A+ Adata + Asmoothness;
    b = b+ Adata*currIn(:);
end
% Solve
% out = lsqnonneg(A,b);
out = A\b;
out = reshape(out, h, w);
gradIn= reshape(sum(gx.^2+ gy.^2,3),h,w,[]);
end