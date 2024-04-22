USE GAME_COMPANY;

######################################################### STAFF ###############################################################
SET @staff_id_insert = '';

DELIMITER $$
CREATE PROCEDURE insert_staff(IN _ssn CHAR(10), IN _Dob date, IN _Name VARCHAR(50), IN _Salary DECIMAL(10,2), IN _Street VARCHAR(50), IN _City VARCHAR(50), IN _phone CHAR(10))
BEGIN
    # INSERT STAFF INFO
	INSERT INTO Staff(Ssn, Dob, Name, Salary, Street, City) VALUE (_ssn, _Dob, _Name, _Salary, _Street, _City);
    
	SELECT staff_id INTO @staff_id_insert FROM Staff WHERE ssn = _ssn;
	INSERT INTO Staff_phones(staff_id, phone) VALUE (@staff_id_insert, phone);
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
CALL insert_staff_streamer('123456789', '2004-05-13', 'Nguyen Ngoc Dinh Khoa', 1234, 'Le Van Tho', 'Ho Chi Minh', '0394913053', 'nhock', '1111111');
SELECT * FROM staff;
SELECT* FROM streamer;
SELECT* FROM play;

##################################################### GAME #################################################################


##################################################### TEAM #################################################################
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

DELETE FROM Coach WHERE Coach_id = 'EMP0031';
DELETE FROM Coach WHERE Coach_id = 'EMP0032';
DELETE FROM Coach WHERE Coach_id = 'EMP0033';
##################################################### STREAMER #################################################################

# INSERT COACH OR PROFESSIONAL PLAYER WITHOUT COACH
DELIMITER $$
CREATE TRIGGER coach_condition BEFORE INSERT ON Coach 
FOR EACH ROW
BEGIN
	IF NOT EXISTS (select team_name FROM team WHERE team_name.NEW = Team) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This game does not exist, can not create coach';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER professional_condition BEFORE INSERT ON Professional_Player 
FOR EACH ROW
BEGIN
	IF NOT EXISTS (select team_name FROM teaam WHERE team_name.NEW = Team) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This game does not exist, can not create professinal player';
	END IF;
END$$
DELIMITER ;

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