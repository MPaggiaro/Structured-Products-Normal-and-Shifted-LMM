function price = capfloorprice (B, libor_3m_t0, t0,setDate, paymentDates,...
    notionals, vol, strike, flagModel, flagCF)
% 
% Computes Cap or Floor price, giving a notional varying each year.
% 
% INPUT
% t0 = evaluation date
% B = discount curve for maturity T with reference at the evaluation date t0 
% libor_3m_t0 = the last fixing of the libor occourred before the evaluation date 
% setDate = settlement date for the cap 
% paymentDates = vector of payment dates for the cap 
% notionals = set of ammortizing notional, each associated with to the respective payment date 
% vol = volatility term structure associated withe the strike of the cap 
% strike = strike for the cap 
% flagModel = 0 for the normal model, 1 for the shifted black 
% flagCF = 0 for cap 1 for floor
% 
% OUTPUT 
% price = the price computed for the cap/floor

caplets = zeros(size(notionals));

act360 = 2;
dt = yearfrac([t0; paymentDates(1:end-1)],paymentDates, act360);
B_fwd = B(2:end)./B(1:end-1);
L = (1./B_fwd - 1)./dt(2:end);


% first caplet is known. We discount it to obtain its price at set date:
caplets(1) = B(1)*dt(1)*max(libor_3m_t0 - strike, 0);

% from the second until the last caplet we have stochastic payoffs. Hence
% we compute their prices with the selected model.
caplets(2:end) = capletprice(B(2:end),L,setDate,paymentDates(1:end-1),...
    paymentDates(2:end), vol, strike,flagModel,flagCF);

price = dot(notionals, caplets);

end
