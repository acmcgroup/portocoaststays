# Homestay — Website

Static site: landing page + password-protected proposal (`proposta.html`).

## Local preview

Open `website/index.html` in a browser, or serve the folder:

```bash
cd website && npx --yes serve .
```

## Deploy (GitHub Pages)

Point Pages to the **`/website`** folder on branch `main`, or use a workflow that publishes `website/` as the site root.

## Repository scope

This repository contains **only** the `website/` directory. Business plans and internal docs stay outside Git (see `.gitignore` in the parent project folder).
