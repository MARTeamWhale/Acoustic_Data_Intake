%mk_QAQC_report.m
%
% Generate report on dataset quality
clear
close all
%%%%%%%%%%%%%%%%%
%Change as needed
%%%%%%%%%%%%%%%%%
Dataset = 'CS1_2022_10';
Path2dataset = "D:\CS1_2023_08\";
datafolder = 'ST7526';
DeploymentDate = "2023-08-19";
RecoveryDate = "2024-08-19";
Foverride = 0; % 1: uses filesize values entered 0: uses median filesize (works in most cases)
file_size_override = 44496280; %48907866; %145299528; %327931464; 
Stat_toolbox = 0; %Set to 0 if license for stats toolbox checkout fails
%%%%%%%%%%%%%%%%%

Path2data = join([Path2dataset,datafolder],'');

fileList = dir(fullfile(Path2data, '*.wav'));

disp(Dataset);
Numf = num2str(length(fileList));
numfiles = join(['Number of files: ',Numf]);


for i = 1:length(fileList)
    fileList(i).datetime = datetime(readDateTime(convertStringsToChars(fileList(i).name)));
end

fileList = struct2table(fileList);
fileList = sortrows(fileList,"datetime");
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
int1 = fileList.datetime(3) - fileList.datetime(2);
int2 = fileList.datetime(8) - fileList.datetime(7);
all_intervals = diff(fileList.datetime); 
if Stat_toolbox == 1
    table_intervals = tabulate(all_intervals);
    disp(['     Value   ','     Count    ','Percent   '])
    disp(table_intervals)
end
if int1 == int2
    interval = int1;
else
    disp("Error: Intervals do not match. Using mean interval as approximation. Please check.");
    interval = mean(all_intervals);
end

Time_index = firstDay:interval:lastDay;
Time_index = Time_index';
dployment_dur = lastDay - firstDay; 
dp_days = days(dployment_dur);
days_text = join(['Recording duration: ',num2str(dp_days),' days']);
disp(days_text);

file_prediction = dployment_dur/interval;
file_prediction_text = join(['Predicted number of files: ',num2str(file_prediction)]);
disp(numfiles);
disp(file_prediction_text);


large_interval_test = diff(fileList.datetime) <= interval*1.025;
small_interval_test = diff(fileList.datetime) >= interval*0.975;
large_interval = fileList(large_interval_test == false,:);
small_interval = fileList(small_interval_test == false,:);

fileList.Large_interval = zeros(length(fileList.datetime),1);
fileList.Small_interval = zeros(length(fileList.datetime),1);
fileList.Large_files = zeros(length(fileList.datetime),1);
fileList.Small_files = zeros(length(fileList.datetime),1);

fileList.Large_interval(ismember(fileList.datetime,large_interval.datetime)) = 1;
fileList.Small_interval(ismember(fileList.datetime,small_interval.datetime)) = 1;

Interval_text = join(['Interval: ',string(interval)]);
disp(Interval_text);

%figure(1),scatter(rounded_index,round_missing_times_logical, 'filled')
%hold on;
%xlim([firstDay-days(1) lastDay+days(1)])
%ylim([-0.5 1.5])
if Foverride == 1
   file_size = file_size_override;
else
   %file_size = mean(fileList.bytes);
   file_size = median(fileList.bytes);
end

plus5 = file_size *1.05;
minus5 = file_size*0.95;
%Fix order of masking index
large_files = fileList(fileList.bytes>plus5,:);
temp_large_files = removevars(large_files,{'Large_interval','Small_interval'});
large_files_text = join(['Large Files: ',num2str(height(large_files))]); 
disp(large_files_text);
fileList.Large_files(ismember(fileList.datetime,large_files.datetime)) = 1;
large_files.Large_files = ones(height(large_files),1);

small_files = fileList(fileList.bytes<minus5,:);
temp_small_files= removevars(small_files,{'Large_interval','Small_interval'});
small_files_text = join(['Small Files: ',num2str(height(small_files))]);
disp(small_files_text);
fileList.Small_files(ismember(fileList.datetime,small_files.datetime)) = 1;
small_files.Small_files = ones(height(small_files),1);

wrong_file_size = [temp_large_files;temp_small_files];
wrong_interval = [large_interval;small_interval];
junk =find(all_intervals ~= interval);
LS_intervals = all_intervals(junk,:);
LS_int_files = fileList(junk,:);
wrong_interval_files = [table(LS_intervals),LS_int_files];
gaps_id = find(wrong_interval_files.LS_intervals > 2*interval);
gap = wrong_interval_files(gaps_id,:);
if ~isempty(gap)
    gptext = 'Large gap found at:';
    disp(gptext)
    for g = 1:height(gap)
        gaps_text = gap.name(g);
        disp(gaps_text);
    end
else 
    disp('No large gaps found')
end
gap.gapplot = ones(height(gap),1);

figure(1), scatter(fileList.datetime,fileList.Large_interval,140,'filled');
hold on;
scatter(fileList.datetime,fileList.Small_interval,140,'filled');
scatter(fileList.datetime,fileList.Large_files,'d');
scatter(fileList.datetime,fileList.Small_files,'d');
scatter(gap.datetime,gap.gapplot,300,'s')
xlim([firstDay-days(1) lastDay+days(1)])
ylim([0.5 1.5])
legend('Large Interval','Small Interval','Large File','Small File','Large Gap','Location','bestoutside')
set(gcf, 'Position',  [650, 400, 900, 150]);
set(gca,'YTick',[])






large_interval_text = join(['Large interval: ', num2str(height(large_interval))]);
disp(large_interval_text);
small_interval_text = join(['Small interval: ', num2str(height(small_interval))]);
disp(small_interval_text);

%temp = setdiff(wrong_interval,wrong_file_size);
%temp_fL = removevars(fileList,{'Large_interval','Small_interval'});

%Missing_time = [];
%for n = 1:height(temp)
%for n = 1
%    [~, fn_index] = ismember(temp_fL, temp(n,:), 'rows');% finds row in large table
%    fn = find(fn_index == 1);
%    if table2array(temp_fL(fn +1,7)) == table2array(temp_fL(fn,7))+interval
%       missing_time = table2array(temp_fL(fn,7))+interval;
%       Missing_time = [Missing_time;missing_time];
%    end
%end

%if isempty(missing_files)
%    missing_file_logical = 'N';
%    missing_files_text = join(['Missing Files: ',missing_file_logical]);
%    disp(missing_files_text)
%else
%    missing_file_logical = 'Y';
%    missing_files_text = join(['Missing Files: ',missing_file_logical]);
%    disp(missing_files_text)
%end

%return;
save = 1;

if save == 1
   Path2QAQC = join([Path2dataset,'QAQC_results'],'');

   if exist(Path2QAQC,'dir')==0
      mkdir(Path2QAQC);
   end
    
   results_fn = join(['QAQC_results_',Dataset,'_',datafolder,'.txt'],'');
   path2QAQCtxt = join([Path2QAQC,'\',results_fn],'');
   fid = fopen(path2QAQCtxt,'wt');
         fprintf(fid,'%s\n',Dataset);
         fprintf(fid,'%s\n',days_text);
         fprintf(fid,'%s\n',firstDay_text);
         fprintf(fid,'%s\n',DeploymentDateText);
         fprintf(fid,'%s\n',lastDay_text);
         fprintf(fid,'%s\n',RecoveryDateText);
         fprintf(fid,'%s\n',numfiles);
         fprintf(fid,'%s\n',file_prediction_text);
         fprintf(fid,'%s\n',Total_GB_text);
         fprintf(fid,'%s\n',Interval_text);
         if ~isempty(gap)
             fprintf(fid,'%s\n',gptext);
             for g = 1:height(gap)
                 gaps_text = char(gap.name(g));
                 fprintf(fid,'%s\n',gaps_text);      
             end 
         else
             fprintf(fid,'%s\n','No large gaps found');
         end
         fprintf(fid,'%s\n',' ');
         %fprintf(fid,'%s\n',missing_files_text);
         %fprintf(fid,rounded_missing_times);
         fprintf(fid,'%s\n','*************************************************************');
         fprintf(fid,'%s\n',large_files_text);        
         if ~isempty(large_files) && length(large_files.name) <= 100
            for i = 1:length(large_files.name)
                fprintf(fid,'%s\n',string(large_files.name(i)));
            end
            fprintf(fid,'%s\n',' ');
         elseif ~isempty(large_files) && length(large_files.name) > 100
             fprintf(fid,'%s\n','Too Many Files to Print');
         else 
             fprintf(fid,'%s\n',' ');
         end
         fprintf(fid,'%s\n','*************************************************************');
         fprintf(fid,'%s\n',small_files_text);
         if ~isempty(small_files) && length(small_files.name) <= 100
            for i = 1:length(small_files.name)
               fprintf(fid,'%s\n',string(small_files.name(i)));
            end
            fprintf(fid,'%s\n',' ');
         elseif ~isempty(small_files) && length(small_files.name) > 100
             fprintf(fid,'%s\n','Too Many Files to Print');
         else
             fprintf(fid,'%s\n',' ');
         end
         fprintf(fid,'%s\n','*************************************************************');
         fprintf(fid,'%s\n',large_interval_text);
         if ~isempty(large_interval) && length(large_interval.name) <= 100
            for i = 1:length(large_interval.name)
               fprintf(fid,'%s\n',string(large_interval.name(i)));
            end
            fprintf(fid,'%s\n',' ');
         elseif ~isempty(large_interval) && length(large_interval.name) > 100
             fprintf(fid,'%s\n','Too Many Files to Print');
         else
             fprintf(fid,'%s\n',' ');
         end
         fprintf(fid,'%s\n','*************************************************************');
         fprintf(fid,'%s\n',small_interval_text);
         if ~isempty(small_interval) && length(small_interval.name) <= 100
            for i = 1:length(small_interval.name)
               fprintf(fid,'%s\n',string(small_interval.name(i)));
            end
            fprintf(fid,'%s\n',' ');
         elseif ~isempty(small_interval) && length(small_interval.name) > 100
             fprintf(fid,'%s\n','Too Many Files to Print');         
         else
             fprintf(fid,'%s\n',' ');
         end
         
             fclose(fid); 
   disp(join(['Test Output Saved to ',Path2QAQC]));
   Path2fig1 = join([Path2QAQC,'\Missing_Files_Plot_',Dataset,'_',datafolder,'.png'],"");
   saveas(figure(1),Path2fig1);
   disp(join(['Figure Saved to ',Path2QAQC]));
end

return % remove to run more in depth (takes way longer) **Incomplete**
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Work in progress
%In depth file check using audioinfo to get:  
%Filename
%CompressionMethod
%NumChannels, SampleRate
%TotalSamples: 
%Duration: 
%BitsPerSample
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for k = 1:length(fileList.name)

Info = cell(1,length(fileList.name));
%Info = array2table(zeros(length(fileList.name),10));
%Info.Properties.VariableNames = {'Filename','CompressionMethod',...
%    'NumChannels','SampleRate','TotalSamples','Duration','Title',...
%    'Comment','Artist','BitsPerSample'};
for k = 1:2
    baseFileName = fileList(k,:).name;
    fullFileName = fullfile(Path2dir, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
                     
    info=audioinfo(fullFileName);
    info = table(info);
    %info = struct2table(info, 'AsArray', true);
    Info(k) = info;
  
 
end %end wav file loading loop
