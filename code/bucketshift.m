function shift = bucketshift (bucketYear)
% Computes the shift (in bps) of every of the 23 elements of the forward rates
% curve.
%
%INPUT:
% bucketYear: can be 2,4,7 or 10. 
%
%OUTPUTS:
% shift: vector of 23 elements giving the shift for every element.

shift = zeros(23,1);

if bucketYear == 2
    shift(1:10) = 1;
    shift(11) = 0.5;
elseif bucketYear == 4
    shift(11) = 0.5;
    shift(12) = 1;
    shift(13) = 2/3;
    shift(14) = 1/3;
elseif bucketYear == 7
    shift([13,17]) = 1/3;
    shift([14,16]) = 2/3;
    shift(15) = 1;
elseif bucketYear == 10
    shift(16) = 1/3;
    shift(17) = 2/3;
    shift(18) = 1;
    shift(19) = 0.5;
end
end