clear all
close all hidden
clc

Dir = '/Users/josmond/Data/LAS/Moving_Marker';
DataName = 'head4_data.raw';
DarkName = 'darkforhead_data.raw';
OpenName = 'openforhead_data.raw';
Ins = 'LAS';
Frames = [3 50];

% Read dark data:

[Dark] = ReadData([Dir '/' DarkName], Ins, Frames);

DarkImg = mean(Dark,3);
clear Dark;

% Read open data:

[Open] = ReadData([Dir '/' OpenName], Ins, Frames);


OpenImg = mean(Open,3) - DarkImg;
OpenImg(find(OpenImg == 0)) = 1;
OpenImg = OpenImg/max(max(OpenImg));
clear Open;

% Read data:

[Data] = ReadData([Dir '/' DataName], Ins, Frames);

DataImg = medfilt2((mean(Data,3)-DarkImg)./OpenImg, [3 3]);
clear Data;

imtool(DataImg)