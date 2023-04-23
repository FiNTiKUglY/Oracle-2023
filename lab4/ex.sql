CREATE OR REPLACE FUNCTION PARSE_REQUEST(json JSON_OBJECT_T) RETURN CLOB IS
    tmp_array JSON_ARRAY_T;
    tmp_json JSON_OBJECT_T;

    request CLOB;
    columns_string CLOB;
    tables_string CLOB;
    joins_string CLOB;
    filters_string CLOB;
BEGIN
    request := json.GET_STRING('request');

    IF request = 'SELECT' THEN
        tmp_array := json.GET_ARRAY('columns');
        FOR i IN 0..tmp_array.GET_SIZE() - 1
        LOOP
            IF i = tmp_array.GET_SIZE() - 1 THEN
                columns_string := columns_string || tmp_array.GET_STRING(i);
            ELSE
                columns_string := columns_string || tmp_array.GET_STRING(i) || ', ';
            END IF;
        END LOOP;

        tmp_array := json.GET_ARRAY('tables');
        FOR i IN 0..tmp_array.GET_SIZE() - 1
        LOOP
            IF i = tmp_array.GET_SIZE() - 1 THEN
                tables_string := tables_string || tmp_array.GET_STRING(i);
            ELSE
                tables_string := tables_string || tmp_array.GET_STRING(i) || ', ';
            END IF;
        END LOOP;

        tmp_array := json.GET_ARRAY('joins');
        IF tmp_array IS NOT NULL THEN
            IF tmp_array.GET_SIZE() <> 0 THEN
                FOR i IN 0..tmp_array.GET_SIZE() - 1
                LOOP
                    tmp_json := TREAT(tmp_array.GET(i) AS JSON_OBJECT_T);
                    joins_string := joins_string || ' ' || tmp_json.GET_STRING('type') || ' JOIN ' || 
                        tmp_json.GET_STRING('table') || ' ON ' || PARSE_REQUEST(TREAT(tmp_json.GET('filters') AS JSON_OBJECT_T));
                END LOOP;
            END IF;
        END IF;

        tmp_json := TREAT(json.GET('filters') AS JSON_OBJECT_T);
        IF tmp_json IS NOT NULL THEN
            filters_string := ' WHERE ' || PARSE_REQUEST(tmp_json);
            IF filters_string = ' WHERE ' THEN
                filters_string := '';
            END IF;
        END IF;

        RETURN 'SELECT ' || columns_string || ' FROM ' || tables_string || joins_string || filters_string;
    END IF;
END;