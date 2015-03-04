DROP TABLE users;
DROP TABLE questions;
DROP TABLE question_follows;
DROP TABLE replies;
DROP TABLE question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);


CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body TEXT,
  author_id INTEGER REFERENCES users(id)
);


CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  question_id INTEGER REFERENCES questions(id)
);


CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER REFERENCES questions(id),
  parent_id INTEGER REFERENCES replies(id),
  author_id INTEGER REFERENCES users(id),
  body TEXT
);


CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  question_id INTEGER REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Tripp", "Davis"),
  ("Kevin", "Gan"),
  ("John", "Smith");

INSERT INTO
  questions (title, body, author_id)
VALUES
  ("What?", "What is AA?", 1),
  ("Where?", "Where is is located?", 2),
  ("Cost", "How much does it cost?", 1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1, 1),
  (2, 1),
  (3, 1),
  (2, 2),
  (3, 2),
  (3, 3);

INSERT INTO
  replies (question_id, parent_id, author_id, body)
VALUES
  (1, null, 2, "I had the same q"),
  (1, 1, 3, "Me TOO!"),
  (2, null, 1, "Thats a stupid question");

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (3, 1),
  (1, 2);
