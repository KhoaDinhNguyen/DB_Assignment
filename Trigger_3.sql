# Trang 5: Thông tin của platform.
DROP PROCEDURE get_info_from_platform;
DELIMITER $$
CREATE PROCEDURE get_info_from_platform()
BEGIN
	SELECT plat.platform_name as "Platform name", plat.url AS "URL" FROM game_company.platform plat; 
END$$
DELIMITER ;
CALL get_info_from_platform;


#Hiện list các production và các thông tin cơ bản gồm: name, name streamer, like, view.
DROP PROCEDURE get_info_from_platform_byName;
DELIMITER $$
CREATE PROCEDURE get_info_from_platform_byName(platName varchar(50))
BEGIN
	SELECT pro.production_name AS "Title" , play.Nick_Name AS "Nick name", pro.num_likes "Likes", pro.view AS "Views" FROM game_company.production pro
    JOIN
		game_company.account acc
	ON 
		acc.account_id = pro.account
	JOIN
		game_company.player play
     ON
		play.Player_Id = acc.owner_id
	WHERE acc.platform_name = platName;
END$$
DELIMITER ;
CALL get_info_from_platform_byName("Twitch");





#Trang 6: Trang thông tin chi tiết của account.
#  dẫn đến trang thông tin chi tiết của production - bằng Account ID
DROP PROCEDURE view_production_info_from_accountID;
DELIMITER $$
CREATE PROCEDURE view_production_info_from_accountID(accID INT) 
BEGIN
    SELECT 
		prod.account "AccoundID",
		prod.platform "Platform",
        prod.url "URL",
		prod.production_name "Title",
        prod.description "Description",
        prod.length "Length",
        prod.num_likes "Likes",
		prod.view "Views"
    FROM 
        game_company.production prod
	WHERE 
		prod.account = accID;
END$$
DELIMITER ;
CALL view_production_info_from_accountID(1);




# Trang 6A: Trang thông tin chi tiết của production (Chỉ có thể vào từ trang platform hoặc trang account).
# 1.Từ platform
DROP PROCEDURE get_details_production_info_from_Platform;
DELIMITER $$
CREATE PROCEDURE  get_details_production_info_from_Platform(platName VARCHAR(50)) 
BEGIN
	SELECT * FROM game_company.production pro
    WHERE 
		pro.platform = platName;
END$$
DELIMITER ;
CALL get_details_production_info_from_Platform("Youtube");


# 2. Từ accountID
DROP PROCEDURE get_details_production_info_from_AccountId;
DELIMITER $$
CREATE PROCEDURE  get_details_production_info_from_AccountID(accID INT) 
BEGIN
	SELECT * FROM game_company.production pro
    WHERE 
		pro.account = accID;
END$$
DELIMITER ;
CALL get_details_production_info_from_AccountId(1);

# 3 Hiện comment từ video
DROP PROCEDURE get_comments_from_URL;
DELIMITER $$
CREATE PROCEDURE  get_comments_from_URL(link VARCHAR(100)) 
BEGIN
	SELECT pro.url AS  "URL", comm.comment FROM game_company.production pro
    JOIN
		game_company.comments comm
	ON 
		pro.url = comm.url
	WHERE
		pro.url = link;
END$$
DELIMITER ;
CALL get_comments_from_URL("https://www.dlive.com/47/Streams/uTM4jvmmGO8");



#Trang 7: Trang thông tin của các sponsor.
#Hiện các thông tin cơ bản của các sponsor gồm name, industry and nationality và danh sách các team tài trợ và tổng số tiền tài trợ.
#Xài function để lấy tổng số tiền tài trợ.
#Không cần trang thông tin chi tiết.
DROP FUNCTION get_total_sponsored_by_name;
DELIMITER $$
CREATE FUNCTION get_total_sponsored_by_name(sponsorName varchar(50)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE toReturn DECIMAL(10,2);
	SELECT  SUM(spon.money) INTO toReturn FROM game_company.sponsorship spon
	GROUP BY 
		spon.sponsor
	HAVING
		spon.sponsor = sponsorName;
	RETURN toReturn;
END$$
DELIMITER ;
SELECT  get_total_sponsored_by_name('Adidas');



# Trang 8: Trang thông tin Donation.
DROP PROCEDURE  view_donation_info;
DELIMITER $$
CREATE PROCEDURE view_donation_info() 
BEGIN
    SELECT 
        dons.viewer AS "Viewer's email",
        players.Nick_Name AS "Streamer Name",
        dons.platform "Platform",
        dons.money "Amount",
        dons.date "Date"
    FROM 
        game_company.donations dons
    JOIN
        game_company.player players ON dons.streamer = players.Player_Id;
END$$
DELIMITER ;
CALL view_donation_info();

# Streamer Nick name
DROP PROCEDURE view_donation_info_streamerName;
DELIMITER $$
CREATE PROCEDURE view_donation_info_streamerName(name 	varchar(50)) 
BEGIN
    SELECT 
        dons.viewer AS "Viewer's email",
        players.Nick_Name AS "Streamer Name",
        dons.platform "Platform",
        dons.money "Amount",
        dons.date "Date"
    FROM 
        game_company.donations dons
    JOIN
        game_company.player players ON dons.streamer = players.Player_Id
	WHERE players.Nick_Name = name;
END$$
DELIMITER ;
CALL view_donation_info_streamerName("kERPx");

# Viewer Name (email)
DROP PROCEDURE view_donation_info_viewerName;
DELIMITER $$
CREATE PROCEDURE view_donation_info_viewerName(viewer_name 	varchar(50)) 
BEGIN
    SELECT 
        dons.viewer AS "Viewer's email",
        players.Nick_Name AS "Streamer Name",
        dons.platform AS "Platform",
        dons.money AS "Amount",
        dons.date AS "Date"
    FROM 
        game_company.donations dons
    JOIN
        game_company.player players ON dons.streamer = players.Player_Id
	WHERE dons.viewer = viewer_name;
END$$
DELIMITER ;
CALL view_donation_info_viewerName("asdasdadasd");


DROP PROCEDURE view_donation_info_platform;
DELIMITER $$
CREATE PROCEDURE view_donation_info_platform(platform_name	varchar(50)) 
BEGIN
    SELECT 
        dons.viewer AS "Viewer's email",
        players.Nick_Name AS "Streamer Name",
        dons.platform "Platform",
        dons.money "Amount",
        dons.date "Date"
    FROM 
        game_company.donations dons
    JOIN
        game_company.player players ON dons.streamer = players.Player_Id
	JOIN game_company.platform plat ON plat.platform_name = dons.platform
	WHERE platform_name = dons.platform;
END$$
DELIMITER ;
CALL view_donation_info_platform("Twitch");
# Trang 9 Trang thông tin Viewer.







#Trang 9: Trang thông tin Viewer
DROP PROCEDURE group_donation_info_by_email;
DELIMITER $$
CREATE PROCEDURE  group_donation_info_by_email()
BEGIN
	SELECT donas.viewer "Viewer's email", viewer.name AS "Viewer's name", viewer.age AS "Age" , SUM(donas.money) AS "Total Donated" FROM game_company.donations donas
    JOIN game_company.viewer viewer
    ON
		viewer.email = donas.viewer
    GROUP BY
		donas.viewer;
END$$
DELIMITER ;

CALL  group_donation_info_by_email;

# Function: trả về tổng số tiền đã bỏ ra.
DROP FUNCTION get_total_donation_from_viewer_email;
DELIMITER $$
CREATE FUNCTION get_total_donation_from_viewer_email(email varchar(50)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE toReturn DECIMAL(10,2);
	SELECT  SUM(dons.money) INTO toReturn FROM game_company.donations dons
	GROUP BY 
		dons.viewer
	HAVING
		dons.viewer = email;
	RETURN toReturn;
END$$
DELIMITER ;
SELECT get_total_donation_from_viewer_email("trieu.phamnguyenminh@hcmut.edu.vn");


# Function: trả về tổng của streamer từ donation *nhân viên lãnh 30% tổng tiền).
DROP FUNCTION get_streamer_donation_cut_with_empid;
DELIMITER $$
CREATE FUNCTION get_streamer_donation_cut_with_empid(id char(7)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE toReturn DECIMAL(10,2);
	IF id NOT IN (SELECT streamer FROM  game_company.donations) 
		THEN  SET toReturn = 0.0;
    END IF;
	SELECT  SUM(dons.money) INTO toReturn FROM game_company.donations dons
	GROUP BY 
		dons.streamer
	HAVING
		dons.streamer = id;
    SET toReturn = toReturn * 0.7;
    

    
	RETURN toReturn;
END$$
DELIMITER ;

SELECT dona.streamer, SUM(money) as 'Total donation' FROM game_company.donations dona 
	GROUP BY dona.streamer
	HAVING dona.streamer = "EMP0016";
SELECT get_streamer_donation_cut_with_empid('EMP0016');



##
USE game_company;
# The money for donation of each time must be between 0.4$ and 20$ for the viewer to streamer.
DELIMITER $$
CREATE TRIGGER invalid_donation_money BEFORE INSERT ON game_company.donations
FOR EACH ROW
BEGIN
	IF NEW.money NOT BETWEEN 0.4 AND 20 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The money for donation of each time must be between 0.4$ and 20$.';
	END IF;
    
    IF timediff(NEW.date, curdate()) > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid donation date.';
    END IF;
    
    
	IF (NEW.streamer, NEW.viewer, NEW.platform) NOT IN (SELECT * FROM 	game_company.donating) THEN
		INSERT INTO game_company.donating  (streamer, viewer, platform) VALUES
        (NEW.streamer, NEW.viewer, NEW.platform);
    END IF;
END $$
DELIMITER ;

INSERT INTO game_company.donations VALUES('EMP0028', 'nhat.tran2402@hcmut.edu.vn', 'Facebook Gaming', '2022-12-27', 999.4);
INSERT INTO game_company.donations VALUES('EMP0028', 'nhat.tran2402@hcmut.edu.vn', 'Facebook Gaming', '2022-12-27', -0.5);

