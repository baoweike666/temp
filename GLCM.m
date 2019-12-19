
clear;

img = imread('G3.bmp');
img = rgb2gray(img);

% 计算共生矩阵
[M,N] = size(img);
GLC_M = zeros(256,256);
for i = 1:M
   for j = 1:N-1
      GLC_M(img(i,j)+1,img(i,j+1)+1) = GLC_M(img(i,j)+1,img(i,j+1)+1)+1;
   end
end

%归一化
GLC_M = GLC_M ./ sum(GLC_M(:)); 
%描述子
%maximum_probability
maximum_probability = max(GLC_M(:));
%correlation
linescape = (1:1:256);
mr = sum(GLC_M,2);
mr = sum(mr .* linescape');
mc = sum(GLC_M,1);
mc = sum(mc .* linescape);
sig_r = sum(GLC_M,2);
sig_r = sqrt(sum(power((linescape' - mr),2) .* sig_r));
sig_c = sum(GLC_M,1);
sig_c = sqrt(sum(power((linescape - mc),2) .* sig_c));
correlation = (linescape'-mr) * (linescape - mc) .* GLC_M./(sig_r*sig_c);
correlation = sum(correlation(:));
%contrast
contrast = zeros(256,256);
for i = 1:256
   for j = 1:256
       contrast(i,j) = power(i-j,2);
   end    
end
contrast = contrast.*GLC_M;
contrast = sum(contrast(:));
%energy
energy = GLC_M .* GLC_M;
energy = sum(energy(:));
%homogeneity
homogeneity = zeros(256,256);
for i = 1:256
    for j = 1:256
        homogeneity(i,j) = 1 + abs(i-j);        
    end
end
homogeneity = GLC_M ./ homogeneity;
homogeneity = sum(homogeneity(:));
%entropy
entropy = log2(GLC_M+1e-20);
entropy = GLC_M .* entropy;
entropy = -sum(entropy(:));

descriptor=[maximum_probability, correlation, contrast, energy, homogeneity, entropy];


