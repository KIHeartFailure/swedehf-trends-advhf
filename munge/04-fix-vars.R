# Cut outcomes death at 1 year
rsdata <- cut_surv(rsdata, sos_out_death, sos_outtime_death, global_fu, cuttime = FALSE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_deathcv, sos_outtime_death, global_fu, cuttime = FALSE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_deathnoncv, sos_outtime_death, global_fu, cuttime = TRUE, censval = "No")

medfunc <- function(medvar) {
  rsdata <- left_join(rsdata %>% mutate(sub = as.character(!!sym(paste0("shf_", medvar, "sub")))),
    targetdoses %>% filter(med == medvar) %>% select(sub, targetdose),
    by = "sub"
  ) %>%
    mutate(
      tg = !!sym(paste0("shf_", medvar, "dose")) / targetdose * 100,
      tg = factor(
        case_when(
          is.na(!!sym(paste0("shf_", medvar))) | !!sym(paste0("shf_", medvar)) == "No" ~ 2,
          is.na(tg) ~ NA_real_,
          tg < 50 ~ 0,
          tg >= 50 ~ 1
        ),
        levels = 0:2, labels = c("<50", ">=50", "No/missing medication")
      )
    ) %>%
    rename(!!sym(paste0("shf_", medvar, "_tg")) := tg) %>%
    select(-targetdose, -sub)
}

rsdata <- medfunc(medvar = "bbl")
rsdata <- medfunc("mra")
rsdata <- medfunc("acei")
rsdata <- medfunc("arb")

rsdata <- left_join(rsdata %>% mutate(shf_arnidose = as.character(shf_arnidose)),
  targetdoses %>% filter(med == "arni") %>% select(shf_arnidose, targetdosearni),
  by = "shf_arnidose"
) %>%
  mutate(
    shf_arni_tg = factor(
      case_when(
        is.na(shf_arni) | shf_arni == "No" ~ 2,
        is.na(targetdosearni) ~ NA_real_,
        targetdosearni %in% c("<50") ~ 0,
        targetdosearni %in% c(">=50") ~ 1
      ),
      levels = 0:2, labels = c("<50", ">=50", "No/missing medication")
    )
  ) %>%
  select(-targetdosearni)

rsdata <- rsdata %>%
  mutate(
    shf_rasiarni_tg = factor(
      case_when(
        shf_arni_tg == "No/missing medication" & shf_acei_tg == "No/missing medication" & shf_arb_tg == "No/missing medication" ~ 2,
        shf_arni_tg == ">=50" | shf_acei_tg == ">=50" | shf_arb_tg == ">=50" ~ 1,
        shf_arni_tg == "<50" | shf_acei_tg == "<50" | shf_arb_tg == "<50" ~ 0
      ),
      levels = 0:2, labels = c("<50", ">=50", "No/missing medication")
    ),
    shf_nyha = droplevels(shf_nyha),
    sos_com_charlsonci_cat = factor(
      case_when(
        sos_com_charlsonci <= 1 ~ 1,
        sos_com_charlsonci <= 4 ~ 2,
        sos_com_charlsonci >= 5 ~ 3
      ),
      levels = 1:3,
      labels = c(
        "1",
        "2-4",
        ">=5"
      )
    ),
    all = factor(1),
    indexyear_fac = factor(shf_indexyear),
    indexyear_cat_fac = factor(case_when(
      shf_indexyear <= 2004 ~ "2003-2004",
      shf_indexyear <= 2006 ~ "2005-2006",
      shf_indexyear <= 2008 ~ "2007-2008",
      shf_indexyear <= 2010 ~ "2009-2010",
      shf_indexyear <= 2012 ~ "2011-2012",
      shf_indexyear <= 2014 ~ "2013-2014",
      shf_indexyear <= 2016 ~ "2015-2016",
      shf_indexyear <= 2018 ~ "2017-2018",
      shf_indexyear <= 2020 ~ "2019-2020",
      shf_indexyear <= 2022 ~ "2021-2022"
    )),
    advhftreat = ynfac(
      if_else(shf_age <= 70 &
        sos_com_dialysis == "No" &
        sos_com_cancer3y == "No", 1, 0)
    ),
    shf_indexyear_cat = factor(case_when(
      shf_indexyear <= 2007 ~ "2003-2007",
      shf_indexyear <= 2012 ~ "2008-2012",
      shf_indexyear <= 2017 ~ "2013-2017",
      shf_indexyear <= 2022 ~ "2018-2022"
    )),
    shf_age_cat = factor(
      case_when(
        is.na(shf_age) ~ NA_real_,
        shf_age <= 70 ~ 1,
        shf_age > 70 ~ 2
      ),
      levels = 1:2,
      labels = c("<=70", ">70")
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
