classdef xObject < handle
    %xObject An abstract parent class in the XPR toolbox.
    %   This abstract parent class provides all common methods
    %   and attributes for visual screen objects within the XPR
    %   toolbox.
    
    properties
        
        x = 0;              % Horizontal location of the object in visual degrees.
        y = 0;              % Vertical location of the object in visual degrees.
        color = [];         
        
        pixX = 0;           % Horizontal location of the object in pixels.
        pixY = 0;           % Vertical location of the object in pixels.
        
                            % Note that location is generally set by the user
                            % in terms of visual degrees, and then interpretted and
                            % translatted into terms of pixels.
    end
        
    properties (SetAccess = protected)
        
        moveDat = false;
        colorDat = false;
    end
    
    methods(Static)
        
        function p = makeInputParser(argArray)
            % A simple method to make a complete input parser from a single
            % argument. We want to be able to do this so we can give each
            % class a static input parser of its own, which requires(?) a
            % single line of assignment. All parameters added by this
            % method will be ParamValues, which works fine for our
            % purposes.
            %
            % Input: A cell array with rows of argument name (string),
            % default value, and verification function. For example:
            % 
            % p = xObject.makeInputParser(...
            % { 'x', 0, @isnumeric;...
            % 'y', 0, @isnumeric;...
            % 'w', 1, @isnumeric;...
            % 'h', 1, @isnumeric});
            
            p = inputParser;
            
            for i=1:size(argArray, 1)
                p.addParamValue(argArray{i,:})
            end
            
        end
                
    end
    
    methods
        
        function setVis(self, vis)
            % Sets the object to be either visible or invisible. The order
            % in which objects are added to thisXprmnt.visObjs, via this
            % function, determines their draw order. By default, all newly
            % created items are invisible.
            %
            % Input
            % vis: boolean value, true for visible, false for invisible.
            global thisXprmnt;
            
            if vis
                
                thisXprmnt.visObjs = {thisXprmnt.visObjs{:}, self};
                    
            else
                
                for i = length(thisXprmnt.visObjs):-1:1
                    
                    if thisXprmnt.visObjs{i} == self
                        
                        thisXprmnt.visObjs = ...
                            {thisXprmnt.visObjs{[1:i-1, i+1:end]}};
                    end
                end
                
            end
            
        end
        
        function move(self, varargin)
            
            p = inputParser;
            
            p.addParamValue('mode', 'abs', @ischar);
            p.addParamValue('x', 'default', @isnumeric);
            p.addParamValue('y', 'default', @isnumeric);
            p.addParamValue('interval', 0, @isnumeric);
            
            p.parse(varargin{:});
            in = p.Results;
            
            if strcmp(in.x, 'default')
                if strcmp(in.mode, 'abs')
                    in.x = self.x;
                else
                    in.x = 0;
                end
            end
            
            if strcmp(in.y, 'default')
                if strcmp(in.mode, 'abs')
                    in.y = self.y;
                else
                    in.y = 0;
                end
            end
            
            if strcmp(in.mode, 'rel') || strcmp(in.mode, 'relative')
                
                finalX = self.x + in.x;
                finalY = self.y + in.y;
                                
            else
                
                finalX = in.x;
                finalY = in.y;
                
            end
            
            self.moveDat = [GetSecs in.interval finalX finalY self.x self.y];
            
        end
        
        function changeColor(self, varargin)
            
            p = inputParser;
            
            p.addParamValue('color', self.color, @isnumeric);
            p.addParamValue('interval', 0, @isnumeric);
            
            p.parse(varargin{:});
            in = p.Results;
            
            if length(in.color) == 3
                in.color = [in.color, 255];
            end
            
            if length(self.color) == 3
                self.color = [self.color, 255];
            end
            
            
            self.colorDat = {GetSecs in.interval in.color self.color};
            
        end
        
        function calcMove(self)
            
            global thisXprmnt;
            
            moveProg = (GetSecs - self.moveDat(1))/self.moveDat(2);
            
            if moveProg >= 1
                
                self.x = self.moveDat(3);
                self.y = self.moveDat(4);
                
                self.moveDat = false;
                
            else
                
                self.x = moveProg*self.moveDat(3) +...
                    (1 - moveProg)*self.moveDat(5);
                
                self.y = moveProg*self.moveDat(4) +...
                    (1 - moveProg)*self.moveDat(6);
                
            end
            
            [self.pixX self.pixY] = thisXprmnt.deg2pix([self.x, self.y]);
            
        end
        
        function calcColor(self)
            
            colorProg = (GetSecs - self.colorDat{1})/self.colorDat{2};
            
            if colorProg >= 1
                
                self.color = self.colorDat{3};
                
                self.colorDat = false;
                
            else
                
                self.color = colorProg*self.colorDat{3} +...
                    (1 - colorProg)*self.colorDat{4};

                
            end
            
            
        end
    end
    
end

