# Variables for baseline tables -----------------------------------------------

tabvars <- c(
  # demo
  "shf_indexyear_cat",
  "shf_sex",
  "shf_age",
  "shf_age_cat",

  # organizational
  "shf_location",
  "shf_followuphfunit",
  "shf_followuplocation_cat",

  # clinical factors
  "shf_nyha",
  "shf_bmi",
  "shf_bmi_cat",
  "shf_bpsys",
  "shf_bpsys_cat",
  "shf_bpdia",
  "shf_map",
  "shf_heartrate",
  "shf_heartrate_cat",

  # comorbs
  "shf_smoke_cat",
  "shf_sos_com_diabetes",
  "shf_sos_com_hypertension",
  "shf_sos_com_ihd",
  "sos_com_stroke",
  "shf_sos_com_af",
  "shf_anemia",
  "sos_com_valvular",
  "sos_com_liver",
  "sos_com_dialysis",
  "sos_com_copd",
  "sos_com_cancer3y",
  "sos_com_charlsonci",
  "sos_com_charlsonci_cat",

  # treatments
  "shf_rasiarni",
  "shf_bbl",
  "shf_mra",
  "shf_sglt2",
  "shf_diuretic",
  "shf_nitrate",
  "shf_digoxin",
  "shf_anticoagulantia",
  "shf_asaantiplatelet",
  "shf_statin",
  "shf_device_cat",
  "sos_com_lvad",
  "sos_com_htx",

  # lab measurements
  "shf_gfrckdepi",
  "shf_gfrckdepi_cat",
  "shf_potassium",
  "shf_potassium_cat",
  "shf_hb",
  "shf_ntprobnp",
  "shf_ntprobnp_cat",

  # socec
  "scb_famtype",
  "scb_child",
  "scb_education",
  "scb_dispincome_cat",
  "shf_qol",
  "shf_qol_cat"
)

outvars <- tibble(
  var = c("sos_out_death", "sos_out_deathcv", "sos_out_deathnoncv", "sos_out_lvad", "sos_out_htx"),
  time = c("sos_outtime_death", "sos_outtime_death", "sos_outtime_death", "sos_outtime_lvad", "sos_outtime_htx"),
  shortname = c("Death", "CV death", "Non-CV death", "LVAD", "HTx"),
  name = c("Death", "CV death", "Non-CV death", "Ventricular assist device implantation", "Heart transplantation"),
  composite = c(F, F, F, F, F),
  rep = c(F, F, F, F, F),
  primary = c(F, F, F, F, F),
  order = c(1, 2, 3, 4, 5)
) %>%
  arrange(order)

metavars <- bind_rows(
  metavars,
  tibble(
    variable = c(
      "sos_com_htx",
      "sos_com_lvad"
    ),
    label = c(
      "Previous heart transplant",
      "Previous LVAD"
    )
  )
)
