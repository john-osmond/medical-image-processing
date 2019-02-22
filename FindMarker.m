% INTRODUCTION

% Script to process image data of Atlantis phantom.

function [y, ConNorm, CNR] = FindMarker(Img, MarkX, MarkY)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%disp('Finding markers...');

%Img = DataAdd(:,:,1);
%[Y, CNR] = FindMarker(Data(:,:,1), MarkX-ROICo(1));

% Set variables:

%Dimm = [2 1.6 1.2 0.8];
%Di = Dimm*Scale;
%Rad = Di/2;

%DiRound = round(Di);
%RadRound = round(Rad);

KernFile = {'2.0mm.txt' '1.6mm.txt' '1.2mm.txt' '0.8mm.txt'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Crop and smooth image and calculate profile:

ImgCrop = Img(:,MarkX(1):MarkX(2));
Prof = nanmedian(ImgCrop,2);

% Interpolate nan values in profile:

X = 1:numel(Prof);
Prof(isnan(Prof)) = interp1(X(isfinite(Prof)), Prof(isfinite(Prof)), X(isnan(Prof)));

% Loop round markers and find position:

for i = 1:4
    
    % Create filter:
    
    D = importdata(['Users/josmond/Data/Kernel/' char(KernFile(i))]);
    
    %clear D;
    %for j = 1:DiRound+1
    %    r = abs(j-(RadRound(i)+1));
    %    if (r > RadRound(i)); r = RadRound(i); end;
    %    D(j) = DiRound(i) - 2*sqrt((RadRound(i)^2)-(r^2));
    %end
    
    KernWidth(i) = numel(D);
    
    % Convolve with profile:

    DNeg = max(D) - D;
    ProfNeg = max(Prof) - Prof;
    ProfConvNeg = reshape(real(conv(ProfNeg,DNeg)),1,[]);
    ProfConvShift = max(ProfConvNeg) - ProfConvNeg;
    ProfConv = ProfConvShift(floor(numel(D)/2):end);
    
    % Remove previous  markers from profile:
    
    for k = 1:i-1
        
        yLo = round(y(k)-1.1*KernWidth(k));
        yHi = round(y(k)+1.1*KernWidth(k));
        
        if ( yLo < 1 )
            yLo = 1;
        elseif ( yHi > size(ImgCrop,1) );
            yHi = size(ImgCrop,1);
        end
        
        ProfConv(yLo:yHi) =  NaN;
        
    end
    
    % Find minimum and calculate signal:
        
    yMin = find(ProfConv == nanmin(ProfConv));
    y(i) = yMin(1); % In case of two minima.
    
    % Define region containing marker:
    
    if MarkY
        yLo = round(MarkY(i)-1.1*KernWidth(i));
        yHi = round(MarkY(i)+1.1*KernWidth(i));
    else
        yLo = round(y(i)-1.1*KernWidth(i));
        yHi = round(y(i)+1.1*KernWidth(i));
    end
    
    % Check if marker is at edge of range:
    
    if ( yLo < 1 )
        yLo = 1;
    elseif ( yHi > size(ImgCrop,1) );
        yHi = size(ImgCrop,1);
    end
    
    MarkSig(i) = nanmin(Prof(yLo:yHi));
    HighSig(i) = nanmax(Prof(yLo:yHi));
    
    % Check data:
    
    %subplot(2,1,1);
    %plot(ProfConv);
    %hold on;
    %line([y(i) y(i)],[min(ProfConv) max(ProfConv)],'color','r')
    %xlim([0 1000])
    %hold off;
    %pause
    %subplot(2,1,2);
    %plot(Prof)
    %xlim([0 1000])
    %line([y(i) y(i)],[min(Prof) max(Prof)],'color','r')
    %pause
    %close;
        
end

% Calculate ambient mean and std:

%AmImg = Img(1:50,:);
%AmSig = nanmedian(reshape(AmImg,1,[]));

% Calculate contrast and CNR:

Contrast = abs(MarkSig-HighSig);
ConNorm = 100*abs(MarkSig-HighSig)./HighSig;
Noise = nanstd(reshape(Img(1:50,:),1,[]));
CNR = Contrast./Noise;

%disp(['Con: ' num2str(round(Contrast(:,1)))...
%    ', Noise: ' num2str(round(Noise(:,1)))...
%    ', CNR: ' num2str(round(CNR(:,1)))]);

%disp('...done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end