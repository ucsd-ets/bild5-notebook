FROM ucsdets/rstudio-notebook:2022.3-stable

USER root

RUN R -e "update.packages(ask = FALSE, repos = 'http://cran.rstudio.com/')"

USER jovyan