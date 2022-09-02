function thisTrial = playTrial(cfg, thisTrial, logFile)

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

    ISI = cfg.timing.trialDuration - thisTrial.duration;
    if thisTrial.target
        ISI = cfg.timing.targetDuration - thisTrial.duration;
    end
    WaitSecs(ISI);

    %% Save the events to the logfile
    saveEventsFile('save', cfg, thisTrial);

end
