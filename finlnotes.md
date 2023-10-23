---
title: "Untitled"
format: html
---

## The model: No fixed effects

$$y=X\beta+(X\gamma) e$$

where $e$ is an unobserved random variable, independent of X, that is normalized to satisfy the following moment conditions:

$$E(e)=0 \ \ \ E(|e|)=1$$

Under this conditions, the restricted quantile regression can be defined as:

$$Q_Y(\tau|X) = X\beta + q(\tau) X\gamma$$

Under the exogeneity assumption, and imposing the moment conditions on the error $e$, the model can be estimated under the following moment conditions:

$$
\begin{aligned}
E\big[X_i' R_i \big] &=0 \\
E\big[ X_i' V_i \big] &=0 \\
E\Big[ I\big(Q_y(\tau|X) \geq y_i\big)  -\tau \Big]  &=0
\end{aligned}
$$

where:

$$R_i = y_i-X_i'\beta ; V_i = |R_i| - X_i\gamma $$

This model can be estimated using a 5 step process:

1. Based on the equation eq1, estimate the location model and obtain set of coefficients $\beta$ and the model residuals $R$.
2. Based on the equation eq2, estimate the Scale model using $|\hat R|$ as the dependent variable, and obtain $\gamma$.
3. Using $\hat \beta$ and $\hat gamma$ obtain the standardized residals.
 $\hat e_i = \frac{y_i-X_i\hat\beta}{X_i \hat\gamma}$
4. Estimate the $\tau$th quantile of $\hat e$, such that eq3 is satisfied.
5. The restricted quantile regression coefficients $\beta(\tau)$ are then defined by:

$$
\hat \beta(\tau) =\hat  \beta + \hat q_\tau \hat \gamma  
$$

## Standard Errors

As described before, this model aims to estimate three set of parameters: 

$$
\theta = \beta, \gamma, q_\tau
$$

Because we have an exactly identified model, the set of moments used for identification cab be used to estimate the *robust* variance covariance matrix for $\theta$, which is given by:

$$
Var(\hat\theta) = \frac{1}{N} \left(
    \frac{1}{N} 
    \sum_{i=1}^N  \lambda_i(\theta) \lambda_i(\theta)'  
\right) = \frac{1}{N^2} 
\lambda(\theta)'\lambda(\theta)
$$

where $\lambda_i(\theta)$ is an $(2k+1)$ vector that contains the influence function 
for the set of parameters $\theta={\hat\beta,\hat\gamma,\hat q_\tau}$, and $\lambda(\theta)$ is an $N\times (2k+1)$ matrix containing the Influence functions for all observations in the data. In general, this influence function is defined as:
$$
\lambda_i(\theta) = \bar G(\theta)^{-1} h_i (x_i,\theta)
$$

Specifically, the influence functions for the paramaters in the  model are given by:

$$
\begin{aligned}
\lambda_i(\beta) &= N (X'X)^{-1} X_i'(\hat R_i) \\
\lambda_i(\gamma) &= N (X'X)^{-1} X_i'( \tilde R_i - X_i\hat\gamma) \\
s.t. \ \ & \tilde R_i = 2 \hat R_i
\left( 1(\hat R_i \geq0)-
       \frac{1}{N}\sum_{i=1}^N 1(R_i\geq 0) 
       \right) \\
\lambda_i(q_\tau) &= 
\frac{1}{f(q_\tau)}
\left[\tau - 1 \left( q_\tau \geq \frac{R_i}{X_i\hat\gamma}\right)\right] 
- \frac{\hat R_i }{X_i\hat\gamma}  
- q_\tau \frac{(\tilde R_i- X_i\hat\gamma)}{X_i\hat\gamma} \\
    &= \frac{1}{f(q_\tau)}
\left[\tau - 1 \left( q_\tau \geq \hat e_i \right)\right] 
- \hat e_i  
- q_\tau (\tilde e_i-1)  \\
s.t. \ \ & \tilde e_i = 2 \hat e_i\left( 1( \hat e_i \geq0)-\frac{1}{N}\sum_{i=1}^N 1(\hat e_i\geq 0) \right) \\

\end{aligned}
$$

which implies that the $Var(\theta)$, written in matrix form, is given by:

$$
\begin{aligned}
Var_1(\hat \theta)=\frac{1}{N^2}
    \begin{bmatrix}
    \lambda(\beta)'\lambda(\beta) & \lambda(\beta)'\lambda(\gamma) & \lambda(\beta)'\lambda(q_\tau)\\
    \lambda(\gamma)'\lambda(\beta)' & \lambda(\gamma)'\lambda(\gamma)& \lambda(\gamma)'\lambda(q_\tau)\\
    \lambda(q_\tau)'\lambda_i(\beta) & \lambda(q_\tau)'\lambda(\beta) & \lambda( q_\tau)'\lambda(\ q_\tau)
    \end{bmatrix}
\end{aligned}
$$

Finally, the variance covariance of $\hat \beta(\tau)$ will be given by:

$$Var(\hat\beta(\tau)) = \Xi Var(\hat\theta) \Xi'$$

where $\Xi$ is a $k \times (2k+1)$ matrix defined as:

$$
\begin{aligned}
    \Xi &= I(k), \hat q(\tau) I(k), \hat \gamma \\
    \Xi &= \left[ \begin{array}{cccc|cccc|}
           1 & 0 & ... & 0 &\hat q_(\tau) & 0 & ... & 0  & \hat\gamma_1 \\
           0 & 1 & ... & 0 &0& \hat q_(\tau) & ... & 0 & \hat\gamma_2 \\
          ...&...& ... & 0 &...&...& ... & 0             & ...\\
           0 & 0 & ... & 1 &0 & 0 & ... & \hat q(\tau)   & \hat\gamma_k
        \end{array} \right]         
\end{aligned}
$$

Where $Var(\hat\beta(\tau))$ is the robust $k\times k$ variance-covariance matrix for the restricted quantile regression coefficients $\beta(\tau)$.

## Alternative SE

### Under Correct model Specification assumption

In MSS, the authors propose an alternative estimator for the variance covariance matrix, which is similar to the application of Feasible Generalized Least Squares, where the source of heteroskedasticity is known to follow a particular functional form. Under the assumption of correct model specification, it may be more efficient than the EH Robust Standard errors specification described above. 

Lets rewrite equations eq1 and eq2, so that the errors $\hat R_i$ and $\tilde R_i -X_i'\gamma$ are written as functions of the standardized errors $\hat e$ and $\tilde e-1$. Let us also substitute $X_i'\hat\gamma$ with $\hat \sigma_i$:

$$
\begin{aligned}
\lambda_i(\beta) &= N (X'X)^{-1} X_i(\hat \sigma_i \hat e_i) \\
\lambda_i(\gamma) &= N (X'X)^{-1} X_i( \hat \sigma_i   (\tilde e_i - 1) ) \\
\lambda_i(q_\tau) &= 
\frac{1}{f(q_\tau)}
\left[\tau - 1 \left( q_\tau \geq  \hat e_i \right)\right] 
- \hat e_i  - q_\tau (\tilde e_i- 1)
\end{aligned}
$$

Consider now, the first block diagonal element of  $Var(\hat\theta)$, which defines the variance covariance of $\beta's$. Under the assumption of correctly specified :

$$
\begin{aligned}
\lambda(\beta)'\lambda(\beta) &= (X'X)^{-1} (X\hat \sigma \hat e_i)'(X\hat \sigma \hat e_i) (X'X)^{-1} \\
&= \frac{\hat e'\hat e}{N} (X'X)^{-1} \sum (\sigma_i^2 X_i X_i') (X'X)^{-1}
\end{aligned}
$$

In general, $Var(\hat \theta)$ will have the following form:

$$
\begin{aligned}
Var_0(\hat \theta)=\frac{1}{N^3}
    \begin{bmatrix}
    \hat e' \hat e \ QPQ_{xx} & \hat e' \tilde e \ QPQ_{xx} & \hat e' \lambda(q_\tau) \  QP_{xx} \\
    \hat e' \tilde e \  QPQ_{xx} & \tilde e'\tilde e \  QPQ_{xx} & \tilde e' \lambda(q_\tau) \ QP_{xx} \\
    \lambda(q_\tau)'\hat e \  QP'_{xx} & \lambda(q_\tau)'\tilde e \  QP'_{xx} & \lambda(q_\tau)'\lambda(q_\tau) \ 
    \end{bmatrix}
\end{aligned}
$$

where 

$$
\begin{aligned}
QPQ_{xx}&= (X'X)^{-1} \sum (\sigma_i^2 X_i X_i') (X'X)^{-1} \\
QP_{xx} &= (X'X)^{-1} \sum (\sigma_i X_i) 
\end{aligned}
$$

### Clustered Standard Errors and Weights

\sum over clusters

$\tilde w =N\frac{ w}{\sum w_i}$

Estimate all models using $\tilde w$ and modify the influence functions as follows: 
$$
\begin{aligned}
\lambda_i(\beta) &= N (X'\tilde w X)^{-1} X_i(\hat \sigma_i \hat e_i w_i)  \\
\lambda_i(\gamma) &= N (X'\tilde w X)^{-1} X_i( \hat \sigma_i   (\tilde e_i - 1)w_i ) \\
\lambda_i(q_\tau) &= 
w_i \frac{1}{f(q_\tau)}
\left[\tau - 1 \left( q_\tau \geq  \hat e_i \right)\right] 
- w_i \hat e_i  - w_i q_\tau (\tilde e_i- 1)
\end{aligned}
$$

