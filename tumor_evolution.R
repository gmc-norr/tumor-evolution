suppressPackageStartupMessages({
    library(tidyverse)
    library(here)
})

"Tumor Evolution Report

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
    --file=<xlsx>   Excel file to operate on
                    [default: /tumor_evolution/data/follow_up_data.xlsx]
" -> doc

args <- docopt::docopt(doc, version = "tumor-evolution 0.1.1")

write_log <- function(msg, type = "error") {
    writeLines(str_c(type, ": ", msg),
               con = file.path(args$outdir, str_c(args$sheet, "_error.txt")))
}

d <- readxl::read_excel(args$file,
                        sheet = args$sheet,
                        range = readxl::cell_cols("A:T"),
                        na = c("N/A", ""),
                        col_types = c(
                          rep("text", 3),
                          "date",
                          rep("text", 7),
                          rep("numeric", 5),
                          rep("text", 4)))

required_columns <- c("Archer version",
                      "Remiss",
                      "Provnr",
                      "Provtagningsdag",
                      "Material",
                      "Genomic location Archer",
                      "Ref/Alt Allel",
                      "Symbol",
                      "Trans",
                      "HGVSc",
                      "HGVSp",
                      "Sekvensdjup",
                      "AO",
                      "VAF",
                      "95 MDAF",
                      "AF outlier P Value",
                      "Bedömning",
                      "Signatur/Datum",
                      "Kommentar")

missing_columns <- required_columns[!required_columns %in% colnames(d)]
if (length(missing_columns) > 0) {
    msg <- str_c("could not find required columns: ",
                 str_c(missing_columns, collapse = ", "))
    write_log(msg)
    cleanup()
    stop(msg)
}

d <- d %>%
  fill(`Archer version`, Remiss, Provnr, Provtagningsdag, Material,
       .direction = "down") %>%
  mutate(HGVSp = str_trim(HGVSp),
         HGVSc = str_trim(HGVSc),
         Symbol = str_trim(Symbol),
         name = str_c(Symbol, HGVSp, sep = " "),
         name = forcats::fct(name),
         Bedömning = str_trim(str_to_lower(Bedömning)))

# Remove VUS, benign, and likely benign
vus <- d %>%
    filter(Bedömning %in% c("vus", "benign", "likely benign")) %>%
    with(unique(name))

variant_df <- d %>% filter(!name %in% vus)
annot_df <- d %>%
    filter(is.na(VAF), !is.na(Kommentar)) %>%
    select(Provtagningsdag, label = Kommentar)

# File name should be based on the most recent sample ID
filename_prefix <- d %>% pull(Provnr) %>% last()

cleanup <- function() {
    # TODO: add more files/directories that should be cleaned up
    files <- file.path(args$outdir, str_c(filename_prefix, ".tex"))
    walk(files, ~ {
        if (file.exists(.)) {
            unlink(.)
        }
    })
}

tryCatch({
    rmarkdown::render(here("report_template.qmd"),
                      params = list(variant_df = variant_df, annot_df = annot_df),
                      intermediates_dir = here("tmp"),
                      output_file = file.path(args$outdir, str_c(filename_prefix, ".pdf")))
}, error = function(cond) {
    write_log(cond$message)
    cleanup()
    stop(cond)
}, warning = function(cond) {
    write_log(cond$message, type = "warning")
    cleanup()
    stop(cond)
})
