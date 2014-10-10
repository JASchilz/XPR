% Psychtoolbox test
clear all

goNoGo = false;
dir = pi;

Screen('Preference', 'SkipSyncTests', 1);

input('Blablabla?: ');

KbName('UnifyKeyNames')
leftKey = KbName('leftarrow');
rightKey = KbName('rightarrow');
spaceBar = KbName('space');


freezeKeys = [leftKey rightKey];


whichScreen = 0;
window = Screen(whichScreen,  'OpenWindow');

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

xpr = xprmnt(window, 100);

KBCheck;

%% Declare some 'globals' here
cross = xSet('membs',...
    {xLine('p1', [-.53 0], 'p2', [.53, 0]),...
    xLine('p1', [0 -.53], 'p2', [0 .53])});

text = xText('fontSize', 30);


numTrials = [10, 10, 10, repmat(40, 1, 10)];
cohs = [.85, .75, .55, Shuffle([.10, .25, .55, .75, .95]), Shuffle([.10, .25, .55, .75, .85])];

results = [];
cohsUsed = [];

for block = 1:length(numTrials)
    
    waitSecs(1);
    if block <= 3
        text.string = sprintf('Press Any Key to Begin Warm-up %d of 3', block);
    else
        text.string = sprintf('Press Any Key to Begin Block %d of 10', block-3);
    end
    
    text.setVis(true);
    xpr.draw;
    KbWait;
    text.setVis(false);
    xpr.draw;
    
    for trial = 1:numTrials(block)
        
        
        waitSecs(.5)
        thisDir = (randi(2) - 1);
        thisCoh = cohs(block);
        
        
        dots = xDots('diameter', 4, 'direction', thisDir*pi, 'coherence', thisCoh);
        cohsUsed(end+1) = thisCoh;

        %% Fixation
        cross.setVis(true);
        xpr.animate(.5);
        cross.setVis(false);

        %% Stimulus Presentation
        dots.setVis(true);

        [keys, keyTime] = xpr.animate(1);

        dots.setVis(false);

        [keys, keyTime] = xpr.animate(inf, 'freeze', freezeKeys);

        %% Feedback
        if (keys(leftKey) && thisDir == 1) || (keys(rightKey) && thisDir == 0)
            text.color = [0 200 0];
            text.string = 'Right!';
            results(end+1) = 1;
        else
            text.color = [200 0 0];
            text.string = 'Wrong!';
            results(end+1) = 0;
        end

        text.setVis(true);

        xpr.animate(.5);

        text.setVis(false);

    end
    
    waitSecs(1);
    text.string = 'Block complete: press any key to continue.';
    text.color = [255 255 255];
    
    text.setVis(true);
    xpr.draw;
    KbWait;
    text.setVis(false);
    xpr.draw;
end



KbWait;
Screen('CloseAll');