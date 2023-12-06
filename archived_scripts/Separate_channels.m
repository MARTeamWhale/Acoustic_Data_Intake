%Separate_channels.mat 
%Split channels of AMAR .wav files
tic;
clear
close all

%%%%% Make changes as needed %%%%%
%enter path to highest data folder
Path2Data = 'F:\CBN_2022_10\Data';
Path2Output = 'F:\CBN_2022_10';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


files = dir(fullfile(Path2Data, '**\*.wav')); %Recursively find all WAV files (add sorting...)
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
    Output_file = [Output_path, '\' files(f).name];
    movefile(file,Output_file);


end
toc;
