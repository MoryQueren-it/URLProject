import json
import os
import random
import string
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)
DATA_FILE = "links.json"


def load_links():
    if not os.path.exists(DATA_FILE):
        return {}
    try:
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return {}


def save_links(links):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(links, f, indent=4, ensure_ascii=False)


def generate_code(length=5):
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for _ in range(length))


@app.route("/", methods=["GET", "POST"])
def index():
    links = load_links()
    error = None

    if request.method == "POST":
        long_url = request.form.get("long_url", "").strip()
        custom_code = request.form.get("custom_code", "").strip()

        if not long_url:
            error = "Veuillez entrer une URL valide."
        else:
            if not long_url.startswith(("http://", "https://")):
                long_url = "https://" + long_url

            if custom_code:
                code = custom_code.replace(" ", "-")
                if code in links:
                    error = f"Le nom court '{code}' est déjà utilisé."
            else:
                code = generate_code()
                while code in links:
                    code = generate_code()

            if not error:
                links[code] = {
                    "url": long_url,
                    "clicks": 0,
                    "created_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                    "history": []
                }
                save_links(links)
                return redirect(url_for("index"))

    return render_template("index.html", links=links, error=error)


@app.route("/r/<code>")
def redirect_to_url(code):
    links = load_links()
    if code in links:
        links[code]["clicks"] += 1
        links[code]["history"].append(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        save_links(links)
        return redirect(links[code]["url"])
    return "Lien introuvable", 404


@app.route("/delete/<code>", methods=["POST"])
def delete_link(code):
    links = load_links()
    if code in links:
        del links[code]
        save_links(links)
    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)