CREATE OR REPLACE FUNCTION PARTHENSE_REQUEST(json JSON_OBJECT_T) RETURN CLOB IS
    tmp_array JSON_ARRAY_T;
    tmp_json JSON_OBJECT_T;

    request CLOB;
    columns_string CLOB;
    tables_string CLOB;
    joins_string CLOB;
    filters_string CLOB;
    values_string CLOB;
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
    ELSIF request = 'DELETE' THEN
        tmp_json := TREAT(json.GET('filters') AS JSON_OBJECT_T);

        IF tmp_json IS NOT NULL THEN
            filters_string := ' WHERE ' || PARSE_REQUEST(tmp_json);

            IF filters_string = ' WHERE ' THEN
                filters_string := '';
            END IF;
        END IF;

        RETURN 'DELETE FROM ' || json.GET_STRING('TABLE') || filters_string;
    ELSIF request = 'UPDATE' THEN
        tmp_array := json.GET_ARRAY('columns');

        FOR i IN 0..tmp_array.GET_SIZE() - 1
        LOOP
            tmp_json := TREAT(tmp_array.GET(i) AS JSON_OBJECT_T);

            IF i = tmp_array.get_size() - 1 THEN
                columns_string := columns_string || tmp_json.GET_STRING('key') || ' = ' || tmp_json.GET_STRING('value');
            ELSE
                columns_string := columns_string || tmp_json.GET_STRING('key') || ' = ' || tmp_json.GET_STRING('value') || ', ';
            END IF;
        END LOOP;

        tmp_json := TREAT(json.GET('filters') AS JSON_OBJECT_T);

        IF tmp_json IS NOT NULL THEN
            filters_string := ' WHERE ' || PARSE_REQUEST(tmp_json);

            IF filters_string = ' WHERE ' THEN
                filters_string := '';
            END IF;
        END IF;

        RETURN 'UPDATE ' || json.GET_STRING('table') || ' set ' || columns_string || filters_string;
    ELSIF request = 'INSERT' THEN
        tmp_array := json.GET_ARRAY('columns');

        FOR i IN 0..tmp_array.GET_SIZE() - 1
        LOOP
            tmp_json := TREAT(tmp_array.GET(i) AS JSON_OBJECT_T);

            IF i = tmp_array.GET_SIZE() - 1 THEN
                columns_string := columns_string || tmp_json.GET_STRING('key');
                values_string := values_string || tmp_json.GET_STRING('value');
            ELSE
                columns_string := columns_string || tmp_json.get_string('key') || ', ';
                values_string := values_string || tmp_json.get_string('value') || ', ';
            END IF;
        END LOOP;

        RETURN 'INSERT INTO ' || json.GET_STRING('table') || '(' || columns_string || ') values(' || values_string || ')';
    ELSE
        IF json.GET_STRING('type') = 'value' THEN
            RETURN json.GET_STRING('value');
        ELSIF json.GET_STRING('type') = 'request' THEN
            RETURN '(' || PARSE_REQUEST(TREAT(json.GET('filters') AS JSON_OBJECT_T)) || ')';
        ELSIF json.GET_STRING('type') = 'unary' THEN
            RETURN '(' || json.GET_STRING('operator') || ' ' || PARSE_REQUEST(TREAT(json.GET('operand') AS JSON_OBJECT_T)) || ')';
        ELSIF json.GET_STRING('type') = 'binary' THEN
            RETURN '(' || PARSE_REQUEST(TREAT(json.GET('left') AS JSON_OBJECT_T)) || ' ' || json.GET_STRING('operator') || ' ' || PARSE_REQUEST(TREAT(json.GET('right') AS JSON_OBJECT_T)) || ')';
        ELSE
            RETURN '';
        END IF;
    END IF;
END;