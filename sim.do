**MC Simulation
clear
set obs 2500
gen g1 = runiformint(1,50)
gen g2 = runiformint(1,50)
gen f1 = rchi2(1)
bysort g1:replace f1=f1[1]
gen f2 = rchi2(1)
bysort g2:replace f2=f2[1]
gen x  = 0.5*(rchi2(1)+0.5*(f1+f2))
gen  y = f1 + f2 + x + (1+x+f1+f2)*rnormal()