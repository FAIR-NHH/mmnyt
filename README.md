# mmnyt
Repo for the paper "Solidarity and Fairness in Times of Crisis" (Cappelen, Falch, Sørensen, and Tungodden)


## Organization of data processing
There are raw data in `data/raw/`, one file downloaded from the JHS
COVID-19 database, and one Stata-file from our own survey. 
The Stata files have labels from Ipsos.

In `data/scripts` there is one Stata do-file that reads and make
some initial transforms of the raw data and saves the processed
ipsos data in `data/processed/ipsos_mmnyt_processed_release.dta`. 

## Organization of analysis
There are 3 `.Rmd` files in the top level directory that prepares the
graphs and the Romano-Wolf adjusted p-values. The
`mht_interactions.Rmd`, which calculates the Romano-Wolf ajdusted
p-values using a bootstrap approach assumes that the computer to run on
has a lot of memory and computing cores (it runs fine with 32GB memory
and an AMD 16-Core X3950). If run on a more modest computer, the
"ncpus" should be set accordingly.

There are 2 `.do` files in the top level directory that outputs
the regression tables for appendix A and C in the supplementary
information. 

All graphs are saved in `.pdf` format to the `./graphs` directory and
the regression tables, in `.tex` format, are saved to the `./tables`
directory. 

The descriptive statistics (S1) and the tables with Romano-Wolf
adjusted p-velues (S15-S20) have been manually entered from numbers
in the log files.



