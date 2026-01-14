flow <- flow[c(1:8, 10), 1:2]
names(flow) <- c("Criteria", "N")

flow <- flow %>%
  mutate(Criteria = case_when(
    Criteria == "Exclude posts with with index date > 2023-12-31 (SwedeHF)/2021-12-31 (NPR HF, Controls)" ~ "Exclude posts with index date > 2023-12-31",
    Criteria == "Exclude posts censored end fu < index" ~ "Exclude posts with end of follow-up < index",
    Criteria == "Exclude posts with with index date < 2000-01-01" ~ "Exclude posts with index date < 2000-01-01",
    TRUE ~ Criteria
  ))

flow <- flow %>%
  add_row(
    Criteria = "General inclusion/exclusion criteria",
    N = NA, .before = 1
  )
flow <- flow %>%
  add_row(
    Criteria = "Project specific inclusion/exclusion criteria",
    N = NA
  )

# Inclusion/exclusion criteria --------------------------------------------------------

rsdata <- rsdata %>%
  filter(shf_indexyear >= 2003 & shf_indexyear <= 2022)
flow <- flow %>%
  add_row(
    Criteria = "2003-2022",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(!is.na(shf_durationhf))
flow <- flow %>%
  add_row(
    Criteria = "Exclude posts with missing HF duration",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(!is.na(shf_ef))
flow <- flow %>%
  add_row(
    Criteria = "Exclude posts with missing EF",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(!is.na(shf_nyha))
flow <- flow %>%
  add_row(
    Criteria = "Exclude posts with missing NYHA class",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(shf_durationhf == ">=6")
flow <- flow %>%
  add_row(
    Criteria = "Include posts with HF duration >= 6 months",
    N = nrow(rsdata)
  )

rsdataadvhf <- rsdata %>%
  mutate(advhf = factor(case_when(
    shf_ef %in% c("<30") &
      shf_nyha %in% c("III", "IV") &
      (sos_timeprevhosphf <= 365 / 2 & !is.na(sos_timeprevhosphf) | sos_location == "HF in-patient") &
      sos_com_htx == "No" & sos_com_lvad == "No" ~ 1,
    TRUE ~ 0
  ), levels = 0:1, labels = c("No", "Yes")))

rsdataadvhf <- rsdataadvhf %>%
  group_by(lopnr) %>%
  arrange(shf_indexdtm) %>%
  slice(n()) %>%
  ungroup()

flow <- flow %>%
  add_row(
    Criteria = "Denominator in calculation of % of patients with advanced HF",
    N = nrow(rsdataadvhf)
  )

rsdata <- rsdata %>%
  filter(shf_ef %in% c("<30"))
flow <- flow %>%
  add_row(
    Criteria = "Include posts with EF <30%",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(shf_nyha %in% c("III", "IV"))
flow <- flow %>%
  add_row(
    Criteria = "Include posts with NYHA III-IV",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(sos_timeprevhosphf <= 365 / 2 & !is.na(sos_timeprevhosphf) | sos_location == "HF in-patient")
flow <- flow %>%
  add_row(
    Criteria = "Include posts with >= 1 previous HFH < 6 months",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(sos_com_htx == "No")
flow <- flow %>%
  add_row(
    Criteria = "Exclude posts with a previous Htx",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  filter(sos_com_lvad == "No")
flow <- flow %>%
  add_row(
    Criteria = "Exclude posts with a previous LVAD",
    N = nrow(rsdata)
  )

rsdata <- rsdata %>%
  group_by(lopnr) %>%
  arrange(shf_indexdtm) %>%
  slice(n()) %>%
  ungroup()
flow <- flow %>%
  add_row(
    Criteria = "Last post / patient",
    N = nrow(rsdata)
  )

rm(rsdata422)
gc()
