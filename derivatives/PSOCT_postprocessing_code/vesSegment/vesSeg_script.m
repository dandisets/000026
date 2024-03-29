%% batch job version of vessel segmentation
% Author: Jiarui Yang
% 10/21/20
function []=vesSeg_script
% add path
addpath '/projectnb/npbssmic/s/Matlab_code/vesSegment';
addpath '/projectnb/npbssmic/s/Matlab_code';

% load volume
%vol=TIFF2MAT(strcat('/projectnb2/npbssmic/ns/210310_PSOCT_4x4x2cm_BA44_45_milestone/dist_corrected/volume/ref',num2str(index),'.mat'));
filename = strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_21499/ref_inv.tif');
Ref = TIFF2MAT(filename);
%Ref=255*(mat2gray(Ref));
%Ref=255-Ref;

% multiscale vessel segmentation
%vol=imresize3(vol,[size(vol,1) size(vol,2) size(vol,3)/5]);
% vol=vol(:,:,43:53);
[I_seg,~]=vesSegment(double(Ref),[3 5 7 9], 0.08);

% save segmentation

%MAT2TIFF(I_seg,strcat('/projectnb2/npbssmic/ns/210909_Ann_NC/dist_corrected/volume/ves_seg',num2str(index),'.tif'));
savepath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_21499/ves_seg_grayscale.tif');
MAT2TIFF(I_seg,savepath);
end