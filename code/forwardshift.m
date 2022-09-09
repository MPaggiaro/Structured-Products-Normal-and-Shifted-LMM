function shiftedDiscountCurve = forwardshift (discountCurve, bucketYear)
% Computes the shifted discount curve after a shift in a given bucket.
%
%INPUT:
% discountCurve: struct of the original discount curve.
% bucketYear: can be 2,4,7 or 10. 
%
%OUTPUTS:
% shiftedDiscountCurve: struct of the shifted discount curve.

%%
epsilon = 1e-4; %we make a shift of 1bp.

flagMethod = 0;
%% 

shiftedDiscountCurve.dates = discountCurve.dates;

% day count:
act360 = 2;

B_fwd = discountCurve.DF(2:end)./discountCurve.DF(1:end-1);
delta = yearfrac(discountCurve.dates(1:end-1),discountCurve.dates(2:end),act360);
L_fwd = (1./B_fwd -1)./delta;
shift = bucketshift (bucketYear);

% First approach: shift on the forward rate:
if flagMethod==0
    L_fwd_shifted = L_fwd + epsilon*shift;
    B_fwd_shifted = 1./(1+delta.*L_fwd_shifted);

    shiftedDiscountCurve.DF = zeros(size(discountCurve.DF));

    shiftedDiscountCurve.DF(1) = discountCurve.DF(1);
    for i = 2:length(discountCurve.DF)
        shiftedDiscountCurve.DF(i) = shiftedDiscountCurve.DF(i-1)*B_fwd_shifted(i-1);
    end
else
    % Second approach: shift on the zero curve.
    zeroRates = zerorates(discountCurve.dates, discountCurve.DF);
    shiftedZeroRates = zeroRates + epsilon*shift;
    shiftedDiscountCurve.DF = zeros(size(discountCurve.DF));
    shiftedDiscountCurve.DF(1) = discountCurve.DF(1);
    shiftedDiscountCurve.DF(2:end) = ratestodiscounts(discountCurve.dates(1), discountCurve.dates(2:end), shiftedZeroRates);
end

%%
end