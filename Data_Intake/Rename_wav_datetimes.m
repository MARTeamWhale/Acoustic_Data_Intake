%Rename_wav_datetimes.m

% Rename wav files to adjust date and time stamps

tic;
clear
close all

%%%%% Make changes as needed %%%%%

% dataset name
Dataset = 'SCS_2024_09';

% path to data folder
Path2Data = 'C:\Users\STANISTREETJ\Desktop\SCS-TEST\RENAME';

% real start time
StartDateTime = datetime("2024-09-23 13:59:00");

% first file time stamp
FirstFileTime = datetime("2001-01-01 00:00:00");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate time difference
TimeDiff = StartDateTime - FirstFileTime;

% find all wav files in directory
files = dir(fullfile(Path2Data, '**\*.wav'));

for f = 1:length(files)
        
    % original time stamp
    files(f).originaldatetime = datetime(readDateTime(convertStringsToChars(files(f).name)));
    filedtstring = string(datetime(files(f).originaldatetime,"Format", 'yyyyMMdd''T''HHmmss''Z'));
    
    % new time stamp
    files(f).newdatetime = files(f).originaldatetime + TimeDiff;
    newdtstring = string(datetime(files(f).newdatetime, "Format", 'yyyyMMdd''T''HHmmss''Z'));

    % new file name
    files(f).newname = replace(files(f).name, filedtstring, newdtstring);

    % apply new name to wav file in existing directory
    movefile(fullfile(Path2Data, files(f).name), fullfile(Path2Data, files(f).newname));

end

% export table
writetable(struct2table(files), fullfile(Path2Data, append(Dataset, '_filetimes.csv')));

toc;