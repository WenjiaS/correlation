#' @importFrom stats pt median
#' @keywords internal
.cor_test_percentage <- function(data, x, y, ci = 0.95, beta = 0.2, ...) {
  var_x <- .complete_variable_x(data, x, y)
  var_y <- .complete_variable_y(data, x, y)

  temp <- sort(abs(var_x - stats::median(var_x)))
  omhatx <- temp[floor((1 - beta) * length(var_x))]
  temp <- sort(abs(var_y - stats::median(var_y)))
  omhaty <- temp[floor((1 - beta) * length(var_y))]
  a <- (var_x - .pbos(var_x, beta)) / omhatx
  b <- (var_y - .pbos(var_y, beta)) / omhaty
  a <- ifelse(a <= -1, -1, a)
  a <- ifelse(a >= 1, 1, a)
  b <- ifelse(b <= -1, -1, b)
  b <- ifelse(b >= 1, 1, b)

  # Result
  r <- sum(a * b) / sqrt(sum(a^2) * sum(b^2))
  test <- r * sqrt((length(var_x) - 2) / (1 - r^2))
  sig <- 2 * (1 - stats::pt(abs(test), length(var_x) - 2))
  ci_vals <- cor_to_ci(r, n = length(var_x), ci = ci)

  data.frame(
    Parameter1 = x,
    Parameter2 = y,
    r = r,
    t = test,
    df = length(var_x) - 2,
    p = sig,
    CI_low = ci_vals$CI_low,
    CI_high = ci_vals$CI_high,
    Method = "Percentage Bend",
    stringsAsFactors = FALSE
  )
}




#' @keywords internal
.pbos <- function(x, beta = 0.2) {
  temp <- sort(abs(x - stats::median(x)))
  omhatx <- temp[floor((1 - beta) * length(x))]
  psi <- (x - stats::median(x)) / omhatx
  i1 <- length(psi[psi < (-1)])
  i2 <- length(psi[psi > 1])
  sx <- ifelse(psi < (-1), 0, x)
  sx <- ifelse(psi > 1, 0, sx)
  pbos <- (sum(sx) + omhatx * (i2 - i1)) / (length(x) - i1 - i2)
  pbos
}
