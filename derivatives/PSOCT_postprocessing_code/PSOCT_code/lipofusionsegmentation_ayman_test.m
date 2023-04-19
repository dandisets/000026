%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generating lipofuscin distribution based on 2PM images
% using channel2 of 2PM
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

% sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P"];
sampleID=["CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P"];
thresh=[6000,2500,2500,3000,3000];
% sampleID=["NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];
% thresh=[2500; 2500; 3000; 3000; 3000; 3000; 2500];
% sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P" "CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P" "NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];
% for id = 1:size(sampleID,2)
    datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/','CTE_6489_2P','/aip/');
    agar_thresh=6000; % threshold to differentiate agarose. Double check for each sample

%     for zz=11:12 % processing 10 images per sample
    %% smooth background  %%matlab%%
        image=single(imread(strcat(datapath,'channel2-','11','.tif'),1));
        mask=ones(size(image));
        mask(image>agar_thresh)=0;
        image(mask>0)=agar_thresh;
        SaveTiff(image,1,strcat(datapath,'channel2_','11','_bg_cleared_ayman.tif'));