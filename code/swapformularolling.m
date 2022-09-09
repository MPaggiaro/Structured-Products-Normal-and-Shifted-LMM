function [price] = swapformularolling(t0, libor_0,notionals, dates, discounts, swap_rate, flagPayer)

% price a swap contract alreay started

% INPUT 

% t0 = evaluation date 
% notionals = array of notionals n(i) = Notional at time T(i)
% dates = payment dates for both the fixed and the floating leg
% libor_0 = fixed libor from t0 to t1 
% swap_rate =  swap rate priced at valuation date t0 
% discounts = discount curve 
% flagPayer = 'r' receiver otherwise payer is assumed 
%
% OUTPUT
% price = price of the swap

%% price the swap

dates = [t0; dates];
year_frac_fix = yearfrac(dates(1:end-1),dates(2:end),6);
year_frac_float = yearfrac(dates(1),dates(2),2);

pv_float = dot(notionals(2:end), discounts(1:end-1) - discounts(2:end)) + discounts(1) * notionals(1) * libor_0 * year_frac_float;
pv_fix = dot(notionals, year_frac_fix .* discounts) * swap_rate;

if flagPayer == 'p'
    price = pv_float - pv_fix; % flag = 0 pay fixed receive floating
else
    price = pv_fix - pv_float;
end

end

