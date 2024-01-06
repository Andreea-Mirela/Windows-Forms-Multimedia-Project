SET SERVEROUTPUT ON;


CREATE TABLE Investitii (
id_investitie NUMBER,
tip VARCHAR2(255),
data_investitie VARCHAR2(255),
poza ORDImage,
semnatura_poza ORDImageSignature
);

CREATE OR REPLACE DIRECTORY DIRECTOR_LUCRU AS 'D:\Media';

--dau drepturi utilizatorului care vine din front end
GRANT READ ON DIRECTORY DIRECTOR_LUCRU TO PUBLIC WITH GRANT OPTION; --dau drepturi inafara bd pt a citi informatie

--inserare
CREATE OR REPLACE PROCEDURE PROCEDURA_INSERARE (v_id IN NUMBER, v_tip IN VARCHAR2, v_data_investitie IN VARCHAR2, nume_fisier IN VARCHAR2) --ia calea din directorul de lucru, dar are nevoie de nume
IS
obj ORDImage;
ctx RAW(64):=NULL;
BEGIN

 --aloc spatiu
 INSERT INTO Investitii (id_investitie,tip,data_investitie,poza,semnatura_poza)
 VALUES(v_id,v_tip,v_data_investitie,ORDImage.init(),ORDImageSignature.init());
 
 --import in obj
 SELECT poza INTO obj
 FROM Investitii
 WHERE id_investitie=v_id FOR UPDATE;
 
 obj.importFrom(ctx,'file','DIRECTOR_LUCRU',nume_fisier); --am in obj imaginea
 
 --update din obj in poza din tabela
 UPDATE Investitii
 SET poza = obj
 WHERE id_investitie=v_id;
 
 COMMIT;
END;
/
--afisare
CREATE OR REPLACE PROCEDURE PROCEDURA_AFISARE(v_id IN NUMBER, flux OUT BLOB)
IS
obj ORDImage; --preluare imagine
BEGIN

SELECT poza INTO obj
FROM Investitii
WHERE id_investitie=v_id;

flux:=obj.getContent();--getContent returneaza continutul din atributul de tip ordimage

END;
/
--export
CREATE OR REPLACE PROCEDURE PROCEDURA_EXPORT(v_id IN NUMBER, nume_fisier IN VARCHAR2)
IS
obj ORDImage;
ctx RAW(64):=NULL;
BEGIN
--incarc in obj ceea ce contine tuplul curent in atributul poza
SELECT poza INTO obj
FROM Investitii
WHERE id_investitie = v_id FOR UPDATE;

obj.export(ctx,'file','DIRECTOR_LUCRU',nume_fisier);
END;
/
--inserare de pe internet
DECLARE
obj ORDImage;
ctx RAW(64):=null;
BEGIN

INSERT INTO Investitii 
VALUES(1,'Actiune TESLA','12-MAR-2019',ORDSYS.ORDImage.init(), ORDSYS.ORDImageSignature.init());

SELECT poza INTO obj
FROM Investitii
WHERE id_investitie=1 FOR UPDATE;

obj.importfrom(ctx,'http','http://i.pinimg.com/564x/eb/93/f9/','eb93f90b67e0022291381d4f429e4905.jpg');

UPDATE Investitii
SET poza = obj
WHERE id_investitie = 1;

COMMIT;

END;
/

--inserare de pe internet
DECLARE
obj ORDImage;
ctx RAW(64):=null;
BEGIN

INSERT INTO Investitii 
VALUES(2,'Obligatiune','13-OCT-2020',ORDSYS.ORDImage.init(), ORDSYS.ORDImageSignature.init());

SELECT poza INTO obj
FROM Investitii
WHERE id_investitie=2 FOR UPDATE;

obj.importfrom(ctx,'http','http://i.pinimg.com/564x/6c/f5/60/','6cf560eee10bcbf0043347a18e4815f3.jpg');

UPDATE Investitii
SET poza = obj
WHERE id_investitie = 2;

COMMIT;

END;
/

--inserare de pe internet
DECLARE
obj ORDImage;
ctx RAW(64):=null;
BEGIN

INSERT INTO Investitii 
VALUES(3,'Fond mutual','13-OCT-2020',ORDSYS.ORDImage.init(), ORDSYS.ORDImageSignature.init());

SELECT poza INTO obj
FROM Investitii
WHERE id_investitie=3 FOR UPDATE;

obj.importfrom(ctx,'http','http://i.pinimg.com/564x/d3/f4/1b/','d3f41be339f89c1fb7bdad9d33a6fc81.jpg');

UPDATE Investitii
SET poza = obj
WHERE id_investitie = 3;

COMMIT;

END;
/

--inserare de pe internet
DECLARE
obj ORDImage;
ctx RAW(64):=null;
BEGIN

INSERT INTO Investitii 
VALUES(4,'Fond de acumulare','15-IAN-2020',ORDSYS.ORDImage.init(), ORDSYS.ORDImageSignature.init());

SELECT poza INTO obj
FROM Investitii
WHERE id_investitie=4 FOR UPDATE;

obj.importfrom(ctx,'http','http://i.pinimg.com/564x/85/46/4f/','85464f107c7decf4fd1fdabe9f86be26.jpg');

UPDATE Investitii
SET poza = obj
WHERE id_investitie = 4;

COMMIT;

END;
/



--prelucrare imagini
--flip
DECLARE 
obj ORDImage;
BEGIN

SELECT poza INTO obj 
FROM Investitii
WHERE id_investitie=1 FOR UPDATE;

obj.PROCESS('flip');

UPDATE Investitii
SET poza=obj
WHERE id_investitie=1;

COMMIT;

END;
/

--crop
DECLARE 
obj ORDImage;
BEGIN

SELECT poza INTO obj 
FROM Investitii
WHERE id_investitie=6 FOR UPDATE;

obj.PROCESS('cut=10,10,60,60');

UPDATE Investitii
SET poza=obj
WHERE id_investitie=2;

COMMIT;

END;
/




create or replace PROCEDURE PROCEDURA_GENERARE_SEMNATURI
IS
    currentImage ORDImage;
    currentSignature ORDImageSignature;
    ctx RAW(4000):=null;
BEGIN
   FOR i IN (SELECT id_investitie FROM Investitii)
   LOOP
     SELECT s.poza, s.semnatura_poza 
     INTO currentImage,currentSignature
     FROM Investitii s
     WHERE s.id_investitie=i.id_investitie FOR UPDATE;
     currentSignature.generateSignature(currentImage);

     UPDATE Investitii s
     SET s.semnatura_poza = currentSignature
     WHERE s.id_investitie = i.id_investitie;
   END LOOP;
END;

create or replace PROCEDURE regasire (nfis in varchar2, cculoare in decimal, ctextura in decimal, cforma in decimal, clocatie in decimal, idrez out integer)
IS
scor NUMBER;
qsemn ORDImageSignature;
--img de referinta si signatura ei
qimg ORDimage;
myimg ORDImage;
mysemn ORDImageSignature;
mymin number;
BEGIN
idrez:=0;
--img de referinta nu o sa o stocam in bd
qimg:=ORDImage.init('file','DIRECTOR_LUCRU',nfis);
qimg.setproperties;
qsemn:=ORDImageSignature.init();
DBMS_LOB.CREATETEMPORARY(qsemn.signature,TRUE);
qsemn.generateSignature(qimg);
mymin:=100;
FOR x IN (SELECT id_investitie FROM Investitii)
LOOP
SELECT s.poza, s.semnatura_poza INTO myimg, mysemn FROM Investitii s WHERE s.id_investitie=x.id_investitie;
scor:=ORDImageSignature.evaluateScore(qsemn,mysemn,'color='||cculoare||
' texture='|| ctextura||' shape='|| cforma||' location='||clocatie||'');
IF scor<mymin THEN 
    mymin:=scor;
    idrez:=x.id_investitie;
END IF;
END LOOP;
END;


-- Generare semnaturi
CREATE OR REPLACE PROCEDURE PROCEDURA_GENERARE_SEMNATURI
IS
    currentImage ORDImage;
    currentSignature ORDImageSignature;
    ctx RAW(4000):=null;
BEGIN
   FOR i IN (SELECT id_investitie FROM Investitii)
   LOOP
     SELECT s.poza, s.semnatura_poza 
     INTO currentImage,currentSignature
     FROM Investitii s
     WHERE s.id_investitie=i.id_investitie FOR UPDATE;
     currentSignature.generateSignature(currentImage);
     
     UPDATE Investitii s
     SET s.semnatura_poza = currentSignature
     WHERE s.id_investitie = i.id_investitie;
   END LOOP;
END;
/

--recunoastere semantica
--procedura pt compararea imaginilor
CREATE OR REPLACE PROCEDURE regasire (nfis in varchar2, cculoare in decimal, ctextura in decimal, cforma in decimal, clocatie in decimal, idrez out integer)
IS
scor NUMBER;
qsemn ORDImageSignature;
--img de referinta si signatura ei
qimg ORDimage;
myimg ORDImage;
mysemn ORDImageSignature;
mymin number;
BEGIN
idrez:=0;
--img de referinta nu o sa o stocam in bd
qimg:=ORDImage.init('file','DIRECTOR_LUCRU',nfis);
qimg.setproperties;
qsemn:=ORDImageSignature.init();
DBMS_LOB.CREATETEMPORARY(qsemn.signature,TRUE);
qsemn.generateSignature(qimg);
mymin:=100;
FOR x IN (SELECT id_investitie FROM Investitii)
LOOP
SELECT s.poza, s.semnatura_poza INTO myimg, mysemn FROM Investitii s WHERE s.id_investitie=x.id_investitie;
scor:=ORDImageSignature.evaluateScore(qsemn,mysemn,'color='||cculoare||
' texture='|| ctextura||' shape='|| cforma||' location='||clocatie||'');
IF scor<mymin THEN 
    mymin:=scor;
    idrez:=x.id_investitie;
END IF;
END LOOP;
END;
/
  
CREATE TABLE Videos(id_video NUMBER NOT NULL, descrip VARCHAR2(40), video ORDVideo);
--inserare video
DECLARE 
obj ORDVideo;
ctx RAW(64):=NULL;
BEGIN

INSERT INTO Videos VALUES (124, 'Film 2', OrdVideo.init());

SELECT video INTO obj
FROM Videos
WHERE id_video=124 FOR UPDATE;

obj.importFrom(ctx,'file','DIRECTOR_LUCRU','training.mp4');

UPDATE Videos
SET video=obj
WHERE id_video=124;

COMMIT;
END;
/
--afisare video
CREATE OR REPLACE PROCEDURE PROCEDURA_AFISARE_VIDEO(v_id IN NUMBER, flux OUT BLOB)
IS
obj ORDVideo;
BEGIN
SELECT video INTO obj
FROM Videos
WHERE id_video=v_id;
flux:=obj.getContent();
END;
/

DELETE FROM INVESTITII;