** Simulation using Clustered Standard errors
** Assume no problems in Model Specification


**MC Simulation
capture program drop sim_mmqreg1
program sim_mmqreg1, eclass
        args nobs type g1 g2
    clear
    // Set N obs
    set obs `nobs'
    // Create groups for FE
    gen g1 = runiformint(1,`g1')
    gen g2 = runiformint(1,`g2')
    // Create Fixed effects
    gen f1 = rchi2(1)
    bysort g1:replace f1=f1[1]
    gen f2 = rchi2(1)
    bysort g2:replace f2=f2[1]
    // create X values
    gen x  = 0.5*(rchi2(1)+0.5*(f1+f2))
    // and create errors based on type
    // 1-> rnormal() symetric
    // 2-> Chi2 (asymetric)
    
         if `type' == 1 gen err = rnormal()
    else if `type' == 2 gen err = (rchi2(5)/5-1)
     
    gen  y = f1 + f2 + x + (2+x+f1+f2)*err
    
    qui:mmqreg y x, q(25 75) abs(g2 g1) cluster(g1)  
     mmqreg, gls
    matrix b1 = _b[q25:x], _se[q25:x] 
    matrix b2 = _b[q75:x], _se[q75:x]
    mmqreg, robust
    matrix b1 = b1 , _se[q25:x] 
    matrix b2 = b2 , _se[q75:x]
     mmqreg, cluster(g1)
    matrix b1 = b1 , _se[q25:x] 
    matrix b2 = b2 , _se[q75:x]
 
    matrix b = b1,b2, `e(warning)', `e(nwarning)'
    matrix colname b = q25 q25_gls q25_r  q25_c  q75 q75_gls q75_r  q75_c warn nwarn
    ereturn post b
end


capture program drop sim_mmqreg2
program sim_mmqreg2, eclass
        args nobs type g1 g2
    clear
    // Set N obs
    set obs `nobs'
    // Create groups for FE
    gen g1 = runiformint(1,`g1')
    gen g2 = runiformint(1,`g2')
    // Create Fixed effects
    gen f1 = rchi2(1)
    bysort g1:replace f1=f1[1]
    gen f2 = rchi2(1)
    bysort g2:replace f2=f2[1]
    // create X values
    gen x  =1+ 0.5*(rchi2(1)+0.5*(f1+f2))
    // and create errors based on type
    // 1-> rnormal() symetric
    // 2-> Chi2 (asymetric)
     
         if `type' == 1 gen err = rnormal()
    else if `type' == 2 gen err = (rchi2(5)/5-1)
     
    gen  y = f1 + f2 + x + (2+x+f1+f2 )*err
    
    qui:mmqreg y x, q(25 75) abs(g2 g1) cluster(g1)  
     mmqreg, gls
    matrix b1 = _b[q25:x], _se[q25:x] 
    matrix b2 = _b[q75:x], _se[q75:x]
    mmqreg, robust
    matrix b1 = b1 , _se[q25:x] 
    matrix b2 = b2 , _se[q75:x]
     mmqreg, cluster(g1)
    matrix b1 = b1 , _se[q25:x] 
    matrix b2 = b2 , _se[q75:x]
 
    
        matrix b = b1,b2, `e(warning)', `e(nwarning)'
    matrix colname b = q25 q25_gls q25_r  q25_c  q75 q75_gls q75_r  q75_c warn nwarn
     ereturn post b
end


 


capture program drop sim_mmqreg3
program sim_mmqreg3, eclass
        args nobs type g1 g2
    clear
    // Set N obs
    set obs `nobs'
    // Create groups for FE
    gen g1 = runiformint(1,`g1')
    gen g2 = runiformint(1,`g2')
    // Create Fixed effects
    gen f1 = rchi2(1)
    bysort g1:gen     f11=f1[2]
    bysort g1:replace f1=f1[1]
    gen f2 = rchi2(1)
    bysort g2:gen     f22=f2[2]
    bysort g2:replace f2=f2[1]
    // create X values
    gen x  = 1+ 0.5*(rchi2(1)+0.5*(f1+f2))
    // and create errors based on type
    // 1-> rnormal() symetric
    // 2-> Chi2 (asymetric)
    
         if `type' == 1 {
             gen err = rnormal()
             //bysort g1:gen f11=rnormal() 
         }
    else if `type' == 2 {
            gen err = (rchi2(5)/5-1)
            //gen f11=(rchi2(5)/5-1)
        }
    
    bysort g1:replace f11=f11[1]
     
    gen  y = f1 + f2 + x + (2+x+f1 + f2 )*( err + f11 ) 
     
    qui:mmqreg y x, q(25 75) abs(g2 g1) cluster(g1)  
     mmqreg, gls
    matrix b1 = _b[q25:x], _se[q25:x] 
    matrix b2 = _b[q75:x], _se[q75:x]
    mmqreg, robust
    matrix b1 = b1 , _se[q25:x] 
    matrix b2 = b2 , _se[q75:x]
     mmqreg, cluster(g1)
    matrix b1 = b1 , _se[q25:x] 
    matrix b2 = b2 , _se[q75:x]
    
    matrix b = b1,b2, `e(warning)', `e(nwarning)'
    matrix colname b = q25 q25_gls q25_r  q25_c  q75 q75_gls q75_r  q75_c warn nwarn
     ereturn post b
end


capture program drop sim_mmqreg4
program sim_mmqreg4, eclass
    args nobs type g1 g2
    clear
    // Set N obs
    set obs `nobs'
    // Create groups for FE
    gen g1 = runiformint(1,`g1')
    gen g2 = runiformint(1,`g2')
    // Create Fixed effects
    gen f1 = rchi2(1)
    bysort g1:replace f1=f1[1]
    gen f2 = rchi2(1)
    bysort g2:replace f2=f2[1]
    // create X values
    gen x  = 1+ 0.5*(rchi2(1)+0.5*(f1+f2))
    // and create errors based on type
    // 1-> rnormal() symetric
    // 2-> Chi2 (asymetric)
    
         if `type' == 1 gen err = rnormal()
    else if `type' == 2 gen err = (rchi2(5)/5-1)
     
    gen  y = f1 + f2 + x + (2+x+f1+f2)*err
    
    qui:xtqreg y x i.g1, q(.25) i(g2) 
    matrix b1 = _b[x], _se[x] 
    qui:xtqreg y x i.g1, q(.75) i(g2) 
    matrix b2 = _b[x], _se[x]
        
    matrix b = b1,b2
    matrix colname b = q25 q25_gls q75 q75_gls 
    ereturn post b
end
asd
set seed 101

parallel initialize 10
foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg1  `i' 1 50 50
save sim_`i'_gls_n, replace
}


set seed 101

foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg1  `i' 2 50 50
save sim_`i'_gls_c, replace
}

set seed 101

foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg2  `i' 1 50 50
save sim_`i'_rbs_n, replace
}

set seed 101

foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg2  `i' 2 50 50
save sim_`i'_rbs_c, replace
}

set seed 101

foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg3  `i' 1 50 50
save sim_`i'_cls_n, replace
}

set seed 101

foreach i in 2000  {
parallel sim, reps(5000): sim_mmqreg3  `i' 2 50 50
save sim_`i'_cls_c, replace
}