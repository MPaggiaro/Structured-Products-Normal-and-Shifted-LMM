function price = swapformula(t0, dates, discounts,  notional, swap_rate, flagPayer)
% formula for pricing vanilla iR swap
% 
% INPUT
% t0 = evaluation date 
% dates = payment dates used for both legs 
% discounts = discount factors used for pricing 
% notional = notional of the swap 
% swap_rate = swap rate 
% flagPayer = 'r' receiver otherwise payer swap is assumed
%
% OUTPUT
% price = price of the swap 
yf = yearfrac([t0; dates(1:end-1)],dates, 2);
price = 1 - discounts(end) - swap_rate * dot(discounts,yf);

price = price * notional;
if flagPayer == 'r'
	price = -price;
end
    
end
