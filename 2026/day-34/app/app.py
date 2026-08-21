from flask import Flask
import os
import mysql.connector
import redis

app = Flask(__name__)


@app.route("/")
def home():
    db_status = "Not connected"
    redis_status = "Not connected"

    try:
        db = mysql.connector.connect(
            host=os.getenv("DB_HOST", "db"),
            user=os.getenv("DB_USER", "appuser"),
            password=os.getenv("DB_PASSWORD", "apppassword"),
            database=os.getenv("DB_NAME", "appdb")
        )

        if db.is_connected():
            db_status = "Connected"

        db.close()

    except Exception as e:
        db_status = f"Error: {e}"

    try:
        cache = redis.Redis(
            host=os.getenv("REDIS_HOST", "redis"),
            port=6379,
            decode_responses=True
        )

        cache.ping()
        redis_status = "Connected"

    except Exception as e:
        redis_status = f"Error: {e}"

    return f"""
    <h1>Day 34 - Docker Compose Advanced v2</h1>
    <h2>Service Status</h2>

    <p>Flask App: Running</p>
    <p>MySQL: {db_status}</p>
    <p>Redis: {redis_status}</p>
    """


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
