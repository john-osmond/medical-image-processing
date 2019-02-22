% Open image data for different devices.

function [] = WriteData(Img, Name, FrameStart)

disp('Starting WriteData...');

if CountEnv({'OutDir' 'Ins' 'BytesPerHeader' 'BytesPerFrame'}) < 4;
    disp('Missing environment variables');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch lower(getenv('Ins'))
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DYNAMITE P:
    
    case {'dynamitep'}
        
        disp(['Writing Dynamite data to ' Name '...']);
        
        % Set variables:
        
        Ext = 'smv';
        %BytesPerPixel = 2;
        PixelsPerFrame = numel(Img(:,:,1));
        %BytesPerFrame = PixelsPerFrame*BytesPerPixel;
        Class = 'uint16';
        
        % Check if file exists:
        
        FileExist = exist([getenv('OutDir') '/' Name '.' Ext], 'file');
        
        % If file exists count number of existing frames
        
        if FileExist ~= 2
            
            % Open file, write header and count number of existing frames:
            
            FID = fopen([getenv('OutDir') '/' Name '.' Ext], 'w', 'ieee-le');
            fseek(FID, 0, 'bof');
            fwrite(FID, zeros(1, getenv('BytesPerHeader')/2), Class);
            FramesPerFile = 0;
            
        else
            
            % Open file and count number of existing frames:
            
            FID = fopen([getenv('OutDir') '/' Name '.' Ext], 'r+', 'ieee-le');
            File = dir([getenv('OutDir') '/' Name '.' Ext]);
            FramesPerFile = (File.bytes-getenv('BytesPerHeader'))/getenv('BytesPerFrame'); %
            
        end
        
        % Set default value of FrameStart:
        
        if numel(FrameStart) == 0;
            FrameStart = FramesPerFile + 1;
        end
        
        % Calculate number of blank frames and write:
        
        BlankFrames = FrameStart-FramesPerFile-1;
        
        if (BlankFrames > 0);
            fseek(FID, 0, 'eof');
            fwrite(FID, zeros(1,BlankFrames*PixelsPerFrame), Class);
        end
        
        % Seek to stsrt point:
        
        OffSet = getenv('BytesPerHeader') + ((FrameStart-1)*getenv('BytesPerFrame'));
        fseek(FID, OffSet, 'bof');
        
        % Write image to file:
        
        fwrite(FID, permute(Img, [2 1 3]), Class);
        
        % Close file:
        
        fclose(FID);
        
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sinogram:
    
    case {'sinogram'}
        
        disp(['Writing Sinogram data to ' Name '...']);
        
        % Set variables:
        
        Ext = 'bin';
        %BytesPerPixel = 2;
        PixelsPerFrame = numel(Img(:,:,1));
        %BytesPerFrame = PixelsPerFrame*BytesPerPixel;
        %BytesPerHeader = 0; % No of 8b bytes.  Divide by 2 to get 16b.
        Class = 'uint16';
        
        % Check if file exists:
        
        FileExist = exist([getenv('OutDir') '/' Name '.' Ext], 'file');
        
        % If file exists count number of existing frames
        
        if FileExist ~= 2
            
            % Open file, write header and count number of existing frames:
            
            FID = fopen([getenv('OutDir') '/' Name '.' Ext], 'w', 'ieee-le');
            fseek(FID, 0, 'bof');
            fwrite(FID, zeros(1, getenv('BytesPerHeader')/2), Class);
            FramesPerFile = 0;
            
        else
            
            % Open file and count number of existing frames:
            
            FID = fopen([getenv('OutDir') '/' Name '.' Ext], 'r+', 'ieee-le');
            File = dir([getenv('OutDir') '/' Name '.' Ext]);
            
            
            File.bytes
            
            FramesPerFile = (File.bytes-getenv('BytesPerHeader'))/getenv('BytesPerFrame'); %
            
        end
        
        % Set default value of FrameStart:
        
        if numel(FrameStart) == 0;
            FrameStart = FramesPerFile + 1;
        end
        
        % Calculate number of blank frames and write:
        
        BlankFrames = FrameStart-FramesPerFile-1;
        
        if (BlankFrames > 0);
            fseek(FID, 0, 'eof');
            fwrite(FID, zeros(1,BlankFrames*PixelsPerFrame), Class);
        end
        
        % Seek to start point:
        
        if (FrameStart > 1)
            OffSet = getenv('BytesPerHeader') + ((FrameStart-1)*getenv('BytesPerFrame'));
        else
            OffSet = 0;
        end
        fseek(FID, OffSet, 'bof');
        
        % Write image to file:
        
        fwrite(FID, Img, Class);
        
        % Close file:
        
        fclose(FID);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.');

end