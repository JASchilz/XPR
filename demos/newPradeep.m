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

if goNoGo
    freezeKeys = [spaceBar];
else
    freezeKeys = [leftKey rightKey];
end

whichScreen = 0;
window = Screen(whichScreen,  'OpenWindow');

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

xpr = xprmnt(window, 100);

KBCheck;

%% Declare some 'globals' here
cross = xSet('membs',...
    {xLine('p1', [-.53 0], 'p2', [.53, 0]),...
    xLine('p1', [0 -.53], 'p2', [0 .53])});

bar = xPointBar('x', -6, 'y', 0, 'pointsPD', 33, 'points', 100,...
    'growthVec', [0, 1, 0, 0]);

text = xText('fontSize', 30);

dots = xDots('diameter', 4);

%% Fixation
cross.setVis(true);
xpr.animate(.5);
cross.setVis(false);

%% Stimulus Presentation
dots.setVis(true);

bar.setVis(true)
bar.changePoints('points', 0, 'interval', 1.2);

[keys, keyTime] = xpr.animate(1.2, 'freeze', freezeKeys);

bar.setVis(false);
dots.setVis(false);

%% Feedback
if ~isempty(keys) && keys(leftKey)
    text.color = [0 200 0];
    text.string = sprintf('%d points!', floor(bar.points));
else
    text.color = [200 0 0];
    bar.changePoints('points', 0);
    text.string = '0 points!';
end

text.setVis(true);

xpr.animate(.5);



KbWait;
Screen('CloseAll');