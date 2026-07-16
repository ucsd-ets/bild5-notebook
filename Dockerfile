FROM ghcr.io/ucsd-ets/rstudio-notebook:2025.1-stable

USER root

# --- R packages installed for ALL students --------------------------------

# Everything installed here goes into the image's SYSTEM library (owned by
# root, read-only to students). This is the right place for anything the
# course depends on, so no student ever has to install it themselves.
#
# To ADD a package: copy one of the lines below, change the package name, and
# add a trailing "&& \" to every line except the last real command. All lines
# are chained into a single RUN so the image stays as one layer (see
# additional-information.md, "Keep your images small").
#
#   Example -- adding 'tidyverse':
#     R -e "install.packages('tidyverse', repos='http://cran.rstudio.com/')" && \
#
# Notes:
#   * If a package needs a system library to compile (e.g. libxml2, libgdal),
#     add an "apt-get update && apt-get install -y <lib>" RUN block ABOVE this
#     one, still under USER root. CRAN alone won't pull system-level deps.
#   * If CRAN can't provide a package, use conda-forge instead, e.g.:
#       RUN conda install -c conda-forge r-<package>
#     (slower builds; prefer install.packages when possible.)
#   * Students can still install their own packages at runtime; those land in
#     their personal library under ~/R and persist. Baking a package here just
#     means nobody has to.
RUN R -e "install.packages('QuantPsych', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('car', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('rockchalk', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('kableExtra', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('forecast', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('broom', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('ggrepel', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('palmerpenguins', repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('vegan', repos='http://cran.rstudio.com/')" && \
    R -e "update.packages(ask = FALSE, repos = 'http://cran.rstudio.com/')"

# --- Deploy sentinel -------------------------------------------------------
# Bump BILD5_BUILD each time you want to confirm a push reached DataHub.
# Verify inside RStudio (Terminal tab):  cat /opt/bild5/BUILD_INFO.txt
ARG BILD5_BUILD=test-1
RUN mkdir -p /opt/bild5 && \
    printf 'BILD5 image build marker\nversion: %s\nbuilt: %s\n' "$BILD5_BUILD" "$(date -u)" \
        > /opt/bild5/BUILD_INFO.txt

# --- Simplified RStudio layout (system-wide default for all students) ------
# Lives at /etc/rstudio (outside the persistent /home/jovyan mount) so it is
# not shadowed. Acts as a default; students can still change it themselves.
COPY rstudio-prefs.json /etc/rstudio/rstudio-prefs.json
RUN chmod 0644 /etc/rstudio/rstudio-prefs.json

USER jovyan
