sk = load_nifti('SkeletonDistance_seg_resample_gra.nii');
dist = sk.vol;
th = load_nifti('Thickness_seg_resample_gra.nii');
thickness = th.vol;
im_filter = imerode(thickness, strel('ball',15,15), 'same');
im_filter(thickness==0)=0;
% ThicknessOnSkeleton = Thickness.*(SkeletonDistance<1).*(im_filter>(min(im_filter(:)+0.7))); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
ThicknessOnSkeleton = thickness.*(dist<1).*((im_filter>min(im_filter(:)+1.25))&(im_filter~=0)); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
sk.vol = ThicknessOnSkeleton;
save_nifti(sk,'SkeletonThickness_seg_resample_gra.nii');
ThicknessOnSkeleton_y = ThicknessOnSkeleton(:);
ThicknessOnSkeleton_y(ThicknessOnSkeleton_y==0) = [];

sk2 = load_nifti('SkeletonDistance_seg_resample_mol.nii');
dist2 = sk2.vol;
th2 = load_nifti('Thickness_seg_resample_mol.nii');
thickness2 = th2.vol;
im_filter2 = imerode(thickness2, strel('ball',15,15), 'same');
im_filter2(thickness2==0)=0;
% ThicknessOnSkeleton = Thickness.*(SkeletonDistance<1).*(im_filter>(min(im_filter(:)+0.7))); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
ThicknessOnSkeleton2 = thickness2.*(dist2<1).*((im_filter2>min(im_filter2(:)+2))&(im_filter2~=0)); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
ThicknessOnSkeleton2_y = ThicknessOnSkeleton2(:);
ThicknessOnSkeleton2_y(ThicknessOnSkeleton2_y==0) = [];
sk2.vol = ThicknessOnSkeleton2;
save_nifti(sk2,'SkeletonThickness_seg_resample_mol.nii');

% mus = load_nifti('/autofs/cluster/octdata/users/Hui/ProcessI29Cerebellum_LSM03_20181116/Stack_nii/mus.nii');
% mus_data = mus.vol;
% mus_data = mus_data(:,1:56,:);
% pix_x = mus.pixdim(2);
% pix_z = mus.pixdim(3);
% pix_y = mus.pixdim(4);
% [Xq, Yq, Zq] = meshgrid(linspace(1,size(mus_data,2),400), linspace(1, size(mus_data,1), round(size(mus_data,1)/2)), linspace(1, size(mus_data,3), round(size(mus_data,3)/2)));
% mus_up = (interp3(mus_data, Xq, Yq, Zq));
% resolution = pix_x*2 * ones(1,3);
% MusOnSkeleton = mus_up.*(dist<1).*((im_filter>min(im_filter(:)+1.25))&(im_filter~=0)); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
% MusOnSkeleton2 = mus_up.*(dist2<1).*((im_filter2>min(im_filter2(:)+2))&(im_filter2~=0)); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
% MusOnSkeleton2_y = MusOnSkeleton2(:);
% MusOnSkeleton2_y(MusOnSkeleton2_y==0) = [];
% 
% 
% ret = load_nifti('/autofs/cluster/octdata/users/Hui/ProcessI29Cerebellum_LSM03_20181116/Stack_nii/retardance.nii');
% ret_data = ret.vol;
% ret_data = ret_data(:,1:56,:);
% pix_x = ret.pixdim(2);
% pix_z = ret.pixdim(3);
% pix_y = ret.pixdim(4);
% [Xq, Yq, Zq] = meshgrid(linspace(1,size(ret_data,2),400), linspace(1, size(ret_data,1), round(size(ret_data,1))), linspace(1, size(ret_data,3), round(size(ret_data,3))));
% ret_up = (interp3(ret_data, Xq, Yq, Zq));
% resolution = pix_x * ones(1,3);
% RetOnSkeleton = ret_up.*(dist<1).*((im_filter>min(im_filter(:)+1.25))&(im_filter~=0)); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
% RetOnSkeleton2 = ret_up.*(dist2<1).*((im_filter2>min(im_filter2(:)+2))&(im_filter2~=0)); % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
% RetOnSkeleton2_y = RetOnSkeleton2(:);
% RetOnSkeleton2_y(RetOnSkeleton2_y==0) = [];
% 
% MusOnSkeleton_y = MusOnSkeleton(:);
% RetOnSkeleton_y = RetOnSkeleton(:);
% ThicknessOnSkeleton_y = ThicknessOnSkeleton(:);
% ThicknessOnSkeleton_y(ThicknessOnSkeleton_y==0|MusOnSkeleton_y==0) = [];
% 
% MusOnSkeleton_y(MusOnSkeleton_y==0) = [];
% RetOnSkeleton_y(RetOnSkeleton_y==0) = [];
% 
% % figure,scatter(ThicknessOnSkeleton_y,MusOnSkeleton_y);
% % figure,scatter(ThicknessOnSkeleton_y,RetOnSkeleton_y);
% % figure,scatter(ThicknessOnSkeleton2_y,MusOnSkeleton2_y);
% % figure,scatter(ThicknessOnSkeleton2_y,RetOnSkeleton2_y);
% corrcoef(ThicknessOnSkeleton_y,MusOnSkeleton_y)
% corrcoef(ThicknessOnSkeleton_y,RetOnSkeleton_y)
% corrcoef(ThicknessOnSkeleton2_y,MusOnSkeleton2_y)
% corrcoef(ThicknessOnSkeleton2_y,RetOnSkeleton2_y)
% save('gra_y','ThicknessOnSkeleton_y','MusOnSkeleton_y','RetOnSkeleton_y');
% save('mol_y','ThicknessOnSkeleton2_y','MusOnSkeleton2_y','RetOnSkeleton2_y');
save('gra_y','ThicknessOnSkeleton_y');
save('mol_y','ThicknessOnSkeleton2_y');