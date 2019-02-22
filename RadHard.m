% INTRODUCTION

% Script to investigate the effect of radiation damage on dark current.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPERATION

% Prepare workspace:

clear
close all hidden
clc
tic

% Set variables:

Name = 'RadHard2';

Ins = 'Vanilla';
Ext = 'raw';

Frames = [11 400];
NumFrames = diff(Frames)+1;
GroupSize = 40;

% Set constants:

InDir = ['/Users/josmond/Data/' Ins '/' Name];
OutDir = ['/Users/josmond/Results/' Name];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%

[Img] = ReadData([InDir '/0_data.' Ext], Ins, Frames);
DarkImg = mean(Img,3);
clear Img

[Img] = ReadData([InDir '/rad_data.' Ext], Ins, [29 263]);
ImgSpot = mean(Img,3) - DarkImg;
Filter = fspecial('gauss', [21 21], 3);    
ImgSmooth = filter2(Filter, ImgSpot);
clear Img;

MaxVal = max(max(ImgSpot));

RadMask = ImgSmooth ./ ImgSmooth;
RadMask(find(ImgSmooth < 0.5*MaxVal)) = 0;
RadArea = sum(sum(RadMask));
RadFPNScl = prod(size(RadMask)) / RadArea;
RadStoScl = (NumFrames-1)/((RadArea*NumFrames)-1);

NonRadMask = ImgSmooth ./ ImgSmooth;;
NonRadMask(find(ImgSmooth >= 480)) = 0;
NonRadArea = sum(sum(NonRadMask));
NonRadFPNScl = prod(size(NonRadMask)) / NonRadArea;
NonRadStoScl = (NumFrames-1)/((NonRadArea*NumFrames)-1);

AllMask = RadMask + NonRadMask;

ImgSize = size(ImgSpot);
ImgArea = prod(ImgSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MAIN BODY

for Exp = 1:15

    Dose = 10*(2^(Exp-1))
    FileName = [InDir '/' num2str(Dose) '_data.' Ext];
    
    % Read data file:
    
    [Img] = ReadData(FileName, Ins, Frames);
     
    % Calculate noise properties:
    
    ImgNoise = zeros([ImgSize 4]);
    
    ImgNoise(:,:,1) = mean(Img,3);
    ImgNoise(:,:,3) = std(Img,0,3);
    ImgNoise(:,:,2) = ImgNoise(:,:,3)/sqrt(NumFrames);
    ImgNoise(:,:,4) = ImgNoise(:,:,3)/sqrt(2*(NumFrames-1));
    
    clear Img
    
    % Select regions:
    
    RadFPN = mean2(ImgNoise(:,:,1).*RadMask) * RadFPNScl;
    RadSto = sqrt(sum(sum((ImgNoise(:,:,2).*RadMask).^2))*RadStoScl);
    
    
    NonRadFPN = mean2(ImgNoise(:,:,1).*NonRadMask) * NonRadFPNScl;
    NonRadSto = sqrt(sum(sum((ImgNoise(:,:,2).*NonRadMask).^2))*NonRadStoScl);
    
    clear ImgNoise
      
    Out(:,Exp) = [Dose RadFPN RadSto NonRadFPN NonRadSto];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATE PLOTS

% Set plotting variables:

FontSize = 14;
LineWidth = 1.4;
MarkerSize = 10;
SlideForm = 'bmp';
PaperForm = 'eps';
Ind = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
Gain = 25;

Out(2:5,:) = Out(2:5,:)*Gain;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot stochastic noise vs dose:

semilogx(Out(1,Ind),Out(3,Ind),'-ko','LineWidth',LineWidth,...
    'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',MarkerSize);

hold on

norm = 1;
semilogx(Out(1,Ind),Out(5,Ind),'-ko','LineWidth',LineWidth,...
    'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',MarkerSize);

%sum((polyval([0.00016 13.7320],Out(1,:)) - Out(4,:)).^2)
%i = 8:600000;
%j = 0.000148*i + 13.7320;
%semilogx(i,j,'--k','LineWidth',LineWidth);

hold off

set(gca,'FontSize',FontSize,'LineWidth',LineWidth,...
    'XLim',[5 300000],'YLim',[2 6]);

%hline = refline(0,Out(4,1));
%set(hline,'LineStyle','--','LineWidth',LineWidth,'Color','k');

legend('Irradiated Region','Non-Irradiated Region','Location','NorthWest')

xlabel('Dose (MU)',...
    'FontSize',FontSize,'LineWidth',LineWidth);
ylabel('Dark Stochastic Noise (e^{-})',...
    'FontSize',FontSize,'LineWidth',LineWidth);

print(['-d' SlideForm],[OutDir '/sto.' SlideForm]);
print(['-d' PaperForm],[OutDir '/sto.' PaperForm]);

close;

pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot FPN vs dose:

semilogx(Out(1,Ind),Out(2,Ind),'-ko','LineWidth',LineWidth,...
    'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',MarkerSize);

hold on

norm = 1;
semilogx(Out(1,Ind),Out(6,Ind)*norm,'-ko','LineWidth',LineWidth,...
    'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',MarkerSize);

hold off

set(gca,'FontSize',FontSize,'LineWidth',LineWidth,'XLim',[8 60000]);

hline = refline(0,Out(2,1));
set(hline,'LineStyle','--','LineWidth',LineWidth,'Color','k');

legend('Irradiated Region','Non-Irradiated Region','Location','NorthWest')

xlabel('Dose (MU)',...
    'FontSize',FontSize,'LineWidth',LineWidth);
ylabel('Dark Fixed Pattern Noise (e^{-})',...
    'FontSize',FontSize,'LineWidth',LineWidth);

print(['-d' SlideForm],[OutDir '/fpn.' SlideForm]);
print(['-d' PaperForm],[OutDir '/fpn.' PaperForm]);

close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate image of spot:

FileName = [InDir '/ON2_data.' Ext];
Frames = [52 200];
[Img] = ReadData(FileName, Ins, Frames);

RadImg = Img(RadCo(2):RadCo(2)+RadCo(4)-1,...
    RadCo(1):RadCo(1)+RadCo(3)-1,:);

BG1Img = Img(BGCo1(2):BGCo1(2)+BGCo1(4)-1,...
    BGCo1(1):BGCo1(1)+BGCo1(3)-1,:);

BG2Img = Img(BGCo2(2):BGCo2(2)+BGCo2(4)-1,...
    BGCo2(1):BGCo2(1)+BGCo2(3)-1,:);

RadMean = mean2(RadImg);
RadSig = mean2(std(RadImg,0,3));

BGMean = mean([mean2(BG1Img) mean2(BG2Img)]);
BGSig = mean([mean2(std(BG1Img,0,3)) mean2(std(BG2Img,0,3))]);

SNR = RadMean / RadSig
CNR = (RadMean - BGMean)/sqrt((RadSig^2) + (BGSig^2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print image:

ImgSpot = mean(Img,3);

imagesc(ImgSpot);
colormap('gray');
axis square

RadCo = [120 140 240 220];
BGCo = [1 3 520 40];
BGCo2 = [1 480 520 40];

rectangle('Position',[RadCo(1),RadCo(2),RadCo(3),RadCo(4)],...
    'LineWidth',LineWidth,'EdgeColor','r');
rectangle('Position',[BGCo(1),BGCo(2),BGCo(3),BGCo(4)],...
    'LineWidth',LineWidth,'EdgeColor','r');
rectangle('Position',[BGCo2(1),BGCo2(2),BGCo2(3),BGCo2(4)],...
    'LineWidth',LineWidth,'EdgeColor','r');

print(['-d' SlideForm],[OutDir '/spot.' SlideForm]);

close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print another image:

ImgSpot = mean(Img,3);

imagesc(ImgSpot);
colormap('gray');
axis square;

Rad = [Spot(3), Spot(3)+50];

for i = 1:length(Rad)
    
    rectangle(...
        'Position',[Spot(2)-Rad(i),Spot(1)-Rad(i),Rad(i)*2,Rad(i)*2],...
        'Curvature',[1,1],'LineWidth',LineWidth,'EdgeColor','r');

end

rectangle('Position',[Box(3),Box(1),Box(4)-Box(3),Box(2)-Box(1)],...
    'LineWidth',LineWidth,'EdgeColor','r');

print(['-d' SlideForm],[OutDir '/spot.' SlideForm]);

close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Frequency Analysis:

%for i = 1:size(Img,3)
%    ImgCor(:,:,i) = Img(:,:,i) - ImgFPN;
%end
    
%ImgCrop = ImgCor(1:10,1:10,:);

%for i = 1:size(ImgCrop,1)
%    for j = 1:size(ImgCrop,2)
%        k = ((i-1)*size(ImgCrop,1) + j)*size(ImgCrop,3)-size(ImgCrop,3)+1;
        
%        img1d(k:k-1+size(ImgCrop,3)) = ImgCrop(i,j,:);
        
%    end    
%end

%plot(Img1D)

% Define no of points to use in Fourier Transform:

%POI = 1024;
%Nyq = round(POI/2);

% Calculate Fast Fourier Transform (FFT) of data:

%FFTy = fft(Img1D,POI);
%ps = ffty .* conj(ffty) / nyq;
%f =(1/0.25)*(0:(nyq))/poi;

% Plot Power Spectrum:

%plot(f,ps(1:(nyq+1)));
%xlabel('Frequency (Hz)');
%ylabel('Power');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% REPORT AND EXIT

% Complete and report time:

%fprintf('\n%s %3.1f%s\n','Completed in',toc,'s')