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
  opkod = " FXL30| FXL60",
  valsclass = "fac",
  warnings = FALSE
)

lvad2014 <- patregrsdata %>%
  mutate(
    dev = str_detect(OP_all, " FXL00"),
    exdev = str_detect(OP_all, " FXM0")
  ) %>%
  select(lopnr, dev, exdev, INDATUM)

lvad20142 <- full_join(lvad2014 %>% filter(dev) %>% rename(devdtm = INDATUM) %>% select(-exdev),
  lvad2014 %>% filter(exdev) %>% rename(exdevdtm = INDATUM) %>% select(-dev),
  by = c("lopnr")
) %>%
  mutate(
    diff = as.numeric(exdevdtm - devdtm),
    lvad = case_when(
      is.na(exdev) ~ 1,
      diff < 0 ~ 1,
      diff >= 120 ~ 1,
      TRUE ~ 0
    )
  ) %>%
  filter(lvad == 1) %>%
  group_by(lopnr) %>%
  arrange(devdtm) %>%
  slice(1) %>%
  ungroup() %>%
  select(lopnr, lvad, devdtm)

rsdata <- left_join(rsdata,
  lvad20142,
  by = "lopnr"
) %>%
  mutate(
    lvad = if_else(devdtm <= shf_indexdtm & !is.na(devdtm), 1, 0),
    sos_com_lvad = ynfac(if_else(sos_com_lvad == "Yes" | lvad == 1, 1, 0))
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
  opkod = " FXL30| FXL60",
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
