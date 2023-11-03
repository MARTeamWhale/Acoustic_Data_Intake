
%Merge_wav.mat 
%merge and move AMAR .wav files
tic;
clear
close all

%%%%% Make changes as needed %%%%%
%enter path to highest data folder
Path2Data = 'G:\CBN_2022_10\Data';
Path2Output = 'F:\CBN_2022_10\AMAR819.1.2.3.4.32000';
%recording interval
%ri = 900; %seconds
%maxDur = seconds(240);
%multi-channel? incomplete
%NumSamplerates = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ri = seconds(ri); % interval to duration
files = dir(fullfile(Path2Data, '**\*.wav')); %Recursively find all WAV files 
filetable = struct2table(files); 
filetable.saved = zeros(size(files,1),1);
File_collector = [];
f = 1;
k = 0;
merge = 0;
%return good to this point
%for f = 1:length(files) %beginning of files loop

while f <= length(files)-1 && k < length(files)%beginning of files loop   
    
    if k ~= 0 && merge == 1
    f = k;
    end
    
    ffirst = files(f).name;
    filepath = files(f).folder;
    fullpath = strcat(filepath,'\',ffirst);
    dt = readDateTime(fullpath);
    finfo = audioinfo(fullpath);
    bits = finfo.BitsPerSample;
    [y, fs] = audioread(fullpath, 'native');
    File_collector = y;
    k = f;
    fnametemp = files(k).name;
    
    if ffirst == fnametemp
        k=k+1;
    end
    
    fnametemp = files(k).name;
    dtnext = dt + seconds(finfo.Duration);
    dttemp = readDateTime(fnametemp);
    
    while dttemp ~= dtnext && k < length(files)-1
        k = k+1;
        %fprintf('%d',f)
        fnametemp = files(k).name;
        dttemp = readDateTime(fnametemp);
    end
    
    if k == length(files)-1
        outFile = fullfile(Path2Output,files(f).name);
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
        k = k+1;
        if k == length(files) + 1
           outFile = fullfile(Path2Output,files(f).name);
           audiowrite(outFile,File_collector,fs,'BitsPerSample',bits);
           filetable.saved(f) = 1;
           toc;
           %return
           
        end
        dt = dttemp;
        dtnext = dt + seconds(finfotemp.Duration);
        dtnexthi = dtnext+seconds(5);
        dtnextlo = dtnext-seconds(5);
        fnametemp = files(k).name;
        dttemp = readDateTime(fnametemp);
    end
    outFile = fullfile(Path2Output,files(f).name);
    audiowrite(outFile,File_collector,fs,'BitsPerSample',bits);
    filetable.saved(f) = 1;
    merge = 1;
    %return
end

movedfiles = dir(fullfile(Path2Output, '**\*.wav')); %Recursively find all WAV files
movedfiletable = struct2table(movedfiles); 
slfpath = fullfile(movedfiles(length(movedfiles)-1).folder,movedfiles(length(movedfiles)-1).name);
lfpath = fullfile(movedfiles(length(movedfiles)).folder,movedfiles(length(movedfiles)).name);

info_slf = audioinfo(slfpath);
info_lf = audioinfo(lfpath);
bits = info_slf.BitsPerSample;
dtslf = readDateTime(slfpath); 
testdt = dtslf + seconds(info_slf.Duration);
dtlf = readDateTime(lfpath);
if dtlf == testdt
    [slfa, fs] = audioread(slfpath);
    lfa = audioread(lfpath);
    com_slflf = [slfa; lfa];
    outlastfile = info_slf.Filename;
    audiowrite(outlastfile,com_slflf,fs,'BitsPerSample',bits)
    delete(info_lf.Filename);
end
toc;

 
