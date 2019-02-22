% Open image data for different devices.

function [Img] = ReadData(Name, Frames, ROICo)

disp('Starting ReadData...');

if CountEnv({'InDir' 'Ins'}) < 2;
    disp('Missing environment variables');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch lower(getenv('Ins'))
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DYNAMITE P:
    
    case {'dynamitep'}
        
        disp(['Reading Dynamite data from ' Name '.']);
        
        % Set variables:
        
        Ext = 'smv';
        Class = 'uint16';
        ByteDepth = 2;
        Width = 2560;
        Height = 1312;
        
        if numel(Frames) == 0
            File = dir([getenv('InDir') '/' Name '.' Ext]);
            Frames = [1 (File.bytes-512)/(Width*Height*ByteDepth)];
        end
        
        NumFrames = double(diff(Frames)+1);
        OffSet = 512 + (Width*Height*ByteDepth*(Frames(1)-1));
        
        % Read Image
        
        Img = multibandread([getenv('InDir') '/' Name '.' Ext],...
            [Height, Width, NumFrames], Class, OffSet, 'bsq', 'ieee-le');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DYNAMITE SP:
    
    case {'dynamitesp'}
        
        disp(['Reading Dynamite data from ' getenv('InDir') '/' Name '.']);
        
        % Set variables:
        
        Ext = 'smv';
        ClassIn = 'uint16';
        ClassOut = 'double';
        ByteDepth = 2;
        Width = 5120;
        Height = 2624;
        
        if Frames; else
            File = dir([getenv('InDir') '/' Name '.' Ext]);
            Frames = [1 (File.bytes-512)/(Width*Height*ByteDepth)];
        end
        
        NumFrames = double(diff(Frames)+1);
        OffSet = 512 + (Width*Height*ByteDepth*(Frames(1)-1));
        
        Img = multibandread([getenv('InDir') '/' Name '.' Ext],...
            [Height, Width, NumFrames], ClassIn, OffSet, 'bsq', 'ieee-le');
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DYNAMITE FUCKED:
    
    case {'dynamitefucked'}
        
        disp(['Reading Fucked Dynamite data from ' getenv('InDir') '/' Name '.']);
        
        % Set variables:
        
        Ext = 'smv';
        ClassIn = 'uint16';
        ClassOut = 'double';
        ByteDepth = 2;
        Width = 5120;
        Height = 2624;
        
        if Frames; else
            File = dir([getenv('InDir') '/' Name '.' Ext]);
            Frames = [1 (File.bytes-512)/(Width*Height*ByteDepth)];
        end
        
        NumFrames = double(ceil((diff(Frames)+1)/3));
        Img = zeros([Height Width NumFrames], ClassOut);
        
        for i =1:NumFrames
            
            FrameSkip = (Frames(1)-1) + (3*(i-1));
            FrameSize = Width*Height*ByteDepth;
            OffSet = 512 + (FrameSize*FrameSkip);
            
            Img(:,:,i) = multibandread([getenv('InDir') '/' Name '.' Ext],...
            [Height, Width, 1], ClassIn, OffSet, 'bsq', 'ieee-le');
        
        end
        
        % ROICo = [1 2560 1 2616];
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% EPID:

case {'epid'}
    
    disp(['Reading EPID data from ' getenv('InDir') '/' Name '.']);
    
    % Convert frames to dec unless variable empty then list all files:
    
    if Frames
        Frames = hex2dec(Frames);
    else
        Files = dir([getenv('InDir') '/*.his']);
        for i = 1:size(Files,1)
            [~, NumHex, ~, ~] = fileparts(Files(i).name);
            NumDec(i) = hex2dec(NumHex);
        end
        NumDecSort = sort(NumDec);
        Frames = [NumDecSort(1) NumDecSort(end)];
    end
    
    % Set variables:
    
    ClassIn = 'uint16';
    ClassOut = 'double';
    Width = 1024;
    Height = 1024;
    NumFrames = diff(Frames)+1;
    
    % Open file:
    
    FID = fopen(fname);
    fseek(FID, 0, 'bof');
    
    % Read header info:
    
    Hdr.FileType        = fread(FID, 1, 'uint16');
    Hdr.HeaderSize      = fread(FID, 1, 'uint16');
    Hdr.HeaderVersion   = fread(FID, 1, 'uint16');
    Hdr.FileSize        = fread(FID, 1, 'uint32');
    Hdr.ImageHeaderSize = fread(FID, 1, 'uint16');
    Hdr.ULX             = fread(FID, 1, 'uint16');
    Hdr.ULY             = fread(FID, 1, 'uint16');
    Hdr.BRX             = fread(FID, 1, 'uint16');
    Hdr.BRY             = fread(FID, 1, 'uint16');
    Hdr.NrOfFrames      = fread(FID, 1, 'uint16');
    Hdr.Correction      = fread(FID, 1, 'uint16');
    Hdr.IntegrationTime = fread(FID, 1, 'double');
    Hdr.TypeOfNumbers   = fread(FID, 1, 'uint16');
  
    fseek(FID, Hdr.HeaderSize, 'bof');
    fread(FID, Hdr.ImageHeaderSize, 'uchar');
    Img = zeros(Hdr.BRY, Hdr.BRX, Hdr.NrOfFrames, ClassOut);
    
    if Hdr.NrOfFrames==1, max_read=1; else max_read=Hdr.NrOfFrames-1; end;
    
    for k = 1:max_read
        for y = 1:Hdr.BRY
            Img(y,:,k) = fread(FID, Hdr.BRX, [ClassIn '=>' ClassOut]);
        end
    end
    
    %Img(:,:,k) = flipud(fread(FID, [Hdr.BRY Hdr.BRX], [ClassIn '=>' ClassOut]));
  
    fclose(FID);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% KINECT:
    
    case {'kinect'}
        
        disp(['Reading Kinect data from ' getenv('InDir') '/' Name '.']);
        
        % Set variables:
        
        Ext = 'bin';
        ClassIn = 'uint8';
        ClassOut = 'double';
        ByteDepth = 2;
        Width = 320;
        Height = 240;
        
        if Frames; else
            Files = dir([getenv('InDir'), '/', Name, '/DepthImg*.' Ext]);
            Frames(1) = 0;
            Frames(2) = size(Files,1)-1;
        end
        
        NumFrames = diff(Frames)+1;
        
        % Initiate image array:
        
        Img = zeros([Height Width NumFrames], ClassOut);
        
        % Open file and skip to first frame:
        
        for i = 1:NumFrames
            j = i+Frames(1)-1;
            FileName = sprintf('DepthImg%04i.%s', j, Ext);
            FID = fopen([getenv('InDir'), '/', Name, '/', FileName ], 'r');
            if FID < 0, error('Could not find file'); end;
            
            ImgTemp = fread(FID, [2, Height*Width], [ClassIn '=>' ClassOut]);
            ImgA = permute(reshape(ImgTemp(1,:),[Width Height]), [2 1]);
            ImgB = permute(reshape(ImgTemp(2,:),[Width Height]), [2 1]);
            Img(:,:,i) = ImgA + bitshift(ImgB, 8);
            
            fclose(FID);
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LAS:
    
    case {'las'}
        
        disp(['Reading LAS data from ' getenv('InDir') '/' Name '.']);
        
        % Read number of rows:
        
        FID = fopen([getenv('InDir') '/' Name '.txt'], 'r');
        fseek(FID, 0, 'bof');
        Null = textscan(FID, '%s', 6, 'delimiter', '\n');
        Data = textscan(FID, '%s %u32', 1, 'delimiter', '()');
        Rows = Data{2};
        fclose(FID);
        
        % Set variables:
        
        Ext = 'raw';
        ClassIn = 'uint16';
        ClassOut = 'double';
        ByteDepth = 2;
        Width = Rows;
        Height = 1350;
        Area = Width*Height;
        NumFrames = diff(Frames)+1;
        
        % Initiate image array:
        
        Img = zeros([Height Width NumFrames], ClassOut);
        
        % Open file and skip to first frame:
        
        FID = fopen([getenv('InDir') '/' Name '.' Ext], 'r');
        if FID < 0, error('Could not find file'); end;
        fseek(FID, Area*(Frames(1)-1)*ByteDepth, 'bof');
        
        % Read frames into image stack:
        
        for i = 1:NumFrames
            Img(:,:,i) = fread(FID, [Height, Width], [ClassIn '=>' ClassOut]);
        end
        
        % Blank dead rows:
        
        for j = 1:135:1216
            Img(j,:,:) = NaN;
        end
        
        fclose(FID);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SHARK:
    
    case {'shark'}
        
        disp(['Reading Shark data from ' getenv('InDir') '/' Name '.']);
        
        % Set constants:
        
        ClassIn = 'uint16';
        ClassOut = 'double';
        Width = 1024;
        Height = 1024;
        NumFrames = diff(Frames)+1;
        
        % Initialise image:
        
        Img = zeros([Height Width NumFrames], ClassOut);
        
        % Loop round frames:
        
        for i = 1:NumFrames
            
            % Set extension:
            
            Ext = sprintf('%03u',Frames(1)+i-1);
            
            % Open image:
            
            FID = fopen([getenv('InDir') '/' Name '.' Ext],'r');
            if FID < 0, error('Could not find file'); end;
            
            % Read image:
            
            fseek(FID, 0, 'bof');
            Img(:,:,i) = flipud(fread(FID, [Height Width], [ClassIn '=>' ClassOut]));
            
            % Close image:
            
            fclose(FID);
            
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VANILLA:

    case {'vanilla'}
        
        disp(['Reading Vanilla data from ' getenv('InDir') '/' Name '.']);
        
        ClassIn = 'uint16';
        ClassOut = 'double';
        ByteDepth = 2;
        Width = 520;
        Height = 520;
        Area = Width*Height;
        NumFrames = diff(Frames)+1;
        
        Img = zeros([Height Width NumFrames], ClassOut);
        
        FID = fopen([getenv('InDir') '/' Name],'r');
        if FID < 0, error('Could not find file'); end;
        fseek(FID, Area*(Frames(1)-1)*ByteDepth, 'bof');
        
        for i = 1:NumFrames
            Img(:,:,i) = fread(FID, [Height, Width], [ClassIn '=>' ClassOut]);
        end
        
        fclose(FID);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VANILLA OLD:

    case {'vanold'}
        
        disp(['Reading Old Vanilla data from ' getenv('InDir') '/' Name '.']);
        
        Ext = 'mi3';
        ClassIn = 'uint8';
        ClassOut = 'double';
        Width = 520;
        Height = 520;
        Area = Width*Height;
        NumFrames = diff(Frames)+1;
        
        Img = zeros([Width Height NumFrames], ClassOut);
                       
        for i = Frames(1):Frames(2)
            
            FID = fopen([getenv('InDir') '/' Name '_' num2str(i) '.' Ext],'r');
            if FID < 0, error('Could not find file'); end;
            LSB = fread(FID,Area,ClassIn);
            MSB = bitand(fread(FID,Area,ClassIn), 15);
            Img(:,:,i) = reshape(4095 - (uint16(LSB)+uint16(MSB)*256),Width,Height);
            fclose(FID);
            
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
% XVI:
    
    case {'xvi'}
        
        %disp(['Reading XVI data from ' getenv('InDir') '/' Name '.']);
        
        % Convert frames to dec unless variable empty then list all files:
        
        Files = dir([getenv('InDir') '/*.his']);
        for i = 1:size(Files,1)
            [~, NumHex, ~, ~] = fileparts(Files(i).name);
            NumDec(i) = hex2dec(NumHex);
        end
        NumDecSort = sort(NumDec);
        FramesOut = [NumDecSort(1) NumDecSort(end)];
        
        if Frames
            FramesOut = [FramesOut(1)+Frames(1)-1 FramesOut(1)+diff(Frames)];
        end
        
        % Set variables:
        
        ClassIn = 'uint16';
        ClassOut = 'double';
        Width = round(sqrt((Files(1).bytes)/2));
        Height = round(sqrt((Files(1).bytes)/2));
        NumFrames = diff(FramesOut)+1;
        Ext = 'his';
        
        % Initialise image array:
        
        Img = zeros([Height Width NumFrames], ClassOut);
        
        % Loop round frames:
        
        for i = 1:NumFrames
            
            % Set basename:
            
           BaseName = dec2hex(FramesOut(1)+i-1,8);
           
           % Open file, read pixel values and write to array:
           
           FID = fopen([getenv('InDir') '/' BaseName '.' Ext],'r');
           fseek(FID, 0, 'bof');
           Img(:,:,i) = fliplr(fread(FID, [Height Width], [ClassIn '=>' ClassOut]));
           fclose(FID);
           
        end
        
        % Shift rows up:
           
        Img = circshift(Img, [-51, 0, 0]);
        Img(size(Img,1)-51+1:end,:,:) = ...
            circshift(Img(size(Img,1)-51+1:end,:,:), [0, 1, 0]);
        
        Img = nanmax(reshape(Img,1,[])) - Img;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end

% Select ROI:

if ROICo; Img = Img(ROICo(3):ROICo(4),ROICo(1):ROICo(2),:); end

disp('...done.');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end