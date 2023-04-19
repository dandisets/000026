function cortical_thickness_3D(filename)
    %% cleanup
    cd /projectnb/npbssmic/s/Matlab_code/cortical_thickness
    if exist('thickness_skel_infra.tif','file')
        delete('thickness_skel_infra.tif')
    end
    if exist('thickness_skel_supra.tif','file')
        delete('thickness_skel_supra.tif')
    end
    if exist('thickness_skel_cortex.tif','file')
        delete('thickness_skel_cortex.tif')
    end
    %% Create the input image
    tic
    addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code/');
    I = TIFF2MAT(filename);
    I(I(:)==255) = 1;
    % interlopate in z (5 x upsampling to match 30 um isotropic resolution)
    [Xq, Yq, Zq] = meshgrid(linspace(1,size(I,2),size(I,2)), linspace(1,size(I,1),size(I,1)), linspace(1,size(I,3),size(I,3)*5));
    I_interp = interp3(single(I), Xq, Yq, Zq);
    I_interp(I_interp(:)>=0.25) = 1;
    I_interp(I_interp(:)<0.25) = 0;

    %% Create and save the line segments
    % The radius parameter should be a few voxels larger than the expected
    % maximum thickness. See the help of makeLineSegments.m for more parameters
    % % and parallelization options.
    if ~exist('LineSegments.mat','file')
        N = 100;
        L = makeLineSegments(N,10,2);
        save LineSegments L
    end

    %% Compute the thickness and the distance transform of the skeleton
    % See the help of MLI_thickness.m for parameters and parallelization options.
    % MLI_thickness_MEX.c must be compiled using: "mex MLI_thickness_MEX.c".
    % Alternatively, the compiled files can be downloaded from:
    % www.nitrc.org/projects/thickness
    load LineSegments
    param.threshStop = 0.3;
    param.numVoxStop = 1;
    param.numVoxValey = 0;
    param.useParpool = false;
    [Thickness, ~] = MLI_thickness(I_interp, L, param);

    %% Visualize the results
    % generate skeleton
    I_skel = zeros(size(I_interp));
    for i=1:size(I_interp,3)
        skel=bwskel(logical(squeeze(I_interp(:,:,i))));
        I_skel(:,:,i)=imdilate(skel,strel('sphere',1),'same');
    end
    % I_skel = imerode(I_interp, strel('sphere',1), 'same');
    ThicknessOnSkeleton = Thickness.*I_skel; % (SkeletonDistance<1) is a 2-voxel-wide skeleton mask. Eroding 'I' eliminates border artifacts.
    % Show the measured thickness on the outer surface of the skeleton.
    % figure; colormap jet;
    % isosurface(ThicknessOnSkeleton>0, 0, Thickness);
    % patch(isosurface(I_interp, 0), 'EdgeColor', 'none', 'FaceAlpha', .1);
    % camlight; lighting gouraud;
    % axis equal tight; colorbar;
    % title('Thickness on the outer surface of the skeleton');
    opt = strsplit(filename,'_');
    opt = opt{end};
    opt = strsplit(opt,'.');
    opt = opt{1};
    if strcmp(opt,'infra')
        MAT2TIFF(single(ThicknessOnSkeleton),'thickness_skel_infra.tif');
    elseif strcmp(opt,'supra')
        MAT2TIFF(single(ThicknessOnSkeleton),'thickness_skel_supra.tif');
    elseif strcmp(opt,'cortex')
        MAT2TIFF(single(ThicknessOnSkeleton),'thickness_skel_cortex.tif');
    end
    toc
end
