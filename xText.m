classdef xText < xObject & handle
    %xSquare Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % We define here all properties that the object class should have
        % in addition to those specified by the xObject parent class.
        % Default values are specified in the properties (Constant)
        % section.

        string;
        
        fontSize;
        
        font;
        bold;
        italic;
        underline;
        
    end
    
    properties (SetAccess = private)
        
        scaleDat = false;
        
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
            'string', '', @ischar;...
            'fontSize', 30, @isnumeric;...
            'bold', true, @islogical;...
            'italic', false, @islogical;...
            'underline', false, @islogical;...
            'font', 'Courier', @ischar;...
            'color', [255, 255, 255], @isnumeric});
            
    end
    
    methods
        
        function self = xText(varargin)
            % The constructor for xRect.
            %
            % Syntax: rect = xRect('property', val, 'property', val...
            %
            % Properties available: x, y, w, h, color. See xRect.m and
            % xObject.m for more information.
            
            global thisXprmnt;
            
            % We parse the input through the class input parser p.
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            % We set the color to that value specified by the user.
            if length(in.color) == 4
                self.color = in.color;
            else
                self.color = [in.color, 255];
            end
            
            % We set x and y to those values specified by the user.
            self.x = in.x;
            self.y = in.y;
            
            % Likewise for width and height.
            self.string = in.string;
            self.fontSize= in.fontSize;
            
            
            
            
        end
        
        function scale(self, varargin)
            % A class method for scaling the rectangle.
            %
            % Syntax: rect.scale('property', val, 'property', val...
            % 
            % Properties available:
            %
            % 'mode':'abs' or 'rel', default 'abs'. 'abs' will rescale the
            % rectangle to the width and height specified by 'scaleH' and
            % 'scaleW'. 'rel' will shrink or grow the height according to
            % the factors provided by 'scaleH' and 'scaleW'.
            %
            % 'scaleH': number, default 1. The height scaling factor, to be
            % used as specified by 'mode'.
            %
            % 'scaleW': number, default 1. The width scaling factor, to be
            % used as specified by 'mode'.
            %
            % 'interval': non-negative number, default 0. The interval over
            % which to animate the scaling. An interval of 0 specifies an
            % immediate rescaling. An interval of 1 specifies a smooth
            % rescaling over the course of 1 second.
            
            % We take a copy of the class input parser
            thisP = self.p.createCopy;
            
            % and add the additional parameters that we'll need.
            thisP.addParamValue('interval', 0, @(x)isnumeric(x) && x>=0);
            
            % We then parse the input.
            thisP.parse(varargin{:});
            in = thisP.Results;
            
            % We add this new scaling program to self.scaleDat, to be used
            % the next time this object is drawn.
            self.scaleDat = [GetSecs in.interval in.fontSize self.fontSize];
            
            
        end
        
        function draw(self, window)
            % This is the class method for drawing an xText object.
            %
            % This method executes any standing object scaling or moving
            % programs, calculates draw parameters, and calls the
            % PsychToolbox Screen('FillRect',... method. This method is
            % generally called by the thisXprmnt object methods, rather
            % than by the user created experiment script/function. See
            % xprmnt.mat for more information.
            %
            % Syntax: text.draw(window)
            %
            % Input: window, the PsychToolbox window to which we would like
            % to draw the rectangle.
            
            global thisXprmnt;
            
            
            % If there is an outstanding move program, execute the calcMove
            % method. This is specified in the xObject class.
            if max(self.moveDat)
                self.calcMove
            end
            
            % Likewise, if there is an outstanding color change program.
            if iscell(self.colorDat)
                self.calcColor
            end
            
            % If there is a standing scaling program, calculate the new
            % scale of the rectangle.
            if max(self.scaleDat)
                
                % We calculate how far through the scale interval we've
                % progressed. A value of 0 means we've just begun, a value
                % of 1 or greater means that the interval is over.
                scaleProg = (GetSecs - self.scaleDat(1))/self.scaleDat(2);
                
                % If the interval is over...
                if scaleProg >= 1
                    
                    % then set the width and heigh to the final width and
                    % height specified by the scaling program,
                    self.fontSize = self.scaleDat(3);
                    
                    % and note that we've completed the scaling program.
                    self.scaleDat = false;
                    
                % If we're still within the rescaling interval...
                else
                    
                    % then set the width and height to the appropriate
                    % weighted sum of the old and final widths and heights.
                    self.fontSize = scaleProg*self.scaleDat(3) +...
                        (1 - scaleProg)*self.scaleDat(4);

                end
                
                
            end
            
            % We convert the two visual degree valued parameters into their
            % pixel equivalents.
            [pixX pixY] = thisXprmnt.deg2pix([self.x, self.y]);
            
            strWidth = length(self.string)*self.fontSize*(2/3);
            
            
            Screen('TextMode',  window, 'TextFill');
            Screen('TextSize',  window, floor(self.fontSize));
            Screen('TextStyle', window, self.bold +...
                self.italic*2 + self.underline*4);
            Screen('TextFont', window, self.font);
            
            Screen('DrawText', window, self.string,...
                pixX - strWidth/2,...
                pixY - self.fontSize/2,...
                self.color);
            
            
        end
        
        function freeze(self)
            % A class method to terminate all standing animation programs.
            %
            % This method is generally called by thisXprmnt.animate method,
            % to halt animation in cases when, for example, the user has
            % pressed a response key and we wish for all objects to freeze
            % in place.
            %
            % Syntax: rect.freeze
            
            self.scaleDat = false;
            self.moveDat = false;
        end
        
    end
    
    
    
end

