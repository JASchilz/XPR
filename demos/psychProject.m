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

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);



xpr = xprmnt(window, 100);

text = xText('string', 'Press Any Key to Lose Your Mind', 'fontSize', 30);
text.setVis(true);

xpr.draw;

KBWait;

for i=1:20
    if mod(i, 2) == 0
        text.changeColor('color', rand(1,3)*255, 'interval',  1);
    end
    if mod(i, 3) == 0
        text.move('x', (rand-.5)*3, 'y', (rand-.5)*3, 'interval', 1.5);
    end
    if mod(i, 4) == 0
        text.scale('fontSize', 30+(rand-.5)*5, 'interval', 2);
    end
    
    xpr.animate(.5);
end

text.changeColor('color', [text.color(1:3), 0], 'interval', 2);
xpr.animate(2);
text.setVis(false);

load urnPts
poly = xPolygon('x', 0, 'y', 0, 'pointList', urnPts, 'color', [0, 200, 0]);
poly.setVis(true);

rect = xRect('x', 1, 'y', 1, 'color', [200, 0, 0]);
rect.setVis(true);

circ = xCirc('x', 1, 'y', 1, 'd', 2, 'color', [0, 0, 200, 100]);
circ.setVis(true);

xpr.draw;

WaitSecs(1);



poly.move('mode', 'rel', 'x', -1, 'y', -2, 'interval', 2);
poly.scale('scale', 2, 'interval', 2);
poly.changeColor('color', [0, 0, 255], 'interval', 1);

rect.move('mode', 'rel', 'x', 0, 'y', 2, 'interval', 2)
rect.scale('mode', 'rel', 'scaleW', 2, 'scaleH', 1, 'interval', 2);
rect.changeColor('color', [0, 0, 255], 'interval', 1);

circ.move('mode', 'abs', 'x', -2, 'y', -2, 'interval', 1);

xpr.animate(1, 'freeze', freezeKeys);

rect.changeColor('color', [155, 0, 255], 'interval', 1);

xpr.animate(1, 'freeze', freezeKeys);

waitSecs(1);

dots = xDots();
dots.setVis(true);
circ.setVis(false);

xpr.animate(inf, 'freeze', freezeKeys);

xpr.blank;

bar = xPointBar('x', 0, 'y', 0, 'pointsPD', 1, 'points', 2,...
    'growthVec', [1, 0, 1, 0]);
bar.setVis(true);
bar.changePoints('points', -2, 'interval', 4);
xpr.animate(4);

KbWait;
Screen('CloseAll');