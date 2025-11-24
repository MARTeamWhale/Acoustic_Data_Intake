%Move_PrePost.m

%Move pre and post deployment wav files to seperate folder

clear
close all

%%%%% Make changes as needed %%%%%

% enter path to data source folder
Path2Data = 'D:\CSW_2024_10';
% enter path tdata destination folder
Path2Output = 'D:\CSW_2024_10';

% Enter deployment and recovery dates & times from Whale Equipment MetaDatabase
DeploymentDateTime = "2024-10-19 15:34:00";
RecoveryDateTime = "2025-10-19 13:22:00";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% part 1: move all files before first full day and after last full day
FirstDateTime = dateshift(datetime(DeploymentDateTime), 'end', 'day');
LastDateTime = dateshift(datetime(RecoveryDateTime), 'start', 'day');
files1 = dir(fullfile(Path2Data, '**\*.wav'));
filesfirstlastday = zeros(length(files1),1);

for ii = 1:length(files1)
    files1(ii).datetime = datetime(readDateTime(convertStringsToChars(files1(ii).name)));
    if files1(ii).datetime < FirstDateTime || files1(ii).datetime > LastDateTime
       filesfirstlastday(ii) = 1;
    end
end

FirstLastFiles = files1(logical(filesfirstlastday),:);

    if ~exist([Path2Output,'\FirstLastDay'], 'dir')
       mkdir([Path2Output,'\FirstLastDay'])
    end
    
for ff = 1:length(FirstLastFiles)
    file = [FirstLastFiles(ff).folder,'\',FirstLastFiles(ff).name];
    %copyfile(file,[Path2Output,'\Pre&PostDeployment'])
    movefile(file,[Path2Output,'\FirstLastDay'])
end

% part 2: move pre & post deployment files
DeploymentDateTime = datetime(DeploymentDateTime);
RecoveryDateTime = datetime(RecoveryDateTime);
files2 = dir(fullfile(Path2Data, '**\*.wav'));
filesprepost = zeros(length(files2),1);

for i = 1:length(files2)
    files2(i).datetime = datetime(readDateTime(convertStringsToChars(files2(i).name)));
    if files2(i).datetime < DeploymentDateTime || files2(i).datetime > RecoveryDateTime
       filesprepost(i) = 1;
    end
end

PrePostFiles = files2(logical(filesprepost),:);

    if ~exist([Path2Output,'\Pre&PostDeployment'], 'dir')
       mkdir([Path2Output,'\Pre&PostDeployment'])
    end
    
for f = 1:length(PrePostFiles)
    file = [PrePostFiles(f).folder,'\',PrePostFiles(f).name];
    %copyfile(file,[Path2Output,'\Pre&PostDeployment'])
    movefile(file,[Path2Output,'\Pre&PostDeployment'])
end

