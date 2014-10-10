% Psychtoolbox test
clear all

Screen('Preference', 'SkipSyncTests', 1);

input('Blablabla?: ');

KbName('UnifyKeyNames')
leftKey = KbName('leftarrow');
rightKey = KbName('rightarrow');
freezeKeys = [leftKey rightKey];

whichScreen = 0;
window = Screen(whichScreen,  'OpenWindow');

KBCheck;
xpr = xprmnt(window, 100);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);



dots = xDots('coherence', 1, 'x', 0, 'y', 0, 'direction', 0, 'diameter', 7, 'like_dXdots', true);
% dots2 = xDots('coherence', .75, 'x', 3, 'y', 3, 'direction', 180, 'like_dXdots', true);
% dots3 = xDots('coherence', .45, 'x', -3, 'y', -3, 'direction', 0, 'like_dXdots', true);
% dots4 = xDots('coherence', .25, 'x', 3, 'y', -3, 'direction', 180, 'like_dXdots', true);
dots.setVis(true);
% dots2.setVis(true);
% dots3.setVis(true);
% dots4.setVis(true);

xpr.animate(inf, 'freeze', freezeKeys);


Screen('CloseAll');