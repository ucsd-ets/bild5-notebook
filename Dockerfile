FROM ucsdets/rstudio-notebook:2023.2-stable

USER root

RUN R -e "update.packages(ask = FALSE, repos = 'http://cran.rstudio.com/')"

USER jovyan
