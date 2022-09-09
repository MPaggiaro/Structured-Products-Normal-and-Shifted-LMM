function price = capletprice(B, L, T_0,T_1,T_2, vol, strike, flagModel, flagCF)
% Computes caplet price with normal or shifted LMM.
% INPUTS:
%B: discount factor B(T_0,T_2)
%L: Libor forward rate L(T_0;T_1,T_2).
%T_0: starting date
%T_1: fixing date
%T_2: ending date
%vol: volatility (should be flat or spot)
%strike: strike on the index
%flag: 0 if normal Libor market model
%      1 if shifted black Libor market model
%
% OUTPUTS:
%caplet: price of the caplet / floorlet

act360 = 2;
dt = yearfrac(T_1,T_2, act360);
% time to fixing TTF:
TTF = yearfrac(T_0, T_1, act360);
switch flagModel
    case 'black'
        d1 = 1./ (vol .* sqrt(TTF)) .* log(L./strike) + 0.5*vol.*sqrt(TTF);
        d2 = d1 - vol.*sqrt(TTF);
        caplet = B.*dt.*(L.*normcdf(d1) - strike.*normcdf(d2) );
        floorlet = B.*dt.*(strike.*normcdf(-d2) - L.*normcdf(-d1));
    
    case 'normal' % case normal LMM:
        d = (L - strike)./(vol.*sqrt(TTF));
        caplet = B.*dt.*((L - strike).*normcdf(d) + vol.*sqrt(TTF).*normpdf(d)); 
        floorlet = B.*dt.*((strike - L).*normcdf(-d) + vol.*sqrt(TTF).*normpdf(d));

    case 'shifted'% case shifted LMM with alpha = 3%
        alpha = 0.03;
        d1 = 1./ (vol .* sqrt(TTF)) .* log((L+alpha)./(strike+alpha)) + 0.5*vol.*sqrt(TTF);
        d2 = d1 - vol.*sqrt(TTF);
        caplet = B.*dt.*((L+alpha).*normcdf(d1) - (strike+alpha).*normcdf(d2) );
        floorlet = B.*dt.*((strike+alpha).*normcdf(-d2) - (L+alpha).*normcdf(-d1));
end

switch flagCF
    case 'c'
        price = caplet;
    case 'f'
        price = floorlet;
end
end
