function msg = readQRcode(frame_BW, finderPatterns_pos, marge)
%Read a QRcode once it is found in a picture
%   Input: frame_BW = the frame where the QRcode is in Black and white
%          finderPattern_pos = the position of the 3 finder patterns
%          marge = marge to crop the QRcode around the finder patterns
%   Output: msg = message bit after bit

    QRcode = getQRcodeImage(frame_BW, finderPatterns_pos, marge);
    
    

    

end

function rowcol_pos = findRowColPosition (QRcode, marge, unit)
    marge_length = marge * unit;
    v_left_timing = QRcode(:,(marge_length + 2.5*unit):(marge*unit + 3.5*unit))
    for y = 1:size(QRcode, 1)
        
    end
end

function spacesBW = pixelColToSpaces(pixel_col)
%Convert the pixel column in black and white spaces using the mean of each
%lines.
%   Input: pixel_col = column of pixels lines
%   Output: spacesBW = matrice containing the best probable color of each line in the first
%                      line and the size of the space on the second.

    spacesBW = [color(pixel_col(1)) ; 1];
   
    for y=2:size(pixel_col, 1)
        if color(pixel_col(y)) == spacesBW(1, end)
            spacesBW(2, end) = spacesBW(2, end) + 1;
        else
            spacesBW = [spacesBW [color(pixel_col(y)); 1]];
        end
    end
end

function color = color(line)
%Compute the color according to the mean of the color of the line
%   Input: line = line of pixel
%   Output: color = color of the line
    color = round(mean(line));
end