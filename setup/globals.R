# default is to use tidyverse functions
select <- dplyr::select
rename <- dplyr::rename
filter <- dplyr::filter
mutate <- dplyr::mutate
complete <- tidyr::complete

shfdbpath <- "P:/k2_stat_heartfailure/Projects/20210525_shfdb4/dm/"
datadate <- "20240423"

# used for calculation of ci
global_z05 <- qnorm(1 - 0.025)

global_cols <- RColorBrewer::brewer.pal(7, "Dark2")
global_shapes <- c(19, 15, 18, 17)
global_size <- c(3.5, 3.5, 5)

global_fu <- 365

global_hficd <- " I110| I130| I132| I255| I420| I423| I425| I426| I427| I428| I429| I43| I50| J81| K761| R570"
