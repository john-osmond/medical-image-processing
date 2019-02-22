function [Hdr, Img, Rng] = ReadHIS( fname )
% READHIS reads in a his format image and returns the header and image.
%   Usage :     [header, image] = readhis('C:\filename.his');
%           or  [header, image, pixel_vlaue_range] = readhis('C:\filename.his');
    
    hFile = fopen( fname );
    if hFile < 0, error('Could not find file'); end;  
    
    fseek( hFile, 0, -1);  
    Hdr.FileType = fread( hFile, 1, 'uint16' );
    if Hdr.FileType ~= 28672, fclose(hFile); return; end;
  
    Hdr.HeaderSize      = fread(hFile, 1, 'uint16');
    Hdr.HeaderVersion   = fread(hFile, 1, 'uint16');
    Hdr.FileSize        = fread(hFile, 1, 'uint32');
    Hdr.ImageHeaderSize = fread(hFile, 1, 'uint16');
    Hdr.ULX             = fread(hFile, 1, 'uint16');
    Hdr.ULY             = fread(hFile, 1, 'uint16');
    Hdr.BRX             = fread(hFile, 1, 'uint16');
    Hdr.BRY             = fread(hFile, 1, 'uint16');
    Hdr.NrOfFrames      = fread(hFile, 1, 'uint16');
    Hdr.Correction      = fread(hFile, 1, 'uint16');
    Hdr.IntegrationTime = fread(hFile, 1, 'double');
    Hdr.TypeOfNumbers   = fread(hFile, 1, 'uint16');
  
    fseek( hFile, Hdr.HeaderSize, -1);
    fread( hFile, Hdr.ImageHeaderSize, 'uchar');
    Img = zeros( Hdr.BRY, Hdr.BRX,Hdr.NrOfFrames,'uint16' );
    if Hdr.NrOfFrames==1, max_read=1; else max_read=Hdr.NrOfFrames-1; end;
    
    for k = 1: max_read
        if mod(k,10)==0, disp(['read in ',num2str(k),' / ',num2str(max_read)]); end;
        for y = 1:Hdr.BRY
            Img(y,:,k) = double( fread(hFile, Hdr.BRX, 'uint16'));
        end
    end
  
    Rng = [min(Img(:)) max(Img(:))];
  
    fclose( hFile );
  
    return;
end