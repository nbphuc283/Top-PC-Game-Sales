/* Fill the blank in the 'series' column */
UPDATE pc_games
SET series = "Name"
WHERE series = '';

/* Change the "Release" column 'Mon-YYYY' format */
UPDATE pc_games
SET "Release" = TO_DATE("Release", 'Mon-YY');

/* Add two new columns 'year_released' & 'month_released' for analysis */
ALTER TABLE pc_games
ADD COLUMN year_released TEXT,
ADD COLUMN month_released TEXT;

UPDATE pc_games 
SET year_released = DATE_PART('Year', "Release"::DATE), 
	month_released = DATE_PART('Month', "Release"::DATE);

-------------------------------------------------

/* Count number of games, total sales & total sales per game for each series */
SELECT series, COUNT("Name") AS number_of_games, SUM(sales) AS total_sales,
	SUM(sales)::REAL / COUNT("Name") AS sales_per_game
FROM pc_games
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10;

/*
series                       |number_of_games|total_sales|sales_per_game   |
-----------------------------+---------------+-----------+-----------------+
PlayerUnknown's Battlegrounds|              1|         42|             42.0|
Minecraft                    |              1|         33|             33.0|
Garry's Mod                  |              1|         20|             20.0|
Terraria                     |              1|         17|             17.0|
Half-Life                    |              2|         21|             10.5|
Fall Guys                    |              1|         10|             10.0|
Rust                         |              1|          9|              9.0|
Diablo                       |              3|         26|8.666666666666666|
The Sims                     |              3|         24|              8.0|
RollerCoaster Tycoon         |              2|         14|              7.0|
*/

/* Count number of games, total sales & total sales per game for each developer */
SELECT developer, COUNT("Name") AS number_of_games, SUM(sales) AS total_sales, 
	SUM(sales)::REAL / COUNT("Name") AS sales_per_game
FROM pc_games
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10;

/*
developer             |number_of_games|total_sales|sales_per_game|
----------------------+---------------+-----------+--------------+
PUBG Studios          |              1|         42|          42.0|
Mojang Studios        |              1|         33|          33.0|
Re-Logic              |              1|         17|          17.0|
Facepunch Studios     |              2|         29|          14.5|
Mediatonic            |              1|         10|          10.0|
Blizzard Entertainment|              8|         58|          7.25|
Valve                 |              4|         25|          6.25|
Iron Gate             |              1|          6|           6.0|
Frontier Developments |              2|         12|           6.0|
Maxis                 |              6|         33|           5.5|
*/

/* Sales by year for each developer */
WITH a AS (
SELECT 
	ROW_NUMBER () OVER (
		PARTITION BY developer, year_released
		ORDER BY year_released),
		developer, year_released, 
	SUM(sales) OVER (
		PARTITION BY developer
		ORDER BY year_released) running_total_sales,
	COUNT("Name") OVER (
		PARTITION BY developer
		ORDER BY year_released) running_number_of_games
FROM pc_games)
SELECT developer, year_released, running_total_sales, running_number_of_games,
	(running_total_sales::REAL / running_number_of_games::REAL) AS running_sales_per_game
FROM a
WHERE row_number = 1;

/*
developer                            |year_released|running_total_sales|running_number_of_games|running_sales_per_game|
-------------------------------------+-------------+-------------------+-----------------------+----------------------+
3D Realms                            |1996         |                  1|                      1|                   1.0|
Amanita Design                       |2009         |                  1|                      1|                   1.0|
ArenaNet                             |2005         |                  6|                      1|                   6.0|
ArenaNet                             |2012         |                 11|                      2|                   5.5|
Arrowhead Game Studios               |2011         |                  2|                      1|                   2.0|
Ascaron                              |2003         |                  1|                      1|                   1.0|
Ascaron                              |2004         |                  2|                      2|                   1.0|
BioWare                              |1998         |                  2|                      1|                   2.0|
BioWare                              |2000         |                  4|                      2|                   2.0|
BioWare                              |2002         |                  6|                      3|                   2.0|
Blizzard Entertainment               |1995         |                  2|                      1|                   2.0|
Blizzard Entertainment               |1998         |                 13|                      2|                   6.5|
Blizzard Entertainment               |2002         |                 16|                      3|             5.3333335|
Blizzard Entertainment               |2004         |                 30|                      4|                   7.5|
Blizzard Entertainment               |2010         |                 36|                      5|                   7.2|
Blizzard Entertainment               |2012         |                 56|                      6|              9.333333|
Blizzard Entertainment               |2013         |                 57|                      7|              8.142858|
Blizzard Entertainment               |2015         |                 58|                      8|                  7.25|
Blizzard North                       |1996         |                  2|                      1|                   2.0|
Blizzard North                       |2000         |                  6|                      2|                   3.0|
Bohemia Interactive                  |2013         |                  9|                      2|                   4.5|
Bohemia Interactive Studio           |2001         |                  1|                      1|                   1.0|
Broderbund                           |1985         |                  4|                      1|                   4.0|
Bullfrog Productions                 |1989         |                  4|                      1|                   4.0|
Bullfrog Productions                 |2005         |                  7|                      2|                   3.5|
Capcom                               |2009         |                  2|                      2|                   1.0|
Capcom                               |2013         |                  3|                      3|                   1.0|
Capcom                               |2014         |                  4|                      4|                   1.0|
Cavedog Entertainment                |1997         |                  1|                      1|                   1.0|
CD Projekt Red                       |2007         |                  2|                      1|                   2.0|
CD Projekt Red                       |2011         |                  4|                      2|                   2.0|
CD Projekt Red                       |2015         |                 16|                      3|             5.3333335|
CD Projekt Red                       |2020         |                 20|                      4|                   5.0|
Chris Sawyer                         |1999         |                  4|                      1|                   4.0|
Coffee Stain Studios                 |2019         |                  1|                      1|                   1.0|
Colossal Order                       |2015         |                  5|                      1|                   5.0|
ConcernedApe                         |2016         |                  1|                      1|                   1.0|
Crytek                               |2004         |                  2|                      1|                   2.0|
Crytek                               |2007         |                  5|                      2|                   2.5|
Crytek Budapest                      |2008         |                  1|                      1|                   1.0|
Cyan                                 |1993         |                  2|                      1|                   2.0|
Data East                            |1988         |                  1|                      1|                   1.0|
Daybreak Game Company                |2015         |                  1|                      1|                   1.0|
Dontnod Entertainment                |2015         |                  3|                      1|                   3.0|
Double Fine Productions              |2005         |                  1|                      1|                   1.0|
EA DICE                              |2002         |                  2|                      1|                   2.0|
EA DICE                              |2004         |                  3|                      2|                   1.5|
EA Los Angeles                       |2007         |                  1|                      1|                   1.0|
Edmund McMillen & Florian Himsl      |2011         |                  2|                      1|                   2.0|
Electronic Arts                      |2013         |                  2|                      1|                   2.0|
Endnight Games                       |2018         |                  5|                      1|                   5.0|
Enlight Software                     |2002         |                  1|                      1|                   1.0|
Ensemble Studios                     |1997         |                  3|                      1|                   3.0|
Ensemble Studios                     |1999         |                  5|                      2|                   2.5|
Ensemble Studios                     |2002         |                  6|                      3|                   2.0|
Ensemble Studios                     |2005         |                  8|                      4|                   2.0|
Epic Games                           |1998         |                  1|                      1|                   1.0|
Epic Games                           |1999         |                  2|                      2|                   1.0|
Facepunch Studios                    |2006         |                 20|                      1|                  20.0|
Facepunch Studios                    |2018         |                 29|                      2|                  14.5|
Firaxis Games                        |2001         |                  2|                      1|                   2.0|
Firaxis Games                        |2005         |                  5|                      2|                   2.5|
Firaxis Games                        |2010         |                 13|                      3|             4.3333335|
Firefly Studios                      |2001         |                  1|                      1|                   1.0|
Firefly Studios                      |2002         |                  3|                      2|                   1.5|
FromSoftware                         |2012         |                  3|                      1|                   3.0|
FromSoftware                         |2014         |                  5|                      2|                   2.5|
FromSoftware                         |2016         |                  8|                      3|             2.6666667|
Frontier Developments                |2004         |                 10|                      1|                  10.0|
Frontier Developments                |2016         |                 12|                      2|                   6.0|
Galactic Cafe                        |2013         |                  1|                      1|                   1.0|
Gas Powered Games                    |2002         |                  1|                      1|                   1.0|
Gas Powered Games                    |2007         |                  2|                      2|                   1.0|
Gray Matter Interactive              |2001         |                  1|                      1|                   1.0|
GSC Game World                       |2005         |                  2|                      1|                   2.0|
Haemimont Games                      |2005         |                  1|                      1|                   1.0|
Haemimont Games                      |2006         |                  2|                      2|                   1.0|
Heuristic Park                       |2005         |                  1|                      1|                   1.0|
id Software                          |1993         |                  2|                      1|                   2.0|
id Software                          |1994         |                  4|                      2|                   2.0|
id Software                          |1996         |                  5|                      3|             1.6666666|
id Software                          |1997         |                  6|                      4|                   1.5|
Illusion Softworks                   |1999         |                  1|                      1|                   1.0|
Illusion Softworks                   |2002         |                  3|                      2|                   1.5|
Illusion Softworks                   |2003         |                  4|                      3|             1.3333334|
Impressions Game                     |1995         |                  2|                      1|                   2.0|
Impressions Game                     |1996         |                  4|                      2|                   2.0|
Impressions Game                     |1999         |                  6|                      3|                   2.0|
Infocom                              |1993         |                  1|                      1|                   1.0|
Introversion Software                |2012         |                  1|                      1|                   1.0|
Iron Gate                            |2021         |                  6|                      1|                   6.0|
Irrational Games                     |2007         |                  1|                      1|                   1.0|
Jellyvision                          |1999         |                  1|                      1|                   1.0|
Keen Software House                  |2013         |                  2|                      1|                   2.0|
KnowWonder                           |2001         |                  1|                      1|                   1.0|
Kojima Productions                   |2015         |                  1|                      1|                   1.0|
Landfall Games                       |2017         |                  2|                      1|                   2.0|
Larian Studios                       |2017         |                  1|                      1|                   1.0|
Lionhead Studios                     |2001         |                  2|                      1|                   2.0|
LucasArts                            |1993         |                  1|                      1|                   1.0|
LucasArts                            |1995         |                  2|                      2|                   1.0|
Max Design                           |1998         |                  2|                      1|                   2.0|
Max Design                           |2003         |                  4|                      2|                   2.0|
Maxis                                |1999         |                  5|                      1|                   5.0|
Maxis                                |2000         |                 16|                      2|                   8.0|
Maxis                                |2003         |                 18|                      3|                   6.0|
Maxis                                |2004         |                 24|                      4|                   6.0|
Maxis                                |2008         |                 26|                      5|                   5.2|
Maxis                                |2009         |                 33|                      6|                   5.5|
Mediatonic                           |2020         |                 10|                      1|                  10.0|
MicroProse                           |1996         |                  2|                      2|                   1.0|
Microsoft                            |2001         |                  1|                      1|                   1.0|
Microsoft Game Studios               |2006         |                  1|                      1|                   1.0|
Mojang Studios                       |2011         |                 33|                      1|                  33.0|
Mythic Entertainment                 |2008         |                  1|                      1|                   1.0|
Namco Bandai Games                   |2013         |                  1|                      1|                   1.0|
Origin Systems                       |1994         |                  1|                      1|                   1.0|
Paradox Development Studio           |2012         |                  1|                      1|                   1.0|
Paradox Development Studio           |2013         |                  2|                      2|                   1.0|
Paradox Development Studio           |2016         |                  4|                      4|                   1.0|
Paradox Development Studio           |2020         |                  5|                      5|                   1.0|
Péndulo Studios, S.L.                |2001         |                  1|                      1|                   1.0|
PlatinumGames                        |2017         |                  1|                      1|                   1.0|
PopTop Software                      |1998         |                  1|                      1|                   1.0|
PopTop Software                      |2001         |                  2|                      2|                   1.0|
Pterodon                             |2003         |                  1|                      1|                   1.0|
PUBG Studios                         |2017         |                 42|                      1|                  42.0|
Pyro Studios                         |1998         |                  1|                      1|                   1.0|
Re-Logic                             |2011         |                 17|                      1|                  17.0|
Relic Entertainment                  |2004         |                  4|                      1|                   4.0|
Rockstar North                       |2015         |                  2|                      1|                   2.0|
Rogue Entertainment                  |2000         |                  1|                      1|                   1.0|
SCE Cambridge Studio                 |1997         |                  1|                      1|                   1.0|
SCS Software                         |2012         |                  7|                      2|                   3.5|
Sega                                 |2010         |                  1|                      1|                   1.0|
Sierra Online                        |1995         |                  2|                      2|                   1.0|
Softstar                             |2011         |                  1|                      1|                   1.0|
Softstar Entertainment               |2003         |                  1|                      1|                   1.0|
Sony Online Entertainment            |2003         |                  1|                      1|                   1.0|
Spectrum HoloByte                    |1988         |                  1|                      1|                   1.0|
Spike Chunsoft                       |2016         |                  2|                      2|                   1.0|
Square                               |1998         |                  2|                      1|                   2.0|
Stainless Steel Studios              |2001         |                  1|                      1|                   1.0|
Studio Wildcard                      |2015         |                  1|                      1|                   1.0|
StudioMDHR                           |2017         |                  1|                      1|                   1.0|
Sunstorm Interactive                 |1997         |                  1|                      1|                   1.0|
System 3                             |1985         |                  1|                      1|                   1.0|
System 3                             |1988         |                  6|                      2|                   3.0|
System 3                             |2005         |                 10|                      3|             3.3333333|
Team Cherry                          |2017         |                  1|                      1|                   1.0|
Technology and Entertainment Software|1984         |                  1|                      1|                   1.0|
The Creative Assembly                |2004         |                  1|                      1|                   1.0|
The Fun Pimps                        |2016         |                  2|                      1|                   2.0|
Tripwire Interactive                 |2009         |                  1|                      1|                   1.0|
Triternion                           |2019         |                  1|                      1|                   1.0|
Ubisoft                              |1997         |                  2|                      1|                   2.0|
Valve                                |1998         |                  9|                      1|                   9.0|
Valve                                |2004         |                 25|                      4|                  6.25|
Verant Interactive                   |1999         |                  3|                      1|                   3.0|
Warhorse Studios                     |2018         |                  1|                      1|                   1.0|
Westwood Pacific                     |2000         |                  1|                      1|                   1.0|
Westwood Studios                     |1995         |                  3|                      1|                   3.0|
Westwood Studios                     |1996         |                  6|                      2|                   3.0|
Westwood Studios                     |1997         |                  7|                      3|             2.3333333|
Westwood Studios                     |1999         |                  8|                      4|                   2.0|
Wube Software                        |2016         |                  2|                      1|                   2.0|
*/

/* Count number of games, total sales & total sales per game for each publisher */
SELECT publisher, COUNT("Name") AS number_of_games, SUM(sales) AS total_sales,
	SUM(sales)::REAL / COUNT("Name") AS sales_per_game
FROM pc_games
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10;

/*
publisher             |number_of_games|total_sales|sales_per_game|
----------------------+---------------+-----------+--------------+
Krafton               |              1|         42|          42.0|
Mojang Studios        |              1|         33|          33.0|
Valve                 |              1|         20|          20.0|
Re-Logic              |              1|         17|          17.0|
Devolver Digital      |              1|         10|          10.0|
Atari, Inc. (Windows) |              1|         10|          10.0|
Facepunch Studios     |              1|          9|           9.0|
Blizzard Entertainment|              8|         59|         7.375|
Valve (digital)       |              2|         14|           7.0|
CD Projekt            |              3|         18|           6.0|
 */

/* Sales by year for each publisher */
WITH a AS (
SELECT 
	ROW_NUMBER () OVER (
		PARTITION BY publisher, year_released
		ORDER BY year_released),
		publisher, year_released, 
	SUM(sales) OVER (
		PARTITION BY publisher
		ORDER BY year_released) running_total_sales,
	COUNT("Name") OVER (
		PARTITION BY publisher
		ORDER BY year_released) running_number_of_games
FROM pc_games)
SELECT publisher, year_released, running_total_sales, running_number_of_games,
	(running_total_sales::REAL / running_number_of_games::REAL) AS running_sales_per_game
FROM a
WHERE row_number = 1;

/*
publisher                                     |year_released|running_total_sales|running_number_of_games|running_sales_per_game|
----------------------------------------------+-------------+-------------------+-----------------------+----------------------+
2K Games                                      |2007         |                  1|                      1|                   1.0|
2K Games & Aspyr                              |2005         |                  3|                      1|                   3.0|
2K Games & Aspyr                              |2010         |                 11|                      2|                   5.5|
Activision                                    |1988         |                  5|                      1|                   5.0|
Activision                                    |1993         |                  6|                      2|                   3.0|
Activision                                    |1997         |                  7|                      3|             2.3333333|
Activision                                    |2001         |                  8|                      4|                   2.0|
Activision                                    |2004         |                  9|                      5|                   1.8|
Activision                                    |2005         |                 13|                      6|             2.1666667|
Amanita Design                                |2009         |                  1|                      1|                   1.0|
Atari, Inc                                    |2007         |                  2|                      1|                   2.0|
Atari, Inc. (Windows)                         |2004         |                 10|                      1|                  10.0|
Bandai Namco Entertainment                    |2016         |                  3|                      1|                   3.0|
Bandai Namco Games                            |2014         |                  2|                      1|                   2.0|
Blizzard Entertainment                        |1995         |                  2|                      1|                   2.0|
Blizzard Entertainment                        |1998         |                 13|                      2|                   6.5|
Blizzard Entertainment                        |2000         |                 17|                      3|             5.6666665|
Blizzard Entertainment                        |2004         |                 31|                      4|                  7.75|
Blizzard Entertainment                        |2010         |                 37|                      5|                   7.4|
Blizzard Entertainment                        |2012         |                 57|                      6|                   9.5|
Blizzard Entertainment                        |2013         |                 58|                      7|              8.285714|
Blizzard Entertainment                        |2015         |                 59|                      8|                 7.375|
Blizzard Entertainment (North America)        |1996         |                  2|                      1|                   2.0|
Blizzard Entertainment (North America)        |2002         |                  5|                      2|                   2.5|
Blue Fang Games                               |2001         |                  1|                      1|                   1.0|
Bohemia Interactive                           |2013         |                  9|                      2|                   4.5|
Broderbund                                    |1985         |                  4|                      1|                   4.0|
Brøderbund                                    |1993         |                  2|                      1|                   2.0|
Capcom                                        |2009         |                  2|                      2|                   1.0|
Capcom                                        |2013         |                  3|                      3|                   1.0|
Capcom                                        |2014         |                  4|                      4|                   1.0|
CD Projekt                                    |2011         |                  2|                      1|                   2.0|
CD Projekt                                    |2015         |                 14|                      2|                   7.0|
CD Projekt                                    |2020         |                 18|                      3|                   6.0|
CDV Software                                  |2005         |                  2|                      1|                   2.0|
CDV Software                                  |2006         |                  3|                      2|                   1.5|
Codemasters                                   |2001         |                  1|                      1|                   1.0|
Coffee Stain Publishing                       |2019         |                  1|                      1|                   1.0|
Coffee Stain Publishing                       |2021         |                  7|                      2|                   3.5|
ConcernedApe[f]                               |2016         |                  1|                      1|                   1.0|
Data East, Ocean Software                     |1988         |                  1|                      1|                   1.0|
Daybreak Game Company                         |2015         |                  1|                      1|                   1.0|
Devolver Digital                              |2020         |                 10|                      1|                  10.0|
Dinamic Multimedia                            |2001         |                  1|                      1|                   1.0|
Disney Interactive Studios                    |1999         |                  1|                      1|                   1.0|
DreamCatcher Interactive                      |2005         |                  1|                      1|                   1.0|
EA Games                                      |2001         |                  2|                      1|                   2.0|
Eidos Interactive                             |1998         |                  3|                      2|                   1.5|
Electronic Arts                               |1989         |                  4|                      1|                   4.0|
Electronic Arts                               |1994         |                  5|                      2|                   2.5|
Electronic Arts                               |1999         |                 11|                      4|                  2.75|
Electronic Arts                               |2000         |                 24|                      7|             3.4285715|
Electronic Arts                               |2001         |                 25|                      8|                 3.125|
Electronic Arts                               |2002         |                 27|                      9|                   3.0|
Electronic Arts                               |2004         |                 34|                     11|              3.090909|
Electronic Arts                               |2005         |                 37|                     12|             3.0833333|
Electronic Arts                               |2007         |                 41|                     14|             2.9285715|
Electronic Arts                               |2008         |                 45|                     17|             2.6470587|
Electronic Arts                               |2009         |                 52|                     18|             2.8888888|
Electronic Arts                               |2013         |                 54|                     19|             2.8421052|
Electronic Arts (retail)                      |2004         |                  2|                      1|                   2.0|
Electronic Arts (Windows)                     |2003         |                  2|                      1|                   2.0|
Encore                                        |2003         |                  1|                      1|                   1.0|
Encore                                        |2004         |                  2|                      2|                   1.0|
Endnight Games                                |2018         |                  5|                      1|                   5.0|
Epyx                                          |1985         |                  1|                      1|                   1.0|
Facepunch Studios                             |2018         |                  9|                      1|                   9.0|
Frontier Developments                         |2016         |                  2|                      1|                   2.0|
FX Interactive                                |2005         |                  1|                      1|                   1.0|
Galactic Cafe                                 |2013         |                  1|                      1|                   1.0|
Gathering of Developers                       |1998         |                  1|                      1|                   1.0|
Gathering of Developers                       |2001         |                  2|                      2|                   1.0|
Gathering of Developers                       |2002         |                  4|                      3|             1.3333334|
Gathering of Developers                       |2003         |                  5|                      4|                  1.25|
GT Interactive                                |1994         |                  2|                      1|                   2.0|
GT Interactive                                |1996         |                  3|                      2|                   1.5|
GT Interactive                                |1997         |                  4|                      3|             1.3333334|
GT Interactive                                |1998         |                  5|                      4|                  1.25|
GT Interactive                                |1999         |                  6|                      5|                   1.2|
GT Interactive Software                       |1996         |                  1|                      1|                   1.0|
Hasbro Interactive                            |1997         |                  1|                      1|                   1.0|
Headup Games                                  |2011         |                  2|                      1|                   2.0|
id Software                                   |1993         |                  2|                      1|                   2.0|
Impressions Game                              |1996         |                  2|                      1|                   2.0|
Infogrames                                    |2001         |                  2|                      1|                   2.0|
Infogrames / Atari                            |2002         |                  2|                      1|                   2.0|
Interplay Entertainment                       |1998         |                  2|                      1|                   2.0|
Interplay Entertainment                       |2000         |                  4|                      2|                   2.0|
Introversion Software                         |2012         |                  1|                      1|                   1.0|
JoWood Productions                            |2002         |                  1|                      1|                   1.0|
Keen Software House                           |2013         |                  2|                      1|                   2.0|
Konami                                        |2015         |                  1|                      1|                   1.0|
Krafton                                       |2017         |                 42|                      1|                  42.0|
Landfall Games                                |2017         |                  2|                      1|                   2.0|
Larian Studios                                |2017         |                  1|                      1|                   1.0|
LucasArts                                     |1993         |                  1|                      1|                   1.0|
LucasArts                                     |1995         |                  2|                      2|                   1.0|
LucasArts                                     |2003         |                  3|                      3|                   1.0|
MicroProse                                    |1996         |                  2|                      2|                   1.0|
MicroProse Software                           |1999         |                  4|                      1|                   4.0|
Microsoft                                     |1997         |                  3|                      1|                   3.0|
Microsoft                                     |1999         |                  5|                      2|                   2.5|
Microsoft                                     |2002         |                  6|                      3|                   2.0|
Microsoft                                     |2005         |                  8|                      4|                   2.0|
Microsoft Game Studios                        |2002         |                  1|                      1|                   1.0|
Microsoft Game Studios                        |2006         |                  2|                      2|                   1.0|
Mojang Studios                                |2011         |                 33|                      1|                  33.0|
Namco Bandai Games                            |2012         |                  3|                      1|                   3.0|
Namco Bandai Games                            |2013         |                  4|                      2|                   2.0|
NCsoft                                        |2005         |                  6|                      1|                   6.0|
NCsoft                                        |2012         |                 11|                      2|                   5.5|
Paradox Interactive                           |2011         |                  2|                      1|                   2.0|
Paradox Interactive                           |2012         |                  3|                      2|                   1.5|
Paradox Interactive                           |2013         |                  4|                      3|             1.3333334|
Paradox Interactive                           |2015         |                  9|                      4|                  2.25|
Paradox Interactive                           |2016         |                 11|                      6|             1.8333334|
Paradox Interactive                           |2020         |                 12|                      7|             1.7142857|
Re-Logic                                      |2011         |                 17|                      1|                  17.0|
Rockstar Games                                |2015         |                  2|                      1|                   2.0|
SCS Software                                  |2012         |                  7|                      2|                   3.5|
Sega                                          |2010         |                  1|                      1|                   1.0|
Sierra Entertainment                          |1998         |                  9|                      1|                   9.0|
Sierra Entertainment                          |2001         |                 10|                      2|                   5.0|
Sierra On-Line                                |1995         |                  2|                      1|                   2.0|
Sierra Online                                 |1995         |                  2|                      2|                   1.0|
Sierra Studios                                |1999         |                  2|                      1|                   2.0|
Softstar                                      |2011         |                  1|                      1|                   1.0|
Softstar Entertainment                        |2003         |                  1|                      1|                   1.0|
Sony Online Entertainment                     |1999         |                  3|                      1|                   3.0|
Spectrum HoloByte                             |1988         |                  1|                      1|                   1.0|
Spike Chunsoft                                |2016         |                  2|                      2|                   1.0|
Square Enix                                   |2015         |                  3|                      1|                   3.0|
Square Enix                                   |2017         |                  4|                      2|                   2.0|
Studio Wildcard                               |2015         |                  1|                      1|                   1.0|
StudioMDHR                                    |2017         |                  1|                      1|                   1.0|
Sunflowers                                    |1998         |                  2|                      1|                   2.0|
Sunflowers                                    |2003         |                  4|                      2|                   2.0|
Take-Two Interactive                          |1999         |                  1|                      1|                   1.0|
Take-Two Interactive                          |2003         |                  2|                      2|                   1.0|
Take-Two Interactive / Gathering of Developers|2001         |                  1|                      1|                   1.0|
Take-Two Interactive / Gathering of Developers|2002         |                  3|                      2|                   1.5|
Team Cherry                                   |2017         |                  1|                      1|                   1.0|
Technology and Entertainment Software         |1984         |                  1|                      1|                   1.0|
The Fun Pimps                                 |2016         |                  2|                      1|                   2.0|
THQ                                           |2004         |                  4|                      1|                   4.0|
THQ                                           |2005         |                  5|                      2|                   2.5|
THQ                                           |2007         |                  6|                      3|                   2.0|
Tripwire Interactive                          |2009         |                  1|                      1|                   1.0|
Triternion                                    |2019         |                  1|                      1|                   1.0|
Ubisoft                                       |1997         |                  2|                      1|                   2.0|
Ubisoft                                       |2004         |                  4|                      2|                   2.0|
Valve                                         |2006         |                 20|                      1|                  20.0|
Valve (digital)                               |2004         |                 14|                      2|                   7.0|
Virgin Interactive                            |1995         |                  3|                      1|                   3.0|
Virgin Interactive                            |1996         |                  6|                      2|                   3.0|
Virgin Interactive                            |1997         |                  7|                      3|             2.3333333|
Warhorse Studios                              |2018         |                  1|                      1|                   1.0|
WizardWorks                                   |1997         |                  1|                      1|                   1.0|
Wube Software                                 |2016         |                  2|                      1|                   2.0|
 */

/* Count number of games, total sales & total sales per game for each genre */
SELECT genre, COUNT("Name") AS number_of_games, SUM(sales) AS total_sales, 
	SUM(sales)::REAL / COUNT("Name") AS sales_per_game
FROM pc_games
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10;

/*
genre                  |number_of_games|total_sales|sales_per_game   |
-----------------------+---------------+-----------+-----------------+
Sandbox, survival      |              1|         33|             33.0|
Battle royale          |              2|         52|             26.0|
Sandbox                |              1|         20|             20.0|
Life simulation        |              3|         24|              8.0|
Action-adventure       |              6|         31|5.166666666666667|
Survival               |              5|         25|              5.0|
MMORPG                 |              6|         30|              5.0|
Action role-playing    |             12|         56|4.666666666666667|
Educational            |              1|          4|              4.0|
Turn-based strategy, 4X|              4|         14|              3.5|
*/

/* Count number of games, total sales & total sales per game for each year */
SELECT year_released, COUNT("Name") AS number_of_games, SUM(sales) AS total_sales, 
	SUM(sales)::REAL / COUNT("Name") AS sales_per_game
FROM pc_games
GROUP BY 1
ORDER BY 4 DESC;

/*
year_released|number_of_games|total_sales|sales_per_game    |
-------------+---------------+-----------+------------------+
2011         |              6|         57|               9.5|
2017         |              6|         48|               8.0|
2006         |              3|         22| 7.333333333333333|
2021         |              1|          6|               6.0|
2012         |              7|         37| 5.285714285714286|
2020         |              3|         15|               5.0|
2010         |              3|         15|               5.0|
2004         |             11|         55|               5.0|
2018         |              3|         15|               5.0|
1989         |              1|          4|               4.0|
2000         |              5|         19|               3.8|
1998         |              8|         29|             3.625|
2015         |              8|         26|              3.25|
2005         |              9|         23|2.5555555555555554|
1985         |              2|          5|               2.5|
1988         |              3|          7|2.3333333333333335|
1999         |              9|         20|2.2222222222222223|
2009         |              5|         11|               2.2|
2013         |              9|         18|               2.0|
2002         |              8|         14|              1.75|
1995         |              6|         10|1.6666666666666667|
2007         |              5|          8|               1.6|
1996         |              7|         11|1.5714285714285714|
2016         |              9|         14|1.5555555555555556|
1993         |              4|          6|               1.5|
2014         |              2|          3|               1.5|
1994         |              2|          3|               1.5|
1997         |              7|         10|1.4285714285714286|
2008         |              3|          4|1.3333333333333333|
2003         |              7|          9|1.2857142857142858|
2001         |             10|         12|               1.2|
1984         |              1|          1|               1.0|
2019         |              2|          2|               1.0|
*/

/* Count number of games, total sales & total sales per game for each month */
SELECT month_released, COUNT("Name") AS number_of_games, SUM(sales) AS total_sales,
	SUM(sales)::REAL / COUNT("Name") AS sales_per_game
FROM pc_games
GROUP BY 1
ORDER BY 4 DESC;

/*
month_released|number_of_games|total_sales|sales_per_game    |
--------------+---------------+-----------+------------------+
12            |             11|         62| 5.636363636363637|
5             |             11|         59| 5.363636363636363|
11            |             20|        107|              5.35|
8             |             11|         33|               3.0|
2             |             13|         38| 2.923076923076923|
3             |             17|         41| 2.411764705882353|
6             |             17|         40|2.3529411764705883|
10            |             21|         46|2.1904761904761907|
4             |             12|         26|2.1666666666666665|
1             |              7|         15| 2.142857142857143|
9             |             26|         55|2.1153846153846154|
7             |              9|         17|1.8888888888888888|
 */

	
