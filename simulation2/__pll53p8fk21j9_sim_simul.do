use __pll53p8fk21j9_sim_dta.dta, clear
if (`pll_instance'==$PLL_CHILDREN) local reps = 20
else local reps = 15
local pll_instance : di %04.0f `pll_instance'
simulate , sav(__pll`pll_id'_sim_eststore`pll_instance', replace  )  rep(`reps'): sim_mmqreg  2000 
