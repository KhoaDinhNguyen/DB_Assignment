USE GAME_COMPANY;

DELIMITER $$
CREATE FUNCTION Team_Salary_from_Sponser(_team_name VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE sum DECIMAL(10,2);
	IF (NOT EXISTS(SELECT * FROM sponsorship WHERE team = _team_name)) THEN
		RETURN 0.00;
	ELSE
		SELECT SUM(money) INTO sum
        FROM sponsorship
        WHERE team = _team_name;
        RETURN sum;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION Team_Salary_from_Tournament(_team_name VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE sum DECIMAL(10,2);
	IF (NOT EXISTS(SELECT * FROM Tournament WHERE joined_team = _team_name AND competition_year = YEAR(CURDATE()) - 1)) THEN
		RETURN 0.00;
	ELSE
		SELECT SUM(reward) INTO sum
        FROM Tournament
        WHERE joined_team = _team_name AND competition_year = YEAR(CURDATE()) - 1;
        RETURN sum;
	END IF;
END $$
DELIMITER ;

CREATE VIEW Team_Salary_Sponser AS
SELECT Team_name, Team_Salary_from_sponser(Team_name) AS Sponser_money
FROM team
GROUP BY team_name;

CREATE VIEW Team_Salary_Tournament AS
SELECT Team_name, Team_Salary_from_Tournament(Team_name) AS Reward_money, 
	CASE 
		WHEN Team_Salary_from_Tournament(Team_name) = 0.00 AND YEAR(start_date) != YEAR(CURDATE()) THEN 0.8
        ELSE 1
	END AS Proportion
FROM team
GROUP BY team_name;

DELIMITER $$
CREATE FUNCTION number_of_people(_team_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE num1 INT;
    DECLARE num2 INT;
    
    SELECT COUNT(*) INTO num1
    FROM Professional_Player
    WHERE Team = _team_name;

	SELECT COUNT(*) INTO num2
    FROM Coach
    WHERE Team = _team_name;
    
	RETURN num1 + num2;
END $$
DELIMITER ;

CREATE VIEW Team_Salary AS
SELECT t1.Team_name , Reward_money, Proportion, Sponser_money, number_of_people(t1.team_name) AS number_of_player
FROM Team_Salary_Tournament t1
JOIN Team_Salary_Sponser t2
ON t1.Team_name = t2.team_name;

DELIMITER $$
CREATE FUNCTION Team_Salary_Per_Person(_team_name VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE money DECIMAL(10,2);
    
    SELECT (Reward_money + Sponser_money / 12) * Proportion / number_of_player INTO money
    FROM Team_Salary
    WHERE Team_name = _team_name;

	RETURN money;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION belong_to_team(_Staff_Id CHAR(7))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE team_name VARCHAR(50);
    IF(EXISTS (SELECT team FROM Coach WHERE Coach_id = _Staff_Id)) THEN 
		SELECT team INTO team_name FROM Coach WHERE Coach_id = _Staff_Id;
		RETURN team_name;
	ELSEIF (EXISTS (SELECT team FROM Professional_Player WHERE Player_Id = _Staff_Id)) THEN
		SELECT team INTO team_name FROM Professional_Player WHERE Player_Id = _Staff_Id;
		RETURN team_name;
    END IF;
    RETURN 'NULL';
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION salary(_Staff_Id CHAR(7))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE team_name VARCHAR(50);
    DECLARE _salary DECIMAL(10,2);
    SET team_name = belong_to_team(_Staff_id);
	SELECT Salary INTO _salary FROM Staff WHERE Staff_Id = _Staff_Id;
    IF(team_name = 'NULL') THEN RETURN _salary;
    ELSE RETURN _salary + Team_Salary_Per_Person(team_name);
    END IF;
END $$
DELIMITER ;

SELECT * FROM Team_Salary_Tournament;
SELECT * FROM Team_Salary_Sponser;
SELECT * FROM Team_Salary;
SELECT Staff_id, Name, salary(Staff_id) AS Salary
FROM Staff;



