# Visualisation of tumor evolution

## Command line

```bash
Tumor Evolution Report

Visualise tumor evolution from variant frequencies
sampled at multiple time points.

Usage:
  tumor_evolution_report.R [--file=<xlsx>] [--sheet=<sheet>]
  tumor_evolution_report.R (-h | --help)
  tumor_evolution_report.R --version

Options:
  -h --help       Show this message and exit
  --version       Print version
  --outdir=<path> Output directory [default: /tumor_evolution/reports]
  --file=<xlsx>   Excel file to operate on
                  [default: /tumor_evolution/data/follow_up_data.xlsx]
  --sheet=<sheet> Sheet to operate on, either name or index (1-based)
                  [default: 1]
```

## Docker

There are quite a few dependencies, both R and TeX, so using Docker is recommended.
Build the image:

<!-- x-release-please-start-version -->
```bash
docker build --tag tumor-evolution:0.5.0 .
```
<!-- x-release-please-end -->

Generate the report.
There is one file and one directory that need to be available for this to work using default arguments:

- `/tumor_evolution/reports`: directory to save the generated reports (and/or logs; write permission needed)
- `/tumor_evolution/data/follow_up_data.xlsx`: Excel document containing the data to be visualised (preferrably read-only)

<!-- x-release-please-start-version -->
```bash
docker run \
    --rm \
    -v /path/to/data.xlsx:/tumor_evolution/data/follow_up_data.xlsx:ro \
    -v /path/to/output:/tumor_evolution/reports \
    tumor-evolution:0.5.0 [--sheet <sheet>]
```
<!-- x-release-please-end -->
