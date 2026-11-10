-- 構築記事DB（pokemon-master とは別の D1 データベース）
-- 日時はすべて UTC の ISO8601 文字列（例: '2026-11-10T13:00:00Z'）

CREATE TABLE articles (
    id                INTEGER PRIMARY KEY,
    x_post_id         TEXT NOT NULL UNIQUE,      -- ポストID（重複判定キー。URLは x.com / twitter.com で揺れるため）
    x_post_url        TEXT NOT NULL,
    article_url       TEXT,                      -- note / ブログ等。無い投稿もあり得るので NULL 可
    title             TEXT NOT NULL,
    x_author_handle   TEXT NOT NULL,             -- @以下のスクリーンネーム。投稿者リンクはここから組み立てる
    x_author_name     TEXT NOT NULL,             -- 表示名（変わりうる）
    rule              TEXT NOT NULL CHECK (rule IN ('single', 'double')),
    like_count        INTEGER NOT NULL DEFAULT 0,
    posted_at         TEXT NOT NULL,             -- X投稿日時
    metrics_synced_at TEXT,                      -- いいね数を最後に更新した日時
    is_hidden         INTEGER NOT NULL DEFAULT 0 CHECK (is_hidden IN (0, 1)), -- 誤検出・削除済み投稿を非表示に
    created_at        TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    updated_at        TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX idx_articles_posted_at      ON articles(posted_at DESC);
CREATE INDEX idx_articles_rule_posted_at ON articles(rule, posted_at DESC);
CREATE INDEX idx_articles_like_count     ON articles(like_count DESC);

-- 構築ポケモン（pokemon_id は pokemon-master.pokemon.id を指す。DBが別なのでFK制約は張れない）
CREATE TABLE article_pokemon (
    article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    pokemon_id INTEGER NOT NULL,              -- pokemon-master.pokemon.id。存在チェックは投入処理側で行う
    PRIMARY KEY (article_id, pokemon_id)
) WITHOUT ROWID;

-- 「ポケモンXを含む構築」検索用
CREATE INDEX idx_article_pokemon_pokemon_id ON article_pokemon(pokemon_id, article_id);
