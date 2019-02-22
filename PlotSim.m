% Read variables from ASCII text file and export in a structured array.

function [Var] = PlotSim(File)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

OutDir = '/Users/josmond/Results/Simulations'
File = '/Users/josmond/Results/Simulations/DoseDistribution.out'

% Open file:

FID = fopen(File);
Data = textscan(FID, '%u8 %f %f %f');
fclose(FID);

X = Data{1};
Y = Data{2};
Z = Data{3};
Score = Data{4};

clear Data;

[X,Ind] = sort(X);
Y = Y(Ind);
Z = Z(Ind);
Score = Score(Ind);

length(X)

Image = zeros(1000,1000);
for i = 1:length(X)
   Image(Y(i),Z(i)) = Image(Y(i),Z(i)) + Score(i);
end

imtool(Image);
pause

plot(X,Score)

ylabel('Score');
xlabel('Depth');
WritePlot(OutDir, ['DepthDose'], 'n', 'y');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RespTime=[33 13 6 8 6 12 1]

UpDate=[...
    19.09 07.09 05.09 01.09...
    30.08 29.08 26.08 25.08 19.08 14.08 01.08... 
    14.07 ...
    27.06 18.06 17.06 11.06 11.06 08.06...
    31.05 29.05 28.05 27.05 26.05 22.05 19.05 17.05...
    28.04 26.04 25.04 24.04 12.04 10.04 04.04 01.04...
    16.03 13.03 04.03...
    22.02 16.02...
    31.01 29.01 26.01 13.01 09.01 08.01 04.01 03.01...
    ];

Update= [08 02 03 08 08 06 01 07 04 ];
Message=[00 01 01 00 03 01 02 03 01];

UpFreq=[12 2 4 2 1 3 1 6 5 13 18 17 9 1 6 1 3 8 2 1 1 1 4 3 2 19 2 1 1 12 2 6 3 16 3 9 10 6 16 2 3 13 4 1 4 1];

% Update Mean = 6 days +/- 5 days

% Last two updates: 12 days, 9+ days.

end