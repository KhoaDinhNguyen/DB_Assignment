USE GAME_COMPANY;

######################################################### STAFF ###############################################################
SET @staff_id_insert = '';

DELIMITER $$
CREATE PROCEDURE insert_staff(IN _ssn CHAR(10), IN _Dob date, IN _Name VARCHAR(50), IN _Salary DECIMAL(10,2), IN _Street VARCHAR(50), IN _City VARCHAR(50), IN _phone CHAR(10))
BEGIN
    # INSERT STAFF INFO
	INSERT INTO Staff(Ssn, Dob, Name, Salary, Street, City) VALUE (_ssn, _Dob, _Name, _Salary, _Street, _City);
    
	SELECT staff_id INTO @staff_id_insert FROM Staff WHERE ssn = _ssn;
	INSERT INTO Staff_phones(staff_id, phone) VALUE (@staff_id_insert, _phone);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_streamer(IN _staff_id CHAR(7), IN _nick_name VARCHAR(50), _game CHAR(7))
BEGIN
	# INSERT STREAMER AND ITS RELAVENT INFO
	IF NOT EXISTS (SELECT game_id FROM game WHERE game_id = _game) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The game does not exist, can not create this streamer';
    END IF;
    IF NOT EXISTS (SELECT Player_ID FROM Player WHERE Player_ID = _staff_id) THEN
		INSERT INTO Player(Nick_Name, Player_Id) VALUE (_nick_name, _staff_id);
    END IF;
    IF NOT EXISTS (SELECT Player FROM Play WHERE (Player = _staff_id AND Game = _game)) THEN
		INSERT INTO Play(Game, Player) VALUE (_game, _staff_id);
    END IF;
    INSERT INTO Streamer(Player_Id) VALUE (_staff_id);	
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_staff_streamer(IN _ssn CHAR(10), IN _Dob date, IN _Name VARCHAR(50), IN _Salary DECIMAL(10,2), IN _Street VARCHAR(50), IN _City VARCHAR(50), IN _phone CHAR(10), IN _nick_name VARCHAR(50), _game CHAR(7))
BEGIN
	IF NOT EXISTS (SELECT game_id FROM game WHERE game_id = _game) THEN
     SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The game does not exist, can not create this streamer nor staff';
    END IF;
	CALL insert_staff(_ssn, _Dob, _Name, _Salary, _Street, _City, _phone);
    CALL insert_streamer(@staff_id_insert, _nick_name, _game);
END$$
DELIMITER ;

# trigger when insert and update staff
DELIMITER $$
CREATE TRIGGER insert_staff BEFORE INSERT ON Staff
FOR EACH ROW
BEGIN
	IF (YEAR(CURDATE()) - YEAR(NEW.Dob) < 18) THEN
	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The staff age is less than 18, cannot create this staff';
	END IF;
	IF (NEW.Salary < 1000) THEN
	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The staff salary is less than 1000$, cannot create this staff';
	END IF;
END $$

DELIMITER $$
CREATE TRIGGER insert_staff BEFORE UPDATE ON Staff
FOR EACH ROW
BEGIN
	IF (YEAR(CURDATE()) - YEAR(NEW.Dob) < 18) THEN
	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The staff age is less than 18, cannot modify this staff';
	END IF;
	IF (NEW.Salary < 1000) THEN
	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The staff salary is less than 1000$, cannot modify this staff';
	END IF;
END $$

DELETE FROM staff WHERE ssn = '123456789';
CALL insert_staff('123456789', '2004-05-13', 'Nguyen Ngoc Dinh Khoa', 1234, 'Le Van Tho', 'Ho Chi Minh', '0394913053');
CALL insert_staff('123456780', '1998-05-13', 'Nguyen Ngoc Dang Khoa', 1724, 'Le Van Tho', 'Ho Chi Minh', '0394913053');
SELECT * FROM Staff_Phones;
SELECT* FROM streamer;
SELECT* FROM coach;
SELECT* FROM player;

##################################################### GAME #################################################################


##################################################### COACH #################################################################
DELIMITER $$
CREATE TRIGGER delete_coach BEFORE DELETE ON coach
FOR EACH ROW
BEGIN
	DEcLARE num_of_coaches INT;
	SELECT COUNT(*) INTO num_of_coaches
    FROM coach
    WHERE team = OLD.team;
    
    IF (num_of_coaches = 1) THEN
	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The number of coach in team reach the minimum (= 1), cannot delete this staff';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_coach(IN _Coach_Id VARCHAR(7), IN _Nick_Name VARCHAR(50), _Team VARCHAR(50), IN skills CHAR(7))
BEGIN
	INSERT INTO Coach(Nick_Name, Coach_Id, Team) VALUE (_Nick_Name, _Coach_Id, _Team);
    IF SUBSTRING(skills, 1, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Financial Insurance'); END IF;
    IF SUBSTRING(skills, 2, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Health Management'); END IF;
    IF SUBSTRING(skills, 3, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Food Ensuring'); END IF;
    IF SUBSTRING(skills, 4, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Gameplay Strategy'); END IF;
    IF SUBSTRING(skills, 5, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Mental Health'); END IF;
    IF SUBSTRING(skills, 6, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Time Management'); END IF;
    IF SUBSTRING(skills, 7, 1) = '1' THEN INSERT INTO Coach_Skills(Coach_Id, Skill) VALUE (_Coach_Id, 'Sport and Body Builder'); END IF;
END$$
DELIMITER ;
/*
DROP PROCEDURE insert_coach;
SELECT * FROM Staff;
SELECT * FROM Coach;
SELECT * FROM Team;
SELECT * FROM Coach_Skills;
DELETE FROM Staff WHERE Staff_ID = 'EMP0054';
*/

CALL insert_coach('nhock', 'EMP0051', 'Telecom Esport', '1100010');
CALL insert_coach('blue', 'EMP0055', 'Telecom Esport', '1110011');

##################################################### PROFRESSIONAL PLAYER #################################################################
DELIMITER $$
CREATE TRIGGER delete_professional BEFORE DELETE ON Professional_Player
FOR EACH ROW
BEGIN
	DECLARE num_of_pros INT;
	SELECT COUNT(*) INTO num_of_pros
    FROM Professional_Player
    WHERE team = OLD.team;
    
    IF (num_of_pros = 1) THEN
	SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The number of professional player in team reach the minimum (= 1), cannot delete this staff';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_professional(IN _staff_id CHAR(7), IN _nick_name VARCHAR(50), IN _team_name VARCHAR(50), IN _debut_Date DATE)
BEGIN
	# INSERT STREAMER AND ITS RELAVENT INFO
    DECLARE _game_id CHAR(7);
    SELECT game_id INTO _game_id FROM team WHERE team_name = _team_name;
    
	IF NOT EXISTS (SELECT game_id FROM game WHERE game_id = _game_id) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The game does not exist, can not create this professional player';
    END IF;
    IF NOT EXISTS (SELECT Player_ID FROM Player WHERE Player_ID = _staff_id) THEN
		INSERT INTO Player(Nick_Name, Player_Id) VALUE (_nick_name, _staff_id);
    END IF;
    IF NOT EXISTS (SELECT Player FROM Play WHERE (Player = _staff_id AND Game = _game_id)) THEN
		INSERT INTO Play(Game, Player) VALUE (_game_id, _staff_id);
    END IF;
    INSERT INTO Professional_Player(Player_Id, Debut_Date, Team) VALUE (_staff_id, _debut_Date, _team_name);	
END$$
DELIMITER ;

/*
DROP PROCEDURE insert_coach;
SELECT * FROM Staff;
SELECT * FROM Coach;
SELECT * FROM Team;
SELECT * FROM Coach_Skills;
DELETE FROM Staff WHERE Staff_ID = 'EMP0054';
*/

##################################################### TEAM #################################################################
DELIMITER $$
CREATE PROCEDURE check_free_staff()
BEGIN
	SELECT Staff_id, Name AS 'Free staff'
    FROM Staff
    WHERE Staff_Id NOT IN (
		SELECT Player_ID FROM Player 
		UNION 
		SELECT Coach_Id FROM Coach);
END $$
DELIMITER ;

CALL check_free_staff();

DELIMITER $$
CREATE PROCEDURE insert_team(IN _team_name VARCHAR(50), IN _game_id CHAR(7), IN _coach_id CHAR(7), IN _coach_nick_name VARCHAR(50), IN skills CHAR(7), IN _pro_id CHAR(7), IN _player_nick_name VARCHAR(50))
BEGIN
	IF NOT EXISTS (SELECT game_id FROM game WHERE game_id = _game) THEN
     SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The game does not exist, can not create this team';
    END IF;
    INSERT INTO Team(team_name, Game_ID, Status, start_date) VALUE (_team_name, _game_id, 'Not enough member', CURDATE());
	CALL insert_coach(_coach_id, _coach_nick_name, _team_name, skills);
    CALL insert_professional(_pro_id, _nick_name, _team_name, CURDATE());
END$$
DELIMITER ;


DELETE FROM Coach WHERE Coach_id = 'EMP0031';
DELETE FROM Coach WHERE Coach_id = 'EMP0032';
DELETE FROM Coach WHERE Coach_id = 'EMP0033';
##################################################### STREAMER #################################################################

/*
DELIMITER $$
CREATE PROCEDURE insert_team (IN _team_name VARCHAR(50), IN _status enum('Running', 'Not enough member'), IN _start_date DATE)
BEGIN
	IF NOT EXISTS (select team_name FROM teaam WHERE team_name.NEW = Team) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This game does not exist, can not create professinal player';
	END IF;
END$$
DELIMITER ;*/
    
DELIMITER $$
CREATE PROCEDURE insert_sponser(IN _sponsor_name VARCHAR(50), IN _industry VARCHAR(50), IN _nationality VARCHAR(50),
								IN _team VARCHAR(50), IN _start_date DATE, IN _end_date DATE, IN _money DECIMAL(10,2))
BEGIN
	IF NOT EXISTS (select team_name FROM team WHERE team_name = _team) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This team does not exist, can not create sponsor';
	END IF;
    INSERT INTO sponsor(sponsor_name, industry, nationality) VALUE (_sponsor_name, _industry, _nationality);
    INSERT INTO sponsorship(sponsor, team, start_date, end_date, money) VALUE (_sponsor_name, _team, _start_date, _end_date, _money);
END$$
DELIMITER ;


#Nguyen Ngoc Dinh Khoa
# HAHA
