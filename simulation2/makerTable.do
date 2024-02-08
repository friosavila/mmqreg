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

foreach j in 500 1000 2000 4000 {
use sim_`j'_gls_c, clear
sum _b_q25
scalar m25 = r(mean)
gen s25 = r(sd)
sum _b_q75
scalar m75 = r(mean)
gen s75 = r(sd)

sum _b_q25_gls,d
gen mnsd25 = r(mean)
gen mdsd25 = r(p50)
sum _b_q75_gls,d
gen mnsd75 = r(mean)
gen mdsd75 = r(p50)
gen bias_25 = _b_q25-(invchi2(5,.25)/5)
gen bias_75 = _b_q75-(invchi2(5,.75)/5)
gen c1_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_gls,1.96*_b_q25_gls)
gen c2_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_r,1.96*_b_q25_r)
gen c3_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_c,1.96*_b_q25_c)

gen c1_75 = inrange(_b_q75-m75,-1.96*_b_q75_gls,1.96*_b_q75_gls)
gen c2_75 = inrange(_b_q75-m75,-1.96*_b_q75_r,1.96*_b_q75_r)
gen c3_75 = inrange(_b_q75-m75,-1.96*_b_q75_c,1.96*_b_q75_c)

mean bias_25 s25 c*25 mnsd25 mdsd25 _b_q25_r _b_q25_c
matrix b1 = e(b)
mean bias_75 s75 c*75 mnsd75 mdsd75 _b_q75_r _b_q75_c
matrix b2 = e(b)
matrix coleq b1 =q25
matrix coleq b2 =q75

matrix tb25 = nullmat(tb25)\b1,`j'
matrix tb75 = nullmat(tb75)\b2,`j'
}

matrix drop tb25b tb75b
foreach j in 500 1000 2000 4000 {
use sim_`j'_cls_c, clear
sum _b_q25
scalar m25 = r(mean)
gen s25 = r(sd)
sum _b_q75
scalar m75 = r(mean)
gen s75 = r(sd)

sum _b_q25_gls,d
gen mnsd25 = r(mean)
gen mdsd25 = r(p50)
sum _b_q75_gls,d
gen mnsd75 = r(mean)
gen mdsd75 = r(p50)
gen bias_25 = _b_q25-(invchi2(5,.25)/5)
gen bias_75 = _b_q75-(invchi2(5,.75)/5)
gen c1_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_gls,1.96*_b_q25_gls)
gen c2_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_r,1.96*_b_q25_r)
gen c3_25 = inrange(_b_q25-m25 ,-1.96*_b_q25_c,1.96*_b_q25_c)

gen c1_75 = inrange(_b_q75-m75,-1.96*_b_q75_gls,1.96*_b_q75_gls)
gen c2_75 = inrange(_b_q75-m75,-1.96*_b_q75_r,1.96*_b_q75_r)
gen c3_75 = inrange(_b_q75-m75,-1.96*_b_q75_c,1.96*_b_q75_c)

mean bias_25 s25 mnsd25 mdsd25 c1_25 _b_q25_r c2_25 _b_q25_c c3_25 
matrix b1 = e(b)
mean bias_75 s75 mnsd75 mdsd75 c1_75 _b_q75_r c2_75 _b_q75_c c3_75 
matrix b2 = e(b)
matrix coleq b1 =q25
matrix coleq b2 =q75

matrix tb25b = nullmat(tb25b)\b1,`j'
matrix tb75b = nullmat(tb75b)\b2,`j'
}

matrix tt =  tb25b',b2'
esttab matrix(tt, fmt(3)), tex