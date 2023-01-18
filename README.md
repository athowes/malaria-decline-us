# malaria-decline-us

The aim of this analysis is to determine which factors are associated with (or optimistically caused) the decline of malaria in the United States.
Example covariates include urbanisation, drainage and socio-economic factors.

## File structure

The directories of this repository are:

| Directory   | Contains |
|-------------|--------------|
| `make`      | Scripts used to run the reports. `_make.R` runs everything in order. |
| `src`       | All `orderly` reports. |
| `utils`     | Helper scripts for common development tasks. |

## `orderly`

We use the [`orderly`](https://github.com/vimc/orderly) package ([RESIDE, 2020](https://reside-ic.github.io/)) to simplify the process of doing reproducible research.
After installing [`orderly`](https://github.com/vimc/orderly) (from either CRAN or Github) a report, let's say called `example`, may be run by:

```r
orderly::orderly_run(name = "src/example")
```

The results of this run will appear in the `draft/` folder (ignored on Github).
To commit the draft (with associated `id`) to the `archive/` folder (also ignored on Github, and which should be treated as "read only") use:

```r
orderly::orderly_commit(id)
```

Any outputs of this report will then be available to use as dependencies within other reports.

## R package dependencies

The `R-INLA` package is not currently available on CRAN, and instead may be installed by following [instructions](https://www.r-inla.org/download-install) from the project website.
