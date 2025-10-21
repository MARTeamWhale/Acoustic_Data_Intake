%Move_wav.m

% Move all .wav files from one directory to another. Optionally move non-acoustic files
% (.xml, .csv, .txt) into a separate subfolder in the destination folder.

tic;
clear
close all

%%%%% Make changes as needed %%%%%

% enter path to data source folder
Path2Data = 'G:\CBN_2022_10\Data';
% enter path to data destination folder
Path2Output = 'F:\CBN_2022_10\AMAR819.1234.32000';

% if you want to skip the moving of non-acoustic files set to 0
move_NonAcoustic = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = dir(fullfile(Path2Data, '**\*.wav')); %Recursively find all WAV files (add sorting...)

for f = 1:length(files)
    file = [files(f).folder,'\',files(f).name];
movefile(file,Path2Output)

end

if move_NonAcoustic == 1
    ext = {'**/*.csv','**/*.xml', '**/*.txt'};
    extensions = cellfun(@(x)dir(fullfile(Path2Data,x)),ext,'UniformOutput',false);
    other_files = vertcat(extensions{:});

    temp = split(Path2Output,'\');
    Path2Output_temp = strjoin(temp(1:end-1)','\');

    if ~exist([Path2Output_temp,'\Non-Acoustic Files'], 'dir')
       mkdir([Path2Output_temp,'\Non-Acoustic Files'])
    end
    
    for f = 1:length(other_files)
        file = [other_files(f).folder,'\',other_files(f).name];
        movefile(file,[Path2Output_temp,'\Non-Acoustic Files'])
    end
end
toc;

 
