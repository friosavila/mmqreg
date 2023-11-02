foreach i in 500 1000 2000 4000 {
use sim_`i', clear
** bias
gen bq25_b_x   =q25_b_x  -(1+invnormal(.25)*.5)  
gen bq25b_b_c1 =q25b_b_c1-(1+invnormal(.25)*.5)  
gen bq75_b_x   =q75_b_x  -(1+invnormal(.75)*.5)  
gen bq75b_b_c1 =q75b_b_c3-(1+invnormal(.75)*.5)  

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

esttab matrix(m500, fmt(3)), md

use sim_2000_robust, clear
sum _b_q25
matrix r1 = r(mean)\ r(sd)
sum _b_q25_gls 
matrix r1 = r1\ r(mean)
sum _b_q25_r
matrix r1 = r1\ r(mean)
matrix r1 = r1\ 0

sum _b_q75
matrix r2 = r(mean)\ r(sd)
sum _b_q75_gls 
matrix r2 = r2\ r(mean)
sum _b_q75_r
matrix r2 = r2\ r(mean)
matrix r2 = r2\ 0

use sim_2000_clust, clear
sum _b_q25
matrix r3 = r(mean)\ r(sd)
sum _b_q25_gls 
matrix r3 = r3\ r(mean)
sum _b_q25_r
matrix r3 = r3\ r(mean)
sum _b_q25_cl
matrix r3 = r3\ r(mean)

sum _b_q75
matrix r4 = r(mean)\ r(sd)
sum _b_q75_gls 
matrix r4 = r4\ r(mean)
sum _b_q75_r
matrix r4 = r4\ r(mean)
sum _b_q75_cl
matrix r4 = r4\ r(mean)

matrix tbl = r1,r2,r3 ,r4

matrix rowname tbl = coef SIM_SE GLS_SE Robust Cluster
matrix colname tbl = Het:q25 Het:q75 Clust:q25 Clust:q75
esttab matrix(tbl, fmt(3)), md

