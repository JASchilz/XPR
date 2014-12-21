classdef xCirc < xObject & handle
    %xCirc An animated geometric-disc rendering class in the XPR toolbox.
    %   This class provides an animated disc for the XPR toolbox.
    
    properties
        d = 0;
        
        pixD = 0;
        command = 'FillOval'
        
        penWidth = 3;
        
        scaleDat = false;
    end
    
    properties (Constant)
        
        p = xObject.makeInputParser(...
            { 'x', 0, @isnumeric;...
            'y', 0, @isnumeric;...
            'd', 1, @isnumeric;...
            'command', 'FillOval', @(x)strcmpi(x,'FillOval') | strcmpi(x,'FrameOval');...
            'penWidth', 3, @isnumeric;...
            'color', [255, 255, 255], @isnumeric});
    end
    
    methods
        
        function self = xCirc(varargin)
            
            global thisXprmnt;
            
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            self.x = in.x;
            self.y = in.y;
            
            self.d = in.d;
            
            self.color = in.color;
            
            [self.pixX self.pixY] = thisXprmnt.deg2pix([in.x, in.y]);

            self.pixD = in.d*thisXprmnt.ppd;
            
            self.command = in.command;
            self.penWidth = in.penWidth;
            
        end
        
        function scale(self, varargin)
            
            thisP = self.p;
            
            thisP.addParamValue('mode', 'abs', @ischar);
            thisP.addParamValue('scale', 1, @isnumeric);
            thisP.addParamValue('interval', 0, @isnumeric);
            
            thisP.parse(varargin{:});
            in = thisP.Results;
            
            if strcmp(in.mode, 'rel') || strcmp(in.mode, 'relative')
                
                finalD = self.d*in.scale;
                                               
            else
                
                finalD = in.scale;
                
            end
            
            self.scaleDat = [GetSecs in.interval finalD self.d];
            
            
        end
        
        function draw(self, window)
            
            global thisXprmnt;
            
            if max(self.moveDat)
                self.calcMove
            end
            
            if iscell(self.colorDat)
                self.calcColor
            end
            
            if max(self.scaleDat)
                
                scaleProg = (GetSecs - self.scaleDat(1))/self.scaleDat(2);
                
                if scaleProg >= 1

                    self.d = self.scaleDat(3);

                    self.scaleDat = false;

                else

                    self.d = scaleProg*self.scaleDat(3) +...
                        (1 - scaleProg)*self.scaleDat(4);

                end
                
                self.pixD = self.d*thisXprmnt.ppd;
                
            end
            
            % We convert the two visual degree valued parameters into their
            % pixel equivalents.
            [pixX pixY] = thisXprmnt.deg2pix([self.x, self.y]);
            
            if strcmp(self.command, 'FillOval')
                Screen('FillOval', window,...
                    self.color,... %color
                    [pixX - self.pixD/2,  pixY - self.pixD/2,...
                    pixX+self.pixD/2,  pixY+self.pixD/2] );
            else
                Screen('FrameOval', window,...
                    self.color,... %color
                    [pixX - self.pixD/2,  pixY - self.pixD/2,...
                    pixX+self.pixD/2,  pixY+self.pixD/2],...
                    self.penWidth);
            end
            
            
        end
        
        function freeze(self)
            self.scaleDat = false;
            self.moveDat = false;
        end
    end
    
end

