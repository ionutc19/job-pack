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

    host: str = "0.0.0.0"
    port: int = 8000

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
