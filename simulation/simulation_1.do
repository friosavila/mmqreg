**MC Simulation
capture program drop sim_mmqreg
program sim_mmqreg, eclass
clear
set obs `1'
gen g1 = runiformint(1,50)
gen g2 = runiformint(1,50)
gen f1 = rchi2(1)
bysort g1:replace f1=f1[1]
gen f2 = rchi2(1)
bysort g2:replace f2=f2[1]
gen x  = 0.5*(rchi2(1)+0.5*(f1+f2))
gen  y = f1 + f2 + x + (1+x+f1+f2)*(rchi2(5)/5-1)
mmqreg y x, q(25 75) abs(g2 g1)  
matrix b=e(b)'
matrix bf=e(b)'
gen smp = runiformint(0,1)
mmqreg y x if smp==0, q(25 75) abs(g2 g1)  
matrix b=b,e(b)'
mmqreg y x if smp==1, q(25 75) abs(g2 g1)  
matrix b=b,e(b)'
mata:b=st_matrix("b")
mata:st_matrix("baf",(2:*b[,1]:-0.5:*(b[,2]:+b[,3]))')
matrix bf=bf',baf
matrix b=b'
matrix b=b[1,....]
matrix b=b,baf
matrix coleq b = q25 q25 q75 q75 q25b q25b q75b q75b
ereturn post b
end

parallel initialize 13
foreach i in 500 1000 2000 4000 {
parallel sim, reps(10000): sim_mmqreg  `i'
save sim_`i', replace
}
