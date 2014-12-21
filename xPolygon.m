classdef xPolygon < xObject & handle
    %xPolygon An animated polygon rendering class in the XPR toolbox.
    
    properties
        pointList = [];
        
        pixPointList = [];
        
        scaleDat = false;
    end
    
    properties (Constant)
        
        p = xObject.makeInputParser(...
            { 'x', 0, @isnumeric;...
            'y', 0, @isnumeric;...
            'pointList', [], @isnumeric;...
            'color', [255, 255, 255], @isnumeric});
    end
    
    methods
        
        function self = xPolygon(varargin)
            
            global thisXprmnt;
            
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            self.pointList = in.pointList;
            
            self.x = in.x;
            self.y = in.y;
            
            if length(in.color) == 4
                self.color = in.color;
            else
                self.color = [in.color, 255];
            end
            
            [self.pixX self.pixY] = thisXprmnt.deg2pix([in.x, in.y]);
            
            self.pixPointList = in.pointList*thisXprmnt.ppd;
            self.pixPointList(:,2) = -self.pixPointList(:,2);
                        
        end
        
        function setPoints(self, varargin)
            
            global thisXprmnt;
            
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            self.pointList = in.pointList;
            
            self.pixPointList = in.pointList*thisXprmnt.ppd;
            self.pixPointList(:,2) = -self.pixPointList(:,2);
            
            
        end
        
        function scale(self, varargin)
            
            thisP = self.p;
            
            thisP.addParamValue('scale', 1, @isnumeric);
            thisP.addParamValue('interval', 0, @isnumeric);
            
            thisP.parse(varargin{:});
            in = thisP.Results;
            
            finalPList = self.pointList*in.scale;
            
            self.scaleDat = {GetSecs in.interval finalPList self.pointList};
            
            
        end
        
        function draw(self, window)
            
            global thisXprmnt;
            
            % Calculate retranslating
            if max(self.moveDat)
                self.calcMove
                self.moveDat
            end
            
            % Calculate color change
            if iscell(self.colorDat)
                self.calcColor
            end
            
            % Calculate rescaling
            if iscell(self.scaleDat)
                
                scaleProg = (GetSecs - self.scaleDat{1})/self.scaleDat{2};
                
                if scaleProg >= 1

                    self.pointList = self.scaleDat{3};
                    self.scaleDat = false;

                else

                    self.pointList = scaleProg*self.scaleDat{3} +...
                        (1 - scaleProg)*self.scaleDat{4};

                end
                
                self.pixPointList = self.pointList*thisXprmnt.ppd;
                self.pixPointList(:,2) = -self.pixPointList(:,2);
                
            end
            
            [pixX pixY] = thisXprmnt.deg2pix([self.x, self.y]);
            
            self.pixPointList = self.pointList*thisXprmnt.ppd;
            self.pixPointList(:,2) = -self.pixPointList(:,2);
            
            % Translate the points to their proper position
            drawPointList = [ self.pixPointList(:,1) + pixX,... %x's
                self.pixPointList(:,2) + pixY,]; % y's
            
            % Draw
            if size(drawPointList, 1) >= 3
                Screen('FillPoly', window,...
                    self.color,...
                    drawPointList);
            end
            
            
            
        end
        
        function freeze(self)
            self.scaleDat = false;
            self.moveDat = false;
        end
    end
    
end

