classdef xprmnt < handle
    %xprmnt a class of objects defining a psychtoolbox experiment
    %   See example scripts for usage.
    
    properties
        window = 0;
        screenRect = [];
        screenDist = 0;
        ppd = 60;
        
        frameRate = 1/50;
        
        visObjs = {};
        allObjs = [];
        
        backGroundCol = [0, 0, 0];
    end
    
    methods
        
        function self = xprmnt(window, screenDist)
            self.window = window;
            self.screenDist = screenDist;
            
            self.screenRect = Screen('Rect', window);
            
            global thisXprmnt;
            thisXprmnt = self;
            
        end
        
        function [xPix yPix] = deg2pix(self, degree)
            
            pix = degree*self.ppd;
            
            xPix = self.screenRect(3)/2 + pix(:,1);
            yPix = self.screenRect(4)/2 - pix(:,2); 
            
        end
        
        function draw(self)
            
            Screen(self.window,'FillRect',self.backGroundCol)
            
            for i=1:length(self.visObjs)
                
                self.visObjs{i}.draw(self.window)
                
            end
            
            Screen(self.window, 'Flip');
            
        end
        
        function freeze(self)
            
            
            for i=1:length(self.visObjs)
                
                self.visObjs{i}.freeze;
                
            end
            
            
        end
        
        function [keyData keySecs] = animate(self, duration, keyBehavior,...
                freezeKeys)
            
            keyData = [];
            keySecs = [];
            
            if exist('keyBehavior', 'var') && strcmp(keyBehavior, 'freeze')
                freezeOnKey = true;
            else
                freezeOnKey = false;
            end
            
            startTime = GetSecs;
            endTime = startTime + duration;
            
            nextFrameStart = -inf;
            
            while GetSecs < endTime
                
                now = getSecs;
                waitSecs(nextFrameStart - now);
                nextFrameStart = now + self.frameRate;
                self.draw;
                
                [keyDown, secs, keyCodes] = KbCheck;
                
                if keyDown
                    
                    keyData(:,end+1) = keyCodes';
                    keySecs(:,end+1) = secs;
                    
                    if freezeOnKey && sum(keyCodes(freezeKeys))
                        
                        self.freeze;
                        return
                    end
                    
                end

            end
            
        end
        
        function blank(self)
            
            self.visObjs = {};
            
            self.draw;
            
        end
    end
    
end

