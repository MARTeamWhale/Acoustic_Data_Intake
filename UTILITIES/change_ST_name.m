%change_ST_name.m
%
% Change SoundTrap filename to match Standard timing
clear
close all
%%%%%%%%%%%%%%%%%
%Change as needed
%%%%%%%%%%%%%%%%%
Path2dataset = "F:\CSE_2022_10";
datafolder = '';
Path2Output = "G:\CSE_2022_10\ST6767-6769";
%%%%%%%%%%%%%%%%%

Path2data = join([Path2dataset,datafolder],'');

fileList = dir(fullfile(Path2data, '**/*.wav')); %Get fileslist
fileList = struct2table(fileList);



for i = 1:height(fileList)
    fileList.dt(i) = doDTReadST(char(fileList.name(i)));
end

ISO = cellstr(datestr(fileList.dt,30)); %Change timestamp format to ISO 8601

for i = 1:height(fileList)    
    temp = char(fileList.name(i));
    splits = split(temp,'.');
    fileList.rename(i) = strcat('ST', convertCharsToStrings(splits(1)), '.', convertCharsToStrings(ISO(i)), 'Z.', convertCharsToStrings(splits(3)));
end

h = waitbar(0,'Please wait...');
for i = 1:height(fileList)
    Path2file = char(strcat(fileList.folder(i),'\',fileList.name(i)));
    NewName = char(fileList.rename(i));
    Path2Newfile = char(strcat(Path2Output,'\',NewName));
    copyfile(Path2file,Path2Newfile)
    %system("rename " + Path2file + " " + NewName);
    waitbar(i/height(fileList),h)
end


%% doDTRead ---------------------------------------------------------------
function dt = doDTReadST(fileName)
% Extract datetime from char string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % define regex for reading datetime (ST)
    expr = '\d{12}'; % expression for finding strings of the form ".DDDDDDDDDDDDD", where "." is any character that is not a digit or a slash
  

    % extract datetime info
    dtStr = regexp(fileName,expr,'match');
    try
        dtStr = dtStr{end}; % "end" ensures that only the match for filename is used, not other potential matches in folder path
        dt = datetime(dtStr,'InputFormat','yyMMddHHmmss');
    catch
        warning('Could not read timestamp for file "%s"',fileName)
        dt = NaT;
    end
end
