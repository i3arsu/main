CREATE DATABASE prodavaonica_elektronike;
-- DROP DATABASE prodavaonica_elektronike;
USE prodavaonica_elektronike;

CREATE TABLE artikl (
	id_artikl INTEGER NOT NULL AUTO_INCREMENT,
    naziv VARCHAR(64) NOT NULL,
    cijena_prodajna FLOAT NOT NULL,
    cijena_dobavljaca FLOAT NOT NULL,
    sifra VARCHAR(16) NOT NULL UNIQUE,
    garancija_datum DATETIME NOT NULL,
    bodovi_artikla INTEGER NOT NULL,
    PRIMARY KEY (id_artikl),
    CHECK (bodovi_artikla >= 0 AND bodovi_artikla <= 100)
);

CREATE TABLE zaposlenik (
	id_zaposlenik INTEGER NOT NULL AUTO_INCREMENT,
    ime VARCHAR(32) NOT NULL,
    prezime VARCHAR(32) NOT NULL,
    oib VARCHAR(16) NOT NULL UNIQUE,
    broj_telefona VARCHAR(16) NOT NULL UNIQUE,
    email VARCHAR(64) NOT NULL UNIQUE,
    PRIMARY KEY (id_zaposlenik)
);

CREATE TABLE kupac (
	id_kupac INTEGER NOT NULL AUTO_INCREMENT,
    ime VARCHAR(32) NOT NULL,
    prezime VARCHAR(32) NOT NULL,
    oib VARCHAR(16) NOT NULL UNIQUE,
    broj_telefona VARCHAR(16) NOT NULL UNIQUE,
    email VARCHAR(64) NOT NULL UNIQUE,
    postanski_broj MEDIUMINT NOT NULL,
    adresa VARCHAR(64) NOT NULL,
    PRIMARY KEY (id_kupac)
);

CREATE TABLE poslovnica (
	id_poslovnica INTEGER NOT NULL AUTO_INCREMENT,
    broj_telefona VARCHAR(16) NOT NULL UNIQUE,
    email VARCHAR(64) NOT NULL UNIQUE,
    postanski_broj MEDIUMINT NOT NULL,
	adresa VARCHAR(64) NOT NULL,
    PRIMARY KEY (id_poslovnica)
);

CREATE TABLE vrsta_narudzbe (
	id_vrsta_narudzbe INTEGER NOT NULL AUTO_INCREMENT,
    vrsta VARCHAR(16) NOT NULL,
    id_poslovnica INTEGER NOT NULL,
    PRIMARY KEY (id_vrsta_narudzbe),
    FOREIGN KEY (id_poslovnica) REFERENCES poslovnica(id_poslovnica)
);

CREATE TABLE kupac_racun (
	id_kupac_racun INTEGER NOT NULL AUTO_INCREMENT,
    id_kupac INTEGER NOT NULL,
    id_zaposlenik INTEGER NOT NULL,
    datum_izdavanja INTEGER NOT NULL,
    id_vrsta_narudzbe INTEGER NOT NULL,
    vrsta_placanja VARCHAR(32) NOT NULL,
    iskoristeni_bodovi INTEGER NOT NULL,
    PRIMARY KEY (id_kupac_racun),
    FOREIGN KEY (id_kupac) REFERENCES kupac(id_kupac),
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id_zaposlenik),
    CHECK (iskoristeni_bodovi = 0 OR iskoristeni_bodovi >= 10)
);

CREATE TABLE kupac_stavka_racun (
	id_kupac_stavka_racun INTEGER NOT NULL AUTO_INCREMENT,
    id_kupac_racun INTEGER NOT NULL,
    id_artikl INTEGER NOT NULL,
    kolicina INTEGER NOT NULL,
    PRIMARY KEY (id_kupac_stavka_racun),
    FOREIGN KEY (id_kupac_racun) REFERENCES kupac_racun(id_kupac_racun),
    FOREIGN KEY (id_artikl) REFERENCES artikl(id_artikl)
);

CREATE TABLE lokacija_artikla (
	id_lokacija INTEGER NOT NULL AUTO_INCREMENT,
    id_artikl INTEGER NOT NULL,
    id_poslovnica INTEGER NOT NULL,
    kolicina INTEGER NOT NULL,
	PRIMARY KEY (id_lokacija),
    UNIQUE (id_poslovnica, id_artikl),
    FOREIGN KEY (id_poslovnica) REFERENCES poslovnica(id_poslovnica),
    FOREIGN KEY (id_artikl) REFERENCES artikl(id_artikl)
);

CREATE TABLE dobavljac (
	id_dobavljac INTEGER NOT NULL AUTO_INCREMENT,
    naziv VARCHAR(32) NOT NULL,
    broj_telefona VARCHAR(16) NOT NULL UNIQUE,
    email VARCHAR(64) NOT NULL UNIQUE,
    postanski_broj MEDIUMINT NOT NULL,
    adresa VARCHAR(64) NOT NULL,
    PRIMARY KEY (id_dobavljac)    
);

CREATE TABLE dobavljac_racun (
	id_dobavljac_racun INTEGER NOT NULL AUTO_INCREMENT,
	id_poslovnica INTEGER NOT NULL,
    id_zaposlenik INTEGER NOT NULL,
    datum_izdavanja INTEGER NOT NULL,
    PRIMARY KEY (id_dobavljac_racun),
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id_zaposlenik),
    FOREIGN KEY (id_poslovnica) REFERENCES poslovnica(id_poslovnica)
);

CREATE TABLE dobavljac_stavka_racun (
	id_dobavljac_stavka_racun INTEGER NOT NULL AUTO_INCREMENT,
    id_dobavljac_racun INTEGER NOT NULL,
    id_dobavljac INTEGER NOT NULL,
    id_artikl INTEGER NOT NULL,
    kolicina INTEGER NOT NULL,
    PRIMARY KEY (id_dobavljac_stavka_racun),
    UNIQUE (id_dobavljac_racun, id_artikl),
    FOREIGN KEY (id_dobavljac) REFERENCES dobavljac(id_dobavljac),
    FOREIGN KEY (id_dobavljac_racun) REFERENCES dobavljac_racun(id_dobavljac_racun),
    FOREIGN KEY (id_artikl) REFERENCES artikl(id_artikl)
);

CREATE TABLE pregled_popravak_racunala (
	id_pregled INTEGER NOT NULL AUTO_INCREMENT,
    kupac_racun INTEGER NOT NULL,
    id_artikl INTEGER NOT NULL,
    kolicina INTEGER NOT NULL,
    datum DATETIME NOT NULL,
    PRIMARY KEY (id_pregled),
    FOREIGN KEY (id_artikl) REFERENCES artikl(id_artikl)
);

CREATE TABLE akcije_snizenja (
	id_snizenje INTEGER NOT NULL AUTO_INCREMENT,
    id_artikl INTEGER NOT NULL UNIQUE,
    postotak INTEGER NOT NULL,
    pocetak DATETIME NOT NULL,
    kraj DATETIME NOT NULL,
    PRIMARY KEY (id_snizenje),
    FOREIGN KEY (id_artikl) REFERENCES artikl(id_artikl)
);

CREATE TABLE bodovi (
	id_bodovi INTEGER NOT NULL AUTO_INCREMENT,
    id_kupac INTEGER NOT NULL UNIQUE,
    kolicina INTEGER NOT NULL,
    PRIMARY KEY (id_bodovi),
    FOREIGN KEY (id_kupac) REFERENCES kupac(id_kupac)
);

-- Relacije koje bi trebali implementirati:
-- 1. ukupna_cijena kod kupac_racun
-- Dobiti kod kupac_stavka_racun gdje treba uzet u obzir sniženje artikla ako ga ima i smanjiti mu cijenu pa pomnožit sa količinom
-- Te oduzeti od iskorištenih bodova (svaki bod = 1 kuna) npr. stavka_racun_1(((monitor od 50kn - 10%*50kn) * kolicina) - iskorišteni_bodovi) + stavka_racun_2(..) + ...
-- 2. Izracunat dobivene_bodove za kupca, npr. svaki artikl ima broj bodova koji moze dati kupcu (od 0 do 100) ako se kupi npr. 2 laptopa i jedan vanjski disk to je 
-- (45*2 + 24) i te bodove nadodat u bodovi, također treba i oduzet iskorištene bodove
-- 3. oduzet od lokacije_artikla kolicinu koja je kupljena/prodana i dodati kupljene artikle od dobavljaca
-- 4. ukupna_cijena kod dobavljac_racun


INSERT INTO artikl VALUES
	( 1, 'Miš LOGITECH Gaming G203 Prodigy', 246.05, 180.52, 'QPHQR4J8', STR_TO_DATE('07.10.2022.', '%d.%m.%Y.'), 6),
	( 2, 'Tipkovnica GENIUS SlimStar 130', 75.95, 36.90, 'U8BA3LR5', STR_TO_DATE('02.09.2021.', '%d.%m.%Y.'), 0),
	( 3, 'Slušalice SENNHEISER HD 350BT', 679.00, 450.20, 'B8RGT6P8', STR_TO_DATE('14.07.2021.', '%d.%m.%Y.'), 19),
	( 4, 'Mikrofon AROZZI Sfera PRO', 474.05, 220.80, 'BZTWRN68', STR_TO_DATE('08.09.2022.', '%d.%m.%Y.'), 12),
	( 5, 'Memorija USB 3.0 FLASH DRIVE, 16GB, SANDISK Ultra', 52.25, 25.05, '7HDDLG9U', STR_TO_DATE('01.02.2021.', '%d.%m.%Y.'), 0),
	( 6, 'Tvrdi disk vanjski 1000 GB SEAGATE Maxtor M3, USB 3.0', 407.55, 260.75, '65VTQNEH', STR_TO_DATE('18.10.2022.', '%d.%m.%Y.'), 10),
	( 7, 'Mrežna kartica adapter USB2.0, nano adapter', 71.25, 35.60, '7WKMJ7LU', STR_TO_DATE('28.04.2021.', '%d.%m.%Y.'), 0),
	( 8, 'Mrežna kamera D-LINK, 130°, 1080p 30fps', 588.05, 334.00, '7SSFD9HM', STR_TO_DATE('25.08.2020.', '%d.%m.%Y.'), 14),
	( 9, 'Miš LOGITECH M110 Silent, žicni, opticki, USB', 89.00, 50.00, 'EZQ5TRTL', STR_TO_DATE('07.01.2022', '%d.%m.%Y.'), 2),
	( 10, 'Racunalo LINKS Office / QuadCore i3 9100, 8GB, 240GB SSD', 3999.00, 3205.80, 'EF7L8XV4', STR_TO_DATE('28.07.2020', '%d.%m.%Y.'), 38),
	( 11, 'Monitor 27" AOC 27B1H, IPS', 1044.05, 796.45, 'W3HC5R72', STR_TO_DATE('19.05.2022', '%d.%m.%Y.'), 25),
	( 12, 'Kabel DELOCK, HDMI, 2m', 42.30, 15.20, 'JF68TS5H', STR_TO_DATE('08.07.2022', '%d.%m.%Y.'), 0),
	( 13, 'Kabel BELKIN Apple iPhone Lightning, USB-C', 140.06, 40.90, 'D2NGWFUM', STR_TO_DATE('17.12.2021', '%d.%m.%Y.'), 4),
	( 14, 'Racunalo LINKS Gaming / DodecaCore Ryzen 9 3900X', 14999.00, 12800.80, 'EPFTG3K9', STR_TO_DATE('12.01.2022', '%d.%m.%Y.'), 71),
	( 15, 'Racunalo AiO LENOVO IdeaCentre / Octa Core i5 9400T', 8359.05, 7112.06, '2PMYLPY5', STR_TO_DATE('09.10.2020', '%d.%m.%Y.'), 59),
	( 16, 'Prijenosno racunalo ASUS / Core i5 1035G1, 8GB, 512GB SSD', 5670.55, 5450.99, 'N7F8TBHT', STR_TO_DATE('17.08.2022', '%d.%m.%Y.'), 44),
	( 17, 'Zvucnici TRUST Ziva, 2.1, 6W', 113.05, 47.32, 'NVPL4VMZ', STR_TO_DATE('22.03.2022', '%d.%m.%Y.'), 3),
	( 18, 'Slušalice GENIUS Head Set HS-02B, mikrofon', 42.75, 19.99, 'CD4T7ATX', STR_TO_DATE('25.11.2021', '%d.%m.%Y.'), 0),
	( 19, 'Graficki tablet WACOM Intuos M Bluetooth', 1399.00, 1299.99, 'Y9AY8E8V', STR_TO_DATE('27.01.2022', '%d.%m.%Y.'), 30),
	( 20, 'Miš CORSAIR Harpoon RGB Pro, opticki', 255.55, 210.00, 'Q6YMCMG2', STR_TO_DATE('10.11.2020', '%d.%m.%Y.'), 7),
	( 21, 'Tipkovnica DUCKY One 2 SF Gaming, MX-Speed-Silver, mehanicka', 1091.55, 800.00, 'Y2YULRUW', STR_TO_DATE('03.09.2020', '%d.%m.%Y.'), 26),
	( 22, 'Monitor 21.5" ACER, 75Hz', 797.05, 664.05, 'WDB3X9SW', STR_TO_DATE('23.09.2020', '%d.%m.%Y.'), 23),
	( 23, 'Skener EPSON Perfection V19', 521.55, 425.95, 'AHB7DAPG', STR_TO_DATE('14.09.2020', '%d.%m.%Y.'), 13),
	( 24, 'Printer HP Color Laser 150a, 600dpi', 949.00, 550.05, 'RYZDJH4D', STR_TO_DATE('06.09.2022', '%d.%m.%Y.'), 25),
	( 25, 'Memorija USB 3.0 FLASH DRIVE, 32 GB, KINGSTON', 46.55, 10.00, 'T775URKP', STR_TO_DATE('18.05.2022', '%d.%m.%Y.'), 0),
	( 26, 'Graficka kartica PCI-E GIGABYTE GeForce RTX 2080', 7789.55, 7259.97, 'WVL6PGEA', STR_TO_DATE('09.10.2020', '%d.%m.%Y.'), 54),
	( 27, 'Memorija PC-12800, 4 GB, KINGSTON Value, DDR3', 208.05, 150.00, 'XKGM6UML', STR_TO_DATE('26.04.2021', '%d.%m.%Y.'), 5),
	( 28, 'Maticna ploca ASROCK B450 Gaming K4, AMD B450, DDR4', 778.05, 457.63, '6SAKYJ9S', STR_TO_DATE('11.05.2021', '%d.%m.%Y.'), 22),
	( 29, 'SSD 1000 GB SAMSUNG 860 QVO Basic, SATA 3', 930.05, 889.99, 'S89E8X6X', STR_TO_DATE('23.10.2020', '%d.%m.%Y.'), 24),
	( 30, 'Prijenosno racunalo APPLE MacBook Air', 12187.55, 11000.25, 'AFTEBTKM', STR_TO_DATE('28.05.2021', '%d.%m.%Y.'), 68);
    
INSERT INTO zaposlenik VALUES 
	( 1, 'Ivan', 'Mandić', 61635030079, '718-24-1953', 'IvanMandic@gmail.com'),
	( 2, 'Sunčica', 'Bosanac', 19204355919, '016-17-6254', 'SuncicaBosanac@yahoo.com'),
	( 3, 'Snežana', 'Popović', 62979565020, '978-76-4875', 'SnezanaPopovic@gmail.com'),
	( 4, 'Petra', 'Šarić', 66244848898, '737-77-6945', 'PetraSaric@gmail.com'),
	( 5, 'Paula', 'Tadić', 86118594699, '854-09-7832', 'PaulaTadic@gmail.us'),
	( 6, 'Ivanka', 'Mijatović', 16496868164, '191-65-9252', 'IvankaMijatovic@gmail.com'),
	( 7, 'Dinko', 'Ivančić', 25295402749, '612-26-8784', 'DinkoIvancic@yahoo.com'),
	( 8, 'Ognjenka', 'Hrvat', 73580158868, '111-88-0963', 'OgnjenkaHrvat@yahoo.com'),
	( 9, 'Ivan', 'Filipović', 11013556560, '687-55-6565', 'IvanFilipovic@gmail.com'),
	( 10, 'Damjan', 'Stipanov', 77498393386, '663-16-6623', 'DamjanStipanov@gmail.com'),
	( 11, 'Ljubo', 'Posavec', 88954256606, '786-47-0128', 'LjuboPosavec@gmail.us'),
	( 12, 'Darko', 'Herceg', 01421635283, '614-32-3127', 'DarkoHerceg@yahoo.com'),
	( 13, 'Duje', 'Šimić', 28456000202, '207-11-0111', 'DujeSimic@gmail.com'),
	( 14, 'Sven', 'Marušić', 94541596419, '962-52-8252', 'SvenMarusic@yahoo.com'),
	( 15, 'Sabina', 'Ilić', 01234985729, '550-12-7533', 'SabinaIlic@gmail.com'),
    ( 16, 'Janja', 'Klarić', 72170880407, '514-51-1697', 'JanjaKlaric@gmail.com'),
    ( 17, 'Zdravko', 'Jakšić', 33512084115, '561-04-2996', 'ZdravkoJaksic@yahoo.com'),
    ( 18, 'Cvijeta', 'Antunović', 04233411322, '758-27-4505', 'CvijetaAntunovic@gmail.com'),
    ( 19, 'Slaviša', 'Lukić', 40411122390, '205-76-7837', 'SlavisaLukic@gmail.com'),
    ( 20, 'Berislava', 'Hrvat', 03481803690, '222-33-6626', 'BerislavaHrvat@gmail.com'),
    ( 21, 'Cvitko', 'Dujmović', 14584159757, '638-46-5926', 'CvitkoDujmovic@gmail.com'),
    ( 22, 'Ivanka', 'Ivanec', 89896127721, '685-25-2035', 'IvankaIvanec@yahoo.com'),
    ( 23, 'Đurđica', 'Vidaković', 92803966491, '989-22-2985', 'DurdicaVidakovic@gmail.com'),
    ( 24, 'Miroš', 'Nikolić', 30771773428, '118-06-5567', 'MirosNikolic@gmail.com'),
    ( 25, 'Blago', 'Barić', 62235580564, '049-66-5869', 'BlagoBaric@gmail.com'),
    ( 26, 'Ivanka', 'Cindrić', 41128052626, '393-31-5604', 'IvankaCindric@gmail.com'),
    ( 27, 'Ranko', 'Cindrić', 17848700188, '563-46-9025', 'RankoCindric@gmail.com'),
    ( 28, 'Ivona', 'Katić', 53040357403, '462-43-8925', 'IvonaKatic@gmail.com'),
    ( 29, 'Tena', 'Petković', 90255777218, '697-02-9699', 'TenaPetkovic@yahoo.com'),
    ( 30, 'Sofija', 'Marušić', 52609911008, '157-49-4497', 'SofijaMarusic@yahoo.com');
    
INSERT INTO kupac VALUES 
	( 1, 'Matej', 'Katić', 57563508075, '762-02-9669', 'MatejKatic@yahoo.com', 10000, 'Kneza Branimira 63 10000 Zagreb'),
    ( 2, 'Draženka', 'Varga', 41647660171, '275-67-9893', 'DrazenkaVarga@gmail.com', 21210, 'Put Majdana b.b., 21210 Solin'),
    ( 3, 'Ratimir', 'Brajković', 12994278673, '840-31-7513', 'RatimirBrajkovic@yahoo.com', 10000, 'Klenovnička 4, 10000 Zagreb'),
    ( 4, 'Dragoslav', 'Babić', 71438211141, '119-42-1387', 'DragoslavBabic@gmail.com', 47000, 'Trg Josipa Broza 2, 47000 Karlovac'),
    ( 5, 'Miroš', 'Petković', 19014676816, '000-67-8557', 'MirosPetkovic@yahoo.com', 21000, 'Meštrovićevo šetalište 47, 21000 Split'),
    ( 6, 'Sven', 'Tadić', 81170736099, '763-89-5556', 'SvenTadic@gmail.com', 40305, 'Josipa Štolcera Slavenskog 5, 40305 Nedelišće'),
    ( 7, 'Jagoda', 'Ivanec', 46789845748, '880-72-2961', 'JagodaIvanec@gmail.com', 52100, 'Vergerijeva 13, 52100 Pula'),
    ( 8, 'Miroslav', 'Kos', 45047683244, '917-07-4830', 'MiroslavKos@gmail.com', 52100, 'Industrijska 13, 52100 Pula'),
    ( 9, 'Fran', 'Bačić', 19739916742, '282-56-2117', 'FranBacic@gmail.com', 51000, 'Dolac 11, 51000 Rijeka'),
    ( 10, 'Nina', 'Lončar', 66769122973, '056-03-8324', 'NinaLoncar@yahoo.com', 52100, 'Kašićeva 12, 52100 Pula'),
    ( 11, 'Bratoljub', 'Hrvatin', 52905491537, '316-84-9800', 'BratoljubHrvatin@yahoo.com', 47000, 'Trg Josipa Broza Tita 1, 47000 Karlovac'),
    ( 12, 'Radojka', 'Kuprešak', 26628682383, '950-89-6550', 'RadojkaKupresak@yahoo.com', 44000, 'S. i A. Radića 11, 44000 Sisak'),
    ( 13, 'Marija', 'Kos', 92331997150, '084-18-5819', 'BorkaKos@gmail.com', 52100, 'Industrijska 13, 52100 Pula'),
    ( 14, 'Roko', 'Bilić', 48629320209, '928-51-3593', 'RokoBilic@gmail.com', 10000, 'Zelenjak 70, 10000 Zagreb'),
    ( 15, 'Zorislav', 'Filipović', 96251912718, '231-31-1067', 'ZorislavFilipovic@yahoo.com', 21000, 'Vinodolska 27, 21000 Split'),
    ( 16, 'Fabijan', 'Barić', 70807329304, '978-39-6877', 'FabijanBaric@yahoo.com', 52100, 'Radićeva 22, 52100 Pula'),
    ( 17, 'Stipo', 'Čeh', 54336255874, '471-33-2682', 'StipoCeh@gmail.com', 51000, 'Strossmayerova 13, 51000 Rijeka'),
    ( 18, 'Desimir', 'Novaković', 27624698780, '454-68-5892', 'DesimirNovakovic@gmail.com', 47000, 'Naselje Gaza 10b, 47000 Karlovac'),
    ( 19, 'Milka', 'Vuković', 33191940161, '912-84-1439', 'MilkaVukovic@gmail.com', 32000, 'Lavoslava Ružičke 2a, 32000 Vukovar'),
    ( 20, 'Daniel', 'Horvat', 78342951678, '140-37-3542', 'DanielHorvat@gmail.com', 51000, 'Mihovilići 12b, 51000 Rijeka'),
    ( 21, 'Stana', 'Novaković', 86487907646, '586-07-1351', 'StanaNovakovic@gmail.com', 47000, 'Naselje Gaza 10b, 47000 Karlovac'),
    ( 22, 'Tuga', 'Kovačević', 88495928492, '931-16-2208', 'TugaKovacevic@yahoo.com', 52466, 'Veliki trg 1, 52466 Novigrad'),
    ( 23, 'Miloš', 'Ivanec', 70379634357, '830-22-1357', 'MilosIvanec@gmail.com', 52100, 'Vergerijeva 13, 52100 Pula'),
    ( 24, 'Anamarija', 'Antunović', 89530722639, '939-63-6761', 'AnamarijaAntunovic@gmail.com', 47000, 'Donja Gaza 7, 47000 Karlovac'),
    ( 25, 'Jana', 'Lovrić', 51623561382, '412-52-9850', 'JanaLovric@yahoo.com', 21210, 'Fra Grge Martića 33, 21210 Solin'),
    ( 26, 'Borislava', 'Matković', 68485074699, '481-50-3649', 'BorislavaMatkovic@gmail.com', 10000, 'Ilica 208, 10000 Zagreb'),
    ( 27, 'Slavica', 'Vidaković', 13644618166, '597-45-0027', 'SlavicaVidakovic@gmail.com', 51000, 'Ivana Žorža 12, 51000 Rijeka'),
    ( 28, 'Vlasta', 'Grgić', 90029834178, '113-47-6461', 'VlastaGrgic@yahoo.com', 35000, 'Dudinjak 51, 35000 Slavonski Brod'),
    ( 29, 'Prvan', 'Ćosić', 71672020503, '362-42-3898', 'PrvanCosic@gmail.com', 21210, 'Matoševa 86a, 21210 Solin'),
    ( 30, 'Nina ', 'Filipović', 86974666336, '336-18-2285', 'NinaFilipovic@yahoo.com', 52100, 'Busolerska 39, 52100 Pula');

INSERT INTO poslovnica VALUES 
	( 1, '849-41-6126', 'ProdavaonicaElektronikePula@poslovna-tvrtka.hr', 52100, 'Monte Bici 1, 52100 Pula'),
	( 2, '434-13-8981', 'ProdavaonicaElektronikeZagreb@poslovna-tvrtka.hr', 10000, 'Samoborska cesta 91, 10000 Zagreb'),
	( 3, '231-33-0977', 'ProdavaonicaElektronikeSplit@poslovna-tvrtka.hr', 21000, 'Krležina 36, 21000 Split'),
	( 4, '550-49-2114', 'ProdavaonicaElektronikeRijeka@poslovna-tvrtka.hr', 51000, 'Frana Kurelca 8, 51000 Rijeka'),
	( 5, '691-01-4803', 'ProdavaonicaElektronikeOsijek@poslovna-tvrtka.hr', 31000, 'Trg Lavoslava Ružičke bb, 31000 Osijek'),
	( 6, '953-08-7084', 'ProdavaonicaElektronikeZadar@poslovna-tvrtka.hr', 23000, 'Jeretova 5, 23000 Zadar'),
	( 7, '503-64-3854', 'ProdavaonicaElektronikeSlavonskiBrod@poslovna-tvrtka.hr', 35000, 'A. Jarića 96, 35000 Slavonski Brod'),
	( 8, '303-51-4904', 'ProdavaonicaElektronikeKarlovac@poslovna-tvrtka.hr', 47000, 'Kralja Petra Krešimira IV. 2, 47000 Karlovac'),
	( 9, '038-43-6245', 'ProdavaonicaElektronikeSisak@poslovna-tvrtka.hr', 44000, 'Kralja Tomislava 5, 44000 Sisak'),
	( 10, '207-66-1957', 'ProdavaonicaElektronikeDubrovnik@poslovna-tvrtka.hr', 20000, 'Frana Supila 3, 20000 Dubrovnik'),
	( 11, '914-26-5755', 'ProdavaonicaElektronikeSolin@poslovna-tvrtka.hr', 21210, 'Zvonimirova 83, 21210 Solin'),
	( 12, '865-60-9324', 'ProdavaonicaElektronikeVaraždin@poslovna-tvrtka.hr', 42000, 'P. Miškine 61/a, 42000 Varaždin'),
	( 13, '969-62-6822', 'ProdavaonicaElektronikeŠibenik@poslovna-tvrtka.hr', 22000, 'Bribirska 22, 22000 Šibenik'),
	( 14, '517-94-3518', 'ProdavaonicaElektronikeVukovar@poslovna-tvrtka.hr', 32000, 'D. Pejačevića 12, 32000 Vukovar'),
	( 15, '376-84-7870', 'ProdavaonicaElektronikeKoprivnica@poslovna-tvrtka.hr', 48000, 'Miklinovec 6a, 48000 Koprivnica');

INSERT INTO vrsta_narudzbe VALUES 
	( 1, 'STANDARDNA', 1),
    ( 2, 'STANDARDNA', 2),
    ( 3, 'STANDARDNA', 3),
    ( 4, 'STANDARDNA', 4),
    ( 5, 'STANDARDNA', 5),
    ( 6, 'STANDARDNA', 6),
    ( 7, 'STANDARDNA', 7),
    ( 8, 'STANDARDNA', 8),
    ( 9, 'STANDARDNA', 9),
    ( 10, 'STANDARDNA', 10),
    ( 11, 'STANDARDNA', 11),
    ( 12, 'STANDARDNA', 12),
    ( 13, 'STANDARDNA', 13),
    ( 14, 'STANDARDNA', 14),
    ( 15, 'STANDARDNA', 15),
    ( 16, 'ONLINE', 1),
    ( 17, 'ONLINE', 2),
    ( 18, 'ONLINE', 3),
    ( 19, 'ONLINE', 4),
    ( 20, 'ONLINE', 5),
    ( 21, 'ONLINE', 6),
    ( 22, 'ONLINE', 7),
    ( 23, 'ONLINE', 8),
    ( 24, 'ONLINE', 9),
    ( 25, 'ONLINE', 10),
    ( 26, 'ONLINE', 11),
    ( 27, 'ONLINE', 12),
    ( 28, 'ONLINE', 13),
    ( 29, 'ONLINE', 14),
    ( 30, 'ONLINE', 15);

INSERT INTO kupac_racun VALUES 
	( 1, 1, 22, STR_TO_DATE('08.07.2019.', '%d.%m.%Y.'), 5, 'Gotovina', 13),( 2, 2, 4, STR_TO_DATE('11.08.2019.', '%d.%m.%Y.'), 8, 'MasterCard', 58),
	( 3, 3, 1, STR_TO_DATE('07.11.2019.', '%d.%m.%Y.'), 10, 'Visa', 15),
	( 4, 4, 2, STR_TO_DATE('06.01.2020.', '%d.%m.%Y.'), 27, 'PayPal', 31),
	( 5, 5, 13, STR_TO_DATE('24.01.2020.', '%d.%m.%Y.'), 11, 'Diners', 32),
	( 6, 6, 10, STR_TO_DATE('17.03.2020.', '%d.%m.%Y.'), 22, 'Amex', 37),
	( 7, 7, 4, STR_TO_DATE('26.06.2019.', '%d.%m.%Y.'), 10, 'Gotovina', 11),
	( 8, 8, 6, STR_TO_DATE('13.07.2019.', '%d.%m.%Y.'), 22, 'Pouzećem', 0),
	( 9, 9, 26, STR_TO_DATE('29.08.2019.', '%d.%m.%Y.'), 13, 'Erste', 20),
	( 10, 10, 7, STR_TO_DATE('27.10.2019.', '%d.%m.%Y.'), 1, 'MasterCard', 36),
	( 11, 11, 6, STR_TO_DATE('13.02.2020.', '%d.%m.%Y.'), 15, 'Diners', 117),
	( 12, 12, 21, STR_TO_DATE('05.03.2020.', '%d.%m.%Y.'), 22, 'PayPal', 16),
	( 13, 13, 18, STR_TO_DATE('26.04.2020.', '%d.%m.%Y.'), 6, 'MasterCard', 0),
	( 14, 14, 23, STR_TO_DATE('24.10.2019.', '%d.%m.%Y.'), 11, 'Gotovina', 0),
	( 15, 15, 2, STR_TO_DATE('17.12.2019.', '%d.%m.%Y.'), 14, 'Visa', 38),
	( 16, 16, 1, STR_TO_DATE('18.01.2020.', '%d.%m.%Y.'), 7, 'Gotovina', 0),
	( 17, 17, 30, STR_TO_DATE('07.03.2020.', '%d.%m.%Y.'), 12, 'Diners', 23),
	( 18, 18, 22, STR_TO_DATE('21.03.2020.', '%d.%m.%Y.'), 12, 'Gotovina', 56),
	( 19, 19, 17, STR_TO_DATE('10.05.2019.', '%d.%m.%Y.'), 18, 'MasterCard', 27),
	( 20, 20, 3, STR_TO_DATE('15.07.2019.', '%d.%m.%Y.'), 4, 'Gotovina', 0),
	( 21, 21, 17, STR_TO_DATE('19.07.2019.', '%d.%m.%Y.'), 11, 'Gotovina', 0),
	( 22, 22, 21, STR_TO_DATE('23.09.2019.', '%d.%m.%Y.'), 15, 'Visa', 38),
	( 23, 23, 29, STR_TO_DATE('08.10.2019.', '%d.%m.%Y.'), 14, 'Visa', 33),
	( 24, 24, 21, STR_TO_DATE('10.01.2020.', '%d.%m.%Y.'), 9, 'MasterCard', 153),
	( 25, 25, 6, STR_TO_DATE('03.02.2020.', '%d.%m.%Y.'), 6, 'Gotovina', 0),
	( 26, 26, 27, STR_TO_DATE('19.07.2019.', '%d.%m.%Y.'), 11, 'Erste', 14),
	( 27, 27, 18, STR_TO_DATE('03.08.2019.', '%d.%m.%Y.'), 18, 'Visa', 0),
	( 28, 28, 1, STR_TO_DATE('07.02.2020.', '%d.%m.%Y.'), 27, 'Pouzećem', 0),
	( 29, 29, 4, STR_TO_DATE('08.06.2019.', '%d.%m.%Y.'), 19, 'Visa', 12),
	( 30, 30, 4, STR_TO_DATE('17.10.2019.', '%d.%m.%Y.'), 23, 'Visa', 45);

INSERT INTO kupac_stavka_racun VALUES 
	( 1, 1, 12, 2),
	( 2, 1, 22, 2),
	( 3, 2, 19, 1),
	( 4, 2, 23, 1),
	( 5, 3, 2, 10),
	( 6, 3, 9, 10),
	( 7, 4, 16, 1), -- pc
	( 8, 5, 13, 2),
	( 9, 5, 18, 1),
	( 10, 5, 7, 3),
	( 11, 6, 14, 1), -- pc
	( 12, 6, 21, 1),
	( 13, 6, 20, 1),
	( 14, 6, 17, 1),
	( 15, 7, 10, 1), -- pc
	( 16, 8, 29, 2),
	( 17, 9, 5, 3),
	( 18, 10, 28, 1),
	( 19, 10, 27, 4),
	( 20, 11, 15, 1), -- pc
	( 21, 11, 24, 1),
	( 22, 12, 1, 1),
	( 23, 12, 20, 1),
	( 24, 12, 9, 1),
	( 25, 13, 8, 2),
	( 26, 14, 11, 1),
	( 27, 14, 22, 1),
	( 28, 14, 12, 2),
	( 29, 15, 3, 1),
	( 30, 15, 17, 1),
	( 31, 16, 10, 1), -- pc
	( 32, 17, 19, 4),
	( 33, 18, 6, 1),
	( 34, 19, 4, 1),
	( 35, 20, 26, 1),
	( 36, 20, 28, 1),
	( 37, 20, 29, 1),
	( 38, 20, 27, 4),
	( 39, 20, 11, 3),
	( 40, 20, 12, 3),
	( 41, 20, 21, 1),
	( 42, 20, 20, 1),
	( 43, 21, 2, 1),
	( 44, 22, 3, 1),
	( 45, 23, 24, 1),
	( 46, 23, 23, 1),
	( 47, 23, 13, 3),
	( 48, 24, 30, 1), -- pc
	( 49, 25, 15, 1),
	( 50, 25, 11, 2),
	( 51, 25, 8, 1),
	( 52, 25, 4, 1),
	( 53, 26, 5, 2),
	( 54, 26, 25, 2),
	( 55, 27, 19, 1),
	( 56, 28, 18, 1),
	( 57, 28, 2, 1),
	( 58, 29, 10, 1), -- pc
	( 59, 30, 11, 1),
	( 60, 30, 12, 2);

INSERT INTO lokacija_artikla VALUES
	(NULL, 1, 1, 23),  (NULL, 1, 2, 11),  (NULL, 1, 3, 21),  (NULL, 1, 4, 13),  (NULL, 1, 5, 26),  (NULL, 1, 6, 13),  (NULL, 1, 7, 24),  (NULL, 1, 8, 25),  (NULL, 1, 9, 12),  (NULL, 1, 10, 23),  (NULL, 1, 11, 29),  (NULL, 1, 12, 26),  (NULL, 1, 13, 14),  (NULL, 1, 14, 20),  (NULL, 1, 15, 23),
	(NULL, 2, 1, 16),  (NULL, 2, 2, 20),  (NULL, 2, 3, 14),  (NULL, 2, 4, 19),  (NULL, 2, 5, 22),  (NULL, 2, 6, 22),  (NULL, 2, 7, 23),  (NULL, 2, 8, 11),  (NULL, 2, 9, 6),   (NULL, 2, 10, 14),  (NULL, 2, 11, 13),  (NULL, 2, 12, 8),   (NULL, 2, 13, 27),  (NULL, 2, 14, 8),   (NULL, 2, 15, 28),
	(NULL, 3, 1, 8),   (NULL, 3, 2, 14),  (NULL, 3, 3, 26),  (NULL, 3, 4, 22),  (NULL, 3, 5, 26),  (NULL, 3, 6, 7),   (NULL, 3, 7, 19),  (NULL, 3, 8, 6),   (NULL, 3, 9, 6),   (NULL, 3, 10, 5),   (NULL, 3, 11, 18),  (NULL, 3, 12, 23),  (NULL, 3, 13, 20),  (NULL, 3, 14, 11),  (NULL, 3, 15, 24),
	(NULL, 4, 1, 30),  (NULL, 4, 2, 11),  (NULL, 4, 3, 27),  (NULL, 4, 4, 7),   (NULL, 4, 5, 23),  (NULL, 4, 6, 23),  (NULL, 4, 7, 26),  (NULL, 4, 8, 17),  (NULL, 4, 9, 10),  (NULL, 4, 10, 19),  (NULL, 4, 11, 21),  (NULL, 4, 12, 10),  (NULL, 4, 13, 26),  (NULL, 4, 14, 13),  (NULL, 4, 15, 8),
	(NULL, 5, 1, 20),  (NULL, 5, 2, 13),  (NULL, 5, 3, 6),   (NULL, 5, 4, 18),  (NULL, 5, 5, 11),  (NULL, 5, 6, 26),  (NULL, 5, 7, 29),  (NULL, 5, 8, 6),   (NULL, 5, 9, 11),  (NULL, 5, 10, 29),  (NULL, 5, 11, 24),  (NULL, 5, 12, 16),  (NULL, 5, 13, 17),  (NULL, 5, 14, 21),  (NULL, 5, 15, 20),
	(NULL, 6, 1, 27),  (NULL, 6, 2, 14),  (NULL, 6, 3, 20),  (NULL, 6, 4, 21),  (NULL, 6, 5, 20),  (NULL, 6, 6, 12),  (NULL, 6, 7, 24),  (NULL, 6, 8, 26),  (NULL, 6, 9, 23),  (NULL, 6, 10, 12),  (NULL, 6, 11, 17),  (NULL, 6, 12, 11),  (NULL, 6, 13, 29),  (NULL, 6, 14, 15),  (NULL, 6, 15, 10),
	(NULL, 7, 1, 6),   (NULL, 7, 2, 25),  (NULL, 7, 3, 13),  (NULL, 7, 4, 21),  (NULL, 7, 5, 17),  (NULL, 7, 6, 20),  (NULL, 7, 7, 20),  (NULL, 7, 8, 13),  (NULL, 7, 9, 27),  (NULL, 7, 10, 10),  (NULL, 7, 11, 5),   (NULL, 7, 12, 21),  (NULL, 7, 13, 5),   (NULL, 7, 14, 11),  (NULL, 7, 15, 25),
	(NULL, 8, 1, 14),  (NULL, 8, 2, 9),   (NULL, 8, 3, 27),  (NULL, 8, 4, 13),  (NULL, 8, 5, 17),  (NULL, 8, 6, 14),  (NULL, 8, 7, 20),  (NULL, 8, 8, 8),   (NULL, 8, 9, 16),  (NULL, 8, 10, 25),  (NULL, 8, 11, 8),   (NULL, 8, 12, 21),  (NULL, 8, 13, 9),   (NULL, 8, 14, 11),  (NULL, 8, 15, 9),
	(NULL, 9, 1, 30),  (NULL, 9, 2, 26),  (NULL, 9, 3, 13),  (NULL, 9, 4, 14),  (NULL, 9, 5, 16),  (NULL, 9, 6, 22),  (NULL, 9, 7, 8),   (NULL, 9, 8, 6),   (NULL, 9, 9, 23),  (NULL, 9, 10, 13),  (NULL, 9, 11, 20),  (NULL, 9, 12, 10),  (NULL, 9, 13, 14),  (NULL, 9, 14, 14),  (NULL, 9, 15, 17),
	(NULL, 10, 1, 27), (NULL, 10, 2, 14), (NULL, 10, 3, 16), (NULL, 10, 4, 12), (NULL, 10, 5, 24), (NULL, 10, 6, 6),  (NULL, 10, 7, 23), (NULL, 10, 8, 14), (NULL, 10, 9, 10), (NULL, 10, 10, 18), (NULL, 10, 11, 7),  (NULL, 10, 12, 21), (NULL, 10, 13, 5),  (NULL, 10, 14, 29), (NULL, 10, 15, 15),
	(NULL, 11, 1, 14), (NULL, 11, 2, 16), (NULL, 11, 3, 29), (NULL, 11, 4, 29), (NULL, 11, 5, 13), (NULL, 11, 6, 17), (NULL, 11, 7, 12), (NULL, 11, 8, 12), (NULL, 11, 9, 24), (NULL, 11, 10, 16), (NULL, 11, 11, 14), (NULL, 11, 12, 9),  (NULL, 11, 13, 26), (NULL, 11, 14, 18), (NULL, 11, 15, 26),
	(NULL, 12, 1, 12), (NULL, 12, 2, 19), (NULL, 12, 3, 23), (NULL, 12, 4, 27), (NULL, 12, 5, 20), (NULL, 12, 6, 24), (NULL, 12, 7, 29), (NULL, 12, 8, 19), (NULL, 12, 9, 6),  (NULL, 12, 10, 19), (NULL, 12, 11, 25), (NULL, 12, 12, 9),  (NULL, 12, 13, 22), (NULL, 12, 14, 25), (NULL, 12, 15, 12),
	(NULL, 13, 1, 15), (NULL, 13, 2, 19), (NULL, 13, 3, 15), (NULL, 13, 4, 25), (NULL, 13, 5, 7),  (NULL, 13, 6, 11), (NULL, 13, 7, 14), (NULL, 13, 8, 18), (NULL, 13, 9, 26), (NULL, 13, 10, 15), (NULL, 13, 11, 8),  (NULL, 13, 12, 26), (NULL, 13, 13, 30), (NULL, 13, 14, 11), (NULL, 13, 15, 30),
	(NULL, 14, 1, 16), (NULL, 14, 2, 15), (NULL, 14, 3, 19), (NULL, 14, 4, 21), (NULL, 14, 5, 28), (NULL, 14, 6, 28), (NULL, 14, 7, 19), (NULL, 14, 8, 23), (NULL, 14, 9, 26), (NULL, 14, 10, 8),  (NULL, 14, 11, 13), (NULL, 14, 12, 6),  (NULL, 14, 13, 9),  (NULL, 14, 14, 24), (NULL, 14, 15, 6),
	(NULL, 15, 1, 22), (NULL, 15, 2, 9),  (NULL, 15, 3, 25), (NULL, 15, 4, 14), (NULL, 15, 5, 23), (NULL, 15, 6, 11), (NULL, 15, 7, 29), (NULL, 15, 8, 29), (NULL, 15, 9, 9),  (NULL, 15, 10, 7),  (NULL, 15, 11, 16), (NULL, 15, 12, 11), (NULL, 15, 13, 8),  (NULL, 15, 14, 11), (NULL, 15, 15, 25),
	(NULL, 16, 1, 9),  (NULL, 16, 2, 23), (NULL, 16, 3, 23), (NULL, 16, 4, 21), (NULL, 16, 5, 16), (NULL, 16, 6, 11), (NULL, 16, 7, 10), (NULL, 16, 8, 6),  (NULL, 16, 9, 9),  (NULL, 16, 10, 15), (NULL, 16, 11, 20), (NULL, 16, 12, 11), (NULL, 16, 13, 8),  (NULL, 16, 14, 14), (NULL, 16, 15, 16),
	(NULL, 17, 1, 25), (NULL, 17, 2, 18), (NULL, 17, 3, 22), (NULL, 17, 4, 23), (NULL, 17, 5, 20), (NULL, 17, 6, 30), (NULL, 17, 7, 9),  (NULL, 17, 8, 21), (NULL, 17, 9, 27), (NULL, 17, 10, 20), (NULL, 17, 11, 12), (NULL, 17, 12, 22), (NULL, 17, 13, 25), (NULL, 17, 14, 7),  (NULL, 17, 15, 17),
	(NULL, 18, 1, 26), (NULL, 18, 2, 18), (NULL, 18, 3, 24), (NULL, 18, 4, 11), (NULL, 18, 5, 13), (NULL, 18, 6, 15), (NULL, 18, 7, 10), (NULL, 18, 8, 26), (NULL, 18, 9, 7),  (NULL, 18, 10, 24), (NULL, 18, 11, 16), (NULL, 18, 12, 6),  (NULL, 18, 13, 13), (NULL, 18, 14, 18), (NULL, 18, 15, 7),
	(NULL, 19, 1, 19), (NULL, 19, 2, 24), (NULL, 19, 3, 16), (NULL, 19, 4, 24), (NULL, 19, 5, 7),  (NULL, 19, 6, 13), (NULL, 19, 7, 24), (NULL, 19, 8, 19), (NULL, 19, 9, 26), (NULL, 19, 10, 17), (NULL, 19, 11, 22), (NULL, 19, 12, 14), (NULL, 19, 13, 14), (NULL, 19, 14, 22), (NULL, 19, 15, 18),
	(NULL, 20, 1, 30), (NULL, 20, 2, 28), (NULL, 20, 3, 17), (NULL, 20, 4, 24), (NULL, 20, 5, 5),  (NULL, 20, 6, 7),  (NULL, 20, 7, 15), (NULL, 20, 8, 20), (NULL, 20, 9, 11), (NULL, 20, 10, 29), (NULL, 20, 11, 19), (NULL, 20, 12, 22), (NULL, 20, 13, 15), (NULL, 20, 14, 28), (NULL, 20, 15, 17),
	(NULL, 21, 1, 28), (NULL, 21, 2, 29), (NULL, 21, 3, 28), (NULL, 21, 4, 23), (NULL, 21, 5, 6),  (NULL, 21, 6, 22), (NULL, 21, 7, 24), (NULL, 21, 8, 21), (NULL, 21, 9, 9),  (NULL, 21, 10, 21), (NULL, 21, 11, 20), (NULL, 21, 12, 22), (NULL, 21, 13, 30), (NULL, 21, 14, 11), (NULL, 21, 15, 26),
	(NULL, 22, 1, 9),  (NULL, 22, 2, 26), (NULL, 22, 3, 30), (NULL, 22, 4, 13), (NULL, 22, 5, 5),  (NULL, 22, 6, 12), (NULL, 22, 7, 27), (NULL, 22, 8, 24), (NULL, 22, 9, 30), (NULL, 22, 10, 15), (NULL, 22, 11, 6),  (NULL, 22, 12, 27), (NULL, 22, 13, 21), (NULL, 22, 14, 26), (NULL, 22, 15, 21),
	(NULL, 23, 1, 9),  (NULL, 23, 2, 20), (NULL, 23, 3, 17), (NULL, 23, 4, 10), (NULL, 23, 5, 27), (NULL, 23, 6, 15), (NULL, 23, 7, 13), (NULL, 23, 8, 6),  (NULL, 23, 9, 20), (NULL, 23, 10, 14), (NULL, 23, 11, 20), (NULL, 23, 12, 9),  (NULL, 23, 13, 30), (NULL, 23, 14, 30), (NULL, 23, 15, 23),
	(NULL, 24, 1, 12), (NULL, 24, 2, 7),  (NULL, 24, 3, 7),  (NULL, 24, 4, 16), (NULL, 24, 5, 21), (NULL, 24, 6, 24), (NULL, 24, 7, 19), (NULL, 24, 8, 27), (NULL, 24, 9, 11), (NULL, 24, 10, 23), (NULL, 24, 11, 25), (NULL, 24, 12, 6),  (NULL, 24, 13, 25), (NULL, 24, 14, 6),  (NULL, 24, 15, 15),
	(NULL, 25, 1, 25), (NULL, 25, 2, 19), (NULL, 25, 3, 10), (NULL, 25, 4, 11), (NULL, 25, 5, 13), (NULL, 25, 6, 17), (NULL, 25, 7, 23), (NULL, 25, 8, 14), (NULL, 25, 9, 9),  (NULL, 25, 10, 20), (NULL, 25, 11, 18), (NULL, 25, 12, 29), (NULL, 25, 13, 15), (NULL, 25, 14, 20), (NULL, 25, 15, 26),
	(NULL, 26, 1, 5),  (NULL, 26, 2, 13), (NULL, 26, 3, 21), (NULL, 26, 4, 19), (NULL, 26, 5, 23), (NULL, 26, 6, 13), (NULL, 26, 7, 14), (NULL, 26, 8, 7),  (NULL, 26, 9, 19), (NULL, 26, 10, 7),  (NULL, 26, 11, 29), (NULL, 26, 12, 14), (NULL, 26, 13, 10), (NULL, 26, 14, 17), (NULL, 26, 15, 28),
	(NULL, 27, 1, 15), (NULL, 27, 2, 9),  (NULL, 27, 3, 28), (NULL, 27, 4, 28), (NULL, 27, 5, 30), (NULL, 27, 6, 21), (NULL, 27, 7, 24), (NULL, 27, 8, 25), (NULL, 27, 9, 24), (NULL, 27, 10, 18), (NULL, 27, 11, 14), (NULL, 27, 12, 16), (NULL, 27, 13, 28), (NULL, 27, 14, 26), (NULL, 27, 15, 13),
	(NULL, 28, 1, 17), (NULL, 28, 2, 8),  (NULL, 28, 3, 28), (NULL, 28, 4, 24), (NULL, 28, 5, 14), (NULL, 28, 6, 23), (NULL, 28, 7, 30), (NULL, 28, 8, 25), (NULL, 28, 9, 10), (NULL, 28, 10, 23), (NULL, 28, 11, 9),  (NULL, 28, 12, 27), (NULL, 28, 13, 5),  (NULL, 28, 14, 5),  (NULL, 28, 15, 19),
	(NULL, 29, 1, 17), (NULL, 29, 2, 15), (NULL, 29, 3, 23), (NULL, 29, 4, 9),  (NULL, 29, 5, 20), (NULL, 29, 6, 10), (NULL, 29, 7, 12), (NULL, 29, 8, 9),  (NULL, 29, 9, 6),  (NULL, 29, 10, 21), (NULL, 29, 11, 21), (NULL, 29, 12, 15), (NULL, 29, 13, 12), (NULL, 29, 14, 30), (NULL, 29, 15, 17),
	(NULL, 30, 1, 5),  (NULL, 30, 2, 12), (NULL, 30, 3, 30), (NULL, 30, 4, 17), (NULL, 30, 5, 28), (NULL, 30, 6, 25), (NULL, 30, 7, 9),  (NULL, 30, 8, 27), (NULL, 30, 9, 7),  (NULL, 30, 10, 13), (NULL, 30, 11, 6),  (NULL, 30, 12, 24), (NULL, 30, 13, 23), (NULL, 30, 14, 18), (NULL, 30, 15, 13);

INSERT INTO dobavljac VALUES
	( 1, 'ComputerSphere', '501-13-6908', 'ComputerSphere@poslovna-tvrtka.hr', 52100, 'Trg Republike 1, 52100 Pula'),
	( 2, 'LaptopLy', '555-51-9843', 'LaptopLy@poslovna-tvrtka.hr', 47000, 'Drežnik 20a, 47000 Karlovac'),
	( 3, 'MaxiChip', '624-88-8462', 'MaxiChip@poslovna-tvrtka.hr', 21210, 'Matoševa 121, 21210 Solin'),
	( 4, 'TechIRT', '309-62-0170', 'TechIRT@poslovna-tvrtka.hr', 51000, 'Milutina Barača 6, 51000 Rijeka'),
	( 5, 'FastSilicon', '158-22-0647', 'FastSilicon@poslovna-tvrtka.hr', 44000, 'A. Augustinčića 28, 44000 Sisak'),
	( 6, 'PSYByte', '263-63-5264', 'PSYByte@poslovna-tvrtka.hr', 10000, 'Ozaljska 93, 10000 Zagreb'),
	( 7, 'PathPad', '915-75-8645', 'PathPad@poslovna-tvrtka.hr', 23000, 'Ruđera Boškovića 5, 23000 Zadar'),
	( 8, 'DigitalXO', '018-51-0669', 'DigitalXO@poslovna-tvrtka.hr', 35000, 'Fra Marijana Jurića 29, 35000 Slavonski Brod'),
	( 9, 'ScanectX', '759-24-4527', 'ScanectX@poslovna-tvrtka.hr', 20000, 'Od Batale 1, 20000 Dubrovnik'),
	( 10, 'LogicMouse', '170-18-4078', 'LogicMouse@poslovna-tvrtka.hr', 42000, 'K. Filića 4, 42000 Varaždin'),
	( 11, 'SyncPhonic', '623-99-3511', 'SyncPhonic@poslovna-tvrtka.hr', 32000, 'Priljevo 42, 32000 Vukovar'),
	( 12, 'Acoustro', '135-90-3280', 'Acoustro@poslovna-tvrtka.hr', 22000, 'Trg Andrije Hebranga 4, 22000 Šibenik'),
	( 13, 'DeitChip', '881-84-7634', 'DeitChip@poslovna-tvrtka.hr', 33000, 'Ivana Mažuranića 27, 33000 Virovitica'),
	( 14, 'Pixoric', '701-69-7580', 'Pixoric@poslovna-tvrtka.hr', 32100, 'Trg J. Runjanina 1, 32100 Vinkovci'),
	( 15, 'rCard', '564-66-1890', 'rCard@poslovna-tvrtka.hr', 52100, 'Trg Republike 1, 52100 Pula'),
	( 16, 'Cacheous', '050-13-2808', 'Cacheous@poslovna-tvrtka.hr', 47000, 'Banjavčićeva 5, 47000 Karlovac'),
	( 17, 'FlashSignal', '534-54-5570', 'FlashSignal@poslovna-tvrtka.hr', 51000, 'Vrtlarski put 9, 51000 Rijeka'),
	( 18, 'Disksy', '570-96-1347', 'Disksy@poslovna-tvrtka.hr', 10000, 'Kranjčevićeva 30, 10000 Zagreb'),
	( 19, 'JumpBytes', '102-58-6099', 'JumpBytes@poslovna-tvrtka.hr', 10000, 'Branka Klarića 6, 10000 Zagreb'),
	( 20, 'CableArc', '297-57-3747', 'CableArc@poslovna-tvrtka.hr', 10000, 'Ulica grada Vukovara 254, 10000 Zagreb'),
	( 21, 'ZoomCast', '648-64-8411', 'ZoomCast@poslovna-tvrtka.hr', 51000, 'Đure Šporera 3, 51000 Rijeka'),
	( 22, 'WireLaze', '293-84-4623', 'WireLaze@poslovna-tvrtka.hr', 52100, 'Šijanska cesta 4, 52100 Pula'),
	( 23, 'DesktopFusion', '696-39-8456', 'DesktopFusion@poslovna-tvrtka.hr', 23000, 'Crno 137, 23000 Zadar'),
	( 24, 'ChromeBox', '049-02-4275', 'ChromeBox@poslovna-tvrtka.hr', 42000, 'Kralja Petra Krešimira IV 25, 42000 Varaždin'),
	( 25, 'VirtualBox', '564-65-6299', 'VirtualBox@poslovna-tvrtka.hr', 52440, 'Nikole Tesle 16, 52440 Poreč'),
	( 26, 'Bootable', '334-07-3404', 'Bootable@poslovna-tvrtka.hr', 35000, 'N. Zrinskog 65, 35000 Slavonski Brod'),
	( 27, 'TrackPixel', '931-69-7996', 'TrackPixel@poslovna-tvrtka.hr', 21000, 'Hercegovačka 136, 21000 Split'),
	( 28, 'PhotoTronix', '363-40-5348', 'PhotoTronix@poslovna-tvrtka.hr', 21000, 'Kopilica 62, 21000 Split'),
    ( 29, 'VideoScopic', '525-98-7825', 'VideoScopic@poslovna-tvrtka.hr', 44000, 'F. Lovrića 2, 44000 Sisak'),
	( 30, 'NichePixel', '545-58-3623', 'NichePixel@poslovna-tvrtka.hr', 20000, 'Sv. Dominika 9, 20000 Dubrovnik');

INSERT INTO dobavljac_racun VALUES    
	( 1, 1, 4, STR_TO_DATE('28.11.2020.', '%d.%m.%Y.')),
	( 2, 2, 29, STR_TO_DATE('01.05.2020.', '%d.%m.%Y.')),
	( 3, 3, 13, STR_TO_DATE('13.08.2019.', '%d.%m.%Y.')),
	( 4, 4, 5, STR_TO_DATE('07.02.2020.', '%d.%m.%Y.')),
	( 5, 5, 5, STR_TO_DATE('28.06.2019.', '%d.%m.%Y.')),
	( 6, 6, 16, STR_TO_DATE('11.09.2020.', '%d.%m.%Y.')),
	( 7, 7, 30, STR_TO_DATE('27.03.2020.', '%d.%m.%Y.')),
	( 8, 8, 10, STR_TO_DATE('19.03.2020.', '%d.%m.%Y.')),
	( 9, 9, 18, STR_TO_DATE('04.12.2019.', '%d.%m.%Y.')),
	( 10, 10, 21, STR_TO_DATE('14.04.2019.', '%d.%m.%Y.')),
	( 11, 11, 18, STR_TO_DATE('05.10.2020.', '%d.%m.%Y.')),
	( 12, 12, 7, STR_TO_DATE('23.03.2019.', '%d.%m.%Y.')),
	( 13, 13, 17, STR_TO_DATE('24.08.2019.', '%d.%m.%Y.')),
	( 14, 14, 11, STR_TO_DATE('18.11.2020.', '%d.%m.%Y.')),
	( 15, 15, 3, STR_TO_DATE('03.11.2019.', '%d.%m.%Y.'));
    
INSERT INTO dobavljac_stavka_racun VALUES
	( 1, 1, 6, 26, 10),
	( 2, 1, 2, 9, 10),
	( 3, 1, 6, 20, 4),
	( 4, 1, 28, 30, 6),
	( 5, 1, 29, 14, 10),
	( 6, 2, 22, 28, 8),
	( 7, 2, 21, 24, 12),
	( 8, 2, 3, 12, 9),
	( 9, 3, 30, 10, 10),
	( 10, 3, 3, 9, 6),
	( 11, 3, 13, 30, 7),
	( 12, 3, 4, 12, 8),
	( 13, 3, 13, 7, 5),
	( 14, 3, 17, 17, 12),
	( 15, 4, 23, 18, 6),
	( 16, 4, 23, 11, 3),
	( 17, 4, 26, 27, 10),
	( 18, 4, 1, 8, 3),
	( 19, 4, 29, 17, 5),
	( 20, 4, 8, 19, 4),
	( 21, 5, 14, 21, 5),
	( 22, 5, 15, 7, 10),
	( 23, 5, 3, 29, 4),
	( 24, 6, 12, 27, 3),
	( 25, 6, 25, 2, 3),
	( 26, 6, 30, 4, 8),
	( 27, 6, 27, 19, 8),
	( 28, 7, 10, 24, 6),
	( 29, 7, 20, 12, 7),
	( 30, 7, 9, 21, 11),
	( 31, 7, 27, 28, 9),
	( 32, 8, 20, 16, 11),
	( 33, 8, 30, 9, 9),
	( 34, 9, 25, 15, 11),
	( 35, 9, 12, 3, 7),
	( 36, 9, 12, 29, 4),
	( 37, 9, 15, 28, 11),
	( 38, 9, 16, 6, 7),
	( 39, 10, 11, 3, 9),
	( 40, 10, 17, 29, 10),
	( 41, 10, 22, 4, 12),
	( 42, 10, 5, 5, 4),
	( 43, 10, 1, 13, 8),
	( 44, 10, 3, 28, 8),
	( 45, 11, 22, 24, 12),
	( 46, 11, 16, 1, 12),
	( 47, 11, 19, 15, 8),
	( 48, 12, 5, 5, 8),
	( 49, 12, 10, 11, 12),
	( 50, 12, 16, 28, 9),
	( 51, 13, 3, 26, 5),
	( 52, 13, 12, 3, 3),
	( 53, 14, 27, 26, 7),
	( 54, 14, 22, 19, 12),
	( 55, 14, 10, 7, 5),
	( 56, 14, 25, 24, 9),
	( 57, 14, 2, 2, 9),
	( 58, 15, 18, 28, 4),
	( 59, 15, 24, 4, 11),
	( 60, 15, 29, 19, 4);
    
INSERT INTO pregled_popravak_racunala VALUES
	( 1, 4, 16, 1,  STR_TO_DATE('16.03.2020.', '%d.%m.%Y.')),
	( 2, 7, 10, 1,  STR_TO_DATE('30.08.2019.', '%d.%m.%Y.')),
	( 3, 8, 29, 2,  STR_TO_DATE('05.11.2019.', '%d.%m.%Y.')),
	( 4, 11, 15, 1,  STR_TO_DATE('10.04.2020.', '%d.%m.%Y.')),
	( 5, 11, 24, 1,  STR_TO_DATE('13.02.2020.', '%d.%m.%Y.')),
	( 6, 20, 11, 2,  STR_TO_DATE('09.08.2019.', '%d.%m.%Y.')),
	( 7, 21, 26, 1,  STR_TO_DATE('23.08.2019.', '%d.%m.%Y.')),
	( 8, 22, 3, 1,  STR_TO_DATE('08.11.2019.', '%d.%m.%Y.')),
	( 9, 23, 24, 1,  STR_TO_DATE('14.01.2020.', '%d.%m.%Y.')),
	( 10, 24, 30, 1,  STR_TO_DATE('25.04.2020.', '%d.%m.%Y.')),
	( 11, 25, 11, 2,  STR_TO_DATE('30.06.2020.', '%d.%m.%Y.')),
	( 12, 25, 8, 1,  STR_TO_DATE('27.5.2019.', '%d.%m.%Y.')),
	( 13, 27, 19, 1,  STR_TO_DATE('01.09.2019.', '%d.%m.%Y.')),
	( 14, 29, 10, 1,  STR_TO_DATE('16.06.2019.', '%d.%m.%Y.')),
	( 15, 30, 12, 1,  STR_TO_DATE('27.01.2022.', '%d.%m.%Y.'));

    
INSERT INTO akcije_snizenja VALUES
	( 1, 19, 24, STR_TO_DATE('03.05.2019.', '%d.%m.%Y.'), STR_TO_DATE('23.08.2019.', '%d.%m.%Y.')),
	( 2, 14, 33, STR_TO_DATE('15.03.2019.', '%d.%m.%Y.'), STR_TO_DATE('18.07.2019.', '%d.%m.%Y.')),
	( 3, 28, 11, STR_TO_DATE('14.01.2019.', '%d.%m.%Y.'), STR_TO_DATE('16.11.2019.', '%d.%m.%Y.')),
	( 4, 18, 17, STR_TO_DATE('04.05.2019.', '%d.%m.%Y.'), STR_TO_DATE('19.07.2019.', '%d.%m.%Y.')),
	( 5, 1, 15, STR_TO_DATE('13.06.2019.', '%d.%m.%Y.'), STR_TO_DATE('21.08.2019.', '%d.%m.%Y.')),
	( 6, 24, 26, STR_TO_DATE('04.04.2019.', '%d.%m.%Y.'), STR_TO_DATE('30.11.2019.', '%d.%m.%Y.')),
	( 7, 30, 24, STR_TO_DATE('09.03.2019.', '%d.%m.%Y.'), STR_TO_DATE('20.11.2019.', '%d.%m.%Y.')),
	( 8, 4, 40, STR_TO_DATE('05.05.2020.', '%d.%m.%Y.'), STR_TO_DATE('23.12.2020.', '%d.%m.%Y.')),
	( 9, 6, 20, STR_TO_DATE('14.05.2020.', '%d.%m.%Y.'), STR_TO_DATE('29.09.2020.', '%d.%m.%Y.')),
	( 10, 7, 10, STR_TO_DATE('14.06.2019.', '%d.%m.%Y.'), STR_TO_DATE('16.12.2019.', '%d.%m.%Y.')),
	( 11, 8, 32, STR_TO_DATE('03.04.2020.', '%d.%m.%Y.'), STR_TO_DATE('30.10.2020.', '%d.%m.%Y.')),
	( 12, 20, 25, STR_TO_DATE('10.02.2019.', '%d.%m.%Y.'), STR_TO_DATE('16.11.2019.', '%d.%m.%Y.')),
	( 13, 29, 25, STR_TO_DATE('03.06.2019.', '%d.%m.%Y.'), STR_TO_DATE('22.11.2019.', '%d.%m.%Y.')),
	( 14, 16, 25, STR_TO_DATE('10.04.2020.', '%d.%m.%Y.'), STR_TO_DATE('29.09.2020.', '%d.%m.%Y.')),
	( 15, 11, 22, STR_TO_DATE('02.06.2020.', '%d.%m.%Y.'), STR_TO_DATE('24.11.2020.', '%d.%m.%Y.'));

INSERT INTO bodovi VALUES 
	(1, 1, 20),
	(2, 2, 100),
	(3, 3, 87),
	(4, 4, 33),
	(5, 5, 64),
	(6, 6, 39),
	(7, 7, 24),
	(8, 8, 29),
	(9, 9, 22),
	(10, 10, 52),
	(11, 11, 121),
	(12, 12, 16),
	(13, 13, 8),
	(14, 14, 9),
	(15, 15, 71),
	(16, 16, 22),
	(17, 17, 31),
	(18, 18, 68),
	(19, 19, 42),
	(20, 20, 22),
	(21, 21, 0),
	(22, 22, 64),
	(23, 23, 33),
	(24, 24, 204),
	(25, 25, 0),
	(26, 26, 17),
	(27, 27, 4),
	(28, 28, 8),
	(29, 29, 16),
	(30, 30, 55);
    
    -- prikaži koliko je svaki kupac (ime i prezime) utrošio novaca (ukupno) uzevši u obzir popuste/akcije i iskorištene bodove

SELECT id_kupac,CAST(ukupno AS DECIMAL(10,2)) AS sveukupno FROM 
(SELECT id_kupac,(SUM(izracun_stavke_artikla)-iskoristeni_bodovi) AS ukupno FROM
(SELECT id_kupac,iskoristeni_bodovi,kolicina,snizena_cijena,(snizena_cijena*kolicina) AS izracun_stavke_artikla FROM
(SELECT *,
CASE WHEN datum_izdavanja>pocetak AND datum_izdavanja<kraj THEN  (cijena_prodajna-(postotak/100*cijena_prodajna)) 
ELSE cijena_prodajna
END AS snizena_cijena
FROM (
SELECT id_kupac,id_artikl,datum_izdavanja,iskoristeni_bodovi,kolicina,cijena_prodajna,postotak,kraj,pocetak 
FROM kupac_racun 
NATURAL JOIN kupac_stavka_racun 
NATURAL JOIN artikl 
NATURAL LEFT JOIN akcije_snizenja
) AS priprema) AS snizeno) AS izracun
GROUP BY id_kupac) AS konacan_izracun;

-- Koliko bodova je kupac ostvario sa kupnjom.

CREATE VIEW dobiveni_bodovi AS
SELECT id_kupac,SUM(ostvareni_bodovi) AS sveukupno_bodovi
FROM (SELECT id_kupac,id_artikl,kolicina,bodovi_artikla,(kolicina*bodovi_artikla) AS ostvareni_bodovi
FROM kupac_racun 
NATURAL JOIN kupac_stavka_racun 
NATURAL JOIN artikl) AS izracun
GROUP BY id_kupac;

-- Ukupna cijena naručenih stvari za poslovnicu

SELECT id_poslovnica, CAST(ukupno AS DECIMAL(10,2)) AS sveukupno FROM 
(SELECT id_poslovnica,(SUM(izracun_stavke_artikla)) AS ukupno FROM
(SELECT id_poslovnica,(cijena_dobavljaca*kolicina) AS izracun_stavke_artikla
FROM (SELECT id_poslovnica,id_artikl,datum_izdavanja,kolicina,cijena_dobavljaca
FROM dobavljac_racun 
NATURAL JOIN dobavljac_stavka_racun 
NATURAL JOIN artikl ) AS izracun) AS konacan_izracun 
GROUP BY id_poslovnica) AS test;

-- Količina artilka u poslovnicama

SELECT id_poslovnica, naziv, SUM(kolicina) as kolicina_artikla
FROM lokacija_artikla NATURAL JOIN artikl
GROUP BY id_lokacija;


-- Ažurirani bodovi

CREATE VIEW novi_bodovi AS
SELECT id_bodovi,id_kupac,kolicina AS stari_bodovi,(kolicina+sveukupno_bodovi-iskoristeni_bodovi) AS novi_bodovi
FROM bodovi
NATURAL JOIN dobiveni_bodovi
NATURAL JOIN kupac_racun;

CREATE VIEW smanjeni_artikli AS
SELECT id_artikl, id_poslovnica, SUM(kolicina) AS smanjenje
FROM kupac_racun
NATURAL JOIN
vrsta_narudzbe
NATURAL JOIN
kupac_stavka_racun
GROUP BY id_poslovnica,id_artikl;

CREATE VIEW dodani_artikli AS
SELECT id_artikl, id_poslovnica, SUM(kolicina) AS povecanje
FROM dobavljac_racun
NATURAL JOIN
dobavljac_stavka_racun
GROUP BY id_poslovnica,id_artikl;

SELECT id_lokacija, id_artikl, kolicina, smanjenje, povecanje, (kolicina-smanjenje+povecanje) AS nova_kolicina
FROM 
(SELECT id_lokacija, id_artikl, kolicina, COALESCE(smanjenje, 0 ) AS smanjenje, COALESCE(povecanje, 0 ) AS povecanje FROM 
lokacija_artikla
NATURAL LEFT JOIN
smanjeni_artikli
NATURAL LEFT JOIN
dodani_artikli) AS pom
