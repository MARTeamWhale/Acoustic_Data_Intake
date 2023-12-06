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