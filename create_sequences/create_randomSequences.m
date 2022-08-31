% create 10 random sequences of stim from the list 'bisyll_list.csv'

fid = fopen('bisyll_list.csv');
data = textscan(fid, '%s');
stim = (data{1})';
fclose(fid);

% randomize the stim vector
random_stim = Shuffle(stim);

% take the 20 first to create seq01
seq01 = random_stim(1:15);
% create the SYL and SCR vectors
SYLseq01 = strcat('SYL', seq01);
SCRseq01 = strcat('SCR', seq01);

% take the 20 next, and so on.
seq02 = random_stim(16:30);
SYLseq02 = strcat('SYL', seq02);
SCRseq02 = strcat('SCR', seq02);

seq03 = random_stim(31:45);
SYLseq03 = strcat('SYL', seq03);
SCRseq03 = strcat('SCR', seq03);

seq04 = random_stim(46:60);
SYLseq04 = strcat('SYL', seq04);
SCRseq04 = strcat('SCR', seq04);

seq05 = random_stim(61:75);
SYLseq05 = strcat('SYL', seq05);
SCRseq05 = strcat('SCR', seq05);

% randomize again
random_stim = Shuffle(random_stim);

seq06 = random_stim(1:15);
SYLseq06 = strcat('SYL', seq06);
SCRseq06 = strcat('SCR', seq06);

seq07 = random_stim(16:30);
SYLseq07 = strcat('SYL', seq07);
SCRseq07 = strcat('SCR', seq07);

seq08 = random_stim(31:45);
SYLseq08 = strcat('SYL', seq08);
SCRseq08 = strcat('SCR', seq08);

seq09 = random_stim(46:60);
SYLseq09 = strcat('SYL', seq09);
SCRseq09 = strcat('SCR', seq09);

seq10 = random_stim(61:75);
SYLseq10 = strcat('SYL', seq10);
SCRseq10 = strcat('SCR', seq10);

% create general lists
seq_list = {'seq01', ...
            'seq02', ...
            'seq03', ...
            'seq04', ...
            'seq05', ...
            'seq06', ...
            'seq07', ...
            'seq08', ...
            ...
            'seq09', ...
            'seq10'};
SYLseq = strcat('SYL', seq_list);
SCRseq = strcat('SCR', seq_list);

clear('ans', 'data', 'fid', 'random_stim', 'stim');

output_file = fullfile(fileparts(mfilename('fullpath')), '..', 'sequences-NEW.mat');

save(output_file);
