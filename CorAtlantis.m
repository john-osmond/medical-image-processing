% Correct image data

function [yDataCor] = CorAtlantis(xData, yData, xCo, yCo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CALCULATE RESIDUALS

disp(['Correcting data ...']);

% Fit line to data:

FitVals = polyfit(xData, yData, 1);
FitData = polyval(FitVals, xData);

% Calculate residuals from line:

ResData = yData - FitData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FIND ISOCENTRE

% Reduce xCo to unique values:
    
xCoUn = sort(unique(xCo));
yCoUn = sort(unique(yCo));

% Loop round values of x and calculate mean residual

for i = 1:4
    x = xCoUn(i);
    Ind = find(xCo == x);
    xRes = mean(ResData(Ind));
    xResData(:,i) = [x; xRes];
end

% Find intercept of two trend lines:

m1 = (xResData(2,2)-xResData(2,1))/(xResData(1,2)-xResData(1,1));
c1 = xResData(2,1) - m1*xResData(1,1);
m2 = (xResData(2,4)-xResData(2,3))/(xResData(1,4)-xResData(1,3));
c2 = xResData(2,3) - m2*xResData(1,3);
xIso = (c2-c1)/(m1-m2);

% Loop round values of y and calculate mean residual

for i = 1:4
    y = yCoUn(i);
    Ind = find(yCo == y);
    yRes = mean(ResData(Ind));
    yResData(:,i) = [y; yRes];
end

% Find intercept of two trend lines:

m1 = (yResData(2,2)-yResData(2,1))/(yResData(1,2)-yResData(1,1));
c1 = yResData(2,1) - m1*yResData(1,1);
m2 = (yResData(2,4)-yResData(2,3))/(yResData(1,4)-yResData(1,3));
c2 = yResData(2,3) - m2*yResData(1,3);
yIso = (c2-c1)/(m1-m2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CORRECT DATA

% Calculate correction function:

rData = sqrt(((xCo-xIso).^2)+((yCo-yIso).^2));
CorVals = polyfit(rData, ResData, 1);
CorData = polyval(CorVals, rData);

disp(['Using correction function: Residual = ', num2str(CorVals(1)) '.r + ' num2str(CorVals(2))]);

% Correct data:

yDataCor = yData - CorData;

disp(['... done.']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end