using WooldridgeDatasets, DataFrames, StatsModels, LinearAlgebra
using QuantileRegressions, FixedEffectModels

 
function mean(x)
    n ,k = size(x)
    return sum(x,dims=(1))./n
end

function mmqreg(y::Array, X::Array, q::Float64)
    ## First get basics
    n ,k = size(X)
    x    = hcat(X,ones(n))    
    ## Extra data needed
    xx = x'*x
    print(inv(xx))
    ixx= inv(xx)
    ## 
    β = ixx * (x'*y)
    errs  = y .- x*β
    ## Estimate Scale 
    γ = ixx * (x'*abs.(errs))
    xg = x*γ
    ## Std error
    std_e = errs./xg

    ## Quantile Regression part
    sqreg=qreg(@formula(se ~ 1), DataFrame(se=std_e) , q)
    vq=vcov(sqreg)
    qt=coef(sqreg)

    #f =  .2433832856564021
    ## Make a version for Multiple Qs
    fden = sqrt( (1-q)*q ./ (n*vq))
    ## STD errors
    print("hi")
    if1 = ( n*ixx*(x.*errs)' )'
 

    vt  = 2*errs .*((errs.>=0).-mean((errs.>=0),n) ) .-xg
    if2 = ( n*ixx*(x.*vt)' )'
    sv  = vt./xg
    if3 = (fden^-1).*(t.-(q.>=std_e)) .- errs./mean(xg,n) .- q.*vt./mean(xg,n)
    ifx=[if1 if2 if3]
    
    bgq =[β ; γ ; β.+ qt[1]*γ]
    print("hi")
    return bgq, (diag(ifx'ifx)./n^2).^.5
end

ss=mmqreg(y,x)
ss[1], ss[2]
wage1
y = wage1.wage
x = Array(wage1[:,[:educ, :exper, :tenure, :female ]])
## First part get formula and data

ss=mmqreg(y,x,0.15)
ss[1]