source("global.R")

library(data.table);library(magrittr);library(jstable);library(survival);library(jskm)
library(flextable);library(flexlsx);library(openxlsx2)
library(ggplot2);library(officer);library(rvg)

dd <- copy(out)

time_var <- varlist$Time
event_var <- varlist$Event
group_var <- "sex"

dd[, .time := as.numeric(get(time_var))]
dd[, .event := as.integer(as.character(get(event_var)))]

## Table 1 ---------------------------------------------------------------------
vars_tb1 <- setdiff(varlist$Base, group_var)

tb1 <- CreateTableOneJS(
  vars = vars_tb1,
  strata = group_var,
  data = dd,
  labeldata = out.label,
  Labels = TRUE,
  testNonNormal = wilcox.test
)
tb1_df <- tb1$table %>% cbind(Variable = rownames(.), .)
tb1_df <- tb1_df[, !colnames(tb1_df) %in% "test"]

ft_tb1 <- flextable(data.frame(tb1_df, check.names = FALSE)) %>%
  set_caption("Table 1. Baseline characteristics by sex") %>%
  add_footer_lines("Values are median (IQR) or n (%). P by Wilcoxon rank-sum test for continuous variables and Chi-squared or Fisher's exact test for categorical variables.") %>%
  autofit()

## Cox regression --------------------------------------------------------------
cox_vars <- c("sex", "age", "ph.ecog", "wt.loss")
fmla_cox <- as.formula(
  paste0("Surv(.time, .event) ~ ", paste(cox_vars, collapse = " + "))
)
fit_cox <- eval(substitute(coxph(f, data = dd, model = TRUE), list(f = fmla_cox)))
tb_cox <- cox2.display(fit_cox, dec = 3, data_for_univariate = dd)
cox_df <- tb_cox$table %>% cbind(Variable = rownames(.), .)

ft_cox <- flextable(data.frame(cox_df, check.names = FALSE)) %>%
  set_caption("Table 2. Cox proportional hazards regression") %>%
  add_footer_lines("Hazard ratios and 95% confidence intervals were estimated using Cox proportional hazards regression.") %>%
  autofit()

## Kaplan-Meier plot -----------------------------------------------------------
fmla_km <- as.formula(paste0("Surv(.time, .event) ~ ", group_var))
fit_km <- eval(substitute(survfit(f, data = dd), list(f = fmla_km)))

p_km <- jskm(
  fit_km,
  data = dd,
  pval = TRUE,
  table = TRUE,
  theme = "jama",
  ylab = "Survival probability",
  xlab = "Follow-up time (days)"
)

plot_list <- list(
  "Figure1_KM" = p_km
)

ft_list <- list(
  "Table1_Baseline" = ft_tb1,
  "Table2_Cox" = ft_cox
)

## Save tables to Excel --------------------------------------------------------
wb <- wb_workbook()
for (sn in names(ft_list)) {
  wb$add_worksheet(sn)
  wb <- wb_add_flextable(wb, sn, ft_list[[sn]])
}
wb$save("Tables.xlsx")

## Save figures to PPT ---------------------------------------------------------
ppt <- read_pptx()
for (i in seq_along(plot_list)) {
  ppt <- add_slide(ppt, layout = "Blank")
  ppt <- ph_with(
    ppt,
    dml(ggobj = plot_list[[i]]),
    location = ph_location(left = 0, top = 0, width = 10, height = 7.5)
  )
}
print(ppt, target = "Figures.pptx")
