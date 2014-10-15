XPR
===

Object Oriented, Animation Oriented, Psychovisual Experiment Composition Layer for Psychtoolbox

XPR is a toolkit for running psycho-visual experiments in Matlab. It's a layer that sits on top of Psychtoolbox. I designed XPR to be:

Object Oriented
---------------
XPR is object oriented, easily comprehensible, and easily extensible.

Animation Oriented
------------------
XPR specifically eases coding of animations. It requires just one simple line to tell a rectangular countdown timer to shrink to nothing over the course of the following x seconds. Similarly, primitives can be told to smoothly enlarge, change color, move, etc., over a parameterized amount of time with a single function call.

Cross Platform
--------------
XPR maintains the cross-platform compatibility of Psychtoolbox.


Examples
========

For a complete example, see minimal_experiment.m. Included below are some excerpts.

In the following examples, we create an two-forced alternative choice task in which the subject is presented with a white disc in the center of the screen which is moving to either the left or the right. Subject is tasked to indicate the direction of movement with the arrow keys with three seconds of stimulation onset. A timer/points bar represents the points/time available to the subject as the task progresses.

Create a white circle stimuli, to be presented in the center of the screen, with a diameter of 1.5 visual degrees:

```
    stimuli.circle = xCirc('x', 0,...
    'y', 0,...
    'd', 1.5,...
    'color', [240, 240, 240]);
```

Create a timer/points bar:

```
    stimuli.pointBar = xPointBar('x', -5,...
    'y', 0);
```
This timer/points bar will be on the left center of the screen. By default, this bar will start off green and "shrink" until it runs out of time/points. Though our experiment does not contain a penalty phase, this bar would turn red and grow to indicate a growing point-penalty if instructed to.

Register names for the left and right arrow keys:
```
    response.leftKey = KbName('leftarrow');
    response.rightKey = KbName('rightarrow');
```

Now the trial begins. We randomly choose a direction 'param.dir' of 1 or -1 and then set the scene as follows:

```
    stimuli.circle.setVis(true); % Make the circle visible
    stimuli.circle.move('x', 0); % Return the circle to the center of the screen
    
    stimuli.circle.move('x', param.dir, 'interval', 3);
    % Direct the circle to move one visual degree to the left or the right, according
    % to the value of param.dir, over the course of three seconds
    
    stimuli.pointBar.setVis(true); % Set the points/timer bar to be visible
    stimuli.pointBar.changePoints('points', 30); % Put 30 points on the pointbar.
    
    stimuli.pointBar.changePoints('points', 0, 'interval', 3); 
    % Direct the point/timer bar to shrink down to zero points over the course of
    % three seconds.
    
    
    [keys, keyTime] = xpr.animate(3, 'freeze', [response.leftKey response.rightKey]);
    % We have instructed all of our objects where to move over the course of the
    % next three seconds. That done, we animate the scene. This instruction says to
    % animate our scene for three seconds, but to stop the animation if the subject
    % hits either the left arrow or the right arrow.
    
    
    points = floor(stimuli.pointBar.points);
    % Record the number of points left on the pointBar when we froze the animation
    
    
    stimuli.circle.setVis(false);
    stimuli.pointBar.setVis(false);
    % Hide the circle and the point bar in preparation for feedback delivery
    
```

Then we would do some logic to figure out whether the subject provided a response, whether it was the correct response, and how many points we should award the subject. We might employ an xText object to display feedback, as done in minimal_experiment.m.


Getting Started
===============

Download, and place the XPR directory in your path.

You must have psychtoolbox to use XPR. XPR is a toolkit which executes the more basic functions of psychtoolbox.


Notes
=====

I'm away from my Matlab environment, and until I regain it I might not be much help in fixing bugs or writing documentation. Right now, it will require an expert user to install and use XPR. Study minimal_experiment.m and the source code for inspiration.

To-Do
=====

* Better comments.
* Going to rework the xObject animation queue. Behavior will change.
* Documentation.

Getting Involved
================

Ways to get involved:

* Writing scripts which demonstrate the animation capabilities of each object.
* Writing documentation, if you understand the system.
