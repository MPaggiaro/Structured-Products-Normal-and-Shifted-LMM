function digitalFloorlet = digitalfloorletprice(B, L,T_0, T_1, T_2, vol, strike, slope, flagModel)
% Computes caplet price with normal or shifted LMM.
% INPUTS:
%B: discount factor B(T_0,T_2)
%L: Libor forward rate L(T_0;T_1,T_2).
%T_0: starting date
%T_1: fixing date
%T_2: ending date
%vol: volatility (should be flat or spot)
%strike: strike on the index
%flag: 0 if normal LMM
%      1 if shifted LMM
%
% OUTPUTS:
%caplet: price of the caplet

Act360 = 2;
Yf_01 = yearfrac(T_0,T_1, Act360);
Yf_12 = yearfrac(T_1,T_2, Act360);

switch flagModel
    
    case 'normal' % case normal LMM:
        d = (L - strike)./(vol.*sqrt(Yf_01));
        % Vega for the normal LMM:
        vega = normpdf(d).*sqrt(Yf_01);
        
        % Digital price (corrected with the slope):
        digitalFloorlet = B.*Yf_12.*(normcdf(-d) + vega .* slope); 

    case 'shifted'% case shifted LMM with alpha = 3%
        alpha = 0.03;
        d1 = 1./ (vol .* sqrt(Yf_01)) .* log((L+alpha)./(strike+alpha)) + 0.5*vol.*sqrt(Yf_01);
        d2 = 1./ (vol .* sqrt(Yf_01)) .* log((L+alpha)./(strike+alpha)) - 0.5*vol.*sqrt(Yf_01);
        % Vega for the shifted lognormal:
        vega = (L+alpha).*normpdf(d1).*sqrt(Yf_01);
        
        % Digital price (corrected with the slope):
        digitalFloorlet = B.*Yf_12.*(normcdf(-d2) + vega .* slope);
end
end