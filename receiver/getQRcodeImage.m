function QRcode_img = getQRcodeImage(frame, finderPattern_pos, cst_marge)
%Return the QRcode image cropped
%   Input: frame = a black and white image
%          finderPattern_pos = the position of the 3 finder pattern in the
%                              frame
%          cst_marge = the marge from the center of the finder pattern to
%                      crop the QRcode.
%   Output: QRcode_img = QRcode cropped

    unit_max = max (finderPattern_pos(:, 3));
    marge = ceil(unit_max * cst_marge);
    
    x_min = min(finderPattern_pos(:, 1)) - marge;
    x_max = max(finderPattern_pos(:, 1)) + marge;
    y_min = min(finderPattern_pos(:, 2)) - marge;
    y_max = max(finderPattern_pos(:, 2)) + marge;
    
    QRcode_img_cropped = frame(y_min:y_max, x_min:x_max);
    
    vertical_up_right_align = -(finderPattern_pos(1,2) - finderPattern_pos(2,2))/(y_min-y_max);
    horizontal_bot_left_align = -(finderPattern_pos(1,1) - finderPattern_pos(3,1))/(x_min-x_max);
    
    % Set up an input coordinate system so that the input image 
    % fills the unit square with vertices (0 0),(1 0),(1 1),(0 1).
    udata = [0 1];  vdata = [0 1];

    % Transform to a quadrilateral with vertices (-4 2),(-8 3),
    % (-3 -5),(6 3).
    tform = maketform('projective',[ 0 0;  1  0;  1  1; 0 1],...
                               [0 0; 1 vertical_up_right_align; (1 + horizontal_bot_left_align) (1 + vertical_up_right_align); horizontal_bot_left_align 1]);

    % Fill with gray and use bicubic interpolation. 
    % Make the output size the same as the input size.

     [QRcode_img,xdata,ydata] = imtransform(QRcode_img_cropped, tform, 'bicubic', ...
                               'udata', udata,...
                               'vdata', vdata,...
                               'size', size(QRcode_img_cropped),...
                               'fill', 1);
    
    % Test to compare
    % QRcode_img = [QRcode_img_cropped QRcode_img];
                          
end
