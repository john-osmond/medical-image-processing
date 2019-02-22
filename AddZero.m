function [] = addzero()

% Script to rename files.

% Assumptions:
% Files are numbered from zero.
% Files are successively numbered.
% Filenames contain no leading zeros.
% Files number less than one thousand.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round all files:

for no = 1:9
    
    movefile(['Patient01_0' num2str(no) '.his'] , ['Patient01_00' num2str(no) '.his'])

end