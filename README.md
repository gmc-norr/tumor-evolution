# Visualisation of tumor evolution

## Command line

```bash
Tumor Evolution Report

Visualise tumor evolution from variant frequencies
sampled at multiple time points.

Usage:
    tumor_evolution_report.R [--file=<xlsx>] <sheet>
    tumor_evolution_report.R (-h | --help)
    tumor_evolution_report.R --version

Options:
    -h --help       Show this message and exit
    --version       Print version
    --outdir=<path> Output directory [default: /tumor_evolution/reports]
    --file=<xlsx>   Excel file to fetch data from
                    [default: /tumor_evolution/data/follow_up_data.xlsx]
```

## Docker

There are quite a few dependencies, both R and TeX, so using Docker is recommended.
Build the image:

<!-- x-release-please-start-version -->
```bash
docker build --tag tumor-evolution:0.1.2 .
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
    tumor-evolution:0.1.2 <sheet>
```
<!-- x-release-please-end -->
