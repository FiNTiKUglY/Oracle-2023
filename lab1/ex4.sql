CREATE OR REPLACE FUNCTION insert_command(ex_id number) RETURN VARCHAR2 IS
    ex_val NUMBER;
    answer VARCHAR2(30);
    
    CURSOR ct1 IS
    SELECT val
    FROM MyTable
    WHERE id = ex_id;
    
BEGIN
    open ct1;
    fetch ct1 into ex_val;
    close ct1;
    
    RETURN 'INSERT INTO MyTable(id, val) VALUES(' + ex_id + ex_val;
END;

