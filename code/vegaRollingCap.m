function vega = vegaRollingCap(B, libor_3m_t0, t0,setDate, paymentDates,notionals, vol, strike, flagModel, flagCF, bucket)
% compute the vega for the already started cap

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
% price = price of the vanilla cap/floor 

vol_shifted = volshift(vol,bucket);
vega = capfloorprice (B, libor_3m_t0, t0,setDate, paymentDates,notionals, vol_shifted, strike, flagModel, flagCF) ... 
    - capfloorprice (B, libor_3m_t0, t0,setDate, paymentDates,notionals, vol, strike, flagModel, flagCF);
end
