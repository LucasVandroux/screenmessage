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
    
    QRcode_img = frame(y_min:y_max, x_min:x_max);
end
