foreach i in 500 1000 2000 4000 {
use sim_`i', clear
** bias
gen bq25_b_x   =q25_b_x  -(invchi2(5,.25)/5)  
gen bq25b_b_c1 =q25b_b_c1-(invchi2(5,.25)/5)  
gen bq75_b_x   =q75_b_x  -(invchi2(5,.75)/5)  
gen bq75b_b_c1 =q75b_b_c3-(invchi2(5,.75)/5)  

gen b2q25_b_x   =bq25_b_x  ^2
gen b2q25b_b_c1 =bq25b_b_c1^2
gen b2q75_b_x   =bq75_b_x  ^2
gen b2q75b_b_c1 =bq75b_b_c1^2
tabstat  bq* , stats(mean sd) save
matrix m`i'=r(StatTotal)
tabstat2  b2* , stats(mean) save
matrix m`i'=m`i'\r(StatTotal)
matrix m`i'=m`i''
matrix rowname m`i'= q25:mmqreg  q25:jkc q75:mmqreg  q75:jkc
}

matrix mm = (m500, m1000)\(m2000, m4000)
esttab matrix(mm, fmt(3)), tex

use sim_500_gls_c, clear
sum _b_q25
scalar m25 = r(mean)
gen s25 = r(sd)
sum _b_q75
scalar m75 = r(mean)
gen s75 = r(sd)
gen bias_25 = _b_q25-(invchi2(5,.25)/5)
gen bias_75 = _b_q75-(invchi2(5,.75)/5)
gen c1_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_gls,1.96*_b_q25_gls)
gen c2_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_r,1.96*_b_q25_r)
gen c3_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_c,1.96*_b_q25_c)

gen c1_75 = inrange(_b_q75-m75,-1.96*_b_q75_gls,1.96*_b_q75_gls)
gen c2_75 = inrange(_b_q75-m75,-1.96*_b_q75_r,1.96*_b_q75_r)
gen c3_75 = inrange(_b_q75-m75,-1.96*_b_q75_c,1.96*_b_q75_c)

mean bias_25 s25 c*25 _b*25_*


esttab matrix(tbl, fmt(3)), md

