function discountCurve = bootstrap(datesSet, ratesSet)
% Bootstrap interpolation
%
% INPUTS:
%  datesSet: settlement date and expiry dates of depos, settlement and expiry dates of futures,expiry dates of swaps
%  ratesSet: bid and ask rates of depos futures and swaps
% 
% OUTPUTS:
%  dates: expiry dates matched with DFs
%  discounts: DFs bootstrapped

M = 24;
discountCurve.dates = zeros(M,1);
discountCurve.DF = zeros(M,1);

%% Initial value of the bootstrap: B(t0,t0) = 1.
discountCurve.dates(1) = datesSet.settlement;
discountCurve.DF(1) = 1;


%% 1st section: Depos

% We compute the first 9 values of the discounts using depos:
rate_depos = ratesSet.depos; %(1:end-1);
Delta_depos = yearfrac(datesSet.settlement,datesSet.depos,2);
discountCurve.DF(2:10) = 1./( 1 + Delta_depos .*rate_depos);
discountCurve.dates(2:10) = datesSet.depos; %(1:end-1);


%% 2nd section: swaps.

% We compute all the other elements of the discounts using swaps:
rate_swaps = ratesSet.swaps;
Delta_swaps = yearfrac([datesSet.settlement; datesSet.swaps(1:end-1)],datesSet.swaps, 6);

% d_swap = datesSet.swaps(1);
% idx = find(dates >= d_swap,1);
% if(d_swap ~= dates(idx))
%     %interpolazione per trovare il primo swap
%     d1 = dates(idx-1); %data più piccola
%     d2 = dates(idx); %data più grande
%     B1  = discounts(idx-1);
%     B2 = discounts(idx);
%     zrates = zeroRates([datesSet.settlement,d1,d2], [B1,B2]);
%     y_idx =  interp1([d1,d2],zrates,d_swap);
%     Delta = yearfrac(datesSet.settlement,d_swap,3);
%     B_idx = exp(-(Delta* y_idx)); %B da inserire nell'indice
% end

BPV = 0;
B_swap = [discountCurve.DF(10); zeros(length(datesSet.swaps)-1,1)];
for i = 2:length(rate_swaps)
    BPV = BPV + Delta_swaps(i-1)*B_swap(i-1);
    B_swap(i) = (1 - rate_swaps(i)*BPV)./ (1+Delta_swaps(i)*rate_swaps(i));
end
    
discountCurve.DF(11:end) = B_swap(2:end);
discountCurve.dates(11:end) = datesSet.swaps(2:end);
    
end




