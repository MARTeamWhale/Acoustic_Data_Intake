%Copy_wav.m 

% Copy AMAR .wav files to new location, organizing into subfolders based on
% sampling rate and/or channel number. Non-acoustic files (.xml, .txt) will be copied
% into a separate subfolder in the destination folder. To also copy .csv
% files to this folder, set option below.

tic;
clear
close all

%%%%% Make changes as needed %%%%%

% enter path to data source folder
Path2Data = 'E:\MGE_2022_10';
% enter path to data destination folder
Path2Output = 'D:\MGE_2022_10';
% to copy csv files to "Non-Acoustic Files" folder, set to 1
copy_csv = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = dir(fullfile(Path2Data, '**\*.wav')); % Recursively find all WAV files
%INFO = [];

for f = 1:length(files) 
    file = [files(f).folder,'\',files(f).name];
    info = audioinfo(file);
    %INFO = [INFO;info]; works... but slow
    channels = sprintf('%.17g-',[1:info.NumChannels]); % Up to 17 decimal places (double precision has about 16) 
    channels = channels(1:end-1);
    sample_rate = info.SampleRate;
    amar = split(files(f).name, '.');
    Output_path = [Path2Output '\' amar(1) '.' channels '.' num2str(sample_rate)];
    Output_path = cell2mat(Output_path); 
    if ~exist(Output_path, 'dir')
       mkdir(Output_path)
    end
    copyfile(file,Output_path);
end


if copy_csv == 1
    ext = {'**/*.csv','**/*.xml', '**/*.txt'};
elseif copy_csv == 0
    ext = {'**/*.xml', '**/*.txt'};
end

extensions = cellfun(@(x)dir(fullfile(Path2Data,x)),ext,'UniformOutput',false);
other_files = vertcat(extensions{:});

if ~exist([Path2Output,'\Non-Acoustic Files'], 'dir')
    mkdir([Path2Output,'\Non-Acoustic Files'])
end
for f = 1:length(other_files)
    file = [other_files(f).folder,'\',other_files(f).name];
    copyfile(file,[Path2Output,'\Non-Acoustic Files'])
end

toc;
