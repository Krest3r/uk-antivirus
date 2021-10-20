import os

from app import create_app


application = create_app(os.getenv("DM_ENVIRONMENT") or "development")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    application.run("0.0.0.0", port)
