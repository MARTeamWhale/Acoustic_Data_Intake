%Move_PrePost.m

%Move pre and post deployment wav files to seperate folder

clear
close all

%%%%% Make changes as needed %%%%%
%enter path to data source folder
Path2Data = 'G:\CS3-2022-10\';
%enter path to data destination folder
Path2Output = 'G:\CS3-2022-10\';
% Enter Deployment and Recovery Date from Whale Equipment MetaDatabase
DeploymentDateTime = "2022-10-15 17:36:00";
RecoveryDateTime = "2023-08-20 09:12:00";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

