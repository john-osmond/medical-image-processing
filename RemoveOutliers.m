% Script to accept a data, dark and open image and apply correction

function [Img, Map] = RemoveOutliers(Img)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Removing Outliers...');

Map = Img(:,:,1)*0 + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove columns with extremely outlying mean:

XMProf = nanmean(nanmean(Img,3),1);

Q = quantile(XMProf,[0.25 0.5 0.75]);
IQRAll = iqr(XMProf);
LimLo = Q(1) - 3*IQRAll;
LimHi = Q(3) + 3*IQRAll;

Map(:,XMProf < LimLo | XMProf > LimHi) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove columns with extremely outlying STD:

XSProf = nanmean(nanstd(Img,0,1),3);

Q = quantile(XSProf,[0.25 0.5 0.75]);
IQRAll = iqr(XSProf);
LimLo = Q(1) - 3*IQRAll;
LimHi = Q(3) + 3*IQRAll;

Map(:,XSProf < LimLo | XSProf > LimHi) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove rows with extremely outlying mean:

YMProf = nanmean(nanmean(Img,3),2);

Q = quantile(YMProf,[0.25 0.5 0.75]);
IQRAll = iqr(YMProf);
LimLo = Q(1) - 3*IQRAll;
LimHi = Q(3) + 3*IQRAll;

Map(YMProf < LimLo | YMProf > LimHi,:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove rows with extremely outlying STD:

YSProf = nanmean(nanstd(Img,0,2),3);

Q = quantile(YSProf,[0.25 0.5 0.75]);
IQRAll = iqr(YSProf);
LimLo = Q(1) - 3*IQRAll;
LimHi = Q(3) + 3*IQRAll;

Map(YSProf < LimLo | YSProf > LimHi,:) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove pixels with extremely outlying mean:

%MImg = nanmean(Img,3);

%Q = quantile(MImg,[0.25 0.5 0.75]);
%IQRAll = iqr(reshape(MImg,1,[]));
%LimLo = Q(1) - 1.5*IQRAll;
%LimHi = Q(3) + 1.5*IQRAll;

%Map(MImg < LimLo | MImg > LimHi) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove pixels with extremely outlying STD:

%SImg = nanstd(Img,0,3);

%Q = quantile(SImg,[0.25 0.5 0.75]);
%IQRAll = iqr(reshape(SImg,1,[]));
%LimLo = Q(1) - 3*IQRAll;
%LimHi = Q(3) + 3*IQRAll;

%Map(SImg < LimLo | SImg > LimHi) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove all outlying pixels:

Q = quantile(reshape(Img,1,[]),[0.25 0.5 0.75]);
IQRAll = iqr(reshape(Img,1,[]));
LimLo = Q(1) - 3*IQRAll;
LimHi = Q(3) + 3*IQRAll;

Img(Img < LimLo | Img > LimHi) = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Apply map to data:

for i = 1:size(Img,3)
    Img(:,:,i) = Img(:,:,i).*Map;
end
disp([num2str(sum(sum(isnan(Map)))) ' bad pixels removed.']);

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end