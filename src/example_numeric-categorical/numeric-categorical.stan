// A version of the Poisson distribution which works for reals as well as integers
functions {
  real xpoisson_lpdf(real y, real lambda) {
    real dens = y * log(lambda) - lambda - lgamma(y);
    return dens;
  }
}

data {
  int<lower=0> n_num; // Number data points which are numeric
  int<lower=0> n_cat; // Number data points which are categorical

  vector[n_num] y_num; // Numeric data

  int<lower=0> m_cat; // Number of categoires
  int<lower=0, upper=m_cat> c_cat[n_cat]; // Categorical data {1, 2, ..., m}

  int<lower=1, upper=n_num + n_cat> ii_num[n_num]; // Indicies of the numeric data
  int<lower=1, upper=n_num + n_cat> ii_cat[n_cat]; // Indicies of the categorical data

  vector[m_cat] lower_bound; // Lower bound of the category
  vector[m_cat] upper_bound; // Upper bound of the category
}

transformed data {
  int<lower=0> n = n_num + n_cat; // Total sample size
}

parameters {
  vector<lower=0>[n_cat] y_cat; // The imputed data points for the categorical data
  real<lower=0> lambda; // The Poisson rate parameter
}

transformed parameters {
  vector<lower=0>[n] y; // All the data together
  y[ii_num] = y_num; // The numeric data
  y[ii_cat] = y_cat; // The data that has been imputed from categorical
}

model {
  lambda ~ gamma(1, 1); // Prior on the rate parameter

  // The xPoisson likelihood
  for(i in 1:n){
    y[i] ~ xpoisson(lambda);
  }

  // Uniform priors for the constraints
  for(j in 1:n_cat){
    y_cat ~ uniform(lower_bound[c_cat], upper_bound[c_cat]);
  }
}
