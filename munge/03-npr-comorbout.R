load(file = paste0(shfdbpath, "/data/", datadate, "/patregrsdata.RData"))

# Comorbidities -----------------------------------------------------------

rsdata <- create_sosvar(
  sosdata = patregrsdata,
  cohortdata = rsdata,
  patid = lopnr,
  indexdate = shf_indexdtm,
  sosdate = INDATUM,
  opvar = OP_all,
  type = "com",
  name = "lvad",
  opkod = " FXL30| FXL60| FXL20| FXL40| FXL50",
  valsclass = "fac",
  warnings = FALSE
)

rsdata <- create_sosvar(
  sosdata = patregrsdata,
  cohortdata = rsdata,
  patid = lopnr,
  indexdate = shf_indexdtm,
  sosdate = INDATUM,
  opvar = OP_all,
  type = "com",
  name = "htx",
  opkod = " FQA00| FQA10| FQA20| FQA30| FQA40| FQA96",
  valsclass = "fac",
  warnings = FALSE
)

rsdata <- create_sosvar(
  sosdata = patregrsdata,
  cohortdata = rsdata,
  patid = lopnr,
  indexdate = shf_indexdtm,
  sosdate = INDATUM,
  opvar = OP_all,
  type = "out",
  name = "lvad",
  opkod = " FXL30| FXL60| FXL20| FXL40| FXL50",
  censdate = censdtm,
  stoptime = global_fu,
  valsclass = "fac",
  warnings = FALSE
)

rsdata <- create_sosvar(
  sosdata = patregrsdata,
  cohortdata = rsdata,
  patid = lopnr,
  indexdate = shf_indexdtm,
  sosdate = INDATUM,
  opvar = OP_all,
  type = "out",
  name = "htx",
  opkod = " FQA00| FQA10| FQA20| FQA30| FQA40| FQA96",
  censdate = censdtm,
  stoptime = global_fu,
  valsclass = "fac",
  warnings = FALSE
)

outcommeta <- bind_rows(outcommeta, metaout)
rm(metaout)
rm(patregrsdata)
