#FROM ucsdets/rstudio-notebook:2023.2-stable
FROM ghcr.io/ucsd-ets/rstudio-notebook:2025.1-stable

USER root

RUN R -e "install.packages('QuantPsych', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('car', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('rockchalk', repos='http://cran.rstudio.com/')"

RUN R -e "update.packages(ask = FALSE, repos = 'http://cran.rstudio.com/')"

USER jovyan
