%pick_wav_QAQC.m

% Select 5 random files for manual QAQC 

clear
close all

%%%%% Make changes as needed %%%%%

Dataset = 'CS2_2023_08';
Path2dataset = 'D:\CS2_2023_08';
datafolder = 'AMAR533.1.32000';
seed = 24; % change seed for each selection

%%%%%%%%%%%%%%%%%

seed_text = join(['Seed: ' , num2str(seed)]);
Path2data = join([Path2dataset,'\',datafolder],'');
fileList = dir(fullfile(Path2data, '*.wav'));

%initialiaze random number generator and set seed
rng(seed,'twister');

a = 1; %start at first file  
b = length(fileList(:,1));
r = (b-a).*rand(5,1) + a;
r = round(r);
Files2chck = fileList(r,:);

save = 1;

if save == 1
   Path2QAQC = join([Path2dataset,'\','QAQC_results'],'');

   if exist(Path2QAQC,'dir')==0
      mkdir(Path2QAQC);
   end
    
   file_fn = join(['QAQC_fivefiles_',Dataset,'_',datafolder,'_',num2str(seed),'.txt'],'');
   path2QAQCtxt = join([Path2QAQC,'\',file_fn],'');
      if exist(path2QAQCtxt,'file')
         disp('Five random files have aleady been selected for this deployment using that seed');
         disp('Check deployment QAQC folder or change seed.'); 
         return
      end
   fid = fopen(path2QAQCtxt,'wt');
         fprintf(fid,'%s\n',Dataset);
         fprintf(fid,'%s\n',seed_text);
         for i = 1:length(Files2chck)
             fprintf(fid,'%s\n',Files2chck(i).name);
         end
   fclose(fid);
end