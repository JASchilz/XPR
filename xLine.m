classdef xLine < xObject & handle
    %xLine An animated line rendering class in the XPR toolbox.
    %   This class provides an animated line for the XPR toolbox.
    
    properties
        % We define here all properties that the object class should have
        % in addition to those specified by the xObject parent class.
        % Default values are specified in the properties (Constant)
        % section.

        p1; % Location of the first end-point of the line, in visual degrees.
        p2; % Location of the second end-point of the line, in visual degrees.
        
        penWidth; % The width of the line, in pixels.

    end
    
    properties (Constant)
        % We give each class a constant input parser object. So that we can
        % achieve this with one function call, we've created a static
        % method in the xObject parent class called makeInputParser. We
        % specify default values and validity check function handles for
        % each of the user-specified object properties. For syntax
        % questions, see help xObject.makeInputParser
        
        p = xObject.makeInputParser(...
            { 'p1', [-1 0], @isnumeric;...
            'p2', [1 0], @isnumeric;...
            'penWidth', 3, @isnumeric;...
            'color', [255, 255, 255], @isnumeric});
            
    end
    
    methods
        
        function self = xLine(varargin)
            % The constructor for xRect.
            %
            % Syntax: rect = xRect('property', val, 'property', val...
            %
            % Properties available: x, y, w, h, color. See xRect.m and
            % xObject.m for more information.
            
            
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
            self.p1 = in.p1;
            self.p2 = in.p2;
            
            % Likewise for width and height.
            self.penWidth = in.penWidth;
            
            
            
        end
        
        
        function draw(self, window)
            % This is the class method for drawing an xRect object.
            %
            % This method executes any standing object scaling or moving
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
            
            % Likewise, if there is an outstanding color change program.
            if iscell(self.colorDat)
                self.calcColor
            end
            
            % We convert the four visual degree valued parameters into
            % their pixel equivalents.
            [pixP1(1), pixP1(2)] = thisXprmnt.deg2pix(self.p1 + [self.x self.y]);
            [pixP2(1), pixP2(2)] = thisXprmnt.deg2pix(self.p2 + [self.x self.y]);
            
            
            Screen('DrawLine', window,...
                self.color,...
                pixP1(1), pixP1(2),...
                pixP2(1), pixP2(2),...
                self.penWidth);
            
            
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
            
            self.colorDat = false;
            self.moveDat = false;
        end
        
    end
    
    
    
end

