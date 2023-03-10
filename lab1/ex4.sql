CREATE OR REPLACE FUNCTION insert_command(ex_id NUMBER) RETURN VARCHAR2 IS
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
    
    RETURN utl_lms.format_message('INSERT INTO MyTable(id, val) VALUES(%s, %s)', TO_CHAR(ex_id), TO_CHAR(ex_val));
END;

