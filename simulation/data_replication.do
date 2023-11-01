use "MAJ_NICOLA.DTA" , clear
mmqreg spl polity_gt lyp trade  prop1564 prop65 lspl  oil_im oil_ex ygap, q(25 50 75) ls cluster(ctrycd) abs(ctrycd)
matrix table1a=r(table)
mmqreg , robust
matrix table1b=r(table)
mmqreg , gls
matrix table1c=r(table)

mmqreg spl polity_gt lyp trade  prop1564 prop65 lspl    ygap, q(25 50 75) ls cluster(ctrycd) abs(ctrycd year)
matrix table2a=r(table)
mmqreg , robust
matrix table2b=r(table)
mmqreg , gls
matrix table2c=r(table)

foreach i in table1c table1a table1b  table2a table2b table2c {
    matrix `i'=`i'[1..2,....]
}

matrix table1 =  table1c\table1b[2,....]\table1a[2,....]
matrix table2 =  table2c\table2b[2,....]\table2a[2,....]

matrix rowname table1= coeff se_gls se_r se_cl
matrix rowname table2= coeff se_gls se_r se_cl

matrix table1 = table1[....,"location:"]\table1[....,"scale:"]\table1[....,"q25:"]\table1[....,"q50:"]\table1[....,"q75:"]
matrix table2 = table2[....,"location:"]\table2[....,"scale:"]\table2[....,"q25:"]\table2[....,"q50:"]\table2[....,"q75:"]

local ss = "Location "*4 +"Scale "*4 +"Q25 "*4 +"Q50 "*4 +"Q75 "*4
 matrix roweq table1 = `ss'

local ss = "Location "*4 +"Scale "*4 +"Q25 "*4 +"Q50 "*4 +"Q75 "*4
 matrix roweq table2 = `ss'
 matrix coleq table1 = ""
 matrix coleq table2 = ""

 matrix table1 = table1[....,1..9] 
 matrix table2 = table2[....,1..7] 
esttab matrix( table1, fmt(3)), compress md

esttab matrix( table2, fmt(3) ), compress md 

