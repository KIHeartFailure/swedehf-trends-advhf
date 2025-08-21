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

rsdata <- rsdata422 %>%
  filter(shf_indexyear >= 2003)
flow <- flow %>%
  add_row(
    Criteria = "2003-2023",
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
