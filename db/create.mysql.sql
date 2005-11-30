CREATE TABLE users (
  id INT NOT NULL AUTO_INCREMENT,
  studentid VARCHAR(10) NOT NULL,
  name VARCHAR(50) NOT NULL,
  -- staffid
  password VARCHAR(20) NOT NULL,
  PRIMARY KEY(id)
) ENGINE= InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE rooms (
  id INT NOT NULL AUTO_INCREMENT,
  room_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE computers (
  id INT NOT NULL AUTO_INCREMENT,
  ip_address VARCHAR(50) NOT NULL,
  room_id INT NOT NULL REFERENCES rooms(id),
  PRIMARY KEY (id),
  FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE subjects (
  id INT NOT NULL AUTO_INCREMENT,
  subject_code VARCHAR(8) NOT NULL,
  subject_name VARCHAR(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE quizzes (
  id INT NOT NULL AUTO_INCREMENT,
  duration INT NOT NULL,
  subject_id INT NOT NULL REFERENCES subjects(id),
  PRIMARY KEY (id),
  FOREIGN KEY (subject_id) REFERENCES subjects(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE testruns (
  id INT NOT NULL AUTO_INCREMENT,
  start_time timestamp(14) NOT NULL,
  end_time timestamp(14) NOT NULL,
  computer_id INT NOT NULL REFERENCES computers(id),
  quiz_id INT NOT NULL REFERENCES quizzes(id),
  user_id INT NOT NULL REFERENCES users(id),
  PRIMARY KEY (id),
  FOREIGN KEY (computer_id) REFERENCES computers(id),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE questions (
  id INT NOT NULL AUTO_INCREMENT,
  content TEXT NOT NULL,
  type VARCHAR(20) NOT NULL,
  is_on_test TINYINT(1) NOT NULL,
  quiz_id INT NOT NULL REFERENCES quizzes(id),
  PRIMARY KEY (id),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE answers (
  id INT NOT NULL AUTO_INCREMENT,
  content TEXT NOT NULL,
  is_correct TINYINT(1) NOT NULL,
  question_id INT NOT NULL REFERENCES questions(id),
  PRIMARY KEY (id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE resources (
  id INT NOT NULL AUTO_INCREMENT,
  type VARCHAR(25) NOT NULL,
  resource VARCHAR(25) NOT NULL,
  question_id INT NOT NULL REFERENCES questions(id),
  PRIMARY KEY (id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE responses (
  id INT NOT NULL AUTO_INCREMENT,
  input TEXT,
  time timestamp(14) NOT NULL,
  testrun_id INT NOT NULL REFERENCES testruns(id),
  question_id INT NOT NULL REFERENCES questions(id),
  answer_id INT NOT NULL REFERENCES answers(id),
  PRIMARY KEY (id),
  FOREIGN KEY (testrun_id) REFERENCES testruns(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (answer_id) REFERENCES answers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

