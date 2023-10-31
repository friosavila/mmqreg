// needed for callout support
#import "@preview/fontawesome:0.1.0": *

// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw: it => {
  if it.block {
    block(fill: luma(230), width: 100%, inset: 8pt, radius: 2pt, it)
  } else {
    it
  }
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(breakable: false, fill: background_color, stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), width: 100%, radius: 2pt)[
    #block(inset: 1pt, width: 100%, below: 0pt)[#block(fill: background_color, width: 100%, inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]]
    #block(inset: 1pt, width: 100%)[#block(fill: white, width: 100%, inset: 8pt)[#body]]]
}



#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    block(above: 0em, below: 2em)[
    #outline(
      title: auto,
      depth: none
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
#show: doc => article(
  title: [Quantile Regressions via Method of Moments with multiple fixed effects],
  authors: (
    ( name: [Fernando Rios-Avila],
      affiliation: [Levy Economics Institute of Bard College],
      email: [friosavi\@levy.org] ),
    ( name: [Leonardo Siles],
      affiliation: [],
      email: [leo\@gmail.com] ),
    ( name: [Gustavo Canavire-Bacarreza],
      affiliation: [World Bank],
      email: [gcanavire\@worldbank.org] ),
    ),
  date: [2023-10-30],
  abstract: [This paper proposes a new method to estimate quantile regressions with multiple fixed effects. The method expands on the strategy proposed by #cite("mss2019"), allowing for multiple fixed effects, and providing various alternatives for the estimation of Standard errors. We provide Monte Carlo simulations to show the finite sample properties of the proposed method in the presence of two sets of fixed effects. Finally, we apply the proposed method to estimate the determinants of the surplus of government as a share of GDP allowing for both time and country fixed effects.

],
  cols: 1,
  doc,
)


= Introduction
<introduction>
Quantile regression (QR), introduced by #cite("koenkerbasset1978"), is an estimation strategy used for modeling the relationships between explanatory variables X and the conditional quantiles of the dependent variable $q_tau lr((y bar.v x))$. Using QR one can obtain richer characterizations of the relationships between dependent and independent variables, by accounting for otherwise unobserved heterogeneity.

A relatively recent development in the literature has focused on extending quantile regressions analysis to include individual fixed effects in the framework of panel data. However, as described in #cite("neymanscott1948"), and #cite("lancaster2000"), when individual fixed effects are included in quantile regression analysis it generates an incident parameter problem. While many strategies have been proposed for estimating this type of model (see #cite("galvao2017quantile") for a brief review), neither has become standard because of their restrictive assumptions in regards to the individual effects, the computational complexity, and implementation.

More recently, #cite("mss2019") (MSS hereafter) proposed a methodology based on a conditional location-scale model similar to the one described in #cite("he1997") and #cite("zhao2000"), for the estimation of quantile regressions models for panel data via a method of moments. This method allows individual fixed effects allowing to have heterogeneous effects on the entire conditional distribution of the outcome, rather constraining their effect to be a location shift only as in #cite("canay2011"), #cite("koenker2004"), and #cite("lancaster2000").

In principle, under the assumption that data generating process behind the data is based on a multiplicative heteroskedastic process that is linear in parameters #cite("cameron2005"), the effect of a variable $X$ on the $q_(t h)$ quantile can be derived as the combination of a location effect, and scale effect moderated by the quantile of an underlying i.i.d. error. For statistical inference, MSS derives the asymptotic distribution of the estimator, suggesting the use of bootstrap standard errors, as well.

While this methodology is not meant to substitute the use of standard quantile regression analysis, given the assumptions required for the identification of the model, it provides a simple and fast alternative for the estimation of quantile regression models with individual fixed effects.

In this framework, our paper expands on #cite("mss2019"), following some of the suggestions by the authors regarding further research. First, making use of the properties of GMM estimators, we derive various alternatives for the estimation of standard errors based on the empirical Influence functions of the estimators. Second, we reconsider the application of Frisch–Waugh–Lovell (FWL) theorem (#cite("frishwaugh1933") and #cite("lovell1963")) to extend the MSS estimator to allow for the inclusion of multiple fixed effects, for example, individual and year fixed effects.

The rest of the paper is restructured as follows. Section 2 presents the basic setup of the location-Scale model described in #cite("he1997") and #cite("zhao2000"), tying the relationship between the standard quantile regression model, and the location and scale model. It also revisits MSS methodology, proposing alternative estimators for the standard errors based on the properties of GMM estimators and the empirical influence functions. It also shows that FWL theorem can be used to control for multiple fixed effects. Section 3 presents the results of a small simulation study and Section 4 illustrates the application of the proposed methods with two empirical examples. Seccion 5 concludes.

= Methodology
<methodology>
== Quantile Regression: Location-Scale model
<sec-betas>
Quantile regressions are used to identify relationships between the explanatory variables $x$ and the conditional quantiles of the dependent variable $Q lr((y bar.v tau comma X))$. This relationship is commonly assumed to follow a linear functional form:

#set math.equation(numbering: "(1)"); $ q(Y|X,\tau) =X\beta(\tau)
 $ <eq-eq1> #set math.equation(numbering: none)

This allows for nonlinearities in the effect of $X$ on $Y$ across all values of $tau$. This formulation can also be related to a random coefficient model, where all coefficients are assumed to be some nonlinear function of $tau$, where $tau$ follows a random uniform distribution.

An alternative formulation of quantile regressions is the location-scale model. This approach assumes that the conditional quantile of $Y$ given $X$ and $tau$ can be expressed as a combination of two models: the location model, which describes the central tendency of the conditional distribution, and the scale model, which describes deviations from the central tendency:

#set math.equation(numbering: "(2)"); $ q(Y|X,\tau) =X\beta+X\gamma(\tau)
 $ <eq-eq2> #set math.equation(numbering: none)

Here, the location parameters $beta$ are typically identified using a linear regression model (as in #cite("mss2019")), or a median regression (as in #cite("melly2005")), and the scale parameters $gamma lr((tau))$ can be estimated using standard approaches.

Both the standard quantile regression (@eq-eq1) and the location-scale specification (@eq-eq2) can be estimated as the solution to a weighted minimization problem:

#set math.equation(numbering: "(3)"); $ \hat{\beta}(\tau) = \underset{\beta}{\operatorname{argmin}}
\left( \sum_{i\in y_i\geq x_i'\beta} \tau (y_i - x_i'\beta) - \sum_{i\in y_i<x_i'\beta} (1-\tau)(y_i - x_i'\beta) \right)
 $ <eq-eq3> #set math.equation(numbering: none)

One characteristic of this estimator is that the $beta lr((tau))$ coefficients are identified locally, and thus the estimated quantile coefficients will exhibit considerable variation when analyzed across $tau$. It is also implicit that if one requires an analysis of the entire distribution, it would be necessary to estimate the model for each quantile.#footnote[There are other estimators that provide smoother estimates for the quantile regression coefficients using a kernel local weighted approach #cite("kaplan2017"), as well as identifying the full set of quantile coefficients simultaneously assuming some parametric functional forms #cite("frumentobotai2016").]

One insightful extension to the location-scale parameterizations suggested by #cite("he1997"), #cite("cameron2005"), and #cite("mss2019") is to assume that the data-generating process (DGP) can be written as a linear model with a multiplicative heteroskedastic process that is linear in parameters.#footnote[#cite("mss2019") also discuss a model where heteroskedasticity can be an arbitrary nonlinear function $sigma lr((x_i prime gamma))$, but develop the estimator for the linear case, i.e., when $sigma lr(())$ is the identity function.]

#set math.equation(numbering: "(4)"); $ \begin{aligned}
y_i &=x_i'\beta+\nu_i \\
\nu_i &=\varepsilon_i \times x_i'\gamma 
\end{aligned}
 $ <eq-eq4> #set math.equation(numbering: none)

Under the assumption that $epsilon$ is an independent and identically distributed (iid) unobserved random variable that is independent of $X$, the conditional quantile of $Y$ given $X$ and $tau$ can be written as:

#set math.equation(numbering: "(5)"); $ q(Y|X,\tau) =X\beta+q(\varepsilon|\tau) \times X\gamma 
 $ <eq-eq5> #set math.equation(numbering: none)

In this setup, the traditional quantile coefficients are identified as the location model coefficients, plus the scale model coefficients moderated by the $tau_(t h)$ unconditional quantile of the standardized error $epsilon$.

#set math.equation(numbering: "(6)"); $ \beta(\tau) = \beta + q(\varepsilon|\tau) \times \gamma 
 $ <eq-eq6> #set math.equation(numbering: none)

While this specification imposes a strong assumption on the DGP, it has two advantages over the standard quantile regression model. First, because the location and scale model can be identified globally, with only a single paramater ($q lr((epsilon bar.v tau))$) requiring local estimation, this estimation approach would be more efficient than the standard quantile regression model (#cite("zhao2000")). Second, under the assumption that $X gamma$ is strictly possitive, the model would produce quantile coefficients that do not cross.

Following MSS, the quantile regression model defined by @eq-eq5 can be estimated using a method of moments approach. And while its possible to identify all coefficients ($beta comma gamma comma q lr((epsilon bar.v tau))$) simultaneously, we describe and use the implementation approach advocated by MSS which identifies each set of coefficients separately.

+ The location model can be estimated using a standard linear regression model, where the dependent variable is the outcome $Y$, and the independent variables are the explanatory variables $X$ (including a constant) with an error $u$, which is by definition heteroskedastic. In this case, the location model coefficients are identified under the following condition:

#set math.equation(numbering: "(7)"); $ \begin{aligned}
      y_i &=x_i'\beta+\nu_i \\
      E\big[ x_i \nu_i\big] &=0
      \end{aligned}
 $ <eq-eq7> #set math.equation(numbering: none)

#block[
#set enum(numbering: "1.", start: 2)
+ After the location model is estimated, the scale coefficients can be identified by modeling heteroskedasticity as a linear function of characteristics $X$. For this we use the absolute value of the errors from the location model $u$ as dependent variable, which would allow us to estimate the conditional standard deviation (rather than conditional variance) of the errors. In this case, the coefficients are identified under the following condition:
]

#set math.equation(numbering: "(8)"); $ \begin{aligned}
  |\nu_i| &=x_i'\gamma+\omega_i \\
  E\big[ x_i \omega_i \big] &=0 \\
  E\big[ x_i (|\nu_i| -x_i'\gamma ) \big] &=0
  \end{aligned}
 $ <eq-eq8> #set math.equation(numbering: none)

#block[
#set enum(numbering: "1.", start: 3)
+ Finally, given the location and scale coefficients, the $tau_(t h)$ quantile of the error $epsilon$ can be estimated using the following condition:
]

#set math.equation(numbering: "(9)"); $ \begin{aligned}
  E\left[  \mathbb{1}\left(x_i' (\beta + \gamma q(\varepsilon|\tau)) \geq y_i \right) - \tau \right] &=0  \\
  E\left[  \mathbb{1}\left(   q(\varepsilon|\tau)\geq \frac{y_i-x_i'\beta}{x_i'\gamma} \right) - \tau \right] &=0  \\
  \end{aligned}
 $ <eq-eq9> #set math.equation(numbering: none)

Where one identifies the quantile of the error $epsilon$ using standardized errors $frac(y_i minus x_i prime beta, x_i prime gamma)$, or by finding the values that identify the overall quantile coefficients $beta lr((tau)) eq beta plus gamma q lr((epsilon bar.v tau))$. Afterwords, the conditional quantile coefficients is simply defined as the combination of the location and scale coefficients.

== Standard Errors: GLS, Robust, Clustered
<sec-se>
As discussed in the previous section, the estimation of quantile regression coefficients using the location-scale model with heteroskedstic linear errors can be estimated using a the following set of moments, which fits in the Generalized Method of Moments framework:

#set math.equation(numbering: "(10)"); $ \begin{aligned}
  E[x_i \nu_i  ] &= E[h_{1,i}]=0 \\
  E[x_i  (|\nu_i|-x_i \gamma) ] &=E[h_{2,i}]=0 \\
  E\left[  \mathbb{1}\left(   q(\varepsilon|\tau)\geq \frac{y_i-x_i'\beta}{x_i'\gamma} \right) - \tau \right] 
  &=E[h_{3,i}]=0 
  \end{aligned}
 $ <eq-eq10> #set math.equation(numbering: none)

Under the conditions described in #cite("newey_chapter_1994") (see section 7), #cite("cameron2005") (see chapter 6.3.9) or as shown in #cite("mss2019"), the location, scale and residual quantile coefficients are asymptotically normal.#footnote[#cite("zhao2000") also shows that the quantile coefficients for the location-scale model also follows a normal distribution, but uses the assumption that the location model is derived using a least absolute deviation approach (median regression).]

Call $theta eq lr([beta prime med med gamma prime med med q lr((epsilon bar.v tau)) prime]) prime$ the set of coefficients that are identified by the modement conditions in @eq-eq10, a just identified model. And the function $h_i$ is a vector function that stacks all the moments at the individual level described in @eq-eq10. Then $hat(theta)$ follows a normal distribution with mean $theta$ and variance-covariance matrix $V lr((theta))$ that is estimated as:

$ hat(V) lr((hat(theta))) eq 1 / N G^(‾) lr((hat(theta)))^(minus 1) lr((1 / N sum_(i eq 1)^N h_i h_i prime #scale(x: 180%, y: 180%)[bar.v]_(theta eq hat(theta)))) G^(‾) lr((hat(theta)))^(minus 1) $

Which is equivalent to the Eicker-White Heteroskedastic-Consistent estimator for least-squares estimators.

Here, the inner product is the moment covariance matrix, and $G^(‾) lr((theta))$ is the Jacobian matrix of the moment equations evaluated at $hat(theta)$.

$ G^(‾) lr((theta)) eq minus 1 / N sum_(i eq 1) frac(diff h_i, diff theta prime) #scale(x: 180%, y: 180%)[bar.v]_(theta eq hat(theta)) $

In this framework, the quantile regression coefficients, a combination of the location-scale-quantile estimates, will follow a normal distribution with mean $beta lr((tau)) eq beta plus q lr((epsilon bar.v tau)) gamma$ and variance-covariance matrix equal to:

$ hat(V) lr((beta lr((tau)))) eq Xi hat(V) lr((hat(theta))) Xi prime $

where $Xi$ is a $k times lr((2 k plus 1))$ matrix defined as:

#set math.equation(numbering: "(11)"); $ \Xi = [ I(k), \hat q(\varepsilon|\tau) \times I(k), \hat \gamma ]
 $ <eq-eqqtile> #set math.equation(numbering: none)

with $I lr((k))$ being an identity matrix of dimension $k$ (number of explanatory variables in $X$ including the constant).

While it is possible to estimate the variance-covariance matrix using simultaneous model estimation, for a just identified model, it is more efficient to estimate each set of coefficients separately. Afterwards, the variance-covariance matrix can be estimated using the empirical influence functions of the estimators (see #cite("jann_2020") for an overview of the application, and #cite("hampel2005") for an in-depth review).

Specifically, given an arbitrary vector of empirical influence functions $lambda_i lr((theta))$, the variance-covariance matrix can be estimated as: #set math.equation(numbering: "(12)"); $ \hat{V}(\theta) = \frac{1}{N^2} \sum_{i=1}^N \lambda_i(\theta) \lambda_i(\theta)'
 $ <eq-eqvcv> #set math.equation(numbering: none)

where the influence functions are defined as:

$ lambda_i lr((theta)) eq G^(‾) lr((theta))^(minus 1) h_i lr((theta)) $

For the specific case of quantile regressions via momoments, the influence functions for the location, scale and quantile coefficients are:#footnote[The derivation of the influence functions can be found in @sec-appendix.]

#set math.equation(numbering: "(13)"); $ \begin{aligned}
\lambda_i(\theta)&=
  \begin{bmatrix}
  \lambda_{i}(\beta) \\
  \lambda_{i}(\gamma) \\
  \lambda_{i}(q(\varepsilon|\tau)) 
  \end{bmatrix} \\
\lambda_{i}(\beta)&=N (X'X)^{-1}  x_i ( x_i'\gamma) \times \varepsilon_i \\
\lambda_{i}(\gamma)&= N(X'X)^{-1} x_i ( x_i' \gamma ) \times (\tilde \varepsilon_i -1\big)\\
\lambda_{i}(q(\varepsilon|\tau))&=\frac{\tau-\mathbb{1}\big( q(\varepsilon|\tau)  \geq \varepsilon_i  \big) }{f_{\varepsilon}(q(\varepsilon|\tau))}
- \frac{ x_i'\gamma \times \varepsilon_i }{\bar x_i'\gamma} 
-  q(\varepsilon|\tau) \frac{  x_i' \gamma  \times (\tilde \varepsilon_i -1\big)}{\bar x_i'\gamma}
\end{aligned}
 $ <eq-ifs> #set math.equation(numbering: none)

The different types of Standard errors estimation, thus, depend on the assumptions imposed for the estimation of $V lr((theta))$.

=== Robust Standard Errors
<robust-standard-errors>
The first, and most natural standard error estimator is given by equation @eq-eqvcv. This is equivalent to the Eicker-White Heteroskedastic-Consistent estimator for least-squares estimators. Considering the location-scale model, the variance-covariance matrix for the quantile coefficients can be estimated as:

$ hat(V)_(r o b u s t) vec(hat(beta), hat(gamma), hat(q) lr((epsilon bar.v tau))) eq 1 / N^2 mat(delim: "(", sum lambda_i lr((beta)) lambda_i lr((beta)) prime, sum lambda_i lr((beta)) lambda_i lr((gamma)) prime, sum lambda_i lr((beta)) lambda_i lr((q lr((epsilon bar.v tau)))) prime; sum lambda_i lr((gamma)) lambda_i lr((beta)) prime, sum lambda_i lr((gamma)) lambda_i lr((gamma)) prime, sum lambda_i lr((gamma)) lambda_i lr((q lr((epsilon bar.v tau)))) prime; sum lambda_i paren.l q lr((epsilon bar.v tau)) lambda_i lr((beta)) prime, sum lambda_i lr((q lr((epsilon bar.v tau)))) lambda_i lr((gamma)) prime, sum lambda_i lr((q lr((epsilon bar.v tau)))) lambda_i lr((q lr((epsilon bar.v tau)))) prime) $

This estimator of Standard errors should be robust to arbitrary heteroskedasticity. However, because the location-scale specification relies on the correct specification of the model heteroskedasticity, large differences in Standard errors compared to GLS-standard errors may be an indication of misspecification of the model.

=== Clustered Standard Errors
<clustered-standard-errors>
Because one of the typical applications of quantile regressions is the analysis of panel data, allowing for clustered standard errors at the individual level is important. If the unobserved error $epsilon$ is correlated within clusters, GLS-Standard errors could be severily biased. The standard recommendation has been to report block-bootstrap standard errors, clustering at the individual level.

Since we have access to the influence functions, it is straight forward to estimate one-way clustered standard errors.

Call $N_G$ to be the total number of clusteres g, where $g eq 1 dots.h N_G$. The clustered variance covariance matrix is given by:#footnote[It should be noted that one could just as well apply the insights of #cite("cameron_robust_2011"), allowing for multiway clustering.]

$ hat(V)_(c l u s t e r e d) vec(hat(beta), hat(gamma), hat(q) lr((epsilon bar.v tau))) eq 1 / N^2 vec(sum_(g eq 1)^(N_G) S lambda_i lr((theta)) S lambda_i lr((theta)) prime) $

Where $S lambda_i lr((theta))$ is the sum of the influence functions over all observations within a given cluster $g$.

$ S lambda_i lr((theta)) eq sum_(i in g) lambda_i lr((theta)) $

=== GLS Standard Errors
<gls-standard-errors>
The standard errors proposed by MSS can be understood as an application of generalized least squares (GLS), which will be valid as long as the model for heteroskedasticity is correctly specified.#footnote[As discussed in most econometric textbooks, like #cite("cameron2005"), one approach to correct for heteroskedasticity, when the heteroskedasticity functional form is known, or can be estimated, is to use weighted least squares. While feasible, however, this approach would defeat the purpose of identifying quantile effects exploiting the heteroskedasticity of the model.] To estimate the GLS-Standard errors, we make use of the following property:

Consider the influence functions and robust variance-covariance matrix for the location coefficients:

$ hat(V) lr((hat(beta))) & eq 1 / N sum_i^N lambda_i lr((beta)) lambda_i lr((beta)) prime\
 & eq 1 / N lr((X prime X))^(minus 1) sum_i^N x_i x_i prime lr((x_i prime gamma times epsilon_i))^2 lr((X prime X))^(minus 1)\
 $

Under the assumption that the model for heteroskedasticity is correctly specified, we can apply the law of iterated expectations and rewrite the variance-covariance matrix as:

$ hat(V) lr((hat(beta))) & eq 1 / N sum_i^N lambda_i lr((beta)) lambda_i lr((beta)) prime\
 & eq E lr((epsilon_i^2)) 1 / N lr((X prime X))^(minus 1) sum_i^N x_i x_i prime lr((x_i prime gamma))^2 lr((X prime X))^(minus 1)\
 & eq sigma_epsilon^2 1 / N lr((X prime X))^(minus 1) hat(Omega)_(beta beta) lr((X prime X))^(minus 1) $

This standard error estimator is an application of GLS that accounts for the heteroskedasticity the model uses to identify the quantile coefficients. We can apply the same principle to find the GLS-Standard errors for the system of location-scale and quantile coefficients. To do this, define the following modified influence functions:

$ tilde(lambda)_(1 comma i) & eq tilde(lambda)_(2 comma i) eq N lr((X prime X))^(minus 1) x_i lr((x_i prime gamma))\
tilde(lambda)_(3 comma i) & eq x_i prime gamma\
tilde(psi)_1 & eq epsilon_i\
tilde(psi)_2 & eq tilde(epsilon)_i minus 1\
tilde(psi)_3 & eq frac(1, x_i prime gamma) frac(tau minus bb(1) #scale(x: 120%, y: 120%)[paren.l] q lr((epsilon bar.v tau)) gt.eq epsilon_i #scale(x: 120%, y: 120%)[paren.r], f_epsilon lr((q lr((epsilon bar.v tau))))) minus frac(epsilon_i, x^(‾)_i prime gamma) minus q lr((epsilon bar.v tau)) frac(paren.l tilde(epsilon)_i minus 1 #scale(x: 120%, y: 120%)[paren.r], x^(‾)_i prime gamma) $

Then, the GLS-Standard errors for the location-scale and quantile coefficients can be estimated as:

$ hat(V)_(g l s) vec(hat(beta), hat(gamma), hat(q) lr((epsilon bar.v tau))) eq 1 / N^2 mat(delim: "(", hat(sigma)_11 hat(Omega)_11, hat(sigma)_12 hat(Omega)_12, hat(sigma)_11 hat(Omega)_13; hat(sigma)_21 hat(Omega)_21, hat(sigma)_22 hat(Omega)_22, hat(sigma)_21 hat(Omega)_23; hat(sigma)_31 hat(Omega)_31, hat(sigma)_32 hat(Omega)_32, hat(sigma)_33 hat(Omega)_33) $

where

$ hat(Omega)_(i j) & eq 1 / N sum_i^N tilde(lambda)_i lr((theta)) tilde(lambda)_j lr((theta)) prime\
hat(sigma)_(i j) & eq 1 / N sum_i^N phi.alt_i phi.alt_j $

This estimator of Standard errors is equivalent to the one derived by MSS by Theorem 3.

== Multiple Fixed Effects: Expanding on #cite("mss2019")
<multiple-fixed-effects-expanding-on-mss2019>
Using the setup described in the previous section, #cite("mss2019") proposes an extension to the model proposed by #cite("he1997") that would allow for the estimation of quantile regression models with panel data, allowing for the inclusion of individual fixed effects. However, as the authors suggest, the methodology can be generalized to allow for the inclusion of multiple fixed effects. This type of analysis may be useful when considering data such as employer-employee linked data #cite("abowed2006"), or teacher-student linked data #cite("harrissass2011"). Or, in the most common case, allowing to control for both individual and time fixed effects.

Reconsider the original model, and assume there are sets of unobserved heterogeneity that are assumed to be constant across observations, if they belong to common groups. In panel data, the groups would be the individual fixed effects and the time fixed effects. Without loss of generality, we can assume that the data generating process is as follows:

$ y_i & eq x_i prime beta plus delta_(g 1) plus delta_(g 2) plus nu_i\
nu_i & eq epsilon_i times lr((x_i prime gamma plus zeta_(g 1) plus zeta_(g 2))) $

where we assume $x_i$ vary across groups $g_1$ and $g_2$, thus are not collinear, and that $delta prime s$ and $zeta prime s$ are the location and scale effects associated with groups fixed effects.#footnote[We could just as well consider multiple sets of fixed effects]

If the dimension of groups $g_k$ is low, this model could be estimated using a dummy inclussion approach following @sec-betas, and standard errors obtained as discussed in @sec-se. However, if the dimensionality of $g_k$ is high, the dummy inclusion approach may not be feasible. Instead, a more feasible approach is to apply the Frisch-Waugh-Lovell (FWL) theorem, and partial out the impact of the group fixed effects on the control variables $x_i$, the outcome of interest $y_i$, with a similar approach for the identification of $sigma lr((x))$. In the case of unbalanced setups, with multiple groups, the estimation involves iterative processes for which various approaches have been suggested and implemented (see #cite("correia_feasible_nodate"), #cite("gaure2013"), #cite("rios2015"), among others).

When applying the partialing out approach, some modifications to the approach described in @sec-betas are needed.

+ For all dependent and independent variables in the model ($w eq y comma x$), we partial out the group fixed effects, and obtain the centered-residualized variables:

$ w_i & eq delta_(g 1)^w plus delta_(g 2)^w plus u_i^w\
w_i^(r c) & eq E lr((w_i)) plus hat(u)_i^w $

#block[
#set enum(numbering: "1.", start: 2)
+ We estimate the location model using the centered-residualized variables:#footnote[Using centered-residualized variables allow us to include a constant in the model specification, which simplifies the derivation of the influence functions. However, as with other fixed effects models, the constant is not identified, and thus should not be interpreted.]
]

$ y_i^(r c) eq x_i^(r c prime) beta plus nu_i $

#block[
#set enum(numbering: "1.", start: 3)
+ Since $lr(|hat(nu)_i|)$ is the dependent variable for the scale model, we apply the partialling out and recentering to this expression ($lr(|hat(nu)_i|)^(r c)$), and use that to estimate the model:
]

$ lr(|hat(nu)_i|)^(r c) eq x_i^(r c prime) gamma plus omega_i $

#block[
#set enum(numbering: "1.", start: 4)
+ Finally the standardized residuals $epsilon_i$ can be obtained as follows
]

$ hat(epsilon)_i eq frac(nu_i, lr(|hat(nu)_i|) minus hat(omega)_i) $

where $lr(|hat(nu)_i|) minus hat(omega)_i$ is the prediction for the conditional standard deviation $sigma lr((x_i)) eq x_i prime gamma plus zeta_(g 1) plus zeta_(g 2)$

The $tau_(t h)$ quantile of the error $epsilon$ can be estimated as usual, and the variance-covariance matrices obtained in the same way as before (see @sec-se), but using $x_i^(r c)$ instead of $x_i$ when estimating the influence functions for all estimated coefficients.

= Simulation Evidence
<simulation-evidence>
To show the performance of the extended strategy, we implement the results of a small simulation study. We consider a simple model with a single explanatory variable $x$, and a single fixed effect $g$. The data generating process is as follows:

= Illustrative application
<illustrative-application>
In this section we replicate one of the excercises from MSS, allowing for time and individual fixed effects, as well as for different standard errors estimations. We use data from #cite("persson_economic_2005"), to estimate the relationship between surplus of goverment as share of GDP, and a measure of quality of democracy (POLITY); log of real income per capita (LYP); trade volume as share of GDP (TRADE), Share of population between 15-65 uears of age (P1564), the share of the population 65 years or older (P65); one-year lag of the dependent variable (LSP); oil prices in US dollars differntiating importer and exported countries (OILIM and OILEX); and the output gap (YGAP). In addition to country fixed effects (as illustrated in MSS), we also show results allowing for time fixed effects. @tbl-tb1 and @tbl-tb2 provide the results for the model with and without time fixed effects, respectively. It show cases the location and scale coefficients, as well as the quantile coefficients for the 25th, 50th and 75th quantiles. We also report GLS-Standard errors, Robust standard errors (brackets) and clustered standard errors at the country level.

#figure([
#align(center)[#table(
  columns: 10,
  align: (col, row) => (auto,center,center,center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [], [polityt], [lyp], [trade], [p1564], [p65], [lspl], [oil\_im], [oil\_ex], [ygap],
  [Location],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.116],
  [-0.715],
  [0.030],
  [0.121],
  [0.028],
  [0.691],
  [-0.047],
  [-0.006],
  [0.010],
  [~se\_gls],
  [0.046],
  [0.540],
  [0.008],
  [0.033],
  [0.070],
  [0.035],
  [0.008],
  [0.022],
  [0.028],
  [~se\_r],
  [0.047],
  [0.597],
  [0.008],
  [0.031],
  [0.070],
  [0.037],
  [0.007],
  [0.017],
  [0.021],
  [~se\_cl],
  [0.046],
  [0.465],
  [0.007],
  [0.032],
  [0.071],
  [0.035],
  [0.010],
  [0.020],
  [0.023],
  [Scale],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [-0.097],
  [-0.616],
  [0.003],
  [0.036],
  [0.087],
  [-0.085],
  [0.013],
  [0.016],
  [-0.004],
  [~se\_gls],
  [0.032],
  [0.371],
  [0.005],
  [0.023],
  [0.048],
  [0.024],
  [0.006],
  [0.015],
  [0.019],
  [~se\_r],
  [0.031],
  [0.398],
  [0.005],
  [0.020],
  [0.049],
  [0.025],
  [0.005],
  [0.010],
  [0.015],
  [~se\_cl],
  [0.048],
  [0.800],
  [0.008],
  [0.031],
  [0.067],
  [0.029],
  [0.004],
  [0.010],
  [0.012],
  [Q25],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.191],
  [-0.239],
  [0.028],
  [0.093],
  [-0.039],
  [0.756],
  [-0.057],
  [-0.018],
  [0.013],
  [~se\_gls],
  [0.059],
  [0.684],
  [0.010],
  [0.042],
  [0.088],
  [0.045],
  [0.010],
  [0.027],
  [0.035],
  [~se\_r],
  [0.056],
  [0.656],
  [0.008],
  [0.036],
  [0.086],
  [0.040],
  [0.010],
  [0.020],
  [0.025],
  [~se\_cl],
  [0.073],
  [0.687],
  [0.006],
  [0.041],
  [0.098],
  [0.023],
  [0.010],
  [0.021],
  [0.029],
  [Q50],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.108],
  [-0.765],
  [0.030],
  [0.124],
  [0.035],
  [0.684],
  [-0.046],
  [-0.005],
  [0.009],
  [~se\_gls],
  [0.046],
  [0.535],
  [0.007],
  [0.033],
  [0.069],
  [0.035],
  [0.008],
  [0.022],
  [0.027],
  [~se\_r],
  [0.046],
  [0.593],
  [0.008],
  [0.031],
  [0.069],
  [0.036],
  [0.007],
  [0.017],
  [0.021],
  [~se\_cl],
  [0.043],
  [0.484],
  [0.008],
  [0.032],
  [0.070],
  [0.036],
  [0.010],
  [0.020],
  [0.023],
  [Q75],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.031],
  [-1.258],
  [0.033],
  [0.153],
  [0.104],
  [0.616],
  [-0.036],
  [0.008],
  [0.006],
  [~se\_gls],
  [0.048],
  [0.551],
  [0.008],
  [0.034],
  [0.071],
  [0.036],
  [0.008],
  [0.022],
  [0.028],
  [~se\_r],
  [0.049],
  [0.696],
  [0.009],
  [0.034],
  [0.075],
  [0.043],
  [0.007],
  [0.018],
  [0.023],
  [~se\_cl],
  [0.039],
  [0.919],
  [0.012],
  [0.041],
  [0.079],
  [0.055],
  [0.010],
  [0.022],
  [0.020],
)
]

], caption: figure.caption(
position: top, 
[
The determinants of government surpluses: Individual Fixed effects
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-tb1>


As expected, @tbl-tb1 shows that point estimates for the point estimates for the quantile regressions are identical to the ones reported in #cite("mss2019") (table 6), including analytical standard errors (GLS). With our estimator, however, we are able to also produce both robust and clustered standard errors for location and scale coefficients. Except for few cases, Robust and Clustered standard errors are larger than GLS standard errors, which may be an indication of misspecification of the model. The GLS standard errors we report differ from the ones in MSS, because they use panel standard errors, equivalent to our clustered standard errors, instead of the analytical standard errors we derive.

Considering the estimated effects across quantiles, we observe few differences in the reported GLS standard errors compared to the analytical standard errors reported MSS. Our clustered standard errors, however, are closer to the bootstrap based standard errors the authors report.#footnote[There are two possible reasons that may explain the differences in the GLS standard errors. On the one hand, in our derivation, the influence function of the standardized $tau_(t h)$ quantile (see \#eq-infs) does not have the same leading term as the one reported in MSS (see theorem 3, and the definition of $W$).]

In @tbl-tb2, we report the results including both individual and year fixed effects. Because Oil prices only vary across years, the variableis excluded from the model specification. Accounting for time fixed effects, does not change the general conclusions one could make based no the results from @tbl-tb1. The two largest differences are that the log of income percapita has a positive effect on Goverment Surpluses, but only for the 25th quantile, because of the largest impact on the Scale component. Similarly, we observe that the income gap now has an impact on Goverment surplus that is always negative, but increasing across quantiles. In both instances, the effects are not statistically significant.

#figure([
#align(center)[#table(
  columns: 8,
  align: (col, row) => (auto,center,center,center,center,center,center,center,).at(col),
  inset: 6pt,
  [], [polity], [lyp], [trade], [prop1564], [prop65], [lspl], [ygap],
  [Location],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.126],
  [-0.418],
  [0.028],
  [0.108],
  [0.042],
  [0.693],
  [-0.014],
  [~se\_gls],
  [0.087],
  [1.157],
  [0.015],
  [0.072],
  [0.136],
  [0.066],
  [0.053],
  [~se\_r],
  [0.047],
  [0.703],
  [0.008],
  [0.038],
  [0.068],
  [0.038],
  [0.022],
  [~se\_cl],
  [0.048],
  [0.506],
  [0.008],
  [0.044],
  [0.077],
  [0.037],
  [0.022],
  [Scale],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [-0.095],
  [-1.255],
  [0.005],
  [0.033],
  [0.040],
  [-0.081],
  [0.008],
  [~se\_gls],
  [0.081],
  [1.073],
  [0.014],
  [0.067],
  [0.126],
  [0.061],
  [0.049],
  [~se\_r],
  [0.031],
  [0.452],
  [0.005],
  [0.025],
  [0.045],
  [0.025],
  [0.017],
  [~se\_cl],
  [0.041],
  [0.848],
  [0.006],
  [0.030],
  [0.048],
  [0.033],
  [0.013],
  [Q25],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.201],
  [0.576],
  [0.025],
  [0.082],
  [0.010],
  [0.757],
  [-0.020],
  [~se\_gls],
  [0.154],
  [2.070],
  [0.024],
  [0.118],
  [0.219],
  [0.121],
  [0.085],
  [~se\_r],
  [0.058],
  [0.751],
  [0.008],
  [0.049],
  [0.080],
  [0.040],
  [0.026],
  [~se\_cl],
  [0.073],
  [0.761],
  [0.006],
  [0.052],
  [0.087],
  [0.023],
  [0.027],
  [Q50],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.119],
  [-0.512],
  [0.029],
  [0.111],
  [0.045],
  [0.687],
  [-0.013],
  [~se\_gls],
  [0.091],
  [1.230],
  [0.014],
  [0.070],
  [0.130],
  [0.072],
  [0.051],
  [~se\_r],
  [0.046],
  [0.695],
  [0.008],
  [0.037],
  [0.068],
  [0.038],
  [0.022],
  [~se\_cl],
  [0.045],
  [0.529],
  [0.008],
  [0.044],
  [0.077],
  [0.039],
  [0.021],
  [Q75],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [~coeff],
  [0.041],
  [-1.555],
  [0.033],
  [0.138],
  [0.078],
  [0.619],
  [-0.007],
  [~se\_gls],
  [0.067],
  [0.898],
  [0.011],
  [0.053],
  [0.098],
  [0.052],
  [0.038],
  [~se\_r],
  [0.048],
  [0.827],
  [0.009],
  [0.037],
  [0.075],
  [0.046],
  [0.026],
  [~se\_cl],
  [0.038],
  [0.980],
  [0.012],
  [0.050],
  [0.086],
  [0.063],
  [0.020],
)
]

], caption: figure.caption(
position: top, 
[
The determinants of government surpluses: Individual and Time Fixed effects
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-tb2>


= Conclusions
<conclusions>
= Appendix {.appendix}
<sec-appendix>
== Model Identification
<model-identification>
The estimation of quantile regression via moments assumes that the DGP is linear in parameters, with an heteroskedastic error term that is also linear function of parameters:

$ y eq x beta plus nu\
nu eq epsilon times x gamma $

where $epsilon$ is an unobserved i.i.d. random variable that is independent of $x$, and such that $x gamma$ is larger than zero for any $x$.

In this case, the $tau_(t h)$ conditional quantile model can be written as:

$ q lr((y bar.v tau comma X)) eq x lr((beta plus q lr((epsilon bar.v tau)) times gamma)) $

This model is identified under the following conditions:

$ E lr([lr((y_i minus x_i prime beta)) x_i]) & eq E lr([h_(1 comma i)]) eq 0\
E lr([lr((lr(|y_i minus x_i prime beta|) minus x_i prime gamma)) x_i]) & eq E lr([h_(2 comma i)]) eq 0\
E lr([bb(1) lr((q lr((epsilon bar.v tau)) x_i prime gamma plus x_i prime beta gt.eq y_i)) minus tau]) & eq E lr([h_(3 comma i)]) eq 0 $

For simplicity, for the rest of the appendix, I will use $q_tau^epsilon$ to represent $q lr((epsilon bar.v tau))$.

== Estimation of the variance-covariance matrix
<estimation-of-the-variance-covariance-matrix>
In this model, to estimate the variance-covariance matrix the set of coefficients $theta prime eq lr([beta prime med gamma prime med q_tau^epsilon])$, we need to obtain the influence functions of all coefficients, which are defined as:

$ lambda_i eq G^(‾) lr((theta))^(minus 1) mat(delim: "[", h_(1 comma i); h_(2 comma i); h_(3 comma i)) $

where the Jacobian matrix $G^(‾) lr((theta))$ is defined as:

$ G^(‾) lr((theta)) eq mat(delim: "[", G^(‾)_11, G_12, G_13; G^(‾)_21, G^(‾)_22, G_23; G^(‾)_31, G^(‾)_32, G^(‾)_13; #none) $

with

$ G^(‾)_(j comma k) eq minus 1 / N sum_(i eq 1)^N frac(diff h_(j comma i), diff theta_k prime) med forall j comma k in 1 comma 2 comma 3 $

=== First Moment Condition: Location Model
<first-moment-condition-location-model>
$ h_(1 comma i) eq x_i lr((y_i minus x_i prime beta)) $

$ G^(‾)_(1 comma 1) & eq minus 1 / N sum_(i eq 1)^N frac(diff h_(1 comma i), diff beta prime)\
 & eq minus 1 / N sum_(i eq 1)^N lr((minus x_i x_i prime))\
 & eq N^(minus 1) X prime X $

$ G^(‾)_(1 comma 2) eq G^(‾)_(1 comma 3) eq 0 $

=== Second Moment Condition: Scale model
<second-moment-condition-scale-model>
$ h_(2 comma i) eq x_i lr((lr(|y_i minus x_i prime beta|) minus x_i prime gamma)) $

$ G^(‾)_(2 comma 1) & eq minus 1 / N sum frac(diff h_(2 comma i), diff beta prime)\
 & eq 1 / N sum x_i x_i prime frac(y_i minus x_i prime beta, lr(|y_i minus x_i prime beta|))\
frac(y_i minus x_i prime beta, lr(|y_i minus x_i prime beta|)) & eq s i g n lr((y_i minus x_i prime beta))\
 $

Under the assumption $epsilon_i times x gamma$, or in this case $y_i minus x_i prime beta$, is uncorrelated with $x$, we can simplify the expression as:

$ G^(‾)_(2 comma 1) & eq N^(minus 1) lr((N^(minus 1) sum s i g n lr((y_i minus x_i prime beta)))) sum x_i x_i prime\
 & eq N^(minus 1) E lr([s i g n lr((y_i minus x_i prime beta))]) X prime X $

$ G^(‾)_(2 comma 2) & eq minus 1 / N sum frac(diff h_(2 comma i), diff gamma prime)\
 & eq 1 / N sum x_i x_i prime & eq N^(minus 1) X prime X $

$ G^(‾)_(2 comma 3) eq 0 $

=== Third Moment Condition: Quantile of Standardized Residual
<third-moment-condition-quantile-of-standardized-residual>
$ h_(3 comma i) & eq bb(1) lr((q_tau^epsilon x_i prime gamma plus x_i prime beta minus y_i gt.eq 0)) minus tau upright(" or")\
h_(3 comma i) & eq bb(1) lr((q_tau^epsilon gt.eq frac(y_i minus x_i prime beta, x_i prime gamma))) minus tau eq bb(1) #scale(x: 120%, y: 120%)[paren.l] q_tau^epsilon gt.eq epsilon #scale(x: 120%, y: 120%)[paren.r] minus tau\
 $

Because the indicator function $bb(1) lr(())$ is not differentiable, we borrow from the non-parametric literature, and approximate the indicator function with the integral of a kernel density function $I lr(())$. This function $I lr(())$, is monotonic and symetrical function around zero, with a domain over the real numbers, and a range between 0 and 1.

With an arbirarily small bandwidth $h$, this function will approximate the indicator function:

$ lim_(h arrow.r 0) I lr((z / h)) approx bb(1) lr((z gt.eq 0)) $

Thus the function $h_(3 comma i)$ can be approximated as:

$ h_(3 comma i) approx I lr((q_tau^epsilon x_i prime gamma plus x_i prime beta minus y_i)) minus tau $

Now, we can obtain the Jacobian matrix $G^(‾)_(3 comma 1)$ as:

$ G^(‾)_(3 comma 1) & eq minus 1 / N sum frac(diff h_(3 comma i), diff beta prime)\
 & eq minus N^(minus 1) sum K_h lr((q_tau^epsilon x_i prime gamma plus x_i prime beta minus y_i)) x_i prime $

Under the assumption that we have enough observations within each combination of $x$, and of multiplicative heteroskedasticity, we have:

$ E lr((K_h lr((q_tau^epsilon x_i prime gamma plus x_i prime beta minus y_i)) bar.v X)) & eq f_(y bar.v X) lr((q_tau^epsilon x_i prime gamma plus x_i prime beta))\
 & eq frac(1, x_i prime gamma) f_epsilon lr((q_tau^epsilon))\
 $

where $f_(y bar.v X)$ is the conditional probability density function of $y$ given $X$, and $f_epsilon$ is the unconditional distribution of the standardized error. With this, we can rewrite the Jacobian matrix as:

$ G^(‾)_(3 comma 1) eq minus N^(minus 1) f_epsilon #scale(x: 120%, y: 120%)[paren.l] q_tau^epsilon #scale(x: 120%, y: 120%)[paren.r] sum frac(x_i prime, x_i prime gamma) $

Asymptotically, however, the expression $sum a_i / b_i$ can be approximated using taylor expansions by $N a^(‾) / b^(‾)$. #footnote[This approximation will be useful when we consider the estimation of the influence functions.] Thus, we can rewrite the last term as:

$ G^(‾)_(3 comma 1) eq minus f_epsilon #scale(x: 120%, y: 120%)[paren.l] q_tau^epsilon #scale(x: 120%, y: 120%)[paren.r] frac(x^(‾)_i prime, x^(‾)_i prime gamma) $

The Jacobian for the second matrix $G^(‾)_(3 comma 2)$ can be derived similarly:

$ G^(‾)_(3 comma 2) & eq minus 1 / N sum frac(diff h_(3 comma i), diff gamma prime)\
 & eq minus N^(minus 1) sum K_h lr((q_tau^epsilon x_i prime gamma plus x_i prime beta minus y_i)) q_tau^epsilon x_i prime\
 & eq minus N^(minus 1) sum f_(y bar.v x) lr((q_tau^epsilon x_i prime gamma plus x_i prime beta)) q_tau^epsilon x_i prime\
 & eq minus N^(minus 1) f_epsilon lr((q_tau^epsilon)) q_tau^epsilon sum frac(x_i prime, x_i prime gamma)\
 & eq minus f_epsilon lr((q_tau^epsilon)) q_tau^epsilon frac(x^(‾)_i prime, x^(‾)_i prime gamma) $

and the Jacobian for the third matrix $G^(‾)_(3 comma 3)$ is:

$ G^(‾)_(3 comma 3) & eq minus 1 / N sum frac(diff h_(3 comma i), diff q_tau^epsilon)\
 & eq minus 1 / N sum K_h lr((q_tau^epsilon x_i prime gamma plus x_i prime beta minus y_i)) x_i prime gamma\
 & eq minus 1 / N sum f_(y bar.v X) lr((q_tau^epsilon x_i prime gamma plus x_i prime beta)) x_i prime gamma\
 & eq minus 1 / N sum f_epsilon lr((q_tau^epsilon)) frac(x_i prime gamma, x_i prime gamma)\
 & eq minus f_epsilon lr((q_tau^epsilon)) $

== Influence functions
<influence-functions>
=== Location coefficients
<location-coefficients>
$ lambda_i lr((beta)) eq G^(‾)_(1 comma 1)^(minus 1) h_(1 comma i) eq N lr((X prime X))^(minus 1) lr((x_i lr((y_i minus x_i prime beta)))) eq N lr((X prime X))^(minus 1) lr((x_i nu_i)) $

Which can also be written as a function of the standardized residuals:

$ lambda_i lr((beta)) eq G^(‾)_(1 comma 1)^(minus 1) h_(1 comma i) eq N lr((X prime X))^(minus 1) lr((x_i lr((y_i minus x_i prime beta)))) eq N lr((X prime X))^(minus 1) lr((x_i lr((x_i prime gamma times epsilon)))) $

=== Scale Coefficients coefficients\*\*
<scale-coefficients-coefficients>
$ lambda_i lr((gamma)) & eq G^(‾)_(2 comma 2)^(minus 1) #scale(x: 180%, y: 180%)[paren.l] h_(2 comma i) minus G^(‾)_(2 comma 1) lambda_i lr((beta)) #scale(x: 180%, y: 180%)[paren.r]\
 & eq N lr((X prime X))^(minus 1) #scale(x: 180%, y: 180%)[paren.l] x_i lr((lr(|nu_i|) minus x_i prime gamma)) minus N^(minus 1) E lr([s i g n lr((nu_i))]) X prime X #scale(x: 120%, y: 120%)[bracket.l] N lr((X prime X))^(minus 1) lr((x_i nu_i)) #scale(x: 120%, y: 120%)[bracket.r] #scale(x: 180%, y: 180%)[paren.r]\
 & eq N lr((X prime X))^(minus 1) #scale(x: 180%, y: 180%)[paren.l] x_i lr((lr(|nu_i|) minus x_i prime gamma)) minus E lr([s i g n lr((nu_i))]) lr((x_i nu_i)) #scale(x: 180%, y: 180%)[paren.r]\
 & eq N lr((X prime X))^(minus 1) x_i #scale(x: 180%, y: 180%)[paren.l] lr(|nu_i|) minus E lr([s i g n lr((nu_i))]) nu_i minus x_i prime gamma #scale(x: 180%, y: 180%)[paren.r] $

However,

$ lr(|nu_i|) & eq nu_i times bb(1) lr((nu_i gt.eq 0)) minus nu_i times bb(1) lr((nu_i lt 0))\
lr(|nu_i|) & eq nu_i times bb(1) lr((nu_i gt.eq 0)) minus nu_i times lr([1 minus bb(1) lr((nu_i gt.eq 0))])\
lr(|nu_i|) & eq 2 nu_i times bb(1) lr((nu_i gt.eq 0)) minus nu_i $

And $ E lr([s i g n lr((nu_i))]) & eq E lr([bb(1) lr((nu_i gt.eq 0))]) minus E lr([bb(1) lr((nu_i lt 0))])\
E lr([s i g n lr((nu_i))]) & eq E lr([bb(1) lr((nu_i gt.eq 0))]) minus E lr([lr((1 minus bb(1) lr((nu_i gt.eq 0))))])\
E lr([s i g n lr((nu_i))]) & eq 2 E lr([bb(1) lr((nu_i gt.eq 0))]) minus 1 $

Thus,

$ lambda_i lr((gamma)) & eq N lr((X prime X))^(minus 1) x_i #scale(x: 180%, y: 180%)[paren.l] 2 nu_i times bb(1) lr((nu_i gt.eq 0)) minus nu_i minus lr((2 E lr([bb(1) lr((nu_i gt.eq 0))]) minus 1)) nu_i minus x_i prime gamma #scale(x: 180%, y: 180%)[paren.r]\
 & eq N lr((X prime X))^(minus 1) x_i #scale(x: 180%, y: 180%)[paren.l] 2 nu_i times bb(1) lr((nu_i gt.eq 0)) minus 2 E lr([bb(1) lr((nu_i gt.eq 0))]) nu_i minus x_i prime gamma #scale(x: 180%, y: 180%)[paren.r]\
 & eq N lr((X prime X))^(minus 1) x_i #scale(x: 180%, y: 180%)[paren.l] 2 nu_i times #scale(x: 120%, y: 120%)[bracket.l] bb(1) lr((nu_i gt.eq 0)) minus E lr([bb(1) lr((nu_i gt.eq 0))]) #scale(x: 120%, y: 120%)[bracket.r] minus x_i prime gamma #scale(x: 180%, y: 180%)[paren.r]\
 & eq N lr((X prime X))^(minus 1) x_i #scale(x: 180%, y: 180%)[paren.l] tilde(nu)_i minus x_i prime gamma #scale(x: 180%, y: 180%)[paren.r] $

This last expression is the equivalent simplification used in #cite("mss2019") and #cite("im2000"). If the scale function is strictly possitive, it also follows that $bb(1) lr((nu_i gt.eq 0)) eq bb(1) lr((epsilon_i gt.eq 0))$. Thus, it can be simplified as:

$ lambda_i lr((gamma)) & eq N lr((X prime X))^(minus 1) x_i lr((x_i prime gamma)) times paren.l tilde(epsilon)_i minus 1 #scale(x: 120%, y: 120%)[paren.r] $

=== Quantile of standardized residual
<quantile-of-standardized-residual>
$ lambda_i lr((q_tau^epsilon)) & eq G^(‾)_(3 comma 3)^(minus 1) #scale(x: 180%, y: 180%)[paren.l] h_(3 comma i) minus G^(‾)_(3 comma 1) lambda_i lr((beta)) minus G^(‾)_(3 comma 2) lambda_i lr((gamma)) #scale(x: 180%, y: 180%)[paren.r]\
 & eq minus frac(1, f_epsilon lr((q_tau^epsilon))) times #scale(x: 300%, y: 300%)[paren.l] #scale(x: 180%, y: 180%)[paren.l] bb(1) lr((q_tau^epsilon gt.eq epsilon)) minus tau #scale(x: 180%, y: 180%)[paren.r]\
 & plus f_epsilon lr((q_tau^epsilon)) frac(x^(‾)_i prime, x^(‾)_i prime gamma) N lr((X prime X))^(minus 1) x_i lr((x_i prime gamma times epsilon))\
 & plus f_epsilon lr((q_tau^epsilon)) q_tau^epsilon frac(x^(‾)_i prime, x^(‾)_i prime gamma) N lr((X prime X))^(minus 1) x_i #scale(x: 120%, y: 120%)[paren.l] tilde(nu)_i minus x_i prime gamma #scale(x: 120%, y: 120%)[paren.r] #scale(x: 300%, y: 300%)[paren.r]\
 & eq frac(tau minus bb(1) #scale(x: 120%, y: 120%)[paren.l] q_tau^epsilon gt.eq epsilon #scale(x: 120%, y: 120%)[paren.r], f_epsilon lr((q_tau^epsilon))) minus frac(x_i prime gamma times epsilon_i, x^(‾)_i prime gamma) minus q_tau^epsilon frac(tilde(nu)_i minus x_i prime gamma, x^(‾)_i prime gamma) $

= References
<references>



#bibliography("bibliography.bib")

