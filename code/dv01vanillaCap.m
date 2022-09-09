function [price,dv01] = dv01vanillaCap (setDate, paymentDates, B, B_shift,...
    notional, vol, strike, flagModel, flagCF)

price = vanillaCapFloorPrice(setDate, paymentDates, B, notional, vol, strike, flagModel, flagCF);
shiftedPrice = vanillaCapFloorPrice(setDate, paymentDates, B_shift, notional, vol, strike, flagModel, flagCF);
dv01 = shiftedPrice - price;

end 