"""
知识库后台统一配置

集中管理：
- GitHub源码路径
- SQLite路径
- 同步配置
"""

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

DATABASE_URL = f"sqlite:///{BASE_DIR / 'knowledge.db'}"

PROJECT_ROOT = BASE_DIR.parent.parent

MENU_PATH = PROJECT_ROOT / "_menu_defs"
POST_PATH = PROJECT_ROOT / "_posts"
GALLERY_PATH = PROJECT_ROOT / "_data" / "gallery.yml"

SYNC_BATCH_SIZE = 100
