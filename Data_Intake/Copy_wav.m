%Copy_wav.mat 
%Copy, split channels, and samplerates of AMAR .wav files to new location
tic;
clear
close all

%%%%% Make changes as needed %%%%%
%enter path to data source folder
Path2Data = 'F:\CS3-2022-10';
%enter path to data destination folder
Path2Output = 'G:\CS3-2022-10';
%if you want to skip the moving of Non-Acoustic files set to 0
move_NonAcoustic = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


files = dir(fullfile(Path2Data, '**\*.wav')); %Recursively find all WAV files
%INFO = [];

for f = 1:length(files)
%for f = 1:100   
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
