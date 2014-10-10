classdef xImg < xObject & handle
    %xPolygon Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        texture = [];
        
        mode = 'center';
        
        width = false;
        height = false;
        
        image = [];
        alpha = 1;
        
        imagePath = '';
        
        alphaDat = false;
    end
    
    properties (Constant)
        
        p = xObject.makeInputParser(...
            { 'x', 0, @isnumeric;...
            'y', 0, @isnumeric;...
            'alpha', 1, @isnumeric;...
            'mode', 'center', @ischar;...
            'imagePath', '', @ischar;...
            'image', [], @isnumeric;...
            'interval', 0, @isnumeric});
    end
    
    methods
        
        function self = xImg(varargin)
            
            global thisXprmnt;
            
            self.p.parse(varargin{:})
            in = self.p.Results;
            
            self.x = in.x;
            self.y = in.y;
            
            self.alpha = in.alpha;
            
            self.imagePath = in.imagePath;
            
            [self.image map alpha] = imread(in.imagePath);
            self.image(:,:,4) = alpha(:,:);
            
            self.mode = in.mode;
            
            self.texture = Screen('MakeTexture', thisXprmnt.window, self.image);
            self.width = size(self.image, 2);
            self.height = size(self.image, 1);
           
        end
        
        
        function changeAlpha(self, varargin)
            
            self.p.parse(varargin{:});
            in = self.p.Results;
            
            self.alphaDat = {GetSecs in.interval in.alpha self.alpha};
            
            
        end
        
        function draw(self, window)
            
            global thisXprmnt;
            
            % Calculate retranslating
            if max(self.moveDat)
                self.calcMove
                self.moveDat
            end
            
            % Calculate realphaing
            if iscell(self.alphaDat)
                
                alphaProg = (GetSecs - self.alphaDat{1})/self.alphaDat{2};
                
                if alphaProg >= 1

                    self.alpha = self.alphaDat{3};
                    self.alphaDat = false;

                else

                    self.alpha = alphaProg*self.alphaDat{3} +...
                        (1 - alphaProg)*self.alphaDat{4};

                end
                
            end
            
            [pixX pixY] = thisXprmnt.deg2pix([self.x, self.y]);
            
            if strcmp(self.mode, 'center')
                destRect = [pixX - self.width/2, pixY - self.height/2,...
                    pixX + self.width/2, pixY + self.height/2];
            end %% FINISH THIS
            
            % Draw
            Screen('DrawTexture', window, self.texture,  [],  destRect,...
                [], [], self.alpha);
            
            
        end
        
        function freeze(self)
%             self.scaleDat = false;
            self.moveDat = false;
        end
    end
    
end

