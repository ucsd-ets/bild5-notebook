FROM ucsdets/rstudio-notebook:2023.2-stable

USER root

RUN R -e "install.packages('QuantPsych', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('car', repos='http://cran.rstudio.com/')"

RUN R -e "update.packages(ask = FALSE, repos = 'http://cran.rstudio.com/')"

USER jovyan
