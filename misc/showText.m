function showText(text, duration, kbcontrolled, justifyLastLine, img)
%Shows text (must be a cell array). Each entry of text is shown on a subsequent line.

global thisXprmnt;

winPtr = thisXprmnt.window;
screenRect = thisXprmnt.screenRect;


fontSize = 30;
bold = true;
italic = false;
underline = false;
font = 'Courier';
defaultCol = [255, 255, 180];

Screen('TextMode',  winPtr, 'TextFill');
Screen('TextSize',  winPtr, fontSize);
Screen('TextStyle', winPtr, bold + italic*2 + underline*4);
Screen('TextFont', winPtr, font);

yStep = fontSize;

Screen('FillRect', winPtr, [0, 0, 0])

if ~exist('justifyLastLine', 'var');
    justifyLastLine = false;
end

if exist('img', 'var')
    imgLen = size(img, 1);
    imgWidth = size(img, 2);
    
    destTop = max(0, screenRect(4)*1/2 - imgLen);
    destLeft = screenRect(3)/2 - imgWidth/2;
    
    tex=Screen('MakeTexture', winPtr, img);
    
    Screen('DrawTexture', winPtr, tex, [],...
        [destLeft, destTop, destLeft + imgWidth, destTop + imgLen]);
    
    sY = destTop + imgLen + yStep;
    
else
    sY = screenRect(4)-800; % might want to adjust this
end

lastCol = defaultCol;


for j = 1:length(text)
    clear str;
    
    string = text{j};

    escs = strfind(string, '\c');
    escs = reshape(escs, 2, length(escs)/2)';

    strLen = length(string) - sum(escs(:,2) - escs(:,1) + 2);
    if strLen > 0
        strWidth = Screen('TextBounds', winPtr, string);
        strWidth = strWidth(3);
    else
        strWidth = 0;
    end
    
    sX = screenRect(3)/2 - strWidth/2;
    
    
    if ~isempty(escs)

        for i = 1: size(escs, 1) + 1
            if i == 1
                str{i} = string(1:escs(i, 1) - 1);
            elseif i == size(escs, 1) + 1
                str{i} = string(escs(i-1, 2) + 2:end);
            else
                str{i} = string(escs(i-1, 2) + 2: escs(i, 1) - 1);
            end

            if i == 1
                color{i} = lastCol;
            else
                color{i} = string(escs(i-1, 1) + 2: escs(i-1, 2) - 1);
                if strcmp(color{i}, '[default]')
                    color{i} = defaultCol;
                else
                    color{i} = sscanf(color{i}(2:end-1), '%f')';
                end
                lastCol = color{i};
            end
        end
    else
        str{1} = string;
        color{1} = lastCol;
    end

    
    if justifyLastLine && j == length(text)
        sY = screenRect(4) - yStep*3/2;
    end

    for i = 1:length(str)
        % Placing a color sequence at the beginning of a string will
        % produce an empty substring str{i}, which we do not want to draw.
        if ~isempty(str{i})
            sX = Screen('DrawText', winPtr, str{i}, sX, sY, color{i});
        end
    end
    
    sY = sY+yStep;
end


Screen('Flip', winPtr);

if( nargin >= 2 )
    WaitSecs(duration);
else
    WaitSecs(.4);
end

if( nargin < 3 || kbcontrolled)
    KbWait();
end