# Version 1.2
# Output has to be more 'user friendly'


mmqreg <- function(formula, data, tau = 0.5, absorb = NULL, weights = NULL,
                   vcov = "gls"){

  # Input
  yx <- model.frame(formula, data)
  y <- as.matrix(yx[, 1])
  x <- cbind(as.matrix(yx[, 2:ncol(yx)]), 1)
  n <- nrow(x)
  k <- ncol(x)

  if (is.null(weights)) {
    # No weights provided

    if (is.null(absorb)) {
      # Simple model, no weights

      xx <- crossprod(x)
      ixx <- solve(xx)

      # Location
      b <- ixx %*% crossprod(x, y)
      e <- y - x %*% b

      # Scale

      g <- ixx %*% crossprod(x, abs(e))
      xg <-  x %*% g
      se <- e/xg

      # Quantile regression

      se_qr <- quantreg::rq(se ~ 1, tau)
      qt <- se_qr[["coefficients"]]
      se_qr <- summary(se_qr, se = "iid", cov = T)
      f <- c()
      for (i in 1:length(tau)) {
        if (length(tau) == 1) {
          f[i] <- se_qr[["scale"]]
        } else {
          f[i] <- se_qr[[i]][["scale"]]
        }
      }

    } else {
      # FE model, no weights

      fe <- data[, absorb]

      # Centered residualized vars
      y <- fixest::demean(X = y, f = fe) + colMeans(y)
      x <- fixest::demean(X = x, f = fe) + matrix(colMeans(x), n, k, T)

      # Location HDFE
      xx <- crossprod(x)
      ixx <- solve(xx)
      b <- ixx %*% crossprod(x, y)
      e <- y - x %*% b

      # Scale HDFE
      erc <- fixest::demean(X = abs(e), f = fe) + colMeans(abs(e))
      g <- ixx %*% crossprod(x, erc)
      xg <- abs(e) - (erc - x %*% g)
      se <- e/xg

      # Quantile regression HDFE
      se_qr <- quantreg::rq(se ~ 1, tau)
      qt <- se_qr[["coefficients"]]
      se_qr <- summary(se_qr, se = "iid", cov = T)
      f <- c()
      for (i in 1:length(tau)) {
        if (length(tau) == 1) {
          f[i] <- se_qr[["scale"]]
        } else {
          f[i] <- se_qr[[i]][["scale"]]
        }
      }
    }

    # Influence functions, no weights
    # Helper function 'mult'
    mult <- function(x, e){
      xm <- matrix(NA, nrow = n, ncol = k)
      for (i in 1:k) {
        xm[, i] <- x[, i] * e
      }
      return(xm)
    }

    if1 <- t(n*ixx%*%t(mult(x, e)))

    vt <- 2*e*((e>=0) - mean(e>=0))
    if2 <- t(n*ixx%*%t(mult(x, vt - xg)))
    # sv <- 2*se*((se>=0) - mean(se>=0)) - 1

    ifq <- matrix(NA, n, length(tau)); dimnames(ifq)[[2]] <- dimnames(qt)[[2]]
    for (i in 1:length(tau)) {
      ifq[, i] <- 1/f[i]*(tau[i] - ((qt[i]*xg - e) >= 0)) - e/mean(xg) - qt[i]/mean(xg)*(vt - xg)
    }

    ifx <- cbind(if1, if2, ifq)

  } else {
    # Weights provided

    weights <- as.matrix(data[, weights])
    nwgt <- weights / mean(weights) # normalized wgts vector
    w <- diag(n); diag(w) <- nwgt   # normalized wgts diagonal matrix

    if (is.null(absorb)) {
      # Simple model, weights

      xx <- t(x) %*% w %*% x
      ixx <- solve(xx)

      # Location
      b <- ixx %*% t(x) %*% w %*% y
      e <- y - x %*% b

      # Scale
      g <- ixx %*% t(x) %*% w %*% abs(e)
      xg <-  x %*% g
      se <- e/xg

      # Quantile regression
      se_qr <- quantreg::rq(se ~ 1, tau, data, weights = nwgt)
      qt <- se_qr[["coefficients"]]
      se_qr <- summary(se_qr, se = "iid", cov = T)
      f <- c()
      for (i in 1:length(tau)) {
        if (length(tau) == 1) {
          f[i] <- se_qr[["scale"]]
        } else {
          f[i] <- se_qr[[i]][["scale"]]
        }
      }

    } else {
      # FE model, weights

      nwgt = as.vector(nwgt)

      fe <- data[, absorb]

      # Centered residualized vars, weights
      y <- fixest::demean(X = y, f = fe, weights = nwgt) + colMeans(y)
      x <- fixest::demean(X = x, f = fe, weights = nwgt) + matrix(colMeans(x), n, k, T)

      # Location HDFE, weights
      xx <- t(x) %*% w %*% x
      ixx <- solve(xx)
      b <- ixx %*% t(x) %*% w %*% y
      e <- y - x %*% b

      # Scale HDFE, weights
      erc <- fixest::demean(X = abs(e), f = fe, weights = nwgt) + colMeans(abs(e))
      g <- ixx %*% t(x) %*% w %*% erc
      xg <- abs(e) - (erc - x %*% g)
      se <- e/xg

      # Quantile regression HDFE, weights
      se_qr <- quantreg::rq(se ~ 1, tau, data, weights = nwgt)
      qt <- se_qr[["coefficients"]]
      se_qr <- summary(se_qr, se = "iid", cov = T)
      f <- c()
      for (i in 1:length(tau)) {
        if (length(tau) == 1) {
          f[i] <- se_qr[["scale"]]
        } else {
          f[i] <- se_qr[[i]][["scale"]]
        }
      }

    }

    # Influence functions, weights
    # Helper function 'mult'
    mult <- function(x, e){
      xm <- matrix(NA, nrow = n, ncol = k)
      for (i in 1:k) {
        xm[, i] <- x[, i] * e
      }
      return(xm)
    }

    if1 <- t(n*ixx%*%t(mult(x, e * nwgt)))

    vt <- 2*e*((e>=0) - mean(e>=0))
    if2 <- t(n*ixx%*%t(mult(x, (vt - xg) * nwgt)))
    # sv <- 2*se*((se>=0) - mean(se>=0)) - 1

    ifq <- matrix(NA, n, length(tau)); dimnames(ifq)[[2]] <- dimnames(qt)[[2]]
    for (i in 1:length(tau)) {
      ifq[, i] <- 1/f[i]*(tau[i] - ((qt[i]*xg - e) >= 0)) -
        e/mean(xg) - qt[i]/mean(xg)*(vt - xg)
      ifq[, i] <- nwgt * ifq[, i]
    }

    ifx <- cbind(if1, if2, ifq)
  }

  # Empty lists and matrices to fill in
  vcov0 <- list()
  vcov1 <- list()
  vcov2 <- list()
  se0.bt <- matrix(NA, k, length(tau), dimnames = dimnames(b))
  se1.bt <- matrix(NA, k, length(tau), dimnames = dimnames(b))
  se2.bt <- matrix(NA, k, length(tau), dimnames = dimnames(b))

  # VCOV of estimators -- GLS
  sv <- (vt/xg) - 1
  qxx <- apply(if1, 2, function(x) {x/se})         # n x k
  Pxx <- crossprod(qxx, xg)                        # k x 1
  Qxx <- crossprod(qxx)                            # k x k
  us2 <- crossprod(xg)                             # 1 x 1 (scalar)

  for (i in 1:length(tau)) {
    vcov.i <- list()                               # temp
    sw.i <- ifq[, i]/xg
    # sw[[i]] <- sw.i
    suvw.i <- cbind(se, sv, sw.i)                  # n x 3
    omgs.i <- (1/n) * crossprod(suvw.i)            # 3 x 3
    # omgs[[i]] <- omgs.i
    omg.i <- cbind(omgs.i[1:2, 1:2] %x% Qxx,
                             omgs.i[1:2, 3] %x% Pxx)
    vcov.i[[1]] <- (1/n^2) * rbind(omg.i, cbind(t(omg.i[, ncol(omg.i)]),
                                      omgs.i[3,3] * us2))
    vcov.i[[2]] <- cbind(diag(k), qt[i]*diag(k), g) # xi
    vcov.i[[3]] <- vcov.i[[2]] %*% vcov.i[[1]] %*% t(vcov.i[[2]])
    vcov0[[i]] <- vcov.i

    se0.bt[, i] <- sqrt(diag(vcov0[[i]][[3]]))
  }

  se0.b <- matrix(sqrt(diag(vcov0[[1]][[1]]))[1:k], k, 1,
                  dimnames = dimnames(b))
  se0.g <- matrix(sqrt(diag(vcov0[[1]][[1]]))[(k+1):(2*k)], k, 1,
                  dimnames = dimnames(g))


  # VCOV of estimators -- Robust

  for (i in 1:length(tau)) {
    vcov.i <- list()                                # temp
    ifx.i <- cbind(if1, if2, ifq[, i])
    vcov.i[[1]] <- crossprod(ifx.i)/n^2             # vcov theta
    vcov.i[[2]] <- cbind(diag(k), qt[i]*diag(k), g) # xi
    vcov.i[[3]] <- vcov.i[[2]] %*% vcov.i[[1]] %*% t(vcov.i[[2]])
    vcov1[[i]] <- vcov.i

    se1.bt[, i] <- sqrt(diag(vcov1[[i]][[3]]))

    #se.q[i, ] <- sqrt(diag(vcov[[i]])[2*k + 1])
  }

  se1.b <- matrix(sqrt(diag(vcov1[[1]][[1]]))[1:k], k, 1, dimnames = dimnames(b))
  se1.g <- matrix(sqrt(diag(vcov1[[1]][[1]]))[(k+1):(2*k)], k, 1, dimnames = dimnames(g))

  # VCOV of estimators -- Clustered
  if (!is.character(vcov)) {
    for (i in 1:length(tau)) {
      vcov.i <- list()                                # temp
      ifx.i <- cbind(ifx1, ifx2, ifq[, i])
      ifxg <- lapply(X = levels(vcov), FUN = function(vcov) {
        j <- data$vcov == vcov           # index
        ifxj <- t(ifx.i[j, , drop = FALSE])           # select rows that belong to cluster
        sifxj <- rowSums(ifxj)
      })

      vcov.i[[1]] <- (1/n^2)*crossprod(ifxg)
      vcov.i[[2]] <- cbind(diag(k), qt[i]*diag(k), g) # xi
      vcov.i[[3]] <- vcov.i[[2]] %*% vcov.i[[1]] %*% t(vcov.i[[2]])
      vcov2[[i]] <- vcov.i

      se2.bt[, i] <- sqrt(diag(vcov2[[i]][[3]]))
    }

    se2.b <- matrix(sqrt(diag(vcov2[[1]][[1]]))[1:k], k, 1, dimnames = dimnames(b))
    se2.g <- matrix(sqrt(diag(vcov2[[1]][[1]]))[(k+1):(2*k)], k, 1, dimnames = dimnames(g))
  }


  # Output

results <- list()

results[["location"]][["coefs"]] <- b
results[["location"]][["std. errors"]] <- cbind(se0.b, se1.b)

results[["scale"]][["coefs"]] <- g
results[["scale"]][["std. errors"]] <- cbind(se0.g, se1.g)

for (i in 1:length(tau)) {

results[[paste("tau =", tau[i])]][["coefs"]] <- b + g * qt[i]
results[[paste("tau =", tau[i])]][["std. errors"]] <- cbind(
  se0.bt[, i], se1.bt[, i])
}

return(results)
  
}
