DROP DATABASE game_company;
CREATE DATABASE GAME_COMPANY;
use GAME_COMPANY;
SET SQL_SAFE_UPDATES = 0;

SELECT LAST_INSERT_ID(NULL);

CREATE TABLE id_count (
  id INT AUTO_INCREMENT PRIMARY KEY
);

create table Staff (
	Staff_Id	char(7) PRIMARY KEY,
    SSN			char(10)	not null unique,
    DoB			date,
    Name		varchar(50),
    Salary 		decimal(10,2),
    Street 		varchar(50),
    City 		varchar(50)
    #constraint 	total_disjoint_staff
);

DELIMITER $$
CREATE TRIGGER insert_staff BEFORE INSERT ON staff
FOR EACH ROW 
BEGIN
	INSERT INTO id_count VALUES (NULL);
	SET NEW.staff_id = CONCAT('EMP', LPAD(LAST_INSERT_ID(), 4, '0'));
END $$
DELIMITER ;

create table Staff_Phones (
	Staff_Id	char(7),
    Phone		char(10),
    primary key (Staff_Id, Phone),
    constraint Staff_Phones_FK_Staff_Id foreign key (Staff_Id) references Staff (Staff_Id) on delete cascade on update cascade
);

create table Game (
	Game_Id		char(7) primary key,
    Name 		varchar(50),
    Creator		varchar(50),
    Year_Release	char(4)
);

create table team (
	team_name		varchar(50)		primary key,
    Game_ID			char(7) not null,
    status			enum('Running', 'Not enough member'),
    start_date	date,
	constraint team_FK_game foreign key (Game_ID) references game(game_id) on delete cascade on update cascade
);

create table Player (
	Nick_Name 	varchar(50),
    Player_Id 	char(7) primary key,
	constraint Player_FK_Player_Id foreign key (Player_Id) references Staff (Staff_Id) on delete cascade on update cascade
);

create table Coach (
	Nick_Name 	varchar(50),
    Coach_Id	char(7)	primary key,
    Team 		varchar(50) not null,
	constraint Coach_FK_Coach_Id foreign key (Coach_Id) references Staff (Staff_Id) on delete cascade on update cascade,
    constraint Team_FK_Team_ID foreign key (Team) references Team (Team_name) on delete cascade on update cascade
);

create table Coach_Skills (
	Coach_Id	char(7),
    Skill		enum('Financial Insurance', 'Health Management', 'Food Ensuring', 'Gameplay Strategy', 'Mental Health',
					'Time Management', 'Sport and Body Builder'),
    primary key (Coach_Id, Skill),
    constraint Coach_Skills_FK_Coach_Id foreign key (Coach_Id) references Coach (Coach_Id) on delete cascade on update cascade
);

create table Game_Genres (
	Game_Id 	char(7),
    Genre		varchar(50),
    primary key (Game_Id, Genre),
    constraint Game_genres_FK_Game_Id foreign key (Game_Id) references Game (Game_Id) on delete cascade on update cascade
);

create table Play (
	Game	char(7),
    Player 	char(7),
    primary key (Game, Player),
    constraint Play_FK_Game foreign key (Game) references Game (Game_Id) on delete cascade on update cascade,
    constraint PLay_FK_Player foreign key (Player) references Player (Player_Id) on delete cascade on update cascade
);

create table Dependencies (
	Staff	char(7),
    Name	varchar(50),
    Job		varchar(50),
    Relationship	varchar(50),
    primary key (Staff, Name),
    constraint Dependencies_FK_Staff_Id foreign key (Staff) references Staff (Staff_Id) on delete cascade on update cascade
);

create table Contract (
	Contract_Id	char(7)	primary key,
    term 		varchar(50),
    policy		varchar(50),
    Start_Date	date,
    End_Date	date,
    Staff		char(7) not null,
	constraint Contract_FK_staff_contract foreign key (Staff) references Staff (Staff_Id) on delete cascade on update cascade
);

create table Professional_Player (
	Player_Id 	char(7) primary key,
    Debut_Date 	date,
    Team		varchar(50) not null,
	constraint Professional_Player_FK_Player_Id foreign key (Player_Id) references Player (Player_Id) on delete cascade on update cascade,
    constraint Professional_Player_FK_Team foreign key (Team) references Team (Team_Name) on delete cascade on update cascade
);

create table Streamer (
	Player_Id 	char(7) primary key,
    constraint Streamer_FK_Player_Id foreign key (Player_Id) references Player (Player_Id) on delete cascade on update cascade
);

create table sponsor (
	sponsor_name	varchar(50)		primary key,
    industry		varchar(50),
    nationality		varchar(30)		not null	default("American")
);

create table sponsorship (
	sponsor			varchar(50),
    team			varchar(50),
    start_date		date		not null,
    end_date		date,
    money			decimal(10,2),
    primary key (sponsor, team),
    constraint sponsorship_FK_sponsor foreign key (sponsor) references sponsor(sponsor_name) on delete cascade on update cascade,
    constraint sponsorship_FK_team foreign key (team) references team(team_name) on delete cascade on update cascade
);

create table tournament (
	competition_name	varchar(50),
	competition_year	year,
    result				enum ("Champion", "Runnerup", "Semifinal", "Quarterfinal", "Group Stage", "In process")	not null	default("Group Stage"),
	game				char(7)		not null,
    reward				decimal(10,2),
    joined_team			varchar(50),
    start_date			date	not null,
    end_date			date,
    primary key	(competition_name, competition_year),
    constraint tournament_FK_game foreign key (game) references game(game_id) on delete cascade on update cascade,
    constraint tournament_FK_team foreign key (joined_team) references team(team_name) on delete cascade on update cascade
);

alter table tournament modify column
    result				enum ("Champion", "Runnerup", "Semifinal", "Quarterfinal", "Group Stage", "In process")	not null	default("Group Stage")
;

create table viewer	(
	email			varchar(50) primary key,
    age				int,
    name			varchar(50)	not null
);

create table platform (
	platform_name	varchar(50) primary key,
    url				varchar(100)	not null	unique,
    parent_company	varchar(50)
);

create table donating (
	streamer		char(7),
    viewer			varchar(50),
    platform		varchar(50),
    primary key (streamer, viewer, platform),
    constraint donating_FK_streamer foreign key (streamer) references streamer(player_id) on delete cascade on update cascade,
    constraint donating_FK_viewer foreign key	(viewer) references viewer(email) on delete cascade on update cascade,
    constraint donating_FK_platform foreign key (platform) references platform(platform_name) on delete cascade on update cascade
);

create table donations (
	streamer		char(7),
    viewer			varchar(50),
    platform		varchar(50),
	date			date,
    money			decimal(10,2)	not null,
    primary key (streamer, viewer, platform, date),
    constraint donations_FK_donating foreign key (streamer, viewer, platform) references donating(streamer, viewer, platform) on delete cascade on update cascade,
    constraint donations_limit_money check (money >= 0.4 AND money <= 20)
);

create table account (
	num_subcribers	int			not null,
    name			varchar(50) not null,
	platform_name	varchar(50),
    account_id		int,
    owner_id		char(10)	not null,
    primary key (platform_name, account_id),
    constraint account_FK_platform foreign key (platform_name) references platform(platform_name) on delete cascade on update cascade,
    constraint account_FK_streamer foreign key (owner_id) references streamer(player_id) on delete cascade on update cascade
);

create table production (
	url				varchar(100)	primary key,
    length			int,
    account			int not null,
    platform 		varchar(50) not null,
    production_name	varchar(100) not null,
    view			int,
    description		varchar(150),
    num_likes			int,
    constraint production_FK_account foreign key (platform, account) references account(platform_name, account_id) on delete cascade on update cascade
);

create table stream_session (
	date		date,
    time_start	time,
    url			varchar(100)	primary key,
    constraint stream_FK_production foreign key (url) references production(url) on delete cascade on update cascade
);

create table video (
	watch_time	int,
    url			varchar(100) primary key,
    constraint video_FK_production foreign key (url) references production(url) on delete cascade on update cascade
);

create table comments (
	url			varchar(100),
    comment		varchar(150),
    primary key (url, comment),
    constraint comments_FK_production foreign key (url) references production(url) on delete cascade on update cascade
);