%Move_PrePost.m

% Move pre and post deployment wav files and files from the first and last
% day to separate subfolders

clear
close all

%%%%% Make changes as needed %%%%%

% enter path to data source folder
Path2Data = 'G:\CS3-2022-10';
% enter path to data destination folder
Path2Output = 'G:\CS3-2022-10';

% Enter deployment and recovery dates & times from Whale Equipment MetaDatabase
DeploymentDateTime = "2022-10-15 17:36:00";
RecoveryDateTime = "2023-08-20 09:12:00";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% part 1: move pre & post deployment files
DeploymentDateTime = datetime(DeploymentDateTime);
RecoveryDateTime = datetime(RecoveryDateTime);
files = dir(fullfile(Path2Data, '**\*.wav'));
filesprepost = zeros(length(files),1);

for i = 1:length(files)
    files(i).datetime = datetime(readDateTime(convertStringsToChars(files(i).name)));
    if files(i).datetime < DeploymentDateTime || files(i).datetime > RecoveryDateTime
       filesprepost(i) = 1;
    end
end

PrePostFiles = files(logical(filesprepost),:);

    if ~exist([Path2Output,'\Pre&PostDeployment'], 'dir')
       mkdir([Path2Output,'\Pre&PostDeployment'])
    end
    
for f = 1:length(PrePostFiles)
    file = [PrePostFiles(f).folder,'\',PrePostFiles(f).name];
    %copyfile(file,[Path2Output,'\Pre&PostDeployment'])
    movefile(file,[Path2Output,'\Pre&PostDeployment'])
end

% part 2: move first and last day files
FirstDateTime = dateshift(DeploymentDateTime, 'end', 'day');
LastDateTime = dateshift(RecoveryDateTime, 'start', 'day');
filesfirstlastday = zeros(length(files),1);

for ii = 1:length(files)
    files(ii).datetime = datetime(readDateTime(convertStringsToChars(files(ii).name)));
    if files(ii).datetime < FirstDateTime && files(ii).datetime > DeploymentDateTime || files(ii).datetime > LastDateTime && files(ii).datetime < RecoveryDateTime
       filesfirstlastday(ii) = 1;
    end
end

FirstLastFiles = files(logical(filesfirstlastday),:);

    if ~exist([Path2Output,'\FirstLastDay'], 'dir')
       mkdir([Path2Output,'\FirstLastDay'])
    end
    
for ff = 1:length(FirstLastFiles)
    file = [FirstLastFiles(ff).folder,'\',FirstLastFiles(ff).name];
    %copyfile(file,[Path2Output,'\Pre&PostDeployment'])
    movefile(file,[Path2Output,'\FirstLastDay'])
end