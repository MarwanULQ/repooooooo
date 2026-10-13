from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return """
    <body style="background:#111a31; color:#b8c2d6;
    font-family:Arial; padding:40px;">
        <p>Hello, World!</p>
    </body>
    """


@app.route("/health")
def health():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(debug=True)
