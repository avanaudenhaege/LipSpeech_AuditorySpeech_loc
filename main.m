% Clear all the previous stuff
clear;
clc;

if ~ismac
    close all;
    clear Screen;
end

targSound = 'tone.wav';

% make sure we got access to all the required functions and inputs
initEnv();

% set and load all the parameters to run the experiment
cfg = setParameters;

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
sylSeqOrder = Shuffle(SYLseq);
scrSeqOrder = Shuffle(SCRseq);

% Set the block order
bothSeq = [sylSeqOrder; scrSeqOrder];
blockOrder = bothSeq(:)';

if cfg.debug.do
    blockOrder = blockOrder(1:2);
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
    cfg.experimentStart = Screen('Flip', cfg.screen.win);

    getResponse('start', cfg.keyboard.responseBox);

    waitFor(cfg, cfg.timing.onsetDelay);

    for iBlock = 1:length(blockOrder)

        if strcmp(blockOrder{iBlock}, 'SYLseq01')
            Stimuli = SYLseq01;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq02')
            Stimuli = SYLseq02;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq03')
            Stimuli = SYLseq03;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq04')
            Stimuli = SYLseq04;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq05')
            Stimuli = SYLseq05;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq06')
            Stimuli = SYLseq06;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq07')
            Stimuli = SYLseq07;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq08')
            Stimuli = SYLseq08;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq09')
            Stimuli = SYLseq09;
        elseif strcmp(blockOrder{iBlock}, 'SYLseq10')
            Stimuli = SYLseq10;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq01')
            Stimuli = SCRseq01;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq02')
            Stimuli = SCRseq02;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq03')
            Stimuli = SCRseq03;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq04')
            Stimuli = SCRseq04;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq05')
            Stimuli = SCRseq05;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq06')
            Stimuli = SCRseq06;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq07')
            Stimuli = SCRseq07;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq08')
            Stimuli = SCRseq08;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq09')
            Stimuli = SCRseq09;
        elseif strcmp(blockOrder{iBlock}, 'SCRseq10')
            Stimuli = SCRseq10;
        end

        % number of stim
        nbStim = length(Stimuli);
        if cfg.debug.do
            nbStim = 6;
        end

        % Set the target for this block
        % it will randomly pick one of these
        possibleNumberOfTargets = [0 1 2];
        nbTargets = possibleNumberOfTargets(randperm(length(possibleNumberOfTargets), 1));
        % sort randomly the stimuli in the block
        [~, idx] = sort(rand(1, nbStim));
        % select the position of the target(s)
        positionTarget = sort(idx(1:nbTargets));

        talkToMe(cfg, sprintf('\nNumber of targets in coming trial: %i\n\n', nbTargets));

        for iTrial = 1:nbStim

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
            % wait for the playback to start,
            repetitions = [];
            when = [];
            waitForPlaybackStart = 1;
            onset = PsychPortAudio('Start', cfg.audio.pahandle, repetitions, when, waitForPlaybackStart);

            if iTrial == 1
                block_start = onset;
            end

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

            %% if this is a target
            if sum(iTrial == positionTarget) == 1

                thisTrial.stim_file = targSound;
                thisTrial.target = true;
                thisTrial.trial_type = 'target';

                wavfilename = fullfile(cfg.dir.stimuli, thisTrial.stim_file);
                audioData = audioread(wavfilename);
                thisTrial.audioData = audioData';

                % Fill the audio playback buffer with the audio data:
                PsychPortAudio('FillBuffer', cfg.audio.pahandle, thisTrial.audioData);

                % Start audio playback
                % wait for the playback to start,
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

                ISI = cfg.timing.target_duration - thisTrial.duration;
                WaitSecs(ISI);

                %% Save the events to the logfile
                % we save event by event so we clear this variable every loop
                thisTrial.isStim = logFile.isStim;
                thisTrial.fileID = logFile.fileID;
                thisTrial.extraColumns = logFile.extraColumns;
                saveEventsFile('save', cfg, thisTrial);

            end

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
        talkToMe(cfg, sprintf('\n\nTiming - Block duration: %0.3f seconds\n\n', block_duration));

        WaitSecs(cfg.timing.IBI);

    end

    loopDuration = (GetSecs() - cfg.experimentStart);
    loopDurationMin = floor(loopDuration / 60);
    loopDurationSec = mod(loopDuration, 60);
    talkToMe(cfg, sprintf('\n\nTiming - Run lasted %i minutes %0.3f seconds\n\n', ...
                          loopDurationMin, ...
                          loopDurationSec));

    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);

    % Close the logfiles
    saveEventsFile('close', cfg, logFile);
    createJson(cfg, cfg);

    % Pad the runtime to make sure all runs have same duraton
    % (due to random nb of targets)
    endDelay = cfg.timing.run_duration - loopDuration;
    if ~cfg.debug.do
        WaitSecs(endDelay);
    end

    cfg = getExperimentEnd(cfg);

    farewellScreen(cfg, 'Fin de l''experience :)\nMERCI !');

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
