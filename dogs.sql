CREATE TABLE dogs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "111 Madrid Street"), (2, "Dolores Park");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Devin", "Miranda", 1),
  (2, "Steve", "Erwin", 1),
  (3, "Sammy", "Sosa", 2),
  (4, "Michael", "Jordan", NULL);

INSERT INTO
  dogs (id, name, owner_id)
VALUES
  (1, "Barkley", 1),
  (2, "J-Cool", 2),
  (3, "Pawl", 3),
  (4, "Taz", 3),
  (5, "Stray Dog", NULL);
