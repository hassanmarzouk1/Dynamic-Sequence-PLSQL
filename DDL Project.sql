/* # First project
__________
dynamic sql : write ddl statements inside plsql code
__________
create seq, trg pairs on all tables in the schema
	- using loop
	- drop all sequences first in the loop
	- replace any triggers if found 
	- set sequences to start with max id + 1
		for each table
	ignore increment by [ only increment by 1 ]
	- donot forget to choose the PK column for each table
	- ignore any not numbers primary key or composite keys
  */

 -- SHOW TABLES AND VIEW NAMES
SELECT * FROM USER_TABLES;
-- SHOW TABLE, COLUMN NAMES AND COLUMN DATA TYPE
SELECT * FROM USER_TAB_COLUMNS; 
-- SHOW CONSTRAINT NAME AND ITS TYPE AND TABLE NAME
SELECT * FROM USER_CONSTRAINTS; 
-- SHOW CONSTRAINT , TABLE, COLUMN NAMES
SELECT * FROM USER_CONS_COLUMNS;
-- SHOW ALL SEQs of THE USER
SELECT * FROM USER_SEQUENCES; 

--> SHOW TABLE NAME, CONSTRAINT NAME, CONSTRAINT DT 
-- REMEBER : ==> ( NOT NUMBERS OR COMPOSITE PRIMARY KEY !!)

DECLARE
  CURSOR TAB_CURSOR IS
  SELECT TC.TABLE_NAME, TC.COLUMN_NAME, TC.DATA_TYPE, UC.CONSTRAINT_NAME, UC.CONSTRAINT_TYPE
  FROM USER_TAB_COLUMNS TC
  INNER JOIN USER_CONS_COLUMNS UCC        ON TC.TABLE_NAME = UCC.TABLE_NAME AND TC.COLUMN_NAME = UCC.COLUMN_NAME
  INNER JOIN USER_CONSTRAINTS  UC         ON UC.CONSTRAINT_NAME = UCC.CONSTRAINT_NAME
  WHERE TC.DATA_TYPE='NUMBER'
  AND UC.CONSTRAINT_TYPE='P'
  AND UC.CONSTRAINT_NAME IN (
                              SELECT UCC.CONSTRAINT_NAME
                              FROM USER_CONS_COLUMNS UCC
                              GROUP BY UCC.CONSTRAINT_NAME
                              HAVING COUNT(UCC.CONSTRAINT_NAME) =1 );
                              
  VMAX_ID NUMBER;

BEGIN
-- Drop all sequences in a loop
FOR SEQ IN (SELECT SEQUENCE_NAME FROM USER_SEQUENCES) LOOP
  EXECUTE IMMEDIATE
  'DROP SEQUENCE '||SEQ.SEQUENCE_NAME ;
END LOOP;

-- Allocate the maximum value of any primary key column in a variable in a loop:
FOR TAB_REC IN TAB_CURSOR LOOP

  EXECUTE IMMEDIATE
 'SELECT NVL(MAX('||TAB_REC.COLUMN_NAME||'), 0) +1
  FROM ' || TAB_REC.TABLE_NAME 
  INTO VMAX_ID;

-- Creation of Dynamic Sequence / Trigger pair for each table:
-- Sequence
  EXECUTE IMMEDIATE
 'CREATE SEQUENCE '||TAB_REC.TABLE_NAME ||'_PK_SEQUENCE 
  START WITH '|| VMAX_ID || 
' INCREMENT BY 1 
  NOCYCLE';
  
-- Trigger
  EXECUTE IMMEDIATE
' CREATE OR REPLACE TRIGGER '|| TAB_REC.TABLE_NAME ||'_TRIGGER 
  BEFORE INSERT ON '|| TAB_REC.TABLE_NAME ||
' FOR EACH ROW
  BEGIN ' ||
-- For Toad:  Highlight COLUMN NAME
':new.'|| TAB_REC.COLUMN_NAME ||' := ' || TAB_REC.TABLE_NAME|| '_PK_SEQUENCE.nextval;
END;';
END LOOP;
END;




SELECT * FROM COURSES;

INSERT INTO COURSES (CRS_NAME, CRS_PRICE)
VALUES ('ORCALE',300);
