These routines are designed to compute p-values adjusted for multiple
testing as described in the paper "Efficient Computation of Adjusted
p-Values for Resampling-Based Stepdown Multiple Testing".

You can load all the routines by using the following command in R:

> load("Adjust.Rdata")

(Of course, you have to first put the file Adjust.Rdata in your
current R working directory.)

There is basically only one routine for `immediate' use, namely
p.val.adj(). The other routine, p.val.raw(), is a `help' routine for
the computation of raw/unadjusted p-values.

The user has to supply a S x 1 vector of test statistics (computed
from the original data),  called t, and a M x S matrix of resampling
`null' statistics, called t.null. It is up to the user to supply:
- basic or studentized statistics
- statistics designed for the one-sided setup or for the two-sided setup
  (in the latter case, absolute values should be used everywhere)
Obviously, how the null statistics have to be computed depends on
the context (e.g. whether the data are independent or constitute a
time series). Furthermore, one could use a parametric bootstrap, a
nonparametric bootstrap, or even subsampling; various possibilities
are discussed in the paper. However, again, this task is completely up
to the user.

Further arguments are:
- digits = the precision with which the results are displayed
           (the default value is 3)

Output of the function: a S x 3 matrix that contains
- test statistics in column1 
- raw p-values in column 2
- adjusted p-values in column 3


The usual disclaimer applies.


Zurich, March 2016
Michael Wolf
