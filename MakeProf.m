% INTRODUCTION

% Script to generate 1D profile from 2D image.

% Inputs: Img = Image, Dir = Direction of Profile (X,Y), Range = Range of
% values in orthogonal direction to include in profile.

% Outputs: Limits = 50% of Maximum Limits.

function [Limits] = MakeProf(Img, Dir, Range)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MAIN BODY

% Make profile:

if ( strcmp(Dir,'X') == 1 )
    
    Prof = mean(Img(:,Range(1):Range(2)),2);
    
elseif ( strcmp(Dir,'Y') == 1 )
    
    Prof = mean(Img(Range(1):Range(2),:),1);
    
end

% Find 50% of maximum limits:

Prof(1:5) = 0;
Prof(length(Prof)-4:end) = 0;
Ind = find(Prof>0.5*max(Prof));
Limits = [Ind(1) Ind(end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% REPORT AND EXIT

%plot(Prof);
    
end