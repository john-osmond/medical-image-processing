function [ output_args ] = his2avi( fname )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

scale_max_sequence_frame=0 %scale to maximum pixel in the movie if 1
make_movie=1; %make the movie if 1
frame_per_second=2.300966 %set frames per second
crop=1; %shall we crop image?
crop_left=200; 
crop_right=825;
crop_top=150;
crop_bottom=1000;


if scale_max_sequence_frame==1
    out_name=[fname(1:end-4),'max_seq.avi']
else
    out_name=[fname(1:end-4),'max_perframe.avi']
end

%find the maximum and average pixels in the sequence
hFile = fopen( fname );
fseek( hFile, 0, -1);  
Hdr.FileType = fread( hFile, 1, 'uint16' );
if Hdr.FileType ~= 28672
    return
    fclose( hFile )
end
Hdr.HeaderSize = fread(hFile, 1, 'uint16');
Hdr.HeaderVersion = fread(hFile, 1, 'uint16');
Hdr.FileSize = fread(hFile, 1, 'uint32');
Hdr.ImageHeaderSize = fread(hFile, 1, 'uint16');
Hdr.ULX = fread(hFile, 1, 'uint16');
Hdr.ULY = fread(hFile, 1, 'uint16');
Hdr.BRX = fread(hFile, 1, 'uint16');
Hdr.BRY = fread(hFile, 1, 'uint16');
Hdr.NrOfFrames = fread(hFile, 1, 'uint16');
Hdr.Correction = fread(hFile, 1, 'uint16');
Hdr.IntegrationTime = fread(hFile, 1, 'double');
Hdr.TypeOfNumbers = fread(hFile, 1, 'uint16'); 
fseek( hFile, Hdr.HeaderSize, -1);
fread( hFile, Hdr.ImageHeaderSize, 'uchar');
max_in_seq=0; 
max_average_pixel_value=0;
for k = 1: Hdr.NrOfFrames
    prog_read_find_max=k
    for y = 1:Hdr.BRY        
        temp_Img(y,:) = double(fread(hFile, Hdr.BRX, 'uint16'));       
    end
    max_in_frame_current=max(max(temp_Img));
    if max_in_seq<max_in_frame_current
        max_in_seq=max_in_frame_current;
    end
    average_pixel_value(k)=mean(mean(temp_Img));
    if max_average_pixel_value<average_pixel_value(k)
        max_average_pixel_value=average_pixel_value(k);
    end
    
    max_pixel_value(k)=max_in_frame_current;
    %simple statement to see if we can crop the image at the end (assumed
    %we have more than 10 frames)
    if average_pixel_value(k)<2 && max_average_pixel_value>10
        frames_to_miss=Hdr.NrOfFrames-k
        break
    end    
end
fclose( hFile );
figure(3)
plot(average_pixel_value);


%now make the movie
hFile = fopen( fname );
fseek( hFile, 0, -1);  
Hdr.FileType = fread( hFile, 1, 'uint16' );
if Hdr.FileType ~= 28672
    return
    fclose( hFile )
end
Hdr.HeaderSize = fread(hFile, 1, 'uint16');
Hdr.HeaderVersion = fread(hFile, 1, 'uint16');
Hdr.FileSize = fread(hFile, 1, 'uint32');
Hdr.ImageHeaderSize = fread(hFile, 1, 'uint16');
Hdr.ULX = fread(hFile, 1, 'uint16');
Hdr.ULY = fread(hFile, 1, 'uint16');
Hdr.BRX = fread(hFile, 1, 'uint16');
Hdr.BRY = fread(hFile, 1, 'uint16');
Hdr.NrOfFrames = fread(hFile, 1, 'uint16');
Hdr.Correction = fread(hFile, 1, 'uint16');
Hdr.IntegrationTime = fread(hFile, 1, 'double');
Hdr.TypeOfNumbers = fread(hFile, 1, 'uint16');
fseek( hFile, Hdr.HeaderSize, -1);
fread( hFile, Hdr.ImageHeaderSize, 'uchar');
  
figure(1);  
map=colormap(gray(256));  

if make_movie==1
    aviobj = avifile(out_name,'compression','none','fps',frame_per_second);
end  

for k = 1: Hdr.NrOfFrames-frames_to_miss
    prog_read=k
    for y = 1:Hdr.BRY        
        temp_Img(y,:) = double(fread(hFile, Hdr.BRX, 'uint16'));
        
    end
    
    %fix any bad pixels missed by the pixel correction map
    y=455;
    x=490;
    temp_Img(x,y)=median(median(temp_Img(x-1:x+1,y-1:y+1)));
    y=774;
    x=444;
    temp_Img(x,y)=median(median(temp_Img(x-1:x+1,y-1:y+1)));
    y=863;
    x=981;
    temp_Img(x,y)=median(median(temp_Img(x-1:x+1,y-1:y+1)));
    y=984;
    x=841;
    temp_Img(x,y)=median(median(temp_Img(x-1:x+1,y-1:y+1)));
    y=926;
    x=515;
    temp_Img(x,y)=median(median(temp_Img(x-1:x+1,y-1:y+1)));
    
    %crop image if requested
    if crop==1
        frame=temp_Img(crop_left:crop_right,crop_top:crop_bottom);
    else
        frame=temp_Img;
    end

    image(frame,'CDataMapping','scaled');colormap(gray);    
    
    if scale_max_sequence_frame==1
        %scale to max in image sequence
        change_to=max_in_seq
        caxis([0 max_in_seq])
        caxis    
    else
        %do nothing it is already done to maximum in frame
        caxis
    end
    
    %get rid of figure axis and make it square
    set(gca,'Xtick',[],'ytick',[]);    
    axis square;
    axis off;
    output_movie(k)=getframe(gca);
    if make_movie==1
        aviobj = addframe(aviobj,output_movie(k));        
    end
end
  
fclose( hFile );

if make_movie==1
    aviobj=close(aviobj);
end

