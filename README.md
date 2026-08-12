# Replication code: Daniels et al. (2019), *Journal of Clinical Tuberculosis and Other Mycobacterial Diseases*

Daniels B, Kwan A, Pai M, Das J.
"Lessons on the quality of tuberculosis diagnosis from standardized patients in China, India, Kenya, and South Africa."
*Journal of Clinical Tuberculosis and Other Mycobacterial Diseases* 2019;16:100109.

DOI: 10.1016/j.jctube.2019.100109

## What this repository contains

Code and documentation only: the three do-files that build the analysis
datasets and produce the exhibits, one author-written Stata command, and the
published table and figures.

```
do/1-master.do         Entry point: settings and globals
do/2-makedata.do       Builds the analysis datasets into constructed/
do/3-analysis.do       Produces the table and figures
ado/tableout.ado       Author-written Stata command
outputs/               Published table and figures
constructed/           Written by 2-makedata.do at run time
temp/                  Intermediate graph panels, written at run time
```

## Run order

Run the three do-files in numbered order. Start Stata in the repository root,
set `DATA_DIR` at the top of `1-master.do`, and run:

1. `do/1-master.do` sets `dir` and `DATA_DIR`, loads `ado/tableout.ado`, and
   defines the graph options the later files use. Run it first in every session.
2. `do/2-makedata.do` reads the source files and writes `meds.dta`,
   `classic.dta`, `qutub.dta`, and `sp_id.dta` into `constructed/`.
3. `do/3-analysis.do` reads those files and writes the exhibits.

| Output | Exhibit | Reads |
| --- | --- | --- |
| `outputs/t1.xls`, `t1.xlsx` | Table 1 | `constructed/classic.dta` |
| `outputs/f1.eps` | Figure 1 | `constructed/classic.dta` |
| `outputs/f2.eps` | Figure 2 | `constructed/classic.dta` |
| `outputs/f3.eps` | Figure 3 | `constructed/sp_id.dta` |
| `outputs/f4.eps` | Figure 4 | `constructed/qutub.dta` |

### A reconstructed variable in the South Africa subset

`2-makedata.do` builds `med_any` for the South Africa subset by sorting on
antibiotic prescription and flagging the first 37 rows. This is a
mean-preserving reconstruction, written because the row-level variable could not
be shared. It reproduces the correct proportion for that subset and is valid
only for the plotted mean. The flag is not assigned to the rows that actually
carry it, so any row-level use of the variable, or any cross-tabulation against
another variable, will be wrong. The comment at that line in the code says the
same thing. Do not use it for any other analysis.

### Dependencies

`ado/` supplies `tableout`. The code also calls `tabout`, which this repository
does not ship.

## Data access

A de-identified version of the data can be requested through Zenodo. [DOI to be
added] Granted files go under `data/`.
