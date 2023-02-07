create or replace NONEDITIONABLE FUNCTION odd_even RETURN VARCHAR2 IS
    even_count NUMBER;
    odd_count NUMBER;
    answer varchar2(10);
    
    CURSOR ct1 IS
    SELECT COUNT(*)
    FROM MyTable
    WHERE MOD(val, 2) = 0;
    
    CURSOR ct2 IS
    SELECT COUNT(*)
    FROM MyTable
    WHERE MOD(val, 2) <> 0;
    
BEGIN
    open ct1;
    fetch ct1 into even_count;
    close ct1;
    
    open ct2;
    fetch ct2 into odd_count;
    close ct2;
    
    IF (even_count > odd_count) THEN 
        answer := 'TRUE';
    ELSIF (even_count < odd_count) THEN
        answer := 'FALSE';
    ELSE
        answer := 'EQUAL';
    END IF;
    RETURN answer;
END;

