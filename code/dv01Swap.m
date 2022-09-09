function dv01 = dv01Swap(setDate, paymentDates, B, B_shift,notional, swapRate, flagPayer)
% 
% compute the dv01 for a swap 
% 
% INPUT
% setDate = settlement date 
% paymentDates = payment Dates for the swap contract 
% B = discount curve 
% B_shift = discount curve shifted on the corresponding bucket of choice
% notional = notional for the vanilla IRS 
% swapRate = swap rate 
% flagPayer = 'r' for receiver otherwise payer swap is assumed 
%
% OUTPUT
% dv01 = dv01 for the swap contract 
price = swapformula(setDate, paymentDates, B, notional, swapRate, flagPayer); 
shiftedPrice = swapformula(setDate, paymentDates, B_shift, notional, swapRate, flagPayer);
dv01 = shiftedPrice - price;                 

end
