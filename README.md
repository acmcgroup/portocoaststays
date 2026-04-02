# Homestay - Website

Static site: landing page + password-protected proposal (`proposta.html`).

## Local preview

Open `website/index.html` in a browser, or serve the folder:

```bash
cd website && npx --yes serve .
```

## Deploy

### Netlify

The repo keeps HTML under **`website/`**. This project includes [`netlify.toml`](netlify.toml) with `publish = "website"` so the site root is correct. Connect the repo and deploy - **do not** set the publish directory to `/` in the UI if it overrides the file (the TOML should win).

If you still see **404**, in Netlify: **Site settings → Build & deploy → Build settings → Publish directory** → set to `website` (or leave empty so `netlify.toml` applies).

### GitHub Pages

Point Pages to the **`/website`** folder on branch `main`, or use a workflow that publishes `website/` as the site root.

## Repository scope

This repository contains **only** the `website/` directory. Business plans and internal docs stay outside Git (see `.gitignore` in the parent project folder).

If you need the old root README from before the website-only split, it is still in Git history: `git show d47874a:README.md`.
