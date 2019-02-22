% SCRIPT FOR BOB TO READ VANILLA IMAGE DATA FROM FILE AND PROCESS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% START UP

% Clear variables and screen:

clear all
clc

% Set variables:

indir = '/Users/josmond/Data/Vanilla/Bob';
outdir = '/Users/josmond/Results/Bob';
name = '14janmultiholelight10';
ext = 'raw';
startframe = 4;
endframe = 10;
xwid = 520;
ywid = 520;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ DATA

% Open file:
    
fid = fopen([indir '/' name '_data.' ext], 'r');
    
for i = 1:endframe
        
% Read each frame:
        
img(:,:,i) = double(fread(fid, [xwid, ywid], 'uint16'));

end
    
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PROCESS DATA

% Calculate mean image:

imgmean = mean(img,3);

% View image (Uncomment):

%imtool(imgmean);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WRITE DATA

% Display image:

imagesc(imgmean);
colormap(gray);

% Format image:

set(0,'DefaultLineLineWidth',1.4,...
    'DefaultTextFontSize',14,...
    'DefaultAxesFontSize',14);
set(gca,'linewidth',1.4);
xlabel('X');
ylabel('Y');

% Print image in 3 formats:

plotname = 'image';
print('-djpeg',[outdir '/' plotname '.jpg']);
print('-depsc2','-tiff',[outdir '/' plotname '_col.eps']);
print('-deps2',[outdir '/' plotname '_bw.eps']);

% Close image:

close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%