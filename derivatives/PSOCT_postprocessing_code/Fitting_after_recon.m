% fitting scattering and birefringence of brain tissue
% run this after OCT_recon.m is finished

folder = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/AD_10382/';      % OCT file path                          ADJUST FOR EACH SAMPLE!!! 
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/AD_10382_2P/';   % 2P file path                           ADJUST FOR EACH SAMPLE!!!
datapath=strcat(folder,'dist_corrected/'); 
nslice=22; % define total number of slices                                                                       ADJUST FOR EACH SAMPLE!!!
stitch=0; % 1 means using OCT data to generate stitching coordinates, 
% 0 means using 2P stitching coordinates.                                                                        ADJUST FOR EACH SAMPLE!!!
ds_factor=4;     % downsampling factor, 4 means 4x4 pixel downsample, which is 12x12um pixel size                ADJUST FOR EACH SAMPLE!!!

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
create_dir(nslice, folder); 
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=11;    % #tiles in X direction                                                                             ADJUST FOR EACH SAMPLE!!!
numY=7;    % #tiles in Y direction                                                                              ADJUST FOR EACH SAMPLE!!!
Xoverlap=0.05;   % overlap in X direction
Yoverlap=0.05;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];
ntile=numX*numY;                                                                                                 
njobs=1;
section=ceil(ntile/njobs);

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);
istart=1;%(id-1)*section+1;
istop=section;

for islice=id%:nslice
    cd(datapath);
    filename0=dir(strcat('co-',num2str(islice),'-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(1).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat(datapath,'co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        if isfile(name1)
            % load reflectivity data
            co = ReadDat_int16(name1, dim1)./65535*4; 
            name1=strcat(datapath,'cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
            cross = ReadDat_int16(name1, dim1)./65535*4; 
        else
            co=zeros(Zsize,Xsize,Ysize);
            cross=zeros(Zsize,Xsize,Ysize);
        end
        % pause here, use view3D(co) to get value for zf and zf_tilt
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
%       Optical_fitting_finalized(co, cross, s_seg, z_seg, datapath,aip_threshold, mus_depth, bfg_depth, ds_factor, zf, zf_tilt)
        Optical_fitting_finalized(co, cross, islice, iFile, folder,      0.05,       130,       100,     ds_factor, 60,    10);
        % aip_threshold should use the same value in OCT_recon.m
        % Find zf by evaluating the agarose tiles
        % zf is the focus depth in pixels, including water space
        % Find zf_tilt when evaluating agar tile
        % zf_tilt is the zf difference at (x=0,y=middel) and
        % (x=end,y=middle) in pixels
    end

    Mus_stitch('mus', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);          
    Mub_stitch('mub', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
    Bfg_stitch('bfg', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
    BKG_stitch('BKG', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
    R2_stitch( 'R2',  P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
    ZF_stitch( 'zf',  P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
    ZR_stitch( 'zr',  P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
    message=strcat('slice No. ',string(islice),' is fitted and stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end
system(['chmod -R 777 ',folder]);

