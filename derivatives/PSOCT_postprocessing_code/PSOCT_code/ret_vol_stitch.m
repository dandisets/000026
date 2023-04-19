function[]=ret_vol_stitch(id,datapath)
% mosaic parameters

Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;

% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

%% get FIJI stitching info & adjust coordinates system

% vol_index=[];
% for i=1:7
%     slice_index=(i-1)*3+1;
%     filename = strcat('/projectnb/npbssmic/ns/190619_Thorlabs/aip/vol',num2str(slice_index),'/');
%     f=strcat(filename,'TileConfiguration.registered.txt');
%     Fiji_coord{i} = read_Fiji_coord(f,'aip');
%     vol_index=[vol_index Fiji_coord{i}(1,:)];
% end
% 
% % use median corrdinates for all slices
% vol_index=unique(vol_index);
% coord=zeros(3,length(vol_index));
% coord(1,:)=vol_index;
% for i=1:length(vol_index)
%     temp=[];
%     for j=1:7
%         if ismember(vol_index(i),Fiji_coord{j}(1,:))
%             [~, loc]=ismember(vol_index(i),Fiji_coord{j}(1,:));
%             temp=[temp Fiji_coord{j}(2:3,loc)];
%         end
%     end
%     coord(2:3,i)=median(temp,2);
% end
% coord=squeeze(median(coord,1));

%% define coordinates for each tile
% id=str2num(id);
filename = strcat(datapath,'aip/vol1/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(3,ii));
    Ycen(coord(1,ii))=round(coord(2,ii));
end


%% select tiles for sub-region volumetric stitching

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+round(Xsize/2);
Ycen=Ycen+round(Ysize/2);

% tile range -199~+200
stepx = floor(Xoverlap*Xsize/1);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize/1)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize/1);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize/1)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing

thickness=50;


filename = strcat(datapath,'dist_corrected/');
cd(filename);


for nslice=id
    
    Mosaic = zeros(round(max(Xcen/1))+round(Xsize/2) ,round(max(Ycen/1))+round(Ysize/2),round(thickness/1));
    Masque = zeros(size(Mosaic));
    Masque2 = zeros(size(Mosaic));
    
    filename0=dir(strcat(filename,'ret-',num2str(nslice),'-',num2str(1),'-*.dat'));
    name1=strsplit(filename0(1).name,'.');  
    name_dat=strsplit(name1{1},'-');
    nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
    dim=[nk nxRpt nx nyRpt ny];

    for i=1:length(index)

        in = index(i);

        filename0=dir(strcat('ret-',num2str(nslice),'-',num2str(in),'-*.dat'));

        ifilePath=[filename,filename0(1).name];
        info=strcat('Finished loading tile No.', num2str(in),'\n');
        fprintf(info);

        slice = ReadDat_int16(ifilePath, dim)/65535*180;
%         slice = depth_corr(slice,0.0026);

        slice = slice(1:(1+thickness-1),:,:);


%         temp=zeros(thickness,size(slice,2)/4,size(slice,3)/4);
% 
%         for z=1:thickness
%             temp(z,:,:)=imresize(squeeze(slice(z,:,:)),0.25);
%         end

        %figure;imagesc(squeeze(temp(1,:,:)));colormap gray;

%         vol = zeros(round(thickness/1),size(temp,2),size(temp,3));

%         for z=1:size(vol,1)
%             vol(z,:,:)=mean(temp((z-1)*4+1:min(z*4,thickness),:,:),1);
%         end
        vol=slice;%temp;
        
        row = round(Xcen(in)/1)-round(Xsize/2)+1:round(Xcen(in)/1)+round(Xsize/2);
        column = round(Ycen(in)/1)-round(Ysize/2)+1:round(Ycen(in)/1)+round(Ysize/2);  


        for j=1:size(vol,1)
            Masque2(row,column,j)=ramp;
            Masque(row,column,j)=Masque(row,column,j)+Masque2(row,column,j);
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*Masque2(row,column,j);        
        end 
    end

    Ret=single(Mosaic./Masque);
    Ret(isnan(Ret(:)))=0;
%     aip=squeeze(mean(Ret,3));
%     save(strcat(datapath, 'dist_corrected/volume/ret',num2str(nslice),'.mat'),'Ret','-v7.3');

% save as TIFF

%     s=uint16(65535*(mat2gray(Mosaic))); 
%     
%     tiffname=strcat(datapath,'dist_corrected/volume/ret',num2str(nslice),'.tif');
% 
%     for i=1:size(Ret,3)
%         t = Tiff(tiffname,'a');
%         image=squeeze(Ret(:,:,i));
%         tagstruct.ImageLength     = size(image,1);
%         tagstruct.ImageWidth      = size(image,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Compression = Tiff.Compression.None;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(image);
%         t.close();
%     end
clear options;
options.big = true; % Use BigTIFF format
saveastiff(Ret, strcat(datapath,'dist_corrected/volume/ret',num2str(nslice),'.btf'), options);
    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end