tic;
clear
close all

%%%%% Make changes as needed %%%%%
%enter path to data source folder
Path2Data = '\\142.2.83.52\whalenas6\MOORED_PAM_DATA\2022\10\CS1_2022_10\AMAR663.1.128000';
%enter path to data destination folder
Path2Output = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


files = dir(fullfile(Path2Data, '**\*.wav')); %Recursively find all WAV files
channels = zeros(length(files),1);
AMARs = cell(length(files),1);
Sample_rates = zeros(length(files),1);
bits = zeros(length(files),1);

for f = 1:length(files)
%for f = 1:100   
    file = [files(f).folder,'\',files(f).name];
    info = audioinfo(file);
    channels(f) = info.NumChannels;
    amar = split(files(f).name, '.');
    AMARs(f) = amar(1);
    Sample_rates(f) = info.SampleRate;
    bits(f) = info.BitsPerSample;
end

UniqueAMARS = unique(cell2table(AMARs));
UniqueChannels = unique(channels);
UniqueSampleRates = unique(Sample_rates);
UniqueBits = unique(bits);


toc