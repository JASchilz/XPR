classdef xPointBar < xObject & handle
    %xPointBar An animated points bar class in the XPR toolbox.
    %   This class provides an animated points bar for the XPR toolbox.
    %   Note that for this class, x and y specify the center of the 0
    %   points mark for the bar.
    %   
    %   This bar can be used solely as a timing bar.
    
    properties
        % We define here all properties that the object class should have
        % in addition to those specified by the xObject parent class.
        % Default values are specified in the properties (Constant)
        % section.
        
        w;          % Width of the bar about the axis of growth, in visual
                    % degrees.
        
        
        
        pointsPD;   % Points per visual degree of the bar.
        
        points;     % the number of points represented by the bar.
        
        negColor;   % The color to use when  
        
    end
    
    properties (SetAccess = private)
        
        growthVec;  % Specifies the direction in which the bar grows with
                    % increasing points. A bar can grow horizontally or
                    % vertically, but not both. Subject to that
                    % specification, it can grow in only one direction or
                    % it can grow in two directions. Specify direction with
                    % a vector such as the following:
                    %
                    % [leftGrowth, upGroth, rightGrowth, downGrowth]
                    %
                    % Where each of the values above is boolean.
        
        xGrow;      % A variable to track whether the bar grows
                    % horizontally or vertically.
        
        repointDat = false;
        
        
    end
    
    properties (Constant)
        % We give each class a constant input parser object. So that we can
        % achieve this with one function call, we've created a static
        % method in the xObject parent class called makeInputParser. We
        % specify default values and validity check function handles for
        % each of the user-specified object properties. For syntax
        % questions, see help xObject.makeInputParser
        
        p = xObject.makeInputParser(...
            { 'x', 0, @isnumeric;...
            'y', 0, @isnumeric;...
            'w', 1, @isnumeric;...
            'growthVec', [0, 1, 0, 0], @isnumeric;...
            'pointsPD', 10, @isnumeric;...
            'points', 0, @isnumeric;...
            'color', [0, 255, 0], @isnumeric;
            'negColor', [255, 0, 0], @isnumeric});
            
    end
    
    methods
        
        function self = xPointBar(varargin)
            % The constructor for xPointBar.
            %
            % Syntax: rect = xPointBar('property', val, 'property', val...
            %
            % Properties available: x, y, w, growthVec, pointsPD, points,
            % color, negColor. See xPointBar.m and xObject.m for more
            % information.
            
            global thisXprmnt;
            
            % We parse the input through the class input parser p.
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            % We set the colors to that value specified by the user.
            self.color = in.color;
            self.negColor = in.negColor;
            
            % We set x and y to those values specified by the user.
            self.x = in.x;
            self.y = in.y;
            
            % Also for width, growth dim, starting points, and pointsPD.
            self.w = in.w;
            self.growthVec = in.growthVec;
            self.points = in.points;
            self.pointsPD = in.pointsPD;
            
            % Finally, we note whether this bar grows horizontally or
            % vertically.
            if in.growthVec(1) || in.growthVec(3)
                self.xGrow = true;
            else
                self.xGrow = false;
            end
            
            
        end
        
        function changePoints(self, varargin)
            % A class method for changing the number of points on the bar.
            %
            % Syntax: pointBar.scale('property', val, 'property', val...
            % 
            % Properties available:
            %
            % 'points': number, default 0. The number of points that should
            % now be on the bar.
            %
            % 'interval': non-negative number, default 0. The interval over
            % which to animate the change in points. An interval of 0
            % specifies an immediate resizing. An interval of 1 specifies
            % a smooth % rescaling over the course of 1 second.
            
            % We take a copy of the class input parser
            thisP = self.p.createCopy;
            
            % and add the additional parameters that we'll need.
            thisP.addParamValue('interval', 0, @(x)isnumeric(x) && x>=0);
            
            % We then parse the input.
            thisP.parse(varargin{:});
            in = thisP.Results;
            
            finalPoints = in.points;
            
            % We add this new scaling program to self.scaleDat, to be used
            % the next time this object is drawn.
            self.repointDat = [GetSecs in.interval finalPoints self.points];
            
            
        end
        
        function draw(self, window)
            % This is the class method for drawing an xRect object.
            %
            % This method executes any standing object repointing or moving
            % programs, calculates draw parameters, and calls the
            % PsychToolbox Screen('FillRect',... method. This method is
            % generally called by the thisXprmnt object methods, rather
            % than by the user created experiment script/function. See
            % xprmnt.mat for more information.
            %
            % Syntax: rect.draw(window)
            %
            % Input: window, the PsychToolbox window to which we would like
            % to draw the rectangle.
            
            global thisXprmnt;
            
            % If there is an outstanding move program, execute the calcMove
            % method. This is specified in the xObject class.
            if max(self.moveDat)
                self.calcMove
            end
            
            % If there is a standing scaling program, calculate the new
            % scale of the rectangle.
            if max(self.repointDat)
                
                % We calculate how far through the scale interval we've
                % progressed. A value of 0 means we've just begun, a value
                % of 1 or greater means that the interval is over.
                repointProg = (GetSecs - ...
                    self.repointDat(1))/self.repointDat(2);
                
                % If the interval is over...
                if repointProg >= 1
                    
                    % then set the width and heigh to the final width and
                    % height specified by the scaling program,
                    self.points = self.repointDat(3);
                    
                    % and note that we've completed the repointing program.
                    self.repointDat = false;
                    
                % If we're still within the repointing interval...
                else
                    
                    % then set the width and height to the appropriate
                    % weighted sum of the old and final widths and heights.
                    self.points = repointProg*self.repointDat(3) +...
                        (1 - repointProg)*self.repointDat(4);


                end
                
                
            end
            
            if self.points >= 0
                thisColor = self.color;
            else
                thisColor = self.negColor;
            end
            
            % We convert the four visual degree valued parameters into
            % their pixel equivalents.
            [pixX pixY] = thisXprmnt.deg2pix([self.x, self.y]);
            pixW = thisXprmnt.ppd*self.w;
            pointsPerPix = self.pointsPD/thisXprmnt.ppd;
            
            barLength = self.points/pointsPerPix;
            
            if self.xGrow
                fillRect = [pixX - self.growthVec(1)*barLength,...
                    pixY - pixW/2,...
                    pixX + self.growthVec(3)*barLength,...
                    pixY + pixW/2];
            else
                fillRect = [pixX - pixW/2,...
                    pixY - self.growthVec(2)*barLength,...
                    pixX + pixW/2,...
                    pixY + self.growthVec(4)*barLength];
            end
            
            if fillRect(2) > fillRect(4)
                fillRect([2 4]) = fillRect([4 2]);
            end
            
            if fillRect(1) > fillRect(3)
                fillRect([1 3]) = fillRect([3 1]);
            end
            
            Screen('FillRect', window, thisColor, fillRect );
            
            
        end
        
        function freeze(self)
            % A class method to terminate all standing animation programs.
            %
            % This method is generally called by thisXprmnt.animate method,
            % to halt animation in cases when, for example, the user has
            % pressed a response key and we wish for all objects to freeze
            % in place.
            %
            % Syntax: pointBar.freeze
            
            self.repointDat = false;
        end
        
    end
    
    
    
end

