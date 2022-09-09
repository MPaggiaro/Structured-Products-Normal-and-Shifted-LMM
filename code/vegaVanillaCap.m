function vega = vegaVanillaCap(B, setDate, paymentDates, notional, vol, shiftedVol, strike, flagModel, flagCF)
% 
% compute the vega of the cap 
%

% INPUT
% B = discount curve wrt the value date 
% t0 = valuation date 
% libor_3m_t0 = last libor fixing before t0
% setDate = settlement date for the swap 
% paymentDates = dates for the payments 
% notionals = amortized notionals for the cap contract 
% vol = volatility 
% flagModel = 0 normal libor mm , 1 shifted black libor mm
% flagCF = 'c' to price a cap and 'f' to price a floor 
% 
% OUTPUT
% vega = price of the vanilla cap/floor 
% 
vega = vanillaCapFloorPrice(setDate, paymentDates, B, notional, shiftedVol, strike, flagModel, flagCF) ... 
    - vanillaCapFloorPrice(setDate, paymentDates, B, notional, vol, strike, flagModel, flagCF);


end
