# Cut outcomes death at 1 year
rsdata <- cut_surv(rsdata, sos_out_death, sos_outtime_death, global_fu, cuttime = FALSE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_deathcv, sos_outtime_death, global_fu, cuttime = FALSE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_deathnoncv, sos_outtime_death, global_fu, cuttime = TRUE, censval = "No")

rsdata <- rsdata %>%
  mutate(
    all = factor(1),
    indexyear_fac = factor(shf_indexyear),
    sos_prevhfh6mo = factor(if_else(sos_timeprevhosphf <= 365 / 2 & !is.na(sos_timeprevhosphf) | sos_location == "HF in-patient", 1, 0), levels = 0:1, labels = c("No", "Yes")),
    advhf = ynfac(
      if_else(shf_ef == "<30" &
        shf_nyha %in% c("III", "IV") &
        sos_prevhfh6mo == "Yes" &
        sos_com_htx == "No" &
        sos_com_lvad == "No", 1, 0)),
    advhftreat = ynfac(
      if_else(advhf == "Yes" &
        shf_age < 70 &
        sos_com_dialysis == "No" &
        shf_gfrckdepi >= 30 &
        sos_com_cancer3y == "No", 1, 0)
    ),
    shf_indexyear_cat = factor(case_when(
      shf_indexyear <= 2010 ~ "2003-2010",
      shf_indexyear <= 2015 ~ "2011-2015",
      shf_indexyear <= 2020 ~ "2016-2020",
      shf_indexyear <= 2023 ~ "2021-2023"
    )),
    shf_age_cat = factor(
      case_when(
        is.na(shf_age) ~ NA_real_,
        shf_age < 70 ~ 1,
        shf_age >= 70 ~ 2
      ),
      levels = 1:2,
      labels = c("<70", ">=70")
    ),
    shf_bpsys_cat = factor(
      case_when(
        shf_bpsys < 140 ~ 1,
        shf_bpsys >= 140 ~ 2
      ),
      levels = 1:2, labels = c("<140", ">=140")
    ),
    shf_ntprobnp_cat = factor(
      case_when(
        shf_ntprobnp < 2000 ~ 1,
        shf_ntprobnp >= 2000 ~ 2
      ),
      levels = 1:2, labels = c("<2000", ">=2000")
    )
  )

# income
inc <- rsdata %>%
  reframe(incsum = list(enframe(quantile(scb_dispincome,
    probs = c(0.33, 0.66),
    na.rm = TRUE
  ))), .by = shf_indexyear) %>%
  unnest(cols = c(incsum)) %>%
  pivot_wider(names_from = name, values_from = value)

rsdata <- left_join(
  rsdata,
  inc,
  by = "shf_indexyear"
) %>%
  mutate(
    scb_dispincome_cat = factor(
      case_when(
        scb_dispincome < `33%` ~ 1,
        scb_dispincome < `66%` ~ 2,
        scb_dispincome >= `66%` ~ 3
      ),
      levels = 1:3,
      labels = c("1st tertile within year", "2nd tertile within year", "3rd tertile within year")
    )
  ) %>%
  select(-`33%`, -`66%`)

rsdata <- rsdata %>%
  mutate(across(where(is_character), factor))
