%This script creates 10 random sequences of stim (bisyllabic pseudowords).
%These sequences will be used in randomized order in the PhonoLoc.

%The stim are bisyllabic pseudowords listed in the file "bisyll_list.csv"
%The file contains 80 pseudowords (20 from 4 speakers).
%These pseudowords have been created from concatenated syllables, but with avoiding to create meaningfull words. 

%%IMPORTANT if script stay busy for more than some secs : stop and re-run.
% it is probably stuck in the while loop because 2 last stim are randomly from same
% actor.

fid = fopen('bisyll_list.csv'); 
data = textscan(fid, '%s'); 
stim = data{1,1}';
fclose(fid);


%%RANDOMIZATION 1st pass%%

%A.   Randomize in a way that the same speaker is not repeated 2 times in a row
        [randStim,index] = Shuffle(stim); %simple randomization
        %disp(pseudovector); 
        
        for v=1:(length(index)-1)
            item = randStim{v};
            itemNext = randStim{v+1};
            
            while item(1:2) == itemNext(1:2) %if 2char are the same for item v and the next one
                %select one randomly in the next items
                indexrand = randi([v+1 length(randStim)]);
                %swap it with itemNext
                randStim([v+1 indexrand]) = randStim([indexrand v+1]);
                itemNext = randStim{v+1}; %verify if it is not the case again
            end 
        end 
        
        %disp(pseudovector);
        
%B.   Create 5 sequences of 15 stim based on this randomization 
% (=5*15 = 75 first stim used on the 80)
seq01 = randStim(1:15); %take the 20 first to create seq01
SYLseq01 = strcat('SYL', seq01); % create the SYL and SCR vectors
SCRseq01 = strcat('SCR', seq01);

seq02 = randStim(16:30); %take the 20 next, and so on. 

SYLseq02 = strcat('SYL', seq02);
SCRseq02 = strcat('SCR', seq02);

seq03 = randStim(31:45);
SYLseq03 = strcat('SYL', seq03);
SCRseq03 = strcat('SCR', seq03);

seq04 = randStim(46:60);
SYLseq04 = strcat('SYL', seq04);
SCRseq04 = strcat('SCR', seq04);

seq05 = randStim(61:75);
SYLseq05 = strcat('SYL', seq05);
SCRseq05 = strcat('SCR', seq05);

%%RANDOMIZATION 2nd pass%%
%A. 
[randStim,index] = Shuffle(stim); %simple randomization
        %disp(pseudovector); 
        
        for v=1:(length(index)-1)
            item = randStim{v};
            itemNext = randStim{v+1};
            
            while item(1:2) == itemNext(1:2) %if 2char are the same for item v and the next one
                %select one randomly in the next items
                indexrand = randi([v+1 length(randStim)]);
                %swap it with itemNext
                randStim([v+1 indexrand]) = randStim([indexrand v+1]);
                itemNext = randStim{v+1}; %verify if it is not the case again
            end 
        end 
        
        %disp(pseudovector);
%B. 

seq06 = randStim(1:15);
SYLseq06 = strcat('SYL', seq06);
SCRseq06 = strcat('SCR', seq06);

seq07 = randStim(16:30);
SYLseq07 = strcat('SYL', seq07);
SCRseq07 = strcat('SCR', seq07);

seq08 = randStim(31:45);
SYLseq08 = strcat('SYL', seq08);
SCRseq08 = strcat('SCR', seq08);

seq09 = randStim(46:60); 
SYLseq09 = strcat('SYL', seq09);
SCRseq09 = strcat('SCR', seq09);

seq10 = randStim(61:75); 
SYLseq10 = strcat('SYL', seq10);
SCRseq10 = strcat('SCR', seq10);


%create lists to use in PhonoLoc.m
seq_list = {'seq01', 'seq02','seq03','seq04', 'seq05','seq06','seq07','seq08',...
       'seq09','seq10'};
SYLseq = strcat('SYL', seq_list);
SCRseq = strcat('SCR', seq_list);

clear('ans', 'data', 'fid', 'index', 'indexrand', 'item', 'itemNext', 'randStim', 'stim', 'v'); 

output = strcat(cd, '\sequencesNEW');
save(output); 

output_file = fullfile(fileparts(mfilename('fullpath')), '..', 'sequences-NEW.mat');

save(output_file);
