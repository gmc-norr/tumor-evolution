FROM rocker/tidyverse:4

RUN \
    apt-get -y update && \
    apt-get -y install libxt-dev
RUN \
    Rscript -e 'install.packages(c("docopt", "ggrepel", "here", "rmarkdown", "kableExtra", "knitr", "tinytex"))' && \
    Rscript -e 'tinytex::install_tinytex(); tinytex::tlmgr_update()'
RUN ~/bin/tlmgr install \
        multirow \
        wrapfig \
        colortbl \
        pdflscape \
        tabu \
        varwidth \
        threeparttable \
        threeparttablex \
        environ \
        trimspaces \
        ulem \
        makecell \
        extsizes
RUN mkdir /tumor_evolution

ADD tumor_evolution.R /tumor_evolution/tumor_evolution_report.R
ADD report_template.qmd /tumor_evolution/report_template.qmd
WORKDIR /tumor_evolution

ENTRYPOINT ["Rscript", "tumor_evolution_report.R"]

LABEL version="0.1.1"
LABEL description="Visualisation of tumor evolution at Norrlands Universitetssjukhus"
