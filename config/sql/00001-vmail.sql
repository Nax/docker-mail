CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL,
  DOMAIN TEXT NOT NULL,
  PASSWORD TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username_domain ON users (username, domain);
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_domain ON users (domain);
