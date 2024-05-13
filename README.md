# Phonology processing regions : LOCALIZER

script from Stefania Mattioni - adapted by Alice Van Audenhaege

Jan2022

## RUN DESCRIPTION

There are 20 blocks.

Categories of stimuli = 2 (syllable and scramble).

Alternation SYLL-SCR-SYLL-SCR-....

10 fixed sequences of 15 bisyll pseudowords. 1 sequence presented per block.

Order of sequences randomized for each particpant.

## BLOCK DESCRIPTION

In each block, all the stimuli of the sequence are presented sequentially.

Trial duration = duration of each audio file + n msec to arrive to 1.2s/trial.
?????????? OR 1s ????????????

In each block there are either 0, 1 or 2 (randomly decided) targets.

The participant has to press when he/she hears a target.

A target is a pure tone (duration 0.5s).

Each block has a duration of 18, 19, 20 s (depending if 0, 1 or 2 targets).

## TIME CALCULATION for a RUN

2 categories with 15 stimulus each one;

trial duration= 1.2s (stim of various duration + ISI);

block duration = 1 category in each block + 0/1/2 targets = 18/19/20s

1 pause of 8s at the beginning of the run

20 blocks per run : minimum 360s / maximum 400s (according to 0, 1 or 2 targets)

20 pauses of 6s = 120s

MINIMUM DURATION = 488s (8min08sec) / MAXIMUM DURATION = 528s (8 min 48 sec)

Fixation cross to fill the time difference to get to 528s anyway.

## ACTION and VARIABLE SETTING

The only variable you need to manually change is Cfg.device at the beginning of
the script. Put either 'PC' or 'Scanner'.

Once you will Run the script you will be asked to select some variables:

1. Group (TO DEFINE): for the moment only controls CON is defined as default
2. SubID
3. Run Number : 1st or 2nd run

## STIMULI

To be used with a folder named `stimuli` containing the following files stored
on OSF in `AuditorySpeech-loc_stimuli.zip`

https://osf.io/2xtsn/?view_only=22f09bb4dc5f4a11823103141ca2f735
