classdef xSet < handle
    %xSet Class for object container
    %   This class defines a container class for objects. Use of this class
    %   is optional, and specialized. It is for use with objects that you
    %   wish to group into single objects for ease of handling.
    %
    %   
    
    properties (SetAccess = protected)
        x = 0;
        y = 0;
        
        membs = {};
        
        pixX = 0;
        pixY = 0;
        
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
            'membs', {}, @iscell});
    end
    
    methods
        
        function self = xSet(varargin)
            % The constructor for xSet.
            %
            % Syntax: rect = xRect('property', val, 'property', val...
            %
            % Properties available: x, y, w, h, color. See xRect.m and
            % xObject.m for more information.
            
            global thisXprmnt;
            
            % We parse the input through the class input parser p.
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            % We set x and y to those values specified by the user.
            self.x = in.x;
            self.y = in.y;
            
            % We convert the two visual degree valued parameters into their
            % pixel equivalents.
            [self.pixX self.pixY] = thisXprmnt.deg2pix([in.x, in.y]);
            
            self.membs = in.membs;
            
            
        end
        
        function addMemb(self, newMemb)
            % Adds an item to the set.
            %
            % Input
            % newMemb: the item to be added
            
            self.membs{end+1} = newMemb;
        end
        
        function removeMemb(self, memb)
            % Removes an item from the set.
            %
            % Input
            % memb: the member to be removed
            
            for i = length(self.membs):-1:1

                if self.membs{i} == memb

                    self.membs = ...
                        {self.membs{[1:i-1, i+1:end]}};
                end
            end
            
        end
        
        function setVis(self, vis)
            % Sets all of the set objects to be either visible or
            % invisible.
            %
            % Input
            % vis: boolean value, true for visible, false for invisible.
            
            for i = 1:length(self.membs)
                self.membs{i}.setVis(vis);
            end
            
        end
        
        function move(self, varargin)
            
            
            p = inputParser;
            
            p.addParamValue('mode', 'abs', @ischar);
            p.addParamValue('x', 1, @isnumeric);
            p.addParamValue('y', 1, @isnumeric);
            p.addParamValue('interval', 0, @isnumeric);
            
            p.parse(varargin{:});
            in = p.Results;
            
            
            
            for i = 1:length(self.membs)
                self.membs{i}.move('mode', in.mode,...
                    'x', in.x, 'y', in.y, 'interval', in.interval);
            end
            
        end
        

        

        
        
    end
    
end

