# mmnyt
Repo for the paper "Solidarity and Fairness in Times of Crisis" (Cappelen, Falch, Sørensen, and Tungodden)


## Organization of data processing
There are raw data in `data/raw/`, one file downloaded from the JHS
COVID-19 database, and one Stata-file from our own survey. 
The Stata file from our own survey has labels provided by Ipsos.

In `data/scripts` there is one Stata do-file that reads and make
some initial transforms of the raw data and saves the processed
Ipsos data in `data/processed/ipsos_mmnyt_processed_release.dta`. 

## Organization of analysis
There are 3 `.Rmd` files in the top level directory that prepares the
graphs and the Romano-Wolf adjusted p-values. The
`mht_interactions.Rmd`, which calculates the Romano-Wolf adjusted
p-values using a bootstrap approach assumes that the computer to run on
has a lot of memory and computing cores (it runs fine with 32GB memory
and an AMD 16-Core X3950). If run on a more modest computer, the
"ncpus" should be set accordingly.

There are 2 `.do` files in the top level directory that outputs
the regression tables for appendix A based on the main 
data collection and the secondary datacollection on mTurk for the
revised version of the paper. Tables from the previous appendix C has
been incorporated in appendix A.

All graphs are saved in `.pdf` format to the `./graphs` directory and
the regression tables, in `.tex` format, are saved to the `./tables`
directory. 

The descriptive statistics (S1) and the tables with Romano-Wolf
adjusted p-values (S16-S21) have been manually entered from numbers in
the log files. The code for (and documentation of) the Romano-Wolf
procedure was kindly made available by Michael Wolf (`Adjust.Rdata`
and `Wolf-ReadMe.txt`), [at his website](https://www.econ.uzh.ch/dam/jcr:41da043f-96a2-43b9-9264-da24e6b66dc0/Adjust_R_code.zip).


## mTurk supplement
For a revision, we conducted a supplementary data collection on mTurk,
the data and analysis is kept apart in separate files, the analysis
is in the Stata do-file `mturklab_analysis.do` outputting `tables/mturklab_indic.tex` 
based on data in the `data/processed` directory.

