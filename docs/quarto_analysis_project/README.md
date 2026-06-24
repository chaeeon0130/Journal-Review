# Quarto Analysis Starter

This is a starter structure for R analysis with Quarto.

## Files

- `global.R`: data import, preprocessing, derived variables, `varlist`, `out`, `out.label`
- `analysis.R`: tables, models, plots, Excel export, PPT export
- `report.qmd`: manuscript-style report
- `presentation.qmd`: revealjs slide deck

## Run

```bash
Rscript analysis.R
quarto render report.qmd
quarto render presentation.qmd
```

## Edit First

1. Replace the demo data import block in `global.R`.
2. Create all derived variables before `varlist`.
3. Update `varlist`.
4. Update labels in `out.label`.
5. Update `group_var`, `vars_tb1`, and model variables in `analysis.R`.
