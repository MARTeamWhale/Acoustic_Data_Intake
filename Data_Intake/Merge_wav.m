
%Merge_wav.mat 
%merge and move AMAR .wav files
tic;
clear
close all

%%%%% Make changes as needed %%%%%
%enter path to highest data folder

Path2Data = 'D:\MERGE_TEST\MGL_2023_08_backup';
Path2Output = 'D:\MERGE_TEST\MGL_2023_08_merged';

START_FILE = ''; %leave blank to start from beginning. Only use when process was interrupted
%recording interval
%ri = 900; %seconds
%maxDur = seconds(240);
%multi-channel? incomplete
%NumSamplerates = 1;
%switch the moving of non-acoustic files on (1) and off (0)
move_NonAcoustic = 1; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ri = seconds(ri); % interval to duration
files = dir(fullfile(Path2Data, '**\*.wav')); %Recursively find all WAV files 
filetable = struct2table(files);              %convert to table
filetable.saved = zeros(size(files,1),1);     %Create variable to keep track of which files are saves
filetable.merged = zeros(size(files,1),1);     %Create variable to keep track of which files are merged
File_collector = [];                          %Initialize variable to collect data
f = 1;                                        %Set up f to mark first file
k = 0;                                        
merge = 0;
s = 0;
%return good to this point
%for f = 1:length(files) %beginning of files loop

while f <= length(files)-1 && k < length(files)%beginning of files loop   
    
    if k ~= 0 && merge == 1
    f = k;
    end

    if ~isempty(START_FILE) && s == 0
        for restart = 1:length(files)
            if strcmp(START_FILE,files(restart).name) == 1
               f = restart;
               s = 1;
            end
        end
    end
    ffirst = files(f).name;
    filepath = files(f).folder;
    fullpath = strcat(filepath,'\',ffirst);
    dt = readDateTime(fullpath);
    info = audioinfo(fullpath);
    bits = info.BitsPerSample;
    channels = sprintf('%.17g-',[1:info.NumChannels]); % Up to 17 decimal places (double precision has about 16) 
    channels = channels(1:end-1);
    sample_rate = info.SampleRate;
    amar = split(files(f).name, '.');
    [y, fs] = audioread(fullpath, 'native');
    File_collector = y;
    k = f;
    fnametemp = files(k).name;
    
    if ffirst == fnametemp
        k=k+1;
    end
    
    fnametemp = files(k).name;
    dtnext = dt + seconds(info.Duration);
    dttemp = readDateTime(fnametemp);
    
    while dttemp ~= dtnext && k < length(files)
        k = k+1;
        %fprintf('%d',f)
        fnametemp = files(k).name;
        dttemp = readDateTime(fnametemp);
    end
    if k == length(files) && dttemp ~= dtnext
        Output_path = [Path2Output '\' amar(1) '.' channels '.' num2str(sample_rate)];
        Output_path = cell2mat(Output_path); 
        if ~exist(Output_path, 'dir')
            mkdir(Output_path)
        end
        outFile = fullfile(Output_path,files(f).name);
        audiowrite(outFile,File_collector,fs,'BitsPerSample',bits); 
        filetable.saved(f) = 1;
        f = f+1;%%%%%
        k=0;
        merge = 0;
    continue
    end
    
    while dttemp == dtnext
        %fprintf('%d',k)
        filepathtemp = files(k).folder;
        fullpathtemp = strcat(filepathtemp,'\',fnametemp);
        finfotemp = audioinfo(fullpathtemp);
        [tempy, fs] = audioread(fullpathtemp, 'native');
        File_collector = [File_collector;tempy];
        filetable.merged(k) = 1;
        k = k+1;
        %if k == length(files) + 1
        %    Output_path = [Path2Output '\' amar(1) '.' channels '.' num2str(sample_rate)];
        %    Output_path = cell2mat(Output_path); 
        %    if ~exist(Output_path, 'dir')
        %        mkdir(Output_path)
        %    end
        %   outFile = fullfile(Output_path,files(f).name);
        %   audiowrite(outFile,File_collector,fs,'BitsPerSample',bits);
        %   filetable.saved(f) = 1;
        %   toc;
        %end
        dt = dttemp;
        dtnext = dt + seconds(finfotemp.Duration);
        dtnexthi = dtnext+seconds(5);
        dtnextlo = dtnext-seconds(5);
        if k == length(files) + 1
            continue
        else
            fnametemp = files(k).name;
        end
        dttemp = readDateTime(fnametemp);
    end
    Output_path = [Path2Output '\' amar(1) '.' channels '.' num2str(sample_rate)];
    Output_path = cell2mat(Output_path); 
    if ~exist(Output_path, 'dir')
       mkdir(Output_path)
    end
    outFile = fullfile(Output_path,files(f).name);
    audiowrite(outFile,File_collector,fs,'BitsPerSample',bits);
    filetable.saved(f) = 1;
    merge = 1;
end

leftover = table2struct(filetable(filetable.saved == 0 & filetable.merged == 0,:));
if ~isempty(leftover)
    for L = 1:length(leftover)
        LO = leftover(L).name;
        LOfilepath = leftover(L).folder;
        LOfullpath = strcat(LOfilepath,'\',LO);
        LOinfo = audioinfo(LOfullpath);
        LOchannels = sprintf('%.17g-',[1:LOinfo.NumChannels]); % Up to 17 decimal places (double precision has about 16) 
        LOchannels = LOchannels(1:end-1);
        LOsample_rate = LOinfo.SampleRate;
        LOamar = split(leftover(L).name, '.');
        Output_path = [Path2Output '\' LOamar(1) '.' LOchannels '.' num2str(LOsample_rate)];
        Output_path = cell2mat(Output_path); 
        if ~exist(Output_path, 'dir')
            mkdir(Output_path)
        end
        LOoutFile = fullfile(Output_path,leftover(L).name);
        copyfile(LOfullpath,LOoutFile);
    end
end
movedfiles = dir(fullfile(Path2Output, '**\*.wav')); %Recursively find all moved/merged WAV files
movedfiletable = struct2table(movedfiles);           %Create table of moved/merged files
%slfpath = fullfile(movedfiles(length(movedfiles)-1).folder,movedfiles(length(movedfiles)-1).name); %second last moved file
%lfpath = fullfile(files(length(files)).folder,files(length(files)).name);      %last file

%info_slf = audioinfo(slfpath);
%info_lf = audioinfo(lfpath);
%bits = info_slf.BitsPerSample;
%dtslf = readDateTime(slfpath); 
%testdt = dtslf + seconds(info_slf.Duration);
%dtlf = readDateTime(lfpath);
%if dtlf == testdt
%    [slfa, fs] = audioread(slfpath);
%    lfa = audioread(lfpath);
%    com_slflf = [slfa; lfa];
%    outlastfile = info_slf.Filename;
%    audiowrite(outlastfile,com_slflf,fs,'BitsPerSample',bits)
%    delete(info_lf.Filename);
%end

if move_NonAcoustic == 1
    ext = {'**/*.csv','**/*.xml', '**/*.txt'};
    extensions = cellfun(@(x)dir(fullfile(Path2Data,x)),ext,'UniformOutput',false); 
    other_files = vertcat(extensions{:});

        if ~exist([Path2Output,'\Non-Acoustic Files'], 'dir')
            mkdir([Path2Output,'\Non-Acoustic Files'])
        end
    for f = 1:length(other_files)
        file = [other_files(f).folder,'\',other_files(f).name];
    copyfile(file,[Path2Output,'\Non-Acoustic Files'])
    end
end

toc;

 
