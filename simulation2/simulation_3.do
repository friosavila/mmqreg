** Simulation using Clustered Standard errors

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
	bysort g1:gen f11=rnormal() 
	bysort g1:replace f11=f11[1]
 	gen x  = 0.5*(rchi2(1)+0.5*(f1+f2))
	gen  y = f1 + f2 + x + (1+x+f1+f2 )*0.5*(rnormal()*sqrt(.5) +sqrt(.5)*f11 )
	mmqreg y x, q(25 75) abs(g2 g1) cluster(g1)
	matrix b1 = _b[q25:x], _se[q25:x] 
	matrix b2 = _b[q75:x], _se[q75:x]
	mmqreg, robust
	matrix b1 = b1, _se[q25:x] 
	matrix b2 = b2 , _se[q75:x]
	mmqreg, gls
	matrix b1 = b1, _se[q25:x] 
	matrix b2 = b2 , _se[q75:x]
	matrix b = b1,b2
	matrix colname b = q25 q25_cl q25_r q25_gls q75 q75_cl q75_r q75_gls
	ereturn post b
end


parallel initialize 14
foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg  `i'
save sim_`i', replace
}

