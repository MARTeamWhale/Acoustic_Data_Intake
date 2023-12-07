%Copy_NonAcoustic.mat 
%Moves files with files with defined extension to new location
tic;
clear
close all

%%%%% Make changes as needed %%%%%
%enter path to data source folder
Path2Data = 'F:\CS3-2022-10';
%enter path to data destination folder
Path2Output = 'G:\CS3-2022-10';
%enter extensions of files you want to copy
ext = {'**/*.csv','**/*.xml'}; %**/ makes it recursive
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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