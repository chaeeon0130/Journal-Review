library(data.table);library(magrittr);library(jstable);library(survival)

## Project root ---------------------------------------------------------------
## Use this line in a real project.
## setwd("~/ShinyApps/kangnam_hallym/user/project_name")

## Data import ----------------------------------------------------------------
## Replace this demo block with your real data import.
## board <- pins::board_s3("zarathu", prefix = "pins/kangnam_hallym/user/project_name")
## a <- pins::pin_read(board, "pin_name") %>% data.table(check.names = TRUE)
## a <- readxl::read_excel("data.xlsx") %>% data.table(check.names = TRUE)

a <- survival::lung %>% data.table(check.names = TRUE)

## Preprocessing and derived variables ----------------------------------------
## Important: make every derived variable before varlist and out.

a[, status_event := as.integer(status == 2)]
a[, status_time := as.numeric(time)]
a[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]
a[, age65 := as.integer(age >= 65)]
a[, ecog_ge2 := fifelse(is.na(ph.ecog), NA_integer_, as.integer(ph.ecog >= 2))]
a[, wt_loss10 := fifelse(is.na(wt.loss), NA_integer_, as.integer(wt.loss >= 10))]

## Variable list ---------------------------------------------------------------
## For survival analysis, keep Event and Time explicitly in varlist.

varlist <- list(
  Event = "status_event",
  Time = "status_time",
  Base = c("sex", "age", "age65", "ph.ecog", "ecog_ge2", "wt.loss", "wt_loss10")
)

out <- a[, .SD, .SDcols = c(unlist(varlist))]

factor_vars <- c(names(out)[sapply(out, function(x) { length(table(x, useNA = "no")) }) <= 6])
out[, (factor_vars) := lapply(.SD, factor), .SDcols = factor_vars]

conti_vars <- setdiff(names(out), factor_vars)
out[, (conti_vars) := lapply(.SD, as.numeric), .SDcols = conti_vars]

out.label <- jstable::mk.lev(out)

vars01 <- sapply(factor_vars, function(v) {
  lv <- sort(unique(na.omit(as.character(out[[v]]))))
  length(lv) > 0 && all(lv %in% c("0", "1"))
})
for (v in names(vars01)[vars01 == TRUE]) {
  out[, (v) := factor(as.character(get(v)), levels = c("0", "1"))]
}
for (v in names(vars01)[vars01 == TRUE]) {
  out.label[variable == v, val_label := c("No", "Yes")]
}

## Labels ----------------------------------------------------------------------
out.label[variable == "status_event", var_label := "Death"]
out.label[variable == "status_time", var_label := "Follow-up time (days)"]
out.label[variable == "sex", `:=`(var_label = "Sex", val_label = c("Male", "Female"))]
out.label[variable == "age", var_label := "Age (years)"]
out.label[variable == "age65", var_label := "Age >= 65 years"]
out.label[variable == "ph.ecog", var_label := "ECOG performance status"]
out.label[variable == "ecog_ge2", var_label := "ECOG >= 2"]
out.label[variable == "wt.loss", var_label := "Weight loss"]
out.label[variable == "wt_loss10", var_label := "Weight loss >= 10"]
