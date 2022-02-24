-- Creation of tables --
CREATE TABLE Restrictions (
  Restriction_ID SERIAL NOT NULL,
  Restriction_Minimum_Age INTEGER NOT NULL,
  Restriction_Description TEXT NOT NULL,
  PRIMARY KEY (Restriction_ID)
);

CREATE TABLE Videos (
  Video_ID SERIAL NOT NULL,
  Video_Name TEXT NOT NULL,
  Video_Description TEXT NOT NULL,
  Video_URL TEXT NOT NULL,
  Video_Creation_Date DATE NOT NULL CHECK (Video_Creation_Date <= NOW()),
  Video_Created_By TEXT NOT NULL,
  Video_Size NUMERIC NOT NULL,
  Video_Length_Minutes NUMERIC NOT NULL,
  Restriction_ID INTEGER,
  PRIMARY KEY (Video_ID),
  CONSTRAINT FK_Videos_Restriction_ID
	FOREIGN KEY (Restriction_ID)
      REFERENCES Restrictions(Restriction_ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE Accounts (
  Account_ID SERIAL NOT NULL,
  Account_Username TEXT NOT NULL,
  Account_Password TEXT NOT NULL,
  PRIMARY KEY (Account_ID)
);

CREATE TABLE Users (
  User_ID SERIAL NOT NULL,
  User_Name TEXT NOT NULL,
  User_Surname TEXT NOT NULL,
  User_Age INTEGER NOT NULL CHECK (User_Age BETWEEN 0 AND 120),
  Account_ID INTEGER NOT NULL,
  Restriction_ID INTEGER,
  PRIMARY KEY (User_ID),
  CONSTRAINT FK_Users_Account_ID
    FOREIGN KEY (Account_ID)
      REFERENCES Accounts(Account_ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT FK_Users_Restriction_ID
    FOREIGN KEY (Restriction_ID)
      REFERENCES Restrictions(Restriction_ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

-- Creation of stored procedures for inserting data to tables -- 
CREATE PROCEDURE insert_account_data(username TEXT, pass TEXT)
LANGUAGE SQL
AS $$
INSERT INTO Accounts VALUES (DEFAULT, username, pass);
$$;

CREATE PROCEDURE insert_restriction_data(min_age INTEGER, description TEXT)
LANGUAGE SQL
AS $$
INSERT INTO Restrictions VALUES (DEFAULT, min_age, description);
$$;

CREATE PROCEDURE insert_user_data(firstname TEXT, surname TEXT, age INTEGER, account INTEGER, restriction INTEGER)
LANGUAGE SQL
AS $$
INSERT INTO Users VALUES (DEFAULT, firstname, surname, age, account, restriction);
$$;

CREATE PROCEDURE insert_user_data(videoname TEXT, description TEXT, URL TEXT, creationdate DATE, creator TEXT, videosize NUMERIC, videolength NUMERIC, restriction INTEGER)
LANGUAGE SQL
AS $$
INSERT INTO Videos VALUES (DEFAULT, videoname, description, URL, creationdate, creator, videosize, videolength, restriction);
$$;

-- Creation of index to search for video information by video name --
CREATE INDEX idx_video_name ON Videos ((lower(Video_Name)));

-- Creation of view to see account names without password -- 
CREATE VIEW account_view AS
SELECT Account_Username
FROM Accounts
;

-- Creation of view to summarise average video file size and video length by publisher/ creator -- 
CREATE VIEW video_avg_size AS
SELECT Video_Created_By, AVG(Video_Size) AS Avg_Size, AVG(Video_Length_Minutes) AS Avg_Length
FROM Videos 
GROUP BY Video_Created_By
;

-- Creation of view to display restricted users only -- 
CREATE VIEW restricted_users AS
SELECT *
FROM Users
WHERE Restriction_ID != 1 --assuming restriction_ID 1 means no restriction--
;

-- Creation of two user groups --
CREATE ROLE Admin_Users;
CREATE ROLE General_Users;

-- Creation of sample users assigned to different user groups --
CREATE USER admin_user_1 WITH PASSWORD 'password1' VALID UNTIL '2025-01-01' IN GROUP Admin_Users;
CREATE USER admin_user_2 WITH PASSWORD 'password2' VALID UNTIL '2025-01-01' IN GROUP Admin_Users;
CREATE USER general_user_1 WITH PASSWORD 'password3' VALID UNTIL '2025-01-01' IN GROUP General_Users;
CREATE USER general_user_2 WITH PASSWORD 'password4' VALID UNTIL '2025-01-01' IN GROUP General_Users;
CREATE USER general_user_3 WITH PASSWORD 'password5' VALID UNTIL '2025-01-01' IN GROUP General_Users;

-- Creation of varying privileges for the different user groups -- 
GRANT ALL PRIVILEGES ON DATABASE "Media_Application_DB" TO Admin_Users;
GRANT SELECT ON Users, Videos, Restrictions, account_view TO General_Users;