-- ===============================
-- FITNESS WORKOUT APP - SOCIAL FEED SCHEMA
-- ===============================

-- جدول البوستات
CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,            -- نص البوست
    image_path VARCHAR(255),          -- صورة البوست لو موجودة
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول التعليقات والردود
CREATE TABLE post_comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES posts(post_id) ON DELETE CASCADE,  -- البوست اللي عليه التعليق
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,  -- صاحب التعليق
    comment_text TEXT,              -- نص التعليق
    comment_image VARCHAR(255),     -- صورة مع التعليق (اختياري)
    parent_comment_id INT REFERENCES post_comments(comment_id) ON DELETE CASCADE, -- لو رد على تعليق
    replies_count INT DEFAULT 0,    -- عدد الردود على التعليق
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول لايكات البوستات
CREATE TABLE post_likes (
    like_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, user_id)         -- يمنع تكرار اللايك من نفس المستخدم
);

-- جدول لايكات التعليقات
CREATE TABLE comment_likes (
    like_id SERIAL PRIMARY KEY,
    comment_id INT REFERENCES post_comments(comment_id) ON DELETE CASCADE,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(comment_id, user_id)
);

-- جدول إشعارات الردود على التعليقات
CREATE TABLE comment_notifications (
    notification_id SERIAL PRIMARY KEY,
    receiver_user_id INT REFERENCES users(user_id) ON DELETE CASCADE,  -- صاحب التعليق الأصلي
    comment_id INT REFERENCES post_comments(comment_id) ON DELETE CASCADE, -- التعليق اللي اترد عليه
    sender_user_id INT REFERENCES users(user_id) ON DELETE CASCADE,      -- الشخص اللي رد
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- Indexes لتحسين الأداء
-- ===============================
CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_comments_post ON post_comments(post_id);
CREATE INDEX idx_comments_user ON post_comments(user_id);
CREATE INDEX idx_post_likes_post ON post_likes(post_id);
CREATE INDEX idx_post_likes_user ON post_likes(user_id);
CREATE INDEX idx_comment_likes_comment ON comment_likes(comment_id);
CREATE INDEX idx_comment_notifications_receiver ON comment_notifications(receiver_user_id);
