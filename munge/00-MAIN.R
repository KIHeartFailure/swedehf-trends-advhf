# Project specific packages, functions and settings -----------------------

source(here::here("setup/setup.R"))

# Load data ---------------------------------------------------------------

load(here(shfdbpath, "data/v422/rsdata422.RData"))

# Meta data ect -----------------------------------------------------------

metavars <- read.xlsx(here(shfdbpath, "metadata/meta_variables.xlsx"))
targetdoses <- read.xlsx(here("./data/Copia di targetdoses Fede 10.09.2025_RL_LBfix.xlsx"))
load(here(paste0(shfdbpath, "data/v422/meta_statreport.RData")))

# Munge data --------------------------------------------------------------

source(here("munge/01-vars.R"))
source(here("munge/02-npr-comorbout.R"))
source(here("munge/03-pop-selection.R"))
source(here("munge/04-fix-vars.R"))

# Cache/save data ---------------------------------------------------------

save(
  file = here("data/clean-data/rsdata.RData"),
  list = c(
    "rsdata",
    "rsdataadvhf",
    "flow",
    "tabvars",
    "outvars",
    "outcommeta",
    "deathmeta",
    "metavars",
    "targetdoses"
  )
)

# create workbook to write tables to Excel
wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, sheet = "Information")
openxlsx::writeData(wb, sheet = "Information", x = "Tables in xlsx format for tables in Statistical report: Trends in prevalence and in mortality of patients with advanced heart failure with reduced EF in Sweden between 2003 and 2022", rowNames = FALSE, keepNA = FALSE)
openxlsx::saveWorkbook(wb,
  file = here::here("output/tabs/tables.xlsx"),
  overwrite = TRUE
)

# create powerpoint to write figs to PowerPoint
figs <- officer::read_pptx()
print(figs, target = here::here("output/figs/figs.pptx"))
