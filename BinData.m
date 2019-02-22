% Script to add 

function [XBin, YBin, YBinErr, NBin] = BinData(X, YIn, XLo, XHi, NumBins)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Binning Data...');

% Calculate width and X position of bins:

XWid = (XHi-XLo)/NumBins;
XBin = XLo+(XWid/2):XWid:XHi-(XWid/2);

% Loop round bins and calculate Y values:

for i=1:size(XBin,2);
    if (i == 1)
        Ind = find((X>=XBin(i)-(XWid/2)) & (X<=XBin(i)+(XWid/2)));
    else
        Ind = find(X>XBin(i)-(XWid/2) & X<=XBin(i)+(XWid/2));
    end
    YBin(i) = nanmean(YIn(Ind));
    YBinErr(i) = nanstd(YIn(Ind));
    NBin(i) = numel(Ind);
end

disp('...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end