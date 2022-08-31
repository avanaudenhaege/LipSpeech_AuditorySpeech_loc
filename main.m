% Clear all the previous stuff
clear;
clc;
% cleanUp();

if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
initEnv();

% set and load all the parameters to run the experiment
cfg = setParameters;

fprintf('Connected Device is %s \n\n', cfg.testingDevice);

cfg = userInputs(cfg);

cfg = createFilename(cfg);

% Prepare for the output logfiles with all
logFile = struct('extraColumns', {cfg.extraColumns}, ...
                 'isStim', false);
logFile = saveEventsFile('init', cfg, logFile);
logFile = saveEventsFile('open', cfg, logFile);

%% SET THE STIMULI/CATEGORY
% load matfile containing the fixed sequences
talkToMe(cfg, '\nLoad stimuli:');
load sequences;

setUpRand();

% Set the sequences order
SYLseq_order = Shuffle(SYLseq);
SCRseq_order = Shuffle(SCRseq);

% Set the block order
both_seq = [SYLseq_order; SCRseq_order];
Block_order = both_seq(:)';

t = '.wav';
targ_sound = 'tone.wav';

if cfg.debug.do
    Block_order = Block_order(1:2);
end

%%  Experiment

% Safety loop: close the screen if code crashes
try

    %% Init the experiment
    cfg = initPTB(cfg);

    [cfg] = postInitializationSetup(cfg);

    unfold(cfg);

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);

    standByScreen(cfg);
    talkToMe(cfg, '\nWAITING FOR TRIGGER (Instructions displayed on the screen)\n\n');
    waitForTrigger(cfg);

    drawFixation(cfg);
    Screen('Flip', cfg.screen.win);

    cfg.experimentStart = GetSecs();

    getResponse('start', cfg.keyboard.responseBox);

    % start of run
    LoopStart = GetSecs();
    trial_start = LoopStart;

    waitFor(cfg, cfg.timing.onsetDelay);

    for iBlock = 1:length(Block_order)

        block_start = GetSecs();

        if strcmp(Block_order{iBlock}, 'SYLseq01')
            Stimuli = SYLseq01;
        elseif strcmp(Block_order{iBlock}, 'SYLseq02')
            Stimuli = SYLseq02;
        elseif strcmp(Block_order{iBlock}, 'SYLseq03')
            Stimuli = SYLseq03;
        elseif strcmp(Block_order{iBlock}, 'SYLseq04')
            Stimuli = SYLseq04;
        elseif strcmp(Block_order{iBlock}, 'SYLseq05')
            Stimuli = SYLseq05;
        elseif strcmp(Block_order{iBlock}, 'SYLseq06')
            Stimuli = SYLseq06;
        elseif strcmp(Block_order{iBlock}, 'SYLseq07')
            Stimuli = SYLseq07;
        elseif strcmp(Block_order{iBlock}, 'SYLseq08')
            Stimuli = SYLseq08;
        elseif strcmp(Block_order{iBlock}, 'SYLseq09')
            Stimuli = SYLseq09;
        elseif strcmp(Block_order{iBlock}, 'SYLseq10')
            Stimuli = SYLseq10;
        elseif strcmp(Block_order{iBlock}, 'SCRseq01')
            Stimuli = SCRseq01;
        elseif strcmp(Block_order{iBlock}, 'SCRseq02')
            Stimuli = SCRseq02;
        elseif strcmp(Block_order{iBlock}, 'SCRseq03')
            Stimuli = SCRseq03;
        elseif strcmp(Block_order{iBlock}, 'SCRseq04')
            Stimuli = SCRseq04;
        elseif strcmp(Block_order{iBlock}, 'SCRseq05')
            Stimuli = SCRseq05;
        elseif strcmp(Block_order{iBlock}, 'SCRseq06')
            Stimuli = SCRseq06;
        elseif strcmp(Block_order{iBlock}, 'SCRseq07')
            Stimuli = SCRseq07;
        elseif strcmp(Block_order{iBlock}, 'SCRseq08')
            Stimuli = SCRseq08;
        elseif strcmp(Block_order{iBlock}, 'SCRseq09')
            Stimuli = SCRseq09;
        elseif strcmp(Block_order{iBlock}, 'SCRseq10')
            Stimuli = SCRseq10;
        end

        % number of stim
        N_stim = length(Stimuli);

        % Set the target for this block
        % it will randomly pick one of these
        num_targets = [0 1 2];
        nT = num_targets(randperm(length(num_targets), 1));
        % sort randomly the stimuli in the block
        [~, idx] = sort(rand(1, N_stim));
        % select the position of the target(s)
        posT = sort(idx(1:nT));
        disp (strcat('Number of targets in coming trial:', num2str(nT)));

        for iTrial = 1:length(Stimuli)

            %  Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            thisTrial.trial_nb = iTrial;
            thisTrial.key_name = 'n/a';
            thisTrial.block_nb = iBlock;
            thisTrial.stim_file = Stimuli{iTrial};
            thisTrial.target = false;
            thisTrial.trial_type = Stimuli{iTrial}(1:3);

            wavfilename = fullfile(cfg.dir.stimuli, thisTrial.stim_file);
            audioData = audioread(wavfilename);
            thisTrial.audioData = audioData';

            % Fill the audio playback buffer with the audio data:
            PsychPortAudio('FillBuffer', cfg.audio.pahandle, thisTrial.audioData);

            % Start audio playback
            % 'repetitions' repetitions of the sound data,
            % start it immediately (0)
            % wait for the playback to start,
            % return onset timestamp.
            repetitions = [];
            when = [];
            waitForPlaybackStart = 1;
            onset = PsychPortAudio('Start', cfg.audio.pahandle, repetitions, when, waitForPlaybackStart);

            status.Active = true;
            while status.Active
                status = PsychPortAudio('GetStatus', cfg.audio.pahandle);
            end
            [~, ~, ~, offset] = PsychPortAudio('Stop', cfg.audio.pahandle);

            thisTrial.duration = offset - onset;
            thisTrial.onset = onset - cfg.experimentStart;

            ISI = cfg.timing.trial_duration - thisTrial.duration;
            WaitSecs(ISI);

            %% Save the events to the logfile
            % we save event by event so we clear this variable every loop
            thisTrial.isStim = logFile.isStim;
            thisTrial.fileID = logFile.fileID;
            thisTrial.extraColumns = logFile.extraColumns;
            saveEventsFile('save', cfg, thisTrial);

            %% Collect and saves the responses
            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg);
            if isfield(responseEvents(1), 'onset') && ~isempty(responseEvents(1).onset)
                for iResp = 1:size(responseEvents, 1)
                    responseEvents(iResp).onset = ...
                        responseEvents(iResp).onset - cfg.experimentStart;
                    responseEvents(iResp).key_name = responseEvents(iResp).keyName;
                end
                responseEvents(1).isStim = false;
                responseEvents(1).fileID = logFile.fileID;
                responseEvents(1).extraColumns = logFile.extraColumns;

                saveEventsFile('save', cfg, responseEvents);
            end

        end

        block_end = GetSecs();
        block_duration = block_end - block_start;
        disp (strcat('Block duration: ', num2str(block_duration)));

        WaitSecs(cfg.timing.IBI);

    end

    % End of the run
    waitFor(cfg, cfg.timing.endDelay);

    LoopEnd = GetSecs();
    loop_duration = (LoopEnd - LoopStart);

    getResponse('stop', cfg.keyboard.responseBox);

    % Close the logfiles
    saveEventsFile('close', cfg, logFile);
    createJson(cfg, cfg);

    cfg = getExperimentEnd(cfg);

    getResponse('release', cfg.keyboard.responseBox);

    farewellScreen(cfg, 'Fin de l''experience :)\nMERCI !');

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
