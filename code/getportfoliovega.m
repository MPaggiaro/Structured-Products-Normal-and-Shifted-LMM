function vega = getportfoliovega (discountCurve, portfolioData, fixingData, spotVolData, bucketYear, flagModel)
% compute the portfolio vega 
% discountCurve = discount curve used for the portfolio 
% portfolioData = struct contaning the relevant data for the instruments in the portfolio 
% fixingData = data for the fixing of the libor 
% spotVolData = struct contanining the selected model type (normal or shifted ) and the relative volatility surface 
% bucketYear = bucket to shift the volatility on 
% flagModel = 0 for normal and 1 for shifted black 

% OUTPUT
% vega = sensitivity of the portfolio value to a 1bp shift in the volatilty surface in the specified bucket
% Shift in the volatility:
shiftSpotVol = volatilityshift (spotVolData, bucketYear);

NPV = npvportfolio (discountCurve, portfolioData, fixingData, spotVolData);
NPVshift = npvportfolio (discountCurve, portfolioData, fixingData, shiftSpotVol);

vega = NPVshift - NPV;

end
