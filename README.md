# Journal Review

Journal review presentation materials.

## RACING Trial Presentation

The RACING trial slide deck is in `docs/RACING`.

- Source: `docs/RACING/index.qmd`
- Rendered HTML: `docs/RACING/index.html`
- Figures and tables: `docs/RACING/*.png`

Open `docs/RACING/index.html` in a browser to view the rendered Reveal.js presentation.

## Render

On this workspace, Quarto needs the local `uname` path and the deck can be rendered without executing code:

```bash
env PATH=/usr/lib/klibc/bin:/usr/bin:/bin:/usr/local/bin:/usr/lib/rstudio-server/bin/quarto/bin quarto render docs/RACING/index.qmd --no-execute
```

Normal execution may require Python/Jupyter dependencies such as `yaml`.
