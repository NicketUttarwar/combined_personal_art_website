# Nicket Uttarwar — Portfolio

Bare-bones static portfolio: multi-page (Home, About, Experience, **Nicket's Life**, Art, Contact). Responsive layout.

**Stack:** HTML and CSS only. No JavaScript, no frameworks, no fonts or scripts. Single stylesheet (`css/style.css`). Content and images only.

---

## Hosting on Ubuntu

### 1. System update

```bash
sudo apt update && sudo apt upgrade -y
```

---

### 2. Clone the repo

```bash
sudo mkdir -p /var/www
sudo chown $USER:$USER /var/www
cd /var/www
git clone https://github.com/<your-username>/nicketuttarwar.com.git nicketuttarwar.com
cd nicketuttarwar.com
```

Ensure these exist and are readable by the web server:

- `index.html` (home)
- `about/index.html`, `experience/index.html`, `life/index.html`, `art/index.html`, `contact/index.html`
- `css/style.css`, `images/` (logo and page assets)

**Heritage section (About page)** — optional images in `images/` for the Naturell explainer. If missing, placeholders show. Add any you have:
- `heritage-intro.jpg` — roots / where I come from
- `naturell-logo.jpg` — Naturell India branding
- `naturell-max-protein.jpg` — Max Protein / RiteBite bars
- `naturell-building.jpg` — building the company
- `zydus-wellness.jpg` — Zydus Wellness (e.g. logo or HQ)

---

### 3. Nginx

**Install Nginx**

```bash
sudo apt install nginx -y
```

**Create site config**

```bash
sudo nano /etc/nginx/sites-available/nicketuttarwar.com
```

Paste:

```nginx
server {
    listen 80;
    server_name nicketuttarwar.com www.nicketuttarwar.com;
    root /var/www/nicketuttarwar.com;
    index index.html;

    location / {
        try_files $uri $uri/ $uri/index.html =404;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|webp|pdf)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }
}
```

**Enable the site and reload Nginx**

```bash
sudo ln -s /etc/nginx/sites-available/nicketuttarwar.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Optional: HTTPS with Let’s Encrypt**

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d nicketuttarwar.com -d www.nicketuttarwar.com
```

Certbot will adjust the Nginx config for SSL. Renewal is automatic.

---

### 4. Check that it works

- **https://nicketuttarwar.com** (or http before SSL) → home page
- **https://nicketuttarwar.com/about/** → About page
- **https://nicketuttarwar.com/experience/**, **/life/**, **/art/**, **/contact/** → other pages

If you see 404 for paths like `/about/`, the server isn’t serving `index.html` for directories. With the config above, Nginx will serve `.../about/index.html` for `/about/`.

---

## Local preview (no server)

```bash
cd /path/to/nicketuttarwar.com
python3 -m http.server 8080
```

Then open **http://localhost:8080**. Use **http://localhost:8080/about/** etc. for inner pages.

**Quick sanity check** (with the server running): `python3 test_site.py` — verifies all pages and main assets return 200.

---

## Project layout

```
nicketuttarwar.com/
├── index.html
├── about/index.html
├── experience/index.html
├── art/index.html
├── contact/index.html
├── life/index.html
├── css/style.css           # Single stylesheet (no JS)
├── images/                 # Logo and page assets
├── test_site.py            # Optional: run with server to verify all pages load
└── README.md
```

---

## Notes

- **Bare bones:** HTML and CSS only. No JavaScript, no `fonts/` or `js/` directory. Mobile menu uses a CSS-only checkbox pattern.
- **No build step:** deploy the repo as-is.
- **Contact:** The contact page uses a `mailto:` link only; there is no server-side form.
- **Paths:** Inner pages use `../` for assets (e.g. `../css/style.css`). Keep the folder structure.
- **Images:** All image assets live in `images/`. Subpages use `../images/...`.
- **HTTPS:** Use Certbot (steps above) to serve the site over HTTPS on Ubuntu.
