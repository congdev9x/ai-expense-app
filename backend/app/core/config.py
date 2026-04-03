from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    PROJECT_NAME: str = "AI Expense Tracker API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Database Settings
    POSTGRES_USER: str = "expense_user"
    POSTGRES_PASSWORD: str = "expense_password"
    POSTGRES_DB: str = "expense_db"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: str = "5432"
    
    # Redis Settings
    REDIS_HOST: str = "localhost"
    REDIS_PORT: str = "6379"

    # JWT Authentication
    SECRET_KEY: str = "YOUR_SUPER_SECRET_KEY_HERE_FOR_DEVELOPMENT"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7 # 7 days
    
    # Gemini AI API
    GEMINI_API_KEY: str = ""

    @property
    def DATABASE_URL(self) -> str:
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings() -> Settings:
    return Settings()
