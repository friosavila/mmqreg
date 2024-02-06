drop2 d*
sum _b_q25
scalar m25 = r(mean)
scalar s25 = r(sd)
sum _b_q75
scalar m75 = r(mean)
scalar s75 = r(sd)
gen d1 = inrange(_b_q75-m75,-1.96*_b_q75_gls,1.96*_b_q75_gls)
gen d2 = inrange(_b_q75-m75,-1.96*_b_q75_r,1.96*_b_q75_r)
gen d3 = inrange(_b_q75-m75,-1.96*_b_q75_c,1.96*_b_q75_c)

gen d11 = inrange(_b_q25-m25 ,-1.96*_b_q25_gls,1.96*_b_q25_gls)
gen d12 = inrange(_b_q25-m25 ,-1.96*_b_q25_r,1.96*_b_q25_r)
gen d13 = inrange(_b_q25-m25 ,-1.96*_b_q25_c,1.96*_b_q25_c)


gen sd1=_b_q25_gls-s25
gen sd2=_b_q25_r-s25
gen sd3=_b_q25_c-s25

gen sd11=_b_q75_gls-s75
gen sd12=_b_q75_r-s75
gen sd13=_b_q75_c-s75

sum  