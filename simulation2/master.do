*** master ***
/// Simulations 
/// Table 1: Showing bias SE and MSE for the method
/// Change Now using Chi2 as source of error

do tab_sim1.do

/// Table 2: Showing Coverage Only Bias, De-biased
/// Under different assumptions: GLS, Robust, Clustered

do tab_sim2.do


/// Replication Excercise 
do data_replication.do