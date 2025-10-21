%mk_rawdata_report.m

% Generate preliminary report on dataset completeness

clear
close all

%%%%% Make changes as needed %%%%%

% enter path to data source folder
Path2data = 'F:\CS3-2022-10';
% specify dataset name
Dataset = 'CS3_2022_10';
% specify deployment and recovery dates from Whale Equipment MetaDatabase
DeploymentDate = "2022-10-15";
RecoveryDate = "2023-08-20";

% optional settings if needed
Foverride = 0; % 1: uses filesize values entered 0: uses median filesize (works in most cases)
file_size_override = 44496280; %48907866; %145299528; %327931464; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileList = dir(fullfile(Path2data, '**\*.wav'));

disp(Dataset);
Numf = num2str(length(fileList));
numfiles = join(['Number of files: ',Numf]);


for i = 1:length(fileList)
    fileList(i).datetime = datetime(readDateTime(convertStringsToChars(fileList(i).name)));
    Path2File = fullfile(fileList(i).folder, fileList(i).name);
   % wav_info = audioinfo(Path2File);
   % fileList(i).Duration = wav_info.Duration;
end

fileList = struct2table(fileList);
total_size_bytes = sum(fileList.bytes);
total_size_GB = total_size_bytes/(1000^3);
Total_GB_text = ['Total dataset size: ', num2str(total_size_GB),'GB'];
disp(Total_GB_text);

% Get first and last day
DeploymentDate = datetime(DeploymentDate);
RecoveryDate = datetime(RecoveryDate);
firstDay = min(fileList.datetime);
firstDay_text = ['First Day in Directory: ', datestr(firstDay)];
disp(firstDay_text);
DeploymentDateText = ['Deployment Date: ' datestr(DeploymentDate)];
disp(DeploymentDateText);
lastDay = max(fileList.datetime);
lastDay_text = ['Last Day in Directory: ', datestr(lastDay)];
disp(lastDay_text);
RecoveryDateText = ['Recovery Date: ' datestr(RecoveryDate)];
disp(RecoveryDateText);

% check interval
all_intervals = diff(fileList.datetime); 

if all(all_intervals == all_intervals(1))
    disp("Intervals match, no merging needed");
else
    disp("Intervals do not match");
    table_intervals = tabulate(all_intervals);
    disp(['     Value   ','     Count    ','Percent   '])
    disp(table_intervals)
    interval = seconds(1);
    Time_index = DeploymentDate:interval:RecoveryDate;
    Time_index = Time_index';
    dployment_dur = lastDay - firstDay; 
    dp_days = days(dployment_dur);
    days_text = join(['Recording duration: ',num2str(dp_days),' days']);
    disp(days_text);
    
    k = find(ismember(Time_index,fileList.datetime,'rows'));
    
    junk = zeros(length(Time_index),1);
    
    junk(k) = 1;
    
    figure(1), scatter(Time_index, junk,20,'filled');
    hold on;
    xlim([DeploymentDate-days(1) RecoveryDate+days(1)])
    ylim([0.5 1.5])
    set(gcf, 'Position',  [650, 400, 900, 150]);
    set(gca,'YTick',[])
    hold off
end
