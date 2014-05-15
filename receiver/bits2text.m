function text=bits2text(estim_bits)

estim_bits=estim_bits(:); % turn the bit sequence into a column vector

% remove the tail, if necessary; length should be multiple of 8  bits. 
estim_bits=estim_bits(1:numel(estim_bits)-mod(numel(estim_bits),8));

% reshape into an nx8 matrix and convert into a text of n characters. 
text=char(bin2dec(reshape(estim_bits, 8, [])'))';
disp(text)