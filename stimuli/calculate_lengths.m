% initialize the sound driver
InitializePsychSound(1);
% Set the frequency
Fs = 44100;
% Set the number of channels both for the audiodata we present and the audiodata
% we record
numChannels = 2;

fid = fopen('name_stim.txt');
nsnd = 0;
while ~feof(fid)
    fgetl(fid);
    nsnd = nsnd + 1;
end
fclose(fid);

duration = cell(2, nsnd);

% 'a'== PERMISSION: open or create file for writing; append data to end of file
output = fopen('lengths_stim.tsv', 'a');
fprintf(output, 'stim\tduration\n');

fid = fopen('name_stim.txt');
for ll = 1:nsnd
    FileName = fgetl(fid);                % Gets sound name
    disp(FileName);                       % Show sound name
    duration(1, ll) = cellstr(FileName);
    pahandle = PsychPortAudio('Open', [], [], 0, Fs, numChannels);
    [sound_stereo, Fs] = audioread(FileName);
    sound_stereo = sound_stereo';
    size = length(sound_stereo); % sample lenth
    slength = size / Fs; % total time span of audio signal
    duration(2, ll) = num2cell(slength);
    fprintf(output, '%s\t%.2f\n', FileName, slength);
end
fclose(fid);

duration_list = duration';
