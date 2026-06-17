from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    ai_provider: str = "openai"
    ai_base_url: str = "https://api.openai.com/v1"
    ai_api_key: str = ""
    ai_model: str = "gpt-4o"
    ai_timeout_seconds: int = 30

    github_token: str = ""
    github_repo_owner: str = "ionutc19"
    github_repo_name: str = "job-pack"

    database_url: str = "postgresql+psycopg2://jobcoachadmin@jobcoach-pg-ionut.postgres.database.azure.com:5432/jobcoach?sslmode=require"

    google_play_package: str = "com.ionutc19.jobcoach"
    google_play_credentials_json: str = ""
    rtdn_secret: str = ""

    admin_secret: str = ""

    host: str = "0.0.0.0"
    port: int = 8000

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
