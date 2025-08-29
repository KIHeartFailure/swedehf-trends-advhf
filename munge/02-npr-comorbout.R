load(file = paste0(shfdbpath, "/data/", datadate, "/patregrsdata.RData"))

# Comorbidities -----------------------------------------------------------

rsdata <- rsdata422

rsdata <- create_sosvar(
  sosdata = patregrsdata,
  cohortdata = rsdata,
  patid = lopnr,
  indexdate = shf_indexdtm,
  sosdate = INDATUM,
  opvar = OP_all,
  type = "com",
  name = "lvad",
  opkod = " FXL30| FXL60",
  valsclass = "fac",
  warnings = FALSE
)

lvad2014 <- patregrsdata %>%
  mutate(
    dev = str_detect(OP_all, " FXL00"),
    exdev = str_detect(OP_all, " FXM0")
  ) %>%
  select(lopnr, dev, exdev, INDATUM) %>%
  rename(devdtm = INDATUM) %>%
  filter(dev & !exdev)

lvad20142 <- left_join(rsdata %>% select(lopnr, shf_indexdtm),
  lvad2014,
  by = "lopnr"
) %>%
  mutate(diff = as.numeric(devdtm - shf_indexdtm))

lvadcom <- lvad20142 %>%
  filter(diff <= 0) %>%
  group_by(lopnr, shf_indexdtm) %>%
  arrange(devdtm) %>%
  slice(1) %>%
  ungroup() %>%
  select(lopnr, shf_indexdtm, devdtm)

rsdata <- left_join(rsdata,
  lvadcom,
  by = c("lopnr", "shf_indexdtm")
) %>%
  mutate(
    sos_com_lvad = ynfac(if_else(sos_com_lvad == "Yes" | !is.na(devdtm), 1, 0))
  ) %>%
  select(-devdtm)


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
  opkod = " FXL30| FXL60",
  censdate = censdtm,
  stoptime = global_fu,
  valsclass = "fac",
  warnings = FALSE
)

lvadout <- lvad20142 %>%
  filter(diff > 0 & diff <= global_fu) %>%
  group_by(lopnr, shf_indexdtm) %>%
  arrange(devdtm) %>%
  slice(1) %>%
  ungroup() %>%
  select(lopnr, shf_indexdtm, diff)

rsdata <- left_join(rsdata,
  lvadout,
  by = c("lopnr", "shf_indexdtm")
) %>%
  mutate(
    sos_out_lvad = ynfac(if_else(sos_out_lvad == "Yes" | !is.na(diff), 1, 0)),
    sos_outtime_lvad = pmin(sos_outtime_lvad, diff, na.rm = T)
  ) %>%
  select(-diff)

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
