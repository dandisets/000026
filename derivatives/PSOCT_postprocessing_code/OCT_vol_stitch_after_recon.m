% volume reconstruction of OCT data
% run this after OCT_recon.m to redo volume reconstruction

% specify dataset directory
OCTpath  = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/AD_21424/';  % OCT data path.
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/AD_21424_2P/';
mkdir(strcat(OCTpath,'dist_corrected/volume'));
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

nslice=24; % define total number of slices
njobs=nslice;
Xoverlap=0.05;   % overlap in X direction
Yoverlap=0.05;   % overlap in Y direction
remove_agar = 1; % 1 if remove agar, 0 if not remove agar
ten_ds = 0; % 1 if make final volume 10x10 pixel downsample, 0 if make final volume 4x4 pixel downsample
id=str2num(id);
for islice=id
    fprintf(strcat('Slice No. ',num2str(islice),' is started.', datestr(now,'DD:HH:MM'),'\n'));
    BaSiC_shading_and_ref_stitch(islice,P2path,OCTpath, 80, 75, 44,0,0.09, Xoverlap, Yoverlap);  % Find description for parameters in OCT_recon.m
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));
    fid=fopen(strcat(OCTpath,'dist_corrected/volume/log',num2str(islice),'.txt'),'w');
    fclose(fid);
end
cd(strcat(OCTpath,'dist_corrected/volume/'))
logfiles=dir(strcat(OCTpath,'dist_corrected/volume/log*.txt')); 
if length(logfiles)==njobs
%     delete log*.txt
    Concat_ref_vol(nslice,OCTpath, 0.09, remove_agar, ten_ds);
    if ten_ds == 0
        depth_normalize_2(OCTpath, nslice, nslice*11, 50,50, ten_ds); % volume intensity correction, comment the mus part if no fitting is generated
    else
        depth_normalize_2(OCTpath, nslice, nslice*5, 20,20, ten_ds); % volume intensity correction, comment the mus part if no fitting is generated
    end
end
system(['chmod -R 777 ',OCTpath]);