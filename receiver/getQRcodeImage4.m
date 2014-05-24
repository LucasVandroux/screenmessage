function QRcode_img = getQRcodeImage4(frame, finderPattern_pos, cst_marge)
%Return the QRcode image cropped
%   Input: frame = a black and white image
%          finderPattern_pos = the position of the 3 finder pattern in the
%                              frame
%          cst_marge = the marge from the center of the finder pattern to
%                      crop the QRcode.
%   Output: QRcode_img = QRcode cropped

    % Compute the margin for each FP
    marge_1 = ceil(finderPattern_pos(1, 3) * cst_marge);
    marge_2 = ceil(finderPattern_pos(2, 3) * cst_marge);
    marge_3 = ceil(finderPattern_pos(3, 3) * cst_marge);
    marge_4 = ceil(finderPattern_pos(4, 3) * cst_marge);

    % Store the position of the corner according to the position of the FPs
    X = [(finderPattern_pos(1,1) - marge_1) ; (finderPattern_pos(2,1) + marge_2) ; (finderPattern_pos(4,1) + marge_4) ; (finderPattern_pos(3,1) - marge_3)]; 
    Y = [(finderPattern_pos(1,2) - marge_1) ; (finderPattern_pos(2,2) - marge_2) ; (finderPattern_pos(4,2) + marge_4) ; (finderPattern_pos(3,2) + marge_3)];
    
    % Choose the size of the cropped area
    x=[1;400;400;1];
    y=[1;1;400;400];

    % Create the matrix of the transformation
    M=[ X(1),Y(1),1,0,0,0,-1*X(1)*x(1),-1*Y(1)*x(1);
        0,0,0,X(1),Y(1),1,-1*X(1)*y(1),-1*Y(1)*y(1);
        X(2),Y(2),1,0,0,0,-1*X(2)*x(2),-1*Y(2)*x(2);
        0,0,0,X(2),Y(2),1,-1*X(2)*y(2),-1*Y(2)*y(2);
        X(3),Y(3),1,0,0,0,-1*X(3)*x(3),-1*Y(3)*x(3);
        0,0,0,X(3),Y(3),1,-1*X(3)*y(3),-1*Y(3)*y(3);
        X(4),Y(4),1,0,0,0,-1*X(4)*x(4),-1*Y(4)*x(4);
        0,0,0,X(4),Y(4),1,-1*X(4)*y(4),-1*Y(4)*y(4)];

    % Create the basis
    v=[x(1);y(1);x(2);y(2);x(3);y(3);x(4);y(4)];
    
    % Resolve the system
    u=M\v;

    U=reshape([u;1],3,3)';

    w=U*[X';Y';ones(1,4)];
    w=w./(ones(3,1)*w(3,:));

    % Make the transformation
    T=maketform('projective',U');

    % Apply the transformation
    QRcode_img =imtransform(frame,T,'XData',[1 400],'YData',[1 400]);                    
end
