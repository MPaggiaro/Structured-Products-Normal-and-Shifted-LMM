function DV01 = getportfolioDV01 (discountCurve, portfolioData, fixingData, spotVol, bucketYear)
%
% compute the portfolio DV01 

% INPUT
% discountCurve = discount curve used for the portfolio 
% portfolioData = struct contaning the relevant data for the instruments in the portfolio 
% fixingData = data for the fixing of the libor 
% spotVol = struct contanining the selected model type (normal or shifted ) and the relative volatility surface 
% bucketYear = bucket to shift the forward curve on 
% flagModel = 0 for normal and 1 for shifted black 

% OUTPUT
% DV01 = sensitivity of the portfolio value to a 1bp shift in the forward rate curve in the specified bucket
% Shift in the volatility:
% Shift of the curve in the bucket of interest:
shiftedDiscountCurve = forwardshift (discountCurve, bucketYear);

NPV = npvportfolio (discountCurve, portfolioData, fixingData, spotVol);
NPVshift = npvportfolio (shiftedDiscountCurve, portfolioData, fixingData, spotVol);

DV01 = NPVshift - NPV;

end
