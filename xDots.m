classdef xDots < xObject & handle
    %xDots An animated coherent dot motion stimulus class in the XPR toolbox.
    %   This class provides an animated dot motion stimulus for the XPR toolbox.

    
    properties
        d = 2;          % the diameter of the patch, in degrees 
        coherence = .9; % percentage of dots moving in primary direction
        direction = pi; % primary direction of motion
        speed = 5;      % speed in terms of 
        
        density = .003; % dots per square degree
        lifeLimit = 4;  % the number of frames a dot will live
        
        frameRate = 1/24;   % the framerate at which the dots will animate
        
        xDat = [];      % x data for the dots
        yDat = [];      % y data for the dots
        lifeDat = [];   % length of life data for the dots
        dirDat = [];    % direction of motion data for the dots
        
        nextX = [];     % the x data to be used for the next frame
        nextY = [];     % the y data to be used for the next frame
        
        like_dXdots = false;    % whether we are imitating dXdots
        
        
        
        
        dXdotsPatch = false; % the dXdots object, if we're simulating one.
        xDotsXY = [0, 0];
        
        numDots = 0;
        nextTime = -inf;
        jumpSize = 0;
        
    end
    
    
    properties (Constant)
        
        p = xObject.makeInputParser(...
            { 'x', 0, @isnumeric;...
            'y', 0, @isnumeric;...
            'diameter', 5, @isnumeric;...
            'coherence', .9, @isnumeric;...
            'direction', pi, @isnumeric;...
            'color', [255, 255, 255], @isnumeric;...
            'like_dXdots', false, @islogical});
        
    end
    
    methods
        
        
        function self = xDots(varargin)
            
            global thisXprmnt;
            
            self.p.parse(varargin{:})
            in = self.p.Results;
            
                        
            [self.x self.y] = thisXprmnt.deg2pix([in.x, in.y]);
            
            self.color = in.color;
            
            self.coherence = in.coherence;
            self.direction = in.direction;
            
            self.d = in.diameter*thisXprmnt.ppd;
            
            self.numDots = pi*(self.d/2)^2*self.density;
            
            self.like_dXdots = in.like_dXdots;
            
            if self.like_dXdots
                self.dXdotsPatch = GoldsDots(1);
                self.dXdotsPatch = loadobj(self.dXdotsPatch);
                self.dXdotsPatch = set(self.dXdotsPatch, 'visible', true, ...
                    'x', in.x, 'y', in.y, 'direction', self.direction,...
                    'frameRate', 60, 'diameter', in.diameter,...
                    'coherence', self.coherence*100, 'speed', self.speed/1.3,...                    
                    'pixelsPerDegree', thisXprmnt.ppd,...
                    'screenRect', thisXprmnt.screenRect);
                
                self.dXdotsPatch = set(self.dXdotsPatch, 'visible', false);
                self.dXdotsPatch = set(self.dXdotsPatch, 'visible', true);
                
                self.xDotsXY = get(self.dXdotsPatch, 'drawRect');
                self.xDotsXY = self.xDotsXY(1:2);

            end

            
        end
        
        function [xDat, yDat, lDat, dDat] = createDots(self, numDotsCreate, coherence)
            % One thing is slightly unintuitive about this function:
            % numDotsCreate specifies how many dots should be created
            % within the _square_ of side length d. The function will then
            % remove any dots that don't fall within the _circle_ of radius
            % d. This is something I will probably change.
            
            if ~exist('coherence', 'var')
                coherence = self.coherence;
            end
            
            numCohDots = ceil(numDotsCreate*coherence);
                                
            xDat = rand(1, numDotsCreate)*2*(self.d/2) - (self.d/2);
            yDat = rand(1, numDotsCreate)*2*(self.d/2) - (self.d/2);

            if isempty(self.xDat)
                lDat = randi(self.lifeLimit, 1, numDotsCreate) - 1;
            else
                lDat = repmat(0, 1, numDotsCreate);
            end
            
            dDat = [repmat(self.direction, 1, numCohDots),...
                rand(1, numDotsCreate - numCohDots)*2*pi];
            
            inds = find(xDat.^2+yDat.^2 < (self.d/2)^2);
            
            xDat = xDat(inds);
            yDat = yDat(inds);
            lDat = lDat(inds);
            dDat = dDat(inds);

        end
        
        function resetGoldDots(self)
            
            global thisXprmnt;
            
            self.dXdotsPatch = set(self.dXdotsPatch,...
                    'x', self.x, 'y', self.y, 'direction', self.direction,...
                    'diameter', self.d,...
                    'coherence', self.coherence*100,...
                    'speed', self.speed/1.3,...                    
                    'pixelsPerDegree', thisXprmnt.ppd);
            
            
        end
        
        function calcDots(self)
            
            global thisXprmnt;
            
            newNext = false;
            
            if isempty(self.xDat)
                % If we have not yet created any dots, then create some,
                % and also cue a calculation of the next set of
                % coordinates.
                
                if self.like_dXdots
                    [self.dXdotsPatch, pts] = draw(self.dXdotsPatch);
                    
                    inds = find((pts(1,:)-.5).^2 +...
                        (pts(2,:)-.5).^2 < .5^2);
                    

                    self.xDat = pts(1,inds)*...
                        get(self.dXdotsPatch, 'drawSizePix');
                    self.yDat = pts(2,inds)*...
                        get(self.dXdotsPatch, 'drawSizePix');
                    
                else
                
                    numDotsCreate = floor(self.numDots*4/pi);

                    [self.xDat, self.yDat, self.lifeDat, self.dirDat] = ...
                        self.createDots(numDotsCreate);
                    
                
                end
                
                newNext = true;
                                
            elseif GetSecs >= self.nextTime
                % If there are already some dots, check if it's time to
                % move the 'next' set of coordinates into the 'current' set
                % of coordinates. If so, do it, and cue the calculation of
                % the next set of coordinates.
                
                self.xDat = self.nextX;
                self.yDat = self.nextY;

                % Age the current dots by one.
                self.lifeDat = self.lifeDat + 1;
                
                newNext = true;
            end
            
            if newNext
                % If we do have to calculate a new set of 'next'
                % coordinates...
                
                % We calculate the next time for a coordinate update.
                if self.nextTime + self.frameRate > GetSecs
                    self.nextTime = self.nextTime + self.frameRate;
                else
                    self.nextTime = GetSecs + self.frameRate;
                end
                
                if self.like_dXdots
                    %self.dXdotsPatch = set(self.dXdotsPatch, 'loopIndex', 3);
                    [self.dXdotsPatch, pts] = draw(self.dXdotsPatch);
                    
                    inds = find((pts(1,:)-.5).^2 +...
                        (pts(2,:)-.5).^2 < .5^2);
                    

                    self.nextX = pts(1,inds)*...
                        get(self.dXdotsPatch, 'drawSizePix');
                    self.nextY = pts(2,inds)*...
                        get(self.dXdotsPatch, 'drawSizePix');
                    
                    return;
                end
                
                % We calculate preliminary 'next' dot coordinates.
                self.nextX = self.xDat + (cos(self.dirDat))*self.speed;
                self.nextY = self.yDat + (sin(self.dirDat))*self.speed;
                
                % Some of these we will have to throw away, namely those
                % outside the circle or that have expired lifetimes. We
                % make a list of indices for dots we will be keeping.
                inds = find(self.nextX.^2+self.nextY.^2 < (self.d/2)^2 &...
                    self.lifeDat < self.lifeLimit);

                % We figure out how many new dots we will need, and then
                % create them.
                numNewDots = ceil((self.numDots - length(inds))*4/pi);
                [NewX, NewY, NewLife, NewDir] = ...
                        self.createDots(numNewDots);

                % We adjoin the list of new dots to the list of old dots
                % that we're keeping around.
                self.nextX = [self.nextX(inds), NewX];
                self.nextY = [self.nextY(inds), NewY];
                self.lifeDat = [self.lifeDat(inds), NewLife];
                self.dirDat = [self.dirDat(inds), NewDir];
                
                
                
            end
            
        end

        
        function draw(self, window)
            
            if max(self.moveDat)
                self.calcMove
            end
                        
            self.calcDots;
            
            if self.like_dXdots
                xy = self.xDotsXY;
            else
                xy = [self.x self.y];
            end
                
            self.xDat
            Screen('DrawDots', window,...
                [self.xDat; self.yDat], 2, self.color,...
                xy);
            

            
            
        end
        
        function freeze(self)
            self.moveDat = false;
        end
    end
    
end

