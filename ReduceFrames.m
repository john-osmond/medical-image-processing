function [] = ReduceFrames(FileNames, Num)

display('Starting ReduceFrames...');

if CountEnv({'InDir' 'Ins'}) < 2;
    disp('Missing environment variables');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:numel(FileNames)
    
    % Calculate Name and number of frames for this dataset:
    
    File = dir([getenv('InDir') '/' char(FileNames(i)) '.*']);
    [~, Name, Ext, ~] = fileparts(File.name);
    
    display(['Reducing file ' Name '...']);
    
    TotalFrames = (File.bytes-str2double(getenv('BytesPerHeader')))/...
        str2double(getenv('BytesPerFrame'));
    
    if numel(Num) == 0
        Num = TotalFrames;
    end
    
    % Calculate mean and standard deviation images:
    
    iHi = floor(TotalFrames/Num);
    for i = 1:iHi
        
        display(['Processing group ' num2str(i) ' of ' num2str(iHi) '...']);
        
        % Open relevant frames:
        
        Frames = [(i*Num)-Num+1 (i*Num)];
        [ImgMean, ImgSD] = StatData(Name, [], [], Frames, [], 10);
        
        % Write mean and SD images:
        
        WriteData(ImgMean, [Name 'Mean' num2str(Num)], i);
        WriteData(ImgSD, [Name 'SD' num2str(Num)], i);
        
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display('...done');

end