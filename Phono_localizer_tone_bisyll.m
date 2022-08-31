clear all;
clc;
Screen('Preference', 'SkipSyncTests', 1);

%% Device
% Cfg.device = 'PC'; %(Change manually: 'PC' or 'mri')
cfg.testingDevice = 'mri';
fprintf('Connected Device is %s \n\n', cfg.testingDevice);

%% SET THE MAIN VARIABLES
global  GlobalGroupID GlobalSubjectID GlobalRunNumberID GlobalStimuliID

%% HNS: Hearing non signers; HES:Hearing early signers; HLS:Hearing late signers; DES:Deaf early signers
GlobalGroupID = 'CON'; % input ('Group (HNS-HES-HLS-DES):','s');
%% (BIDS format for subj name = sub-XX)
GlobalSubjectID = input('Subject ID (sub-XX): ', 's');
GlobalRunNumberID = input('Run Number(1 - 2): ', 's');

%% TRIGGER
% num of excluded volumes (first 2 triggers) [NEEDS TO BE CHECKED]
cfg.mri.triggerNb = 1;
% the keycode for the trigger
cfg.mri.triggerKey = 's';

%% SETUP OUTPUT DIRECTORY AND OUTPUT FILE

% if it doesn't exist already, make the output folder
output_directory = 'output_files';
if ~exist(output_directory, 'dir')
    mkdir(output_directory);
end

output_file_name = [output_directory '/output_file_' GlobalGroupID '_' GlobalSubjectID '_ses-01_task-PhonoLoc_events.tsv'];

% 'a'== PERMISSION: open or create file for writing; append data to end of file
logfile = fopen(output_file_name, 'a');
fprintf(logfile, 'onset\tduration\ttrial_type\tstim_name\tloop_duration\tresponse_key\ttarget\ttrial_num\tblock_num\trun_num\tsubjID\tgroupID\n');

%% SET THE STIMULI/CATEGORY
load sequences; % load matfile containing the fixed sequences

% Set the sequences order
SYLseq_order = Shuffle(SYLseq);
SCRseq_order = Shuffle(SCRseq);

% Set the block order
both_seq = [SYLseq_order; SCRseq_order];
Block_order = both_seq(:)';

% number of blocks in a full run
N_block = [1:length(Block_order)];
% number of stim in one block
N_stim = length(SYLseq01);

TAR = 0; % will be used it to print target/non target stimuli
responseKey = 'n/a'; % will be used to print response when key press
run_duration = 528;

%% START TO PREPARE THE AUDIO DRIVERS and SET THE VARIABLES FOR THE SOUND DELIVERY
% initialize the sound driver
InitializePsychSound(1);
% Set the frequency
Fs = 44100;
% Set the number of channels both for the audiodata we present and the audiodata
% we record
numChannels = 2;

% OPEN THE SCREEN
% open the screen
[wPtr, rect] = Screen('OpenWindow', max(Screen('Screens')));
% draw a black rectangle (big as all the monitor) on the back buffer
Screen('FillRect', wPtr, [0 0 0]);
% flip the buffer, showing the rectangle
Screen ('Flip', wPtr);
HideCursor(wPtr);

% STIMULI SETTING
trial_duration = 1.2;
target_duration = 1;

% STIMULUS RECTANGLE (in the center)
screenWidth = rect(3);
screenHeight = rect(4);
screenCenterX = screenWidth / 2;
screenCenterY = screenHeight / 2;

% STIMULI FOLDER

stimFolder = 'Sound_stimuli';
t = '.wav';
targ_sound = 'tone.wav';

% FIX CROSS
crossLength = 40;
crossColor = [200 200 200];
crossWidth = 5;
% Set start and end point of lines
crossLines = [-crossLength, 0; crossLength, 0; 0, -crossLength; 0, crossLength];
crossLines = crossLines';

% save the response keys into a cell array
Resp = num2cell(zeros(length(Block_order), N_stim));
Onset = zeros(length(Block_order), N_stim);
Name = num2cell(zeros(length(Block_order), N_stim));
Duration = zeros(length(Block_order), N_stim);

try  % safety loop: close the screen if code crashes
    %% TRIGGER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', wPtr, 50); % text size
    DrawFormattedText(wPtr, '\n READY TO START \n \n - Détectez le son cible -', ['center'], ['center'], [200 200 200]);
    Screen('Flip', wPtr);

    waitForTrigger(cfg); % this is the function from CPP github

    % Draw THE FIX CROSS
    Screen('DrawLines', wPtr, crossLines, crossWidth, crossColor, [screenCenterX, screenCenterY]);
    % Flip the screen
    Screen('Flip', wPtr);

    LoopStart = GetSecs();
    trial_start = LoopStart; % start of run

    WaitSecs(8); % wait 8sec at the beginning of the run

    % Block loop (15 stim x 20 blocks)
    for b = 1:length(Block_order)
        block_start = GetSecs();

        if strcmp(Block_order{b}, 'SYLseq01')
            Stimuli = SYLseq01;
        elseif strcmp(Block_order{b}, 'SYLseq02')
            Stimuli = SYLseq02;
        elseif strcmp(Block_order{b}, 'SYLseq03')
            Stimuli = SYLseq03;
        elseif strcmp(Block_order{b}, 'SYLseq04')
            Stimuli = SYLseq04;
        elseif strcmp(Block_order{b}, 'SYLseq05')
            Stimuli = SYLseq05;
        elseif strcmp(Block_order{b}, 'SYLseq06')
            Stimuli = SYLseq06;
        elseif strcmp(Block_order{b}, 'SYLseq07')
            Stimuli = SYLseq07;
        elseif strcmp(Block_order{b}, 'SYLseq08')
            Stimuli = SYLseq08;
        elseif strcmp(Block_order{b}, 'SYLseq09')
            Stimuli = SYLseq09;
        elseif strcmp(Block_order{b}, 'SYLseq10')
            Stimuli = SYLseq10;
        elseif strcmp(Block_order{b}, 'SCRseq01')
            Stimuli = SCRseq01;
        elseif strcmp(Block_order{b}, 'SCRseq02')
            Stimuli = SCRseq02;
        elseif strcmp(Block_order{b}, 'SCRseq03')
            Stimuli = SCRseq03;
        elseif strcmp(Block_order{b}, 'SCRseq04')
            Stimuli = SCRseq04;
        elseif strcmp(Block_order{b}, 'SCRseq05')
            Stimuli = SCRseq05;
        elseif strcmp(Block_order{b}, 'SCRseq06')
            Stimuli = SCRseq06;
        elseif strcmp(Block_order{b}, 'SCRseq07')
            Stimuli = SCRseq07;
        elseif strcmp(Block_order{b}, 'SCRseq08')
            Stimuli = SCRseq08;
        elseif strcmp(Block_order{b}, 'SCRseq09')
            Stimuli = SCRseq09;
        elseif strcmp(Block_order{b}, 'SCRseq10')
            Stimuli = SCRseq10;
        end

        % Set the target for this block
        num_targets = [0 1 2]; % it will randomly pick one of these
        nT = num_targets(randperm(length(num_targets), 1));
        [~, idx] = sort(rand(1, N_stim)); % sort randomly the stimuli in the block
        posT = sort(idx(1:nT)); % select the position of the target(s)
        disp (strcat('Number of targets in coming trial:', num2str(nT)));

        %% stimulus loop
        for n = 1:length(Stimuli) %% num of stimuli in each block
            Stim_start = GetSecs();
            keyIsDown = 0;

            % LOAD THE SOUND
            pahandle = PsychPortAudio('Open', [], [], 0, Fs, numChannels);
            wavfilename = fullfile(stimFolder, Stimuli{n});
            % Prepare the audio data for each matrix square
            [sound_stereo, Fs] = audioread(wavfilename);
            sound_stereo = sound_stereo';

            size = length(sound_stereo); % sample lenth
            slength = size / Fs; % total time span of audio signal

            % Fill the buffer with each matrix square
            PsychPortAudio('FillBuffer', pahandle, sound_stereo);

            % Play the sound of the matrix square (pieno/vuoto)
            time_stim = PsychPortAudio('Start', pahandle, [], [], 1);

            %               %check the response during the stimulis presentation
            while (GetSecs - (Stim_start)) <= trial_duration
                % register the keypress
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && min(~strcmp(KbName(keyCode), cfg.mri.triggerKey))
                    responseKey = KbName(find(keyCode));
                    %                     else
                    %                         responseKey = 'n/a';
                end
            end

            loop_end = GetSecs();

            fprintf(logfile, '%.2f\t%.2f\t%s\t%s\t%.2f\t%s\t%d\t%d\t%d\t%s\t%s\t%s\n', ...
                    time_stim - LoopStart, ...
                    slength, ...
                    Stimuli{n}(1:3), ...
                    Stimuli{n}, ...
                    loop_end - Stim_start, ...
                    responseKey, ...
                    TAR, ...
                    n, ...
                    b, ...
                    GlobalRunNumberID, ...
                    GlobalSubjectID, ...
                    GlobalGroupID);

            trial_start = trial_start + trial_duration;
            TAR = 0; % reset the Target hunter as 0 (==no target stimulus);
            responseKey = 'n/a'; % reset the response print to null

            Name(b, n) = Stimuli(n);
            Resp(b, n) = {responseKey};
            Onset(b, n) = time_stim - LoopStart;
            Duration(b, n) = slength;

            %% if this is a target repeat the same stimulus

            if sum(n == posT) == 1
                TAR = 1;
                Stim_start = GetSecs();
                % LOAD THE SOUND
                pahandle = PsychPortAudio('Open', [], [], 0, Fs, numChannels);
                wavfilename = fullfile(stimFolder, targ_sound);
                % Prepare the audio data for each matrix square
                [sound_stereo, Fs] = audioread(wavfilename);
                sound_stereo = sound_stereo';

                size = length(sound_stereo); % sample length
                slength = size / Fs;

                % Fill the buffer with each matrix square
                PsychPortAudio('FillBuffer', pahandle, sound_stereo);

                % Play the sound of the matrix square (pieno/vuoto)
                time_stim = PsychPortAudio('Start', pahandle, [], [], 1);

                %               %check the response during the stimuli presentation
                while (GetSecs - (Stim_start)) <= target_duration
                    % register the keypress
                    [keyIsDown, secs, keyCode] = KbCheck(-1);
                    if keyIsDown && min(~strcmp(KbName(keyCode), cfg.mri.triggerKey))
                        responseKey = KbName(find(keyCode));
                    end
                end

                loop_end = GetSecs();

                fprintf(logfile, '%.2f\t%.2f\t%s\t%s\t%.2f\t%s\t%d\t%d\t%d\t%s\t%s\t%s\n', ...
                        time_stim - LoopStart, ...
                        length, ...
                        'target', ...
                        targ_sound, ...
                        loop_end - Stim_start, ...
                        responseKey, ...
                        TAR, ...
                        n, ...
                        b, ...
                        GlobalRunNumberID, ...
                        GlobalSubjectID, ...
                        GlobalGroupID);

                trial_start = trial_start + target_duration;
                TAR = 0; % reset the Target hunter as 0 (==no target stimulus)
                responseKey = 'n/a'; % reset the response print to null

                Name_target(b, n) = Stimuli(n);
                Resp_target(b, n) = {responseKey};
                Onset_target(b, n) = time_stim - LoopStart;
                Duration_target(b, n) = slength;
            end % if this is a target

        end % for n stimuli
        block_end = GetSecs();
        block_duration = block_end - block_start;
        disp (strcat('Block duration: ', num2str(block_duration)));

        length_IBI = 6;
        WaitSecs(length_IBI);

        IBI_variable(b, 1) = length_IBI;

    end % for b(lock)

    % Play the sound of the matrix square (pieno/vuoto)
    PsychPortAudio('Close', pahandle);
    LoopEnd = GetSecs();
    loop_duration = (LoopEnd - LoopStart);

    disp(strcat('Timing : the run took (min)', num2str((loop_duration) / 60)));
    disp(strcat('Timing : the run took (sec)', num2str(loop_duration)));

    % FILL the time difference with baseline (due to random nb of targets)
    % Draw THE FIX CROSS
    Screen('DrawLines', wPtr, crossLines, crossWidth, crossColor, [screenCenterX, screenCenterY]);
    % Flip the screen
    length_endFix = (run_duration - loop_duration);
    endFix_time = Screen('Flip', wPtr);

    WaitSecs(length_endFix);

    RunEnd = GetSecs();
    disp(strcat('Timing : the run closed after (sec)', num2str(RunEnd - LoopStart)));

    Screen(wPtr, 'Close');
    sca;

catch
    clear Screen;
    %% Close serial port of the scanner IF CRASH OF THE CODE
    if strcmp(cfg.testingDevice, 'mri')
        CloseSerialPort(SerPor);
    end
    error(lasterror);
end
WaitSecs(1); % wait 1 sec before to finish

cd('output_files');
save(strcat (GlobalSubjectID, '_', GlobalStimuliID, '_Onsetfile_', GlobalRunNumberID, '.mat'), ...
     'Onset', ...
     'Name', ...
     'Duration', ...
     'Resp', ...
     'Onset_target', ...
     'Name_target', ...
     'Duration_target', ...
     'Resp_target', ...
     'IBI_variable');
