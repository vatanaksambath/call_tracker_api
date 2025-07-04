PGDMP  4    (                 }            call_tracker    16.9    16.9    F           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            G           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            H           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            I           1262    20963    call_tracker    DATABASE     �   CREATE DATABASE call_tracker WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE call_tracker;
                postgres    false                       1255    20964 �   audit_logs_insert(character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, timestamp with time zone, json) 	   PROCEDURE     �  CREATE PROCEDURE public.audit_logs_insert(IN _method character varying, IN _original_url character varying, IN _user_id character varying, IN _ip character varying, IN _user_agent character varying, IN _status_code integer, IN _message character varying, IN _error character varying, IN _duration_ms integer, IN _log_type character varying, IN _log_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP, IN _body json DEFAULT NULL::json)
    LANGUAGE plpgsql
    AS $$

BEGIN
    INSERT INTO tb_audit_logs (
        method,
        original_url,
        user_id,
        ip,
        user_agent,
        status_code,
        message,
        error,
        duration_ms,
        log_type,
        log_time,
		request_body
    ) VALUES (
        _method,
        _original_url,
        _user_id,
        _ip,
        _user_agent,
        _status_code,
        _message,
        _error,
        _duration_ms,
        _log_type,
        COALESCE(_log_time, CURRENT_TIMESTAMP),
		_body
    );
END;
$$;
 �  DROP PROCEDURE public.audit_logs_insert(IN _method character varying, IN _original_url character varying, IN _user_id character varying, IN _ip character varying, IN _user_agent character varying, IN _status_code integer, IN _message character varying, IN _error character varying, IN _duration_ms integer, IN _log_type character varying, IN _log_time timestamp with time zone, IN _body json);
       public          postgres    false            L           1255    20965 G   business_delete(integer, character varying, character varying, integer) 	   PROCEDURE     U  CREATE PROCEDURE public.business_delete(IN p_business_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_business
    WHERE
        business_id = p_business_id;

	IF NOT FOUND THEN
        message := 'Business not found.';
        error := 'No business exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Business deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete business.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.business_delete(IN p_business_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            @           1255    20966 S   business_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.business_insert(IN p_business_name text, IN p_business_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_business(
        business_name,
        business_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_business_name,
        p_business_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Business inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert business.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.business_insert(IN p_business_name text, IN p_business_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            ]           1255    20967 K   business_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.business_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.business_id) INTO v_total
    FROM tb_business a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'business_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.business_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'business_id' AND p_query_search IS NOT NULL
                THEN a.business_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Business retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.business_id,
                        a.business_name,
                        a.business_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_business a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'business_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.business_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'business_id' AND p_query_search IS NOT NULL
                                THEN a.business_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No business found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve business.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.business_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false                       1255    20968 e   business_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.business_update(IN p_business_id integer, IN p_business_name text, IN p_business_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_business
    SET
        business_name = p_business_name,
        business_description = p_business_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        business_id = p_business_id;

	IF NOT FOUND THEN
        message := 'Business not found.';
        error := 'No business exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Business updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update business.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.business_update(IN p_business_id integer, IN p_business_name text, IN p_business_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20969 D   call_log_delete(text, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_delete(IN p_call_log_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    DELETE FROM public.tb_contact_channel
    WHERE menu_trx_id IN (SELECT call_log_detail_id FROM tb_call_log_detail WHERE call_log_id = p_call_log_id);

    DELETE FROM public.tb_call_log
    WHERE call_log_id = p_call_log_id;

    IF NOT FOUND THEN
        message := 'Call Log with ID ' || p_call_log_id || ' not found.';
        error := 'Record not found.';
        "statusCode" := 404;
        RETURN;
    END IF;

    message := 'Call Log and associated contacts deleted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to delete call log and associated contacts.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 �   DROP PROCEDURE public.call_log_delete(IN p_call_log_id text, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            .           1255    21586 �   call_log_detail_history_insert(text, text, integer, timestamp without time zone, timestamp without time zone, text, boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     )  CREATE PROCEDURE public.call_log_detail_history_insert(IN p_call_log_detail_id text, IN p_call_log_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    INSERT INTO public.tb_call_log_detail_history(
        history_date,
        call_log_detail_id,
        call_log_id,
        contact_result_id,
        call_start_datetime,
        call_end_datetime,
        remark,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        NOW(),
        p_call_log_detail_id,
        p_call_log_id,
        p_contact_result_id,
        p_call_start_datetime,
        p_call_end_datetime,
        p_remark,
        p_is_active,
        NOW(),
        p_created_by
    );
 
    FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
    LOOP
        CALL public.contact_channel_history_insert(
            (v_channel->>'channel_type_id')::integer,
            p_menu_id,
            p_call_log_id,
            p_created_by,
            v_contact_channel_id,
            v_msg,
            v_err,
            v_status
        );

        IF v_status != 200 THEN
            RAISE EXCEPTION 'Failed to insert contact channel: % (Status: %)', v_err, v_status;
        END IF;

        FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
        LOOP
            CALL public.contact_value_history_insert(
                v_contact_channel_id,
                v_value->>'user_name',
                v_value->>'contact_number',
                v_value->>'remark',
                (v_value->>'is_primary')::boolean,
                p_created_by,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact value: % (Status: %)', v_err, v_status;
            END IF;
        END LOOP;
    END LOOP;

	message := 'Call Log Detail and Contact History inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert call log detail and contact history.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.call_log_detail_history_insert(IN p_call_log_detail_id text, IN p_call_log_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            6           1255    20971 �   call_log_detail_insert(text, integer, timestamp without time zone, timestamp without time zone, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     \  CREATE PROCEDURE public.call_log_detail_insert(IN p_call_log_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_call_log_detail_id text;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    SELECT * INTO v_call_log_detail_id FROM generate_id('CD');
    INSERT INTO public.tb_call_log_detail(
        call_log_detail_id,
        call_log_id,
        contact_result_id,
        call_start_datetime,
        call_end_datetime,
        remark,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        v_call_log_detail_id,
        p_call_log_id,
        p_contact_result_id,
        p_call_start_datetime,
        p_call_end_datetime,
        p_remark,
        TRUE,
        NOW(),
        p_created_by
    );

    FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
    LOOP
        CALL public.contact_channel_insert(
            (v_channel->>'channel_type_id')::integer,
            p_menu_id,
            v_call_log_detail_id,
            p_created_by,
            v_contact_channel_id,
            v_msg,
            v_err,
            v_status
        );

        IF v_status != 200 THEN
            RAISE EXCEPTION 'Failed to insert contact channel: % (Status: %)', v_err, v_status;
        END IF;

        FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
        LOOP
            CALL public.contact_value_insert(
                v_contact_channel_id,
                v_value->>'user_name',
                v_value->>'contact_number',
                v_value->>'remark',
                (v_value->>'is_primary')::boolean,
                p_created_by,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact value: % (Status: %)', v_err, v_status;
            END IF;
        END LOOP;
    END LOOP;

    CALL call_log_detail_history_insert(
        v_call_log_detail_id,
        p_call_log_id,
        p_contact_result_id,
        p_call_start_datetime,
        p_call_end_datetime,
        p_remark,
        TRUE,
        p_menu_id,
        p_contact_data,
        p_created_by,
        v_msg,
        v_err,
        v_status
    );
  
	message := 'Call Log Detail and Contact inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert call log detail and contact.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.call_log_detail_insert(IN p_call_log_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            2           1255    21585 �   call_log_detail_update(text, text, integer, timestamp without time zone, timestamp without time zone, text, boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_detail_update(IN p_call_log_id text, IN p_call_log_detail_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    UPDATE public.tb_call_log_detail
    SET 
        contact_result_id = p_contact_result_id,
        call_start_datetime = p_call_start_datetime,
        call_end_datetime = p_call_end_datetime,
        remark = p_remark,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE 
        call_log_detail_id = p_call_log_detail_id;
    
    IF NOT FOUND THEN
        message := 'Call Log Detail with ID ' || p_call_log_detail_id || ' not found.';
        error := 'Record not found.';
        "statusCode" := 404;
        RETURN;
    END IF;

    DELETE FROM public.tb_contact_channel
    WHERE menu_trx_id = p_call_log_detail_id::text
      AND menu_id = p_menu_id;

    IF p_contact_data IS NOT NULL AND jsonb_typeof(p_contact_data) = 'array' THEN
        FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
        LOOP
            CALL public.contact_channel_insert(
                (v_channel->>'channel_type_id')::integer,
                p_menu_id,
                p_call_log_detail_id::text,
                p_updated_by,
                v_contact_channel_id,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact channel for call log detail ID %: % (Status: %)', p_call_log_detail_id, v_err, v_status;
            END IF;

            FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
            LOOP
                CALL public.contact_value_insert(
                    v_contact_channel_id,
                    v_value->>'user_name',
                    v_value->>'contact_number',
                    v_value->>'remark',
                    (v_value->>'is_primary')::boolean,
                    p_updated_by,
                    v_msg,
                    v_err,
                    v_status
                );
           
                IF v_status != 200 THEN
                    RAISE EXCEPTION 'Failed to insert contact value for call log detail ID % (channel ID %): % (Status: %)', p_call_log_detail_id, v_contact_channel_id, v_err, v_status;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    CALL call_log_detail_history_insert(
        p_call_log_detail_id,
        p_call_log_id,
        p_contact_result_id,
        p_call_start_datetime,
        p_call_end_datetime,
        p_remark,
        p_is_active,
        p_menu_id,
        p_contact_data,
        p_updated_by,
        v_msg,
        v_err,
        v_status
    );
  
	message := 'Call Log Detail and Contact updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update call log detail and contact.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.call_log_detail_update(IN p_call_log_id text, IN p_call_log_detail_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            5           1255    20972 y   call_log_history_insert(text, text, integer, integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_history_insert(IN p_call_log_id text, IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_call_log_history(
        history_date,
        call_log_id,
        lead_id,
        property_profile_id,
        status_id,
        purpose,
        fail_reason,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        NOW(),
        p_call_log_id,
        p_lead_id,
        p_property_profile_id,
        p_status_id,
        p_purpose,
        p_fail_reason,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Call Log History and Contact inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert call log history and contact.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 2  DROP PROCEDURE public.call_log_history_insert(IN p_call_log_id text, IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            9           1255    20974 �   call_log_insert(text, integer, integer, text, text, integer, timestamp without time zone, timestamp without time zone, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     ,  CREATE PROCEDURE public.call_log_insert(IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_call_log_id text;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    SELECT * INTO v_call_log_id FROM generate_id('CL');
    INSERT INTO public.tb_call_log(
        call_log_id,
        lead_id,
        property_profile_id,
        status_id,
        purpose,
        fail_reason,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        v_call_log_id,
        p_lead_id,
        p_property_profile_id,
        p_status_id,
        p_purpose,
        p_fail_reason,
        TRUE,
        NOW(),
        p_created_by
    );

    CALL call_log_history_insert(
        v_call_log_id,
        p_lead_id,
        p_property_profile_id,
        p_status_id,
        p_purpose,
        p_fail_reason,
        p_created_by,
        v_msg,
        v_err,
        v_status
    );
  
    CALL call_log_detail_insert(
        v_call_log_id,
        p_contact_result_id,
        p_call_start_datetime,
        p_call_end_datetime,
        p_remark,
        p_menu_id,
        p_contact_data,
        p_created_by,
        v_msg,
        v_err,
        v_status
    );

	message := 'Call Log and Contact inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert call log and contact.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.call_log_insert(IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            $           1255    20975 K   channel_type_delete(integer, character varying, character varying, integer) 	   PROCEDURE     y  CREATE PROCEDURE public.channel_type_delete(IN p_channel_type_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_channel_type
    WHERE
        channel_type_id = p_channel_type_id;

	IF NOT FOUND THEN
        message := 'Channel Type not found.';
        error := 'No channel_type exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Channel Type deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete channel type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.channel_type_delete(IN p_channel_type_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20976 W   channel_type_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.channel_type_insert(IN p_channel_type_name text, IN p_channel_type_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_channel_type(
        channel_type_name,
        channel_type_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_channel_type_name,
        p_channel_type_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Channel Type inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert channel type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.channel_type_insert(IN p_channel_type_name text, IN p_channel_type_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            M           1255    20977 O   channel_type_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.channel_type_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.channel_type_id) INTO v_total
    FROM tb_channel_type a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'channel_type_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.channel_type_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'channel_type_id' AND p_query_search IS NOT NULL
                THEN a.channel_type_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Channel Type retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.channel_type_id,
                        a.channel_type_name,
                        a.channel_type_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_channel_type a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'channel_type_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.channel_type_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'channel_type_id' AND p_query_search IS NOT NULL
                                THEN a.channel_type_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No channel type found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve channel type.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.channel_type_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            ^           1255    20978 i   channel_type_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.channel_type_update(IN p_channel_type_id integer, IN p_channel_type_name text, IN p_channel_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_channel_type
    SET
        channel_type_name = p_channel_type_name,
        channel_type_description = p_channel_type_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        channel_type_id = p_channel_type_id;

	IF NOT FOUND THEN
        message := 'Channel Type not found.';
        error := 'No channel_type exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Channel Type updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update channel type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.channel_type_update(IN p_channel_type_id integer, IN p_channel_type_name text, IN p_channel_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            %           1255    20979 W   contact_channel_delete(integer, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.contact_channel_delete(IN p_contact_channel_id integer, IN p_menu_trx_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_contact_channel
    WHERE
        customer_type_id = p_contact_channel_id
        AND menu_trx_id = p_menu_trx_id;

	IF NOT FOUND THEN
        message := 'Contact Channel not found.';
        error := 'No contact channel exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Contact Channel deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete contact channel.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.contact_channel_delete(IN p_contact_channel_id integer, IN p_menu_trx_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20980 k   contact_channel_history_insert(integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.contact_channel_history_insert(IN p_channel_type_id integer, IN p_channel_menu_id text, IN p_channel_menu_trx_id text, IN p_created_by integer, OUT p_contact_channel_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_contact_channel_history(
        history_date,
        channel_type_id,
        menu_id,
        menu_trx_id,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        NOW(),
        p_channel_type_id,
        p_channel_menu_id,
        p_channel_menu_trx_id,
        TRUE, 
        NOW(),
        p_created_by
    )
    RETURNING contact_channel_id INTO p_contact_channel_id;

    message := 'Contact Channel History inserted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to insert contact channel history.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 %  DROP PROCEDURE public.contact_channel_history_insert(IN p_channel_type_id integer, IN p_channel_menu_id text, IN p_channel_menu_trx_id text, IN p_created_by integer, OUT p_contact_channel_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            #           1255    20981 c   contact_channel_insert(integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE     8  CREATE PROCEDURE public.contact_channel_insert(IN p_channel_type_id integer, IN p_channel_menu_id text, IN p_channel_menu_trx_id text, IN p_created_by integer, OUT p_contact_channel_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_contact_channel(
        channel_type_id,
        menu_id,
        menu_trx_id,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_channel_type_id,
        p_channel_menu_id,
        p_channel_menu_trx_id,
        TRUE, 
        NOW(),
        p_created_by
    )
    RETURNING contact_channel_id INTO p_contact_channel_id;

    message := 'Contact Channel inserted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to insert contact channel.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
   DROP PROCEDURE public.contact_channel_insert(IN p_channel_type_id integer, IN p_channel_menu_id text, IN p_channel_menu_trx_id text, IN p_created_by integer, OUT p_contact_channel_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20982 x   contact_value_history_insert(integer, text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.contact_value_history_insert(IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_contact_value_history(
        history_date,
        contact_channel_id,
        user_name,
        contact_number,
        remark,
        is_primary,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        NOW(),
        p_contact_channel_id,
        p_user_name,
        p_contact_number,
        p_remark,
        p_is_primary,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Contact Value History inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert contact value history.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 $  DROP PROCEDURE public.contact_value_history_insert(IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20983 p   contact_value_insert(integer, text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     c  CREATE PROCEDURE public.contact_value_insert(IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_contact_value(
        contact_channel_id,
        user_name,
        contact_number,
        remark,
        is_primary,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_contact_channel_id,
        p_user_name,
        p_contact_number,
        p_remark,
        p_is_primary,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Contact Value inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert contact value.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.contact_value_insert(IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            )           1255    20984 �   contact_value_update(integer, integer, text, text, text, boolean, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     [  CREATE PROCEDURE public.contact_value_update(IN p_contact_value_id integer, IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_is_active boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_contact_value
    SET
        user_name = p_user_name,
        contact_number = p_contact_number,
        remark = p_remark,
        is_primary = p_is_primary,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        contact_value_id = p_contact_value_id 
        AND contact_channel_id = p_contact_channel_id;

	IF NOT FOUND THEN
        message := 'Contact Value not found.';
        error := 'No contact value exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Contact Value updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update contact value.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 S  DROP PROCEDURE public.contact_value_update(IN p_contact_value_id integer, IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_is_active boolean, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            `           1255    20985 L   customer_type_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.customer_type_delete(IN p_customer_type_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_customer_type
    WHERE
        customer_type_id = p_customer_type_id;

	IF NOT FOUND THEN
        message := 'Customer Type not found.';
        error := 'No customer type exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Customer Type deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete customer type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.customer_type_delete(IN p_customer_type_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            1           1255    20986 X   customer_type_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.customer_type_insert(IN p_customer_type_name text, IN p_customer_type_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_customer_type(
        customer_type_name,
        customer_type_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_customer_type_name,
        p_customer_type_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Customer Type inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert customer type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.customer_type_insert(IN p_customer_type_name text, IN p_customer_type_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20987 P   customer_type_pagination(integer, integer, character varying, character varying)    FUNCTION       CREATE FUNCTION public.customer_type_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.customer_type_id) INTO v_total
    FROM tb_customer_type a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'customer_type_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.customer_type_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'customer_type_id' AND p_query_search IS NOT NULL
                THEN a.customer_type_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Customer Type retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.customer_type_id,
                        a.customer_type_name,
                        a.customer_type_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_customer_type a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'customer_type_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.customer_type_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'customer_type_id' AND p_query_search IS NOT NULL
                                THEN a.customer_type_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No customer type found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve customer type.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.customer_type_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            G           1255    20988 j   customer_type_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.customer_type_update(IN p_customer_type_id integer, IN p_customer_type_name text, IN p_customer_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_customer_type
    SET
        customer_type_name = p_customer_type_name,
        customer_type_description = p_customer_type_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        customer_type_id = p_customer_type_id;

	IF NOT FOUND THEN
        message := 'Customer Type not found.';
        error := 'No customer type exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Customer Type updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update customer type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.customer_type_update(IN p_customer_type_id integer, IN p_customer_type_name text, IN p_customer_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            F           1255    20989 H   developer_delete(integer, character varying, character varying, integer) 	   PROCEDURE     ^  CREATE PROCEDURE public.developer_delete(IN p_developer_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_developer
    WHERE
        developer_id = p_developer_id;

	IF NOT FOUND THEN
        message := 'Developer not found.';
        error := 'No developer exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Developer deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete developer.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.developer_delete(IN p_developer_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            /           1255    20990 T   developer_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     x  CREATE PROCEDURE public.developer_insert(IN p_developer_name text, IN p_developer_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_developer(
		developer_name,
        developer_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
		p_developer_name,
        p_developer_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Developer inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert developer.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.developer_insert(IN p_developer_name text, IN p_developer_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    20991 L   developer_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.developer_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.developer_id) INTO v_total
    FROM tb_developer a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'developer_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.developer_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'developer_id' AND p_query_search IS NOT NULL
                THEN a.developer_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Developer retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.developer_id,
                        a.developer_name,
                        a.developer_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_developer a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'developer_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.developer_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'developer_id' AND p_query_search IS NOT NULL
                                THEN a.developer_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No developer found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve developer.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.developer_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false                       1255    20992 f   developer_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     y  CREATE PROCEDURE public.developer_update(IN p_developer_id integer, IN p_developer_name text, IN p_developer_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_developer
    SET
        developer_name = p_developer_name,
        developer_description = p_developer_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        developer_id = p_developer_id;

	IF NOT FOUND THEN
        message := 'Developer not found.';
        error := 'No developer exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Developer updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update developer.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.developer_update(IN p_developer_id integer, IN p_developer_name text, IN p_developer_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            \           1255    20993    generate_id(character varying)    FUNCTION     ~  CREATE FUNCTION public.generate_id(prefix character varying) RETURNS TABLE(id character varying)
    LANGUAGE plpgsql
    AS $$


DECLARE
    total_count int;
    total_plus varchar;
    txt_code varchar;
    temp_var int := 0;
BEGIN

    IF prefix ='LD' THEN
        SELECT COUNT(*) + 1 INTO total_count FROM tb_lead;
    ELSEIF prefix ='CL' THEN
        SELECT COUNT(*) + 1 INTO total_count FROM tb_call_log;
    ELSEIF prefix ='CD' THEN
        SELECT COUNT(*) + 1 INTO total_count FROM tb_call_log_detail;
    ELSEIF prefix ='ST' THEN 
        SELECT COUNT(*) + 1 INTO total_count FROM tb_site_visit;
    END IF; 
    LOOP 
        -- Pad total_count to ensure it is 6 digits
        total_plus := total_count::varchar;
        WHILE LENGTH(total_plus) < 6 LOOP
            total_plus := '0' || total_plus;
        END LOOP;

        -- Generate the unique transaction ID
        txt_code := prefix||'-' ||  total_plus;
        IF prefix ='LD' THEN
            IF EXISTS (SELECT 1 FROM tb_lead WHERE lead_id = txt_code) THEN
                total_count := total_count + 1;
            ELSE
                temp_var := 1;
            END IF;
            EXIT WHEN temp_var = 1;
        END IF;
        IF prefix ='CL' THEN
            IF EXISTS (SELECT 1 FROM tb_call_log WHERE call_log_id = txt_code) THEN
                total_count := total_count + 1;
            ELSE
                temp_var := 1;
            END IF;
            EXIT WHEN temp_var = 1;
        END IF;
		IF prefix ='CD' THEN
            IF EXISTS (SELECT 1 FROM tb_call_log_detail WHERE call_log_detail_id = txt_code) THEN
                total_count := total_count + 1;
            ELSE
                temp_var := 1;
            END IF;
            EXIT WHEN temp_var = 1;
        END IF;
        IF prefix ='ST' THEN
            IF EXISTS (SELECT 1 FROM tb_site_visit WHERE site_visit_id = txt_code) THEN
                total_count := total_count + 1;
            ELSE
                temp_var := 1;
            END IF;
            EXIT WHEN temp_var = 1;
        END IF;
    END LOOP;

    RETURN QUERY SELECT txt_code;
END;
$$;
 <   DROP FUNCTION public.generate_id(prefix character varying);
       public          postgres    false            a           1255    21660    get_business()    FUNCTION       CREATE FUNCTION public.get_business() RETURNS TABLE(business_id integer, business_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.business_id,
        p.business_name
    FROM
        public.tb_business p
	ORDER BY business_name ASC;
END;
$$;
 %   DROP FUNCTION public.get_business();
       public          postgres    false            8           1255    21673    get_channel_type()    FUNCTION     5  CREATE FUNCTION public.get_channel_type() RETURNS TABLE(channel_type_id integer, channel_type_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.channel_type_id,
        p.channel_type_name
    FROM
        public.tb_channel_type p
	ORDER BY channel_type_name ASC;
END;
$$;
 )   DROP FUNCTION public.get_channel_type();
       public          postgres    false            -           1255    20994 #   get_commune_by_district_id(integer)    FUNCTION     o  CREATE FUNCTION public.get_commune_by_district_id(p_district_id integer) RETURNS TABLE(commune_id integer, district_id integer, commune_name text, is_active boolean, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.commune_id,
        c.district_id,
        c.commune_name,
        c.is_active,
        c.created_date,
        c.created_by,
        c.last_update,
        c.updated_by
    FROM
        public.tb_commune c
    WHERE
        c.district_id = p_district_id;
END;
$$;
 H   DROP FUNCTION public.get_commune_by_district_id(p_district_id integer);
       public          postgres    false            >           1255    21662    get_customer_type()    FUNCTION     <  CREATE FUNCTION public.get_customer_type() RETURNS TABLE(customer_type_id integer, customer_type_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.customer_type_id,
        p.customer_type_name
    FROM
        public.tb_customer_type p
	ORDER BY customer_type_name ASC;
END;
$$;
 *   DROP FUNCTION public.get_customer_type();
       public          postgres    false            C           1255    20995 $   get_district_by_province_id(integer)    FUNCTION     u  CREATE FUNCTION public.get_district_by_province_id(p_province_id integer) RETURNS TABLE(district_id integer, province_id integer, district_name text, is_active boolean, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.district_id,
        d.province_id,
        d.district_name,
        d.is_active,
        d.created_date,
        d.created_by,
        d.last_update,
        d.updated_by
    FROM
        public.tb_district d
    WHERE
        d.province_id = p_province_id;
END;
$$;
 I   DROP FUNCTION public.get_district_by_province_id(p_province_id integer);
       public          postgres    false            *           1255    21659    get_gender()    FUNCTION     �   CREATE FUNCTION public.get_gender() RETURNS TABLE(gender_id integer, gender_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.gender_id,
        p.gender_name
    FROM
        public.tb_gender p;
END;
$$;
 #   DROP FUNCTION public.get_gender();
       public          postgres    false            R           1255    21661    get_lead_source()    FUNCTION       CREATE FUNCTION public.get_lead_source() RETURNS TABLE(lead_source_id integer, lead_source_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.lead_source_id,
        p.lead_source_name
    FROM
        public.tb_lead_source p;
END;
$$;
 (   DROP FUNCTION public.get_lead_source();
       public          postgres    false            B           1255    20996    get_province()    FUNCTION     �  CREATE FUNCTION public.get_province() RETURNS TABLE(province_id integer, province_name text, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.province_id,
        p.province_name,
        p.created_date,
        p.created_by,
        p.last_update,
        p.updated_by
    FROM
        public.tb_province p;
END;
$$;
 %   DROP FUNCTION public.get_province();
       public          postgres    false            +           1255    20997 
   get_role()    FUNCTION       CREATE FUNCTION public.get_role() RETURNS TABLE(role_id text, role_name text, description text, is_active boolean, created_date timestamp without time zone, created_by integer, last_update timestamp without time zone, updated_by integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.role_id,
        r.role_name,
        r.description,
        r.is_active,
        r.created_date,
        r.created_by,
        r.last_update,
        r.updated_by
    FROM
        public.tb_role AS r;
END;
$$;
 !   DROP FUNCTION public.get_role();
       public          postgres    false                       1255    20998    get_user_role()    FUNCTION     l  CREATE FUNCTION public.get_user_role() RETURNS TABLE(role_id text, staff_id text, description text, is_active boolean, created_date timestamp without time zone, created_by integer, last_update timestamp without time zone, updated_by integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.tb_user_role;
END;
$$;
 &   DROP FUNCTION public.get_user_role();
       public          postgres    false            Q           1255    20999    get_user_role_by_id(text)    FUNCTION     �   CREATE FUNCTION public.get_user_role_by_id(p_staff_id text) RETURNS TABLE(role_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.role_id
    FROM
        public.tb_user_role r
	WHERE 
		r.staff_id = p_staff_id;
END;
$$;
 ;   DROP FUNCTION public.get_user_role_by_id(p_staff_id text);
       public          postgres    false                       1255    21000 $   get_user_role_permission_by_id(text)    FUNCTION     p  CREATE FUNCTION public.get_user_role_permission_by_id(p_role_id text) RETURNS TABLE(role_id text, menu_id text, permission_id text, is_active boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.role_id,
		r.menu_id,
		r.permission_id,
		r.is_active
    FROM
        public.tb_role_permission r
	WHERE 
		r.role_id = p_role_id;
END;
$$;
 E   DROP FUNCTION public.get_user_role_permission_by_id(p_role_id text);
       public          postgres    false                       1255    21001 "   get_village_by_commune_id(integer)    FUNCTION     i  CREATE FUNCTION public.get_village_by_commune_id(p_commune_id integer) RETURNS TABLE(village_id integer, commune_id integer, village_name text, is_active boolean, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.village_id,
        v.commune_id,
        v.village_name,
        v.is_active,
        v.created_date,
        v.created_by,
        v.last_update,
        v.updated_by
    FROM
        public.tb_village v
    WHERE
        v.commune_id = p_commune_id;
END;
$$;
 F   DROP FUNCTION public.get_village_by_commune_id(p_commune_id integer);
       public          postgres    false            b           1255    21002 @   lead_delete(text, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_delete(IN p_lead_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    DELETE FROM public.tb_contact_channel
    WHERE menu_trx_id = p_lead_id;

    DELETE FROM public.tb_lead
    WHERE lead_id = p_lead_id;

    IF NOT FOUND THEN
        message := 'Lead with ID ' || p_lead_id || ' not found.';
        error := 'Record not found.';
        "statusCode" := 404;
        RETURN;
    END IF;

    message := 'Lead and associated contacts deleted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to delete lead and associated contacts.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 �   DROP PROCEDURE public.lead_delete(IN p_lead_id text, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            &           1255    21003 �   lead_history_insert(text, integer, integer, integer, integer, integer, integer, integer, text, text, date, text, text, text, text, text, date, text, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_history_insert(IN p_lead_id text, IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$

DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    INSERT INTO public.tb_lead_history (
        history_date,
        lead_id,
        gender_id,
        customer_type_id,
        lead_source_id,
        village_id,
        business_id,
        initial_staff_id,
        current_staff_id,
        first_name,
        last_name,
        date_of_birth,
        email,
        occupation,
        home_address,
        street_address,
        biz_description,
        relationship_date,
        remark,
        photo_url,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        NOW(),
        p_lead_id,
        p_gender_id,
        p_customer_type_id,
        p_lead_source_id,
        p_village_id,
        p_business_id,
        p_initial_staff_id,
        p_current_staff_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_email,
        p_occupation,
        p_home_address,
        p_street_address,
        p_biz_description,
        p_relationship_date,
        p_remark,
        p_photo_url,
        TRUE,
        NOW(),
        p_created_by
    );

    FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
    LOOP
        CALL public.contact_channel_history_insert(
            (v_channel->>'channel_type_id')::integer,
            p_menu_id,
            p_lead_id,
            p_created_by,
            v_contact_channel_id,
            v_msg,
            v_err,
            v_status
        );

        IF v_status != 200 THEN
            RAISE EXCEPTION 'Failed to insert contact channel: % (Status: %)', v_err, v_status;
        END IF;

        FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
        LOOP
            CALL public.contact_value_history_insert(
                v_contact_channel_id,
                v_value->>'user_name',
                v_value->>'contact_number',
                v_value->>'remark',
                (v_value->>'is_primary')::boolean,
                p_created_by,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact value: % (Status: %)', v_err, v_status;
            END IF;
        END LOOP;
    END LOOP;

    message := 'Lead and contacts history inserted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to insert lead and contacts history.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 �  DROP PROCEDURE public.lead_history_insert(IN p_lead_id text, IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            f           1255    21004 �   lead_insert(integer, integer, integer, integer, integer, integer, integer, text, text, date, text, text, text, text, text, date, text, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     Z  CREATE PROCEDURE public.lead_insert(IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$

DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_lead_id text;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    SELECT * INTO v_lead_id FROM generate_id('LD');
    INSERT INTO public.tb_lead (
        lead_id,
        gender_id,
        customer_type_id,
        lead_source_id,
        village_id,
        business_id,
        initial_staff_id,
        current_staff_id,
        first_name,
        last_name,
        date_of_birth,
        email,
        occupation,
        home_address,
        street_address,
        biz_description,
        relationship_date,
        remark,
        photo_url,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        v_lead_id,
        p_gender_id,
        p_customer_type_id,
        p_lead_source_id,
        p_village_id,
        p_business_id,
        p_initial_staff_id,
        p_current_staff_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_email,
        p_occupation,
        p_home_address,
        p_street_address,
        p_biz_description,
        p_relationship_date,
        p_remark,
        p_photo_url,
        TRUE,
        NOW(),
        p_created_by
    );

    FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
    LOOP
        CALL public.contact_channel_insert(
            (v_channel->>'channel_type_id')::integer,
            p_menu_id,
            v_lead_id,
            p_created_by,
            v_contact_channel_id,
            v_msg,
            v_err,
            v_status
        );

        IF v_status != 200 THEN
            RAISE EXCEPTION 'Failed to insert contact channel: % (Status: %)', v_err, v_status;
        END IF;

        FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
        LOOP
            CALL public.contact_value_insert(
                v_contact_channel_id,
                v_value->>'user_name',
                v_value->>'contact_number',
                v_value->>'remark',
                (v_value->>'is_primary')::boolean,
                p_created_by,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact value: % (Status: %)', v_err, v_status;
            END IF;
        END LOOP;
    END LOOP;

    CALL public.lead_history_insert(
        v_lead_id,
        p_gender_id,
        p_customer_type_id,
        p_lead_source_id,
        p_village_id,
        p_business_id,
        p_initial_staff_id,
        p_current_staff_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_email,
        p_occupation,
        p_home_address,
        p_street_address,
        p_biz_description,
        p_relationship_date,
        p_remark,
        p_photo_url,
        p_menu_id,
        p_contact_data,
        p_created_by,
        v_msg,
        v_err,
        v_status
    );

    message := 'Lead and contacts inserted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to insert lead and contacts.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 �  DROP PROCEDURE public.lead_insert(IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    21006 P   lead_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.lead_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
    v_user_role text; 
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.lead_id) INTO v_total
    FROM tb_lead a
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_name' AND p_query_search IS NOT NULL
                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_id' AND p_query_search IS NOT NULL
                THEN a.lead_id = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Leads retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.lead_id,
                        a.gender_id,
                        g.gender_name,
                        a.customer_type_id,
                        ct.customer_type_name,
                        a.lead_source_id,
                        ls.lead_source_name,
                        a.village_id,
                        v.village_name,
                        a.business_id,
                        b.business_name,
                        a.initial_staff_id,
                        CONCAT(s1.first_name, ' ', s1.last_name) AS initial_staff_name,
                        a.current_staff_id,
                        CONCAT(s2.first_name, ' ', s2.last_name) AS current_staff_name,
                        a.first_name,
                        a.last_name,
                        a.date_of_birth,
                        a.email,
                        a.occupation,
                        a.home_address,
                        a.street_address,
                        a.biz_description,
                        a.relationship_date,
                        a.remark,
                        a.photo_url,
                        a.is_active,
                        a.created_date::TEXT,
                        CONCAT(uc.first_name, ' ', uc.last_name) AS created_by_name,
                        a.last_update::TEXT,
                        CONCAT(uu.first_name, ' ', uu.last_name) AS updated_by_name,           
                        (
                            SELECT json_agg(
                                json_build_object(
                                    'channel_type_id', cc.channel_type_id,
                                    'menu_id', cc.menu_id,
                                    'contact_values', (
                                        SELECT json_agg(
                                            json_build_object(
                                                'user_name', cv.user_name,
                                                'contact_number', cv.contact_number,
                                                'remark', cv.remark,
                                                'is_primary', cv.is_primary
                                            )
                                        )
                                        FROM public.tb_contact_value cv
                                        WHERE cv.contact_channel_id = cc.contact_channel_id
                                    )
                                )
                            )
                            FROM public.tb_contact_channel cc
                            WHERE cc.menu_trx_id = a.lead_id::text
                            AND cc.menu_id = 'MU_04'
                        )::JSON AS contact_data
                    FROM tb_lead a
                    LEFT JOIN tb_gender g ON a.gender_id = g.gender_id
                    LEFT JOIN tb_customer_type ct ON a.customer_type_id = ct.customer_type_id
                    LEFT JOIN tb_lead_source ls ON a.lead_source_id = ls.lead_source_id
                    LEFT JOIN tb_village v ON a.village_id = v.village_id
                    LEFT JOIN tb_business b ON a.business_id = b.business_id
                    LEFT JOIN tb_staff s1 ON a.initial_staff_id = s1.staff_id
                    LEFT JOIN tb_staff s2 ON a.current_staff_id = s2.staff_id
                    LEFT JOIN tb_staff uc ON uc.staff_id = a.created_by
                    LEFT JOIN tb_staff uu ON uu.staff_id = a.updated_by
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_name' AND p_query_search IS NOT NULL
                                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_id' AND p_query_search IS NOT NULL
                                THEN a.lead_id = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE                  
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id
                        END
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No leads found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve leads.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 �   DROP FUNCTION public.lead_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          postgres    false            K           1255    21008 J   lead_source_delete(integer, character varying, character varying, integer) 	   PROCEDURE     p  CREATE PROCEDURE public.lead_source_delete(IN p_lead_source_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_lead_source
    WHERE
        lead_source_id = p_lead_source_id;

	IF NOT FOUND THEN
        message := 'Lead Source not found.';
        error := 'No lead source exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Lead Source deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete lead source.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.lead_source_delete(IN p_lead_source_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            '           1255    21009 V   lead_source_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_source_insert(IN p_lead_source_name text, IN p_lead_source_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_lead_source(
        lead_source_name,
        lead_source_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_lead_source_name,
        p_lead_source_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Lead Source inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert lead source.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.lead_source_insert(IN p_lead_source_name text, IN p_lead_source_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            7           1255    21010 N   lead_source_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.lead_source_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.lead_source_id) INTO v_total
    FROM tb_lead_source a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_source_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.lead_source_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_source_id' AND p_query_search IS NOT NULL
                THEN a.lead_source_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Lead Source retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.lead_source_id,
                        a.lead_source_name,
                        a.lead_source_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_lead_source a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_source_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.lead_source_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_source_id' AND p_query_search IS NOT NULL
                                THEN a.lead_source_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No lead source found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve lead source.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.lead_source_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            ?           1255    21011 h   lead_source_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_source_update(IN p_lead_source_id integer, IN p_lead_source_name text, IN p_lead_source_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_lead_source
    SET
        lead_source_name = p_lead_source_name,
        lead_source_description = p_lead_source_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        lead_source_id = p_lead_source_id;

	IF NOT FOUND THEN
        message := 'Lead Source not found.';
        error := 'No lead source exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Lead Source updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update lead source.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.lead_source_update(IN p_lead_source_id integer, IN p_lead_source_name text, IN p_lead_source_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            S           1255    21012 �   lead_update(text, integer, integer, integer, integer, integer, integer, integer, text, text, date, text, text, text, text, text, date, text, text, boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_update(IN p_lead_id text, IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    UPDATE public.tb_lead
    SET
        gender_id = p_gender_id,
        customer_type_id = p_customer_type_id,
        lead_source_id = p_lead_source_id,
        village_id = p_village_id,
        business_id = p_business_id,
        initial_staff_id = p_initial_staff_id,
        current_staff_id = p_current_staff_id,
        first_name = p_first_name,
        last_name = p_last_name,
        date_of_birth = p_date_of_birth,
        email = p_email,
        occupation = p_occupation,
        home_address = p_home_address,
        street_address = p_street_address,
        biz_description = p_biz_description,
        relationship_date = p_relationship_date,
        remark = p_remark,
        photo_url = p_photo_url,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE lead_id = p_lead_id;

    IF NOT FOUND THEN
        message := 'Lead with ID ' || p_lead_id || ' not found.';
        error := 'Record not found.';
        "statusCode" := 404;
        RETURN;
    END IF;

    DELETE FROM public.tb_contact_channel
    WHERE menu_trx_id = p_lead_id::text
      AND menu_id = p_menu_id;

    IF p_contact_data IS NOT NULL AND jsonb_typeof(p_contact_data) = 'array' THEN
        FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
        LOOP
            CALL public.contact_channel_insert(
                (v_channel->>'channel_type_id')::integer,
                p_menu_id,
                p_lead_id::text,
                p_updated_by,
                v_contact_channel_id,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact channel for lead ID %: % (Status: %)', p_lead_id, v_err, v_status;
            END IF;

            FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
            LOOP
                CALL public.contact_value_insert(
                    v_contact_channel_id,
                    v_value->>'user_name',
                    v_value->>'contact_number',
                    v_value->>'remark',
                    (v_value->>'is_primary')::boolean,
                    p_updated_by,
                    v_msg,
                    v_err,
                    v_status
                );
           
                IF v_status != 200 THEN
                    RAISE EXCEPTION 'Failed to insert contact value for lead ID % (channel ID %): % (Status: %)', p_lead_id, v_contact_channel_id, v_err, v_status;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    CALL public.lead_history_insert(
        p_lead_id,
        p_gender_id,
        p_customer_type_id,
        p_lead_source_id,
        p_village_id,
        p_business_id,
        p_initial_staff_id,
        p_current_staff_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_email,
        p_occupation,
        p_home_address,
        p_street_address,
        p_biz_description,
        p_relationship_date,
        p_remark,
        p_photo_url,
        p_menu_id,
        p_contact_data,
        p_updated_by,
        v_msg,
        v_err,
        v_status
    );

    message := 'Lead and contacts updated successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to update lead and contacts.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 �  DROP PROCEDURE public.lead_update(IN p_lead_id text, IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            =           1255    21014 F   project_delete(integer, character varying, character varying, integer) 	   PROCEDURE     L  CREATE PROCEDURE public.project_delete(IN p_project_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_project
    WHERE
        project_id = p_project_id;

	IF NOT FOUND THEN
        message := 'Project not found.';
        error := 'No project exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Project deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete project.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.project_delete(IN p_project_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    21015 d   project_insert(integer, integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.project_insert(IN p_developer_id integer, IN p_village_id integer, IN p_project_name text, IN p_project_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_project(
        developer_id,
        village_id,
        project_name,
        project_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
		p_developer_id,
        p_village_id,
        p_project_name,
        p_project_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Project inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert project.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.project_insert(IN p_developer_id integer, IN p_village_id integer, IN p_project_name text, IN p_project_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            ;           1255    21016 L   project_owner_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.project_owner_delete(IN p_project_owner_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_project_owner
    WHERE
        project_owner_id = p_project_owner_id;

	IF NOT FOUND THEN
        message := 'Project Owner not found.';
        error := 'No project owner exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Project Owner deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete project owner.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.project_owner_delete(IN p_project_owner_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    21017 v   project_owner_insert(integer, integer, text, text, date, text, integer, character varying, character varying, integer) 	   PROCEDURE     {  CREATE PROCEDURE public.project_owner_insert(IN p_gender_id integer, IN p_village_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_project_owner(
		gender_id,
        village_id,
        first_name,
        last_name,
        date_of_birth,
        remark,
        is_active,
        created_date,
        created_by
    )
    VALUES (
		p_gender_id,
        p_village_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_remark,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Project Owner inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert project owner.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 (  DROP PROCEDURE public.project_owner_insert(IN p_gender_id integer, IN p_village_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_remark text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            H           1255    21018 P   project_owner_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.project_owner_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.project_owner_id) INTO v_total
    FROM tb_project_owner a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_owner_name' AND p_query_search IS NOT NULL
                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_owner_id' AND p_query_search IS NOT NULL
                THEN a.project_owner_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Project Owner retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.project_owner_id,
                        a.first_name,
                        a.last_name,  
                        d.gender_name,
                        a.date_of_birth,
                        a.village_id,
                        a.remark,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_project_owner a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    JOIN tb_gender d ON a.gender_id = d.gender_id
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_owner_name' AND p_query_search IS NOT NULL
                                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_owner_id' AND p_query_search IS NOT NULL
                                THEN a.project_owner_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No project owner found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve project owner.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.project_owner_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            A           1255    21019 �   project_owner_update(integer, integer, integer, text, text, date, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     s  CREATE PROCEDURE public.project_owner_update(IN p_project_owner_id integer, IN p_gender_id integer, IN p_village_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_project_owner
    SET
        gender_id = p_gender_id,
        village_id = p_village_id,
        first_name = p_first_name,
        last_name = p_last_name,
        date_of_birth = p_date_of_birth,
        remark = p_remark,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        project_owner_id = p_project_owner_id;

	IF NOT FOUND THEN
        message := 'Project owner not found.';
        error := 'No project owner exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Project Owner updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update project owner.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 _  DROP PROCEDURE public.project_owner_update(IN p_project_owner_id integer, IN p_gender_id integer, IN p_village_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            4           1255    21020 J   project_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.project_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.project_id) INTO v_total
    FROM tb_project a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.project_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_id' AND p_query_search IS NOT NULL
                THEN a.project_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Project retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.project_id,
                        a.developer_id,
                        e.developer_name,
                        a.village_id,
                        d.village_name,  
                        a.project_name,
                        a.project_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_project a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    JOIN tb_village d ON a.village_id = d.village_id
                    JOIN tb_developer e ON a.developer_id = e.developer_id
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.project_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'project_id' AND p_query_search IS NOT NULL
                                THEN a.project_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No project found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve project.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.project_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            X           1255    21021 v   project_update(integer, integer, integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.project_update(IN p_project_id integer, IN p_developer_id integer, IN p_village_id integer, IN p_project_name text, IN p_project_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_project
    SET
        developer_id = p_developer_id,
        village_id = p_village_id,
        project_name = p_project_name,
        project_description = p_project_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        project_id = p_project_id;

	IF NOT FOUND THEN
        message := 'Project not found.';
        error := 'No project exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Project Owner updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update project.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 7  DROP PROCEDURE public.project_update(IN p_project_id integer, IN p_developer_id integer, IN p_village_id integer, IN p_project_name text, IN p_project_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            D           1255    21022 O   property_profile_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_profile_delete(IN p_property_profile_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_property_profile
    WHERE
        property_profile_id = p_property_profile_id;

	IF NOT FOUND THEN
        message := 'Property Profile not found.';
        error := 'No property profile exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Property Profile deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete property profile.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.property_profile_delete(IN p_property_profile_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                        1255    21023 �   property_profile_insert(integer, integer, integer, integer, text, text, text, text, numeric, numeric, text, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.property_profile_insert(IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_property_profile(
        property_type_id,
        project_id,
        project_owner_id,
        village_id,
        property_profile_name,
        home_number,
        room_number,
        address,
        width,
        length,
        remark,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_property_type_id,
        p_project_id,
        p_project_owner_id,
        p_village_id,
        p_property_profile_name,
        p_home_number,
        p_room_number,
        p_address,
        p_width​​ ,
        p_length,
        p_remark,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Property Profile inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert property profile.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.property_profile_insert(IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_remark text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            _           1255    21024 S   property_profile_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.property_profile_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.property_profile_id) INTO v_total
    FROM tb_property_profile a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_profile_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.property_profile_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_profile_id' AND p_query_search IS NOT NULL
                THEN a.property_profile_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Property Profile retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.property_profile_id,
                        a.property_type_id,
                        d.property_type_name,
                        a.project_id,
                        e.project_name,
                        a.project_owner_id,
                        CONCAT(g.first_name, ' ', g.last_name) project_owner_name,
                        a.village_id,
                        i.village_name,
                        a.property_profile_id,
                        a.property_profile_name,
                        a.home_number,
                        a.room_number,
                        a.address,
                        a.width,
                        a.length,
                        a.remark,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_property_profile a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    JOIN tb_property_type d ON a.property_type_id = d.property_type_id
                    JOIN tb_project e ON a.project_id = e.project_id
                    JOIN tb_project_owner g ON a.project_owner_id = g.project_owner_id
                    JOIN tb_village i ON a.village_id = i.village_id
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_profile_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.property_profile_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_profile_id' AND p_query_search IS NOT NULL
                                THEN a.property_profile_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No property profile found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve property profile.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.property_profile_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            E           1255    21025 �   property_profile_update(integer, integer, integer, integer, integer, text, text, text, text, numeric, numeric, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_profile_update(IN p_property_profile_id integer, IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_property_profile
    SET
        property_type_id = p_property_type_id,
        project_id = p_project_id,
        project_owner_id = p_project_owner_id,
        village_id = p_village_id,
        property_profile_name = p_property_profile_name,
        home_number = p_home_number,
        room_number = p_room_number,
        address = p_address,
        width = p_width​​,
        length = p_length,
        remark = p_remark,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        property_profile_id = p_property_profile_id;

	IF NOT FOUND THEN
        message := 'Property Profile not found.';
        error := 'No property profile exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Property Profile updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update property profile.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.property_profile_update(IN p_property_profile_id integer, IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            e           1255    21026 L   property_type_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_type_delete(IN p_property_type_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_property_type
    WHERE
        property_type_id = p_property_type_id;

	IF NOT FOUND THEN
        message := 'Property Type not found.';
        error := 'No property type exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Property Type deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete property type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.property_type_delete(IN p_property_type_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    21027 X   property_type_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_type_insert(IN p_property_type_name text, IN p_property_type_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_property_type(
        property_type_name,
        property_type_description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_property_type_name,
        p_property_type_description,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Property Type inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert property type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.property_type_insert(IN p_property_type_name text, IN p_property_type_description text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            U           1255    21028 P   property_type_pagination(integer, integer, character varying, character varying)    FUNCTION       CREATE FUNCTION public.property_type_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(a.property_type_id) INTO v_total
    FROM tb_property_type a
    JOIN tb_staff b ON b.staff_id = a.created_by
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_type_name' AND p_query_search IS NOT NULL
                THEN LOWER(a.property_type_name) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_type_id' AND p_query_search IS NOT NULL
                THEN a.property_type_id::TEXT = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Property Type retrieved successfully.'::character varying,
            NULL::character varying,
            200::INTEGER,
            v_total::INTEGER,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.property_type_id,
                        a.property_type_name,
                        a.property_type_description,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_property_type a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_type_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.property_type_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_type_id' AND p_query_search IS NOT NULL
                                THEN a.property_type_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        RETURN QUERY
        SELECT
            'No property type found.'::character varying,
            NULL::character varying,
            404::INTEGER,
            0::INTEGER,
            '[]'::JSON;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve property type.'::character varying,
            SQLERRM::character varying,
            500::INTEGER,
            0::INTEGER,
            '[]'::JSON;
END;
$$;
 �   DROP FUNCTION public.property_type_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying);
       public          postgres    false            "           1255    21029 j   property_type_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_type_update(IN p_property_type_id integer, IN p_property_type_name text, IN p_property_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_property_type
    SET
        property_type_name = p_property_type_name,
        property_type_description = p_property_type_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        property_type_id = p_property_type_id;

	IF NOT FOUND THEN
        message := 'Property Type not found.';
        error := 'No property type exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Property Type updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update property type.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
   DROP PROCEDURE public.property_type_update(IN p_property_type_id integer, IN p_property_type_name text, IN p_property_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            W           1255    21030 O   role_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     O  CREATE PROCEDURE public.role_insert(IN p_role_id text, IN p_role_name text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_role (
		role_id,
        role_name,
        description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
		p_role_id,
        p_role_name,
        NULL,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Role inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert role.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.role_insert(IN p_role_id text, IN p_role_name text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            P           1255    21031 ^   role_update(text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.role_update(IN p_role_id text, IN p_role_name text, IN p_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_role
    SET
        role_name = p_role_name,
        description = p_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        role_id = p_role_id;

	IF NOT FOUND THEN
        message := 'Role not found.';
        error := 'No role exists with the provided ID to update.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Role updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update role.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.role_update(IN p_role_id text, IN p_role_name text, IN p_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    21032 F   site_visit_delete(text, character varying, character varying, integer) 	   PROCEDURE     e  CREATE PROCEDURE public.site_visit_delete(IN p_site_visit_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_site_visit
    WHERE
         site_visit_id = p_site_visit_id;

	IF NOT FOUND THEN
        message := 'Site Visit not found.';
        error := 'No site visit exists with the provided ID to delete.';
        "statusCode" := 404;
        RETURN;
    END IF;

	message := 'Site Visit deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete site visit.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.site_visit_delete(IN p_site_visit_id text, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            V           1255    21033 �   site_visit_history_insert(text, text, integer, integer, text, integer, text, timestamp without time zone, timestamp without time zone, text[], text, integer, character varying, character varying, integer) 	   PROCEDURE     c  CREATE PROCEDURE public.site_visit_history_insert(IN p_site_visit_id text, IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_site_visit_history(
        history_date,
        site_visit_id,
        call_id,
        property_profile_id,
        staff_id,
        lead_id,
        contact_result_id,
        purpose,
        start_datetime,
        end_datetime,
        photo_url,
        remark,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        NOW(),
        p_site_visit_id,
        p_call_id,
        p_property_profile_id,
        p_staff_id,
        p_lead_id,
        p_contact_result_id,
        p_purpose,
        p_start_datetime,
        p_end_datetime,
        p_photo_url,
        p_remark,
        TRUE,
        NOW(),
        p_created_by
    );
  
	message := 'Site Visit History inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert site visit history.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.site_visit_history_insert(IN p_site_visit_id text, IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            N           1255    21034 �   site_visit_insert(text, integer, integer, text, integer, text, timestamp without time zone, timestamp without time zone, text[], text, integer, character varying, character varying, integer) 	   PROCEDURE     3  CREATE PROCEDURE public.site_visit_insert(IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_site_visit_id text;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    SELECT * INTO v_site_visit_id FROM generate_id('ST');
    INSERT INTO public.tb_site_visit(
        site_visit_id,
        call_id,
        property_profile_id,
        staff_id,
        lead_id,
        contact_result_id,
        purpose,
        start_datetime,
        end_datetime,
        photo_url,
        remark,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        v_site_visit_id,
        p_call_id,
        p_property_profile_id,
        p_staff_id,
        p_lead_id,
        p_contact_result_id,
        p_purpose,
        p_start_datetime,
        p_end_datetime,
        p_photo_url,
        p_remark,
        TRUE,
        NOW(),
        p_created_by
    );

    CALL site_visit_history_insert(
        v_site_visit_id,
        p_call_id,
        p_property_profile_id,
        p_staff_id,
        p_lead_id,
        p_contact_result_id,
        p_purpose,
        p_start_datetime,
        p_end_datetime,
        p_photo_url,
        p_remark,
        p_created_by,
        v_msg,
        v_err,
        v_status
    );
  
	message := 'Site Visit inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to insert site visit.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.site_visit_insert(IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            Z           1255    21035 V   site_visit_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.site_visit_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
    v_user_role text;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id = p_user_id::text;

    SELECT COUNT(sv.site_visit_id) INTO v_total
    FROM public.tb_site_visit sv
    LEFT JOIN public.tb_staff s_staff ON sv.staff_id = s_staff.staff_id
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'site_visit_id' AND p_query_search IS NOT NULL
                THEN sv.site_visit_id = p_query_search
            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_name' AND p_query_search IS NOT NULL
                THEN LOWER(CONCAT(s_staff.first_name, ' ', s_staff.last_name)) LIKE LOWER('%' || p_query_search || '%')
            ELSE TRUE
        END
        AND sv.is_active = TRUE
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE
            ELSE sv.created_by = p_user_id
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Site Visits retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        sv.site_visit_id,
                        sv.call_id,                     
                        sv.property_profile_id,
                        pp.property_profile_name,
                        sv.staff_id,
                        CONCAT(s_staff.first_name, ' ', s_staff.last_name) AS staff_name,
                        sv.lead_id,
                        CONCAT(l.first_name, ' ', l.last_name) AS lead_name, 
                        sv.contact_result_id,
                        cr.contact_result_name, 
                        sv.purpose,
                        sv.start_datetime::TEXT, 
                        sv.end_datetime::TEXT,
                        sv.photo_url,
                        sv.remark,
                        sv.is_active,
                        sv.created_date::TEXT,
                        CONCAT(uc.first_name, ' ', uc.last_name) AS created_by_name,
                        sv.last_update::TEXT, 
                        CONCAT(uu.first_name, ' ', uu.last_name) AS updated_by_name
                    FROM public.tb_site_visit sv                  
                    LEFT JOIN public.tb_property_profile pp ON sv.property_profile_id = pp.property_profile_id
                    LEFT JOIN public.tb_staff s_staff ON sv.staff_id = s_staff.staff_id
                    LEFT JOIN public.tb_lead l ON sv.lead_id = l.lead_id
                    LEFT JOIN public.tb_contact_result cr ON sv.contact_result_id = cr.contact_result_id 
                    LEFT JOIN tb_staff uc ON uc.staff_id = sv.created_by
                    LEFT JOIN tb_staff uu ON uu.staff_id = sv.updated_by
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'site_visit_id' AND p_query_search IS NOT NULL
                                THEN sv.site_visit_id = p_query_search
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_name' AND p_query_search IS NOT NULL
                                THEN LOWER(CONCAT(s_staff.first_name, ' ', s_staff.last_name)) LIKE LOWER('%' || p_query_search || '%')
                            ELSE TRUE
                        END
                        AND sv.is_active = TRUE
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE sv.created_by = p_user_id
                        END
                    ORDER BY sv.last_update::TIMESTAMP DESC NULLS LAST, sv.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON AS data;
    ELSE
        RETURN QUERY
        SELECT
            'No site visits found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve site visits.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 �   DROP FUNCTION public.site_visit_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          postgres    false            :           1255    21036 �   site_visit_update(text, text, integer, integer, text, integer, text, timestamp without time zone, timestamp without time zone, text[], text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     K  CREATE PROCEDURE public.site_visit_update(IN p_site_visit_id text, IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN

    UPDATE public.tb_site_visit
    SET 
        call_id = p_call_id,
        property_profile_id = p_property_profile_id,
        staff_id = p_staff_id,
        lead_id = p_lead_id,
        contact_result_id = p_contact_result_id,
        purpose = p_purpose,
        start_datetime = p_start_datetime,
        end_datetime = p_end_datetime,
        photo_url = p_photo_url,
        remark = p_remark,
        is_active = p_is_active,
        updated_by = p_updated_by,
        last_update = NOW()
    WHERE
        site_visit_id = p_site_visit_id;

    IF NOT FOUND THEN
        message := 'Site Visit with ID ' || p_site_visit_id || ' not found.';
        error := 'Record not found.';
        "statusCode" := 404;
        RETURN;
    END IF;

    CALL site_visit_history_insert(
        p_site_visit_id,
        p_call_id,
        p_property_profile_id,
        p_staff_id,
        p_lead_id,
        p_contact_result_id,
        p_purpose,
        p_start_datetime,
        p_end_datetime,
        p_photo_url,
        p_remark,
        p_updated_by,
        v_msg,
        v_err,
        v_status
    );
  
	message := 'Site Visit updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
    message := 'Failed to update site visit.';
    error := SQLERRM;
    "statusCode" := 500;  
END;
$$;
 �  DROP PROCEDURE public.site_visit_update(IN p_site_visit_id text, IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            !           1255    21037 D   staff_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.staff_delete(IN p_staff_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public.tb_contact_channel
    WHERE menu_trx_id = p_staff_id::text;

    DELETE FROM public.tb_staff
    WHERE staff_id = p_staff_id;

    IF NOT FOUND THEN
        message := 'Staff not found.';
        error := 'No staff exists with the provided ID to delete.';
        "statusCode" := 404;
        ROLLBACK;
        RETURN;
    END IF;

    message := 'Staff and associated contacts deleted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to delete staff and associated contacts.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 �   DROP PROCEDURE public.staff_delete(IN p_staff_id integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            3           1255    21038 �   staff_insert(integer, text, integer, integer, integer, text, text, date, text, text, text, date, date, text, text, text[], text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.staff_insert(IN p_staff_id integer, IN p_staff_code text, IN p_gender_id integer, IN p_village_id integer, IN p_manager_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_position text, IN p_department text, IN p_employment_type text, IN p_employment_start_date date, IN p_employment_end_date date, IN p_employment_level text, IN p_current_address text, IN p_photo_url text[], IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    INSERT INTO public.tb_staff (
        staff_id,
        staff_code,
        gender_id,
        village_id,
        manager_id,
        first_name,
        last_name,
        date_of_birth,
        position,
        department,
        employment_type,
        employment_start_date,
        employment_end_date,
        employment_level,
        current_address,
        photo_url,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_staff_id,
        p_staff_code,
        p_gender_id,
        p_village_id,
        p_manager_id,
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_position,
        p_department,
        p_employment_type,
        p_employment_start_date,
        p_employment_end_date,
        p_employment_level,
        p_current_address,
        p_photo_url,
        TRUE,
        NOW(),
        p_created_by
    );

    FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
    LOOP
        CALL public.contact_channel_insert(
            (v_channel->>'channel_type_id')::integer,
            p_menu_id,
            p_staff_id::text,
            p_created_by,
            v_contact_channel_id,
            v_msg,
            v_err,
            v_status
        );

        IF v_status != 200 THEN
            RAISE EXCEPTION 'Failed to insert contact channel: % (Status: %)', v_err, v_status;
        END IF;

        FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
        LOOP
            CALL public.contact_value_insert(
                v_contact_channel_id,
                v_value->>'user_name',
                v_value->>'contact_number',
                v_value->>'remark',
                (v_value->>'is_primary')::boolean,
                p_created_by,
                v_msg,
                v_err,
                v_status
            );

            IF v_status != 200 THEN
                RAISE EXCEPTION 'Failed to insert contact value: % (Status: %)', v_err, v_status;
            END IF;
        END LOOP;
    END LOOP;

    message := 'Staff and contacts inserted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to insert staff and contacts.';
        error := SQLERRM;
        "statusCode" := 500;
END;
$$;
 S  DROP PROCEDURE public.staff_insert(IN p_staff_id integer, IN p_staff_code text, IN p_gender_id integer, IN p_village_id integer, IN p_manager_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_position text, IN p_department text, IN p_employment_type text, IN p_employment_start_date date, IN p_employment_end_date date, IN p_employment_level text, IN p_current_address text, IN p_photo_url text[], IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            Y           1255    21039 Q   staff_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     f  CREATE FUNCTION public.staff_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
    v_user_role text; -- Declaring variable to hold the user's role
BEGIN
    -- Retrieve the user's role based on p_user_id
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    -- First, get the total count of records matching the search criteria and role-based access
    SELECT COUNT(a.staff_id) INTO v_total
    FROM tb_staff a
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_name' AND p_query_search IS NOT NULL
                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_id' AND p_query_search IS NOT NULL
                THEN a.staff_code = p_query_search
            ELSE TRUE
        END
        AND a.is_active = TRUE
        -- Apply role-based filtering using the internally fetched v_user_role
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE -- If 'RG_01' role, select all
            ELSE a.created_by = p_user_id       -- Otherwise, filter by created_by
        END;

    -- If total records are greater than 0, proceed to fetch the paginated data
    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Staff retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        a.staff_id,
                        a.staff_code,
                        CONCAT(a.first_name, ' ', a.last_name) AS staff_name,
                        a.gender_id,
                        d.gender_name,
                        a.village_id,
                        e.village_name,
                        a.manager_id,
                        a.date_of_birth,
                        a.position,
                        a.department,
                        a.employment_type,
                        a.employment_start_date,
                        a.employment_end_date,
                        a.employment_level,
                        a.current_address,
                        a.photo_url,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) AS created_by_name,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) AS updated_by_name,
                        a.last_update::TEXT,
                        -- Aggregate contact data here
                        (
                            SELECT json_agg(
                                json_build_object(
                                    'channel_type_id', cc.channel_type_id,
                                    'menu_id', cc.menu_id, -- Assuming menu_id exists in tb_contact_channel
                                    'contact_values', (
                                        SELECT json_agg(
                                            json_build_object(
                                                'user_name', cv.user_name,
                                                'contact_number', cv.contact_number,
                                                'remark', cv.remark,
                                                'is_primary', cv.is_primary
                                            )
                                        )
                                        FROM public.tb_contact_value cv
                                        WHERE cv.contact_channel_id = cc.contact_channel_id
                                    )
                                )
                            )
                            FROM public.tb_contact_channel cc
                            WHERE cc.menu_trx_id = a.staff_id::text
                            -- AND cc.menu_id = 'MU_05' -- Uncomment if you only want contacts for a specific menu_id
                        )::JSON AS contact_data
                    FROM tb_staff a
                    LEFT JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    JOIN tb_gender d ON a.gender_id = d.gender_id
                    JOIN tb_village e ON a.village_id = e.village_id
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_name' AND p_query_search IS NOT NULL
                                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_id' AND p_query_search IS NOT NULL
                                THEN a.staff_code = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                        -- Apply role-based filtering using the internally fetched v_user_role
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id
                        END
                    ORDER BY A.last_update::TIMESTAMP DESC NULLS LAST, A.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) t
            )::JSON;
    ELSE
        -- If no staff found, return empty data with 404 status code
        RETURN QUERY
        SELECT
            'No staff found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    -- Catch any exceptions and return an error response
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve staff.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 �   DROP FUNCTION public.staff_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          postgres    false            I           1255    21041 �   staff_update(integer, text, integer, integer, integer, text, text, date, text, text, text, date, date, text, text, text[], boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     ;  CREATE PROCEDURE public.staff_update(IN p_staff_id integer, IN p_staff_code text, IN p_gender_id integer, IN p_village_id integer, IN p_manager_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_position text, IN p_department text, IN p_employment_type text, IN p_employment_start_date date, IN p_employment_end_date date, IN p_employment_level text, IN p_current_address text, IN p_photo_url text[], IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_channel jsonb;
    v_value jsonb;
    v_contact_channel_id integer;
    v_msg character varying;
    v_err character varying;
    v_status integer;
BEGIN
    UPDATE public.tb_staff
    SET
        staff_code = p_staff_code,
        gender_id = p_gender_id,
        village_id = p_village_id,
        manager_id = p_manager_id,
        first_name = p_first_name,
        last_name = p_last_name,
        date_of_birth = p_date_of_birth,
        position = p_position,
        department = p_department,
        employment_type = p_employment_type,
        employment_start_date = p_employment_start_date,
        employment_end_date = p_employment_end_date,
        employment_level = p_employment_level,
        current_address = p_current_address,
        photo_url = p_photo_url,
        is_active = p_is_active,     
        last_update = NOW(),           
        updated_by = p_updated_by     
    WHERE staff_id = p_staff_id;

    IF NOT FOUND THEN
        message := 'Staff with ID ' || p_staff_id || ' not found.';
        error := 'Record not found.';
        "statusCode" := 404;
        RETURN;
    END IF;

    DELETE FROM public.tb_contact_channel
    WHERE menu_trx_id = p_staff_id::text
      AND menu_id = p_menu_id;

    IF p_contact_data IS NOT NULL AND jsonb_typeof(p_contact_data) = 'array' THEN
        FOR v_channel IN SELECT * FROM jsonb_array_elements(p_contact_data)
        LOOP
            CALL public.contact_channel_insert(
                (v_channel->>'channel_type_id')::integer,
                p_menu_id,             
                p_staff_id::text,      
                p_updated_by,          
                v_contact_channel_id,  
                v_msg,
                v_err,
                v_status
            );
           
            IF v_status != 200 THEN           
                RAISE EXCEPTION 'Failed to insert contact channel for staff ID %: % (Status: %)', p_staff_id, v_err, v_status;
            END IF;

            FOR v_value IN SELECT * FROM jsonb_array_elements(v_channel->'contact_values')
            LOOP            
                CALL public.contact_value_insert(
                    v_contact_channel_id,
                    v_value->>'user_name',
                    v_value->>'contact_number',
                    v_value->>'remark',
                    (v_value->>'is_primary')::boolean,
                    p_updated_by,
                    v_msg,
                    v_err,
                    v_status
                );
               
                IF v_status != 200 THEN
                    RAISE EXCEPTION 'Failed to insert contact value for staff ID % (channel ID %): % (Status: %)', p_staff_id, v_contact_channel_id, v_err, v_status;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    message := 'Staff and contacts updated successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN 
        message := 'Failed to update staff and contacts.';
        error := SQLERRM; 
        "statusCode" := 500;
END;
$$;
 k  DROP PROCEDURE public.staff_update(IN p_staff_id integer, IN p_staff_code text, IN p_gender_id integer, IN p_village_id integer, IN p_manager_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_position text, IN p_department text, IN p_employment_type text, IN p_employment_start_date date, IN p_employment_end_date date, IN p_employment_level text, IN p_current_address text, IN p_photo_url text[], IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            (           1255    21042 K   user_role_delete(text, text, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.user_role_delete(IN p_role_id text, IN p_staff_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM
        public.tb_user_role
    WHERE
        role_id = p_role_id AND staff_id = p_staff_id;
		
	message := 'User Role deleted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to delete user role.';
            error := SQLERRM;
            "statusCode" := 500; 
END;
$$;
 �   DROP PROCEDURE public.user_role_delete(IN p_role_id text, IN p_staff_id text, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            [           1255    21043 c   user_role_insert(text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.user_role_insert(IN p_role_id text, IN p_staff_id text, IN p_description text, IN p_is_active boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_user_role (
        role_id,
		staff_id,
        description,
        is_active,
        created_date,
        created_by
    )
    VALUES (
		p_role_id,
        p_staff_id,
        p_description,
        p_is_active,
        NOW(),
        p_created_by
    );
  
	message := 'User Role inserted successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'User Failed to insert role.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.user_role_insert(IN p_role_id text, IN p_staff_id text, IN p_description text, IN p_is_active boolean, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false                       1255    21044 c   user_role_update(text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     x  CREATE PROCEDURE public.user_role_update(IN p_role_id text, IN p_staff_id text, IN p_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        public.tb_user_role
    SET
        role_id = p_role_id,
        description = p_description,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
         staff_id = p_staff_id;

	message := 'User Role updated successfully.';
        error := NULL;
        "statusCode" := 200;  

    EXCEPTION
        WHEN OTHERS THEN
            message := 'Failed to update user role.';
            error := SQLERRM;
            "statusCode" := 500;  
END;
$$;
 �   DROP PROCEDURE public.user_role_update(IN p_role_id text, IN p_staff_id text, IN p_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          postgres    false            �            1259    21045    tb_audit_logs    TABLE     �  CREATE TABLE public.tb_audit_logs (
    id integer NOT NULL,
    method character varying NOT NULL,
    original_url text NOT NULL,
    user_id character varying,
    ip character varying,
    user_agent text,
    status_code integer,
    message text,
    error text,
    duration_ms integer,
    log_type character varying NOT NULL,
    log_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    request_body json
);
 !   DROP TABLE public.tb_audit_logs;
       public         heap    postgres    false            �            1259    21051    tb_audit_logs_id_seq    SEQUENCE     �   ALTER TABLE public.tb_audit_logs ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    215            �            1259    21052    tb_business    TABLE       CREATE TABLE public.tb_business (
    business_id integer NOT NULL,
    business_name text,
    business_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
    DROP TABLE public.tb_business;
       public         heap    postgres    false            �            1259    21057    tb_business_business_id_seq    SEQUENCE     �   ALTER TABLE public.tb_business ALTER COLUMN business_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_business_business_id_seq
    START WITH 324
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    217            �            1259    21058    tb_call_log    TABLE     {  CREATE TABLE public.tb_call_log (
    call_log_id text NOT NULL,
    lead_id text NOT NULL,
    property_profile_id integer NOT NULL,
    status_id integer NOT NULL,
    purpose text,
    fail_reason text,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
    DROP TABLE public.tb_call_log;
       public         heap    postgres    false            �            1259    21063    tb_call_log_detail    TABLE     �  CREATE TABLE public.tb_call_log_detail (
    call_log_detail_id text NOT NULL,
    call_log_id text NOT NULL,
    contact_result_id integer NOT NULL,
    call_start_datetime timestamp without time zone NOT NULL,
    call_end_datetime timestamp without time zone NOT NULL,
    remark text,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
 &   DROP TABLE public.tb_call_log_detail;
       public         heap    postgres    false            	           1259    21612    tb_call_log_detail_history    TABLE       CREATE TABLE public.tb_call_log_detail_history (
    history_date timestamp without time zone,
    call_log_detail_id text NOT NULL,
    call_log_id text NOT NULL,
    contact_result_id integer NOT NULL,
    call_start_datetime timestamp without time zone NOT NULL,
    call_end_datetime timestamp without time zone NOT NULL,
    remark text,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
 .   DROP TABLE public.tb_call_log_detail_history;
       public         heap    postgres    false            
           1259    21627    tb_call_log_history    TABLE     �  CREATE TABLE public.tb_call_log_history (
    history_date timestamp without time zone,
    call_log_id text NOT NULL,
    lead_id text NOT NULL,
    property_profile_id integer NOT NULL,
    status_id integer NOT NULL,
    purpose text,
    fail_reason text,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
 '   DROP TABLE public.tb_call_log_history;
       public         heap    postgres    false            �            1259    21078    tb_channel_type    TABLE     /  CREATE TABLE public.tb_channel_type (
    channel_type_id integer NOT NULL,
    channel_type_name text,
    channel_type_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 #   DROP TABLE public.tb_channel_type;
       public         heap    postgres    false            �            1259    21083 #   tb_channel_type_channel_type_id_seq    SEQUENCE     �   ALTER TABLE public.tb_channel_type ALTER COLUMN channel_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_channel_type_channel_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    221            �            1259    21084 
   tb_commune    TABLE       CREATE TABLE public.tb_commune (
    commune_id integer NOT NULL,
    district_id integer,
    commune_name text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by text,
    last_update timestamp without time zone,
    updated_by text
);
    DROP TABLE public.tb_commune;
       public         heap    postgres    false            �            1259    21089    tb_contact_channel    TABLE     V  CREATE TABLE public.tb_contact_channel (
    contact_channel_id integer NOT NULL,
    channel_type_id integer NOT NULL,
    menu_id text NOT NULL,
    menu_trx_id text NOT NULL,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 &   DROP TABLE public.tb_contact_channel;
       public         heap    postgres    false            �            1259    21094 )   tb_contact_channel_contact_channel_id_seq    SEQUENCE     �   ALTER TABLE public.tb_contact_channel ALTER COLUMN contact_channel_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_channel_contact_channel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    224            �            1259    21095    tb_contact_channel_history    TABLE     �  CREATE TABLE public.tb_contact_channel_history (
    history_date timestamp without time zone,
    contact_channel_id integer NOT NULL,
    channel_type_id integer NOT NULL,
    menu_id text NOT NULL,
    menu_trx_id text NOT NULL,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 .   DROP TABLE public.tb_contact_channel_history;
       public         heap    postgres    false            �            1259    21100 1   tb_contact_channel_history_contact_channel_id_seq    SEQUENCE       ALTER TABLE public.tb_contact_channel_history ALTER COLUMN contact_channel_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_channel_history_contact_channel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    226            �            1259    21101    tb_contact_result    TABLE     :  CREATE TABLE public.tb_contact_result (
    contact_result_id integer NOT NULL,
    menu_id text,
    contact_result_name text,
    description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 %   DROP TABLE public.tb_contact_result;
       public         heap    postgres    false            �            1259    21106 '   tb_contact_result_contact_result_id_seq    SEQUENCE     �   ALTER TABLE public.tb_contact_result ALTER COLUMN contact_result_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_result_contact_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    228            �            1259    21107    tb_contact_value    TABLE     q  CREATE TABLE public.tb_contact_value (
    contact_value_id integer NOT NULL,
    contact_channel_id integer NOT NULL,
    user_name text,
    contact_number text,
    remark text,
    is_primary boolean,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 $   DROP TABLE public.tb_contact_value;
       public         heap    postgres    false            �            1259    21112 %   tb_contact_value_contact_value_id_seq    SEQUENCE     �   ALTER TABLE public.tb_contact_value ALTER COLUMN contact_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_value_contact_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    230            �            1259    21113    tb_contact_value_history    TABLE     �  CREATE TABLE public.tb_contact_value_history (
    history_date timestamp without time zone,
    contact_value_id integer NOT NULL,
    contact_channel_id integer NOT NULL,
    user_name text,
    contact_number text,
    remark text,
    is_primary boolean,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 ,   DROP TABLE public.tb_contact_value_history;
       public         heap    postgres    false            �            1259    21118 -   tb_contact_value_history_contact_value_id_seq    SEQUENCE       ALTER TABLE public.tb_contact_value_history ALTER COLUMN contact_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_value_history_contact_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    232            �            1259    21119    tb_customer_type    TABLE     3  CREATE TABLE public.tb_customer_type (
    customer_type_id integer NOT NULL,
    customer_type_name text,
    customer_type_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 $   DROP TABLE public.tb_customer_type;
       public         heap    postgres    false            �            1259    21124 %   tb_customer_type_customer_type_id_seq    SEQUENCE     �   ALTER TABLE public.tb_customer_type ALTER COLUMN customer_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_customer_type_customer_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    234            �            1259    21125    tb_developer    TABLE     #  CREATE TABLE public.tb_developer (
    developer_id integer NOT NULL,
    developer_name text,
    developer_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
     DROP TABLE public.tb_developer;
       public         heap    postgres    false            �            1259    21130    tb_developer_developer_id_seq    SEQUENCE     �   ALTER TABLE public.tb_developer ALTER COLUMN developer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_developer_developer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    236            �            1259    21131    tb_district    TABLE       CREATE TABLE public.tb_district (
    district_id integer NOT NULL,
    province_id integer,
    district_name text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by text,
    last_update timestamp without time zone,
    updated_by text
);
    DROP TABLE public.tb_district;
       public         heap    postgres    false            �            1259    21136 	   tb_gender    TABLE       CREATE TABLE public.tb_gender (
    gender_id integer NOT NULL,
    gender_name text,
    gender_description text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
    DROP TABLE public.tb_gender;
       public         heap    postgres    false            �            1259    21141    tb_lead    TABLE     �  CREATE TABLE public.tb_lead (
    lead_id text NOT NULL,
    gender_id integer,
    customer_type_id integer,
    lead_source_id integer,
    village_id integer,
    business_id integer,
    initial_staff_id integer,
    current_staff_id integer,
    first_name text,
    last_name text,
    date_of_birth date,
    occupation text,
    email text,
    home_address text,
    street_address text,
    biz_description text,
    relationship_date date,
    remark text,
    photo_url text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
    DROP TABLE public.tb_lead;
       public         heap    postgres    false            �            1259    21146    tb_lead_history    TABLE     �  CREATE TABLE public.tb_lead_history (
    history_date timestamp without time zone NOT NULL,
    lead_id text NOT NULL,
    gender_id integer,
    customer_type_id integer,
    lead_source_id integer,
    village_id integer,
    business_id integer,
    initial_staff_id integer,
    current_staff_id integer,
    first_name text,
    last_name text,
    date_of_birth date,
    occupation text,
    email text,
    home_address text,
    street_address text,
    biz_description text,
    relationship_date date,
    remark text,
    photo_url text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
 #   DROP TABLE public.tb_lead_history;
       public         heap    postgres    false            �            1259    21151    tb_lead_source    TABLE     +  CREATE TABLE public.tb_lead_source (
    lead_source_id integer NOT NULL,
    lead_source_name text,
    lead_source_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 "   DROP TABLE public.tb_lead_source;
       public         heap    postgres    false            �            1259    21156 !   tb_lead_source_lead_source_id_seq    SEQUENCE     �   ALTER TABLE public.tb_lead_source ALTER COLUMN lead_source_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_lead_source_lead_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    242            �            1259    21157    tb_menu    TABLE       CREATE TABLE public.tb_menu (
    menu_id text NOT NULL,
    menu_name text,
    description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
    DROP TABLE public.tb_menu;
       public         heap    postgres    false            �            1259    21162    tb_occupation    TABLE     '  CREATE TABLE public.tb_occupation (
    occupation_id integer NOT NULL,
    occupation_name text,
    occupation_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 !   DROP TABLE public.tb_occupation;
       public         heap    postgres    false            �            1259    21167 
   tb_payment    TABLE     [  CREATE TABLE public.tb_payment (
    payment_id integer NOT NULL,
    call_id integer,
    amount_in_usd numeric,
    start_payment_date date,
    tenor integer,
    interest_rate numeric,
    remark text,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
    DROP TABLE public.tb_payment;
       public         heap    postgres    false            �            1259    21172    tb_permission    TABLE       CREATE TABLE public.tb_permission (
    permission_id text NOT NULL,
    permission_name text,
    description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 !   DROP TABLE public.tb_permission;
       public         heap    postgres    false            �            1259    21177 
   tb_project    TABLE     M  CREATE TABLE public.tb_project (
    project_id integer NOT NULL,
    developer_id integer,
    village_id integer,
    project_name text,
    project_description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
    DROP TABLE public.tb_project;
       public         heap    postgres    false            �            1259    21182    tb_project_owner    TABLE     s  CREATE TABLE public.tb_project_owner (
    project_owner_id integer NOT NULL,
    gender_id integer,
    village_id integer,
    first_name text,
    last_name text,
    date_of_birth date,
    remark text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 $   DROP TABLE public.tb_project_owner;
       public         heap    postgres    false            �            1259    21187 %   tb_project_owner_project_owner_id_seq    SEQUENCE     �   ALTER TABLE public.tb_project_owner ALTER COLUMN project_owner_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_project_owner_project_owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    249            �            1259    21188    tb_project_project_id_seq    SEQUENCE     �   ALTER TABLE public.tb_project ALTER COLUMN project_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_project_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    248            �            1259    21189    tb_property_profile    TABLE     �  CREATE TABLE public.tb_property_profile (
    property_profile_id integer NOT NULL,
    property_type_id integer,
    project_id integer,
    project_owner_id integer,
    village_id integer,
    property_profile_name text,
    home_number text,
    room_number text,
    address text,
    width numeric,
    length numeric,
    remark text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
 '   DROP TABLE public.tb_property_profile;
       public         heap    postgres    false            �            1259    21194 +   tb_property_profile_property_profile_id_seq    SEQUENCE       ALTER TABLE public.tb_property_profile ALTER COLUMN property_profile_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_property_profile_property_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    252            �            1259    21195    tb_property_type    TABLE     3  CREATE TABLE public.tb_property_type (
    property_type_id integer NOT NULL,
    property_type_name text,
    property_type_description text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
 $   DROP TABLE public.tb_property_type;
       public         heap    postgres    false            �            1259    21200 %   tb_property_type_property_type_id_seq    SEQUENCE     �   ALTER TABLE public.tb_property_type ALTER COLUMN property_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_property_type_property_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    254                        1259    21201    tb_province    TABLE     �   CREATE TABLE public.tb_province (
    province_id integer NOT NULL,
    province_name text,
    created_date timestamp without time zone,
    created_by text,
    last_update timestamp without time zone,
    updated_by text
);
    DROP TABLE public.tb_province;
       public         heap    postgres    false                       1259    21206    tb_role    TABLE       CREATE TABLE public.tb_role (
    role_id text NOT NULL,
    role_name text,
    description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
    DROP TABLE public.tb_role;
       public         heap    postgres    false                       1259    21211    tb_role_permission    TABLE     :  CREATE TABLE public.tb_role_permission (
    role_id text NOT NULL,
    permission_id text NOT NULL,
    menu_id text NOT NULL,
    description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
 &   DROP TABLE public.tb_role_permission;
       public         heap    postgres    false                       1259    21216    tb_site_visit    TABLE     0  CREATE TABLE public.tb_site_visit (
    site_visit_id text NOT NULL,
    call_id text NOT NULL,
    property_profile_id integer NOT NULL,
    staff_id integer NOT NULL,
    lead_id text NOT NULL,
    contact_result_id integer NOT NULL,
    purpose text,
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    photo_url text[],
    remark text,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
 !   DROP TABLE public.tb_site_visit;
       public         heap    postgres    false                       1259    21587    tb_site_visit_history    TABLE     o  CREATE TABLE public.tb_site_visit_history (
    history_date timestamp without time zone NOT NULL,
    site_visit_id text NOT NULL,
    call_id text NOT NULL,
    property_profile_id integer NOT NULL,
    staff_id integer NOT NULL,
    lead_id text NOT NULL,
    contact_result_id integer NOT NULL,
    purpose text,
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    photo_url text[],
    remark text,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
 )   DROP TABLE public.tb_site_visit_history;
       public         heap    postgres    false                       1259    21226    tb_staff    TABLE     p  CREATE TABLE public.tb_staff (
    staff_id integer NOT NULL,
    staff_code text NOT NULL,
    gender_id integer,
    village_id integer,
    manager_id integer,
    occupation_id integer,
    first_name text,
    last_name text,
    date_of_birth date,
    "position" text,
    department text,
    employment_type text,
    employment_start_date date,
    employment_end_date date,
    employment_level text,
    current_address text,
    photo_url text[],
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
    DROP TABLE public.tb_staff;
       public         heap    postgres    false                       1259    21231 	   tb_status    TABLE       CREATE TABLE public.tb_status (
    status_id integer NOT NULL,
    status text,
    status_description text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
    DROP TABLE public.tb_status;
       public         heap    postgres    false                       1259    21236    tb_user_role    TABLE       CREATE TABLE public.tb_user_role (
    role_id text NOT NULL,
    staff_id text NOT NULL,
    description text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by integer,
    last_update timestamp without time zone,
    updated_by integer
);
     DROP TABLE public.tb_user_role;
       public         heap    postgres    false                       1259    21241 
   tb_village    TABLE       CREATE TABLE public.tb_village (
    village_id integer NOT NULL,
    commune_id integer,
    village_name text,
    is_active boolean,
    created_date timestamp without time zone,
    created_by text,
    last_update timestamp without time zone,
    updated_by text
);
    DROP TABLE public.tb_village;
       public         heap    postgres    false                      0    21045    tb_audit_logs 
   TABLE DATA           �   COPY public.tb_audit_logs (id, method, original_url, user_id, ip, user_agent, status_code, message, error, duration_ms, log_type, log_time, request_body) FROM stdin;
    public          postgres    false    215   �                0    21052    tb_business 
   TABLE DATA           �   COPY public.tb_business (business_id, business_name, business_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    217   c�                0    21058    tb_call_log 
   TABLE DATA           �   COPY public.tb_call_log (call_log_id, lead_id, property_profile_id, status_id, purpose, fail_reason, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          postgres    false    219   ��                0    21063    tb_call_log_detail 
   TABLE DATA           �   COPY public.tb_call_log_detail (call_log_detail_id, call_log_id, contact_result_id, call_start_datetime, call_end_datetime, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          postgres    false    220   V�      B          0    21612    tb_call_log_detail_history 
   TABLE DATA           �   COPY public.tb_call_log_detail_history (history_date, call_log_detail_id, call_log_id, contact_result_id, call_start_datetime, call_end_datetime, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          postgres    false    265   ��      C          0    21627    tb_call_log_history 
   TABLE DATA           �   COPY public.tb_call_log_history (history_date, call_log_id, lead_id, property_profile_id, status_id, purpose, fail_reason, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          postgres    false    266   =�                0    21078    tb_channel_type 
   TABLE DATA           �   COPY public.tb_channel_type (channel_type_id, channel_type_name, channel_type_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    221   ��                0    21084 
   tb_commune 
   TABLE DATA           �   COPY public.tb_commune (commune_id, district_id, commune_name, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    223   c�                0    21089    tb_contact_channel 
   TABLE DATA           �   COPY public.tb_contact_channel (contact_channel_id, channel_type_id, menu_id, menu_trx_id, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    224   :�                0    21095    tb_contact_channel_history 
   TABLE DATA           �   COPY public.tb_contact_channel_history (history_date, contact_channel_id, channel_type_id, menu_id, menu_trx_id, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    226   ��                0    21101    tb_contact_result 
   TABLE DATA           �   COPY public.tb_contact_result (contact_result_id, menu_id, contact_result_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    228   :�                0    21107    tb_contact_value 
   TABLE DATA           �   COPY public.tb_contact_value (contact_value_id, contact_channel_id, user_name, contact_number, remark, is_primary, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    230   ��      !          0    21113    tb_contact_value_history 
   TABLE DATA           �   COPY public.tb_contact_value_history (history_date, contact_value_id, contact_channel_id, user_name, contact_number, remark, is_primary, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    232   ��      #          0    21119    tb_customer_type 
   TABLE DATA           �   COPY public.tb_customer_type (customer_type_id, customer_type_name, customer_type_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    234   ��      %          0    21125    tb_developer 
   TABLE DATA           �   COPY public.tb_developer (developer_id, developer_name, developer_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    236   �      '          0    21131    tb_district 
   TABLE DATA           �   COPY public.tb_district (district_id, province_id, district_name, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    238   >�      (          0    21136 	   tb_gender 
   TABLE DATA           �   COPY public.tb_gender (gender_id, gender_name, gender_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    239   ]      )          0    21141    tb_lead 
   TABLE DATA           `  COPY public.tb_lead (lead_id, gender_id, customer_type_id, lead_source_id, village_id, business_id, initial_staff_id, current_staff_id, first_name, last_name, date_of_birth, occupation, email, home_address, street_address, biz_description, relationship_date, remark, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    240   �      *          0    21146    tb_lead_history 
   TABLE DATA           v  COPY public.tb_lead_history (history_date, lead_id, gender_id, customer_type_id, lead_source_id, village_id, business_id, initial_staff_id, current_staff_id, first_name, last_name, date_of_birth, occupation, email, home_address, street_address, biz_description, relationship_date, remark, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    241          +          0    21151    tb_lead_source 
   TABLE DATA           �   COPY public.tb_lead_source (lead_source_id, lead_source_name, lead_source_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    242   �      -          0    21157    tb_menu 
   TABLE DATA           �   COPY public.tb_menu (menu_id, menu_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    244   [      .          0    21162    tb_occupation 
   TABLE DATA           �   COPY public.tb_occupation (occupation_id, occupation_name, occupation_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    245   @      /          0    21167 
   tb_payment 
   TABLE DATA           �   COPY public.tb_payment (payment_id, call_id, amount_in_usd, start_payment_date, tenor, interest_rate, remark, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    246   ]      0          0    21172    tb_permission 
   TABLE DATA           �   COPY public.tb_permission (permission_id, permission_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    247   z      1          0    21177 
   tb_project 
   TABLE DATA           �   COPY public.tb_project (project_id, developer_id, village_id, project_name, project_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    248   �      2          0    21182    tb_project_owner 
   TABLE DATA           �   COPY public.tb_project_owner (project_owner_id, gender_id, village_id, first_name, last_name, date_of_birth, remark, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    249   o      5          0    21189    tb_property_profile 
   TABLE DATA             COPY public.tb_property_profile (property_profile_id, property_type_id, project_id, project_owner_id, village_id, property_profile_name, home_number, room_number, address, width, length, remark, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    252   �      7          0    21195    tb_property_type 
   TABLE DATA           �   COPY public.tb_property_type (property_type_id, property_type_name, property_type_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    254   r      9          0    21201    tb_province 
   TABLE DATA           t   COPY public.tb_province (province_id, province_name, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    256   �      :          0    21206    tb_role 
   TABLE DATA           �   COPY public.tb_role (role_id, role_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    257   		      ;          0    21211    tb_role_permission 
   TABLE DATA           �   COPY public.tb_role_permission (role_id, permission_id, menu_id, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    258   Q	      <          0    21216    tb_site_visit 
   TABLE DATA           �   COPY public.tb_site_visit (site_visit_id, call_id, property_profile_id, staff_id, lead_id, contact_result_id, purpose, start_datetime, end_datetime, photo_url, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          postgres    false    259   �
      A          0    21587    tb_site_visit_history 
   TABLE DATA             COPY public.tb_site_visit_history (history_date, site_visit_id, call_id, property_profile_id, staff_id, lead_id, contact_result_id, purpose, start_datetime, end_datetime, photo_url, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          postgres    false    264   �      =          0    21226    tb_staff 
   TABLE DATA           Q  COPY public.tb_staff (staff_id, staff_code, gender_id, village_id, manager_id, occupation_id, first_name, last_name, date_of_birth, "position", department, employment_type, employment_start_date, employment_end_date, employment_level, current_address, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    260   �      >          0    21231 	   tb_status 
   TABLE DATA           �   COPY public.tb_status (status_id, status, status_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          postgres    false    261   �      ?          0    21236    tb_user_role 
   TABLE DATA           �   COPY public.tb_user_role (role_id, staff_id, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    262   �      @          0    21241 
   tb_village 
   TABLE DATA           �   COPY public.tb_village (village_id, commune_id, village_name, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          postgres    false    263   <      J           0    0    tb_audit_logs_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.tb_audit_logs_id_seq', 2704, true);
          public          postgres    false    216            K           0    0    tb_business_business_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.tb_business_business_id_seq', 324, true);
          public          postgres    false    218            L           0    0 #   tb_channel_type_channel_type_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.tb_channel_type_channel_type_id_seq', 6, true);
          public          postgres    false    222            M           0    0 )   tb_contact_channel_contact_channel_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.tb_contact_channel_contact_channel_id_seq', 124, true);
          public          postgres    false    225            N           0    0 1   tb_contact_channel_history_contact_channel_id_seq    SEQUENCE SET     `   SELECT pg_catalog.setval('public.tb_contact_channel_history_contact_channel_id_seq', 52, true);
          public          postgres    false    227            O           0    0 '   tb_contact_result_contact_result_id_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public.tb_contact_result_contact_result_id_seq', 40, true);
          public          postgres    false    229            P           0    0 %   tb_contact_value_contact_value_id_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.tb_contact_value_contact_value_id_seq', 172, true);
          public          postgres    false    231            Q           0    0 -   tb_contact_value_history_contact_value_id_seq    SEQUENCE SET     \   SELECT pg_catalog.setval('public.tb_contact_value_history_contact_value_id_seq', 66, true);
          public          postgres    false    233            R           0    0 %   tb_customer_type_customer_type_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tb_customer_type_customer_type_id_seq', 2, true);
          public          postgres    false    235            S           0    0    tb_developer_developer_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.tb_developer_developer_id_seq', 19, true);
          public          postgres    false    237            T           0    0 !   tb_lead_source_lead_source_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.tb_lead_source_lead_source_id_seq', 3, true);
          public          postgres    false    243            U           0    0 %   tb_project_owner_project_owner_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tb_project_owner_project_owner_id_seq', 4, true);
          public          postgres    false    250            V           0    0    tb_project_project_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.tb_project_project_id_seq', 5, true);
          public          postgres    false    251            W           0    0 +   tb_property_profile_property_profile_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.tb_property_profile_property_profile_id_seq', 4, true);
          public          postgres    false    253            X           0    0 %   tb_property_type_property_type_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tb_property_type_property_type_id_seq', 3, true);
          public          postgres    false    255                       2606    21247     tb_audit_logs tb_audit_logs_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.tb_audit_logs
    ADD CONSTRAINT tb_audit_logs_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.tb_audit_logs DROP CONSTRAINT tb_audit_logs_pkey;
       public            postgres    false    215                       2606    21249    tb_business tb_business_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_business
    ADD CONSTRAINT tb_business_pkey PRIMARY KEY (business_id);
 F   ALTER TABLE ONLY public.tb_business DROP CONSTRAINT tb_business_pkey;
       public            postgres    false    217                       2606    21253 *   tb_call_log_detail tb_call_log_detail_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.tb_call_log_detail
    ADD CONSTRAINT tb_call_log_detail_pkey PRIMARY KEY (call_log_detail_id);
 T   ALTER TABLE ONLY public.tb_call_log_detail DROP CONSTRAINT tb_call_log_detail_pkey;
       public            postgres    false    220                       2606    21257    tb_call_log tb_call_log_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT tb_call_log_pkey PRIMARY KEY (call_log_id);
 F   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT tb_call_log_pkey;
       public            postgres    false    219                       2606    21259 $   tb_channel_type tb_channel_type_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.tb_channel_type
    ADD CONSTRAINT tb_channel_type_pkey PRIMARY KEY (channel_type_id);
 N   ALTER TABLE ONLY public.tb_channel_type DROP CONSTRAINT tb_channel_type_pkey;
       public            postgres    false    221                       2606    21261    tb_commune tb_commune_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_commune
    ADD CONSTRAINT tb_commune_pkey PRIMARY KEY (commune_id);
 D   ALTER TABLE ONLY public.tb_commune DROP CONSTRAINT tb_commune_pkey;
       public            postgres    false    223                       2606    21263 :   tb_contact_channel_history tb_contact_channel_history_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel_history
    ADD CONSTRAINT tb_contact_channel_history_pkey PRIMARY KEY (contact_channel_id);
 d   ALTER TABLE ONLY public.tb_contact_channel_history DROP CONSTRAINT tb_contact_channel_history_pkey;
       public            postgres    false    226                       2606    21265 *   tb_contact_channel tb_contact_channel_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.tb_contact_channel
    ADD CONSTRAINT tb_contact_channel_pkey PRIMARY KEY (contact_channel_id);
 T   ALTER TABLE ONLY public.tb_contact_channel DROP CONSTRAINT tb_contact_channel_pkey;
       public            postgres    false    224                       2606    21267 (   tb_contact_result tb_contact_result_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.tb_contact_result
    ADD CONSTRAINT tb_contact_result_pkey PRIMARY KEY (contact_result_id);
 R   ALTER TABLE ONLY public.tb_contact_result DROP CONSTRAINT tb_contact_result_pkey;
       public            postgres    false    228                        2606    21269 6   tb_contact_value_history tb_contact_value_history_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_value_history
    ADD CONSTRAINT tb_contact_value_history_pkey PRIMARY KEY (contact_value_id);
 `   ALTER TABLE ONLY public.tb_contact_value_history DROP CONSTRAINT tb_contact_value_history_pkey;
       public            postgres    false    232                       2606    21271 &   tb_contact_value tb_contact_value_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_contact_value
    ADD CONSTRAINT tb_contact_value_pkey PRIMARY KEY (contact_value_id);
 P   ALTER TABLE ONLY public.tb_contact_value DROP CONSTRAINT tb_contact_value_pkey;
       public            postgres    false    230            "           2606    21273 &   tb_customer_type tb_customer_type_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_customer_type
    ADD CONSTRAINT tb_customer_type_pkey PRIMARY KEY (customer_type_id);
 P   ALTER TABLE ONLY public.tb_customer_type DROP CONSTRAINT tb_customer_type_pkey;
       public            postgres    false    234            $           2606    21275    tb_developer tb_developer_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.tb_developer
    ADD CONSTRAINT tb_developer_pkey PRIMARY KEY (developer_id);
 H   ALTER TABLE ONLY public.tb_developer DROP CONSTRAINT tb_developer_pkey;
       public            postgres    false    236            &           2606    21277    tb_district tb_district_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_district
    ADD CONSTRAINT tb_district_pkey PRIMARY KEY (district_id);
 F   ALTER TABLE ONLY public.tb_district DROP CONSTRAINT tb_district_pkey;
       public            postgres    false    238            (           2606    21279    tb_gender tb_gender_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_gender
    ADD CONSTRAINT tb_gender_pkey PRIMARY KEY (gender_id);
 B   ALTER TABLE ONLY public.tb_gender DROP CONSTRAINT tb_gender_pkey;
       public            postgres    false    239            *           2606    21281    tb_lead tb_lead_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT tb_lead_pkey PRIMARY KEY (lead_id);
 >   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT tb_lead_pkey;
       public            postgres    false    240            ,           2606    21283 "   tb_lead_source tb_lead_source_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.tb_lead_source
    ADD CONSTRAINT tb_lead_source_pkey PRIMARY KEY (lead_source_id);
 L   ALTER TABLE ONLY public.tb_lead_source DROP CONSTRAINT tb_lead_source_pkey;
       public            postgres    false    242            .           2606    21285    tb_menu tb_menu_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tb_menu
    ADD CONSTRAINT tb_menu_pkey PRIMARY KEY (menu_id);
 >   ALTER TABLE ONLY public.tb_menu DROP CONSTRAINT tb_menu_pkey;
       public            postgres    false    244            0           2606    21287     tb_occupation tb_occupation_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.tb_occupation
    ADD CONSTRAINT tb_occupation_pkey PRIMARY KEY (occupation_id);
 J   ALTER TABLE ONLY public.tb_occupation DROP CONSTRAINT tb_occupation_pkey;
       public            postgres    false    245            2           2606    21289    tb_payment tb_payment_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_payment
    ADD CONSTRAINT tb_payment_pkey PRIMARY KEY (payment_id);
 D   ALTER TABLE ONLY public.tb_payment DROP CONSTRAINT tb_payment_pkey;
       public            postgres    false    246            4           2606    21291     tb_permission tb_permission_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.tb_permission
    ADD CONSTRAINT tb_permission_pkey PRIMARY KEY (permission_id);
 J   ALTER TABLE ONLY public.tb_permission DROP CONSTRAINT tb_permission_pkey;
       public            postgres    false    247            8           2606    21293 &   tb_project_owner tb_project_owner_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_project_owner
    ADD CONSTRAINT tb_project_owner_pkey PRIMARY KEY (project_owner_id);
 P   ALTER TABLE ONLY public.tb_project_owner DROP CONSTRAINT tb_project_owner_pkey;
       public            postgres    false    249            6           2606    21295    tb_project tb_project_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_project
    ADD CONSTRAINT tb_project_pkey PRIMARY KEY (project_id);
 D   ALTER TABLE ONLY public.tb_project DROP CONSTRAINT tb_project_pkey;
       public            postgres    false    248            :           2606    21297 ,   tb_property_profile tb_property_profile_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT tb_property_profile_pkey PRIMARY KEY (property_profile_id);
 V   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT tb_property_profile_pkey;
       public            postgres    false    252            <           2606    21299 &   tb_property_type tb_property_type_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_property_type
    ADD CONSTRAINT tb_property_type_pkey PRIMARY KEY (property_type_id);
 P   ALTER TABLE ONLY public.tb_property_type DROP CONSTRAINT tb_property_type_pkey;
       public            postgres    false    254            >           2606    21301    tb_province tb_province_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_province
    ADD CONSTRAINT tb_province_pkey PRIMARY KEY (province_id);
 F   ALTER TABLE ONLY public.tb_province DROP CONSTRAINT tb_province_pkey;
       public            postgres    false    256            B           2606    21303 *   tb_role_permission tb_role_permission_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tb_role_permission
    ADD CONSTRAINT tb_role_permission_pkey PRIMARY KEY (role_id, permission_id, menu_id);
 T   ALTER TABLE ONLY public.tb_role_permission DROP CONSTRAINT tb_role_permission_pkey;
       public            postgres    false    258    258    258            @           2606    21305    tb_role tb_role_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tb_role
    ADD CONSTRAINT tb_role_pkey PRIMARY KEY (role_id);
 >   ALTER TABLE ONLY public.tb_role DROP CONSTRAINT tb_role_pkey;
       public            postgres    false    257            D           2606    21309     tb_site_visit tb_site_visit_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT tb_site_visit_pkey PRIMARY KEY (site_visit_id);
 J   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT tb_site_visit_pkey;
       public            postgres    false    259            F           2606    21311    tb_staff tb_staff_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.tb_staff
    ADD CONSTRAINT tb_staff_pkey PRIMARY KEY (staff_id);
 @   ALTER TABLE ONLY public.tb_staff DROP CONSTRAINT tb_staff_pkey;
       public            postgres    false    260            H           2606    21313    tb_status tb_status_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_status
    ADD CONSTRAINT tb_status_pkey PRIMARY KEY (status_id);
 B   ALTER TABLE ONLY public.tb_status DROP CONSTRAINT tb_status_pkey;
       public            postgres    false    261            J           2606    21315    tb_user_role tb_user_role_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.tb_user_role
    ADD CONSTRAINT tb_user_role_pkey PRIMARY KEY (role_id, staff_id);
 H   ALTER TABLE ONLY public.tb_user_role DROP CONSTRAINT tb_user_role_pkey;
       public            postgres    false    262    262            L           2606    21317    tb_village tb_village_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_village
    ADD CONSTRAINT tb_village_pkey PRIMARY KEY (village_id);
 D   ALTER TABLE ONLY public.tb_village DROP CONSTRAINT tb_village_pkey;
       public            postgres    false    263            p           2606    21318 -   tb_site_visit fk_site_visit_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 W   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_contact_result_id;
       public          postgres    false    259    228    4892            w           2606    21592 =   tb_site_visit_history fk_site_visit_history_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 g   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_contact_result_id;
       public          postgres    false    4892    264    228            x           2606    21597 3   tb_site_visit_history fk_site_visit_history_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 ]   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_lead_id;
       public          postgres    false    264    4906    240            y           2606    21602 ?   tb_site_visit_history fk_site_visit_history_property_profile_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_property_profile_id FOREIGN KEY (property_profile_id) REFERENCES public.tb_property_profile(property_profile_id);
 i   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_property_profile_id;
       public          postgres    false    264    4922    252            z           2606    21607 4   tb_site_visit_history fk_site_visit_history_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_staff_id FOREIGN KEY (staff_id) REFERENCES public.tb_staff(staff_id);
 ^   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_staff_id;
       public          postgres    false    260    264    4934            q           2606    21343 #   tb_site_visit fk_site_visit_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 M   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_lead_id;
       public          postgres    false    259    4906    240            r           2606    21348 /   tb_site_visit fk_site_visit_property_profile_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_property_profile_id FOREIGN KEY (property_profile_id) REFERENCES public.tb_property_profile(property_profile_id);
 Y   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_property_profile_id;
       public          postgres    false    4922    259    252            s           2606    21353 $   tb_site_visit fk_site_visit_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_staff_id FOREIGN KEY (staff_id) REFERENCES public.tb_staff(staff_id);
 N   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_staff_id;
       public          postgres    false    4934    260    259            {           2606    21617 C   tb_call_log_detail_history fk_tb_call_log_detail_call_log_detail_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail_history
    ADD CONSTRAINT fk_tb_call_log_detail_call_log_detail_id FOREIGN KEY (call_log_detail_id) REFERENCES public.tb_call_log_detail(call_log_detail_id) ON DELETE CASCADE;
 m   ALTER TABLE ONLY public.tb_call_log_detail_history DROP CONSTRAINT fk_tb_call_log_detail_call_log_detail_id;
       public          postgres    false    265    4882    220            P           2606    21363 4   tb_call_log_detail fk_tb_call_log_detail_call_log_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail
    ADD CONSTRAINT fk_tb_call_log_detail_call_log_id FOREIGN KEY (call_log_id) REFERENCES public.tb_call_log(call_log_id) ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.tb_call_log_detail DROP CONSTRAINT fk_tb_call_log_detail_call_log_id;
       public          postgres    false    219    220    4880            Q           2606    21368 :   tb_call_log_detail fk_tb_call_log_detail_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail
    ADD CONSTRAINT fk_tb_call_log_detail_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 d   ALTER TABLE ONLY public.tb_call_log_detail DROP CONSTRAINT fk_tb_call_log_detail_contact_result_id;
       public          postgres    false    4892    228    220            |           2606    21622 B   tb_call_log_detail_history fk_tb_call_log_detail_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail_history
    ADD CONSTRAINT fk_tb_call_log_detail_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 l   ALTER TABLE ONLY public.tb_call_log_detail_history DROP CONSTRAINT fk_tb_call_log_detail_contact_result_id;
       public          postgres    false    4892    228    265            }           2606    21632 6   tb_call_log_history fk_tb_call_log_history_call_log_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_history
    ADD CONSTRAINT fk_tb_call_log_history_call_log_id FOREIGN KEY (call_log_id) REFERENCES public.tb_call_log(call_log_id) ON DELETE CASCADE;
 `   ALTER TABLE ONLY public.tb_call_log_history DROP CONSTRAINT fk_tb_call_log_history_call_log_id;
       public          postgres    false    266    219    4880            ~           2606    21637 2   tb_call_log_history fk_tb_call_log_history_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_history
    ADD CONSTRAINT fk_tb_call_log_history_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 \   ALTER TABLE ONLY public.tb_call_log_history DROP CONSTRAINT fk_tb_call_log_history_lead_id;
       public          postgres    false    266    240    4906                       2606    21642 >   tb_call_log_history fk_tb_call_log_history_property_profile_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_history
    ADD CONSTRAINT fk_tb_call_log_history_property_profile_id FOREIGN KEY (property_profile_id) REFERENCES public.tb_property_profile(property_profile_id);
 h   ALTER TABLE ONLY public.tb_call_log_history DROP CONSTRAINT fk_tb_call_log_history_property_profile_id;
       public          postgres    false    4922    252    266            �           2606    21647 4   tb_call_log_history fk_tb_call_log_history_status_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_history
    ADD CONSTRAINT fk_tb_call_log_history_status_id FOREIGN KEY (status_id) REFERENCES public.tb_status(status_id);
 ^   ALTER TABLE ONLY public.tb_call_log_history DROP CONSTRAINT fk_tb_call_log_history_status_id;
       public          postgres    false    266    4936    261            M           2606    21398 "   tb_call_log fk_tb_call_log_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT fk_tb_call_log_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 L   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT fk_tb_call_log_lead_id;
       public          postgres    false    240    219    4906            N           2606    21403 .   tb_call_log fk_tb_call_log_property_profile_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT fk_tb_call_log_property_profile_id FOREIGN KEY (property_profile_id) REFERENCES public.tb_property_profile(property_profile_id);
 X   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT fk_tb_call_log_property_profile_id;
       public          postgres    false    219    4922    252            O           2606    21408 $   tb_call_log fk_tb_call_log_status_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT fk_tb_call_log_status_id FOREIGN KEY (status_id) REFERENCES public.tb_status(status_id);
 N   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT fk_tb_call_log_status_id;
       public          postgres    false    261    4936    219            R           2606    21413 $   tb_commune fk_tb_commune_district_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_commune
    ADD CONSTRAINT fk_tb_commune_district_id FOREIGN KEY (district_id) REFERENCES public.tb_district(district_id);
 N   ALTER TABLE ONLY public.tb_commune DROP CONSTRAINT fk_tb_commune_district_id;
       public          postgres    false    4902    238    223            S           2606    21418 8   tb_contact_channel fk_tb_contact_channel_channel_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel
    ADD CONSTRAINT fk_tb_contact_channel_channel_type_id FOREIGN KEY (channel_type_id) REFERENCES public.tb_channel_type(channel_type_id);
 b   ALTER TABLE ONLY public.tb_contact_channel DROP CONSTRAINT fk_tb_contact_channel_channel_type_id;
       public          postgres    false    224    4884    221            U           2606    21423 H   tb_contact_channel_history fk_tb_contact_channel_history_channel_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel_history
    ADD CONSTRAINT fk_tb_contact_channel_history_channel_type_id FOREIGN KEY (channel_type_id) REFERENCES public.tb_channel_type(channel_type_id);
 r   ALTER TABLE ONLY public.tb_contact_channel_history DROP CONSTRAINT fk_tb_contact_channel_history_channel_type_id;
       public          postgres    false    4884    226    221            V           2606    21428 @   tb_contact_channel_history fk_tb_contact_channel_history_menu_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel_history
    ADD CONSTRAINT fk_tb_contact_channel_history_menu_id FOREIGN KEY (menu_id) REFERENCES public.tb_menu(menu_id);
 j   ALTER TABLE ONLY public.tb_contact_channel_history DROP CONSTRAINT fk_tb_contact_channel_history_menu_id;
       public          postgres    false    244    226    4910            T           2606    21433 0   tb_contact_channel fk_tb_contact_channel_menu_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel
    ADD CONSTRAINT fk_tb_contact_channel_menu_id FOREIGN KEY (menu_id) REFERENCES public.tb_menu(menu_id);
 Z   ALTER TABLE ONLY public.tb_contact_channel DROP CONSTRAINT fk_tb_contact_channel_menu_id;
       public          postgres    false    244    4910    224            W           2606    21438 .   tb_contact_result fk_tb_contact_result_menu_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_result
    ADD CONSTRAINT fk_tb_contact_result_menu_id FOREIGN KEY (menu_id) REFERENCES public.tb_menu(menu_id);
 X   ALTER TABLE ONLY public.tb_contact_result DROP CONSTRAINT fk_tb_contact_result_menu_id;
       public          postgres    false    244    4910    228            X           2606    21443 7   tb_contact_value fk_tb_contact_value_contact_channel_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_value
    ADD CONSTRAINT fk_tb_contact_value_contact_channel_id FOREIGN KEY (contact_channel_id) REFERENCES public.tb_contact_channel(contact_channel_id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.tb_contact_value DROP CONSTRAINT fk_tb_contact_value_contact_channel_id;
       public          postgres    false    4888    230    224            Y           2606    21448 &   tb_district fk_tb_district_province_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_district
    ADD CONSTRAINT fk_tb_district_province_id FOREIGN KEY (province_id) REFERENCES public.tb_province(province_id);
 P   ALTER TABLE ONLY public.tb_district DROP CONSTRAINT fk_tb_district_province_id;
       public          postgres    false    256    238    4926            Z           2606    21453    tb_lead fk_tb_lead_business_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_business_id FOREIGN KEY (business_id) REFERENCES public.tb_business(business_id);
 H   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_business_id;
       public          postgres    false    217    240    4878            [           2606    21458    tb_lead fk_tb_lead_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 F   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_gender_id;
       public          postgres    false    240    4904    239            a           2606    21463 .   tb_lead_history fk_tb_lead_history_business_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_business_id FOREIGN KEY (business_id) REFERENCES public.tb_business(business_id);
 X   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_business_id;
       public          postgres    false    241    4878    217            b           2606    21468 3   tb_lead_history fk_tb_lead_history_current_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_current_staff_id FOREIGN KEY (current_staff_id) REFERENCES public.tb_staff(staff_id);
 ]   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_current_staff_id;
       public          postgres    false    241    260    4934            \           2606    21473 +   tb_lead fk_tb_lead_history_current_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_history_current_staff_id FOREIGN KEY (current_staff_id) REFERENCES public.tb_staff(staff_id);
 U   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_history_current_staff_id;
       public          postgres    false    240    4934    260            c           2606    21478 3   tb_lead_history fk_tb_lead_history_customer_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_customer_type_id FOREIGN KEY (customer_type_id) REFERENCES public.tb_customer_type(customer_type_id);
 ]   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_customer_type_id;
       public          postgres    false    4898    241    234            ]           2606    21483 +   tb_lead fk_tb_lead_history_customer_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_history_customer_type_id FOREIGN KEY (customer_type_id) REFERENCES public.tb_customer_type(customer_type_id);
 U   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_history_customer_type_id;
       public          postgres    false    4898    234    240            d           2606    21488 ,   tb_lead_history fk_tb_lead_history_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 V   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_gender_id;
       public          postgres    false    241    4904    239            e           2606    21493 3   tb_lead_history fk_tb_lead_history_initial_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_initial_staff_id FOREIGN KEY (initial_staff_id) REFERENCES public.tb_staff(staff_id);
 ]   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_initial_staff_id;
       public          postgres    false    241    4934    260            ^           2606    21498 +   tb_lead fk_tb_lead_history_initial_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_history_initial_staff_id FOREIGN KEY (initial_staff_id) REFERENCES public.tb_staff(staff_id);
 U   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_history_initial_staff_id;
       public          postgres    false    260    240    4934            f           2606    21503 1   tb_lead_history fk_tb_lead_history_lead_source_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_lead_source_id FOREIGN KEY (lead_source_id) REFERENCES public.tb_lead_source(lead_source_id);
 [   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_lead_source_id;
       public          postgres    false    242    241    4908            g           2606    21508 -   tb_lead_history fk_tb_lead_history_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 W   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_village_id;
       public          postgres    false    241    4940    263            _           2606    21513 !   tb_lead fk_tb_lead_lead_source_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_lead_source_id FOREIGN KEY (lead_source_id) REFERENCES public.tb_lead_source(lead_source_id);
 K   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_lead_source_id;
       public          postgres    false    242    240    4908            `           2606    21518    tb_lead fk_tb_lead_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 G   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_village_id;
       public          postgres    false    4940    263    240            j           2606    21523 &   tb_project_owner fk_tb_owner_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project_owner
    ADD CONSTRAINT fk_tb_owner_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 P   ALTER TABLE ONLY public.tb_project_owner DROP CONSTRAINT fk_tb_owner_gender_id;
       public          postgres    false    249    4904    239            k           2606    21528 '   tb_project_owner fk_tb_owner_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project_owner
    ADD CONSTRAINT fk_tb_owner_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 Q   ALTER TABLE ONLY public.tb_project_owner DROP CONSTRAINT fk_tb_owner_village_id;
       public          postgres    false    263    249    4940            h           2606    21533 %   tb_project fk_tb_project_developer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project
    ADD CONSTRAINT fk_tb_project_developer_id FOREIGN KEY (developer_id) REFERENCES public.tb_developer(developer_id);
 O   ALTER TABLE ONLY public.tb_project DROP CONSTRAINT fk_tb_project_developer_id;
       public          postgres    false    4900    248    236            i           2606    21538 #   tb_project fk_tb_project_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project
    ADD CONSTRAINT fk_tb_project_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 M   ALTER TABLE ONLY public.tb_project DROP CONSTRAINT fk_tb_project_village_id;
       public          postgres    false    4940    248    263            l           2606    21543 5   tb_property_profile fk_tb_property_profile_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_project_id FOREIGN KEY (project_id) REFERENCES public.tb_project(project_id);
 _   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_project_id;
       public          postgres    false    248    4918    252            m           2606    21548 ;   tb_property_profile fk_tb_property_profile_project_owner_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_project_owner_id FOREIGN KEY (project_owner_id) REFERENCES public.tb_project_owner(project_owner_id);
 e   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_project_owner_id;
       public          postgres    false    252    249    4920            n           2606    21553 ;   tb_property_profile fk_tb_property_profile_property_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_property_type_id FOREIGN KEY (property_type_id) REFERENCES public.tb_property_type(property_type_id);
 e   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_property_type_id;
       public          postgres    false    254    252    4924            o           2606    21558 5   tb_property_profile fk_tb_property_profile_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 _   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_village_id;
       public          postgres    false    252    263    4940            t           2606    21563    tb_staff fk_tb_staff_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_staff
    ADD CONSTRAINT fk_tb_staff_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 H   ALTER TABLE ONLY public.tb_staff DROP CONSTRAINT fk_tb_staff_gender_id;
       public          postgres    false    239    260    4904            u           2606    21568    tb_staff fk_tb_staff_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_staff
    ADD CONSTRAINT fk_tb_staff_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 I   ALTER TABLE ONLY public.tb_staff DROP CONSTRAINT fk_tb_staff_village_id;
       public          postgres    false    260    263    4940            v           2606    21573 #   tb_village fk_tb_village_commune_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_village
    ADD CONSTRAINT fk_tb_village_commune_id FOREIGN KEY (commune_id) REFERENCES public.tb_commune(commune_id);
 M   ALTER TABLE ONLY public.tb_village DROP CONSTRAINT fk_tb_village_commune_id;
       public          postgres    false    4886    263    223                  x��ks�Hv(�Y���wf�
�|gr�3�.��ޞq���z7�
J���HIuw����f&�L���+� UOE�
����<����_~��������f�]�}Znoϫw����w������j>GW?lv����Ǘ�~��|'J��
���O/ww��������0����O?��_~z���۔�M��y��X%2e�G*�G��n���K������V|��#� ^���6�і�T%���,���}�Ϗ��������Q�N�Z|����N�bu=��_|���y����ٚ����ַ���N������S<�����2bʰ9C��Δ�#^�JE�3�Ơ��c��g�ÓF���`Br� 4m�'�N��%,A5�ѿ���M��mA-�D�Sٝ6Ë�+e�D�Cc6'*Ἳ�Aq
�&S�Bܠ6�Xei4?xB3�ߍ4m$q-t'��J&PA�6�8�28M�~hpA܉2��2J)�
��?��z����i�~�����o}����q�a��8e��OK�����b�q�?��z�I�p��_k)GQ�����o����(M�+��2Ѥ,P����D�4b��}Zl\6bͼ"���0�P�������a�q��qE(r��Pƺ��6z��0Ux%S�2b8�ߴb:W��X��s��%*��N��q:�h��!jP�0۽�fXQ}ۥJ5�9^����z��fYF�
ŉ��5����9����p��O�s�K(� m���2ĽS&Xv�I���R%]KPR�Y������emyۋ��I�/T9x�R�Ņ��R+��<�ځ�������;�z*	蜊�B:~`�ʭ+A������|�n~Y��}`)$9��8!ҝ��
1"�G�UJ	vJ
o����`�T��y�ӊ��� ?>�U�h	�:��Ss��"�5\�i
Q�B���}���ž�-�)%4�R1G4�	�M���~�a��_n�?���珛��f��df��|Z������k�O�~��ys�9�6͔�pd4�h������Y������-����x������+�'-�\�7�Cy0�1O0��|����z�5e�2���6�ㅖ���� tB�V)CI*�����h���h2ڐO��>�j'S�\�
YGg4�|G�M��_5r�_W������n�ݷ�ţ~�����7��� i��d%�H�z�& M*���$eUοb�3PoSE#ӗ�������l������~7��h�V����Y�R�I� �:�Ų�8t�Xj��U�p�A(�T�Ĳ��fLu+r�f��nxy|��9�U�GN�`V�5,�Q'e��Ψ�=P
] �c�{D���Y���d��@͔��T"�P�0����X&b���Uus9�<M���*
#م�x9g$A��j������&R5���:�����=+-��D��L�S�p^h/޳�bhȏ��$�E@8�*�h�^�O*`S�`W��*����L^f�W�[��W�+R
�Y� �Y�-sEQ�>>�54���4|�Ҋz�qX�k5h.����'��n��s�}�tQW胔z6I+���+��]���J�-6 ��ll$�-�@��A`�����8��_t����5�H�I�"��U�2`1(��rZ�pZ���q��;���D�<��n�)�����F?�iB=n�7�'����rv�Y�w����i�N��*_P��"J(Z�����L�U��឵�J�f�P��Ԉ�$E��&�v%�w�D��-P2�+�\��"<->-5��K-x�_���+}�����bk.�v���'���;���Ն��u&�;�C$��L�M���s\��ָ�٦�-�܈$�5��t��j[��"��ζ%=�u�9��ɣ�� �k�t�$n�]�N2g8Q�*[�*I�qw��\j�=IRZX�r��ɓ}�� ��ݼlg�ܤ����n��unX��_47��Fv�y��-$�x��/�����ۀx��P�ղ����EYP$O�I�(Md���:���L�>��RU-k%X��J��EFJ� Q�-�������L:e?e�&��T�*5\�@���C�S�U8��k��*�9�nH��|C�3S���R�3@�d$�������܎��*a����W�
VM���tE��07��T݄��~{�D���J݀�t���T:0a{N&0 (��C9��n�ɒ����j�n"��\C�;�{ ����U͢t}�m&���D_[ <���.c�kar�%��|i5��Ew��!��h5G-�	Ҵ�aQ5*��	�(�K��%�F��vc(tif�(�͉@��]�� 4�4�
RWr�ZM��	Ɣ�:ZM�{u�
�g4*1f��l�u����Sw�-�h�<�GP��1Kd�>�,1�jk)��+XC8J�<����I��G��ȹ��G���6x �⿠%I�<N<��_J�E��ʰ9�.N�I��F���^ʒ�r"u�_e��b�4@�~���"7Ձ�R���[��ME�-{ɺ�J%k�1eWZ�^�v!-[���PU���TXj���(��@�Rdf�v�AÇ������K� �1?��pUU�VG�W��@xK��#|�F�N�Z��P+��I���`�.�A)�le#`&eAK�R��ch�H����*� ���@��6F,��Vt�ѿ��2� ������C�N�%�t<�&$ͯ��;s�aD�v�[��`H��8U㆔E�k�7Rx�~Xm�n��jw��~X��?���Y��k�.�u�]X��040
\J�ax���-Rdp�q����ʁL�W�1� ���߬�0Xpx&��582 �ۗ��A�V�ʃ�O�f���z��r{�1�S���|5���X$���ʆ:.dL�aD���،�J9)��6���&%[�3��>4s�^������b�M�Ǣ�n1�@Z;xF��c��$emòF�7L��PcI��n�j�=7 ի[�A���H����2(�q a8��o������fq�V{��M�����v/�F���r��h?��gfy�*�a	h|K U�i#���4��C�!�7LO�P�CZ%#��B��a�R���m��R��׮��:M_��G��<a�ӹD�_Z�Uu�ON��Q=qb�^:�#n~l�8���Ͳ5 ��Ò��f�ؠ�+���ǹnIo ��a̔+4�:�������[����[V�udS�������ܾN�:ʀ�f��)ԆAkÓ[$iM�u���Yw$7�*-��=���vn�(»a�YLNV���3��_��0�l{P�K�U`�:���D�����1�O�ς�����|��� q�Q�'\�&fv����
ҿ�J+��
���c�/�2�C�WW��7]�n�c�Vf4&���@���#PZ(��2�n�ǽ&��L��6q6���p7�}DwQ�!�>qk[Qܑ`h����vD��H���>�����.��*����c�R?�N�C�>�b��UB���%��b�o�����r����W�~��l����~��li�5[�g����b;��߯;~����(n<�Gp�S@�^�k��T1X����2�5�����ы��Z�r����������g�����ؒ���?�u@��A�J%�I���Ο�qT������73�/���W����ez+W�	�%�-�F.����!�� t�c�l�UL�.��Sg�)h����r�^�z/��妡�W^� h��{xYߙ�ř)U2��]���� U����#q
-	��$��;�
S.K܍�?=�ǋnx,��J1<�,����Vr`圈D�
�d!AZ�4�҄������<����L�Aj`i�p[�ǳ	h�.t���y<U�p�Z���^��K�x���.47.*q4��@�'���$@sjh��@�k4\���� �wϤV%i��9�9�4�hB��͞Grhe��W4T��IA�Uam��
�q��2xrV<����|��(�]gf˃�*ˏl��~S�d�/_|Xn������ve�̱�(Xw3�Xh���k?    �����:ԫڈ4���ď�eBQ[�qB�f*�Ŝ�ᙚuv`xYl
��2B`7�(^���e�T�y))�{��� 􈰪"�T�y/"|	�׌��W�G��P��0\�f��ϲP��Ԃ���ȨC�ɋ�J*=&LùL+,��r��b͕nB�0�G��u|�X�{�s�
Ck��D ���J�e�nr#��bꨀ6o�> ��^��˾�C��c��B#�]ht,��=��7"�������<x:X8F�P��R�V�auʋ7��Gw�F�:�}�Z�Ϟ��jMˢ����r7ó��V�l�����n_����R?2�j�e��r��]_϶������O�P�	xbX0i#�v_�YG�N���Ro-DD�)��:
�B9D��L���¡r��1J�+\�$J̠	�v:ʃ�t?i���^0+V������d��c�h D���"q��X��\e3�?������:jDNl��rɓ-�nK�����]�i`�ЂC�2c�3�B�\m�����~~�}\�%�̭�>I�*�dT�Y,xV�0��4(D�!�f�p1�#�1�g��B��c��c��徸>�ŭVe��������F} 6����z�i��4��4J+c�<|�)�ƍ#�et��#�P2��T��((C��45M�z�����pkF�����n�)�g�qH5�$��� ^n�¶
uD����� �rF+��o`������DyB|��F3|�mkZ0{
�J\�VA�!F�L�^���O�3��w�U:#]���z/�A�\m����^�CKg���~�A�g��o���U��<n���1���=��Q�r(T��u���j�-�����0 �c����}�Xz�c�
��
���.�����H�R����\��T4�MϬ�mm�XF,��.�"�$H�jK���;��E�I�mm��0� <��7桖��E'�܁V��h��0��"tv>#k��@F%$-�f��[׎yc�D4h��9��f(�0,�϶Ψ`�;P�χȪ>����>&�Z?�����b�%�a�]�5/��,�(��0RÌ��tN�be�Yfu2|�2�1�WΌ���	q���w\U�V�'.�=�U���<�>����Z�Z��Y��w{��y�����{�v
����.w/������r�/��C@˄�ؙ6��0 ��bB�|�(�^¡9�=�C���8��/��֘G(�4�����P��ћ�"BQg3�m���
��Ю��U(P7S��pߺ "�+6zl�'6��yx#�Xr�I���ɀ���w�����nRzT���˳V���1<T/6^��Ӄ��w�!?�l��>m̴���T0��<�<�w����z����伴�ߙ��-i���|�p|i��@�2N6�'�km��1��%�(��[K8��F,��o?$X8s�f��XE�ލ��@��Zh]D�V�n@���6`�J(>)��cչ��W�?<506��3u�Ð�����|��*D�F@�m�) E'!�*>��Jx�`l��+iU�CY_-#Vjh��t��$��E(�l�Hr�^w��e��
.
�L�N�l�e���f@;�Հ�{\e�vH2	�rM�	I��Q5B�n�f4k�3�HC��;�4;��s�j�ENz���#<16Z𱎍n�a���s}P�YHI�KTǽ	�R�B��ZﷇP&����� C��Q��G$@��@4|3��0����&*�e��P?a����24S���Qf��ރi=����1>O����K_.Ƴ:�o��\���b34(��@��D�N'c�a3�-�
�ຽ$���3N[SR�*���{��s�0j���fv��K���y�!�����cPQ�B%O�nP�����)@��-#M��a�O����j�mM�n��j��n%x�n~Y�kf��/�N�D�&ӧ�9N�K�P`m�e
Kꠍ��o��u6-�o9!i˥���ΐK��L:���l�f���b�|�6[U�Y����#�0�AVd/�Y4��&:��&�x�R�
�ax&․W�����z��/C�W��G�̾/�@�6/�����^�SS���ɡo |�&���@�� ���A����, ������Lћ��o����i	��8��v:�A��ܸ�E K[��݈B�B����S��IP���=U]Ye���<��{n�Zp���쌀�
ύ˱p�v��W��ew�e���D	w�pˎ����=J���ʏ��V�aD���6��ύK�9�%�n�g���1NO�2��+�*;�K(���Wl��!�K�Wb  l�P�^��bӀ�If���ZL��d(��x�"�$��#b�����X��� ��D��	8�ܬ�%7���q��'�����s���ؖQ�f��7{�	��&����WU1�"A�sz]h+8�ӴX9���B�&�2�.��1�*5�(��D��r���ɀj~���&"�ȝ):����8lT�/���s�B�W��j5G(��C=��u����CNQ�M����uP��LDEAݢ0������� �i��#ng�fņ�jp��xP�1>J�+����A��m &��:s	��Y�lW��jp��>�ϥ�K��a��J4e%�\�5@��6�%�	ID�.r�����%\3�+4J$�n��%�>u[�Z>'��Ź�� ��>��T勗��>#�n"���壙,�vNIM�U3ũQD{�y�����k��R��U9���x��iՈ��SN�Εi�.֪�<3^ӧҊ�ډS	j�Y܅��r�UkzL�ͥ����WnR.�#/ ����o{����Z�Y�}SuM��+�X&��E*��z�ZQ?٭�� �R�`�\l�>ޘ�9��~`'��d���Ҧiy�`�e�����jq�}��,?[���eKљ���N�����AoZ�4
��`L�v�߮􋽌K�ܰ��ͯ�����ο?^pA ��Q�͖ �d�!19b��;�bd1,ߛF��Pg|o�CP"#���	c5CwZ�T����FK�t���lt�	�����*;*ч�x7�n�	���	�����S�ejt�	��L��Q���Hx�US�H:ch��T42�ua*�Lm�^*&�m�ZYCS������F�h��e"����.<�9[�jWTL�[�aU��2}\[8��� Hխn�TB���F��.L���������u*��G��s�a��H��ID�I�����L�N�ǿ�M�}��ln7y1��0�Z%�X <S�e�vR=���_ KT�G�.h-F��d���?IP����0մ/��]}����?�����rq�uF�+��z;昘B?F�&����z>��(U%�e>��܆��� n�Q�H��N��H��IjdJ�P�(�Z�ײU&ʉ��	����-:F�?�	������#P��G&L2
�ԅI�6�
�阱�Z�7;���̓���z
���UŞ%
qo �z�n�`-��y'4er�P����F¾u��kF櫿��qXyh�ۤ��i�u��F6X�0t
�����Q�D"�K����ġ|%f�5�������ƫƅ�@��~�\g����*��$���,��$�9	�:���X��FSµkN!�k��ҡ�$�^�\&BUjW�W�6�.	��ڕ�.NF雭��������'��,�8�+n��q����[M����Q��Q��r��jc���(UaMط��`B"'�[�I�(uXB�Pˉ�d����6u��� 99y�5L���Yh^s3�L���ڟ��TZ5�?c3�H��q�&U�Ư%_��)2*A���}k�V�+(�ǵ]�t�I�u�X�MFUV]�����Mط���=���;��b6ɴn�G+�
;j�V���l�lj¾=[�`SF�_G1�dZ��i��k(1��0кxX=.w�^�7����7���gƗ�M����S�`�1i��T�J�2ǭ/��L���@��2п"����$?�E>��;u����>��N���c�i���30�vz)<�w8|U���@�4�g=����$� ��*(�0q� j�6(_�    !x�prZ�;�h�Z(&�����1����U@�ؔD���i�|�}6��Ʊ)� ���$�Ǳ)Ih�!f�c}o��	����x���x�xZT�S�ȣ�ݏh�IN�2���v�g����2���l�ʩ��ǣ��4^5��ڲ�sS����^�Q"yM� ��,P�ɳ[��N���,�u(�af8����Gױ%�W�Ȑ����&*�ڕG�8dw��»�γ��M�Rt<�̱@]�M��_-O��؂(ug��h��,�MD�hB�I�O��D���x�jp�!��B�t`�	8�9�b<T\�yJ�↧u�I��lJ�aF�W�y��LƱ��[��2a�op���EƱ�:�G��Y`�{N,7+��#�R�Fb�p��e�6c����s��04�F%C���-�$ݐxJ܂�C�:aI,��n%�lК��'�a�ٟ��t�Q�6�@Y�"#�Z��z�̃Z��Iŧ<AnJ��٠mi�p�nd��j�0E�������Y�P|6hۚ��y�a��Ar���V��~؄�%[0���B�٠m{�y�����T+���+�,R�VEÊ2u2%s�;+�u^�+�K�W�M)?�ZFL%�`,�dIn���N��Q
k$�0S�`A#������P�A�e�/��P�`X��223{Zu�NY�s�GB���T��Q��N;9�;z!V���v�(m�i�i����`�d�[�jI
��Y4�����
�U*��3)������{��JPg���P���Va�3	tb�����w�j�����S3�=�5�UX۳���F �0��kƵ��@-�]�1͂�Xy~�����46ᷖ���vlR�.��A#^�r('\������cy���������L� ]��lP~#��~Y=>�=Hqj�oV�ݾ����q������'������v����v���~�E3<�|�U��W�_����]�5�}^���c��533H�g���]H���Ls�G���m���oC��Ӡ�+7bL�2ec�=�X�6Eo��#Zu#Q�lW�,�Y��}wr�?��c�Y�������z{��&#����Qfg��r�a=���<�۬w���_x�t��~��D�+��ԥNy�m�����\�E=�<��c�7y��+	c�~�'K �~���=�UP	7��M����=��k"PKkό8��m	�}<�}(%� k��L������>�.G����!;��EE�}��bQ� ���m��h��06�GC=
ҭPa���Rb�G���⼹����p��9A5%�@��YjV¸M�_?�$A�g�lrϤ�R�X�P^�Ӓ���Ut��V]˧�U�eԵ����Ì��,̘&iJ��4������H�:�ݳ��.�O�?D+(�JD��cS���t���Ώ�|�3�,�#��oi��!8�т�d�аͥ����?��u�Ű1bI�}��??�
˨a�sqѪ0��f��6<�~$zu��lQ)rixb��ǜ�!fp���5�oi�EE�������Z? r4š�\hk"A��t��lK;+*�8[��¾�QB��C�z��Ǌ��$
�� ؑAbf՟Y�Cđ�إ!Rv�ZT1��:OUp]��\f\��H�4�x���jU���?'Y_��U���).VGͦ��ۋ��:ulR0���6�@c��C �Dv-�t��� .Za�Y-�fi�w����1O=/Y����˒)����"i����]�"�^v��,��"��{'��@��3
Ʉ�^Ķ�5�aLEvVz�b �_�� ���@��@E���?1cDX5f��6�Gg�ƅ��棃�ьB��}E���C��/�5X�FW2A"���/7>�v��yj+Z�B
��+��0�E�C?0ue vC�,�5�����/DA�;C���X�N�C��ԜS�>hF��p �s|*��l,@[6C�Pk���j��7Iz���i�&�;�/�&-(�K�5v�.�a�)���q����e�J��o��W�=�(#\y)��	�Tpf�.*��{s�EwnT��w����2n��� ������������6�6� g������a�x����<o��ƣO]]pr��̞��x|Y���6�/O��N�1�<�#�h�b�J�T�ͬ��{|q��܌�m2g�p�*�ٜ�D���4��ѧ������ ��b�C���K�?C�+ɪy�;�w�5��n2��ѧ��b��z.���}�"C�͒�z�4��j҉�f�=�wD�O;Vå�9�|��0.���Z�mr^�kڙ״���uS�^<���ְ�Ψ��0xM@�K��Jq��6�)���FA��ƺZ<���T!ةbͪ��a���T�1ORqT��.l�;�7�U_�$��H��tly�� fFe��K���!���#��/��k8y�xt�.�ү�[޿l7 �{YZo~]��u���g�����b裿�U���D���P��%UXeF�'}�ICi_<:�.O����d���@�
6H��Pd�!���dݮ�į��D69	̅ib�T_��K���Dx��(h�4	�rɨ"�uh�h�Jr6GZC��,^�	h�xP�4���2<�+�a��ݾ�Vk3P �)�ho��tf�rj�j���2��YF�������7�v4�
^�	���Z^�!0�S_�_��ba|ĩ�ȱ��� ��
��vj��W������RF��V|��,`�H�1�&i';����ck���3
���i�2��|�.�,����xW�Ί�&W�/Ϗ�;����%�\R�e��R�`^���ơ���r��A}���� t��w<=���5.���M��x�n��2Ywڝ��΁����ρ��ۉ�Y�r�Dӗ�a.�����>��W�*�8�G���s c�`������؆]=��TRЋ��Y�,9���	a��)rh�<M�Ց(�2�����xưx�c ^<WAd�ŧ���qb���΅�Htt�M�wxP�������wK�7+R�e1_��
	jK1�]��\��L�'�~�q��Z<�FVF/�7�����CJK�^��� ����&p�������y�R�Ŷ}�;N~�(޷���m�4УFb�2USȷ!10���\ܿ�m^�w��N�6�{��3��0�?A�����&��0pʏ����tBKȊ09��MQ�2B����X��(�K�Rxm�0�U�w	���S��@m���(D0��{���OL5%5Fe21LcAc��S�4��/�1P���pu>��0��,�8��:�)��v��DPR��|�⫨�o������~����v�y�e�͔�:]Y��SQ]������|������ �J�/��P�(�:��5c���o�I��ՁwB(�T� j��^�0�:""�:n�11�/�AAM1K&+�t�����֗��DL뫙���A.e2q�wD���2V݇1�x�M���s*��:pk�G����`0��P�����$�w�Pk_L���J0�7�de�Z�2u(�p$&dPxQCL�4�bFZY	F�F!B{Y���LX���W`�+��=�$!hXO�*0�]��f�a���B����~�ܾ5�	8���r��)0�P�.˰��>4l>|Ryi>���}#��p���U��\5W2$s�CxY�!Va��и�S�}s�ӈ��r���J���@�-�b𮀡�+���03�*[�^���Z�o�]n/TW��N��E5��>�Y��Ё�MJВ�N�j�c�B��u'���? �Th���v,>��.\�F)7��<hx���Æ�(���vz��!�"��a��;�<�z��M�D�A��0���|�{^�g�Ր�&�t�^����!a�ܥ��TM�)>��l��^�p�O#%�T��cx���G���/��]�a�WK�(*���PSP��`���Y�� �h����N�3}��$\ۙl�:T����������_�Q�ֺiXc��γw�6t�ȫF�y�O��    Px��Z:u3��!HXV�,M��dس�k'���z�� NS,�	�T,��Ɋ�fv����i�X�Ah��i�3�(���M���/<;�2�@X���	r��xZ7Ya����,̘$��&��0[q�1yZ7aa����D��i�ԁ�
J�f0��ƫZ�l�Vl�Z7�t����V�#��lmi��4�z��6O��Y�H�*����B���u��AS,�� ��5ӥJ�������V2U���.�Uy�6Ii?�Ċ���G5��Ơ��i���RPzg���ԃó�=���Y;��)������GD��5'� �(D��j��w���+��
JAi�ќЄ+� ����S6��-�1N�;Y���P����4�ܥ[��Q�,����{�J<8كT��-� Ae�~�(���>�<`��.��C`]�A#��v��X�w�@�Qȍ~�#�3��_V�a�!��"����D�Aӵ�vd����m�.������)��rA���F��՟�W��7OO�������4��$��1�}��Z5��rNx�Sw1��?~���"L}�E��pNq�����i�Fy��(�+S�]	?�����̵~cJ��9��Έ;��;>n��n�v�y:|���|����i��\ԏ]�g�^�u�?����)6�f����9��I-&;R��[w��t�}!P2U���N:��907 ���X��'n����*��o��+�y�&f����M�Yj�rF?K+G^�@���d���jq��~X���9��DDS_�d�ٟ�Τ������+��}�}��p�i˿j��ӯ�Z'���hL�/�_�X/�.H]�H���� ��N�tV
iNf�ӏ��l���Y3�}�/'�I��Ljy��l��}���[M��s���.W�v�vy��ç��_�9a필�>=*I]�<o\X�9�T�5	�J)arؠu�ڒ1��6��)(ęs��<�A�(lj��`qV���R���q��&?䔀���+x����t8o�U`�]��x�*W��/�}���W2���P�	c�>�pD�C�����!�O�>2xH!���I��-�K�&�qxA̐؅�Jh��<�	��HNN 99�d�8������N`�J�
?�5�yVʜ�.̇�s�q���`c�҉ W]Fk�Fbط�1�sL!�C�pJU���V�����U��f{�H=�W+�kuɚ#]C�Zkr��)��(�+����Jz����j�Z�����k��&+o!5�쇟u���&iZHbu����^஡�Zy\kz
�F���~,��|!
�7�9!�~6�@����gk
,���D]\��i.(�� ��lK)�l���MAL�+�v��H���!u�-k)<q44Z�A�8N��a�����A���?�����/��"�Ij)蜙��N�����.^yxY��T����CТ
�E�ɠ_��iq�畯�'\ed��!�M����3E@�U,fd�ϻ��� �<}Xmw���3 �JO���8������r}�"��Q�OK�3f�����v��lC���T#b��f�*:N��Ǘϋ��i�֤2o��OϏ���Iq%�'f�Z�?�8o�7�}ǯ)}Hc�����
�����vk:K7{��q��ܼl�����|Dl��yEM�U'�����gD���$��%D=���B�&F�i�@��ZEX�@MTX�"�Uw���1l܂���o9A3�L[!R	/�M�`t������œ~���+�M���?&�����r|R�X&Q�6�:�	e�j��d{<��Z��|# ��Z����H~ȭ`���.}�D�-i����S�M&�(&D>U��Č�
�)(���V ��}��~.��ڙ2V�v�_������n_���lP6���`���FU`x�P"]��fҚ�\����� _Y���v2��UU��4T8WJ�2���q�Be�4��� ���t`=��{DE�����-�)�\�NAk�^��9#���jEgғ�'������w������]�!<v?T�A1L/%���H/��0�;'�
��fu�Qc�Иּ�1�xi�(��1ݹmҴƤƢ &��-���X���(�� ӝ�Q�DQHeOK��PˠC���C�Z�LR��.'��j�䇃Gn�uޑ�5V$*��p �i�-��dtPX�C�G@:��)���}�Q�r@!$ORT�����ny��|j�D�%/|�J�j�d�>.��A����`|&>��Iʻ85j$���j�	xz#s��2���$?�)���@�T`<�*�F��A�*<�~��)��O��/���C�S֟����fn!�2���f���%cl��l!?	F����F!� �IN&��O�&�,�#擊|��W�}������ڇA�Ǟ�O�t��e�D�40c�RS|�S_tQ3:�>�ɂ�"��U�x��Z����5s���ǘ�MH�R��M0� �1��<���~#�c��VT����������J��j>��֜�'8��� ~cF��xCB @����6�jF�S&��!vf%/�%��DW%_U\��wbǮ��"4gB��c�j��R��};���35"+vqG�DVU
�L��"V�<�,���Id�,�b�7���"Hf���	x��P7W�?�Ž� SUcj}���o��]�O�=�[��@�M!���-�+X��.s ���/$��$W��pÙ�,�*���Ù�\풋!~�������۪a�����p?�\uQ����}�_f'�e���Ԝ����|�M��",ZJ��h�/����hi!C۠Ԝ�	eS'�y�qE�<H��n��]��gOb�-域W���&�~�~�ݽ��2�[Ci�
�>C�����Ym�o��_�e����*����p���֊Ҁ�L5چ�V��п�5����Ԣբ�@�`�[&��*�"Z Z��
&��X%$��|���2Z\��T���*�Sq҇v��[�b'�A��	��s�����w>`�Sq�MA�����6�N�.x�[U�n����&�}*:��/���fЗ��q��p��L�q��<��:-�6B2�<T&Mƙu]��F�i��o��=Vj`5I~��+i���x����.�vN��c��5g<�;
������^�EKr��� �͂��+L�^�p���h8"��[��X�e'������@t�>�o~H㧽�$5�R�᭩?��Q�*�!��JJ`���l���}�5+DŽ������q	v+I��gu�c��EW�{Υ{b%���H����@[��Å6��o�}�����?��G��NbM5
';n��oe����(0�J�Y���t3�{3b崚Nȸ7�8m��M��<*���0�@�'��̳�ce��H����a��y�>��np.�oP��B�tn1�f��1���y'��6���ξvq=�����$Y�_�S��ޤ����=�;�����t�}X�{{X�O:w'E�Pƅ�.m�����,������J?��'�޴�f�?,[h�,���S����~���w��%�����f��"I�ݷ�e�~>H��o�� �ť�op��Rt\)P��ҷ���J�1
� y���m�d�^�l�[оV�4<�!�)N���6��̄ү�/�D�ڶ���E_���Z�]�3?]�?���!�����)���0x=n(�BZ�I�ݦ,!M2o�y��k%��俚o�%�<rR\#��r-�dȔI�@(A�_L�z���V$m �!S&��6)��l��B�@Y�O��%`�j4N�El��wNd�K�"s<�V��Ԥ�Z��8����|	j������A����H$I���+ef W�'���"��B�+ygpq2��w��4ôR��i�X�IT��E���	��_&Y4ɢ*Y�b�i��ngYT���/��,V�FjG6L1l[NM��,�dQ�,���i��]e�:�\�ߜ:'��J������*���$�&a4	�*a+Y�tw;/<�v��7��\���
��4�޴���S>	�IM¨B�
�7���O��    ����e�/N��j��������~3��������d�pY�K�GX��&�TƝ�q���bee5�LΩJ��IM:vұU:6VV���~�:vR�����ֺ�PWn~?���S8R@|��fE>�vR@��С�RqMw��T@�7cr�}Y����`Ȫ\�B�b���"U$%�Jٮ;��-_��Ĥ$�(�X9Ҧ�;)�/CZ��.���x��5Q��1C��-�tĤ#�tD��u���{���Y�Үf���X��Q�<Z���P���	I���I M�J EK_7�]x�Ձ�J��_�Wwf�ç��|��/�ͣ~��-'�靆}e��oo�{��?}��%H�Y�ೢ�9jVh��UC�KIRB<���0�m�s�>tstCb(*�Ps4yfi ��jţ夹��#�V�`4)�IqN��JqF�I7���gՌ��l�n��������Vijm9�:�'96ɱ
9&��6�n��awɕH"Z����+	��$�&�T)������X��g9� ��c�2="Ea=��?8I�L�$�.X���H��ƫ;��c�h@�~�D�����#�Nq�I�Mr�J�EJ5����!b`���1����(���R=W�s�0j��sB�)OX:��gHG��'	u�J��.*{_�|��O٥��ln����L��XB;�"AR��mP5Q�����N)h�1v<kȂ�&�C۪Ŝ�DR<h[�P�.�dA[(4s��D���mR��"m�Hez���U�20�j�<OR�&+I/)ϰ��
[�c�,A�Ez%>����l�z)V���6w+�6ʗL�����~��{��L�� �w�o֦�!��W(�r4�ҒD��"��bs����%I���5��M���C�vߖp��ՙ��Q��
�cA�8ar�'�>)�V
���.Ӕ�������og����nՏ˻������������]���\�T��	9OY"�$��T�$���Q���ƻ�9� ���+�m���O3b(�v�s��;B�������H{nn���Jˈ
T�AC�F������Ȑ���Zɜ�b�0|SB�Z~,&��p�Q���U-[�<В�S��br0�{-� !������U@���,���H�R2��w#�;�xfh�ck*�)NR�[��J҄���=�d�O��d��X�x���:Q��1#����y[D�F��No�$հ�� >��Ӗa ���ߐk�ǀ��R��Au�9��ygZ���ġ������cd4�C�Qԡ���L�	M���C��31��>C�\V��+H����P�^�+-+��Y�*��!�߳�\9�E�c�B+�2U_r�1&(���!m� �e$P��Q(6�<�W%���3�i@��T)�/qԠ'Á!3�M�h`�Er6��9ܒS�Y�8j������$Tk3�Q��!��g���Q�����2lt�b��$��l@����2��+��H3�",���[X,,�`�!���Ҁ�P��1��D�ЋƬј�.Ab&a���.3P'ITD�M���*3�8�$�Ҁ4�3���[F�\�ĴBhp��v*�5�i�4�*4�e	(��,�B	
����N堩UIb!MH�*P��Q�1�����F7�(%5����A��U&Zٔh��_Q�U�����۹�Q��y����QZ���5�>�@c���n�R0ث�SD�6��������߾� ���x��:ChN��c$��Gc:��N7�ܨl<pƔ�t��ng� ���7J҈��J)I`����D<��Ft�n'3��ET�>���J��%C�)r�0�
�,ȯ߱�x���o��o�����e{��J���e�Zk��'����7%c7{Kf�=�v���Kke_����v��ݽ</273?jj۔��v�<�4oW�ys���mW��/�.��>��+m��Bje���^�{^b��W��W���W�������z�]e�lc�]v6mI�����\o�o�7���+T��bō��� ���6}�)�HIH�����9K��`eA���=�LtN�9%�"��'�x9�Qҳ\�����fo=�Ok��j�ekQ���v��yq�֋{�V��������ɻ·�8�]7;f��*�V��<>pO�qO�q0��%�\���Y�JS$�T�E��I�^��U𖿸7�P�?vA�W�_z	�+�hĤ��T�I�� <`ǲ��EL�6"�.���"̕��K�C堑��m�F��m�`ؤx�*�#�m�q���a�
˥
v	xq\q8��GW'��f��i*���ݨ���f�\}X�^�rW�ç���7%ax�����������1<3������6���b��u��g��o��?j:�Z���U���ТT!Z�c6�>n>�����yf�Uz��Ij���L!M��l�]z�C�H}�LJ\M9�I�Oj=L��~H�K~F�^���
N�����h�8�Y~*J��Lp������"jM������މ����	聉>�;�ͱLS��u	�)��j$#82=�埲�_3�U��3y�|��L�	���3��tp�|�C�A���3�{�;���z�L����
$� �s*�Hoa�2E��J`&��:%���B	לj��OZp�����v?{���Ҟ9�)"�6V.�[<��Ք�l!���"bS�s2�&�"�D��
*D�L5��kWW��a>'8I�+D3�bD,0
W�9Ӣ��)\�����|5�̬T;��Wޮ���ϧ��Z�=??���Ƴ�Fb�_nwof�/������1ro��3cof��Z��e�5�A�~9�j2y��.)xL�S0#s��<M!���K���ؼP���]qov�pXfZ �dU�v�Q`َ%R�IVM�j�U�eU�&���=��B�r����:���8��j΁	�#U�N��8��7��9A���D
�2!Cv � )��4�|
�Ni�I�X��t�-�֩���%�[."y��,e:�0���"���!�&s�\"�k�tջ�˸zt�	���HA�Ќ4f04#d��.�5ex^�<S�Y.?Mi&�~]�?ξ�v�]i[���!�qy��ޗ��Ձ���nz�B�Ъ_��J�1�h�T�44ɴI�M2-T��\�j���eZ�N�����McԇP�&�v+v)Ue$I�'�o ;��-;>*�.�W�f�^����3�{�TL�ɧ�t���h4kQ��_�*BL���=�� ����c-
h����1!6�@9�%b��j��x؝V"�~�&�[M�퀜"�s0bb�k�5��T%��"JDL,7��y<���f�w6��61�au:�f�����"-���F
�<�	��Eˑg�M��)X0���H{7�u>'{]���^���w�T�(�B�r�pB64T����@�����ݙ�޽�E��� �j�9�"C����86����Ś�.1OP��S|�u���p�V�5���wOp(:a��^?L%j�r�6�IFxP��Ś�-I`���*¯G���$�'9�SNǚ��p��7��+62����IQ�j&�9�h�y�B��e}�yT�[y�$���"���t�/á."6ͣX���M�p��>��р�>ik\����96���h'kc�6�2k#ְ��K~Fk�{��N����)Ckr5�ڿD��$�$'	��#V_g�%���G�Xq�2NOW�99bRP\~5}V_�`��^���q�����	�kF^VO&��+VU)�6Y�&��	����T$1(>����s�C]�Ƞ�}Ьf�m@�L�h8K�o7I��%�w�d4p)�D���)d�ݑ���E�f��&��ߙ�o��}��}I�_#?������6��7���F��%�AW��笳��s����ҽ�DƩ*�����bNPB��!�1ȸM՝VÏ���[kg�;Q����z����Μ�����~�vfsf����D4��s��'ny��Q����O�k�s"�%M3c/�A�����RQ�|���!����n����J�-^�,�<Qr����J��qn�`������Aᦖ���Ă��    ���~�r�9nj=�	o��gUՄV�	7 GI�X�nS*O���ϓ����W��I��I����|� ����hEw�ҊDk�1�"�j�i7�;c�Dk�i�٨ֿl���b��F�W�:�H@����H~�P�z���=�eNh���7#��H~s�͞�f�7yUgkI��ԫ�(7�U,\3��)x9	�I��Q�l�ov[!���N?�<���͞6Z/{6�՜��^�q�_l?,�yA��
IشԢB8����9��B��\��p�h�D�
$ZÜ� wW)V[��Gs��%XP����]�ܵ��f�1��4�~~*������-d�%d�����ddgI#���n��z�=�p���ę�4�td͔��T�'�N�v����!n��Dn��_��E��N�$Ĉ����2K������P�ش{�����!o#e��nvwy��r���K^��M�Z.�,�Iʽ؍�K�4�C&��2�L��I�Nb��؍�Kj��=��B#������n�o�m[�6/��}��/&��o��y��_�?��/���o��v�_�>.�8l{Z��RW�Dc��X�&�T��M�dzN2p��=d`��҆�ݵ�Kf@�n�=��b*�`��������$�:++�p�;+��?� ��6�8+&-J���T����;&a5	��AX�J�4���J��=��βjX8T�$yh�����r4h7R����8�+�{z3���u�3�kY��(,�f��LR75E1~Fx�wY�F���>ֶ��^)L�)J���X۾����� G2��%�v	;�a`���K�Oo��=��9wTf_��kf�`�}��0TjixEB��^3*.:�T������ۙ{����-�?.�6����,~n;���T��+f8K��+��2y,�=���fZ�p�of�Ϛ�&A��&�j���T� �r�L�a�2u<R��B]3P��	S�nϓx�!�#�+4����o�ٲ ;o�G[��b����W%BO��	ר8��'AS�H��x�L�R8�M6i��4fa�5���є)��t����Lp��2"�(��>�+k�&�*�42?(��x{�����0Q�	kB8$ڦ4z�'�l�$A��mS1�����C�І�������)���'�`2
z�jE�nvgT�	+-�Wm�}��̿jx	J��;.�f�b��_} �H!Cѫ�6���p�N��s|�m�/�`��g�p�:����e_eĚ�^h�F�+��f��X�ӄ30���Q���ˈ8 ��d��C�<e	��� �����h��]0��L������T�Dd`�;�f�`�xW�ӱ�_ܺ����ח���Mrm�&�"�N��T՝�۟o2	{s���dp,� ��E�����F8X�Q�P%&�7��I��y*=�����u���D���T��k,�J�H6:'�4^p1�Fots#έj90G@���0�X:K\�������Ǎ������|�j�r>x�dB�2b��u��τT��`L�-t�͹�A3f��=->-5��������ݰ�ݷ�R�-�O� ��}�����ۖ4L҅=����&L���v����y���)��o�J�S�_�6
\4'�!��<�s�d�kԫ)o�@����
2�^߈K9J�XP)NR��l$,�V�J��~�����e�S|��5�w��͒�Q���i(�C:�x�j����c�=(�(��ݖyd�"c\=���U�
�Wx�D
]<C�<����r��Dvy�4ƽB�KRMyKň���^�4^J:�>X���S&�0�@�^#v�Q��c�aifc�+)�a�+�c�ԈI�--��z=9e�<5+�;�����H"�^�1�~�Lᕔ!0e�5����,��
OP��V���_V����bA�`tNٜ�	Uy2�B�"z����r��|��b6���BN�U*�p�v�{yܗ��e���Ծˢ���m��E��˴�Ǖ���r�_�?$�۷6x�4Ț��_I��yj�[n}}�I��R����~����{W�n��?�Yn�Xn�賕���r���|͜��������$�O��/��r����!fs�%����'���O��ُ˿�@��v���O��ԯ�1b��?�~���S��jD���3 DW����A��2�(�:Zhp��e��,IqIX��_�[y�d��)��V����F���A����Dɮ6~�.���"��:=#�.KM@V�1����>��Ġ՗�(���xϐY*Mq������.�)cad�;
�^�C�
h��9�\[6�=L�(�df�x��Ç�`Z��_�ڪ(�V|jC;��Ҙm��!`�XAj̼���lD���ca�",�ڤKiu��2��}�MUvl����jg�ͣ~���e���G�J(#=J�"��O����.��}X��n7�=1*'΀�~��	�#�9��z��f���z ,���A�`=�NOr9� --���y�!,a�:�l���N*""�)h���� n>����Z��)t�@M�1N�)��Wsn�Z����f;��a_%��_/�O�ͯ�7���r2w�B�թ��"��>��a+ï>%	Gr�����{3�	����+M�|ϕ�q��5~;MZ��j������Ga�e���F��/�����EumW~�K14�Z�Y�N�sӔC)��᙮!��~�R}W�_������g�Ϛ���6ۙ17�Q��Y���|�	�W�+{JY���@?�0FA��LkcӚK�t��v���'�r��y�̾��Y��d�4n��a&���߬2ʑ7�}�
���'|�^!>9h�/7)K<�\����i�yʸ���uɢ�4���u��B�=�S)���a��8�S�/�n˫�-Q�-MǪQ%叴��7�j��������Ɠ�Z���Q�L)�.WֳO�Ϧ�L�b�2��ç��ݜ��^Q���8ڢ��B5�`�!�J���{]�1j���X]�e�vV��-|F^�;�8
T���"�������6M7�Ro$��u��u�Yu"����!'��W�U�':9	*���t�aǚ ��?.L����������K� �R���^(���G����e�6�O�xn cT�Ȉ���`s��|W�A��E_�F�#�J��$�v,"�
u�y�����7�����Ieq=��PCl��	v\k���d��.��4�F���.�h5[y?�y�x��A����V3n^����?7�e�m�����F����a�Um����d�E��H�FGC,L�-=�Ϙd�k�<�/�t���Śy�)xc��W�=�6)� ��a��j����3�x�\fTԻ��Ю5,�W�ʁ4�J�n<�q�6��85]?x�:ax��X��+���Kv�.�2����#�;��~���^�B�j��~���6��0�%4ߵ&b��$4 ��d���~�&j��PQ��)��ݒ�!�X`��`�'Qx`����bށ���Q�$�ԋ�ĞQ"P�k��V��G�l.c�0Y��ex������M�q�������$���'�h�J���r�]��c��N)�(H���C�2�"�"�}J7ւ���o$��͒w�x� �^���J�<%e'��*es�����]N{�	�y���H��Zj�o"A����]N~ƃ�x9�v����op(���V`.a�� ��о�[�M���
�ރ=�~܅��B!Z�n����Ŧ��E\͓���B�n�8�m+8���N*-��6ny��M
�4�P#�ȡd�1*�]�03�S����DQih��b1�$.�Dq�-�1G��(���6D�Q��[�J��Fت�j3[ihy=�Ԅzy�����:�OF����Zia��(!E��`<��BjB�O=�ԡԧ��դ���2b's4��/_�u�Ob�o8P���Rv\�9B*Լ�&1ˋZ��n}�w��8�Ql���=�y���8�>V��%7m �/d�.�`�eN��n����<�r�X"٠;65��]�Ի�X��u��䪨�"����5.�sO:��ӁEDZE�5�Ķ*Q`�rqT�    ,�����py�Y"�����бP� /)bɨ#�vMT����;Mgk:���XyY��Z:�C����<�b��`��kQ�B��9V�2u��<���o��������{�3���.�� Elzv��Ƈz�8̗��顎rJzʱ('C��%Tr6?;؇7p?�_>.+m6�/��b�y���l,U��ЇH��ejt��	�.a�� ��"��1-6�R`w���N5W_�ņbFy��"�J�����ﾝ�f�6/�������Xz����B^�l�}�|�����G�ħ0CS�EԷ�BԎfۿ쪮H����8�8�=h+Bߩ�n�����Q��YR��3��5'u�8�ٻ�m}�����d%�F�B߭�u}�q�^/�����������������Tro9U|��4�XB������ve���K�]駟�8Л��l~��ҥ.���6�O��v���K���7�STI�?k��v��ݷ�24�������2�C��t�]�d�m��+���׼���!��A��0�P�,�Lr`�!�<S�+S9^�8ř����4���nN~��_ �OB�O�V	B%�3ΐ;�jV�3�Ix�-^�>.�N����b>� �������S.�I*Iwł'�2)�8���Ŀ2F|c����&ìf� ��^�c/�ΟP#$hN�W�]�M�`�#0�1����� ��R��pܐRC�E�Ŝ�91�|����4�@؉f��ZL�n�t#�b��Li�@i��.�;�4-"��d�{��<���|��4�i3��pe�����.�_|���Y���9B	/�N�`� �Pi�+�Cp�	�o��u�8b��~�٤��Z��6h%�HGiP\��æ��r E~�a�I�|}
�0D\�^dz�D�z�x9H��Y�	�cG��#?l~� "��u�}S�>���1ZhF�R4>3Ц��1�(�s/�/�#@��C�x�Ej�<�߇ Z_G�<E��	�i����6w+���\>���t���!RS�?�a��-�fF�L���t�������p�@��,uא�V��3/Mx1�zR����cZ�'���'��v��V�r��b@�P�BM�N���陁�-h,PE�w�шɿ��f�d�J2���+�hlCL_�n��ea����T�2R�����˽>H���$((���3�~�����T���x�����r�ù�y޵���V
0|�0N��z��7!���0s,��Mٝ��8���l<A=,W\m����4������n61�6��� �9��o�y}�L��>m37ٯv��~�|���#����"�jq�{����Yܿ���朷��b~of����q�r�4�Ύ�#3�IŽ `�WW�mۊ$��#��߬W�E��6j�E�B���~��e��f�j�����o�6n_����?o�s���x�95�ݟw�����s��z�|����i���}�؍����Ϗ�[�����#"!|����������W���?-�>m~?���v�qF'������b���^��&J�[�͓GW+�^��~�l����t'2�b�a�RdG ˥Ti�Q8u���$���J!�yzڬ�}�2z��&`Y~���i�.�-m���za���#��(d�I�*N�\/{�̸M`\YkϘ�Mfz=J�)K'j�;��{�KT�~�C���e�Z�/�	�|L�0�5r�a<��I�l�p�%IJ]&�)66�1g*���s����~U&�LV������(*.�e�
��^UN��L��&�|8rR4���!��'���*�u�_Y۞R��;��=��U�GWT�"$ԙ��W@զc��4�	{�T��c����i��Jh���&�v�y��-��� GۓD���hc5Ux��Ӑr7���]�&H�)�>H����):ϫ=߮���'}s��݋���n&gϋ�~�~�ݽ�ݾ�g�ۥ~dyj�������v���������{�C��b��ۗj���,��M��q�P�����@�՗T%eT�ǴK��i���f��ԹQu���t{�LV��?��UC�B'�ih:��8�g�B��R�g�s<��Ձ�,���z�&_WKi���D�.	E�D'X
��VCĪ(T���zQ	X�p�$�E^�����&�0��ma;��9�
�0j����T��\l��� �Ŝ�D�ιT�_,1�xOiU�E��량�����\~��)O(�y/^=��(_"������Pi��yt�������y��RN������N��O���ܐ���	z��y"�{�LM�4<�^�K��i[�_5�� ��>���k�4�17��H��|�^,1�Y����Q��WS.5�ِ�����ɯ��G�ԝSCWU��T�zLy�<9��t�J��3�Q��q�� 9;��ɤ�L�9)�1Miڰ4-k�O��:M{�wT:���+qÙL)
YD��^��P|j˽ܶ܈�OP��ܺ�9l~(��-]��"z5�!��$�M]�f��U� ���pD�N��0�:�y1V�D�4e i1��}��u��b�q�Ѫ�b�(D ��K��!�G	)�����%����p�h�Q���G�k\,��x/�;�|�A+�b�q�{U9��E&��#!�+ΐ���b��X�2_���«x�BTJП+�
2 ���D�3��^9�N)FUe$%�
��]є�O���'�z^&r'�+���}�jH~}�dm���f��e�<����<��
�LUQJ|�w�e���ܾ5���]���:A��G��z��M��DA����x��֧ɗai�y"h��sJ��gPuۗы�P�q�0ᧂz�l���$%Ӽ�a����m���U����������Ȕ�Ь.7��RgF��4�w[UoUF�4�\r|�wN��
f]s����˭r�\�9EKE|[$� �b�m�{��l�o�_rX�|rUGw�(�/����s��^5��0���B;ާ`�oFQ���.��E��)N�,�/����0@� �/!"�gZ�ޢA)�*��E�>K�R؞I�``����v�yV�e��g�d"M	;�8����*U�k��t$5��lϹ����7UQ�̜�r~�#��(g�H̑L���Ζ$�����R�i
݇��|����_9��u��)��:����ԥ<@��
ʠ��-'�z���ՠ��?֭	??��n�����lgL
٢���Cb�c���uz&%�
2jm��ԓ�L�(����fZ�Yឪ�"�Wy=��${Q,/:d�.-�dK�S��;��yu��]��IBv��LR:�l���@�����¹�찉R��ˌ�^iK�Cg}z?��T��!� o<�>�|ѳwz��ٜ�����-����.�Ϋ��(Z��Y1��#N[�����",Mx� ���XA4`OƯU7J9��rz"��k��L~�x9�����ke��R7�ԅ|H�v("�TF۾Æ3��hڿ �)�G4��0d�<OYK�k{�{�{ҏ�72�1�Y�/���'ʼFa�}��d��,��K�R����Y�D�igm�*��y2��d����ٷ��+ �8��Y�/�dd;Db���;[m�+ �8S�E�ԯ�7l������M?�%��c�N/.Ґ�]��t
Y���١ŰKiȦY_5AO��`"5#l�8V�n����ڞ%�SM�8\{��40�����R���w�l/��1��������/�%Q>%ތèq&y��[!����|��S^��
#.�0����NP���K���~Rx`��{(�,�,M�A*;P��(��%�q֭rxn�(��Ύ�ee��<4�N�'�����tY5��ƀ�7jf����}]��F�ݳ�W0��)�'33<�Y��6�VwI��ުvU�4Zc���K�F/�f�xK�`&0H�n��0222ND�Z��h(+-W���Z[gYiɎ$zD��e�ZE��	/�%� ���Մ��С}�2�U��Օ���ecOL&ݒ�g�ĝ8gʍ���7���Yn��ԥ��ݶ��=wQi��\���X&�z���S���aŁ��p>`�E��%g\?�}�����    �E�= ��IM�e7�4`5�Ј���W&��۠I����Ђ̖�H}�v��n`5���z�[NЪ�W{lӬ��n$���	\�W�{L��+W̒�����T��Z���g\��j���*#eZ���Y|2�"S_QsWյY�itW s�:~���+j�<�Ա�k���o[M� �Y��E;��]zA��cJŹj�	�֧`��/+fб1��]�,�3��C���i�~n9��#�0���t[s�'�&��	w�Ҝ��P�8}5�,X���P���P`d7�; +��0]����ʖ��֡��S�k���\���#@�44��:/y�(lDC%n��qe�z�|����g]�(�&f�Q;\���:7պ�0��ui)�R�F�Uc�����d�=k�D{��`��#���2>B<G�U��0R/2��l/�%'mQ��,�}1��R���^J��k��*M_�����`M��~��[���z�z����p5~�M>7�ضu���)B:l:H��!@�S;�L�K-�~����I�mfՋ�\�c��:U�����m�S2\^����>��{���K��ΩL��z o��Lѳ��Fԡ���զWۿY0�ߚ���A�m�[�=9�=����5��1����l,�撚��u��an�X������O�����>���>�t�/�f��w��������߃�����79�����}��v3���%��1G�c��	�tw�v����X�$s�s4�	U`�c��sP_�hF8����|p*���=�����̱s)6zp�G5�q��\�g�a�T�,p�Iː��q��/^��n]Y�t�qO;"V�[�40t+���/�\�]te,8*��ຄ�9u�g(GR�� �JNˠ�ٮ�b��������������󕹒&��m-��SjLL/|%^Xo��R�n�"��F4����RA^,T��]��\�f�8ә�k�;��+� ڽe��5�>V�/��oYj�7���kJ�Ѹ��6]�l�*ą�ދ�tm�K��Cʪ��F�{3me�|/~T����(Fյ�eL�x-]���^|�m�5#(&kL,�֫i[W�c�I�f ����: ��h�ȺLŦ�5b���'�4/ۈHiP�&�-d��ıAı�R�
Y��]�F�~E&���w�!�I�: �Uْ��)��t�qӥ��A4i��G2���_���Jw��%���ga4ܒ���'���9Qir͐��+�a%;rs��V���l3�˧}�hf��l�]9}l�n��k�m� ���.�)?��n�쿴��ۏxx�8�|y��p���C����ǯw�zw����n6����x�xsw�ts��O�O������(�"�I}�:��q�7��/�ӏ�k�IcQ��L����#8K�ZE~<uVz��O�E��8)��M�1Q�5�v�P���<�-��p��M>��B?UX���d���ɻzg�'|,�#z�P�W(�{hY��ϗ.Θ�
��|��Mx��꽊wc��ŠGRܜL�d��x�$0������y��f���T�dq�V
�%�M�
 t�Z~I(��_�v��#�u%3���"�镃�3Ը}�c��A'Z�B���.�#u��A�p�
&C�Q�� 4�>�'Qm �_{�o�&�$��<1�pį���&ߤGtqO��<���'�ܛ���w��������vw���w�^��Ts�ȻL�~�����T�/j?���ܦ�(��eSW�_�o���35�Y��G~���h����Z�V�C�� r����yΌ������k[p峪��ȕI�	)z7l��z��2 �+��4�lT����z�H8���&^`�/�������T��q݋M�@J��Fp2���<sC�R1	�Չ���5���7��ظʹ���7����?kN�ԤT4��7��U�2�Po��H �l"N#&n�<O ��+��o�&�@��.�M�@?�Ն��i/�W�Z�f[ɓ�����B�ꨱW&U�W���W�'�
_��|q��%lmϔ_���������s��A"�/��>�_�K{�3)XyKˀ�YB�����.d�i�7�Y=���U
�7��q�mg��T�t$����v�i��=t�4{\yۙ����~{�+o-�܃�)��.7!�f���/��nįB���%4���L��j����f/��8���6Fk}3,���Fv�b��!����[� N�������\[��N0�^���vE���F��F}`����g�Q��;K��u�\g20��hW�ټ�6XoQ�����]`���H�&�z�m�z�J��5�������}==`�:�d�Qvk^�v�F���3]���>24$�ѺM-�F* �I�nJI~x�})%i�J�Z�i��4K�		}�����#��ڂZ}<�z%�&"�o�|ly�=�7=7~sw����Ϸ7�nҞ����O�����x�������n�����_�ؚ�ƛw?��w��;�Z�,�CT��%�m��D?������nN�ꄉ�j(0�K��5Ӷgu�Ot���
�!ڭ����Y���U#�v��cpN)�7�-�{�����7��{O�(v'��Kl�����fs& ]��`�su(㈲�خ����5�,G��d<.%v��Aa�)c����w'��D�E�����I~\���yGR�o�w<��P'��Yϑ��	V��h^�� � @�*������@J��9�i���w'�C� �a{��o��x/��K���]�`=�F�����])�W�� _��l������\ܡ�������gGFri����T����nܚ|x�G4��������ӯߵ�ç����p�O>���×�����M:ў�?��� �_}��ieq��ل�&i��w���O#�g�ϽM�}���??���Zu~6;G�}"����4���P\B/ʟ��s�%�J����4�8m�K��񳔗�h[Pt�jdh�Y�-������?Oqˈi-���k� ݬ) гG5�2�3��W'��2�76wmwM�D2L�kJ�#b����� �_�;��x�@�)D�Q_]����;&�V��w���;<����)��JU"�z���C�������ϟ�>̔<2`ڸ�e����ċ� {�:����fmԷ"`�(�%C����N�rB��C�->�e�<�<� ���0�h7��11���!_�i��T�3"	��]* �钠K~���oL����v�����N� ��A7U�K@I����d�������X>N���,2�.�f����{��fpʗ��;/�hdu�{:]��l����A��N�м��[hڐ-�\޷�U�K�	��Q�K�y]��ݢ�����9P��f	�!TK� ��8�v�GUY4S_v��uR�Vަ�12�sz�&|-�e�=�즇iʗ��얇�2� ^Jv�˨��<�TuW�J�dDG�%Y�:���$��?���9��E ��'���;~Nx�3S�3G%�Z��H����b���#��Ǟ4N�*�?��W��5J���i�)5��Q�Ǯ׏!�ד���(Oxb^��
�6���E�[3�N��Yz�+Lz�0p�4T�R��J�>�fwm{�Węq�N�q[�X��c�o�ി����_������~�}ws�������O����������_[�����]ъq�[�}WS�&�Њ� w)Z�w�'K�t�刺�=���ۋQ���~~Ń�o�儺�҅�K?�&����GP�B�w�mַ��zj�'c8�j�#U�t�%{T����Ī�FaU�1��utw?����#�I6H��g�<��4��hՃ�im>E{m�+9f/��A��^�\�{��zk=|b�(k@Ϩz�yh��jY�1e�M����!d����W��z�|���0&@}�גb�m�:�擯zҔ]�uS����|�U �gC,s���l+��^��v�(�ay�2đ<��=�����:�q�H27ͫ�Z���t�/��^<5\���U��}d9W=��?��.�?���������ۧǧ��BR�G�S�@�    r���w�bJ�,��e��Ǯa�ݦ6ve\�f3Ph���3
�gK�R���v]��e��}���!?eI2�S=����
�K6�S,��%��0��,�{p�����t�I�U/1f��Sk�C�b�k'��>�̞젗a��k�
��_d�Wv�R�B�ݍ�cp���N����eo0�:D���L�a�YDJ|k�l��re��Z�.��묄O6C	?�Fe������!ц��ީ���'i�"�$��3�{��-b"UI돟�>}x�6d	1�gm�JB[�b<
��3H�V5�C#m��ļ,�^��ldt|}���+�h{����_��ߜ���>�r2��w�]�X�!X�s��q����L�.��5���ʾ!i���R
hӍ�l�(>mβʐ�B��*4wS���4L놲!��J�+k{Z$kḿ�ihhh�ՒĘ�������x��U�*�R���8�H/�=�6v��q���h^k�KH �gm�ɨf��!�a�q��R��W����ɡ�Ak0{w�d ��B^��a!�`�n�l��'��=�ё�J��e@������jD�Jd#�%�����!��]���h�4Q�г=��<h|��[����z9��H���Q.`������A�:�h�YI;��6mf�������U��QA��w��z�:_Pr�]hS�q����x`�^J;�_�m�=%ZD�����yg��e���b*���β�67����N�@�;#�-�*j���3��ݬ�] �g/Tr�}$" ��Y��dh2p��;#����Y�F>����}��Q;����x���eQ�qv�l�������<��J
�����6��+{#��c��]�m�� ��JLZ�޴�GW.�z#epN�Mr�G�Ê��e�]���@�S0����3���n��i�S!@��(À�+z�5�,m����M; �yl7��z 6o� ,K��U��6�ORZ��ȶ��M��ވȶ[�H������������[�so�@m�~�y��_?��ꟻ��Ϋ`O���(l��^U;���/�f� P|���u�;3]՘�[�M-^'��8/|{_im���qCof����|{��߾�R���܊�:�[-�J�V�N��§�G�^��5�53V�-mMS�[�ls��&��-Q�4�Su����ۋO�l3G��@QU�4|���z��>.��;H����N��?)���T�5sh�[���z�{Ս�A7rY���I1m�@�y��B�Ȱ�m�>����|N�)�R����R��\� `�]� M�MYʤeQO1ڔ���y=`t��-a�S*�f�Y�ej��F�b����r�{v��+����}�G9�"$�����������9;��P��)a��K�Z<���zd
�8�[�	H��	ݥ|4x�.��\/%g;T���]]
뜴��9�F{f�ɝ�@�=DV����}��I��4�&|6"[ZmK��+�)N�ݨ�R�Gꥠ0��1�r���RXOO�h8��?ɪ�8��j��[	(��k� &@G�虧:b}'�JA��^�Q�eTbG�� �O]��'G�a��,FȨ�/ر�j��w�b &��>¼"�c6k��TGS����3-a��&ïB�������\w�"�O�Ѧ"ͺ�Y"��]3h��<o���~%��q)�ˌ�F<o��G^���#ƽS��s�˙#w1^�[��9j.�0Ai`s�եl���Ep�~~v�:E��bJ�F�kPH;���^�^���hm��H��I�?�1�쫧�E��ⓀRe��0��'. U��� @�
�dGw,*���(�e,�S�n�D,k@�f.;j�����t�ʦ�`������9�6�HtZGΤ�pe9�m�lB=0م���.���U�Ku�f�$+�ث�1n	�h�)$�|���Qa���ֈ�ϝU?�U��F_��o"�t� 1_��5�{޻� �/$⫳�ίݒ�UA��`o�`�zky.���g.�=����ۏ_�߆��O�O��~�o��ǧۿ=��������x���m��n��߾�������O�_�������?<�����o�����}������Oڢ�t�p�s���gi���4����A��w��Z�p..e��o�tjN��J��5���r�����.��;��.}{_�����0�gʌ�����p�R��wk�J9��a�T����{�-Z�W��~lU}WSaC��\�����X���c� �ޔ}�WҎc��ղ�'�-1й��+"Q����ښ_�a:��F��Zv=s�Iu��p4F���#�C�w} �]?�\>A��i7�� +�9wX>�h�����P
���1�E��Ǽ՝��U����)
�s�(�����s�h�J�ʓ���n�3�תH�y�d�n_�z��1Ŷ>8]ّ�R���#"���������ڿ����T�~�ǧ�O_�������c��6�(�����q���>�߽;�}��y+v��o��H6i"��헪>�Ե�dr6��=��$4Sfy�ĉ�$�ޥ�;����Ō�x.��]�GPЎ9�w����ν�K�v��=綡��U�+�M��<��,�m�0�m
{�~�td[�Q�)	 �����Wo6�  гM�O7D� 8Y��3��'���y@Ř}��/��d 9K��
��u;$j��t�����θ�;dzTU!?�2�� �og��7X%D�X�қ��d�_��\��x�2'����A(v�͕%׮���-��=Ę������"s1fO�{�Cto�l;{���K�r�6� ��>&�L7�6 V'S8�Xi���m
�S?����#�F#Z��3�Έ�����9b�ڄ�
�I�K#r��@�㔿�7Om�~��{�	c��������?}�P{�W[;G����~�A*������,�����|+1��a�YZ# X6�4 �نS�.Zm}�@�2�;�1���;����CU�S�qq�]�h�m��fp��7����@)a��� �@Ǽ���._�R6�͆b���7��QA&�^�"��昔�$��J�`�a!����Y��}�*-���F�Z���]*���繡�����yB��M���f�n��t�.�yU]�YJ�`��:�!�O��[�k�%�<�UU�n��Z0R�}A��0�NE��k�[�VRʺ���鲚��_M����WW�J�����g��X��<^����_���Zk(�Ŵw�8s߾��k��K���5ΑX�݃�+У�f��� ��|��ܨ - �3r�\�:6�-��Mv� �L��5�+EʌD>�sEM�-h����/XYE���"lAUE�pU���V�D4,��F!����qm# h6:��CۦU�ꍖ�?����F3��Of��JC��c�t\&��=�B����n2�!H�Z��7��=�};��5������6���JZ�zOj5n+5�Q$���ڟu�m��Y �l�^�P��h�H 	ˠ���g��	�ok��H���	�P������]��tކt[���I繗)v��x��6�u���z)�(���@)ţ~��-�>Z�le��Oow�̚�78�,����vЛ�f�����@]:���4���l3j�lF���Ȋo3��Xt1�2����EctE�IsP���<YS�s5�i��#��;爪-�X�:���,��솃�N����j:_ ��>+$�������	��`#IL�f�n��߂����' Щ��v�kh�o�
 �~�4�����垈a�S�<�rR*	��-�bѻR�W���gY^���������%{8����������^�h9�2�j��:fة��1��0ï�w�ucy13l��?�TH���r"�����ِ%4���T7�xEUڡΥ�������>.M@ֶF� �enz����.E��j4��L�*�&h�8vqR�2^�&8Q����V6I �{.�JI/(���ɗ�����&gzrv(���.�k�A�A����Ub�����k��G�&��t)�ՠ��r�����mǩ�ڳU݊(A��4-����*h4W�\��    ;��%�k�:�B���<���R:9f��6x\Yv�D��&k$Y@�U&sG�G�O����7�����?�p����Ͼ�4+7Y;���n���z���ّ���?|:�a�x��������ܞUljc���㨫r��|��є?���:�N��ʠ��v������)�j�w�g]���=(1���-rī��0��,�>g�3�0���_���C5b��/�9�I~��|S� ����d���[�AUǑ�@e�<}b'�5H�8��.����z��v��������]O� ��w��Ά��K��P#1d�2�a:��F#Q��a��0�L7��<����4ڋ��+M �g�!6@�PN*�x����$7��0y)���S�6>��Ɇq^L&[�d�|�t$���d�%'��~p�ٻ놛ߌ���ޭ�l1�z�4ë�V�F�dd�d,�oxA�zo�F���Z:v �ٗ�=ģ�t�]��Ҍ��~���I.�5�{��1� �w����8d�0�]W0DJQ�N̊l�/#�}{�C ���3��L�K�ܷ��p��:�_�]�e6 ����N�L/8��ƪ���7*�.�Ac3��N��:K|Y�kL�L��̡eg�=�eg�g<�,f9��4�4`�x�#Ol���|7�	�F�����<#�;rxV��/�l���{�5���m*"ٞ@P{��[S�剬���68㴆~���"�=���{&r��,@�͆��9]�@?=�0�Hj�ņ�PU5=��ê��O��]q������}_ݕ��\;�.�Uw� ���'ȑ6�C( γ�J�A=8)��HA9�H\o
΃�9���f��-D�]��G�9rlk�ƣ�h��;��w�Le5<tR��
�K
f����hV[ �o=�1�Ůq��l�A�'�C$ŋ�%]��|DU�ܑ�)ƙx���z�K�rPb��%��3��> �ȴ��<u�P�8�!5c_:{ӧ�r�|j�+��Q0���>:?�GUƔ2Oօk~��T��k\p8h"���3�rzv8������K6u}F䱻�x���FI�,&O���^Md����f6sg]���T��:�-��;k`�$~���ڥ��yN��<7V
Q�viw��.��`hbJ-`=�Y"�r^��P�U����-O(�0�s���}����UU�s���� �v�F���}N�翱B�͎9}�;��}�`({��÷�e�0�y���ޥӷ�b{Vo��=��gS(��F�k8�5���j��-�X��ɓ��b�|�e�*f����Kp]�|�e-wa�0y�҅Iu��yM�ы�/]��)����aԻ�.L�v# �]aq�K&e����a��і�R5����Ҩ��?��Ė[r���'�lYwZ0\������;���� @�Q�l	�q�h��߻|��Jh���a�e�Ҡ�]�F4t*�[*;����	�0?���{k�xW��)�&��%��+i�8�lG����o�E��7����z���,���2jʮ$��$�}`�
&M��FL?e�g�65x*�~��}�O�������륩W;�i�fԕ~j��OO�(Pxv����B�R&���P|(KR���F@���{L�{1�Z��l��3o}�43��C^KJ0bé��wW��{u�`���������Zp㮪��=���%D��gC�`Mer��@��X��H1�V�%�eT���iW��JEe��qŎ��๔���zo��k?k\�S�#��e��g.�sܦҧ�r]s5�3�v��v 7 0�c�����a���Fv����c��*W�����'"Z�3��`���+�B�]������;�x�n�<7��WU�BY���XyB� u8����͟��/s����ӷ���t���y��C����xDg������_��_S�X����C����F-M��[PڴQ��RJ���o�L�{��%�^�cz��Ԃb۟�,eę����T�_����[q`L���>�[�h��Z)�ɋݠ9h]H�iu�7Ȓ��}hI}),7�����z�.7)x������N��|v��[�\���Z���U'�6�>{��F/���r"Z�W��a1z_r5He^Ǉ�E2�͛�!����9�*�h��W�5~����S�*9-'�����N��햬�}@�s�t�O�+J¶j�j�%Ӡ����ۇ�}�țiY���]Q)��ߠC�����W�6���2h����1����T��5�0�sce�ܥyB��o��E:Ϸ'��5���>�,�5ݼ,$�)���b���(�.�y����0�{;e.�K[g2Ŗ���G9o�Y��P�_���4"3R���9}��{�zT}�P%�do��X�L]ݴZ�����`��w��������&�b�7��<�H5i_z�/�M��(�Ij�a.ELX�Z<Rj�ߕ��\PJ�9c4�E��-�J?)�嬷M�����r�(�!����ۓo2ʔ�q�>tv!��� �Li\Y۟G\!�!�e�ѳE�$���4��p�XA���!�b����Lt�l�6��*%:�u4dy����(S)
V�*9���Q	?����ˏ�腲�e���ȃ2��wf��()ތ�Yʗ�GZ�BK���������J���0���2L�F��F�J�e���G�Z�U��_�P!)"�� %��d�{��aW���!(��R൜�`/�B��"�*�2{��%����6Q$e+#{HD(�ګ�� ]"�xK�ri�o*o!�N	�`̄��p����P�����J´�p��L ��/궠��KF�sX�+m��ȯ��Ј�A�#ZY�˅�N��*ƻ� �dt����b���ω����є.),�O-'z`�rxCҊ�b�;����H��f�t�L�EEU�
����l�o1
��=	�C�Zt_�8D�#���R�`�J�#�pw���2��ԡR�ó��뮏��-��=�M����&-�[Jw���b�RHJ� ˮ���B���Z�-9�}pY^kM��>%:\�]�G�QN��2��{��>�<�u�Am]��q��b�å�_1��zʀ��a��6�����j*�-����0s'�?�"�i���oě�WY���${�xY��߲R�K�˴?8[5��RZ7�-�闏��~ ��z�^�W�+�?��Q�Ёj����T�ǌ=Ԧ�]���L��Lު�h_>� P��!��b���ی{H�)K2����*T��m������7%2Y�M"�������jw�F���µ��Z~$��xZJW�>��h�A�iEj�9H|�Q��F�M��Q�<+�����q�K|7u�tʞ�;��L����T^�nYቔV.��;�z��7�o� *#:5]��Ai(-ߜ=�ӮW�ڣ�dd�]P�:iP���^� �M(_m&�'?j��p#9h	p�����Dy������i�Q�)����#}��
7(�6,ƫ�7�-)R�Z�c��ї�j�����!Hh�c1G�5Ã���R�X����S.��hp�ǈ5�PΏ�
��O����R�W�ɬ�Kd8d�\a�W���p��5���w�X����Ёe6��h���Y% �r]����hJ`�`;�0J3�G��P����<A�G���ת6�Bl�5}�/d�z�<�H�`b��ø�Y��saSiT��e��/���Q�(P�a���Ѷ�ِ5���n���C�4%�5�\G�~��2!	xr�	#�pk���b��lg��tҚ�b��I���2�����=�#�VZc�4sJ|󈾹lAl6�=�8�ZR���S�F��
Wmf�r&՚e���f���+�����a����@-��ou�l��+΅D�-}�=�5���C��I�J�s�Ȑ�b��W���@Q��L��H-�R	Yr:Q�����M��T�st���T�@q�*���ӧ0]����fB�B��y� �+TQI�^ō ��@T�o6dr)1݌39>�p��$t�Hl@�^RKVF$b������$����`�� )-֌�w�E��q5X���������|�sBv�Ra-��L���#��F�`i{�-�<�m���@R�@���`�����ֺVY"�s�X�    
9����\����_Z%w���E8S�Y���?g!oH��t���>b�bScb����$ ����I��6��[�������=�h>�V�B�k�AI ���� .��V�e)� ��n��">{`�,�y��tВz�ڗ�.�>�{\�L�u�P��hH�R��ٸK� �����q��_yW9��[�ʸ���q��b��0���O���.�b"�O7X�%¬ac�P�W 9sh�u�a4��T Ye�Q��NU�>���ɹb�}��@��p˚�g�n��25W9k`�~Kv����BCQ}{���C���B����ֺ<�
�M�8�hwe��xWko��%'�᭨i�e1����f'w�r�l`���Ŗ�x�;���k�E�c<�)��E����(�`�țv��@͛���Ied1?��`rY�y@5 �xd��p��ʌ;5�˱ȢH���g�GSX-Ѵ	��xW��	,:�̲~��;^���2�Rs.��׏����;:%�\���nS)��-�X�c� `HRjϥM~��ƪE�]܇�'�K�7b��R�>y�r^m+�R�����{����P��֞����w���L:�l]�]��㄰C���,�i�&�{]�R� 6��/ؾ` a�Ň�nw�\�U�`�J��MKxl_Љ5Bl ��:�$�.K�y��5�������K��ax�����e��y�A7m�E��ҩ�<�e����4B�˗��ދ�-���/I����VTfVy��U���:%�^�d�	�WJL=c8�-i� �S*���je@�XR7]F_�x���e�7�����a2������Ѡ�@
��4�~��#/�a�d�g�����v�d���FJ|���PM+�w:m${zG\!E&��K��Y�f��p�����ۿ
��l�=����c6SH�d=zi��إ�x�[5UT�6eV���; ;�oy��6ɳ����X5��I��˰�����S���=�y"�r^����>K��l���:���)I��}��.{�9��В���|�%��cz�ԛ�Q)e�U�."�',Z�W]4�i��P�"��e���N�Z��?���H��rz�7��<��+�����H�
t;po�Ag�t��M)%?�1�gt�D��Ma��q�Eߔn�����&1T�1�g��&,�S��}y+, �n��E�J�-b�&�1m�֠��i�x1fO�:�\q��C9�!� 1ֳ?:�3������b%�y�E��|��ϫl{�Cŕ��X635�7?W\>s��v�"W[>sh��n�NX�L��y���:����c��g��1pe�GޯE8Sޏ翱�h4�+,_�]����+Y�q_��W���P:��(OxB�rU�so�yo��zqe�sǖ���e�\]y�4����ںRʗ\i���t��w}�7�ӿ�a����O�~�������=ɚ������Yw��������ה6��w�����8��G�ZA1���<��MJ�:>;Q���M�(�����v�ݘ�b��iQ�����6W�#�Y��JhԒ�E�a27��75���O�s��Q'��$.���\��T-�����7R}[��g����cÃߤ��_�uH���9����� 8�&�Ț����Dn�1�|/E�.�V�1�0{#QA^t6DF�,��Q°��%���T���3"�jG�����.�tތGN1��Z`MJ5���� �;��r�1�к��=H;x!]!��)������O�A�:����p�'[U�P�1)���,Ԯ�������כ�����_n����ǧ�?���헧O�w������/��_濍F�f��D��[0���z��*�	-��d@8���+*f�0�y��"�����{�v6s�t����WJ����-*�F� �y����*��-;� ��xwZ�3Ř翱�0+d�2�]nO��1d�\�w�+������NU&"t�o���|�x���{���e����k����{�pN�{���zT=�fR�]Fב|@����&�����瘸߻�!���Ř͖S��}���c=�� W�E��X��N�?�F����dr)���z�K�G�E^Z��� �K�=g�Y-�~�����sRB�Yˏ�P@Kigg��SC�SQ�K��2�6���9R�Z��g;u�6p���K̳ۧZSJ�� ��2:�Q��.џ��tKP�G*]�y��F������ɞ�W[c1\C�i�q���CjJjg��gR4���Ω^-I�N���H�nI/?�CT"%�e�|V�'˹��F�)��˓��; �`R��9I�}T�k�T&�q<�~W��+��i�����������Z/\�ٓoNJ9���A�	��lo=$����Ѕ�	]C��O@���Pw�h ,W\:k`�%Q�������Y��pܦJC�^��*�5��)�_��L
JS�h��V ����V)BJ��@;;cB2��8���:�9���:.�Z�*�\�=Z�����؃�+��syBQ{�ǦƎ�r(N�ı�~�c�'������l(V�r�b̞N�U��)B}p)M��O�\�W�����C��T��q��M��=h0�r���" @EQ���_�KQt�U֝JP9�Y-&(�{0�)]�Oo�`���Փκ��R��H���&�5���|���)-���_m'4�~)��V��h�+��R����|7��ԉ����M��(��,&��[�nJQ9�s3���=+#�Hfݐ*�2���r�>X�Z�X�1Zl=�B������ QA I�g@�p�{&�����#��qX0n����HĮ���k�zS��ǣ��BrL*����V���[LlZj<
̥9�J�_�J����..�.�}:�� �Rɿ�ۆnC�v�-���|B��/셱E�y��ƃRU��e(���.���6P-e��N
�jmJ�7c8�	@jLwO��������qw ʅ�ܚ����/� �	J	/g}���%�N�ԥu�Ÿ��h} �ђ��2�� �ڀɥ}����+��~��L+��	��P̐��2����<0E��e�
��V(�r�q������4z'p�q��������M��f\ayk�g�G�Z:���KNjLUMjSҷY�Yl7m ��n�d@|��&he$�|�Q|/
X�)�u!�B����s��Z�x�})���}���D����O/y���G��L��`6а� m����"7�]�f��vC{Dў]���BjLKϊ�J����,�$�*5�#�(�M�/��u{�]�r���ĽMH>�Gգ�W���>��y�ҳ�S	1.�8���pט�^�2�6��}̿:�� �ee��i
B� �+�J7�[\�,c&[GF\Q��{)}4���e�j�����/���7�ܥQ�
��YR�� ���`�pÑ2�r�Ҵn�ȥg���+�R�b�������T�c6w�h4B3-�Yzy��+c���Ҵ,�.�Gx�ߖ����j_Y���jv�~1Qu�;^��3ߑ�eZR�k 
x���Z4Q�UJh6c4ُ�S�;HuYQn:�E�ݣ�p8S
�%�q����R�� ��`E+�h�?1/\�7��܁8�]?�A���+�υN*���S��%��^t���ߛC��C��RI]F��O&�G+�����#4(���`�����Q {�G��ۋz�S��
ͤ��M��R��(w����%�)���p:��)e֌�\�^�@5�Gw�;�I&Tw"5Ze�L�����*想����HJ95��%ߏ �S���¨i�UM�ʈ�f��r�\]�~�L;�
RxT�G�C2*X]@�v��+�,¾�'��VJ}4k@��;X��)?Z(�E��}�hu�,鷴���h�3��Z*,w�M�Ѿۢͺ~؀j��/%њ1�l'EC,�@k�p�߹������7-J��_��5�f��HiV_zZ�H�a�6��P=�~��֣QZ>U��\w7 ��HqS��79���<�O��x`��
*�{/5\��e��5�h)���}�S�U\!�GtǕ���zx���e)ޱ�U�N�GE�&��ؙL�| 	  ���j���7�w��j`+�#uBe�<m�$o��� m�.%�q9��H�h��r�. ���D�k�o6����h��r�<C�dC����t��Jf�� �HqS�'���ݛ�&�dw�h=<Sʦ�'�3��$;��
������S����)�լ�!>��i��({/� k�R+)�X*-K��V(ާ�"�*�#�(��Ƶ�jx����b��%�B��L���~��5U�^��i�sZɥ/�#��"T�&ȵN���'8I��'w�i>Y��,A֫� ��%#t'�p�<:E嵻@��Tf��n�����lH�IMV�G~ ����K�ٯ��{��A��2���	O��
�)ҬC';v�Ҕ۽�h2��i�>�U"a��L*��𤅆�*;�Z���j8�u�"�t�4���"�-K��U*К��ZY (T�����M�0-�*�Y�7��"wz����N-w�}�?�QM�
/&REUFX�v��2��tT][��МR�:Fq�~�Qt*���A!\���z7E�4;\�*	
���}C���sW=��o��a�����MCK��1{�%5vR3��U�j4���O+�.��v�"��ߘ��*�*� w �6���[����0����q5�?�je_"rM�c�6���q?���˯,/��� �h}�RjX> b���2�� �~rRpY��KD�� rև��3�
�P��B�g�^ʎw�I�����?����0QE��4���~;����d������i����\裨u�� -����j����J���m/(�������e��_�~���������c'�E�9(Sys|���×�����?t����ο�{�ƴ�]���(�ټ/����k?γ#ۯ���t�gQц��oP6����Jʪ\����T�{��}@��B���)I�Wˬ�>��p���V����Gɾ��IB5�����)�֌]���Dg3iַ'��A�K�hs0��}*�C%~RHU�>E5�5i�S1�m6�?��H�[)G5���.�nh�piR������M.$�=�v&�r��Y���'
<��U�OLO
�`_0�9�ߒ׾�]M}Sׇ�T]E���^k)3-���M�������������kk�R	���6�]%�����rt�J�{��s\��Ծׅ�N����d&o�ǿ':Ui=��Z�dZi�9�@�դ@�p�77�N�N3-��Q���s���hU1fs?���QCK��1�}!y��wW O%�@�yZ�4��8�K����B�p�9$�����b)sZ�s�4��~@��Z��`%ӦV8����}T�g_#^�V���t7�sP!ۡ5���{��jC�(�	:b�l.���@1����ᛍ"���������5�BiUS1_|�����Oɾ-`��%B�|q���IO_za��3Z�S��^j<$��f�	<����"�ʧ4<3��l��tR{���QD�}�ٛ�QP��&F: �����=�Ϭ�w��̙������bC�η6ٷ��z��)Ǜ�f��<�������e��q���mF��Y�ç����	�T��zhYP1A�PC�'��a���������CH�N8�EGh_e^E6V�}����U��R@�]iYuB�o�<<�7��|�pN�.�����YN?�M��К���pz�Q��yRmT��v%y-�[)�dvwEo8��#��g��ۡ�-��bz�/�:�a?���ozww�y0���������>�8dЮ�짔��|���a����}�ȼ�mu�G�������wv��R�Yg�|@�-��(�D��pK�O�R�K��|��lH5J)����K��x(ϑ��%���g6>� �*����s�+���^J/��"/-E�^NW�KzR�����cԣ���<�*��R��
������t���R��|����:RQS��k�����n?f�5}f�B��[ӥ��|��Y4#f����b�u���}M�0�����2��Zi�D!_|��PZ�����""_�RB�%?'�ؑ�C��A�� �!�ex�4�0t���Fh�. ��� ,��R�3XS���]SY�+?�A.��3�#���0Z�0� ��S&V5"]D�v:��Уڠ�۴<��G(י4i�?C20ƣO����!v�~ Z���q�1$�RF�d�z<<P�!��+���ƐX�m��I�M�:�H�I9fs��ƣ�h��ƫ�ToiR����������!��r2�����	�=�� �e�5"�@K�tO6)���Ӓ��]��?���شY         �  x��\�o�8f�
=-��F���-v�����6�X�#�6Y�QRR�_3��8i�����h�����74g/��Y�D(��0=aƿ��o��5�y������`7C?�:����-��i*���e�M3[8fw��Ϫ���-���+Y��nցY�����+��5���R�F���`��r�@��V5=~�*Л�z٫�4�V
�a��4��}�r�FsvQ=*��O�4�V6������&��FR٧�J�*�ڶ��4y�l�P%��*{k]���Om�KPҭ58����*�ژ�Sn���X����A���{Ց��E-��GǛ/��[]���I�l9t��*;_&c}|Ս�k�r%y�n�ݓ1�ߦG�C��`�+Z�죄��\�.�z|Yp�E�ә�v ���S���ʢ���LD�F��G��p /-%Z\�'�?���u����	N�+�A�D)�S�|IE6�hL��/��ea<UW��M���3�2.8����(
���P 4n�/�^����
�V)��t�!4Ѷ!؅-7�W#��&.�5\j0,�N�G����E�bmu9�n���t^�<�ٍv�/3AeGX aKkZO��Eѧ��B%Q��̪���K��v��ĝ4{��T���\9{gzU��|����/^�![���Ϩ1�#t�F��v�XL��U��h��(��[�{p� ]w���(UOS�N֤-��Zi8έVR�a;_6a���qlϏ��}��`���qƮ�h�1svD�.�=������a���$7:g$�'ܭ���ЭC���M+��>�2~m�I.���Օ?��`1�F����n��uc�>HUG,���bij4+�� L�)\ï@��N�rXoz��������Q{7�|��fP�#~��Ґ-��(f3|�șP* ij����5���#di*�tW�·�4_��+���3�yk�n(�S�����ի�P� �<�x��� ���z x�K^�`j
Zn��� 9����c-1UN�ש���3����Bzj�q�Vn��	�r��U���΢�D�g�+����e	�K7�ѵ"�n���[�{�����Q�G�"��׍R�+�م�����`K�Gʖh��lf��r<�^U���[YU;���FA�wyt��TIp;� ^K٘V+B1.yf_^�J!t�0����<��-��y�n� K9;�O��7���H�W-!�(C���,v	v���D��8Z�#E��J����+jjgUw K<@Z|C8aX�#l a���}�{��mM��E�VWk�AE6�������\��|J��kS�]���t��Pk�#V�k�T��j%�QT��J�y��U���P���m���!�F�)����(Y�L���<�٭^�)H�!}C��$�<A.b��i)�N�X9(x�M}��J<��Um{v���3K9J1�������O�9�#��x���U\��B%�4�Nx��t�����}�����	|�>��^a�)�Q	����	ך�[�������tA���1��׬v�Q[RN�y���.J@�0��3!�S��~��^�.���y+��C{tW���3��A=U<yV6�oe���K�J�﷌�
�h�W{@U)��w�>���E�.j��+d�!Yݻ�K���L7����F���+�Ȧ$$
�+Ј��0���?^pȖ����+;h�GG�p�+�S��&�B�Av�(f� 1�c+- D�o�j�%��;��/����t>�e�ښ��z�Z�rv��W �S� Z��J>$�2�� wr(�����^�X{�qt�� 7c[h�|$��S��>%���܎,ǭ@~Y�< cH�{,9���q�Nr9N]�16��<��h\��8ń��RzvyN���9�c��ZU�y}��5	�@=U	��w�L.�ݸǽ�D��%	��#W�e8���nX?�i	.� խ��K���	Dlp9�c63l[�
v��O�<P0_8�0=��%@�I�I�ƻ3�����Z��g��[�����V����v��E������lMa��+c ���4aݕHU!�=T��;M1���va�ii��d���iIa�M)�bFZ0��/��B�m�g׵��B�8�]�)����n{�'%%Y|��_�]y�����Л���&��]��s�u�/�$�Yʮ\g���{�l�ijf�宬�S$�
�u�Y>�H���׎�8�9���G(��6)�<A�m���~��|�[��y�rD�D"���ؤ���]Z3&�*hV�K5Z+���uvg\K�t��)Va]4��a�]$����yΖ`wEW9�5U5��6t��cg�NЃ}�Nx�x�#ld�%��bj�R�V@��1�Y[�n�G��8DUw�|7eB�6�5�����7��E�1]<J�) y16��YY9V�i�8$�7H��
[��EE�f�]�ڴ!SaM�˟�}~r\s!�7��~��4�Ꮷ/�~#�d�X�d*�-7r�C�]��'��x�J��ܘ� ���M9LB�l|�8D7_��@y�X'[(�Pك�|l$�o� ��nu�Tm�.��ki���+C<a�a�D�!�|��AH>�
�E���^�sFp�[[�[�b̓�	�;1X�?�W8��MJe ���+ �&���!�C� ՚��$��a!�!��;>�1����Q����*�6��	\��
�Q��}��h>�C]�O�D���1h�,
,��ڸ�~�nQW��W��<R\u�Z�L;E$��+|mIQ4ո�'^ F[�yB�W�K�1�9���5��ĀO��0��
�v˧R|<�1��B�=�b�܏�ЮjT�z�:~�p�b77�+T�M-�I'jĵ[lן�PdPr?�(��ˇiF�4�K���}{�:���E�vkz ����σ{8V������~5N����c�'���V�9�t|D\L����߆0�/�p?���$���c'���t� x��[;4��o����D
���U��<�U�z����qOij �ZQ�B����) cW"Ȼ	^7�x�mk�S�l��@0F"���+�D�����%)R �2&��H���#�yӘA�6�;r]!M~0�J�|�<jNG�4��Zӛc�[HUG�B,��PM"�@f���Y�~� �@�(��qW�@�b�q����"b&~� ��=���kF쮷J���2�$��yօ�Mtϧ�A�� ;�qc��H8���]�_�,��FY��Ȋ��?�1[��?�T���WH���ǯy���m$�Y����]�?��E��_v����ϼ��4a�i��~���I2��4�G̏��Ċ�W�~!M�|�q$y�4�{�� �:$,��$��'�\�!�F�|�n�����1�v��CM(*�AL�o�k���'U[j��Ƚ&ElQ(<����<G��ԟ�9[�v�_��s�^s��*H�<�M�O������qqF3U�K����d�Í��w{�Tn������9N�� '"l�l�������#�Q��xN��=L�/]z�4.�?�D�;d�)A���Z���Os3�R��LE<��mq���?�������Ԟ�O��J���B�F�J�d�̀E���~m*X�i�����)�߿�y�����         R   x�s��5 CNˈӐ3�(5�$U!91'G!'?�3Ə������T��L��D��������X��������"Ə+F��� ?�x         Z   x�sv�5 CNgː����T��L��T���� ��Č�b�)�%��%I#c+c+#c=CCsScN#D�61�322313����� ���      B   m   x�3202�50�52Q02�20�22�344�05�tv�5 CNgː���T���� ��Č�b1~�%	LӍ@*b��0�������P�҂�ĒTl�@� sD� �M3`      C   U   x�3202�50�52Q02�20�22�344�05�t��5 CNˈӐ3�(5�$U!91'G!'?�3Ə����9F 1~\1z\\\ <��         �   x�m��
�0Eד��f�2�J�Ѝt��M��A���[�M�ٜ�������'��e���@�*G�1Y!���ӆ+@h�p���>�.�_C�ؘ�����:�b�2%�ѩ#��[��96���;>J����$_B��H��7�q��\��\�q����!�4�$��Te*����_U�            x���]o�J��=�Bw�nq�d��������7@��a�H�Y�"�~���I���>̌�_(��������]��n����m8��ߋϫ������|���$ !�N��c���w����WD�n8o��n���U�����C�ҿ��r^<����� �q}8�����ZA�Ӱ�;���tdΫ���fqw�����-����pT %�V�j����~�x*t������}/�[�/��}�����
�c�l�&�5:ш�n�[�7h_��W\����S�k~��!�=X�����̑�ӤuH]<�/�w�ު�w9|_|��a5���f�]1�j�Y־�i�����b\5���j������TW6��HC2}�p}�``67���b�}�5'<$�mJ�Y�Q�!8o3R��Cf��|:i�xH�۠O�BI$b8��E�x����H���Ho3�v�����j��M�Kz���W/FI��1jX/��'!�à�y��b����^����J�n�Onm�mVBh->��0�Ԃ�b���@�7Lk��뽚��	\w���|� ��ֶ\��jFH&ܤ�~�xV�`�x�o����z%:,@D�:�b������e;���A1�� ����I����Z>�!��SħD[no{�_�1MQ��_UsD�Ӱ;����4���H�_ͯ��n�]/z�� :�K�jxt�cz������`v�:�AA-�$s����{�6�y�ߜ�C0�Wh����؋Q������?��u�)��D5���w}+c"�H<�ί�M%�E�mM;J?r:�΋�� �����Iؠ�mkm��Hc0i�Ǥ�a�]���ؾ[��lAr�C�Ϥ`T �<bpY{D��h��+	*��Y=��| <�γITAm�������p���byT�ZA(�͇����'�#�����{��9�4F�8���=׷��,���A��5���Ԓ*h���s���!ߚ/��f�T�Θ��l������
ڝ�OC���ݭ�~gDR9��4Ö���+�xFb��O�
�w?ӫ��b�{}��A��o�o����j���Y���	b���?�G4rR��_����vi�w�C��m�b5��av�k��W�-+ꎿӸy����Kc>�_6;3l�bܯ�k ۆ�M��؟*��|�ݸ^�_���auƸW󼁔:Ky��C�I���f���苋��\��g��F5�����,O*-`�󍾂����H�C���c�h~)-�2CR��������@m��-_C��TSC�lQ�;XaQi�-��A}m��5My��W��˛J�ژ��:|�_��b�H,��%9@`!��?�D��8� @p���_�Q ���� ���dzo_��V>e2U�Mm���׍���׎7i�� �}�7b�F���[��=ZGcG���ӷ�F~xD_��9���u��W�TJ�l�_��ա�^J�(bQ�7_��d��y%V���F�,]*h��y/՜����"�n�r�vyg��n8�u����^��:�߲���vl*�����G4dc>�l:&�D25�����嘿��Ɨ��Q�'�:��P��� ��,���^�"4i7*���A,���A��®�ݡH'�V�Xk��ޖE3�WB�qТf��y��,�%��U6���qPlݨ-�;�j@���A�<Q�f�f2b�wPk	$�|>o�G��������H�.�������|�端�����8c-4e11Po�/� ��s�wi�P#z�k��^,T�T�҄��D=��8n�Hd�s0���%�-t6g���|��0"kX~�4�f���Xä�����N�a?Jf�|G�a<f�:�|�ְzXi㦆�X�j�k���0�َ���a/��Z�����F��Ԛ��k�@Q���gc�Z)����0�k��5L�4�ׇ�QP�p��;�,���(���Kp�������j����$<���Y7�l6&Q���|�/�������!����n�U�x��K��5�L��cR��4�[05͚F��E԰0�lh �紀�YP�T����P�T��7B�5F/�✵��i�iL�P�R�C�>ow�3<��'��Ơ�jP��$�F�Q_�ұ�*,�V��v�j����?��rk�"�\H�Ad԰\�[%�}�����`�eB�j\�n���O���2aσ�	���D�=15���P������J��X��C�?@���&[)P;[>�f
��&�Ǥ�����u��	f�T�>��r�������\���a�����n�c<�l��m�΃k&� ��'s�<�
v���C �]0
��j��oZP��L��9Y_�iOry�脘�-O��"� �>�4>kۄ����Sò������!�ȮL������q����0*��~���%6�/��y@�E3������J�����5�Xc�ֿV'=_�ƂKTX4Ձ�����Ak�h}(�\�ּ[����Pt5���$�Kc"(̴��s����Yc�.@�#�3�s�W(�i��g5�ʵ��=on����(�`'�&E4$lb�i��@�7�h�y\��
Ҏ)�1;��&6u�`L6�G�����5�(O�`DL��j�N�<�*.���(J;���߫/����N�a�+�r� )Xii������x]<�;P���O��9�@	�92���7�<�d!-ӀѪ���k�$<�<:98s�>跊�`8������)��P�GO��r��
1���
�N^�ԝ�ȗrͅ-�<5�~m8�VpX�sn��6pC��!����&0���5���n=O�X�@��MM��O60��ʻ��m`7��_���F3������XGlx��T��lV�X,��0Q��9V��<EO��� �*��������K���r����AY�[ořmc<a�X��h�ذW�´z�������Tk������xk��_�r�`�زcKq���p�v3�䧹���9� 8���G<������0pm��^e6�4�ޔ�����e�_U�Q8�T��Cl>�2Ude3�Ax����s��q%>�Cn;���4�x��_+q4��	�0�,	`� ?����R5�d�ִ�$B}&��j�??O�;ZH��ɛ�m,beh!�v���NtQ�㡡Ex���B�ٗ�v��{�q��QE��p8_�� F�,w���à��B��5�pV�1�]�����_�(����W����2q<���o�(�O�w���o.8�͚�Ӯ���4qBI�ǁ��*`T}ud`��DX&,�&[�գu�JVI)��Í:$i`���vR(FW@�����b��LuPi	�J���m�ۇ��z�k���\4�B���Y3��eF5�����ޗ��E΀:2���2Bz1w�r+�!�wO��۠Le+H1B��q%�?Hs�C��pk���=T:m�L�ݼ_=4:C>oN��C��P�V�u�ҍ��7��>GRt��>��ἰ�0��P�F�Nd��h�P�F�A����!yԧ-k>�<<'F�y6��蘘�8�4��]�:�5�7)��FeAg�`~0�gz���z��W�����c��M��Jƶpn�hz\������j���P3��4I��c5^���B��j�gH\ڔ�H���5��
ʃ��i�YI@��������ϛ93j��|�9�ٮ���+(������yxxN�˓����[���}e���Ӫv�/�����(��UΦ���|�Z��0ߨ<�t�.>�>�߭���\[V��顶{h�i��vfp�;=Tw<�����[�O�w��-^݀��`^���j`��H�����&-�_���C���1���|��P�<��ֈi�?�|â��˚Z!�C�����8����<�����l�C��`��R�:J�AbfN�>~�B�f�u����Z�:7Pۤ�.z8���ɲV�i����מsM�O�\a��ܤ���]�o�
�J���f�dL>K��q(Ex�m��!n�yxX@l�by
��ͪ�:y7�ҵ�d?�T��(�+��"G?�q�B*�FQ�i~�3U���{y    �框z�bIpj���툳����vʈގ�1J��z�hQ
	@�EA��iJ@�����gp"�u��n���Bg�c]wd��}Ԍ8�x0w������e��<� 7��(NL<��(e�a��#�ΙApk�q
�{I�yƔ�]����ؤE`T ��|:���a�"����nu��QsU�%S�Mf\�1[WF�0.Z[;�P@�}���mAB8�Z�hV��vE���X�~�6v����A^��S������!�� �GK���= ƔY�̷y>XL���i���9VI�Vh�+J� ����y{u|7?�l��_C��o��ez����=���HĔɇ@K�J;wB�}2����c���4�v�U�-ud�(aμ�x�}P�R6��`�ѥ5:�r­�E��PO�i%�Y�OpQ�.�	r���Q:����Ўօ�?�L�Ïu�'�E(n���i�{�vh�ڛ�Zv�46#��\=�űz�p����H�t�����B{'��!�:�e�����^B[����m�/J�jqdގ�᪹Bs�p��h-hZ-����Ǉ��S$ѩ-ޱ}�bs��b2�d���0V���Y��u[nrO��S3eB�֢cڛ��̕�։�bi���Ï����IL���"@\!Ǧ�=�����@�8�7@R�j��ط��I�+;-������*�2�@M� A�Bb�j~{�¥��B��Q�-4}��P�	-Tg�ѻ�<��!B�1�#A�1�#�;Q"<����^�h���=�9�ORp���F]ͻ��nH$�ΐ[�4vj��{��2�%EQ��XQ��+�1C(�gq5���`�J;�Z��o�~�=
d�	렅u����Zּ΋o��:�[w��˷��v�ʬwz�t�n��Y��P�e9�M�Z<��Q���q�n���s�nl�x�$=:21S��;k��;��exQ�P�z8����Vy�y;��^�`� �:���N\�
Ь��T�K�$3����j��P��b'4� �:�Z�|(�s�;�V� ��'ִ ����d��u-@ϖ���EQ�z)P��<����jI��õ����q��O��8��s��=�jE�͞�j_�y�/�w^�%Q��0{جf�y�Ya��IW�h���������D�[Dh��kƍ�o�m'��0"�6E� /�#�lc��a���k�`S�`�YT(|�|^�Gq~����r�%��o^�V�õkFj�Td#��� 3�e٫`HF1�CO)6�tJ��)���ۈ��`\4����<�0�&H� 0�&�t�`Y�kg�<�
��L	·X�a+XY�
����!v�a�H��&��<��KS�C0~2{T_zƏ^���A��w����S��C;V�B:��h&���� CҌ�1W�q�+Zt����h�M���H�3���W��?*���?�
C��~�hч���M�E/��[�h���t#aP�l�_�ɒ@���X�ZW�_�wm�|���� ���wM�_>�QƼ���J�Zɗ�0`x���:7,�pe���\��5W^�FN#"	�6����Ն<���/�o˹gD΢ ���<�@� ��A��yžU��#I��ׂl���G'�ŷ\��md��TǤ���0�w4��r%�����U�@�8��}�D?�581���\�-�0�0�!��q@2\k�6b���;W�l�IE؜&.\G���#�M09�L+aoFzb�33$�ڌ�'���E��r��֔�AY��'��V�0�p3!FX���al�ߛi��G�[�)X��,�������9�:�A�5��G���J��5;�ʟ�+��r���;�������4��*�Y��(�ڎW��G�aaG8�J��F�1��©#L��/n�S��+aO�r퉰�#<YH�)��DTH�Ƈ��������W5���Zg�Gjq
J�2!��O#�ۜ��aA�C����EXQqL�����É0�"��Dh�_��(������XX�jL0��U�0k�h�w����(���\9N�7�f��cʈ�$�7�<WU�mdؽ������Ľ��Q�šA�M�K��Ľ\Ɛ7�",`!�m/��E�X�pa��I\�����MZ}�T����(<��d�o�aHE���a��'�N\�00�{@)P�Ą��4�!H)"�",���ⴘ��n��v�]aJ�ńmK��#~p�E��#4�8^�(\<�������x�P��5X�h�ۊ�;���ndr�e|���f:9�l�0�����Anq�$�A�hG��n1�FR�8Bv��Z����)��G���f;Xj���8��*_v�s��{ޯ�싐U��#�N��L�t]����������y�Q-���zR�gi-�?F��$�Tr�<^�Si+#�T���(���9����Vi�z>7;�9�R3Fjw��?��&�9��.o�M�s�3���Q yW�bB|�90e�Ј�;4c�]�s�>"��y�a�"�VD�]����Ϭ#b�"b�ԩKD�۹��$�1wW�H>Mg�򯾸�&�"W�?)]9Q�R��{5�󻳍��G+��.�bF$�	m��~Ώ;"� �T�\<�wæL���=�1#"��Si˙�h��~����l@��砶�ҍ�hqeܘ��D�14@���:}�;�Sz��]Hyg#��/�k���~�P��d�Sf>2^QKq+"�!�M�J�ABC�,<`5���-P��k�~�2� Y~�ֶ�ׂ!���LS��\Q�u�ƫ_�7�|D��wB#��a{\m~/��*1�ϑOꏛ�9��u|)Ӏ)��-"5����k�a(��A�S�'><�R�;�u�	�L�N�:8��E�w8�xӋ[���1a�Lu�ဠ��}Xo�^�ဠ�{�:���;��ɍ�m뺂*@Y���vyG3��h�}�����k<z�",��]=�\{�Z,S<�Ǻ�ܦ��g�c�\(@��n��	6ߕ;�wF1R�tpu�1��.�wp
uG���^�i��#�]�(��!�gAl�n�m|,ʬ�n�<.����B����[�Q�ׅB�V[��>���X;A�[;d�"upC�AɞYϕ���߹�|������di��)O��L����r���>?a� 3n�:|�I�U�.� ���V����` X���sdy����rQ.S6e_Q+/���c/�'��&��z�mm�P�w�N�P�T�*+���k�aU���T#�U��&y9S���c�����07�AyR��:��{:����[�n��=��2�G��yg���*f����X�i�`vu:�R~�kF�J���.%p�\!H�lM0��<�Y*��E�pX�*i��H<�� 
�Zcv�v�@4ȁ%�X�̠���l�(��r�okfR)%;0{�_�"]�J\�"�|O2� �������9�@">#I��>�v|�
U�r!�|j��y�"d�]�� �L23?�5s<�ڹf�1�7�����Y��*�L�����q;�_����,��^��\�̎�87��]����n}=&ui>�B�V{5b7A#�`;P��K�W�.]�X�^�3܅I%�sIP�>,n�ͤT�������ށ�5AYskw�w0]���c��Ĳ�K�N��j~�ݿ©�D*"XJ7p]�P�xɴk����(y�F���)��U��e��Tj����a�k>��b�����r�G0��Y��벡O�~8�J����#	��-d�|`]�P��"�G���j�pux>�E���m��_��*����&\(��w,����X��y	L��O���u���.�tY�K�z(5�w_��|�q�tpVaAbqĐ���߫��Ԯ~^]w��*����r��H-�KK��\Ql���ҩ١�Z65��OXwg���"s�c96�řϊld6�S/K�8�cU��X��h��}S�kdm5��ɴzIzKY��9õ<�sFk�6hs�4��x�^�l�%��$����.�D�FX��UQ��<�bie'{��    ��ºa]4 ��+hW(vS�5}�d�|�����TD���o�r�~[�~	ʓ�qe"�T��>��(����8JL?)��@fY����w�ޫ�{Zs���,��5�k���6�))JEc��*O�K�·�PL�^8Iw�R4��kI;�cH�) �-8j� �.(���(w��e$)�ݰ�
��j����^�����5Tp���FW�wև�S�B/����1o��Yp� ��"W�8���B�h�[�j��x�,Ty�;���ɕ��Ǻu.ףC`�EI����G|�X��UL>����Ύ5�\��΅=C(�I%-sr�}�q�zé�\;���ju�4�����ƪι�n��+^;��:��D�M�
vט����u���u���k��Ņ��8�(�#����X��C%D"$�"u�Jq������BJ��]�Bu���A�h~��;+�����4N�\.�gZ�(���X�@إ�d
:����X���QtW����|vH����7�*,H���T=�j�{v��Ư��#�~�/������e�{���!Od�������r�b���|_(��yT�QD�Κ燷,ʗ��I��;V���׮D4$��^鵎:;�p�r���j��� o�g�@D!�
����Y/��Ld�?�����X�ϱ���\c�?��[�U����Z���4���� <�O"�ޱ4�c=�u���G	��]cjh�6�Q�(>�y˕�=�΋�������@n��AB��c����kJ��y;�T�9ǒz��z��5�ܥ��,��j"<B�s����tXW@���z�������K�y��V>�����pޙiX���zK�� k�zݯyP�ZFMڕP3k\���\�vC���0=��l��J�a�?9K�d��)�,���S� �� ���e�^-��ABa|�S�|�5O �[i�x��ˮ_�]-M8 ��`pKd�^9Aj!��y�F�JˎbJ^��۱,�+�s�����)�--{����+$���u��e>l�:�<|e1>`"�c>6'�V���"L	�����v]z�!��LVdR�>��V��q		��	��r[P��P�$�vTV�Q�� ,.Dj8��PXW�u��Bj,/D����@�5������
C��U�a��@�ՁV��+J�b"�;�0ӱ<(���jMfu��I+�XҴ�Q� ����
<���4��&��."V(���!f�k
�2����*Rޱ:QƔ��N�2H�W�3>�Ǵ�l��P��;�uI��$�"��a�О��� �
9oM��g⤒كq#S*����Tp1�,w��c�'ǊOC��c�'��NOv܈+#�������$��s�O��R��RP�*g�c](��{�#�R9GǂPd,�� <���c�>�c�'W���X�)�	�_�)&?�28寨B�CǚO�򝔸@���X�	�%e�R�Y�ɱ��A�0v,��j��S��覀9c[��ʎ��.P�s�ZN�R��_|�+uK�]%)��-��^�K�����@�W�ұΓ��3Y�1�����~q[X�{�n�c]���� j��׺7k*����;���t!��~VX"r�c���������C`��iC��OiŲJ��V��dF�1�%Sn��|�1�_�V��|�a��:@�
�d�ő.�� �;�G����1��x�)�=�0	;
�ׇ��n�Q�ݔ+�xZ��(�1�Gq3TC
A�5�:��r7qYP;��n��&B�AR*?.�#�s6u�XG,�K]��6vLW��$�~�:��������|4�,�4� *��g����J��1m��hxK�N���1���9=_��h������(W`A�3#sX)vzu4��ԕ��G�����%�'W��dib{�ߣ��R$`51QC��m)�7tw\s�Ȩ���V$21�@.�l���S��AOM��.��V|�6�&���	čHގ�I+�~��E����NzWG��p�X=bzL�nrS��G6�Ћb��jq[ Z�HɧmF:M@f����b������:BE�a�h0����Uk�����w\���*��n�Ӣpoϱ���ʒ����dI�f�?�I�red�? _ζ<J�����0e�? (U�ώX��M��x�!n^:��9)�v�H�]E!Wc�,q5ڱ���ɕ�u�FF�ab�;0O̅V�����Em7@!C&y/T̔���ߴfU��(�j4]Ĳ�2}�u� Am��T_�^�E�f���괋�5���!ϔ�`�>@�ftp���Tǯ,�G�C�����@��Q����}.�[�P��ˉ�c? ��2�u��-�n�e��i���^j�����.��!�P��h�w���M'y#����La��<��8��� �#�^�sXY�i+B+E��e��q}b:-�}y�`��d��z�x�^x�*C������<����[�k:V�K�%�A�Nř��J;EY�Ԙ7P�yK1!��J��T%���Lk��Z�K��;�ekǒT���߉�0,8��Z),,9�^Eh����X4I�4r,����^7b�d�&@�p�:�� M+ૌ�b�"ǚ@��j�Rj^��%���}�x��O��B	a�L�Xj[��)-���AW[t,+�P�ge���`*�|F��A��1�[n�5���$�dB�Yh�헲�ꤔ�ޒ���r,*��mȲ��;�zx~��<�%/&�]Qj`�!@��	��k-����|f��c!�~��#Z~���X��V�~�oC���~7/��X�����Y�ȱА��X�����XIȡ����ѝ���rm���~�g�qH��z���6f�<�7YM�r�*�"`�2X�e� }K?��s�g[m�|q@������e�7���5�?�-!�d'`ț�D�QF9;ף��4B"c�c5B�-�����hh'�d��N(�-��ZT�D����`I���wRY��E�U��h ��%��8֤��2�b4h�<�тՃ����H,ߒ�%�a��q��UV��?�"��\hG���"�L�ũ��fETv����ZReP�>(����C��޺f�c�̥�y��ˀ C�_l��TY
$#��Ρ�X��/�X������N�X�±�Ŧ��ݱ��)��m�XЂ\a�4���}^������U�Z��S��;g��ڀ$�v���p�����@�^,Ia�Y��/�
'���.���Y�� y�����Ҳc��&H>k?� M�p��CF,U��*����#��:s TrZ�zCFV+>�_)fH��`�F%	v^K5T ������fK�����! B=�'�	���ţRIX�PZ����^�"VI@�Ż��V:�N ����=�J�%�,G}pY|9�(�����D�O�b��ՠo��\̳�)��Fǂ�t,/8�J�aY�L��`2��;����C���N��T!F�j�!e�x��cP�>e����lIu4P�1P����l�,wH5&B�_�m~�*E���0S餕��ãP���J޼�d��uȻ
Yq�|FN�L0J��g@jR���ꟊ�%�InV�텁�Ĕ����)]@
S
��[��'Q�X�i)ij����X�]"���^G�zF���G�h��u��d�y���뜀k3g��k������ΗR�z^� ��lYH� �G
�Z�%-(RM/>��<q�Z��lZ|R�3��YU��0I5��=A�l��S�t�Z;Kn,�����t�+�S"i0��\������;���@�f�R��S��`6�^Fpԥy�IE2Q�@�yY�TM
&�gu�5h�
��C'�k��E͒4��f��<|bI0�؉�hЬ�ܱ�� ea�s��n�4	�|��_<�xA�'!�:�)�%��NV%4�����f�|yg��a��O�0bA��=��w,hFڎ�n�\�DyE��ƒ'j�aQ Sf	UW��tG�̐e*8�#js��M�'u/(� '֧UMŚ���>�������i�&��x>�_Ir��k�e��i>GX��~[ʨ�"8�w�6R� �
  _����m�%k���y�ʠ������n�!4dM2���8��X캜t-�i�+&b�V]��1i10��2i1�4��k�>u<�������v�O	����T7���7�#�)=��t`~���ܢO�#����h�5��Px(�����l��_��je0*R�R����J������aT*�cg`˕����yK�π)�I�ҥ2gǃ1�z���y��Ur�g}��<������ɞ��TOT� �䇕�o���?�q��z��2!4�i�*3B��Hȿ�E���yd�4q���a��@{��xٰ���Hf�63�6�/��L[ʋ.t	�t�@8��Q0�Yc>��۹_1�r�d̴�%ӌ�p6V̛���2��3߆+f<�r���:�7��Tɶ��$z0�@ �e����ٟ)pA�� +��E��k�[0�j��HC$�@��A������ ��\lW���lqge�"�� ˊ��n3ք)S1�38yc@�<ĭ��� K��\����LOP1tu�Z�T�]���g�8�3�f�\�'�v*f��`n/u�T14�b����+f��v<�.#%W��r��}!�Q����GZU�,M �-�P X�+\����:��0����Γ�ˏU����i(��F:+沮��g˨9�]�SC�#���&�d��yx$�t!�E.��px�� ��T�&8��r�L� �	T˽�x�ս� A�Qe!"�k�|� 
Q�3z��B�{�E���}$��X�	
*��Ȋ���{��N�'�f�"D)&�F���.�1�_�W}�eq���	=��
��A�+�0�<�I��wL8ܘh9��<y�b�tP��ޝ--�%>�����rP����O�{2��W��^xJ{��σ�����J��3s�WHi�OP1W9��-o	W�S���b~r0�)��K@ڌ`��������C��4<��E2����@v$�+^�l���Z�*& r\Y�Óz�H�[�/����H������|#�g� �H�8+�󣞊����x��vP�!�����������\$Ր��:I�O"�m[�Dl�v��v��۟�zτ��"P���F�t� l���M�œ�}�=)&0S���Du�T��
���6n��ۙD:"��^F�X��+`����$�:���$%鲰�yT����J��q(�Ix	���.��3�۟L���	?N�<� s�pq�&��!�"����+~H�Tg@��L�o.J�X!���tڂ�̃�X ��7)�5���2�2 ���q���\�1	h�Qj;������������(T+צ���y79��\��#�rO���Qw�����ҳ+�ɽ rV4V,� �1ɨ05=�ϗ/�U,�p��%�o~�'f{��W<���#5�G���Ȍ"
HE䶷����p��-��O�Oj��-�����Y��H�tA�'�}��l���߿��!�ꂩH$@�
z\+#�!!5(�d)۳��x�_إ�R��~7�MU�7:�M�3: �wX3b�=O��8�����G��)�y~I��Q1uW!V��2c�P#(��Í(x�����p�QQuPDE�  [+h�]0R�{j��[��p��aǟ�ƼS�$$�����23�6�����o �>�F!�F�k��r��T�.�y���$����b97�۩�:r� �!&�;èsY���eV��-$`=wX����/č+0��0�ߦ~�|�_�&?"��Oy�@�ۄXИ0���@�R�<pLC��4 ��]
�@���!��ꍄ_P�e�\v�8pu�d���u$Jf-�n��aW���rf�:Id1��d�B�&`n\��T�����M��Z]�}V�}é�+�>�Ii���Q��pRBb1&�S8g�% ���*~U5�P�-](��`!�3�~7�+��ut��5ߪ.�I�X]�b!�
E_��oS��c�x��2Q{Ų;`�~���*.����V����/�q�܆��B�s�`Y�%G��[���H��AFF;���r\��< ���e�K;����Zq����@��'fﮘ�z�`�b�n��=����U�e�l�������!{��`�BmaV@��J��IX���o�v���b.�
Y>�]AKb:SBS8�MLhzͩ�s�K��g3�YV�O��:�j�+�>��|�gnXyT⻊yU 1��Yd���Z��a[1�J��.����*$�L%fA�?7ڼ��iV�o�W̑R1Y����<�TSVZ1Q
^ J�#��R >�ί2��b��T�Ř��xk�C��1g
8��R�b�jJ�R�.�/�ϓB?FFʫGS�T̄��Қ�FF3���9�Km�̻r���|:3�
8QO�bjJ�"��l��t3�
���^mbL�2j����ɊV2��e�Z	���k�C	iFD䎨�����djf��%�aOõ��k�[�-��1����$�Iհ{��=L��x����W���#|8��i���t����dx���g{~���I�
>Xf������H�gꨜ�� @��L ಈ�wz{�s��燝�n-%��,U�p�0 �n֫R�q��,�'�;v�e%���0�{�+S����i��+e��A��'A�?I��J>��llQ�h�l�?�#�<�<]����\m��+K��^��	��-�q@�:�e�#�W~���f�h�.�G��^�������?�U�         x   x��α�0�����D��NKV���?���D�C�Z7�ә�x�%����R3mQi��V�6ݠ؟=�;V���[�q�}o^[/���P��Y��9I\�%��5g!�W�ѽ�����5         h  x���KN�0���)��X~籅�������S�I$�ʪ��5��ZH�Dq{"�&��*�@����'�_Nty�@����\˝��gtSt-����������l򾑩�ui�Z�0]�x>�:�R~��vf��,3�5qp��^#��Բ*�$� ۄs(��cq���>�\R��H\k��ǌtMH�k��PMi�����pw�ܑ\�4�:�n��w3��V˞k���tM�I�k~WQիZ�Ýn�#i&y̈́x��-�+�Q���	Ʉ��ؕz�԰��KB:!�%��9��Z4�-�.coy�W;媘�
XM�-1!�᠞�f�1��yW<���w]?%&(>n��+��eY�g͉�         y  x��U]o�0}�_q���-��(}�RR%@h�&U����f����ρ���)%�ă��=����6���!���o�����Z׈C�WN�4�%7N��qjn�qd~ur��p'4*�4��-Ơ	�K|5���f���F��#�˄s5�qMߡL����\G�)o�Rr�·�s7�����Lg����V6{�"��x]�-H&^*z[tq�����c�}�����b��^?���q����b�N�7Q�\q�^>��/f��x ])4�����u�� !�.C�f��#;(7w�]�-�0�?&�˩�"��*d�3��ʟ33l0Uri�\��Z�*�y	��!{
ь�-����̈�T����b��S �s�UR.�YS����R!<�%�@=�y�'�T�}��L�V�ْ��0�xN��,��|��0o��q�%9+Qn���#_���X�f@��R؎-$����_�Rύ>�Y\���;�jMĽ�����DmZ��5[wb*KDX��j���(9��o��& ᤤq�샬�4�󼔴����LI;)�RnJ�s��S�I ��S�_��~J�\.��4Ui�~Ji�A��O�	5W�4U�������Oi;ߨ�~J���Oi�@ri?m�j��O?����ut2�         �   x��б�0�9</@�M�;9�ࠓw.,�UQ����[</���!�p	�8R!�66�u����#Jԙ4R��C�S�rPPlb'�#���Y��Ƌ}ha�k�l˺��4� �n}�O]ٮ�a�x��VN�ȩdǦg4�Y|���������R~�,�B����L��$9F�h��`"I�|9�{      !     x������0�k�S�����TPP@�Ds����]�N<>� g7��D(.�����}�$ƀ|��M�5B�fr��:~��?���YRv������~������:v/���N^�����?�G�q|�v��:����F���>���y|�Z����n�,�B3%��z1^��}}clF���%���<S*��l˫�^����ƴL��ǆ�^f@�+�0�����.�+0!���3����+�����[/_X�	!N�ج0n�6�v�u���Ɂ4[��z�B}���S�PtMR�b��Vf �I���D���$>
����l��|��Pu�|`,XT�l�&\��	\c�9���Ɇ�0����>y"�b���p._"h��6I��f�H��}݈}f� O6,��|���e�)`jAr���XS|��/�?����Z�\>�����	���ƣ�мEY��td�� $'���4ə|�&Kx`�q0'�����2�vl��3�܋}��#JT"�q]ל)�����78���      #   V   x�]ɻ�  ��n
���0�	1Ji$
��K��{[��y�+������k+��fx!	��2S���y�Y=�?c��)��H\"���6      %     x���]j�0����@��,K9�NPc��`�t;����a����X�4�������\&^/��u���u`�r@;PLh��L�lJǧ���Uy�^�WuF�1��*٪$)�S��e`$�tU��v#H.���T�)��"K�zȡ�n�IՎ�X7�	y�,P,���/*�e��"L,:LD)Jl�k5:�!�=�A��iw<�+ŭ����I{�=��P��ī�N�1R����Opa98����|z(Ļ�I�/&|���1n�BZ�-���8~���q      '     x�uX�j�H=+_��ܖt[��3sXp�1�	,�7����e���{-{�ʰ���~U]��̣ML��{��S|�������8eS�c�VCh%�����������{L�C�Ht���|Z��Q�KNή�\��c������'�/xQwt��p�3�8�?lMb�'��#Y�g�#��x��,���캽��%�E��?�-}�F�%<�c��nG:ɰY�e�m8�޵)"|�WJp*�u^��v�0JQ�Y?�%}�2��MI����5�n庡�2�ʭ�;��1�8�ێm���A�}���(|�ݧ-����Z7��~��Y$x��dV~!a�˃�_���7F�x�QD�w'	�uZA�F<3<$O��a�x��TV�Eu����� c�fF��t� ��*f�D�{��7ҳwJ.dP���c:���A��~�.}��x�HX�ڶ��=너m�d7ƗD\rH�C��?��!r(�C�=�
N�3�+�b�(/6�y�����n5xR���y��E��2��rT�[ �}`#H�ο����x��m��Z�}���PhΤ� �ϫ�h�ל�������ɝ�'w<�vIR�E�y��C�9K�A��9���yT~��'d����58<�����ɒ�vP���@[�uK�*�b���Y��"�{, J��rw�����W&S��,��4XrD�, ��'D�( nZY�J�R��1�B/)�t
5kJ��>����C��ŏ���j�OK�S&�m���fUB���,�%t)�ulF���%�)c�Ӫe.!N�lB�v�f*;R��W&�������`@�B�?�pl�>��&�F]j�l�(>�����Y tg��p��,��=|F�گ��[ 4�kߡf�莝lwh�L.&�|�	K�@�hxΧ�n/�QZL^�I��<⚐�}��6pK|ŗ�{K��Ȇ���ʳW()w
�<�Z� �O����c��i�W�S����T�]\� "��k	�����R��q,��~�5=�X [�VB���A�LNʆ	U�x]��i|3lJc5���B�ҍ�et��A@`��f`em[��D�� �F���s~*z��s�w텡-7����xp^����r
�v�E��8 x��N4�l�P�ֿ_��8��I&m��et��hi�4�
%J��r����t�&��2):vM����]{$��˧E���:V�^4 P2RV��뿟ކ�6�z�qTBDQ^ ==H�=m�}�ih���:2�6x_26�ކ�[ ݷ���&��~cv�ܚ�^{�4���o5J�������0!ա���P��2j��a+S��{����9�]��91s>�&�W-������l�g&JZ5�������qϰ���]9"������ �?���3�Ak������\�R�r�*�=��tN���l����(
<�3LCu����9\�!n!4�jh����;�%���Sn/k�>���Zi4�����V�J�8.��'D�?��8�>��%	�R4� �z��RK4���WA��EѼ���7_cA�5�C��0/������)J���V7k4��nSW��8S��	wx�
��6cH_�V	ga��Ң�[���)��Q�W7Hi8g��VC���Z�1�>ӗ ;g���o%k8j��k����_�:�l��A�m�g�I�"t��5̠rZ�a�T�n�clZ��r:f$L�%�Eybt݆�c��Cs�dXZlK�LF��)��#���e;v�&[Zl¡C9Bt��#m6(�E��V�\�2�Nai�o���V���v��)d0�'��yKΓ;k�,bQs��N��[�o��T���WK�m�E\[|s+o��Vn���r)o͟����ģ3�J��^xt4����h&��w�R�0z��qKo��O��FfN�����`5BF�ݛƍ��E>x�i�����懎ky>����q���Z���ݵ4�V�5GY�,�����^>":��{e�O�biA�G7L��t�) �}'w=�6�m4L˰Ӥ�r�y�e��Ӫ�S���4) w��>Vu'�=<<�W��J      (   %   x�3��M�I���,�4Q`�e�閚�M"F��� Ua      )   ~   x��q�5 CN(402050��J�S��2��K��sS!��D����D��T�;�,鐛������ ��$��+�N#N##��������������������������������!W� ��+$      *   �   x�Ő�
�0���S�Z��Cۓ������d���v����&&���?ɏ �f`��S�@s�� Hv[)�4��ơ�s��p�m�u��RX��Ղ��i�i}��cצF�gS�@��g��D��Z���5�x=��4��~�z�Ft:������g��}���%��� ,���      +   r   x�]�A�0��+�"{�%��HAnH�(��>Ҟf����������&��u>Z���� ���A�X��;��e��,մ��YD�8��eo��3��TE#�fu�8�x����,�      -   �   x����
�0E�ӯ�(Il}t�\X_���:h�MJ�*�{-��Y�9ܹ7;�������U�
�H.���`R��$�Dw��Q�$�TY�������`����:ЌV��,SFݰBC�XTui[D?���5�@,2�����Đ���6� *�5�}+t����Xж⇳�ˠ�I��Ĳۀ&`e�54>�i�A�i|;��#t��Q����      .      x������ � �      /      x������ � �      0   F   x���70�t��
���,0� �5�tq�qq�.k���Kֈ3�����!�3P��=... �#�      1   �   x�m̱� �������� Cd7�M�1r����H��������Q�\�;oUS�=��(�8?���Ȳ�_(j��I1��D�Mq��� ��O�M���Av ��3��	L�A7�~eլg�ݐ��
ww5J�I$U�      2   _   x�]�1� �z8���|�f�,6Fi,��^�}��D�S��gp?�ѷ19T���4�����c�h9GՉ�њ�Ĝ}.����?�8,,)���U)      5   �   x���1�0��+�����9l�^�!� Ab"7�����b�iiO ��P��Z���}\o��A{꼬_�2�2���t�ʹj;!�Aī�`�G=�h4�z~y�??ȟ�1���K�}���f ��ι7�*7      7   u   x�m�1
�0�W��E���`��6B.�{ۅ���4;�|�b����=�{vRR�� ~P1b�����<M��Vjn}��^���zU������!��*�E;�x��| �()�      9     x�u��n�0���)�S����1�J�S/pP�L���	�l�r�>%?;v�ȁpT'B~34��e>Y�t�ߑB�Ac?8~���^��exy��m=Pj;��q��ݗ
��;��Q�-b�h����9�7�S�z+U�a׫��H���u���K��ܨ���/���e�������Ԗ��4H�����Av��� u���e	�
�4��er�`KN�^��?���daE�mgY�.w7U�M�ToOY�}.��      :   8   x�r�70��M�KLO-��CC\A@y#Nϼ�Ғ��yCNǔ��<L�=... K      ;   k  x����N�@����)��vvP���(�DBV�HM�6ۢ��6��&i��;�?����jP�lz<�ϫAAc�m_��i�p���Y
,��,id�:���އÿ��`�`����1�iQ�.���O�A�qjp*8�Y�&�n�m�۹&Ն{Vz�����W�v����\"��B�BAa��,�օ>�p d

c���O�65T�J����W�]�}X�1�
kV6�]�h����\@&�jVi�Ңҧ�bp���['^J�1��t���q��g�B�լ�F�E�ceIc����&
ɰX�{2M����o� �РPPc�컪q]�� �РPtPh�ZR�9���6�����Ճ�R�@//�,��`9�      <   �   x���Ak1���_1?��M�f+�ڋ ^ڣ A�5���dE�ߛ��x���y����Պ:��6��3�6�M��w��1���n`sƜg���0�gDr~�L	�[1�J�FT�t�����D��:��9N�a��)P�]v���+�����8���z�����V`x����2��Gp��4T$��b�!V˜�wbi����d���E͎7M�UH`�      A      x������ � �      =   �   x���m
� ��Sx��ר��;Aa놰J���ӹ��l���|�&<��*9H�p��er��E߫��S�1](��5��4 ��t}Օ%F�E{������QDY�rO�������Q<]xz�[�1�K<{;�e��m��g%_�6Dݷ���i�d�d'�w��1� |<m|      >   R   x�3�tK�����,�4�4202�50�52P02�2��22�33��0�����2�.MNN-.&Z�!�[~NN~�Bh�zb���� 4�!      ?   E   x�r�70�4 C�?�N##S]3]CC##+SS+N�T�WP�D�q��!��	������ ��      @      x���]oɮ�}��W�lN]��Շ�d�@q�{�� ω<"öd(V���o���ղn*�;� _�f}�,���pu�!�?��m���_������?9,�7�u�n7[�\��o�տ�/���G#������~q,�߻Oʭ]����3e�����y�z�d=��a�~����y|v���~�zٯƦ-n�[N6�?q���]|^���h�]�և7���N���8��u��~���������B�/�"[�q�}w��?����������nK��X~?�x+:L�Ο0&L7����⫌u�:L��mf�9�}�8���7����a&���ߜ�Z������ߣ�Q&�m����k��s���ߒpu����y|h=9��q��#�������GE�Qя�Z=�tv8`���a��z��p����	����/��Ηj�A0C/<6OM��;,>�0�z�9����aN�����c$��]��i�~A��z�~��s^�$��n�Xn�٬~r����n-�i�q��tyv'AZG��W녬�K�k^ڴ���_��>l9�z�v��q�k[�܍cxܽv�y"�"bBD{����y��^S"�'|t^����#���Ǟ]�(9\�4�׊;��苘���~\�^֏�+�#�X����;C4A�ɗq���(�7�5o~�|Ӈ����q]��&A�il������qMgy������#��qc��	��r^��7�~��-A��g��ֳt*&H߻50�%ξ�3$�M����A��w'�8X��!�ۈ�x.k���8�8�H�=�fH?7B$��д����qo3�X��e�5��#vA�!��������5����Z4�����w����dˡ��WݣĒ��`������R4�ï`�����*��è7��E��Xl-=,�lvN[���d��+nv��aϧf�p�d5.m�J�^)h�l���.�N��3OKh�m'J�7w*:��XсU�����W�*�����G���}V/�YE���|���_�e�ɸ�zm� �I��*��V?|G���༵6����ldMƢx�^B����-�8�k�'��G��Zo,ǡ�kEU���X��p�@��2`��:,��
x�>�oe�\;�끍K�(௻W�a0H�Q�{^���0`�.�ՀQ2���F,���n����uٽ4aG{m��������Օ����AA���W��%�$C�͎5��C��x#g�ɻoV�jݳ\�62�x/��;�"��q1�k��������v8v���m�b�W6�G1z�zD�?7�j5.}2(ؾ0�б�[�%�L�3������e8����M�u�����F(���.)#V�-�Y�|�c�`=~�l��Í�p�\1\��I�2�M��d�q7�Y�� oq�����Q����t`>n�^��8�c,�ڮ���)�k���$b��?��'��ݚx��9�N� 'q0�>�+�kTx���޺�9���Z'�"��Nc����߮��2�7���T�,�����xIGd(�G�����u$����{�g���� nБ�y�i�>Pk���9TZӴ7�|��ٰ��$�ϳq˽ZŌ�W2�^� �d�U���ְ�\n��ϫ�RpJQ�g���s��<��⨏~� >�����$�<{���%����o�՛'O�����\-�q����k=N�i.\Nu��ؐ���y=��������o������m��ǩ�`�(�q�OZmߨ5��M�/c�ܳݤ�y[ሯ�y[?;o�T�娋x̱'�:��g?�����ݳ;�B��Փ�5��;�}��"[J��5�2N��u�}�Q�߸R`Ի�� �Z�w�ӭ����NL��A��W�k�W:��x��W:����������$�&��G����_u�
݅Q�a&�ΰ],��Ӆ�C�"k����ї���`���o���ё��h��i��+VѨ�p(�!�k���o��=�]��	�5�0���Js�5zj���F�CA��ͩ�Y�7�'U��j!������"���iVj�;^#�/��	�G=����O�-,�|��q�0�	;��q��뙇�G�sD������8���q(������P��o��2��S�<�����2���F?�|b�i����9��Gp�߭�wgtQ���#Ό>�j��=0'U�#
}Z[�Ge���Қ��:!����|BH�{��8�iF�d/
�ǩ���:&O�Ӊ��e#c�P0��`F(�qj䘮jf�⮜u B���_�g�yr#�ʨ�@�W6>#Tʈ�0Y2�W;�uy޺�=uE��Q��q<��4B�<�m�P0��b��z�	ꬷڦ��q��q�����L�й��sE�\�����#�-!���Y��dA�з"�v��a	�;&�P���+�yj�~�z���rJr#%B��z� ���"'"t)m�.�b�nƭ�!]8���鉮SjW�ծ�K{������D�_�h�-E(b��w�r�0B��ͮ��������{�S�.�?�vo�\������hh��?�y�}h=#v+5n#�����2"jH�v�N�݈�!����i|�����&�8GD
�9�8>�Υe8��p�2Éą��EX�;i�/o.F�g�gz0�G��E?b�Np@D0O��TG��蛼+b�oڽ8O	M����%P���q�] Ț�M���C���C�d��:��T�	c�5"�A�Z^~�y+hI-~K�9���'aČ���|s������N�kaBu9�\�s�@�]��+!�ֿ��k|�@筯)�θ��,LO[��h8�P�34�R^̱�zN&^A�MG�+�7W"�A$�vk��vn=ꁼ]CD���2Ȩݯ_�5��΃�2�p�']Ƹ��H��Q���:�W�Ñ"GX&*(�F)��5>f4�� ̡	�u��𭭠ݸ���%A~���d���^�rD��	�+$�:�}-��w%���=����C�W!7("H��Gͯ�F�����
ITi�rC/�DD 	���>>ˋ1����uO=��?��a��H4"�G�D��h�������s����&s	��cM.��%z���,"�}셦?�o���B�x|�-s7
�$/k���t��!������i몡	K�7���n�RD�� �M��h���+^�C��6���<\�E�)	u�;����nK׀�<��M��8W�Wz:���< �c�������!\My��1"&I�߬�Ch}`��s����\���G2f;.;|h�4Aw�B��_\��$�.�Y�d	2AL�w��g2��cI��9⾳?r�q��J�r��&�ǒ9��;&�/f��Hp%�=��Ď�����%�f���k�L��P��q7<�.�Q����z0�D�mV��ɩ���I?6��D�[�J��#�0O�H���%8f�֟_�P����w幱�D����SGQ��(���GQ�������"RN�	�n��R�������P˅ƏJh�k&����ٳ�K	-O��4c�3/H�M(��&X�I-G�ȿ���`ʿnO&IC��/�d��I0�ޜ�"��A���%���#��`�%�K��������$��	�������-�#'n�%Xh6�v|0|�k�$X/��Ɏ��	Ƌ�_wOtO)��2�Y�~�`������K��ӎyd,e�C��+�8^̄���]Y0��wa� ���d�:���Ȋ�N�2��d���@H^#����h��o�j�,��Y��|8^|�X>b�_��)A�N�=|t�R(!4��8��]���`*�{������R@S��ӑ3T���G֓[n�,��=����E�T���@Fnرx��#_���P9�m��"ę�~��{�dd(h97j3����Tu����u�q3���+	JBn���y|߈��(d\�f�m����Z\�Gz�7CONm\G\6=:�����~1Zz��Z�`B� ���Bt �ls�o���9�4��Qz���&�D�����)��*b�E�6``��ir��.��1��W��UYZ�d��    �+�7y�{s�����7�����wf
d(]������s�f�.��]2t��q���B�����%[�#[�34a��r(M�/�f���_I��?�u:×��|�gN��'�:O��#W�2���j�\��-τ]�+U��E����v��usg(< W�p@;�@f�7S�Bh�G7ã+Ȓ�ݬ�G�q>ç����~Ü�Z����wV�8�Or7����p�
41֛����W
�+�귗Q
<,����w۟>�m�l�ؕ��R��{��
*�ٞ�]sD~�M�����"��q��Ψ
�|f�mA�љ�=gJA�� ��t���)�Ԛzr�܋z����<r���刺�Ql�5��v�a�Jf��YZ4��r�1�`gW�׽@ɜ��u�B��=S��-�Z��Z_�d*���~���/Z�׏��,P0�;gjup�P�K��WS�Ͷx���>ռso��B�o�����������-[҅�:a�2n�O\��uD��z?��#��0ɛ��4i��;5i/���S���]�2��䰝GN�QE�3/���q8�PS��P|��z([$'s����s#��v(���ٲ�թ���On9y+n�y6юǢ ��s�ſ�����Bt����X��J"���b����D �P���Ӥh����A�V��]`��cD��Z`��4)0M���쒢)~��� ����$.0F�t�`�4���)AL�?.��\ҳ�����N��>n��U@��:N�_��3^��\`0�`*0��� ��&��lvyx��.��,��7?O+������\ݬY����������U`	�w���&�*C���[+���k�Zp���)[�����޷G6�*t߉�H�/V���h�9Zp=�t~s
@�@����@��
UW �9�Bѭ��T��h�r�V�
���:c��XՕ8.�P�5I�
���ŧ�L���<>m��r�.l:��J�CO��qO�k�>_�}�b��μ	t���hO4�b�7�e�l���궺zu��V�����32z\�+��j�8�C�bK�MUq'Q�a����@�1����-�WTg^-�h{�T(�W,*���N<E�fQ��O]=Ft���睳(Ft���("Z��վ #z/Ꙛ��W��<��u��zхѽo]�"z�㮈�V����ׅ��QU�]-t^SU,�0I�~WU�P�����Gf�U�L�ܪ��]	C@U�k�\�@M�槠������ͮ�R��TS,n7̽U��T�fG��*4<�\~�jz�?����0����y���1��?3F����Lqdh�������*��v�[B��x)�^t��n�WX�+�އ��:���[Ћ�N��T ��>b�e�YނVЋ�3.)@,�­�1t�fW��Ԃ�,v�wg��]�u��}��ۮ�+�_��9�zU��㜉`�d_xZjOs��.��F`&O����}an����k���Ao�J�-rm�z/Эx��4@��x�� �1�� ��"92�����8a��� _E C��l��W�(Ԃ|򾾃�4p�y���h�Cs��l��̅��Z�`�Ο:�A8@�����q������/=�� w��~h僯���9,�����7���P��#=��`8��<�`�J��+��TE�4��t�Ao�m5����PQ�v;�Y�t���ׇ�����!2겇�ah��eNb�ʩ�Wn�<�o���� ZW� 
r/1B��3@4"p���P���tY_~�[!����7����t�A�F���p����ehB�]��S�������p�	���u���/:�GSA��x�zZ9�ݹq$�+�ݲS�L��м1n�ỗk��dW3�v�m��t����y��(�C��&�9�	9@IP��W���j��K�FO�+cds��̢"�0ʥ�H �����퍏N�S��t����oP.��X����}�X�T�I<��,*X����m㋏�IX�qw�T�	�R���M��f�09��~)H�&�ip��Og��.n�Z��ȓ8�6?�z!Yk1=�H��8�Ů��B��B}���c�y7c7���+�����b��<�eY�����"�Es�;j���������~ڸө��Tߟ,/rL��.�����x�P�I���pM�E�JbH�ӈ	�0�#���K��*��)KiD�X��tB���2�#k�d,�V:�ֳ~�\i�^�_��
���yj�"�!72L������W�H����)��؝Riz�(���L��|�[->��� t�6�k���kFJ� ]=ְ8��͎�/06�mQ�T{34�Ǯd�݆`jei��i�'���5ؐ D3A\|X��f�Ќ�������`H"2��L�H:>�S�6+����AK�h3��~-��9�!��,��eP������]w��+ם��o``l��܋[�B��]k��9�2.��R@,���
�R�-y	!;[�!�Qp�g����m[��wՄ��lϝ�$ ��OK�ѡ!_K�#�ɜ*u��"�<�ݫ'qk�p�����C��"�>]T�D�=����ٺ�&0��>��|37��u��f�ⷺ��*����|uޖ0Ғ�7�3��kM����ĕePt-u/�m���a����후��|�f�1�	@`^/��/Ȑ��*��`�ڥ2U�Ep���,Y�^�!�w���d�Qn�l�iiPim�e򌩍��҃s�h�p��'E��)�~HA:O� ��Q�%y=7>f���/
�n/4>�l�"o��W#�i�qܭ��w,l׸�8�H�q8˦K�Y	WGK�kjKN>C����_ѯΩ�!��2ɰ�8�X>3��Fy�vE�j)�N�2+����򃜤�[��~�8�FE�V��9?2��Ý��@E����ƌ"�jB]_���?�W��Ǟ'�<���A�)&�],��@�8��~�)l�-WO?�Ol�;{��b�Ƃ��� ?�Qƕ�٣~��v��k�t0�����|u�`u-����4�o=�l�B���p'�ͦ�OgAs�ÿ���s���5���4� ��c�ΐ�;�3d �э�ѿ���^�}��Zl���d�����G�摳��d��`b	�'�����Un4"�7^�u:W�B�+�WzO�@xd��/�Ե�:XVV�w��A��@�+V�ژ�A6.�gY�(�����w�j���J<�[���ˣ'bL�����{��s��#���4z��@H����D��`��9�u�.M	��� �$0�we|�k7t��|�.pܟ��n���f'Wz��O9��w�f u�뢉�p���s7�<I@��]{�kPȲ[8Vl%�7�`uE�'��bEQ{J�Q�IO���Xr0hh�*��"1*���@�2v-��*�գbMh/���;T�� ��Y�}����$v1$ �^Y�/�khT�<�UZaS0�>@�H��RD��-q��kU���n�D;|�!H������j5jjv~M�55i���`���ƺ.3��i��@ԡ�&&��5��f{��C�M#���JlwO�VTgRɹ��	Q�j���?���8��A�� ��Y�z�=nd?���=�5+�eZ����W�Ϯ�N�X�ߩ6fŸf��Lc���qz]�VO�%g�����円{��}?���9�ˀ���艥 ��G�:�`ų�xZ�1"e{����{�킠����a�;���հ��s,��"��;���ްL5"�`T9���핻��Ֆij=�w��!ȟ��9�wȀ@�!`�ӆFH:~��zw��>F��u��C��F}7;�����	@�:��I�A�O�����ބOL�U��.떓2$ �2���Ю�h�����2���7�<հL�{�k��߻oQcT�M	dPi��8=���W�{(ˊ�0����,�'���Y8�z`��G
��f��\��{8�{un[(R�������6�v�a���-W�{8�{̈́hNF�x��g�'+���    �����V��k��
��i���@����N�*��j��G]iT����k��]&�ܗq!]Т�F���vڻ~d��=���W�{��%Q�yŽo��A0@*�&�I��C�����baGS=tyCy�T��D1�A��}ջ��ݛ^����mV�볘:#;��Z;$�������X���݃�t<>Y��`�P���q� ׫_�g���]��2F�4�$Bw��[2r��ysyK�`"��qMt�ٲ��J����>+��j�����٧�� �5^��Y�7�P��I�?vǗB_a�v����7p�<>�~t�q��	f�hsS6��_��3�@���0�� Z���d��	��]���Z���@u4z�a$��ٍn4��o�-mBa�FB������.#:v�q�:�o\q)��a:'�J��j����uyް�,j/�8�RkZ	�nTց`"�p�a�O��X�6c�a�ͻ���2���h�d�0^�"i� �S�r����J
�q�߈������y��VDO��q�D�6hE��h����ѱ��-;ێ8k��C�qn �" /��4�az(��#�,�2�!H�I|��	]5�d$]�=w�K��!o�ի�H8;oBw%+�C��A]v�|&"����r>��kuv[%2���^�U$\Mm��P��Uc�ȦW�2��t�I�u�\�D<}���<ό���ݽr2c��fs�٬�F坻"l���s�FX�V��w� ˮ��1��s�֘fZ( M>"*L��}?��
�>�Qrh�������؎-��ʡ�Ɇ��Sr�}L��i�Α�p�Еc��!K抈�3���	@�|�����O7�~;Z$��v���t��h��o��]0Њ���䂱V����[k\7u����kP� ,�⒈�\ 2v��q�;���p5IQ�	��VB�fư��F�n�E\�f�����_.8�Ȋ��:>"Z�̂+58���p�h�7c�"���e��*tV��������~=>��G�AfMX�w|�H'�_�S?�Tt��[q&j��4-�8���X1�&W���'��z���D�_�ΗX��~<�g�i�;+΀�N�H\�c@Ǽ��V$�Kr�وB�r�����2��AlW[Z�_��ZS�+���]�3$ �i�Fy"�;�hq��#�l2�zɷ����=��n�x^������m�	�!����;4~:����L�K��M�;�r��M��ȟ�������\�4@1����E3$ 9���4	��t5+db1���?�%�34�G�<��%8CNh���zH��H$x$��4�f���	�ʽǷkُq
��;$�'����;�JpN$���Ui5��� h��E�)�+�B�s��Յ��~3�">U.�u�=�OW��B��'{���}ݽ����6�5�L��Q"��M�Z���?t�I*J�\uFEPK�|�K��\:Z�b�F��F��?7�IkCP�Q�K�Դ��±�LB���!H++ET��0���tl�t�y�Į�r4E1��_\�N0��	�F|�k�$�)Zol��yY����Q#���s��
���~-��2m$i����_]U�x C/Ⱦ^��d�;�L�U #�֞U�5���m4,�]xGW�P���ӌ��F��5�Z7�ُ��lm%c(c��zδ>�xS+c���G&��uaޞ�:@b�vO��B
z��t���lC�����r^�a���K�����]vV.���T6�������Xa��+�c�(G\Y'�s<'h�ä́��s���1jhB�9G�z�_C���,�� k���|�i�Y]�U��N8I���p3$ ��	�Y�yи��61�v�y����y�"h�C	�Ŝ�GV��yT�4G���R��;73ΐr�f��e�!M��.�P!��r� ���/zƝ�C
��zT�n�aT���.8�2��<�`qf|Do�q<$&C���h�����Df;REa��|��z-�d�J6sA櫈�H�*�g��%naK�Z�o�^:���z��x� ���gE2�%��X�W�zP-��~�W��~Nn,t�$2.���୞	=�8g�L��y�2�_#ao��ː��[�>Cnde��U�3H�
기}���Yh�4w�spa�������~P�
�1�$��P[�m8c
e�^�1���1BJ�[А 9ɜ��vg�3�
z���������3�v�����8ZF��>�
V��~��q���{�t�V����g�޳]��:�V� ~��k�Z��=��3���]4w%_!R�ƅ�;����)�3��m`x��X��}j �(� 	����� �RG+ ���rڲɍv���@aI~�r��t��z�f��O`g���0j��������]3@�CS��yx��<77��9>`ݙ�^S��LT�����=�p�P�r�[��w(+2�ut��+	@4��F�VR�+q�}.DK���e�(0��}v��D
,�V��L6(7hg�%��>r���;pQ��K+�N��n!FC�����$g�d�X��E�������t*+8jD̰.0M���o4#G�qZZ����{38ܙ���՚��-�&�[gϐ �L3n�Xz�݉��{_H�ޱ�������(��
28�[�OD�/0퀌�vP��\C����v��#�[�zF���Y��eg�F���H�VOE!)�Ks/�6,��.0�Z�=�Z`���[���X`R	t}�a�����3$ 9����p��G`����"�
l���-��B���G��]4" !�W�E7t�>�@Gҳm
��b=?������:��+� �n�!�?,��Q�	wM'_�>�%�lk$����Q��z��mhNҝ�b+����M2B+6"�7�;)�jXv�J��
?�Tk�_ݮ�W�E���53�+65�R�!ȗ�^�	Gd��q��:��Ɵ3��b3��]���[�[�͐ uel�Vl)��c���bKQh�¯W�(���Na֊��Zh�-�s7���ʊ�7�]|�|4D�]|NV�j����*��V��	b�17��3&"��Z����;��Ѹy�B^[�aI&�<�k�j�ٲ��b�2_�`A;+w�e�T���	�t���k����#�&�f�!�m�Fˍ
$C �.[�s^�[�Uz�^�mrKy�Z����iUn��B_��qKo�\r8Wxs�kٗi�p�/G��|�&�������V�sj�o�~�
��`��}Y�ԩS�(/�jd�� ߊH�:���ؔ
_�[�ː ��J����W�~�8>d�o�'�Z�@7�B�;��cXj̓�ӑ`E��Y8��S�����S��'u ��b�\�����o�S�s�gz$w=V8okZ�s���wS[�Ͽ����&j�o�V�D����ԗPqu�餔�����0p�?��F8���Q�V~/n�6��i3$ �H����u�9�1;@�L��I�����t4Х��/�-�U���8Qf�_�=��}��J�9A�ti}��
�z^�\S3A���<@E��:���,���+;��%�E����a�M � �H�.�.�����w�|ȓ]����v��!3f@p�	y铆3��� ��q����;b��ܬ`��^��T�}p<g/<9���^�����bp���_�o��k_p2i���|>��0��0@��u��#���+� 2��@}9�9{�>B2���?��Pa�K��mÂ����|G�x�5��o<h`��P��Z1K�&t�k��zP�m��u����	��� ���ֽ<�c��c����2�xSg�2(�>a���*�����ɉsਲ���]�ǯ�w!��Tf��ӊ��9�EH�)�']km��6������ѓJ��
?��~�3�Z����e�`�M��s��l_]����0'ǀ� �P#axl� �n�-���`W��?��X ��5�;�`���;��C���ii�qdHɆ�����&��O</� ko8�����U ���v�
�;�|`����y�G(x��:�4���j���x$����s�_|ΐ D]    ��u�!��ݯV�8%r"���@�n�U�X�c��㎚r�_S�CM9Ct/��|i�/��?ߝ��`�Cݍ��TO�Qh	��Q�~�� �Qn"�lL/���=��:��\��s@�B����ϊ�}Z=�s,ԟ3|��|��=��@(A�����A���߼����&j\��U�Ɗ��MT���s�_v�C�9C.�~�Px���Po�8�b�S=Al	f�/�,�&&�K�*��|@%��N�hzk�ʌ�=�ٮ�Ʊj����p|�^� Z��=���S9�oE[���c\�X�bE�t���ݗ1<%E�Аw[(���S�|�zp��S�ML����.�+� ;E��3H��qY����
٫oPm|q���a��=SEC�[�|�ܵf����{��-��*�6jT>T��T<Tƙ�th_(k�D��za@�BChS:|��۽x��h���-�Q�otV.�q�4/�h�b��!�X�!ޕl�*(��4�^�a�0�W&��a�KTT�|9EIA�.�2~)l`i/����=��ph t͢��/�}�(+�K��BSb�Iz?\���f�;^�E�~j��q��/��*+(���%e�Q��'���i��/r�P1X�>MYr/�M�b1B~�	���$����8k&�k(�ؾz)'z�������C)��}
�[PQɿ�._Hc�|b�UU�=��o�Pq�33T�MP������0�J�T�e�
J�}H={����g���7:&j�����km�Y���'���n=�
~��"\��e���U@�-���9g(�uI�I@�-�L����@�-k�;zPxK)�y��{q����bA�UE��9��n��a3��mD�gw؊;��p"�~�:l���TE�wvT"��$'�w��1N�s�Y��v�.��x��v �D,��)9ze�C���u0�;7Z5t�����æo��q���/��O:l��lw����14A��\��_[/���tFt���v�;����"z�=�P��g�T,��y2��h	<�M�a��,����vٮm��H�蕦XpS����i���($],c��nf6�����w�κv�``� �t:lg�.��:lj���+��w�����+��y���?C(������y�hii;��*�v6�,��!�ৈ��=�~�M�A�:�C���@5��-t0ħj�xޛc7���ʡAz=�����(Tʮ'�����	~9��r<��|ex���*�<J�I޿��љ�qb-��#	f(ã�]�u��y�~
�Y��Y�-\C1�3d9��Zä�h�L�s�:�u�״8N��((6�bCņY�ε��e���	�
)r3��K7P\H)ť~�Н�t��F�T2��OT
}�#���k2aP_Hɖ�x�e!��@��-wKj�Q�+T"R�/f����v�
D
i�,�1��P���)5|Z�V#�)��l�E!"{��
)����2C�/3PfH�;	�u$!�Y�ޣҋ�*:�RNjb�����B�i*h�:D�m|�η�z�=S��qH����,p#�D /P<��Q�+T>R�z�ˑT>RH�y��j����ݩS0���G���Py������(�fs��^	=�$��]	��>�*�����M��Y�Ok��i�f�V�~i>'�w*������5-�)�zm@'%/m�����T�<̐��o��j����)S��ߕ�@��]�d��ٔ�=�N�&�[����@��oL�(�2G�F;s�������r���t�9����]f#�vI�k��.	V�C�B��;���������$c`�>�9���б%UC���E�� ����]͟�#.k�h��nO���`]uJ1��P��ދ��a6^�z�w8o�&�&ʕ(d�S��KJs��R�ѥ��qsUKB��B�W��~���r��}�Dq��/z�J"5S�Q�#�b��^Lc@	E�Ȁ�3P$LE@d��+b� c�	��z�n3Q\���Fu��A��g���2��/.�z ;���(+�Q��(�ۯۈ�^u��QDRU�w&tg�k��'�ߜ
c�.�	}�ZB}�d�A�a��NNŀ� &��OӘ��"!��ZT���[�;�V6���Eo~ *zC����Fu��Wo�>�A}{�^3k�4�Epr�@ƘA	;J3"��;,HHup@ �gH ���a���zv�h`Ǥ�ڰ�鉉�������w8�!�� ?�����ǹaP?A���]kF��0.�3�-[��w��t�C8�����`[��H5#{�RDaTJ��%�]�������F&��"jP>B���R^F�\�S�@Ε,u�A��RkH r���h���qP�PKC�9zG\���9�uGk��@ޢ�.�2>�1�	@n7�!��!�zP�v�9�]��ђ1�5J���BiX�DpTڳ~J���j�
�@XNp�!��2�$y�
�UhV?#��*9<O�eX�aOt����yr|̵3�b��]�-�^r%�~��&�T�ĝ+Ɇ ���+U���Ʈ޽�� �zp�ٟa�����T!��q{�Tf���4�=dh:sw�<S��M*�q�=w�4 �v���Eb@/87�	@ls�t�j6���G�\W��5��sN�����y0�!	�ǧŽ���b�����Z���u�G��4�4fm�k��_W�z�K���@���w=��X��[����v��rh��a�=�ۼ4�oee4)�/�H����g ⨗��N��⋳��X�E�|{ܐ<�B�F��`#� ��idR"[vBhA�4�����b����T��)��+w�S�&K{��3���.��gÆ�Q$)��)\۽��W�I��=X9��r��еV�޸�������,@������r�Q����<w{���[Q��k������!����3$ �[��`�x���L�g�ݰ��_lV[,��z��'y70o�r�O���}A�+�*�T�k��uW6��[W���zړU���Ao�㇕��p55�b`�����c#c�}!��$˅q�C���g�9�q&��/�*�&&�0��I��ѩ+��x#� �����Έ)p��[��i�ч�Ob<���gHvGʹ0H�X�&�4ph��{*o�hV$�9z��Iٍm"TW S���ԛz�˛|�Vr�}�'�_���Z!z�5�㧃�G�_�U�:x~:s���yV#�������<�1̴ֺ�i��	�ґ�O[�\�4�����gt�'���� ��]8fpw������׾Q�C�l�K'��5ӈ:x���L~��<}IFH2��&�5��tKK�:蛍ǧ}�������r���Q�s��>I]@.H%A|��/�)&L-�[���)�tu�^��H���iH 2�)ve�����X�u�zp�������g��I���Ż��#��ӽ~�p㽷4��S��1���1�Ђ1��-^<8[��������z���ҝ�;Frx���:y%�wԑ4p��oy9���&��]䴣�D*�rTWd�";�";s���7�``���dS7�o���熆�9�)!C�=��=\���ԐcH�?��N�����������8�`:$x����k�F6���py�4}�F?>+ƀ�������ϙ��z�B��D��p�	���V1j��˝Z\���)�n�U��������j�k�T���NWﰞc�ϱ�t��=��^/�є�u���rrQ��{����Z� �3t[֡e���{#����\k
y�I�3z��n�!���j�tg����������oQ�^F��č��qB�P�ݠ`C����������/8��EU �N�[�ף�b6]�[�oWoDy�k�{)w��Ф��\C=����� N��?nh�uE{hսE�|��� �4M}y%K}u֍�5$ qb�� =|����ߓ,����66Zk����7&�Q�Rj]8/-���.��jX/3�{�G�D����B낻����z�    �}���"�C�Ui�^���	�e��ꫵLJWP� Wa�0
"!{���T��N�
��o[y��=�F�$�iWj��u��9��
T0b�ŤBT��U�z(V���:�@���'��Чz��!�!�v�A	З��B�Z�mI����Q�"sٽP#k�����<���m��c��ƂH	Uw� K`�5@��<��Ǒq��ՇW�$k��s�d�6:� �gƽ�S�$:0��s��4��r��_C��*��']!eB�B8��ǲ��2������R�c��?�q��13���g1�z�o��{�����z�~!2��G�ڦ�CaLn�V��_��g߽�@g�Ӎ��ђP�m,8�>�ŬDh2_n����Di�$�4I0M�tUb)��`�����B���������A����� ���Z���y
	���PY���p(�����[NϾ����	VX�+,���T�u�`���I���=���#�2�ӟ�埮:��d�����q�u������4����6��5?	@4�=�L�;'�^�7���}�cCcR��t�J-�{ &�����uG��G��k�+{tO�n|�T��w�T�8��1�-p�������:G�2��&���7�L��N|.,H�x$��(�� =GJ��O@g�Ftb<���̄�&eDO��r�|���B���dl!�4�B�Y�gl���I�NƾqĜɓ�_�c�̗�Qd��=�z��y��_��-�B���f��S�+/��1��@���/�����к@L�Nǚ���u��?*�r�CM�_v����1#3���o۟ ��<�#c��2X�5E��26=A��=E@rQWJ������ �{A�^�����t2gl�G��Ӹ|%1c;���ܾ���l/x�s�������BQ�`�n�枼��6�Km�R�5_����f,�G�.��l��At�w2VZ}$v��B��̾O2�'���O�h�I�S��΁2���Qbde8'��lX>y�~�L�#{!�\g���y�G��xC=���),�\�b��%dt��E��fuQ�6��v9���Yo�gt�&�z��"|�r��dm��#Ý�-g�7�3�Jy�@F'�C��L�1��bn���N��G���d-�[��e8O@g-�[��N��T|Or�(������J�9�{�YY*D�:$3�Y��h>9K��� _W*D_�*�r�!�ao2T��v��Ow��NDA��++bbX�1Q�?Ç�g�-zh��C��'	��������ud8O��Хr�h��>E��O�����Ǣ�Sp��!��q�!���qT�!t�Rb��"�'>��N̾;1Ý�ս��B,�P�F��r#^E%�ٱ�Pn�1��!I"aPt��1�=�͈�y��nƬ�gV�gO�ƍ���hɸђ���\?�:�`jY,7?�ށ+-z72n�(�Re\e�z���kSnM���2$V�'��$e4��r�B�[&ٿe�q�D�c �D*�yo�qC~p�=~����L�]2��M� �&��M�}3"�_IjrC: vY�:� �&h��9��DTm08�op!꽏'Z�˸���#�,� ��I2ACℴ���30:�������1i:!#J{+�1��!�L$[�#���3�c֑	�#4W��\��M�%��k}��W�_`��>�����xXg�X�[�a�db[�I�T�b㾯��r�Rk����|ӯ�N�)�v����z�*8��0��,���n��܀E݀?Ą���gF��yjL��qjRx	Nu�!i5/
����FF�����^D�jp8��8_ߡ{ݍ��S'��K���p�&?q:�C'�_8�ܡ��/܏Mn�������O�����Ϝ>���ί�n���ޯa��yW(�qMQ/w8ŻO��>�����./ =:���m���V��J��KE�K��g���r�:�G������۷�-�X���uZѥ��T���T�U[�����|��3+�F���K��8fKK�{GS��&�wow��k�����YD��x��}�[��n��p�\=z���u� S3Ci:#{�K?T� F�0�m	��zq��q�[f:y$W��xN:�\���{k���;5�����!�Sڙ+�6WV���X""�:��q��v��YS0���*_�>i\7c9�}�Uƪrd?����XR��:��k�3sh=�R���d���K���=.�2~�]�$u���@"�"�^�UA/ⶏ����)R�Pr��m�rU�33�1��UA���r��W������٢��4/濗�|	W���OM��]���T!��^u��u�]��kA �Ϗ�.}TE�睙\1����W1��pG��9�E�٤��������JT��bs������?Ѓ��Л�7��/��IX���q�v@8+_���8CAzOMu,��0v�m%�t衡�8��`�
��wL8��zh_�$3N�#�-C�I��D�x��А��iN]x_�5>����|�%�Z�ps��0��nf��Cng��F�-?@���OLP��~G;
���R�҈B��':�I t�G�NxAf�S���Н|�&����Q�X�w��,�#m�`���Ɋ=_jK:��WVx���}��>	� 	������t
�yS�v2��3�+�Ng􅆤w�TE���}���Ά_�m:�W�+�F�wU���,��O�
oќ�S��I4�T����T�p	���z�*<A�I� �p ���ߧ�����d�����/\��itwE�w��u�}�y��9�ޱ޷����FwW$X��Ã�q=ƪ��ptի�3?�pt�)��gͭ�p�ct ϩ�mUM#�����)-`bx���E�X��
����-+=�A�j�cx�v[��.��'�kZ?���STb�<��![�W��^�
�V�����Y�^-!��c��u�^9��m�ý�9�-����"���K���1J튴��V���xo���fi�8o,h�����젻�O�4׫Z����й�����V����P�bD����ډL�p����O��c��W ��45s�QO�ۆ<=W6�E��`ڗ�
@�A�[1�FFG���
�^Ռ<���	?���U��8у��d)��Rbu�<+��I��������/[]q)az�î"	�-�Z�K��W�bЪ+��.�C<�
Rqm�� �t�����{~G��3X}�`�g��gЦ�i`�������&��/$��p�_xK\��i��/=:���#3@�ō�
��>��c�4���T�B���N� �w
x�����
���)����U�+]��WH����
y���^!���Q�+&n�_)�5\������uA��}��
x�;�Q�QY��+����k����!�2J���r�^��삼��Uv�lQ�<,ev��|tn-�6c+ɍ8����v��](�k�WT�r������+Powz���r)����Z���3w��꜊����͢�o����QǷGߗQC��v:��ؙ%�����FδPԷo�uW,!j�� ��z��^}M�[���g%x��y�a�t�xj����=���~���a�trmX���-�;&�.�F:j�0u�$vu��+8u���_$��r�/4��hp*�Qyc��u�7F5�0���MI�I�H�l]qq��ɞ�@� d|�ܔ��	\�d{��~�ʊ���n5�9�����_��,�^��լ�P��;�uU��K,��:JT�`�E�0)(��`Kqa��F��H��ʅ����ʶ��+�>j�
��,ɦ�q�~~a	�Ks9_k	n�����x���n�r������s%�C#F��o	�\���Y�"ƿ�c���)��\@��ߪE� FN@�:{��4s[��}R��!1䣟�'Xk����z��wY��Tn�3_'��>��YpG@����u4�Y@����Y�����D}|+��
�A���z���Pd�|�'�I�!)B�㽒B��q����Л[C��wNF��j'K��T�jU��,���
k�-%�"�n�ɑ�U��9�ۋ�CE��uo����/��iT: �kc^A�����_��]    �xS�]�V+%}ܾ�_�[�W���A��ڹ�,X�=��[,(�09��D��?������y	@�/������4�����%9���/��4�����ա���GQ����ΚP�Cb0?iE9��о�����L�e�ڌ���G�#�מ���߿ul��c�i�8]�kh���N�YfM�Z�h9s?�M�|�2���u���9�(�5����f�'��0X?�}�ᮂ�d�p��A�L�A�[��$��E3 	_��$�SD�OxRʀ|����؀|�$S�Wg��SV��q6��؟�e^�Sz���ڥYE�|��2��|D��J����}R$ �%
�#8�C&�Y%0�.�1�s҈b��Y�ԻT�P��T,7��\b��B����+}A@���%4�߽8rM���~*�.�"��~�c�Z�� WՌu]d~*a�۟��E4���Z��j�Y��Y����
��Tx��(�td�2y�ޔ oJP��{Jd3��� �J�Y��n����v��W�U�>��R��p�̚ɯ�*Zڋ�y{�zZ���������D�{���*���{�Z� ��R��7�җ���q�۸�M��/�����i�.�2	̥
�~���ܯw$Q�Y�`��U�ݨ�<���J�檏ݬV�����+���H ��4�I����:��u�px�G���O�W���vOG<���3q0�O!��( �wh�g�YTA�.����3�| H����=R$���%��:C� �y9r�t�o9���\�n�Sr����Kh���������u�y͏Fj�ZO��ߺ���_F�+9��bD�����L�F������������℡wNG��F��5�5Z�����Jw3�A'��ŒC����2����W��8��m���8��;׈8�z�3zly�8�z��*�)��������c��E	BgF�	� N�nez0�b3#��GDK.(�Zc����$wÏ���V�qIga�k?Z�F��E�����?*�G]��)[>��n����T��Y@?9Q�J��I �l�m�(z�W���k"��Q�H>�zl��@\�w;»ͻ=�wd��pnG��3���e��=��.Cv#)�Y
G���U�:������o�Ê�CG-?"���NJ�r���׳�D;����36�����{Lwdn�̕�m;{�p�F��8>��#|��x�RRcZ��w+F��/��S1�q��$��
�v���8�V�]�z�"<�]|�咔����û���z�u�8���]�N��ݎ�WoRB�S���Ќ}�`w�+�A8�?�&ZrB�{~�I���g�E�O8]y�YO���`����{O#���,zD�"�Mg�q�(B.�*O)rV��,Z�������'G������6i���Y�uV���E6f�!P�{t��v��$�����	�З�{f���r���NeA0(�A�rl^P7"$¯��b�7�V>��O`�U��W��
�ҳ*����jfܲ���@��B��#ܦ
�="��0��F��MA�d�~9�F��|��y�#��'zC6���6Asދ�{�#��ì��r=����0B�M`���Q@�#E���~�ΡP�H����!{q�U�f(��C��^���BT!:b$�G@"��5oͳ:��G��O�!Cw(� �"�<����0P��A����|����=��֣NHS��_l1A	Ŝ��o�uR�ٍaBᛀ5_��Eo�q�X �n��U�J7��tP�Ɛ��P�F�� y�����Iq����
�Q��[��G�Q�Fٖ �
$������vgF&���$x����Kq�@���c�׀@R�ng	>��_iHp	�y���`�'ߠO0���uw!0#��?e�!��s�f$X��Pgd|��n5��.� ����`9��1x�kz��sSf�'�����IvOO)��\�u̵��n�ћz�BD�<mV������<'���$xN�j���:9b�[��;�B�hJ���-�������2]
l>ݭ�`Ȝ��۱
�Nig,�vU0z�mnO�S(�N��P:�Q�h�E�g����tb�/�D~��L\!���`)��O9�%�2C[sI-P����{O���j���$��1��	TH�y3��up9�)���w�� �H��F}�p'���6ԝ�
�����T��Ǒ�!�B�2.��j�_�fӮ�>	&���0�Ig�X�	v�)�Z�����Z�z7Xnr�s�92h�p��?<6Y�:��+|��a�J�tv%W��jN��|c%������������wy�I�־�4���kA���uy$�<��^7�JF��C(-�L�>�E�Q)w��݇[Zt$t�����exʀ.E'D�	w�[�2V�� Ip�$�b(	�#�"�HB	*���p%�y	���,�7!�K(��k'ه��=�.0�|OL�'&��
Hy��$�sO����ɸ2g�&��t��x����@�oH Ү�ҰAC�	���u��U�0�lX����� �VĞ���ݩ{�k�Ff���k���,� ���
���Ae\n�U{��A2G�Y�=�/��9�Ԑ D/�kPH��n�F�hToF��?�s�˸��kF$z�O2��
2ӂOt&�!�woD�A���}{֚ܨ6$��0>�~_�����OcT��%���ו��sߍ Ͳo� d~����jj�����J��icH �,�WR���dK
z�;�٘�?�Mpw�&tSjrh�!2>�����k�޾4����g�e_�GM��|�4$G�T�uڕ�/�&�����!�����1�q]�D�$�zP�T�#��H|�Df^�֫_��ݛ3/fS��x�ƕ�q���"�[���ސ �n��ɹ����t���e��� 4Ln�#.�L���Z~���H���������������1@���"4@�k�A�f&V� �A=��r�Q��*X�ְr|��w�k-V���%;�I�sH��J���cL�UTgq�F� e�Z|>W���������2*�Ƴ�Q��ԪKc!@��N�	@��*��r�1=�;)}�5+���U4TV����swe��fYz��nl�⭙#׸\PE�@����9�~wf��޵�z%d��C�9�ֈa��U�;�ӂHvUz�Ȱ�*�Ϗ����T60T׸�R\�D�!8��������7O\���)��QC��ڞ��b�@}�݆N�N�;���mt�kct�1�R�*���PP��kr���ՠ���͓�n��`\�Opm�6Dw���y"a�Fv q�z��IcB�yv�!�;��mgI�qw���A��pkf��0>�)�t��q�<��i48�mqK�-K��%[�{��nR;CK]Jgb�E����N��c]�~7.���J��ĉV�10�����2=s�L5Kf�8��X���o� �l�[g���M�^�%ك��Z�bzO�O�Ys�]��f���,���[i�F�c�s���\�������E��}x#�T�%O�����o{=>���l�<q��|����X�4A���!r�dLd���rcHd�Ai�2r�aP>��a���$a��S��ӈ5)�kRĚm�ɹ11�"���܏�|�g���������/C�OlŎ��zC����nz�w|�����r%�;��$0�8�^P���3brƙNB���M�z�ւ6�z���,�Λ�9*�Tw�9�Y�
�����epz���-"&�{U̐ D�rq�c�����8[g� �dӶ%���`"4� E�����=+���i��RdC�PXt4�e%����.�:3��Z�3��#܎����Ru_D8�%��o��y��{<C&y*)��S���ɢ�}�:s�00�UƸ�%D�P\Ge��R�6hbC;��`U�V�F���賫V����I0�Jc�駧��fO�f�� �30�Ň�bԣ    �soI���͇΀OS��Y�|��ɐ؞sxٞW�0&�ej�7���av�e�2�;�A��3��"�2s�	@���q`>�����ͥ̕�m��A���s$����?�����5����7ou]8V�T伎����56Lv86�/�+�C��q��6�Ǟ�U��K�ףMR�����uաuH�)�n\-�͛�%�{�i�B��)��#�؏d@'hHG���	J�`w�Ѧ�P5��S�6v�sK�L-@5��;=O�D�S��z	�Q'��^�B�{�oD���]Z�h�H�<'�y��<� C<�����-Y�4S�6�!�Ŝ��v@�4Z45�LPL�ԅ�r����=����OGn\N�H��~TN>��K~��%:��N��V��	�c@��}�v'�=n������G�]K�t��v���i���������NΌ�N�6��ͧى=�yqoX�B�~�8�T{�IK^����E/K�~{�<҂��&�S����L���^~��5b�E�l�H�a	�um�[D��q�t�gL�w7Ah��{�(���a		�I��
���F&����&EgDy�%��%xޢ��{3D�:	�N�L���ag;�����j�&J0v._*1.�g������H���ȕ�1��{���өS�|�+	�{3Đ d�Z|�2-��hQ��%�ϑ,�2��hLl��wC�I`�|�F�F���vF� i�jjk��\�p.��푱�#��
a��b���4��V�sWA���Zp��?�$*�^/F�$���Aoî> �;T���@Z�tWH_���pI3}Ӭ���h�ЙZ�	�Ҝ����>�]�I�1+%Yvl�:�e��;`��t�9�4��º8`rr뙄F�pI�����X�U�Z�uw�0	~��>�4h{�oD��n���3��+��K>4�[���|B��UF�ciM�G%��z���!g��������u#�$D�ו	@,�Չ�L�n�����K@��?�ߘ� $ؒ��'��y�g��e�Y��f�p�r��s�83|,yw·e��eN:�~����^eL��{��Ҙ�v�"�2�+Y]'X��Vb�Q�#�^�/F6G���|��ZR��c}{�8�~�,i�������	��\L�/�"kզ�����pj��.���i�o�HM��&aM��ǝy,���xV�o ����@�h}��Ҙ�1�`n:�3�Y-`+:LW����N�^�g _��y��f�~�[�)){c\������e���:i�@�s>Y�кA6|�[����@���*�a�g�D�0�A�V������8͊�U`�ހ����ne��y:� f����T~3�4ih1�-_P"z�&���0�RI����(ZO\�%��"���:�X����C�i��?�����
߿�n�B������:���v��$�r�Z��#�ގo� �^�I4kdRםq��C!a�&��u�@n��>��VC/��6�͑--��`X��m�`��v��L^`86ڐ�C���;:2y:�e�;����32C�����2�+u������!���R�b#3Hu��܌�`3����
r�v�w�] `�ݑ����"U4� ��!$MfH�����7����F�T�e�L�4;�1�8����M�$k�i�����D⍥�u��>\8j�Z�Ꝅy쨠��f_�,���o�w=0�l)1��[�\��~˟���ÊP��Z8s����7�ږ ^�xil��c�s�cad~|}� ���wEn7�6�9w����d���A�<��/v��8�]'W��"�y��{}s�Rh��@&=��0�q�82�l�.��.eX�y�A�N����3.��kN%PG�9�!��dK� ^=�ȸ����:�u�����"㲎p� |{ůg\��vi�/��������$u����c's��>��(9���͢�3�h���x�G�[BP�6K�ZoL�/�1G"a�ǌw3@�nz��9�	�%�0$ �����lpDH�N~���k1n�H�����a� ��%@wk~�<Hljwn\)��INm@{VC�'BQv�"� �|.߸6���p�ם
�8fp{9Re9�օ�gR�|Ħ΅c��T>/�!�!���$�	�I�dXl�"�L�s��d���rA�p�z�{3H��XvI�J���~���s��D�G�.p����l89�'� 3�ڒ�p�>%���0��x�B#Lr��c*O�274�c�gH�S0�s�a����{��6��]{�Ь��ʬ<����ߖ�%X�zH����Z�����x�X$ߠh/@됙��(�{���|��2`���:�������2^`/j���s��Ƌ%��*0��y��*���LRbm�����s(�Ņ�]��_ȋZ���Gӑ
�ml޶jzpƦ��?�.�?~�̣X`p/�����.�(�����tbO(0��<3{���R`}?���
_���KX�[�+'���b�֞���^|#x��h�uw�����Gؿ�p�f���wA�a��#�ˬ�w*����w�kG/�~�k�;�����YF�ʓo���#��� �Z�����1�xѐ�i������x���WXϋo=/��r組7l fK�v�20����}����*z�-�[��q~DGX*����6���ZI����+0�ۋH|�hF�HXi.����3z���$|��K����K/�t���̐���QOп�ɸ��]|kv�5���DqVd����'�F�kv�D!�Z�#mĺ�aq����-�y�8�;c�#�Pn\'G�=gĒ�����o� :/�@J ��3�Z�,ނ�S�i�g�ѻX��3-eT`�HbP����{�J�D�^p��n70�.���Q`���5��6�������\�.�:�w�W �9�bn�4w������Q��ϊ����x0:N�WY,׎_V˦��+P,�����N���}2_���K���i^h\�o����Wc��Y��d��R��Q)M5�1o��-���5�t��կ���4@���	w��{ADrưb��O=)�&v�Ԅ9������j��g�-0�+�
�T`�/�pK
��B���5.DR.@W>���i�4̃�(��9���S����;�BE� ��m����0흻�7L@�Q��&!� ���O�@�
^�b���'j ��ī��Wh�k��G>�
U�.Uh�4T���W��*�:*��sr�*tr��E�xX�y��\U(��m%�R�
~��n[���E�!�mX�q�2�Z\��W_o����j� �S�������Bq�$��W��+t��s�zAz�U��u5[e�6^���m֏~�M���#�ժ���s̞�m\5'�~�_��}Z��D���ۿ���#�ص)T���mi�&nd�0-�^g���*U�?�M�ªP�*VVAL��)�:cf�0(��QO���v���',�MZW?��ϫ�?L��L˃����-N���+����~/h�BM���_��FP��a�|�yUu��;;�*tsa��H_������V��u����c�>�����z�BGF�Ў��Wh�uu���+_�#�k|��sD��*�c�.���4�
ո��h+��j�����Vh�/�rWh�uV��9c�\��B��s��#�ЮPgk�*}�v�R+(�� K?ȌD��jQ��֥�{�D�7c�>M�ɪ���^篧�Vh{���*���J*l���:�*t>��K�.�	������`@ib4��Bϫ�{����S� �$e=SK�f7?��[��	w�hD�bW�0�
��.T��p��`8X�Im�̻j_]U�|E�f������ʹS�߽��b��W��ΑR1���x=�������++ZW�j��4���UheU��xN�
�L(�7��
�lA^:*+3AE���؟�����U(e�[�i�B-�2���W��aH �3�+`e��[�#�X��,3����o�g�gϷӳѸ|�qË��)B;Rwɸ��Y��5����5�c��2G    k�F�zo^\<n֞C�~6��=�9]�g�`ظ�dd�o��G�����[k�g}2!���!�;F���֛<���>�N���~���5��������O��n��9���'NZ���B-������	@���s�: �c��5��Á���I�{�"����Ph���f����$�W�o�B���Et�$!��5`N	
�c���D$���yد��D�UaV�ې �oJe� na�vn�䳈�td#f4���#��=Y���u���9�X����GL�2�K}@n�0��LX���i3�O����mָ>5]��*���΍NǴ��et�/�%�CZ �1\����f�8 �π�iȀ�qIJ�2����R���vM���A^Z�3���N����z�{�&,ғ_xGaM��q�4a�&+A����)	@,���oy#f�)�iH�_��Y���&��?&�4vبqy�O�x�{ĴL���y��_v��3�G���<���np[>�
Կ���ַ�i���L�7o� )'h�0�oh}o���Xp�c�X*�IƐ 2 U΍@z�k�Zq<�$ h�Gs�ABd��V#3H�9C1������N�:�A=��/af,��k>��v��au|�+��eh��9Η�j]΍Ԏ�������Ki�a
֎cz2$ YV��^�x4y��05���)���JK��s|5����vVR�J2�?1
�X��*09%_�������dݯ������YY����DR#��A�ķI��>���H"�J�7��mIm2���h�Mg�-!<�|�Z�<��[�g\�!_�,�-�%���46G��OƱ�����]�K�ܥP�,ms�����v�[��n��LN�����i0gdJ��:�Ok�U��e�?�X����v��V'{y%5q���v'+�ɲ�*5�%���y�Ų��c�4$ ���b���ְ���L�,��\R���,��1��ojX�흴T}rw�8s������W�}��ٸ�z���?�>S�P�W	}�~������]�-�ň�ħ<m\δ�>;Z�����¸g?9�������B���|<-�%(�"�4�x���hh�cPִ��I3�=G��Du*�i�q����y�F 1���h`�����`e��%��#����j ��V&��Yڠ��>s!!�o�0?%�Q��b��Ƥ�񶿬�5_@�������%t�h�8����<�$��iA?���j�$�#z0��-ߞ��mYҮ�,���3�o�@�m	���i���䑄v���'��Ґ]�h8�hR�a�|�[)��w� �K��[ў<�����@cP��K	a��F��ɹ�&� JP���=��^*�!�)���54��Jr^���|���IΟߞ����	��1JgX6]ꉛP�a�&6�P��W��Cr�?28��p
��w�2��<)~���>MY5������ّRˆ�ge��胭$���������������	@�ּ`�QC�$�R9�Ogo��c�#~Ǎ2n��tr����q���p�Y��c"�����!��kl\;~Rw������&��,��}~Ц��212��Ǚ����)�)���K�7$ Q����V7n w����Tbu�o��_�?9�}>����U�p�|�&� gEHN��1e���	��vY����Ƶ~EoKa����F#���s6�>��9�Ч@���[�ݮ�������N��;U&$ 1������� ���=�LfC#P�cϐ���[3t�w%X^�~z�3�~U������t�#u����6��7[[p�#�L��7��>sf #uj�hY+p\go�g/`m�q�{��~��'�@���*M�P3@�
?�L:4DG,��k�J<�n�{�M�V$�Q�#�CaC�~tf,�C���ݥ����C�"�԰2�X����s�s��+���N���,��2,���kdp��A0��ٱ��t.��DJ�Q��W��4��s3ĥ�HKc�|ѯ<�d@ ��@9�À(��!�SI�����jw�����S�՗1uZ����4ht��(I5������b�Iq��6��Խ�v�0��sWrĬET�qb���po�L��"�X"v��u@p˰�@��τu�Jh�J�����G97�;�1&�?D���ꀰ����mM��+'��IJ[�?]�I�YĔsՈ�"؀H{��'�p]?J�
�6�\�ZJ��{@,��}��
�>5H��gD�~�ɀ�An�裍��Q˴��m��s�R����F�2 �d��Gq����JF�_���׃c��k@�`(�=��b"��4��'�Z�%g@��`�tI%q���S}A+B��ې#Ĭ�g���]S;BҊV��J0��&�&@�
�ƍ�[��4BԊ��qq�Liqe6K��>)���6gF��K���Y*�q0����Q,�������0�����AO��Lq�ȸ�#B؊��!l	b�^�(!s�}�Ƃp2.�9��9��Z�L�7Ű�Y����\�٭}Ňo�zQ�K�):׫�F��W��0B䲛�z8��dL��o���'���,]Q_y\��1�zuQV(ݸq9�<{��>�R\��fv��}�=�~�'U�v�k�1����1�uX-�É�� ��Dy���?@�s�����Ĺf��3�����Y���w��vGŷ�J�|��i^�e0B~�����4���E][p�྿�Z������E,�f��=��>@���D�^����b{��y�>�<���Yn��I��gB-��C8��Sq��a9u�T�q�l�7�Gĥ���+9.��7570ߝU�0��Q�,�V01�.׍�9���f>O�(̉V�OI��=���M�������.��O�Z]=+B�d� �ަ�N� �#4���cѿ�_t	�����}g	_mZ�
PB�ƥ�+��']����q������������L�|��m��I�~�]��7���hB�GU���(�R3��J��'ǓzS�3׉��F�u�W�"�:A>n_���)n�]��/Ӎi�h�~g剆Dhwz5�v��a��{������..�:���1���C���I/<-B���Ӻ���b��9��d�5�q�z$`�m"L77��/&!H����^���uf�g�f&^~8�iˡ��<:�:���E
{3��ꉎSO��x���B��,�9�ǡπix�4��w,,��Uٍ,K����`����I'I'Qk7���2����qhD$�Ğ��#�"P�2�B�h�g�-��A���A���#�Ob�Q�R�����S�$'ZZ�I�V���c�4|в!ԇ�6�g����C���^z�2��`-x��ok�B.�����%��r�`I:�����s`�#�P�shl��{��ܼ��'a�"��}ւ'K���6z�>��R�����y��X��q��w���ۀ�?�?�ayO��/@���"���W�ŐĬU^����!!m���M���m`�:�G\�L������k���H!�[�K�+8� ���GD�P�޽�������q}r4=�Z�#��]�O�����7^숴����28�f�Ll\D��=�\��Re\�9i�[��p������+�7�("�H�se"�����<�9�+�4��_���:�,����4W|1 ��⃩j����[�gs�#��b�1rͨ_ʜ�󓋧5�8w����WӠH}*,Ki"i�DDNO�sz"rzAIz'�("�'.sJ��6"�'��
�@~��a!4'}""{'j�	������y�������o��ZD���}
�3�-�9��>jiQN���ދ+ֹ��,��=�y`]�����-�	pO������Tʈ������m���&�B=�o��3"Q'��:�:�RJ��t��t��L=�Ȗ.�v��W�� w'��|��,a=��w��G���C������Hr\�߉�a�Bk^hY���=��F��D�/�ǪnwT,@�!o�cP���������'��!�G_E���f_���Wvl�g���IJ<�?��+&�.�7�Md;^a^dg��D�    ���pih8���a��ŗs���V�4p�r���_�O��#�������)E�|�	Sq��64�M�Ąt��)XO�g�ȕ��C%'��|~���������\ G
���It��
}*� �h_H��=EJ���,H���&I�G�7pm�H���BD�G�,�6����5�π�d�܇>��DĄ������[g2����A*S��z%�"��O�̓s���Q��B)������%]s	2�4�ë���{��1�AD�V���LC�������C���߳=a�N�^��iNiN����{E�:EK�qnA��*��?m��D�L���h�*��%�j�pZ���qe���|�lVD�S<Hab���N��:^iOz}�O>8_�閕���'��{�<���Õ��w�A~������q8��5�
���~o���I�/f'�Eȶ_�@���ЧEƙ���E��߹�;�"!�	�	�4�D���;��@��w�&�C
�Q��lx�yB,d�{|����� ��>�h߄P��Hr�/�)���e��c�	����.z6ބ0��&�&ps�B�F�y�	ᅩG_q�6!�P�j�F7��eB`�^�^�=�ǒY8ߒ%�*��1�8�C�
�-�R��ͧU�Ⱥ�� ��������%ۑ���c�[�K�r2n|�K�������h bZ�>��gz!�ie;vZ-wͿ7Όض�(
�{��2g�i�IT�70���o��K�����j
�m?�4�%!�)Y`�'ޔޤ��]�Q"�t��^i�0q?^�&��cB�S��⟒�H����e�t]r"vB��N%�h'��_*�0�;!�)��Xv��KtJ=��l�XB��]����9"��z�B,	aN��G�IrH��t��3�i�	Ni�D�h[	�N:��q�-B��yƟ`�l�6[gzG,97v*!v*�r������^	���I��Jb%M�Y6CB�R���=H⧄R����K-H��J��,��O?��n��	�S���DɈ57�G�A�7���>�ΥB���l���C����e�'J�m�~W����K�>���c�O���y6�5SM�t�M����n�e�Y7ϲ$w�d���qWE���5���^���!/��C#�)�! f_@���b��b�)QPg�f�����fL��N�V��x�lR��y��o퍝��Y@fk����Ҳ��_3q8#%[��4��Rx2��싓�d�r��k�'��9<=C��|٧qRH��d�$��ں��1��5$�"&ww�y�*bZ���[�9C�ɾ0�!��sj�~�C�Ts��u��N�`�N�!��Acf���G�1J��񺷂=��ɕ!��YL��C��R@���)@����K�t ڭz��%Cȫߖ���qKm���q�k�H�υ�f���a�A����`���z�@��q�ُC͈C���Wk�<d�2�*d���e �{�ǒ}��.pN�CF�i�PJ���Z�$��+��Ff��C�#3bP���Yi������9#5[̪Sw"#5k����o!���5���z0)��9�]�Y�O�W})#5[�z�C�D��2���`)��FiQ�6�脌fğΗt�B����k2�O���~�y�oʉ��8S�,#�T�M�'��	v�A\�M1�ُQ͈Q���w��[E�~f��L�֖P:Prɯ`�������{N��ҩ*�!�ow����5�2bR�AK������ݴ��j*�(�6�����T��y�3BR�wqE��tX��S #*5#��}> 68	���Q��Kȇ��~�%�=Ɍ�����:�@���b�����j^���߰`/��T����ۿE�q.;��_b���5�rkg$i�j� ��a�p�BF$l��Pm��=^ֿ w�*���S���⪵�<�����==��6T�#�~iFi��E��#'�ݵW�wGl7�H}�����k�������y�G�gĒ���Wg�7�]{w�S@F0���w�#x1�����y/㾞���=�;3�D�����(�ݼ�!A�bFn�<2��:��Ō��<#|Qozf|��m����>	�;mA<�3#�,�QgQg�,L�ޅ�3�w��m�=�Z�j�9�����ۏݨ�_�7�B����<��p)�g9,|їTBZ^ĕ9�5!hY�t��۔F�f��31W�g9��i�}&�lAYeF�@���l����O�U͆n�>��c�ReD����2e��(��(#A�
tF�h����!0h�BF�P��%�$�y\bF܏b���v"���V�<܌H�^Z���gC��,>'�#�G�y�{���F�Pg���t�r��6���_�8��� 2)�����gg��Ҝr��¨e�������7�琼����������Q�X�/��OL{R~X��j~=s������RZ�()����Q"���pk��J�䱬�!>hE�g:�����9tdb����_X�t3@�˽w,`�%}cޔ�X�=�坂h��;pO�~��\�QGhAY��;�
*��1m��Z� ����~��|��[����P�51��/��#AK3�'�7���y�<�/n�`ʁp}
D��}��C(p���V�r+s+q�:+n�wp��U�ۭX�+f,�eM���=��=���M�������]�y��v����o�Wv?��4�x��^�Sѳ�������z~���
��)�v?�!�����q�BJ����Z*�	vE�qĚs���� ��}f�E���0A�`>�..�|s0�����+�4��7��i��Ѯ����?�-K���u^..iW�ߢ�Ms���6TV+���}�s���%�����
b�V(�|��`A�]�a��w�s}.��͏/�+�Fk
�����xQ�������i9_4��gZzg>	�'d9����z���oS�/��L,p��^<��U��W*�{�
莙���b�'ݤ����d]��S�� .�y�y$BA�XAg��g^e� B����ޝ��)��������纅�¥�8�y�KPȯ����������2;y���o��%����F�B��g*/�
+�ʳ���X��D#y
��`����1{�錡OŤ&Z9ni���>fs����1�)q��1΄CX���}2�\?�R8V4�Pk��f���r�1�9@��O�LA�-}����� \�� H�s�N1�@�q�f�۲g�Wm&���h�N��a�y���O��o⌷��2������{�zLz=�
����sj�����'���4<��z�������&CSV��E�l�g��+(8����r�JJ�1�F��^�٤���ry�Z��y���_������+���.p���¼���:�����p204���y_Pym��~��c�������)�Q�ӷA���{���$ YTD�6tT"�4��e;AZ^���_V���;���+�`k)�ۺ���.�̐VVJ^�M6�� �w�ց홒�v��A�n	%��Ž-���x�/a8W)�O�V�y�iw�=��'�v�}C	�|����+��<�����Y}�.﷓���ܺ�s��Ӄ+�ש^�T/�~�W��S�S]H���\���p�tm�FE�~g��0̝>}t�U|�^�nTv�O�X*�XP\JF-��?_P\j���]�:���E/z2-A�1����+����G�v\C�)ZД^�f�`������Qj��Q�<{�)�Z_�m~y+<��[��@!��(�(=��:d�$������G�o�����V%��n��pJ�DI��i&��PtU6|V1J�����!4D�]�D���zʃF�p��k��N.��t�+|�a���^�cA�-��7yҿ�g���p��Z�8?�Ϭ�4/]_P�K5���hy^s?�s�S�s�gv���~m�{-q���n7wA���e=��4΀-C��?�� �F��7PAPM�A5�Q�6[Q3_��P���v!}�8    ��~��;����{��!�f�tRǊ���ٓ�)�5�W�r�f�+�bS�i�ނr`EKXY��7@�O�g[��6��`�r�-�;xJo[E]0e5y��Z�
6��c:A9���Y(v���s�x(6_����re~�G?>� >�,�m�O�Q¹�}��N��;�2"�����WqQ`�S�Q%��b�B퟉�1+��K��`�/6I���aPv1Ys8�}
���o�EC��������QiqIZӤ ��ab#��/���j[?	� J����%-��*~���:[����;pM�{kA���Ŧ�*��U��x��J[���-����$����V	�Ґ�L=&���U�=k�C����t�v�2�I�l�tC)(�%��)�=m��֏g�%���w* ��;x�[�n�_ٓ���r9ҧ䚚O��b�P�y�>	]�s>�a3x�`��嗢�ŏ7,�7,���s�i����H��ʚ	$�P��o���Z� lm
$�㳳-�)� ?�_�(	�|��4�u 
�K���.���W�)�pN��ʰ���e��'��p�<��Ja8F�x�	{y��Wg�B�(k���ݨe���0���,��`NA]��8��1��+;�Ч�\����f�^R����WBc���I\�O�lg�s�\����c�<2!����
53�/��I[t�g���2����".�����~'���oa���a�,�������
b��i7�Z4k�����W"k���I3K�j��K�jq@\�`�)3}9N���Z?�5#�C��}][�kg�S�2a�U�ٟ��'c�@���&�����/N��}ZPs���Oʍ�c���<�����;���@ �t�1o�9����"7�x���P#(GKC��H�:�#�Ǿ����W��}Ԫ��`G�F8S2`�c�î�o�B�Fbږ/4���}�tE�O����B�Y��iZPH�>	��-q�t���{�)-X�׎��9��Sg���_�ơ�Goj��a�i��&�6�[�J�i�ܼ2)�"n��q�q�բ�e�țT��+�ŕU��d����ۯ��J�^Q�_�Ϗ��}{��m�+B�uD��8�\=xD'��"�_@'h�"v߆��$*"�����*�����{o�Q�2M�޷1�Z}n�wX�?+G������h���=��X���"Ⱦ�`z�rDE��`~E֊��j���%�����t�'@:�0`�v����p���<U\/�Tb�T[\�;m�TZ_�N�Z�$�dEq����"�X@��WD�^��Aa�J}��;�3tc�#�=w���"��N�{��O7qVi�AD}�)�Gѿ�o��I�O	ts'!�"����ۗ��� t�eT��}e(�����@��WW-a�~~޲>�A�� ��<p:vZ��s͊���:+B��vZ�UWD�r���p�|Ep��O�Ϛ{�*���j�ȹ�]\����UE�j��V+�Vk�y�Č��c,=��"b�.#�δ^��^�o�Y�`u0+�V�1���e���TD���P�,�]ձy����`�༊�j�b4��`�ZY�iQy����Α`^���L_�?k���%�&]����W��.�8Z�'��{k\F����<}HY�;'HU���b��a�ϩUK�>'4�E���:������s��uU�Z�`���X-���.��PWk���r�.'&#l��uU�Tzؖs�U��z��V]U�����+�A^W�����o��X'=.�Zĝ����yxeˊX5�{;ˤ�>n�MEX��Q��S[�"o��Wģ�t��٠	6_l��B��§�_H�F�|�F���P��5������hG�6(藇ͽԶ�֠
)�HL$˳ATP�B��x�Fh�)�j�u��D���Y.�4����Р�Y��Ju6����R��
�zS�������c�a�p�A{�aW�kР��<2#V�
%����y�E�-��Lgsg7�hP��?�����nП��GkО��'6(O�L��oHG���60�[C2�p��"?��^`xCN2���o�J>_o=�ә�v&a�L�&��Y�>#�ih,h����w����
���au<�4p^�>C�/�g~�NH������OʾK�c��ϋ~�<T@�>)�o��j���G���g7�7?��!��Yb�Gg�"��8��^%~#NG�s�Q����A�i��ې\.��lА\.�o�F6��ܘwnH2?@߻�V����Z��3�4$�7���gޢ�!�\��q�I�����Ċ����u*�CZ�4-�����p�do��J}f�����pq��<�|�T�y�YN�hœ�������{6�+U�h���E����D�y{�]2�S�g�����sU�f��T[ڑ\�B�mJh-����E��X��F�f-P�`p�^�R�wr�5F���7�oT&n0I	(1G�I!-o+��|�øX.޷�B���\�H!O�DWg����|a�X�I����,1ܫ��`Sk������"�����m��	��(�6��K��>��f]d��55b����z�Q���<5���v���\	m��5�����1�Ż�m}V>L��G�C��{sC�55����3]$��T1��snȰ?^�zCC�}e�m�a1'��v>�1��Y^sC�$J�G�	�#Q$ �`Y�@�ܭ]�������	��i�$���Eǎ��eZ1s��x)[��!�b��o���ܾ�����{5C��8A���I_h_z����2O���p|U�n�d��3ٍʥ匾w�>?7�Q�'��$;��S�	@�:F���
@�D0�����6#)pJ����"veF0��n���~��%X�,�
�nT�mt�����8*����G������}X(�b}>hmH%�y�y����4�ֹZ�
��!�B��P��"}���	���)�� R�����l�?�;F,ɸw+�2#����;���.{����w�Wph�*��,�9����s� ńQ�4E�K��&��/��ATI��v�ꤷ*���a�#�{�8�Tb����_D�W&���`3EJKQ'.��F�
̪]h�tN�~��i3B�>�
Hg?���[}�X���l�jUXf:P0? m��h��D�m0ʑ<����*
�s�?�����:#|�B[Mx�?��1a�Ĕ'䴻��7�)Q��{����Q*���)��p�|�D���=MK� ��W�FR� ��)Ah��ͣd9�F|�{ӈ/{tl*�Y����):OX ©௪���h���~���ρ�%V�O�B���W���[�>?�b��P���=��g��� ��3�N�H r�+�����,cM9-��� .5�ܓ�2V�Pqd�7[��t�g,�����T����oG�T��k�:p�?�dc���d����<I�p�6܋��p|{^IW�xpQ�ٜ�i�·G��X��n���1S���E�߯� B5�*���N��)X�=y��`%ν������$[4�;���²�_����C�|+qY��{���ZV����ٮDş�l��_�\<�\��t��
�l��^L�J����煷(��5^�BU���*&���Lks*g���>ϰ�	�wfU��z>�A���Yt��ReKe����m�� ,y�ܰ����N0�@�ϊk�V�O��J��p4D_Fq� ��kH�/�Z~+��=�?�eZC�����hOm��||�f7� �z�|7��6AK�+��H rc_��Rn �����4��������(� ���t�|{���Z����/e|X �"��V��WC�����w�nR��^��jǾ�x���}�yp�"}��3!�U��=o���B� _�ma<����t>�����2����o�n�ψ���$�lq���	@�}������8�luK�WJF��A<Q"�l�k�,�e�V�̵H���X�T3@����� �V��D
����������e
��$����j~�Z����n�X���1,Y�ܒa������)���g�uZ���{���˫J���������b匔����    ˩a3븯���C0$ ��/k�e�p��0&#��R��30&����nqv���{���MdH�
���L�0p�gĐ ��z5b a-���O׈��_�x�c��K�>���裣1`���r��7+e�}#��=g5�t�4���|�qfK\"�{�q���D��@�\C�4h?�뭨t'�����0ۗ�qq�i�V`�~>v�/w���k����a��	�x8��&b:�C��ż�F �1�ro`<��h\��,v\8��Έ��7'�P�/��4���8=F�>�o�$��=��[�_�WΊ��O�Dj�<-����r�ȟf����X��3�|	s?�T�32�+�}����E�T��V7lv>�H���X�	@L� ��`�pu����Im�S1۠��'�5;&��G~��X�wo"�7y#ּ��"#U@4�Ԑ������/İ",� �ZgH b��fD�� RNR�ߠ8_n+�*Y���	�e���/�#�6~q�!��q���������~�˿`v
�/5���_t	��ު;���CtG�!��_��ΰ3j!���I}ζ��b)9�7C5ޘ����m�b)͆�+ҙ����S[����X��r��h'�T�Q��c��Z��*�5z␪���;���r�uM"ˍ�0��\^�4^��tr˟�#PHa"�*�`�&=jU�5�J�TU���C�趼���SEV��˫�jH "�utԠk���BC��@��>��@�1b�:	�A0����TN����m�C[OFI+ N���8'΄�&V���(�,&�@'8i�kx�8I 3~�
,�;�5XxB��d�ac��F���αp,��΢���A� D
�;� D��]}�ʖ�P�mD�י�;����0�M�g#Te��Y���}�@�6�6�Ac�h �@�]��'4,���
A� Jճ���0�H�� �� �5]�t�f:h�Jۼ���Ƣ��1������!.���Ӏc���q�i��jO�݈�[<6d�����6@AV�By\���	y�p��|����u3$��q�2X�A� ����ep�͔>����#�K^�����{:�Iw{0� �̊�y��k��:�z�X�al��[���1��n:@7�ӃHr���F���M�6�"8�h�y�0����'��+)s�=��٬_->��I��w� =ѽ%cyZ`��o�q~��c����ૢT��b5@	���7�YzoPn?��
�Z�1��ƺ����㭌,�\�v!6�΄ZA�C����zR�X��p��hC�|��i� ��� L�,6�yy8��9~��5��t����|�+����bŭ��zV��>��%���c��TA��X�r*x�|q����S��b��^֌�}���c�Ї>�֏�1Q�b쟩+Ӱ>���b�pL���vG"̃O�%����wk��7,/'� d�tF�a��|tV[;��5,��n�W�@ �H���(�BlDq6���
���ڰ��\k��a��8���n���%���p�O�P-m�Hp��B���$�R��j�τo�4���=� l��	Q�􊢻�DZ�IO ��8���lt������ФI����#������B�6��%���]���nkr�8F,�J움���n�!e�@A���6����x��x�>ܿP�� ��}	� ˔E�p�����	u,)��z4tiDX�om��6DS0'�/&e�p��D�F������7�5�A5iq\�8�٤��\�� ��YӖ��I�Z�#���L� �"��,�&�wFfB>��TMz1��u"�:n�0M,�����T
A��"�Tj��n�2�&�.M����;�a8�=�p�� �n�+�Dh���*#�JA&!���N�R*j�Y���r{9M���]q>B�ķFGH�B�0u#"���'}��GrE�0�(�7i8k� ����hQB�"8��~a�F��2ؓ��jġ5���,3���P*B��y*�lse��S5��I׆ė�� N��N��:��(.};��)�_$�Q��&�����u?L8��I�$��M��t�Bߨ����bXԐ�y�)'j(d�af�J8`��&��8bW±��fN
�;��K�I��)@�3Η��D��ߊ,�2IE���Ym�䑹H�\O8��?�ږp�'���k�.̈́3}Oz+3�PO=n�##��Ȇ3KFW��xoE�k�p�s����v��#�hNV��i�	�A�ٌ��_S;Z�� ����Ո���m7L�L�b��~�6C�S'�)��{�<}	�F��y#ib��N��$g�s�m���o���=��0ڧː�?�d{p{i�7�t=�`��z��I4�-�P[��$�"�Ee�߿2+C�3b9��9bf]?C��!U<�e�̎�uzG`��A�n��ȭ�	�p�ޒJ^F� ��<���o�M=!NﶞD�/?N��W��ݓ�ֈI]��r��1��an�J��cݐHr��}6tY�F��l\N�t�>wӸx����#�����1�PҺYx��#ӽ����s��E�'-���Q�z�K7�Kp5�D'�!A�H��g%c��A-	N��9����B>ƍ�|�7�{�|�U��*Y����i[6�@׻{�$���ZP̊��J�G����	,a�����4�ָ�9G"(��on�e��Q}at�0*���RSJ��d��I�܇;�a!��Z3L"X����������x�^$\�UG�����g�!�
�C�ҝB���G}#��~Y�R�����,7c��x^�Q���;�w��Z�`Xh�h#�dhe'��>'� Af�!�?B����4�i�ЯWS���R�q�e=��m��?��?-R�o��G����Kl�t�0`��n��6x��i�%k�_� 6�,�a���G$-�����#R��W�_��[Ww���S�9W��e�D��nP�C;f�����I�����>�D�к����b=hQ�, �
�>\]<�F�㌦�y�V����DT=q�9���>kzj���D��c�K��Q�R�����	���Fhuc����*ݸ�򏉄u�~{L$��$.$�Z#�6B�-mR���5a��w��1�3\ �ʍ�4��~�ȻZ��kT��Ǔ�Y1�,5)�и��ݾz�ЈAwZs2������N,���W:���q���r�1�({�|�c��ֲɐptg�/?B���G�\6m�n0�4?ك�q�O�IS�һf���q3D�l��;�n��=1���p�"�n�͌8� {�P�x�����/�7Cҵ��_|�c�!�����{�aX��~2d��ý/�&�z2D]r٣n6�Z�!��lg�ӹ���v%�	1[����:�!����;��Et~���3��l�d����8�!<�T�ː��/Ke�R�X̆;K��˱sf�QY�OL���!I�n��w�6�;�d�32o�^�n�$�M`y���AJ �,���]�JbW�Ȑ"2l�̜�!@�.p$�맳�%l?�`�!:g�Q'�6C�ȫ�&�Oη�0����^J͹}���&�/z�cW^Ȑ����)�-�'n� ؒ˜g1�Rj�F�f����#�Ac��T�7b��~��F�8o���1Ě�M:��Hye���4O6���#6eX�oa̰0
b�>/�6��($-nH��n��^:s��y��զKc�ޠOL���?�sZ�ˈү2mU��v��`�v�{"�����@S~������I�Yk]���Ui2����Kx�L�*�xUg*X�Y6�,+�,��
���9���k�E6[!CI�v��Y�,��y���e�iXZ�uV��U�ߑ��k�ع{MD)���nH��q��V{+���ޔà8�ȃܯ�f��0��0��7�4h �^aF�R.>s�+#c k��/�R#�*ω�oFc=3��E����u��QOQO���H� �3�[�)�J3*2B��{���F0��nf��C'#�=[�§�*_Ç#�����_�_+,    Џ�ռrrr
ԣN���b
t#p�{��1����}��fuȧU��r����_�>�NnwL�*���.*�G>x�U�
��M��}�����
,!���7�~��b�}�7��N��T|U�@U*]g�2��MS�2��3�{]�B��T�h�s�@]2R�'�fP�lڒ^mC��J��Ԕ{�]�[:���\��|��f��t.00��1z:	麈!��4-
)��L��惋��a���G�/u7h���4ƢJ�\��ݷ@q��a��(�����y>����WR�@؞���.���&J�˫xZ��@s\�;�z�\R����5:���=I;�(�jy͛��h�Z��l�z� w�[�q���.h�������������H#fI,��B����;b�TՓ�}~�JS�
ZTU��/�@=x{7�@+-Ѥ"���tS};�uր}A��(��WT�bq.�o�Hm\�`��H��Z���W��@U*��T�*��~�'���&�������d�U�C��j�;g����.��%���>mH�g�r4%ځ(��������� y�!�^�寷I2����Io<��\��;'�@g*�v׎4l�?W̻�hCE���-�q��L�zQQm�#�@=*s"��Og'�Xբ�<�p��Tz%/Q�9����;_w�@u*Z�L����[�h��0��������-H��}�>{�72����y���(}�W�
�>A$k�%�(}�|zxf�:�^�{ن	oVK��^���.W��-F.�X��J:�ZfT�n^��@k���&��8���Ҕ�����;���� �]қ���q������[�^�F���+��K*~^RA^RA�ϴ.�Ή�$��)x�h3lF��� �hʍ��c�T��97O�Ǥ�
]���|���jj��ӽg��p�֕�3}b;t�{W �Q��U��}P�ۭ���E%V8u�{
Y�w�U�
Ӆ
�9*lXnڰڏ���X���X�
�EUCO��0YT$/��fS��� �r�ttE�bE�k֩�E�4��Qa��V{{����-���m��r(vHK�N���+,
�v��ĮP�HȪ}b9�Q��d�`\���l~b��9`�VY�n!���T%��<��yI*L:�7�T�t�e6�����J���z�La��D/۠��*8\m�q���8�j������U�p��`��
��Ҥ�ф�
�G�-����_��xT3P��M�����9�@���
�������?\ԩ0sTs�sd�˻&�
B=P�97�����c�a��E��*l	KR�pr����/Za� ��>�t�G������k�>3�U�+��jI'O�B��|����]��/YO����ޥOJ@slv�c}�>�g �����G�6�º3��I������o^Z$�i��
�r�<��zQ�Y�`~�H�,��
� 7۟���ʸT/�������*��~��q���\��*��a�b��E�D���U�T�N��S]U,������U����f6⺪XqZ���L�w�;Ћ����EV��-�B���v[��V��>�U��p��ղ/��Th���s���
m�0�Z���^�ʍ#�Pw��7�Vh��MX%��L�L�ǿ������Ӭ�>�	�BݭVW���-��p�2*��j��;�C��n����m���
�V9o���P�UuR�y��l�J�w�1	���Pk���ҿ�K�(��$��A��juC�̊������5���L���\�/�UQ�K�Z N*��W�zW/�V�?�n-b���$ZU�᪽(�g�D).{���z<��� מs�y+�q�7�(v~���U��n��7�nE�� e4��h�2�E#9W	�HO~�!�����_�Y�rL�u������A�4��n�'@7�L��
Z���5�{��M��7Ot{PQ'�	�����4m��Ⱥi	�����
�HK�i�X@�0}�{Z�>�Vb�X	��/7�c<ZP�>��O�GW�	�փ��h�r�}�Om=�g�ğT�P�'���b!�ؗP��`�lS=(@S���C��b�>i�Z����*��O�9�1�����;��8-�/@p_F1�A�������W*݇��K%��������7yi07�P�`(nfT�˻�H�,���d6*��_��¼v���@�,6�X]0Ԯܮb�`"�Kj��Kn�m�x6���`����i0s6���Y��N�f��c!n0v*Le�K�ݕI�F�f);�J�W��SI� �9���iQ'M#I�������i0wȣ��jH��i��㩐����~�Ц�Y�9�R��pw�{k�1o�}RQ����V���:���kC5��,�ͬ���E��U	j�"�L����K՛��s"��w�"֊J/w?i�d����g���q������O���G]7X^�/����Ʈi2B����	�݄���+j�S����.�l��'�>B�.�O0a����ˆ�U�d�7`7�j~uC�l9�=ݵR��=�ɒ���Y �)Xw����-��~$���<:+6�>=���*8*�x�ڇ_�^�z����_����Xp?ζ��a-.H���\�~�]�͹��j�`��4Qz���7*�6X��F�Ypʵ8޸3����z ]u#>��=GG|sR*�i��S��{�����8L��o۾]��kCL��u�@��������.cN]�C��A8B��o"y��=��%�49�LӨDS-����h�K��3�6x!Zo&�~s�}�RN�7�����4� Zw��gS��cN���r�&RW���r�,��dP�0i^E����D�w�=�iV��{H<$͢1_=��`Z���1xK�`ɕw���j%+N��5����,l�7��A�M��w||]��(^�1�9ׅ���is�0-�G	�����6U�􉊡���Z+Ʈ�k*0S`��Y���W���Ӵ�ꅔ�u������+'iJ�$�|�	@��B��*�'�g?N~�ayu�c���'�7�в����6��}א ��_7j �_������^i��R{N��@���c`p^\ۋ�"b��ϐ Dr�N�C��p+�A���Hޢq	�'x��<=8�nv*�!/���0� {o�?�W�r�zO��.NVGw3$ Y�fx|��0��u��9M� %|����K��4Xߘ2���&��M��dl�y�Us�X�A#�|s����m� J�閭PXßO�]F��������9&1ӎaH �{�3������;uF���D�.��O~�����o����F�g���{���o�""c�ݐ �><(d� P�+t	d�\>c53.��6!Y���V���pgH bѤR��T�6t z�#m��@�_֧v���F�,�<8��;l^ԕ�!�S5���l� �/�~���!y�bز}����=7�$����|���	�W��&�d9��S˙q�s:Ē$E'�b˫KA̹w��]ê~���4L��cH 2)*���-ʂ���*����of�-ѓ;�uj$��!�oC҉, Mm�򯌭`�E�Qj}��J�s�it���΋F�r�~�qϷ�1J��9��h��{�n/�Z��AJH��5D�̴_c���_����x1-� {!��Q�:k	Sl��pm�bi1��h8�D��Oހ�1�b����֘�*=8f����Nj�pj 5�����5�?D��d}�ܟu�=i��-�^��n�ꍴ�4;o\�WdG���*���wֺ^W��
r%�>��8 T���血~H��{�v�v�L��y7;���NM�FeP:��t��ݟZj�4R��
��]��d#[Wݽ߯V�<��� ]w�UBTQ�� ����`��;���HZc����CG�ד�.�)���UC���R�޾���<��N�/����4P�/���8�9�}��cjԸ������z�8.NP���� �;1'�u7b$�.8ǌ���4ԿXq<�`m�|;�,�1GpӶ��e�_3�    �լhV�)Lof�"5��jIX��5_����(Vn�zC�������P��x�ϐ����	O��3�}�f5�F��YZ�^�i��f:�T���:P���@��$m: ��V'�D�F�P=�����o�M�,Y_�{Û��� Mb��+g=5���=� B���O4A4󎔖0l�6��6l<���jH�T7��=ס�ݞ�=r�]����й�ŧ�#��ճQ��@��i�B<$㤠t��@�6d��~cF��6^��km�튢ݏq.�@�G�h��[���4�j�h�~��/+d� ֪b[H�8Ȉ�B��
�����g�a�/F�F`?�������� �y!Ɔ w�F�H����E����!@tC����f`��ߜ�[���WC����6=-��-f�rg!Pg��\�7�A�� Gt)t�� 2����ԃmh:I	��������oon�?֧	��ܾId�3�����bb��0	c��L�[�A�v�� 
"E��{Ac/@ʖ_���v�7$ q�M?vU��O,��踿$iOkLZ^�f�7�4"���4HR�@"to�g�!�|�����NF�����"4�؋a����F� �D��q�&�o�, ���g�3>�X��a��r{�B$��'�ѳ��uC�1JmWQ#M(�ai�����Wi��=-1�U;��S$�{Y	v6D ����Î���Jb�%@�u���#��o�M���d�#���J����4���qc��W�����4B�{W�3��G��8[ݸI�#��c���d����=B�F����7��®��tGU��	�D(��ti{�I.�_rƻ����ߜ�����΍�Hι֗�k��y�v.��NFh���=��Gՠ�K�zs�q��;?�������'����!���Z`c���|�P��F�b�� 'b'����:�ɪ:�\��a�b�x[W�P����K}�0������Ϟ�4B�����K��Z՟Mo�tuV{Ұܯ8���3Bi������
�#*@g����и��]!��G�ŉh²Ǎ�Y��W�#Bs�����2I!;>G�٣&S���qF�N�bͷ.(邙�=}��T������Gh�Q3�_��6���}b�w������7���;��G_1�P�����m� v�|]�C*��R�ȱkݮ$Bٌ���l
���F�Ţ���eS()�J:�� ��	���og!By�T�諚�� ���&�$7?��o��O����y�}�]�;7������lEԿ��ЖK�d�%�k�:Kϧ�b5w��2;��6��m�f�L���h�j����9�9A��l��c<A�MZ[qwO6��6iE�Ǘ-����䫳	�lR��.�'r���OL�KPwS�5�w�b�Y�"A�5�i�	�m2EXb�/��9A�M�0L2�������4A!L�B��&k��kZ���7���@���_r8%��1�a�p�^��#ڍ�L���]����J������k�	�dB�$�LP&����t��������?0�,Xo��l#���TT�Uι� �L2��q	JmH"&��3�.�̴t-;�uB���V��<�FW%MPI�p�������&�v�f�����04��16��$(��WJ�Ҵ������u��_Πد��@2��&h���}d�u��oA�r�a7��݈�n<2�r�ȈCOh���eF��a��u0��;xW�q�&�1몮�80 �A8� Ԧ��7���q8�y��q�K���˖瀷�������mQ�w�87�zc����O��q����g<a.{ݏFX�gʱ(�0�O��pG���8����Jm�#�Ӿ2�?x�i~B�y��Rv������#h����d���>�D-�漓a��n]�7O���$��L:c����_��#�n���!Hwa�����F�����G����F�����Lk_h���{�8���>t��x)�*�>�����JI`2_���l��6�6�+���Sv\�v�͑�P'�}�	�7|;w�T<�koao�4��:��'�U<��<�Nχ�kW8���aW����91�#�R�}�2טG$��K��'R���ڇ��)`XvxZ���0]��x��x\�Z�P�f�Q��� ���o`(��v�&�^����0���H�>Vf}C�C�x�QqϞ�`!�Wd��K� ��i#�+֟O;f��g_��8������n�¦��?���Is�����;�Ug�y�	g���1�2c�̘��Ռ�g���!5f����!0
r6&%CZ̚���~cxW��sy�
��3��<KC�"^!Z���L%̐i�Z����B$<�+�d�*y/�H]�7Ι!����ːS�Вe<\h�y��D~�?�m�i"��y���}	'C�ɋ��V���C������a�n�P3�Vo��!b����Y�����42M���o�R�6��F@|�I�!�e��v���\�;�}���|��|Ө8NG늎W};'%Y��~��It�Q�8��U�`��͸��!T�9[׫ӑ![ec�^v^�ga*�ϕ�2䫬��⎸�3���X�������T^o0��md�4�3h���|���QJXk��:sW�W��&g�6�+�d�;Y�L�
�NFI}���0x����\�ːt��D�rys�ne}rմrNn��ӟ8ra�W6�^��l6w�$V]���c6w��k�e\wu�VW���p�
f�J[7���%�ee�?�7Q�i��R0����<�!�)�}�p�SX���pK=x.��}��/��q���������ξ#8�,������䊿���pl��`!��߼t�r�)�,����j���x�D,�H��*ξ�8�U,������p�����a�?H	1�E@J� 5ӌ2	<@J�� %�ܵjLnXrӫ�tv� IaB�����()�����m^���?��jګWߵ��F��Q��[�P�nU7d�Y�T�"8�1S�pUs�\���T���DY�ەYC!���eα�[X�VQ�R�<t[,���λ[f���FY���}�	@������L�J1��>��{�vY�����g�,P6��l(����hEYH���Bjwo�fL��!�F�~~xe1-fZ5n���xaWD-Q�J��6L�+�O�7���Z���@@U���Y{/�'������X )�.���4'��5lD���Q���D�Ђ"Z�E��t��n�̆�`���|5CF�/�8q
�4��K�"�0ln��T &K�z|�����Iefw���I���^�>qI@�+�y1���1�N��9-"�/D%��(h� r`���L
�A��4��H�'�Й}G�%��C��~�f���9@�$D�):���,�}��Q���BY�;f�*���*���+�c��	@�NwP��!r~�S�`���I�e@��� � ׇS����^\b�������D�����C��MQ���-`c��<\j2.�*�n�nC����������_��.�"⪙��o?�ߩ"^!a�M�	@�Q����f�ޫF��=)*,�u!�~�m�G����}.�ۍא �����F'����~�7O\���W���^0���Î��닏[VJ�B�u����nyI��
A�ZA}��TȰ�r�S��B�զ���Y÷��,2$ �|_IS���WOh�ic ���������>$ms��$��T�l���}ͽ�fy���΄7(���9>̆���_cH ��$o����U�}�&O�l�g��˖٧4Zkw3�}�>50�9��m��U	@���ĭ�\C��'^�#�In��	�|����ܣ������u���M�_�I�?p�q�y���|U� e?o��_�n��������m��ǿ{�����W	�����k����4���pւ�'P��!t>jC����m� D�œ/Ӑ�2��d`�$u4�����f��O�蕆�>o^��=a���� ��4�4r     i�|��yC#P� �߰l����ѵ�۳���d0NB��qĠ8B�!��i� H_�ɉ�E`��1	�,�����¨�Z��y��ňQ�BpR4�
4Bd�������w�P��\W�3���]��h�\�w�j<�����E�ғ׽��1(���)�5֤��!ȹ�#[�X�
����S�T�{狒V7������1j�)�B� �>����>�н��`�8VCkr�\g ���O���a�O�װL5��@�����N�}ޟIasD�PtM�`��3-t����X#	@�8o�Бs���հU�5�G�b�j/}��|�W� H:��3	@�M"�:�r��|`�SZ����P9��v��1���]��F���� sIX��qƵ%�Hhr�g�6$ ���v���>ܿ\|X��j���,d�捸mL�e�ƍ��ۗS��	�g�6$ ���8�C��/� �F#@�x��#=�s���#}���Aڐ ��Q��53�i$�aqE��6tw8��tΊ�����мwC �P�vp"�p䀀=_�r�6 ��ό)`�Xt�vy��lH r�yر�6`�u.E��9�?��Z�_g����l	��C=[���<?�F�9�,� 4I3�3�C=�j�ni���-�	0��ZjX�eUC�)=�04�6h�������}?i��P؇�S&ڠ��x)Xc�|A�����2m��~���:?��=�K|��&<����Mx�݂�͋������}�ԬgP$u�X�l��L=L�s����R�Hȓq��;����at���o�1��c�l�����e�F��B$��d�f:��y3`;4���D���^8`/T�e[̀�P	�������r�?5,�p�<����J���ʠԿ ����/�t�F�c����������J�>/� ���!����iP�!CG,^�dw9�/jd�Ȫ��xpI�d0�-o�q����aH r.���_�ĸ��pT�`[�m��7��#^��'���1=��<('#�UFm�)����S������+�Ϸ���3��2���4��5S���Xr���{��}
���E�(�ɽ�W
;WnN�?c�G����.4�␧�����!��`i7���Х-Ke�*��w���7+S�2�z-z*32�� )�.)�1���Csvs6/��0�cdvr	q�Lu!/��đt%�.��Cy�V��۳&p��n
M��n׌�4*иN�|�d��d���}͈͗f��b@~e�Tv����kQ:�~�{�hsv����*H������YH�q�'S�ꁮ$}�\��^�������PG��ox�R�v�t��e������S�br8^||�'�Gv�i�
�/�Dvߩ:Q}�=�Ӳ�N�q�q�[����{�P\��7G�p�n���}�:�݁�5�VVYRsܰ�؍e���7z��b�������+��Bw���oy�d��9������!j����3d�ƈ*�Hͦ.Zɕ8}��������pR�"�P�����4x���[�'�)�ξ��dG��_����h��|}D%���iDt�4����a�{C�#v)�Ή��	㮲�o9i��ש��[���ٚd�������DR�è��޻&�zq5LoHr�m�=8���#_ohqz�,,L�v�VqKӵq�u+O��l��J�"��U\�����5�0�!�?973�݊�: m���Ɩ3��);ŕM�~�-�u7z��1N�<z������P�eo6�)"���Yv�r�4�o_���l=����������߀�`�R�o�`l����H�¬�FN��"���0�3c�K4�[�ﭚ9�}F_|{T3�Zε�c�tÆ��\���q\
FƏ��-����Q[|�����{��R�n���0K��Y�l��Gώ�$u����<��j�F{�4چ��hQ���gD���5ېhw�sSK�I���5JI�;��y�,��'�=���ɱ��.�v�g�������m��w������s-V���`��G+qΡ�!,�<���9m��i��Ӗ��ؠ�����b ��F�)�Ohl� K�?���;��<Ǡ ��Fh�?�D��,~���}�&�Ȳ%��o��a�s�b'��N5M?}�������a/��n�����>6���� ��F��؞ӣN�~ղ����7����oգG��L�g��٣g�6duߔ�����FGu��ThɭE���^޺�N���Nު��Z7��~��?�jXݥ���e�
.�9���<�6��i��ps���V�81قf��n�ݛ�g�U7��'Qmu�%L2>z�qCT�쁎���K]l�_��iK���:,�7Z�{���筥{wu��YBzp���h��ѓ��qR�ѓ�"�I�X=�ٓ��h�W�h�Tb�����ve�]��};1[�k����{�Sy������՝��J�y�a[Tu�i��Z���Ww�V�ھJ���+����< "fV�w��Ӄ��gap�U5Ӏ7�^2�_ǯ��U���9�u��J�g�j<8�7h�PH)�0C*��1o�A8�z�awx��@��2��:}L��Fug� ��M>7V�%]5e��
�m��9�*d�JV�^}H��U��Ў}L�n?��z9��\?���r�F?v�A&�6ͨr_ݼ��y_ݼ���{���༅�+�Q�-�-|�WZ>�b*��������'��gtdT���� n���3������ya��.τ�'ٮ�b߼�����חW�y�LXQ���Hs�u9��w$��``q��)X����@OK������f���aӹ�_����{���������B�� @�O~K��V��M�0c�!��C�s�aEF�R�y ���޸P��\�D7�O-{�s���8L��������M��u�5���I�X�����jC�fG���Qv�:���Ȩs�����|�w~���7$9����O�Ӊ��|t~�������;zO�5����0w�!ɑ�����{ϯO��ε�7���}B���G�-m��1X�{��o�`~�>���У'�6�G�=�Z2z^�h���_N��'Ȓ0��\����k4|u�Gu�Z��o�����!ca۰��Q+Goe������}��������E�gp}|��\:��bJ{?[qr����U��o+�Z/˳�N�%oe�;��x�'}e���-G�Y�d�
�]����ɒ����5L}�lS���z�Baz�����j-��C'�l =DC����z?��Ǝ�5v���O;n��~�!�������_?�{i��KĲ!��ԣ'g52v �~)�R�jw�<P�����;I���c�E}�repEK3r�uep߬%�����^Ya�7�7�"�-�K6�/vP�n|j2�>��=�!jѲ����4��NC�9T�p�hbp}o��^��]U�Ϭ>Rj��5��5���n�N����=F�( �'y���N^�{2�߉�Ԟ���4����9�.4�WA�����~K��=��?oY��]���J��=GO�i�����̫?���3�	=���A�c��������SK�w�
����w�B����q�3��������!���%p$t��Bj!k������؆i?x�p7��7x�ΰ�p��~�a���KQ���#��u�f�u��uA�I�� $�4ϡ�Y��՝�yߥ
��
ͰrUEו�i�}م�
F� ��ht� W���Q=��G0�����ΟQ�I�-Y�u^a���l�գߙRd��H��ѯN��i�Yh��T�,\o�4o��_����2�:�wO�S�q!�t!�k�k��~���?68��Ì?���n�6��|�|-�LF�������5ȇ0��U���R���Ys�|�]���OXb�0�'<��;����en! ���4�~:������x�aN�����EY_��[Xj���\|�i�W�9��:���T�n���n� O���G��S�G��z� ��{o���$urt?�׳�U��U�Q=��R*��<�����9V1�]�>�E�3�V=^6����    �Ա_-��EZ�5�����"y���R]�u��S/������z;���M��1�xh+�ih)�n)��:���Z.�5��)�F7���g��p�<4���nُ~�y(�c8�i��L�M����,p�C�͋���2A>�kAo��O�ҭ��>EkҐ������{���I�m3�g�����C��,���{0�G��-8�-8Z���X2��J9�~~�4�,�ʖA�;/,fzp���£��ǧ}����A�ҳu�A��ʅ6�9�G�H��k�)� ��5�4�%c�,�:Zn�i�����7xbY71��id�|����@<�뻠yɭ���� ���q��BA��_H� ���r�9�@��2���c����A��&�]��q������0^n��-�{6pCG�|���=��6$�#l� V�1���|2�x���䬭j:��0�˳�>�,l�BJ���kJ���H	�R9I���veA�3���8Ү�t.~�]X�E�0ݛ�27%�����=_���h��� �Ҵ��ՋK�x`^��ɐ�U��I4�)C(��̷�)C$��gDܗW��_�n-�؎�r��H�J�9��O��My\�)�P��i�~�ctw���FwG�)��0�I�d�JwwJ	yR����p����{^;Ұ���F�Gq�/��I+x�@��������tnrzؖ��ڶ�0w�?yЖu�ĭ�&凜�\�t�e�1Y>!L
>'�72�̨�>q�.���4m���/��]4K+������^|�'�Ӭ��_s�kn�_s�;�G��&D`h��1���F��͑l3O���ݳ�UCe��5������ܟ�})�7ws�i��n���oR���iy�<Acg]r_J��h�@����r&���>�TR�|�*=�#}A��wC.��-r��t��7dt�"�b5o���,�b^��M��$�'�@��/�-9�\�����|��|
msf�z0̢��սjq8����\?�<D'��4�P��%˨���f��J�;���s4�w&�z��W	z�Dr�Y���R+�rp:k͎9#	b@�3��N5A�V��c�B^xx�u����	rA���#�	�\:��>Ӑ�ܛ�sK��C6��J���5��r�ot5��/���&���Kc͗o{ >˘�nE{��9�aZ�Ѹr6�h�A���X�k������``g��ע����&H&$��������N������N�z��V|Zu��쨙M�u��oQ{�L��0�0�|����ߡt69��+K�_��.�5^<8��Is"����������ߩ�%H�s���B��b���K��Z���iP[�첑�l��d?BB6R=���=H}�\~��L}�O�LSB��c���S����>��!$q3첾����#��ϐ���!�y\t\8�y�!����C_3
�����a	��K���?ĉñ옺yf�X�ɣ,R������c,&=r�$�YLz����㝖=S�h���#,싃�Z�WL~�Ήii����ȝ<���~���6n'���*���0S>�������Ph��m'��XZ� '��k��#��#���פ���<4$�\&�5Yαޙه`^�_��ES�O��3�m��7�W&O�������g��;�솓� և�9#��fz۶0��L%���q{҄wo{�r���+��u��TZ�焫����-"�,5/���G]�}�<�Eܕ����'�x�����գ� ,�� ��C��\~��R|�s�
<o�פ�3�>cp�c:�����[�wv��#
��(S�2y,ʤ��=>xRvl�g����|�.�:��w�R��S3&<پ�������b��� �/�����{칀;�������v����[����'��p���EL^�n�t���|purt����U׼q'ܴ4�D��H�\��:�#,D#"fV��Ŧ�����јv�'�.����������P��<�{no�3Ý�w��`����v~ ��E+�A�HŘ���]����F=B���>>I:&O%m�}���Փ'�v(�A�ci6i_��4�}*'�ۡu&>y-��.7��>A���'bVw�=���"Qx�����p|;���A����"���g&�D��`�sx5!aӆ˧
	]�ƣܧ7��gg)7y�܄�%�2<���2���b�@�G&��Nwkx2�ɯAL�5�ɯALv!	����n�H�Zw�K��%=}��xw��w'?ޝ� �g�,��i�я_�o��&?��f�]\dڃ���x�\R���Wi9oy�Ѹ���v'?���s�M~�;�D4,5����n�~�;�"���v�b��S|�8��� � uMV���Nt��_?ZTV�������.*�E�3�ɏׯ���.N~���M~�8��Kg�䧌�mF���7O��d?h����פ���Q�+���3%L~�(�$��@Jqgȷ�.J�mKC���ǎ:
����["� AE��7�u��v ����n��G����~֙�n�� ��G|S|�7�ߤ�;՝,;&�����g�*�4��ֻ/B�����`�+��1�f��}Z����4�s��>a��sV�_gM* |��g���gѩ����~ڕ9��u���>FrL2w��g~�@�5�Y��o��z��{8_�e����1�$G�ժ��N�M��tsS�l0��)X�f��>�[S���xm� Q��98���@|G=���EM����	�	�V�i+�.�I���(f*���Y���=Q`�+�A�b�=��A�~G"��� 
��G�a���-m�$GN�5����'9�	M+��(��)�(���ܝ��t�t܆>hup�I3�o��*�����>��J/$�J�M�B�\E�$GZ���*�����k�Tu*R������u�3�37�y��F���k�L�q�s&����=%���R^DB�(SNM�g2
��i�d%�E�D>>�K�v�И;7�}��C���[���6����i�Hr���㞻$�k��9�*k�a*U7�V�ۼ�9��*�c�zP$9�1�w/4L��������يG-�p������(�L���=����eRp���5����R��J\1��C�|���+��hڢ�>�={Ho��QC��>g��'Oݧ`=w,�Rٷ�=�ވ���Cm�Q��S$9�er.����N.)4�}D/�-�(W���t�}H�K�뿨xF��jrm>���a��9�q�t�q<��f������T�t�j�v�D1��Kc�zT$9����fG�Y�������]��FFCt��@�Do?1�P�ki��|��j���{F��A�:f`l���m���$�K"of>�)��M�_$R��=vV��bf5}���$�����ke��O)�T���_�G��2YH����B�rV����צRv�d;}�g�����Hrd�g��׭$���@5��vQږ*�gJW�7ub����h���o��C�a��b�6Ѧ�XaE'G� �׫����d�$GD���q�ɡP�On7��ƬN���������鷏�!ǥ�[�j^�$��>�.��S�	q����������?�f+���n�\�ߔr�9o�����.ۮ������~W�g�o+]�ޅ�{^�+qar9�.��܊���5��JN��[K��$������K��L��3��3y�$��Q(;�8������>P�?��s����MP�G��Gd����eH���t[��B���!��X�E��� I�Jz�����t���/D{�������OA��_��]�V.o8��'w|&�S�\%�Irǧ��������)���h�E�`�n�V�p?O��D��iw��TvJ�{В;:S�;^���Q��yIb����y1b�uӢ��(x���#xb��0rJ�Թ|C] �5Y���ş�pu.�L��%��v�{}�Mx*�΅�y���mc��o^ι޻&ܜ����*���o�ի������o�^$w�%��?�rtK���?b2��3����0����ݜ�wB�]r�]�jU�S2��n��S2��n��S2��    �DQ�dr���)��5���y;���;BOOrOO�k���$w�%�R,�SFӿi�X0^F*�5�)QjE�#k���%�(7����3SޒCsʅ>��yw`�$�ۤ�o��o��w��]6iU�zOǟ;mV`c�s�MZ{x�����~��Q7�d���O~�K�a��H̮��X�ͮ�f�+�j�/�����D���yI*?�:��PbZf�}g�� ~h����!��H?/G��)��D�5<���H����s�BW�"�n)�/�j��g����R�@r8q0;ج��d9���ت�]�H��]�%��t�d���2=�/�{����v�h�����W�Y�n@�؀�n@�Sd��� �%��b?�k1
�-Ȋ�*W�C���3��Y/���#�[�Wk�#i�,K�/rb��b�=ъ�͆�S�����Tz��.�M��@L�WmK�ȇ�B��#m��('�@�Y�xo��#/h�惃gV��Ŗ�b˫;9�jR}��f�5X���S@�{�+e7޲�n���k:s�{� ���9۟�w����5�f�o|(6m�H5���
m��6� ���CO/�]�Δq4�&��V��}�V����#�;qhv���o�A4�����f���蘭�юٹP�8��\��.O�%q0m�[O)��*��M�զ���΃H5(�:M�/��x�0�0�W���L�d�+%V�+����⺂r��X\Q��5����B��M]����䡗ŷ�o�ŷ�����z'��wr�H�(���UL���9�ih�'5�	������Զ.�߯~��[�ƿm�+:�=+�a�x�*�aM4���l�.�[��pO֮��
�ip��o��]��{�l��5��¾B���
|�"�>,��*�S��S�h�]czoXߪ��\q�j��[&ޢБTܑ$ȻǗ��y���{��d��ެ�β�&]ܓTpэ^j�{/����S��S,C2MөPvHGxtrV���O���|qN�]8�]8�h�Ft�Z�}S6�9l�F����$X�&�m�`5�|��p]���]@%vw������@neS�o��E@E�#b�J�l�*���~����d3��,�}�!ɑV�r#�����G�cTq�\_4���3���T4�;=�5|Y�]�{5����o��Q�cHr$HomPvH�w�[��n?v��R��A��Qf�.I��$��C z�L�7J�!�Q?�I��s�{�'�U-�J��6kP��E�B�_�h�$GP�e{12��G^w���]�d��quý��d�u���51�~i�X5$9�Z������������gT�K�����i�L�>S�7�������E�n���8Y��񥚃�����;�G-S͎���C��#���^K�%�E504�I������R-��Ws���BATQA��m����$����A�"S2���+4�I�賸���{0�>��?��p)��"���B�m`v�O�d��Ko�5de(7܍�ή�B��VQ5Q�G� mWRk����Z��f`u7�N��w|�u�k�,#�f-�OGw��]9�������]}t���ӳ�
$�͚R�?$���A�0q.e͎b'�<�*I_��C��#����M��;=o`ڋ��7,����PwC������aK�9?�2�w�/��;?1lpL��pxfDh.)��pv>;������cA�_8\:.��D�~`���=�OI*��t���(J�+qoX�b�LN�!}< {��yh�Q�)!2��8�On�����Ò�潏3��j��gMj��V͸���/�A�� 䝮���;�f=�
��C����l����	:O^�ݰα���A�C��k���;$彏���+Fr$/ȃ�E�Pq(P-{؊�&`�JF+�+��au��9�x����������U��F���9��=�"kH��7���^Oڌ�ݑ��Qͻ3p����|9LI�ue5�U��{h�+��7,^ʐ� ����%��A�ga�ϙz�뗯P��<��q�}x�bT9�՝k�����S��h�������g<.��i\u�S�B=0�T�4D}����a���`��6Ļ�໒ ���%�1.;.��I�:N�f�֬i޶p�|�|������If���0Q��Qթ���hrLY|9��|��|еZ�"2�k�ݨ�]X)^������W��r��_�#P��૤���z�!@�/���AO�g{��_�/Z���e���ՠ��(�w���f�r��.����������Ơ���G�Fd'fH�t����ϡh��� s*�(]��������W��&�r~����Ĳ�����Xd��}��Q��w(rs���l"9�O䙋ɑ��Up�����:ם�ݞ$�w�_a_�F9[����C}�N����	d.n��HD4������I&;vQZ�X �`�t(��2�G^�3�oΖK���U�te4�q(U�u�j�Pt�J�9�}:|��X�1~�u�Xߙ��p|}��Ó���S�b0��-�4O,�����Rz���i:)�5J�N�|<sl�ru�4��x}�Ћ��GjDm���N_�l:�]'+��L�S{tG�9� ���oΌB̐��/w��<r��{^��tgpЄ}DD8� Y"�/Ls4�Rq+|������"�|���Կ��� �¡�l�?ȫh}��Wf8]@���/:XJH�=p�x��g���`EQ5oi��a�\y�Rp���G�o����)*�.7�]Ƹ(�s0�#���X��h^�H؋S�E��G��E�	��dJ��{��ù����Z(��<8V�Yf��w��]�%���@�$�t��8� Ɍ�^(���oT'�,o<k�����#�A�@G���o|~�ѱ�4������ٻ��&�}l����V%t�b�c
��8ڡ)�Y�l�5xv��r_?-�3|jep��nϫ4]
�.A��=��������]h��WڣTF��fZ��VN��<�~@gЍ����W������wT�)�ل��;q�:�҄�aOf�d����#H� ���O\�)�״���=������*-l´��͟9۾�ՠh5&|�l�ju^�Q]`�q%@��u�V㳄�*{����[֟�Zx�`�=1���9������+���)�,�
,��Jr�e!?7�������ro��aۡ��o^4�!��<�Q?v��N�#�Q�X�������9�}�9�.���o9�ğ:�~����H%-�S��'���J|�gM�Y�E��:' Z;%�I�2����Њ���U��ph���s[^ߟ�68Y@�ۏ w��u�=c7〯����_�+$�	��_4�
�~hG
��i���*ѷ�<0O�%Zv�z��R�;9l�h���:���q����oI+���
19�wl��v~F���ǦW��U���k|i��#d���!�Q���#$s��3��z��y�L'{���Zk������*4�0\ϡH�k��
u���"h�6��	����WY�q�b�fm>jh��<�^�
�8��s(zG��9�JvS��rUP�3u�T(�A�7{n$V���E���Ǝ�������r�/j���$vI�Tэ�.U�K	t���O��X��J-(r�x6�*�����y>�r��X�=����S�������S��T�(ɒ*7g،��y��$8��Pm�^6��zb%�
���`�V�E�3�0z��ܸpZX{��i�z^�y�z.P��X��C��-�z �6���#Xr�Tm8�J�<�Bs�y���r˕%p� �����:*|.'wPU�T�/?�[��y+|�'jr�TE֞[�a찹��%@�/�:���A��:U@�,�{�����x|���[�����7��_>N��bZ���LBx7h4�N�����_�;��� \��5�<NQ���{d�=�S��.�o��彙!�l�ԟ����\$ �R�yI�A��8֝=���v�_�+�~:l��y/��방:t�S��!ռ    ��s$�Y����~�5.>�
�T�n�3I��dYHv�ӡ
�Q������G�:�����=l��S��V�G�'�����g�{��.O�C�9���fe���s�puP�:�F8�/v&�Q!߽p�QMKȏv"�͎z���-;�w�bU!�Y��j8���Dix�����)Ze�s8I�)�"�#�H� tu��[$�&7u��a���ʹ��D�NS�.�4=����W�h�"��H��=U�:x)���������x�>�2����[R����cuy�\b��K��>MdX������v�@
�=�Fp��O߂]���O}|�2�����?�х��K��squx�>k���K���XP�so$ҊJ��y�����NZ�tCﭶ����ů,�ʣ�Fjb����i�w��#׻�C�Ǹ��[�?C��ǈ��nz7��?����N�z?�ۢ��c���i��O�A����"I��"��� ��<�~2�=�"���<�A/��z9̊��Y�0!�+Y%@�O�p��r:���=�æ�Bg���aW�~Y]�����aX�w1�E�bEJ�軆s�.��zXzL�3�C��n�q�@[!�,�P�L�����:R�zX	B}��=̂~}���:���?fX��_�_��c�����_�զ���Lix��C�����л{M����8�����m���q=��/�t+�ot{�r��m�;�f�丐����=n\��=�m��QO����C���9� ���@�&:���U���"��b�`:Bڮ�=��x�
t��K*�V��d`������l%@q`H}��L�чv�=�dՠ�&u}��:p�~��Q=�����C	Ph��P<�j���6�%�7�*(�߼��=T	�5��������QR����z����9 5W�{x�{8�y��L�!KT3?=���w��z��ԁ�O��z1`�~��];�{8�{�h������la��|V8��yD珿�{V�T0rH�5�'���
~q{x�.�G�="u#�k��վ��#pU�Sq���'t���ߦ��s�x�N���/�k�o��J�d��v���d��N��W*�	V��\,v �~?�'Ftr ��(�hZ���4@zS&>�v�����'QI�#]J�M[� Uc��#��e����``8��ȸr:��p"�r;�m�P�����wJ�����~�ya-��?=���H�<��8l��W�:5غ5@g/�:��h�v�W�l�}��*��fZ\�ί�+Q��XC��
t�{�JO%h���L#���*��#F�W8YA��� �t��e�y~�ǟk��憧g���^v(z����t�gRFб�F��:�`��pxv������ѡK�`ի��v�w�A	�͑�.�+�O�Wع�V���h[��� �/���ٹ��+���U�Oۓǰ�®Ih�Q�;v
�=�o�����Zʀ�uɕ�O���Zo�m�՚���_#��9o���x����?�%ˠ�@G��2(� �� +�<����d�!?�8W_����}���+z�"��5�;y���]��3� ��'�/�z����%@>�^�7w��5�:��R�Ҁcui��!GO�Y�g0J3�0�C	м�>�ب�/��x<��4��SUGr����ѕ���K>(^3V�/?�b��D��7�,Լ	��.c)��:� }:�d��X���x�tAA��+ϗ9�4�;��Qu)G��%'c��"/���Q�� �IK
�;W�yX��V4�AM����	���3�ɜ1�3�̟�XڸNt8>xz�1r�� Ŗ���y��@N�/o��\��ZZ�ᶻ'>*;��*h���z� j�e��ǹq�E�_���?^��NȂe/�iPts�,<�
����(�|�Fk�
�$4(���?6,C�w�Q@�_���w/lM.����<)	q����n���{qG��������]LL�{7R��-�*8żf���P��eOe7���ȯ�Pv�n���,��Ӆ��q����o�"����-�bKҴ��ȕj`^��v,a��e��`NUl=q�{BܻA����S�րw���:Jb@��K�J\�W�4���w�k��0�V��N}`���t�#�J��p����Ko�@Ƌ���azt:=�������SD��;�J�5��C��2���x�K_���;�)�aJt��L����X+�ߺQu��G-Tɔ��&_4(�e>�ފo����ô�0:C�S���Q^���dx]Ҝ��Y2�.+�<}@��eE��t0�n�P݆:���o�>��5Ը�ƀ�6�ĩt���� {��A�m易�Ӷ�S��i��)@�
 H[	$.�	c1:T3(j��	cqj��	cqj��	cqj�E;a���a��͠��v���h��|mE����ڊ��m(*Ƅ�"L�bP��D���V$���V$���V$���V$���V$���V$���V��N�vs��F�ftjnujF��V�ftjnujF��V�ftjnujF��S3��؁��@3(쮌�*�����*�����*�����*�����*�����*�����*�����*�����*7����*7�+w��0�qhPC��l�{w�(.�A6ƽU=_S\��l�{�p��� 3�[��dn	���#�;�=jP���������K���������K���������K���������K����W�*�M�����Ou>+�����O���:�;�m�ģ�b����=�5z*FOm����S[��b����=�5z*FOm����S[��b�����r۫|�t�P�7(jH������:H�kI������:H�kI������:H�kI������:H�kI�K��^$��t~��i�����Ҷ���ݥm��K[P�N���M�'3��c��X�[c��X�[c��X�[c��X�[c��X�[c��X�[c��X�[c��X�[c��X�[c�O��^�c�Oo:��� AF�%@A��� A-A��� A-A��� A-A���N�b�J��:�S�V���Աթ#:ulu�N[�:�S�V���Աթ#:ulw괡����W��ӛ��?A���*�u�[���Un��2\W���p]��ʓ�(.�	��Z�� ȩ%�	��Z�� ȩ%�)]n{�
��8�rF�e�b	�?�[���\n��2�s�������S+�(*!|_QTB�����,�}EQ	Y���W	�7��~��>W�fl��\)��m�s�hƶ�Jьm%���ۊ 2H[�@i+�H!o��)�r ��fR�[)�@
y+�̥ �_����-t�:����r@g8�s����-t�:����r@g8�s�-Դ����/����8�'#�ǠPB���r��gK�=[��--�l�{��ܳ���r�zTQnDeD�舌�h�7=�hE��舆{��(��poz6�ņ�g"_Ql�z�ņj�{3N�mP�����o�7ܛ���,po��{���YZ���fi�7<uq^p��FGTtD�SW�+-O]����<u�����x�J�SW�+-O]����<uε8��A	P�S;tjùV�\+-�Z�s���kε�r�8�J˹V�\+-�Z�s���kε�r����d�%@�����_R�/��|I����%��J˗T�K*-_R�/��|I����%��J˗T�K*M_R��(N`nPԐ� 	5�DN��r8�J�IT�$*-'Q�����DN��r8�J�I���W�А.��H(�����Ӷ���U࿊��� 5�=B��U�����W����_��J�U�*-�U���^g�^vD��[[zo��[[zo��[[zo��[[zo��[[zoEX�B��_��Pl�W�%,�a	�^e�B!���3��jH(CB��B!�-��B!�-��B!�-��B!�-��B!�-��B!�-��B!�-��ZE�u�Jo:��~� c��B��-��B��-��B��-��B��-��B��-��B��-��^��P/و^j�P\�%]n{��BB��QawԖ�QawԖ�QawԖ�QawԖ�Q    awԖ�QawԖ�QawԖ�QawԖ�Q!�P\B5]n{5�Pz��A�m�S-�Z��5���?u�V�׺�	������\�s��\�-s��\�-s��\�-s��\�-s��\�-s��\�-s��\�-s��\�-s��\�-s�"�ԫ|,v�M�������.m�?�=�ElJV���eJV���eJV���eJV���eJV���eJV���eJV���eJV���eJV���eJV���iJV�%����Ӷ��aѧm��b�����
�����
�����
�����
�����
�����
�����
�����
�����
�����
��6��
��6��
��6�W�������`�1zbk���-k���-k���-k���-k���-k���mkx��iDsTDs,=#FO#��"��ԫ|��M�������1m�?=c��4z�V ��3���gL[�#f��2�Ĝm�@������`[)�#f��́@
y+z�\�S::��S�S[::��S�S[::��S�S[::��S�S[::��S�S�:������Ӷ���9�m��sJ��&甶&甶���Hq���B[�c�HE;�HE��HE��HE{�Huİ��XD,�Bѱ�X���c�H�^�c�H',����}>�t�O���c�H',�@�J �i+�Qtpp��2��s�f$:0�j�x�[��&��bX]�'�P�v�>��<��@��$��^%@ĶA�@�%?���il>cY1pc��r�*rXJ2�ۯ4凡PK�N3Dك�Zh;)����dK7xX������I�a�x�F�ꭹ��H6L��Y���H�c����:{����?����z�[e+���~��_�:`����-͗4�\�`Zv��n��oW,O��=����Ok� ���9�H�U#G��Q�k��SJ�E�����˯��v�J;�A��g830o��ݯą��~�{�3[����уm���W�����W���^��Q�cG�w������Q�r�5������?�ET�I�!����D�(�i?X�#�*��2�L|(Pdy��Y�2�HY�I�kcXY��X1]�dC����[�:��[J�n���k0*>��VH2<TȲ��.��N �֌w���駊�.أ��yn\#���w/Ѹ����@	���|�w�ԡ�(?�Q���ᑧR2��H7��?��7�<�h�9�{�W���{�L�h��Q��\�H'�_$!�q�&ė��W�]�l�Z�╏��կ7Z?E((u���%(uiXj[I��{.Y�u'ZJƳdNF�7tKb��fz)����#�Met�V��9���f��ԥ�P�ԥ�hʫ`����F/2v�g�-�cy�.���~���~�q����1ˆO�	��~�8��U\���dW��n!%��E��A��g���nbи<�%��5#
Xn(`
X���646�7��� ��:��T*O���ekF#K!C��7�ǹb\�)�SF%�ihl=N��_l��q����4�[���s:» ��~����1�9>���E��%.Т`xz��Hzy�X^�6�2�[�U]�(�����I~��Vc��'a?���/FH&�zX��y�3
F���!�5��q=�fA�%�����u��0���7l�h��r�"�O��x��q�ѫ7��o�=N3�r�"0�{i�A㯞��[��5{�q��eX��������d�B�g ����6�e�2�h�Td���6��8I<��e0Ծ�m8\wy0��ex�����8s@����7nk���)В]�-SQ���Bf�����qo��/����t��N�9N�8.w
>���%��{���A$N��>��O��.)?%J�C�>e��%#P�i��Oχ���3��9��Q��n�%[��r��V�(�IghO�V����M����?����K���Sb0B���f������J�fT8s���B��P��]^�,7ʚe�53H�|�gkE������o�}����R�����Ac�d�I"�Ǉ���#�slhzk�"6|�#�顑:b�V=��>G�0�b[�ʀmeh%��,�l!Ŧ���c��":`�݀�n@&Tz"6`�;a�P��m`�NX�V,�f	�25�e´Lrg�dRg���� ��4IJ�>2ϖ�eA�:���O_"���A8l�J��O�/g,��<�C�3?�3/��ԏ��J���yc�K�2V���R�oX�J+���:�i�C;���7��o��8�I��w��wwD`��,3 ЍVU��V#BF�.�IJ��-��7����xiĥ6�C�cD��EW�)�������D�;p���66n���C6��)�b��������?���p�u2��x@V��O�R�7l�_ٔ��ٯ�8Fqߌ�,8$q�L~��o�l�[4�`�֎P7Ɔ�1B��z�4�x��#WV�篻�����s);�q�L8�>G��@��t��ݟZp����/��Me�����e�]�3�k�#n���ܢqAMp�i�=��i���<�ߝr��oѷ��E�Xw���9��)����͛H�����1YQ�`�=,m�F�Q9��Vt?����7~c�?��00�ejHT��F�9��~$5�����'1/�׍D����T�xq�焿�n�6A>\����'������2��/9��<#���u�a0��cg�g�@�t�����v�	�>��Q |ZN����P#܍K,R<	'>81jX�)'�n��V�՘�7A/�zф�K��=~����I���jBĥ@�w;[H�G��,�u��a��X�LP���FP�H��8�����Tq�hR'�3-=��AU�	�6-���{سi��e:�'��ِ�$��BnHf�N�����?����(�Ի����Lp }�F�x�3���js� ����yκ1�<'GN惈t�	ǐ�a�"~l|ְb�`�	�!�|�x�����5rZ�)!���Ϟ��O�����w�y��"2�7�o��0B��:��԰<j�nZC����� �m��������N�Q��̆���G>[`�n���3�/��t�!����η���/�KhB���?�~&��;���QM�?ۢ��:�g���� �n-��a���'��`2���~���o�C�w6-><�K��BN��ۑ��V ]nHq-�'�"&����~�%'���)y�?�ǧ�Kv����s0"�"(3tg��*��ݶ$�*����a�|	g�����؃q���x��]��|F򁈭�T��V5l>������<w�n�DM����K��������ԣr%{ alWI���ӷ��߳M}K�dpЌ��n���W��q�	ѧ�&f�l���g�؄ Щ:!T =�{/A��&�P��PY�`���������a�"y�������{���'��p�Yjö�4����?!���n*�Z2�#$3��L��@R��ui��:�� ��~Z)a$��O|�B	PtҥT�P�c�*�l�JUPVӘ^ZS�x�p���	�o�
%@��f�����HE���F%ݰ��K���g|J�>V(:��}:�^�<��\P��������ɷl�P��}E�F�B	����iJf�\�S���e�񰺀R��==T����|��T�O�w������4N�3��/�R6�T�I�`��8s�JϩQ�9�ҳB�|x�гBr�補Z28�ڳ�/zy��	���C,~�P�Y������s�%aAH٢�QѼA�]KѲ���F�(]A_�
ug�T0�{�jW�	�#���/��@�:+�
�>^V@��_�5)�2��������_�1R��+�1*>+^�����g9�������[�4�V�X����1+@=��b6�r�eT5�Z1��/L$e��+�
�x|���JM����--��?ݿ�k������Pp�8q�^L�Զ��WlJ�XW�\&��O���c�u� j�I&��ǋ���;f)�H��"    �������	$����|Bt����/�=}{�3�Ô�lJ���;qS�.vC8���pw֊��+w�(߃����Q��칪ZDm���5o��9-���ƛh���I\�%�/�y�
z?-�jX�
�S��*�����
�$E�ʜ��A�����k$x%�ﴈg���J�v�w�tz�ii�r����ǯ�*����G��i=����J���I�7�����%�mO���	u�2[$�2(�� l���PF��&:cn�:�@�s2Cc��u�eqy\��E�z�fv�N�n�������{b�.C�HTt��P�k0��NP�}��Z6�34:au����5�Sv��XS���g}���=17��=1�Fs8��7��TO���)S��̴��wU�V]��7�*���4VK2Tŷ�b�����c�C��ZD��a��=/�����.��_�A��daJV�˭h7��b��Fl�M=t��������8L��� �����5�?��W�.Ԑ�]������7��r�c���}:|>̣[�X�ҿioإ#kEHO�?@`�ABAd�|�Ļ� ���� F9cL���ؒ1"� �m�~PGi�+F��uk����!<2�7a��Ӂ�=*O!Q������"m�����,,,e��Sti)!S��6�0B�V�p��Ai�gL���	�S�>cB}�ԪϘP�1��3&�gL���	�S�>cB}�ԪϨ԰�H�C��E2O*5m(�y2�"djT�L��Z!*B�VEȄ���U2�"djU�L��Z!*B�VEȄ���U2�"djU�L��Z!*B�FEȄ���U2�"djU�L��Z!*B�VEȄ���U2�"djU�Tj�P���>.�Դ�x�Wt}��ejՠL�A�Z5(jP�Vʄ��U�2�ejՠL��!*B�VEȄ���U2�"djU�L��Z!*B�VEȄʋ�Qy1��bjU^L���Z�*/�V�ńʋ�Uy1��bjU^L���Z�*/�V�ń2��Q1�bj�AL(��Ze� �VĄ2��U1�bj�AL(��Ze� �VĄ2��U1�bj�AL(���e� �fĄ�~�Q�/��_��ɥ�['	��땄�'�3hqrgj�)�~q�<�ͷ��@�?��fO�P�Ͼ[�"_n\=����ߩ}�;��+����
�X:u��ٔ���\$��Е\=�^�Ȍ���G#N�Y�q��8][!'K���w�LK�Ez�u)	�E�%v���)�����������Sl�4G�Deo�5�-8�@EE%��n6G�S\�R4:|w���^v���fB9����j�U��@��DyE�9ǿ�,J,*�s1�$@�Eoo��Y�EV�uYylL����čL�$&ToL��	���c�`F��@OC*�C��XCW;�9*��Qd*:n�n6�yO��3txT�O�^�ս`\I��t>>K(��~n�,%��5��]����)�V(	`�s��%ZrpR�ڬ=�&zTf�r�F��__yT��(A�J�$��/����:���S1���x#��U6���ïb�I(�W����{�b�����{��W�9�1	�qa$�)�֟P��p-�5-����/	U+W�B�P�Ҟ���ʩG�I�)8�G�J%��Wk���{K7��������V�o,͝e�'�0�`:L��tEuL�,�
�r�>�r�qI�I����=�@�L{��x��v��� �eڃ�z�Y��~����p�05���/�w�����/O/�PY���Q/�Ilj�2�BwO�W���лz^��9
U�_gw�Zi��C�@S�!$y����{������0�P�R��<M$�P�R�k���7�>-���ѳ�Ixj�D�l�����qB�K�g2�g9�^P�^0��/?}Z��yG�7cH,]v�:��fjT�L���мu��	����x���9�n*ï%��T�����j0����z#�bG1�_J�ngbP�9r>�����,����Y�5hPt��~>U��C��*��k�zĄVEF�A	���g�[�*��]oldz���E��A	������f�����ZVѲzʩ�uy�v��l�u6[wrI�f����>]�ܡs"�àHF���6(R���x0� ԜȏZ
��z���E{�A	����8�lt}sL�m��W$�W�
�yqL�A	Ь���?s5���劽�l�%�9%������A��3��J`t�׎�UA�W�|V��|Q��d�5Y-R^�ð�`/;���xe��d�!Yo�s����Vc�U�2� �co� �9���h[<�3��@%�]x4.��#�C
�{twO�=�F�⩛1u���|N�hR����%r�M[�����^9,��,��D�4:������r����0।��)�q��@��+azV�o�BqJ��D~����n-4#>\}�S+<g�ZX��<�.(Xh���y�H�빱��2P����1��^���1+�Ƅ��DO����L�h�N�������_C5|�������x
tn�El�硰'ڸ����^��!S�3�.�k��p\����>�F��W1�nZZp?뚚}��P.���Ǵ��΍w��ݪ�M�y$JvU.���-�w��
��{V�aP$Z[�d0�UR�]������k*Y�72�՘��rk=Ag����ooD����6�@��,���@J#�Л�.[��
�_z�۠H��70�
vZ!?�qF43:ti���=s�ׁ�����둜��o�px��x�/�狪��[�rT����u1�c�x�^Z�"�J�+�yi
ښ�F�s�����O?^��y�B\�+����=�c�>8�Ѹ1�s��(7I�P�u�*����֖����ϣ�|I �����,�iC]���rqu��n�Wwگ��_��k��^N�2��
���I����A ��U�a-����$6*�����S�ޏ����c>�����ޟ���]��&�A��<�Iw�8�Ǡ���U3�s�B}�f�~��[�^N� ���@�Pm����QOY�B���x����p����ݪb��S��,��08y3��zOu#?W��1X�+ԍ�Dנ���0&��"�� �"~��Ul��њA	?�3(RC��>�u�#/�i_�]��j�Vl���A	�ܬ��5�bo]Ӎ��cz������·E?w2(�=iX��0t���cϳ����>����5��@�?�[��a��n=��֞�9�P'jd�yi��`SI\dP�|3oYF�īb�U��أgM�J��Kb�g<=�a�r4Ƴ]���Җ�t�(��Ŷ�b��b��V�No�>}��]�e�;9u+�zz�	�Ӏ+n�1D�'�a\�u��:&^�;,˝&�Тa�TtN]�K��tX�;]���U5�ӳ���ﰤw�%�Ò.���-���â�iV�nuX��z�NB�⥺�Rݩݱf!��e`�D�z����s��)�c��nA4/6:�񅾃Y��<F"� ��߼_�[�o<��`#a� #>3V�;(��)=��64/(�|;���\���:�iQ�~� ��ȼ'�%�7�q�Y�~�ıʿq����4A
�FS��n����=��`�O��k�_��=��y0���GD��VT���5�]��ԋ�ѽ�j���dQhd]Z�+������J��rhG&h.���ŝPE//�s��h~&(/)�k�݁��\4j�
�3>rw	�MX�͠(VF��&���+�]�Z�D�y�xt*�-��||��%|o��Br�.5�ܾ����o{�#�{ݳ"��epw��Q�a`D��y���ꬂ/�Q�/-=t־����Y{�3`�.$2`3�h7롲
t�3OU�G}���q�0���۝�3�WW':"�s{蹽Ec���z�`����Q�)^�=t��⌯��>
u���mz(�����c�&�?�S=�6�FF���ɱ��C��=I�e��l��x۳�C�7�ʂ�����ӝL�qެfK�:bzhg:a�Հqׇ-�k���t�0.���    �����p�� #LЏ��ɷ�C8.[P&� ~�;`�f��:r�%7`�Ӥ�'+�ed]w�wg��O���!9�Q�=2���Ac�wOL�0��t�&|l���F� #h�E�jA�[CO5ثG�q�J����<b�
���1b<p�gň�p��wߑ���
�aw�?_��4½3��KKa5,_������O�V��n��B�H�킨��޽�%;�ҋw�;�@u�d*̈M}ġ��x7,o��x��T�M��+v���g��5b�������n�^�ӱ�ʳq#�w��Q�(#����� �u���.ը$��|�����@�@i��:"���������U�K��^�w���\�b�a��Y�7���v���h�Q#(+�G�.������#>ʤ�էPCܰ�����ɨE*�2a�"O���.@������r=S0cpE�CE��A�B�*b��=Y�7�nE໓�^�C���q���}7�fld2J�gXL��<���+i�@��cc4�e��� Y��u4l:S��O��]z�%h���������_��
0�z�½��&�-`䰐�Ѹ(���5
f��sf��5]�ڿ:+��E0Q������e��2-"�|��ƒ�I~�L�a��mPd��A�+c��Ꝟ���N��J����uA%U�Wk�V��E/�
Y1�욭$th�v����&8Q�ߌ��Ƅ�+{�ԧ�?�4�?�Eb�p�VMg(S���'V�T_��(H�A6%@�x��Ff�7���j�3[֚���i,���N���s��FJ���e�֌�����S���?<eE �D��;������J��紈Ǝ���f�I>�g�|�p���4t����c\D6�A	��%v�ay�������7���} �tc���p�0c�)���������=pX}m5l<5�����@�Xe.9�"
;�
6�>-Ґ�q��x�S޼[M�д��/˷�K'�����{5�;Qs���ՠ�T��Z���I���x� �+'_e�՞3`Dn��q�L�w�aG�����@ �����9-��mތP.]��P]�FH4:06(�<jl�i�?ɕ�,g�>B�7�!X���=����	�Y� �$W�d0bp���za6��	2�:d�t˳�����X�C���	c{2��O�	�zj�S�\u�]�z��)�3���^�q�gI	Zdqw�}���uSZ�q��u_Z�A�|�YIC����_Da���1nƬ�}����wk��n��]�</��{E�h*.��\��C�;~��s*M��n^�:�s�:@�)���=_�_K�t�&��k��ҽZyq�qwK�tǖ]g�hi^���i�а�2���\�8�~�׊mn�����j��k���7���:{~�gKVh?��)������֙-q������d�X�r�s���[ݗ/W_�Ɋ%���/?1糹%~��E�S��h3��o�Bwgtt���~���y��4��oPt'��D���'�0f�L�b�%���L�:F�@T )�!?�͌5+Jbb� Ȗ!	<fo���#��j��H�x���$-�i�ͼ���G�cm��6��VnE)��gp��\�,q����3�5�@����A�N��Y1jX��s7�2���C��K�5�?~�~wnZ���H��͌����J�?�y$�&�˯w��j㇍5��E��+�"��P۰E��n�vϒ�S��"Jx��$�L��	��3\��ArWL4�dU2,x�F.�T����S1ɖ����]c��(�'�f�zX1���Q��:�zOO�j��L� �F��.O_$�Z�%�'}��[:���J1(Z��ׁ�?�M4g;�O�x{���Z]28��p<�J�_,��~�o��@�� ����3d\��M�G���
r��_�"���Oj�e���%jC�PJCqD�U�Jb�y,@F��c��N�'t6wkx�м���׳]lk.V���
p�uі�c��K�����c��W}w�W����*�2��^ڑ����d8��__P ]n���Qr���2:,����Ч���/-�>-�j�5x��xa�"�,�1kQ}��>-��;/�f$`���ٝ��Ζ&�m:/�R��Z�y���-`�:��Q*09��w��~�����%#���+wo����.���80�������tꥨ�i�����90�����f�3f��Ɲ>���OW9�?~�57�!U�G���y�� �ʆ'�7rؐ�����`\K��!-bѴ���������/����h���8a�A	�V]��dC=1��Kሩ6�s�?};�I7�[�F����G~R'�p����[�ӷ�=��J1�6Of�YJ�gt�9�i��S�]tLy�دa�����ld�:�V�FW�0͠�60(����&3����nl�]_�.xH����#��
|���w�K`V|��+���r�q�Ӱ>O�f):����l�����^͘�z�n�/�0��
�p<U8;��}f���2�z� ������!Ap�ghC�<|��5��򁇴8��|l%@���{>Ri����#��6� ������ͬw��¥���f���@���ʏ_�X ��3s3�޹�3n;����<i*��罜���L�tD1���\��^Q������ EAU��%�1����\Z�����Q�:`<��A�	�M1����U!�_�1nZ8�<�_�A �O��'S,��&���A^�����+�,�1�*(In�x_����
0!�q$x�fa�gK�)T���x� �Ώ�yx[��#��gPt�W���q n���#�v�b�G����d��n�:^��X�zM�w�pR�S���>�����!�m=����;�����i����P�|o�/�mx;y���P�Ќ~�- Б� ��t�r�?߿
΀1�� �"� EM��~3����a64�V�cp�pX%r��ߖ�T�~Xn��������ꋣK���X�A�AF�;�G�Q���V�$��(7�.>D�[��޿ʬb)r�@e">��c�*�D�>���>B�'��=u#$=Je2��~�0v�ء��i��d��L�1-�B�y>�ƴK.C�M{�W�W,<�U.3*�ji�=5<�����ة ��^�rB:
���'���_�6r �Ͼb��u�?� دh��f_E�u�IkJ�Ny�2���*�X�<�G�&X��B�w���Dϧ��Aq7� ��֔`��(��qӉ�wÿBΒ0ߎA	J*�E��K��$�X�N�0�Quyk`T$�Hf�T�v�'	� �*(�A?>�Y��(A��?XB�;�$ar� �s��	~�݉^Y@�>԰W�%3L/��m��o���G����^�W-�Y���&l�$�9R�͑��Hj!�ɢn�hL	��$���,���n��c�[^O�4f*>MlX}�GZ@�"Mqm�)�HSlP\��"C��pղ���]Zq����
wiըQQ�����ejh�W�L�w_*��
���kjn��p�V�A��%%�H�WxC����c���e��
�gd]T�F����4:6���Ԁ��^����LϽ*\�ղU�waO7�
GiU��Dü<�=6��4:c+���1i�V�Қ����E����@	����a3��/d=��@���F���7|���@��?c�G�tk��.4멘<%G����d�`����B��C������Ū�b�>40��2���b0��tN����X=G�r�V�:˂�K���%��?��e�3*�vG�uR�KS\K����'���	އ0�qKp8���`�:څY�	�i��+>f	
1�lnP d��%G�6�'t�~���	�q:���\��Ó�"�b	�����<���&HǖJ�<�$4��Y'��]�E�y��K�a�Z�k�]�b���%E��krM���~�AI���Z���´�T�����HP�y�y� ��z��$���¥��z	�v:V��i��n    �o.�=����D��_��1�e�ᐅ<��?ζO;zꗠ{'\����ld�V$���c�W]�����1������§�R�'��PD[�,�h6�L݋֣W���u6� �	�i�}�ք��#������y�QO��˵�]���,	��_����&��B~D��N!�JЁ�3��ݚ/���Z�>���0��3�Jx�v�O&F�oI�����l���e�N�ি5�u˝mn�0���6�+pE��&	�&ɜ�UI�!w܍.���%z	�&�#��܌���w���\��� SOE�oOK8Iޘ��m�����^�0�H:25�k�sY�hy~��p�"�3�}�� �5��3�}�N����U?�ї��xF��q;WJ8*Q��-2���.��e�W��=���:��bP �v�R����#C�Ɉ���������&����L�z`�D�{4��㲸���Nz�6C���wP�:÷o'.9w���̄���O��5�ݿ�4.`��bx��;C�9L)�����QF✟��}�FS 2�쿄u�	m4!a�b)��cBM4�J�֣%ZӐ!��z��eW�୞���{G��-���d˖jК\*`:z���d�r
�q��.�h��V!�AU������%��������m�b�s ��m#F��M��i�b���dN~O��^N����֏֘!��똎���es/$�H�bf��7��t�d���(���N�_E�h�kL��PώaZ�a4�H�������+C;ˈ�Ƚ�2�3a��<!�����l��T�k�e\�=hJ�����٪L��C"aHX`u��������2|��7Қ	#�HC�ڝY7��W�U�OFM�z�iI�{GW���a9�&�7��e
��c�(sO�2t��ʻ�Ŗ��hN�z_������ȴ{�Ҿ�؝���2-�'qq�6�)��"�z��p�F��!��}��m~j�+����i.]�C�� ��$���2�2WB{�6�>]kW$���{�6c�e�|�1p3�O3� )`9���2�h�KJ�'����x�C��kiZZ�v����v�\��{����c����;?��(��bDTr11�-f�cBJ^9/�a����MC��݋���������e�dZ&����k�~	[�!:�$@=��,=kvCE��o�kϐ�,��	7[*z�]���d��=�յ뛝�=�A��W��5|E�,�x������O�gi���O����%C�"?�Bq�����l��Wh2.�f�"mbr��2��f��M��g\�~�֥F�������zb���p�/G��q�x�R]�T�S@�q22�:����c��Ψ�O74g�@�!�-�K���WQ�<��Ј'�P���|�18�巼��O��&3��غIe�ͱr�#�:���x���<u^B�<�֝�DD˲g>�,�i��(�F���I���@T|��;�@������$�ne�q����7F`v!���q�Hq���=r/�����Z�=/Sxb���x��QB��Ɠh�� ,PR�7��l�'��?�ٳ`���%��3hu)+����5�Pxc���`�[t����`{ �F/!��Akg�� Ոey^
�ȃ�b�l	ʈ��/�C枋¥
��m���X��k��������\un,0���2¿�����\/j3�����l�
l��w�n%n�_���-�� V���o�ػeG͢�������F��Q���+P�E/1���(�+B,�[���r���@��)H����'���O�H���@E�N��876�%A���'�r����OA�i:�7��B��o��������dA�����lEq���������F� H�%�/2�F�,�a$���&9�*,��b�UXbu�T������M��U͑^�{������֟
*s��FA�ޟ\�,{4oT�gu�>���j�}�<1��
#� �;�
S� f�m���}qg�
k� eVP�iiՈ��&�b��M�
�N u�<���FTS�ߛ$����!��Tu��V�!�MEj4����ġ�s6&$�M+�k�Ĭ�
;��k���c2��@���5+l��CK�:A��T��7�@&=:���n��5����g��V��( ��Ya2j��͓_�e���%�0;|��H��h��ȳ�&d�5��*��UP�B�
{��*6��ww�Ya)�~S��Ξ诲��C���9��>�1Wa�UUz��ٱ[�A7@���¤���B��s�U�
s�b?�e��y޳�̨nLV�u�%���7lPΨ �^"x�(r�3��3ji|��Y�g՞�0�#R!`�[��0���)�RA����;�~��b��?��u�q1[j���o&�a[�����]Ƈ�n��1��?��KM��a{�*�3|Ĵ��YhF�-�ERc	,g$���z��q�ѓs_{����%��NK3�/�q:!��AD��aI�=1�_�	�<ѵg�A4�hi3���m�H-��a�ґE�}`�a�e%%�hB��~Ěb3����;U��G��/�W����R���ǏF��t���g���C6����~�d�V'��w�#:)�}gؾ��FПH":t�OP4~��w�� _I���qE��a�
&��iX��b���?o)�a'�+v�;Q �ΰguEX��R`�Hd���0!�9���U��^2�+n�~0����{�7�A���e��5��^3l���S��׬B��*j��i
3,/��o�O�a|��x�~�U�N�}����2ע�ƽ$������c}ֆ�[�ql<�y�{ 9�����6�WL�^��:��8>���>~��y�~�ܱ�j!�E�8.>��"2�����F�Og������[bF�h�����x����}�� ��}����߭������Q�pVb������ȯVLĆ����y6-Ub��M��j�$��!۳ș���tK]bgȼdVWC�t9X��w��#�G�_���_Я	��̭���H�8%��kH/@f;5��ǺQ�0��9�˂�Qn>��!��+��Y\��a��g����ڭ��Pƅ�{)��~A���{z9}F .{9ie�ߚ-�ֲM���R�"��5��͚6K [�}�1��#��3Bf	�Of���G$�!l�$��fΚkYډ�7#r����������Tߋ]�P�\ϠhP4ڊ��p��4�;���P�P{�� x4;����D_j�:�%�U��������m��>�Yc�Z\���z($��M��vi>�5�;��`��a��G\��1��6�9�A��:�RJ��!�G���1���6�"���Yr�=6~!a���H0􆔣��^��llڊ`�p\�4��m$�r�A�y�_n�{^�����f!�~�a:��ckQ�q����&iB���֢ႡP���������1�ف�nK2�7(I�*������t5��Z��ϒR3�3�o�r�N��B�gzSy�h�K�m��D�d�.�-������]	�"�2ݠ�ot�AK=����a�>2�v�����٩��N�S[�{�f��"�1��ީ���Wp�PBĦ~��I�=���f�x��YD�p��:b��S�q#T�%����i������"�vЩFSf]����{E���4�$���䆓d�ξ��C�7�&7�ñ�Y��˟�p��[IG��[7�1I:^B��5;�IhӴ���\�D���Z@�+V�6*�
���8YR��n�)&�ʹ�7�pS���ڻ3:N��ֽ(	3����#�%�'�����4�m��̸=!s?�Y%8y�,ʌ���-ˆ�Y�8r]I���4D�jk���K)e��?ɸ�a���U��~~m�Ϡ�Ϡ�%*ˮ�[ZO��4P���s������q{�G���jk�.���=�3�{H�����x�t��~ ��Զ�����F*��O�NzB�nO¿7\S�?�n��ۊ.ߠ˷.?��Q^8���{�oxV4_��~W�\�;���}>�W�Xe�e���+Ag�����    |�r|�����*Z� �\|��0Z�J�hl����?����u[��
��d8}����,�j�=<�yg� ��6���7�@6������e����O��}�nv�A�n����m��"2��*����h�}ҀaڣO$�eC�����O��6��� �g�}�]�-�pS����٦�"�+KhC?R����￝6��=���orۊ�� �6KR����A�Uz�l��&������'+h�Mڛ��s{�\�d� L�?j�g�ό��Y��'?ciC2���]iH��:�'�pN_<�5[-��΅���]�-hܗ�7f4��N+��:���� �h
:1@$o+"y�H.��Q��~��/}��8�a���	�����씣A,oC��cr6(�BZ�mBUP���R�/��rk�A*��m~>�ON_�L�f�Al���|4�Θ�d����J�d��=(�[g+g���y��d�C��&��� uV�0�|ul�FÜ���|�̻: t&@� ���Q�9��Z���O�eǛ�p�P t0Ÿ��ғK{s��8��wD�V:�V��rw���f��쮅�%d}BPAO� ���vK$s�#�Uʕ�G�+�+��9דZ�|�bדZ��
�=�����H�+�)VB�S�M� H�
w���%T�!Jz\B�'��I
�P�I�W1(����~0{�no�A����T�?B���g���/��,�V�aer	�\��U����J���<spQ>�������`�U��Kψ���W���7��I�=����b{�sQ�<����LS(�ۯ`��(|��N%�x��I���voy�����"�?i�'���Oh>qL����m���\�l��	�x���r� �\Og����"#b�����aPR��@1&Qw|���xY�T̟�f�p��/�v�'�T>��#/H&T��c�xv=����i�|uML_��ʬ
M�|�K�f�8]��x�(��ΰ� 虻�k�+� �B����`�h]��?�gm
.��߭M�O5R��qs߷��^���n�ݻ�J�4�a�p�����]�l�P���\K{�b8�,��	�&~T-'����P��"aܔL ���:�(�AZ��e�{ꄅrZY(',�ӈ���/(7�##r�A?�����x�
&��8���P�i�@�{�VE˾(~,�*(��(5��.+�9U��ie)��Nv�� �w�]Jf ��"�Y��w��5YX',�/q��NX/']���w��\9~�dK�G����7aћh�Oe&0b$�w���d��m�	��rk�㾓�k�27���焚�(��l+��o�ْC@I��z�'�
@]���Q�Yœ("
�#���7��~J}�zr"y@Q nL��U!rت���W(�hJ~	
JP���)����4�If���P�uw�1a��V��	��t��jdv%K3���ɠ�ʪ��p}&K/N�pE�T���#KfWT=�S( ��{��yK�Uݝ2GG���K_ƙ����}]gꇅk?����e�?V���*�C�(9���#�qP�x�漆r!��2V�C�x3R+�d?���"��+���i�&`��|�� �Se���\�2��?�Mީ�])������˟a��3���1}#c����� ?����/TL*.,�PD��Ca?y��e����{�d�$����B\�+D��> &��"v�|�)���{�C���ۆh����4\��ڻ�Kv���$v`�h��A�}�eU�X�Yz:��~���O۱_%x���u�
�*�����l���jcB��۲�mY۞���CT�	hwR!9-��`���d"vh���������@5m�Wo"�؝��;qiQ�ޛe"vhQ�P�U2�����,b{&P_�~��u���"��gw�ئE$!q���K/�����>�B�ED}K8ׇ��l; �v���Q����C�0�����ݹ;)���Y�C8��O��j��V�h(AD��=��I8+z�T�<�=�LI��F#���=���s��9;[fM>�'��?�s~B���(ꝫ�؉<���|��kV(:�m4��w_k��YG�-?�A�����Y�ӣ�2�+��3h=�">J6�ݍ�������--���]٭d�OLΎݓ�8]iXD9eG{Y#�m{�y_�cٛ�Q���V���e�fjYƗ�=���H\�@"$�h��$+ͪ�1�pfBd'�S*��[*۟d^����/N�l5���4V�B����y�����ȕ��%$�=��s��}R���x����ղ#$�x�YC8	
��5��6�������-�F��CU��uu�W
�f_F�ɹ���h���$�N�:��iA-�PB<���T��`%��\�P*T�7_�=Ű=l�IHo	����HJ��E�&Дm�Jb�7���@L�24�U�M.FH��mov�k�f���JkT�����#ip|��Q*��E(yql�=m�;�L�F	�ۼ�S�Q�c�M�3
v����I� N��S�����4�ַ7?;8xshZ�0ZR/�ؒ0�ј��oޥO�F3R}�����/b�7�0.�F���J����Ӱ��6k�b�H��GyC;��`
磯�Q6�-`�E'���3��>��7��i����B��pzPn2� b��0�J5*�o������0�`!H�A:B��g�xZ������_��:��5����=P������Z�U�}l?/��(sj����B�Z��E��qEΎ���y���u��:��#��3߽)B� �ޡd:"�+e3��l��-`Wr�(X���Ǎz�֖�>���J�}�6�5�� �����|l��l?��~&@]=T͕{�Y��R+�e���7�:@�|ԝT���g�~�>�O��h7�$��a�� ��� H��>`����EpKUܟ\:>'ƥ�}�ǈ�{z``�sui��+����]  �<��9P������P"��y�w#���.v�mY>^wd#��o\k�0*|L#�o�w�	݇* ��wFN {�����tHҏϯ���M`��1�+YD���򐰈֣���1�MC�dkC��3M���0G���Z���h��Ǎw.n�h ��J�cR��.ы�i�A��ڍHgd�NX���]#�=��	��<�9|����K/�����[�>���?.�r����kd���N���D8�W���l�|�������F.��'�+;>0( ���6�M�Y��������Å���ZiXv��1̍�`.���\�0��"�f���Ϻ~X�T&Hh�$"�k���k������H�F��d�_v׬F�h�+7�A�ja�t���d?5}�����tA���gxsɌ���z� �¯��l�R�ɯ��F��͉����{���<J�l;6B3�d����ch��P>�:����ZD����M��F�_~�i�O�7t4�N��a�,�f��-ǐ6v4���J�ɍ�)c�h2馍32՗�ø������h�Q���'�4Oǽ�$A�`���� ׹Ҙ	�;���o���Q��&�L��[Y�>��E�`��oToǕ%�p��:J�|�f�2l�?Rg�����ß�JM#���0��6���0���ug6h����� ]>��w���	���r�D�'l,ڡ�i|Ka`\�b��jl����RK��u�]Z�Z�ݧ;�'� +�O�c���<D����vr�%38�T��O����vB⨕R��VK��D����y)���ּ�2z��2l4ѻG//�A�eWZ��0��E��`��%F�b(4��RD��55c̱S,���6yE��1�zf{��phT1�_E�+O5���]�Sތqh�X[������ʌ�7�Ld3F^�6��$@�6��onw�t�>��Pt�br�������-}����t����@/v�w^�b����Lr[�cʹ���v�O����c�Qy�^�3�\7�-NʾbzFfp|pF�{���b&��˼čG�t��)�"'uPĐ���N�u��&��t�v7�����zމ��ÿ��eA�z[=�H���ZR�T��Xr�V�5x    ������bcW��QA�
�w�ɧ������~נ~�]��-��41�O�H�������h׿���/�������5����ߧ�Ӯ����e?�k���'KZ�k)�o?��`��!�p��g�����=��v�v���^��&��O�g򏮵=����@�Hi�Hߪ� �Oo���E�G����%R1r���즂�Q��6( W�}Y�_�������LU����#-*��2:��	W����^xT�*(�F�!3��t���u��z��©û�򆏖�t�2Hb*����d��]�i�BzA�}`~ٕp0�_�O��3���q�0��<A�+�2ё����G��G�К�AO{��y�@����h��uC�
0;��T���sg�.=������I}��ZrM�	��ԣ]�:9�����,B��n�
���A{�ї�h��ͽ�i�h��*?]mI���i\m��6���r���Րe�P�X*^�u�0]��8A`���^���r�p�l(�L�^O��y��FG�X0Y��/�ӯ������hL�?�.@ê[�׍?�
�U�a�N���`\�8�'g�d�*a��6LP's��P��	�ᴢ	Nр��?�d~�����FS��B��FK�σ�۽}��v��TM �� �U��K�.����y h��+�s)��#3@�`�jz�ި��w��ν4�OU����*3rIR�ƻI�6�k8=�DnY��ŷSrﺖ�����>2�9�+���ĵ�	Z�t��k�Ժi˜m�ft�Y��y�&'�(��3��l��/�����������V�^�d�g����чfr�A�F� �ۭ��M� n�n�Ͻ\����f��@Z܏l�74tÙ�{}���.Y��t����E64�O�_m��۞m'P�� ��}%�pC;�ϴ1Ѱ601r%mף�1Aj�<
����蛗�[�������&^g�����:����޹��dV{�%|sk2�F��jLZ5Fȍ{�2A_�x�����L��@`����["�;à H���U7B�Ӹ
[� ����E��}D�^U��o��[5���c!�	x�Y����2�=����Ǜw?5E/+H;x�Nݟ���
��*����i-_��b�})۱�(����0�;��8F���I^;�CLov�	b��W��M`�=��o7���y|��oCě����Rr��V�Ce��n�B!�UaP �� 
a���џ{"B}�u��,B%�@	;h�qQ��O]z�{v�F(I��vD!�J.V�!#[��Vs����,��p��y٨}��5�"$B%7v&�d�m��v0( 2-���#䱸&�D(cz���R��	�0�],BC@	����w�f��������h!��eD.����C�:f�&�Q!�i��-7����Qa� ��)�d��Ϗ�Gf� �yEh^d@��ѳ��������!�]54�B����W_�e5���\���p{[z�_�e7=�l��`֊s�-(v��$��QPf{�]�!d��y����ڄ�y�_���僆#fE�s�&B����+�DE�W��D��y^���y+�R�W��=/s��!�ă�yl�W��J~B������k��n,,������J�@���@��\u�P]Z^���*�K��΢hA�p�K�.��$�{\��v�(!���h�rZ�
Rc٪C6����$��j�^�^���eB�	��7�/dl��3	�D�t�Z��i�%��vح���/�C<B�P�:�E(�ڷ�-�����E��1ޗ���PD�]r� M$E�zH<t��$�=�HT���fEc��F"z:���k��D��#���z�o��?V��ø���r���������#����x��Z�#��|Ζ� Bs���3�����������~G���X
�!�ݻ��ɧ[b�!����	"��##(@|k2N���߷���+���}�E��=�����b���Y��v��&� ���F԰���%�a����)�7����:�F��/�%HbB۝�+�����׾����%�cT�M��Fɘi����CǸ�k9$�dɂ����F6���;6M��ҊT� U	�Fn�H%���b��w�N�B%�{9�w��� ^~��:�r�͖	Ҕ��w�O����r�o�D��w����$nq��t:�Q,a�{.� c�#A�H�a��HB���K�0A�H=��Pԋ�.@Ko"}$���y�j�����o���(	���b�\�+l�$�o'5N�Ő��vU�e3���	z@��4��IPI�5@�O�ᑠ�f�%l��ʶ>a[��ۚ�U��>�ˈf��N�v��ȟ�O�A�Ln�)6_]�~�����ie���WN��D�I�/��D��i> }�&a�,���NO�/kI�O>�������ٵ��W0/�|�~v�#a�,�\6�I/р	�.$~phæ����%����=���[g3̌�bfd��{����ƃ��kq�a�17�a	�^;��?e��S-�>�aO�+��Lp6EFr�$�JȰh$0	!è���G6+ɾ�s��F� H�l4�2A���\(�Q{>�h�����N�1�m�8m�0y�V�d�����4��e�P'�L\�F]�8���~�|#��m=�U#/�tFKML�#%�)F�@�B}ޮ���Kޟ�2,�����a�djx1č��౩�ɼ$&����������Q����ʰ~[I}kdu��� _�~�Oa����)��0�L���Mg�~�\6�wq�+����@R<��l��%�z���+���橔a~	j��[X�LV[NCӹSF�}�F� d����J�$�t�G�o�}4�A��[��b�+�a����bFP�w�{�z�0�\s'ɰ���^dҍ
*���D5�q���T������3�q�����w�����'.���]DJ8}�����}]�g����c3�{S���"�/Z{��>ݸ��Z�*t�Es6x��_�Z��to'9w��+cl~���|���W�^���&d;�� -?�y��z�R���]B^����M�f��EbFY�aQ�aQ�����mF��q��f����N�q���i���������O�gx��/*��޲���z~Ö�1�%`��w�MR��@���;WI�p��Tϳ�V^�PЯ��Q�}zv�x����
�H�66��K�Ie�װ`�TTR��5?�R�FI�w��^DS%���p��@�,nQb�,�&�����*�@�,�����e_�wA��ҝ�H]F|a����v���&C�1�_�u6E�~�v�]��zw��v�
�:�{���E9�����]��B���;u\�l�%���-������;�l-���-���)0|ˊ�[`�
��z1�$��BN W:NFq�ED~�^dsD]�#*��,����'�TLu�{��c�d�g}k�b�P�B����J=�ǝ̐��U����U�R��Q1�g�T�.���܀��K��\���oy<�orۨ�yYH=璜krی���y���sF���pː%a�*B�o�~�A�y4���28Z��F<�\7���˗��9B����ۊ���,�F]���d ��g%����_�V�W�V,�U���^;a��	֥�կX�����<_qdW�W㑓�8a�Nv�D�2&�I�˚�Qq~g%'3d���~�����/�t���-��I�*�c�=��RE4c���v�Y:�7��a4ӊ�$\�sWq��j�I?2���G@�6w�	�A�e��H!�=t��)�Q	Թg����g�AЙ4�?�a���1$��̐��?n5*�����`Pd�	U�>j�׀#.��o3+��0�:�@�N=��u�� �k��BB3�Ѡ HVpg�5j���I\S��Y( $�p� �n�&�<�ɠ Hݼ]������u���t��9�SB�O([�
��ሜU����|���^g�l�6�7�j������n�N6]�B<[�"�(-�u&�:��C9�j���hJCE@���x�0���(FeP    ˂�WUB��h�0�4��ϓw�x#��8�%@KC#Х.Ď��#��C����<�S$�^���ʦAйlH]Y��	�����`tEr琈�gC2����-c
���1��ME� ����uo�t����F�(�[~x��+��Ϙ�bs�}}9��]�_E4��#f��y��hu)���*E�&�>�A�գkE�&�rڛ"����c4���	1)[D}��%)bB���
��5���iB�J;'S���	%MH�a`��A��e�D(��E�q58�"(9L���~K̠�;o*���M���3��/r=��o5�
��\Ӹ�3��9-3$9w��~Q̐1��^�0�s�c���F\��^�dH����w>��I´˽n
��F[��;@� L�x��	sSZ���d��w�P�\y�k�u�z����t����\^�C�|�>��%LR�+נ ��_j�'aC�ǃ���;\����FW(pc-+n�n��w�����Q��ށ2
�Ww	�����Ռ�ײ��Z��j�zy�[��[P޲Vތy�{"���	5��^�^�H#� ��r����sR����&d�����@���?��N)cv�+�[���N��n3f��Z��n��1�u�����1�q'E� ��9�3rړr��|a�G�ތ٭s�n��sB1��1ye�5�K
��΄6�|�ɘu���LgL7���s����Y�K�TS;q��i����
�� (�z5E��(�|1{�����2Lu �����j�x�kkv�'Ct|tR�W���zx�����7'���`��裲��g�m����x�W�IW0�}��S�tPV�
���Nc�X�#	"��炙̜�Gc���+Yf�DW)�����?E쏻���p�{9�u]s
\$ʊ�D���Auafz�,�Yw�X0�[�s���R	���ނ���z�!E
�I�)0!��o�������C�~���î$��%� �$��0�xu��8��ڢ5�:O���G׾��/P��;֣3zt�M���j���;5�؍?����3�L��ASS��.�N�歓�G�X��'���TVP�ˣ� z�og��@��o��32��UE����1i0�ޠ�3�!+�|�J��\
�\Jw�p��b	�jR{ݠb�Rg�;�!������lw{r�f(pk9b%��7�*�tstpWˊ����t�m�+6;k�w�K���������F]Y4*���u*�����b� xA�2�����e���U�b�����0ht�c1_��idY�P�ӾzHŚRW֔�5E�j�W�)�m�%�b%�O�+fۺ2�V̶U��ݽ�T7[��|Yg��i�bj�?��+�Ժ2�V̩]]?,}���W�+&U<�ҹ�fX���\4$�t��S�2�Θ.g3��z�1_�J3&��&����1c��B�y���������Ϙ�=��:�l��}��0{e�l��w�r����\ �Q2M��8��%��Oh1>�Ϙ��֥�'_4K ��	m,��xBw��V��yٵ�����Z����d3c���^i�	m�wU��j�&�����8t*���F��}s�7�����;��W����98�Ӱ����a�裄�s稆�W��Ţ��6p�����a1�\��aem++k��ڠq��l_iiX`�X��4��B�M���UV!R�� ��͵��Ѹr�u�{_Â�V����g�N�����}ê�ǚ�����ݰj7�+&^Ò�T�_L���Zհb����D�r�V���Z�sQ�=�a����O�}�τ��f7��G��pvU̠ �B��wd��������\~ix1�gP �.O�������{	_<:W���M�4}l6T%���w�jr�P�t�Pu�^�� ��.�nc��{���ަ�Y�:����ճw��,8�AL�n�� =cqk�BҁZ��g�V8���
�b�H�
�b��*^��{p�
�b����$u}=��G�Dc�- {^gxX(�f܄�� UwÐ� �`
���y'���o[JBZ"����U��^�G��.�;�D��\�"��E>]o|�d��QQ�jf� ~�&��}%{#Ǡ���y�hJ�Y��9Qi	��@�O4��h	�8�0����~�����y���'�9s�ǋ�nT�}�?n�aC�m7��P�̎5( ���n��a0-{X�T�E�X��t�_<8K���d��-`�=<�<�\�n_oD�� �Q��͚(��m�˞����0���|�9y׌G���9�ǖ?
���6����\;K���q�S�s�o���n��G���R՜U�h��&�\B7g{"� ?��A��d��҂��X���3�s'��O7NBH@Lʰ
�"��U�Qol�dP �ew�f�[�L˸$�pF��{��YͰ��5l�Ȩ�,�t�Y�e�[v�
R��x�F͠>�nw�'[�0�w�<�;�Q*�Q-�����c�J� �ܯ�Od�(h���v+�^Ќ=�!O-Y�����܂��$�=
��hx1�3��	��K�]PФ�����F%=?|gN�Uy�h���� �W^�j�{ES�M�A7+���AWي���1��I`�R�ܜ�hѺ��+ڲj�I�t�j8���f�a����D�H�FHu���������#�MG�\�Yz"P�*�e��rٮⲝA����CŅ;���zvB�lg����v�����Y��<��Q�]pBi��a��a҃]�Sw�'�6�"���e&l#&��ɞj�b2��MaXF3}W��FLV}/1�^����Öΐ��2���	�	~)��R�A�b.�fm1���x�2�O�a�M@/$Y�mAcζO�H�mA�HJ�
( l8O�B�������]z��UhX�d$Ԇ%�rW�	���Vg�	f�fW_�u� ��k����qĴ��V�?4��.�x�W�=[<���?(��>����ɮ)>��$�N�]Dc{�Y?�Nōĺr#��F�AZV��ˋSYq1��;�d@>sB��S�����"f2�	��M(��	��LR����ѹ�RqK���Y��c+��)>��1E�7�����S�%��h�-��#��;\Du�\9����?�57"f��q�y	�ç��)J �T��<ST�ة����;�FLR����/k�)��:b]��Xq� �eE�1��\�~�O�+n$��}��.�鲘��@$  a�x1�#v�т�^����2��n_Pe|?�����A���Vq��=�v��͠�n����hW�a�����k3G�z,��塷��1u�Ccx.K�W�	K�NYq�� 7�e�-Jcz�j��L��*nR:���čO�U��u�0n蘖�u��s9��K���m~�L1F�Q�b�H
��k@'��$�f�\��G�ɽc	Wd��Y����Wj;���2XP2�D,9v�ԂJ8��h��3W.H8��xꋥw�\q1��\̭��k����ٱ� � �L6̪N0?�Z7��M�	��^�uӡ��K%�!+KyQ�U`�������_�,���49/J��?��G���2�j�,�da�z�m|�6Y��M���]V6,����!	��YmP D`�0����1&���������lO����4���$zz�~B�̭�d��|Dߊ\VI8t���;_>K8tJv�c��$��Ξ^��׮N��sw�$���q>�����[V�!�{�λ��$r5ƵN����/��a�1l��Hr.�С���`=[�(BL ��`2�����z��M@/�����׷�;aW�o���l�M�ĉf�1l�4z�'NR+@˅�R����=�Z*���"a��gc0��2E~�qBT�^l�Hce4��������A�U�o�n��e�<�D�O�Sh��;�f��e��
b�W���Y�r8�׶�{7�A*)��w��{��ssgv���F��7��@��N�O������b5l�BLX����\u���5K6��:����`$�a��P3�m��������	$]��A�w3�o    x�?R�v���vX�;$��v�J,�e�:����{g6���b�fQ�0�F֨���pV���@���ν(b��ơ�DE��G�	G�=E�_�.*�K?��A���[w.~sT�~ޙp���&�	g�='ޚ_��>P� Ͼ?�H��/r�x'��XU7p0H��Y�龊V�T ���76�5Lm��_�aܸ�F+�׌�ü�
�$W�߂3z��]2��:�����3�μ����;�:���Yɒs��>�A������f�ȡ��+�x;~L���R�eJ~gZu!�di݅頼ԥT����Obg4��RoP ���{2�z���Y2Wzc��'h2�Nɐ���g���.��n�+�
��s�d)�����"@4t�&���FS�fi�<>�[ߡ6Y�{C�7�iw����.�AC�;�HR��=�Z���=��Hv)�?����f�&���7�� ��\yr��v?�о^�s߿���#/�<��2� �:�H�R�ٱ�ߺЫ�in�Ч-M�_%Ф-	;9uLjt���ˀ"1�R�K��ٌ�4�Wo�<jE�����]lD蠙�O�;����PÊ�����c�Yٌ ���ɬ���I�/��a	����&ȩu�Y@�-#�\�4���u��y����C��T
��.��P�'2��.��"̾e���p�I�H���r����s����^Qp���W ]�ݙ?�
�
��,;WW�(8�ҟ�
άʸ>B������ʊR��9bٜyA�UŎ�>-3�� 'U=`�Ý8��c�T���9�+Z�Ri�$��*8���c�~�
N�
����M�|z*8�)ҾfEdT���_�ST�q���鏆���Z��Ѹ<�6���\ ��.	����E�����U6��k�W�1��_��3��(��(��f-g��Wp R^��l GT~��G*8�Lm;=���s��tm+O,�.��Y�>6�#j?"�9�J*���="�ApR&�r=&����Ǐ�`h����$�)�^�v�=�Z'�T���3��$-� 5�����轎gK:E�	�U��uY ��.�ݭ@/+�6x��&�e��J/�5�3:n�����{���J�K�
�� �{fdCS �
:�/�C#H�sb���b�2���)VK�ˋ$gP9*��-Pa�,D,�_�����%�fP ��&9�*/���y�����yFzBEwnY=���
����k��)$Ӱ�K��i�1��+���iTU�~�������؈�a��b#Ph�	���L��{����Z��p���rP��R3z(G�Q�؅�q��lwNt�e���ɶ,�hޅ��S�����qM�2*��! �\��o��fό�)���F�O����Ɵ+Z��£@�x��XL��#
G��fw�W�9
�7�zcY��F�4B��ΰ:���^�5jA��M��8
Jg�F\0iG��k>N�L��-�����fY�7�M����z�0}��&���j��1�zf� f�}�pu<�Y�����r(e��B7�f��T8���O��"H]A*D��]L	3f�s��/���v�G�E�T�qPP_/�PAGQ�R�e�G~�B%�@+T�����6����@����
����#��%��*D-��+u��
���%u<���^T&��	݌++�J�PA+|B_7�'YW]%�BH�l�(�F%P]r�	T()���r*T}�*���S��bi^5��P!ʾr��g�Ӭ>�wu�p�Eb��*�p���Ce
�A452��Q5��YDW��O��#�{�L淈��y��S���o���j���X��e"�L\o܈��p�\��Ä:�O��S���������{*�9��.%atͻKB�%uc�Z&\_h�?*���*L�����v�r/I&���[�
�@6( Iʟ�3*[ԣe��O������T�G՜�Y�Ϩ����
����.e�Q�k]�;b�T�F���B8Ң�Щ-����.�V�M����	�U��O���\Q���Cl+b�d�t��r#��TйK;[�ÕK���g�]��\ !d�Ws��/�����_�9�f6w�E���b����nQ�d��"�2Q���7I��c���#�:\fFW��E�tQm�M��+��>=�n����W�P/�y4�\�x!�ͫt����u|F��2��|d�QC�p�BF���5�T�rg,�H�ʎ�bG*���o�-U�q���ؑ
���{`ŶTI�
�䤆���j�������ء`�u�thcs:�r��e�8<v4�_���;�A��^���ӧ����7���#������o�Ѵ��G8��I�c3,��ÓoQ��Ǿ�\f���Q�IB�>�Y�N>���>U���%���}g-NE�!��ߌ`�)h��
�]T�]$�v�e3�NUp+�J�iV�1�S�?�p&���4�DG����"����i`T��S.�zI��Gy,d&��x��w˧��5���
D�;+��F����j>LG(��`$�ܨ'�h#~�W��ae{�=�9�_�6�!�=�^(`g����O�he���4ĵ��Ӗ���v@ae�
y��n B!'�o�N�
�s	�=A�H�g쁄�����~'�!-��7�[��N躧}YW�y�[�?ow��%`'�_I��,�����\�����y�@Х$� -W�r��Md7N�@��
�ny�n1}/}�2�^����3'h���V޶"F6���x�c�A����Ώ�РE
u��s�)R�Kv��A�l�oL|Zd�ն�� ��)<�`zM՛ct�E�/`����⫣'����Axk�J�9�[C, ��#�Gf8M'�pu<��u���#�t�9���"!�A��Geڜ�Q�y�Ej9i������rOR�� �-��r����3�]i����~���<�N���g�$.�w�?��bFP��?�5]������:W[������S�T�>1h�^g��S;�Wz�_�m�{�	P�������$4�<iQ��YPϥ��MJ�zP�y
���{���_5�W9�n�l*���R�T�^\�k���a(Tb�6h~�;����ɯA�L���G@�ݵ�A�kz��B	�M�mW�ݙ]xF-q�A���vO0d�1�H 2�%�QoH��N��Z��Ȍ����>�r�`&	�u�y^}���hZ3��՞��7�h�j9qS�t�\����=��>��묬F�Ԝ�GuC5"���%��1!��6L�˄�4�0M�`���oyv���>��n-%��Ot{4F�y��}E�A[l&���e��*&�}m�����iQ����F�Ըji��������b/�?4��4����i=��K��6����a���鈊F��EZ��'s+��~ؐ3M��xy��}[���cJUP�v(�M(n�<�������oץ�����K� ��<����T��ݣ3d���۩���OV�	�>��t��y|��佧+U@E\�z����[�o'���C�n~�;Ee�(��3��0���f�3Ms����Ha�M�C�p�7n���e=�U�Ft1��U( ���5�������yכۥ=�B~�͝��'	?�.�:��2(����+Q�>Џ٣\=z񃷂(7��d����?	UN7�
@���i-��)_�S.r��F����G�G�v�����r��d-�P��0�k��Z��n� �i����q�S����|K�KS��Hv�m���3�X��ݣ޶�+҂Jy�-,�*��
�ԓ�1���@��" db⟖�����
*�𩥠6�T/]�
�ZaQ �.C��=�B�2�ޟ\����N/Y�XV4�D�MQQ{�{��l~��H���c����z�R��K��
@�q��� ѳ(�"0�}f��̔�2 UKI�i( �|* ITĽAJ��PV���$:�w�C�8H��Tu��}d#����Jr�й���.X�L&�f�@��t�覾ӌ�V�|��P t&�ǭ���i�h�/	���h)� �čS0�ŷ��i�`s	y��    7�
�Q����[��P $��}9`�&�C�Lc�R��Z���P(Z��v��ݏ��u�p�M�8���*�@��&`g����*4ڀ���	T/���� �z� 1�?���?�7JEPt�0��p�u S*��O�[�K�XSݸ�����58����x���`;z"��N�u�VRC�������%.޹�2C�}�]�7�Zɞ��- rD+xp��M:Hݿ���� : e�F�5�9 U���lb�o�E�n�������
t@���_�\�������<�Ɖ��$�#9�7�g@i�J��!��B�5a�\�`6 2I��QI�H��͋�+�ﾐW��]�f�����6��C��#��G�X��~�ԂK��7G�4	q@i�z�>��Gq�5W��W'�	ф�|)�}����\@N��C?�;� �����4 �YJ�|^ʎ�ҩ���U�uS]l��l��Sy�HDO�+�d+�\���ѫT��ur溯d�#�2�9\":��Õ���$k����E�5���
^�c0k鵕$[>$�VF��$@yH�mo�n��1�'�k1LG�K�L�Զd�sB?�"�T���Y��V�62 _�ⶉc�I�C����#[�:��2�$�+��:R������+�^�/X�Ham�eN��@I�?�"����
6�z���V%���Ȇ�|aF{ruٳI4Hl�,�/i�U!�v�t�*�A�Rj��R�Y�2�3����H�h��_��%M�����E!�e�|>ɀ�h]��! �v�^���V�!�J�At�W������#wX����[!ٴ��V�c�J��I��L��@i@��Dw	H�wN
Hԭ�W�b��QH�mo&��a��D���"����b6AE�Օ���\�ʽ�6 !��"��&�����# �r4NL@&�^%;7�n�����Ǎv����<#
G�K����<�{.+��w�m匚��k���A�:�.��k������3����7��4 ������9�Wp�.R�uSQ�`GM�b�7�'.�����"+�LC�jo��}�-�ؓ8�����_5ꛮT%~�Ϯ����K��V�`Z�{�q���	�ԃi�zvI��(�^U(_�!Ň)>@��~��_ڂ/�z�l]Y9@������	S.��g��\��f�b���%y}�f���{Q��b�	�;��io�Q9��<���4&��;��pZQ'����wr��n�MP'�l��K�g�����M��_e��ɭ�	:�p�:�L��D��i�7�ޢ5AB�T*z�=�>����_"g�^�MЌ�~�!��SLЍ&��ҀA�-�������dr�|4�D�Q*�r[a�l$ܙ�''�9d�h4�#�~�r8�����D k��B�	,�g&h%��(b�|�2Yh
@dg?A�,��{BN�Pa|�?a�/�'���� L���_��	5h	�\�P��G"W,����%�;�	;�ɂ�P�	�����	��G�9� n�L Y�k�򞒳:�J1Q`�������9�H�Ce'�k�Ʉ���+�
&�=��m�p޿�D�4a�7Y�5M��sC�ς�SVƲ݄1�',��O����zF��q�5/���o#�xxNF�(/g��7��hF=C��p����|�v�[Ģ�/�=~c�)kf����X,��b�X����:^F,��i�r�x�B
������s�͈�1jx6ut!�]�)����?�f&T��'|	�X�������N��5�"V������������{�OC�=5�E��s�ΎXE�k_�X���
��E�����E�[�c���U<t:e~�в�#�����޿��2�-B�>z?q��Э�(ۤ��j-��Dh��Tp�MB;pW�c�S�C-�W∕8�%P?��b��#��.T8f^��p<�����T8���-e���Go�D�!a%I++I�J��)�.������^=�?\o������s���gK�Xd�2(�9M����L�0�'l�hI����ɕ����4��!�|XI#�F^!]�>；\�����Ԇ|����䕱�;��R��_�����J�L���%�����<�<�yȕ�*�D���@ �1K�ڐ�<��r�K�M�kF��i�����������[��7�^|��L�a�}Vs����toϧݩL�A�iP �.��>�����Q��#��q�?O�:6� �݄��ֿn��M�_�ul1( Z������_�uq����i����K����u	_����t�y�����޽�+н�0�N��\5( z���5u}'��I�q���?�2,�ۈ�~ӻ&��L�لQ�5L���[�FN�$��ip|�.]'�v�O*aB%L��-@{
oW%@D-��>a�$�������1x|��%�QA�p�v;�yD���~�|k�6�?_/�O{��%�22����������
�Q&�
 Y�9?ٚ��x�3I�e\����N�^��.��|���((=��
�䠀����+�tOF��E;02��ή��| �u��ݜ|��a*���2
��ܗ׏'�v���	��|�}�ShE�`6uV�������\5���H�z0���w 0 ��	��f�`�c�~���@U-rmv�{����z� IKCU"c'��J����@���{�lg�����ڠ Ȃ�9{�&prn�s�{[P��+�M/vn}��Ŏ�{�z�`I��z0
C��6( ��60�L`z�_l��-� HSk�O��=�NC,��/�-C/� �[C��Վ4)L�=��݌N�Q�U	A`z��Z@�~����b�����x���2�ٝ.�ɻ�ϢG;R� 0a	`�,Pw�������'��c`<�T`�� �@�z�FF�1b�gG�2*���{�y�g�%`�hL�uyr>��"�/����c��(�+{~DdP ���	o]��G�B���?b���]k�f�� �#���@�^!�K�(�c�H(�[�����/q��X�vB(n����P7��c�u���4�rAݠ ۝s7����uØ�.+��kY���NB��J�A�n�8�C'���|�;oYO�Љ�S2(r��ȟ">�w䄎�N{lYM�����(ADp$�>`/�/X�$T·�ޚ�[U"�y���o:k�E>��Y5����m-��w�l?I�O�@H��p�ly��g�v�+��xZ9����/8�t�����~���<�/�ڬ�r��5(�mE�nP����ΙY�>m��̓��A��Ӟv�����N7jP�ۊ�ݠ`�i�H|��sh��m���,��#�7������oz����M`e8���lлۊ�ݠw�.O�9>�Z�A��qҠa��A�6��F����	/�W��[o�m��;�G7n��Џ��n~9ld����@���NG�gȟ��$� ӣv���o>���+��d� =2����9��/Yrݥ�����"�R�~L�ܥ&�@����� ���Q�%'<�O	��	�䥸�;3t��nl�����hP�ۊ�ݠb���Oμ�v��A�6�b���ШJ|��
�&|?�&�Swq�-�����k���8C#Pm�J�k¤�߮֍'V5��mE�n��4�q�זd�"7���;��{/�A�lܠܞ��TP�|�n4�i��H�ҮA6ɐ�>Ү�&��1ov�meG۰�5�l{M�5�h@_�32���M���,`d�?s���(��me�ܰO6H�ؕ��������kE��(J�ś{��ԠH�1w_f`9?�kS�>й9�͊�
v�]K1b�����A��x���ƕfv�h�m"�:����u-N��'O��o\>|����ϕO-�X��	u���9�T��R���PW���:�6d�Pml�ke�0�O�����e���O5�
�����@���ťk�F؀^l7B��5�;�ܺ�(aj�bJ��bЅ:X\��t�ܘ���Jb��tUK�UrѸ�/���k= yx��.\F�4����{v`R3��H�\�z�Le�g���m4�^ڽ�=>�    <;�:8y����kE�Z�#��6?�e4a�ҟ?V��]��٠.�u�A]2��2$�(⻺�������σ���]4��ܖ0��S�ϻAP2裹��O.=�ATzI�w��	sZ�q*׵N>8N����A�Zxs��^]����˘A�@� P�6hS!�������{*gL�;~W̘4�N/~�I\k��b7>�0Æ4����dO�+c$啑�1���{w��E��q-���z��� ���R�����{5c%�++i�J�O�i�X��	��̐�R�t~Sex��r�_7��۴�mZ����*�أ	�;b)e�������l�=��n�\0�Ç�c�(E�X��`��l��Xh(I���A�w]yT�L �kDd��n.!�^s	1�{3�[���3�{���(u�0( ��J����e;�-9`6p6u��9`.U�]���Se����jj���
eeU(Xʐμ��N�iϬ�,�ĝ���� ����,���x�����p�7'�sg�RV֐�5����uq0t:F��T���������K�ns�{ChF<�/;ˎ@�
W��['�-@��c��p��g�vG��G���+�������,�z?��n���;�
4Z����~c��k�C��5��]r;7���Ʈ���
E�^w�&����7�ĺ�P ������+ֽ��ڒ:W�:�^=��͵g�u>�/}O.�|���2�,�T�}�NV����1=�M��@F;{�C���8��:7��9T;A^m��լߩʉ�֑<��#1U-F�v�Q��C�\�=9�������t����Kg#��~����	�z���;�AڔOJ�Prb�u( ��}۬�m����_��|�#x/"��I�4��\5�:dc�IV��	`�D�� u��\�]p����?�ڡa�$�v��	�:YI�RF���G˗E�}�b�Y�Zr��;�{��iB��qӡ ���H�#c�Hĝ*�� ���w���	�g'�ig2K��8^v� �i���kK\�Q7|Ş�b[��n"�&�aqPؓ���`��Nk�Ggkޡ<>J�bs�ԛ7F,��!K|�;[��=ݬC3�K';Fg�A)��#�A�-��s>�F�pë�A@;=���PQ��/?»����J8�}��ƄN�-�	U����	�ӱ	��ݹ�=8qm:I�QBgӓq�ji1���*ϯYU&��7-�	f�ԃi��{��d�1���{���	T�2�g��P�39��;�iB*g�عt�ޥ�K� �3*>c�:6((2��: ��'����w�Lt6�ň���4�pl�A/�{
T��'t( "�3sK��㧇��a'�x������'��	5���Y�������v��̍���zT��Z�D�_����������[���?w�9vv�w,�)D֢͠��~{���熏��C�_B[Fѓ����	��Bzr�W�?.��2���Hӫrl�̾5}�b4^?�]��{4L`��z�p� ����:����V@�
��PO���F�h�KlTKm����-lt���[B�ns?-�2]H��`���K�$����Ow�=i�jX,�$^�	�b��l��wC�t~:�%z���[e�;���wI��y=W�N�o�N A�^�ut���"��Y�������0Z�[�!� XĮ���u( �H��vD�ؖ�L��ؙ�~K�t�@��FlF�]��;Y@�>`A;t���ӿM�<>:��C�:��	�m�Xf�ē diW��|7b_7�N�����G�yށs��vj>zZ��\6���f9b�M���Qձ���R�~9b?v�o[f{��O��w}��9G=�X�n�GR���@���N�-���u��P d�浃s�#��׌"vz~�bwy���S�"�zq�2m[�q�����q�F�E������o�.�:�u( ���n�ێO�O�K3*u����������oWFl���Ҟ����QF�v]_��xFmf�j�Y�ø�1��
�ZPw���N���Ep��wM�l�����?8�!:��~�#b/n@�;x�T��<?�rnܣ�Fp�It����K�u���h!�W�"�	G�B������={
:'T4h�3.k�/CD�*��s����A";�>������eg��~�<���Ou�z�nY�f��<Gl�#6�r7�L�3�Jr��`F3�=˴o�h�S�.m�̓]����ٿ��.�3�fF0Df��h}�g��B��P�\��&y��|r��D��"�@���\,Z�r�_D QO�Ȧ!b�u��㵋t�
�/:�W����n�
R��?�k�a04n��X0�FF��gK/W�'Ц�?�}{�a���	���
!j��O3м,�����_�	�Dz�C˪ݹip�ȀJ�*�!N%	���
h)�k������w'	�E���b����'}�ļ�;��PhH8=�R�S$lU����wK����+�'ѡ8���ޑ:�И�'���y*aךt���;$�X��ڏ�	__��f"a�jQ:V��t:�E'�_/��� �Na��M��co�[7μ}��������)J���h�qn#��@�9��~9�cg��~TU�(ɧ.�ы�ߡ$_�UŪ�'�8o�%����i�V�#�v	��N�R���_��`�F�W!�p	\ͨ�׻.�P��C5�<L�j( Z��fW�;�j���%�?mX����F���X��I�̀q:��͉g��dk�".�ʲ}R�	�i&r��kUP��\������ˍ��Nz�s#��4�w�����.�3�M�!_`q�i-���ʦl����q�E��O��0��׽��޺�{��)�a�f��i���$�HE	�cU�^軳�ƨ���k��Zhw�E��-���9I�W~s*��'�F�Ib?qr{��KO��I��7_,����PxAd<`Zq�O��'n�8���%��iF����gE�1̇��t�0cH����_��v	D'��
�X&��M�a�Q��P%t��!B����C薇�)�=�_}����N�\%$�_n�+�Lf�3U���k6�3�Zf&��T\��]�z�i*s�F±2c��j &'�Ô��S�@��E��>�,��ukXf��/v�Η7�%�)�9,��-���ى%�SA����P���/�[�ENL���ǽAY�S�\���
^��y��"��N/��ҝ�����骈Բ��#�[���	�VGL^n���Y
���>;��
�4ǯk\ؾ6��Fט�x���N&`�0^F35��N #��|��q���(����h1���$P:j���pj��_'ȑ�C#̡��};y�Ձ���c�#,���?�n��Vv��{7�$�*051��F�#c4��D�}��?�ز���(��D�[6l��e���+F�/}Iα�(Zc2���[=XK\�� Z�V�.?`��Q�1�V�Q���_�_]��Kf|�u�Z'y�	�Z��p6��k�Ga�<��QX;Cx��`�j�$:[��SC֞v��S����̃̝�}���k���&Ї{�Q��a���qRP�(�vu��m��NAX=%�K�7�n���#�MX�Ӎ�bӏgfkįE����#�*J��ar�®s""�-Z�[��Pe�=
����W�`^�"N_m]H�gh�Q����Z��qčA�/��twu���"�k����U[^��+,ЬA� TL ak1�z-��e�/\N])*K������X*��Q���Aؠ�^?�}����cj��������{�-~�J�iՁ�N�4j��<�����Tș1����/( Blk������6���JG	�̓�⽡{�3��0���ٞz���xQ$��&ѡ�)
�����`;��75Xз8S`E�;7Ք���`jg�2
 �>e�$��3)���9��C��)���R@�ܑ���Pn]��Ft�vs|zq�6���g���#�K���_er����~?����|_G�I=�v!���w    �lǆ�0 ����s}�'�� c����@~6�|��<�g�U=l���`Zת,��e*�i�E<uk����o� �w	L��a�0���X�g����s��t'w��_�a�V܈b�tMV���j�vCe��7�>�߸V��An��@S����(2"�o����*?��{����_�`�Wi���^{/J"!"�&�+P 4���������ag���t�7%	Dn�$�mKb�B�4#�,ᗾ3!HAu�xL�JvES=p���(! (i��=��6=��.h�=_�1�aL��vB�Q�D�����I�U����ڞ��	ۃ����.	�E
���Ww�'�%M/��oh~�@l�M��Qhw���8�n�x��}����j�_�M�|�VY��d6�gQD����-@��/��+t ?[ ��p���P�� �Ô@��b�Q��-4��vL�O��X*�}~��+'�<����T:�O����.�Wh��@^2��t`Dr��m%������w7\(!@%Y�G��RBHJ�5���K7���La'��B�����c����B�=�	�d�F����aN�s#_��۹eONp/�⮞{�����h���=�%lIp*'s��]�	���/ݖ2v�l�}'��9����f�C�<���'������=����N#� wT&8*j��L�T&x�h��
#��ؙ��qӪY3�M��ڰ)'�(SII�*�	.J�4���A1��\�	~I���/�cD�2�f_�D.|I��-P t�����_&'�U�\���Y˦��N�@��2�.q$x-�^4ѻ��G�p�#�z�,�d� �����*��'�v�˾x��Z>A�7�'$rJ���n���,��[� ���$�b��_����}��W/�!���=������6�%	�Ym�@�%�f�=���{7�L�{���F$�h�WPu�3����e8o����!l��o*�V���-h��m�#3��L�5( jlG�#��%L��L�����qR��/��&�Q�ھ�qy�O��m�b�i(g���$�&k��B}��FgS��j]����8�{�����7D8�S�A��9�C�pC�n����+N�»tc���	[:e:T��/�;K]@�q��������q�\��X��z�%v�=>�q������3�����:`�񉃼������b�D�5'�-��NI��`+N���L�������������i�]r����$8S����|L�tz�]��d.5r�(��(����7���(P����5X�)L_�aӪ� d	����lKg[��-�1Ŏ��%��Q�@q^�6�P��,n8��&$*Op�%xEHΒ[�hU(����Vv�罿�%���1�g��d��	SŢ�'�C����&�<;���I��ty<��jD� �A�����<�Z.�W��Gد�[+�J�����I�a�.-�,B��������TGџw������7)Ev��c��]
UD��q��G�8kib���#��oA'���@�"��Ĩ�o���G/����i�aM���\�q�g6��O����G���h�N`W�qR�Q-�����6E�:�Ԅ�sI���*�Cu��J� ^r��H�u��t���^͙������/5B�x��/))8 �Ir����A]���q�[�NK� Y<ix� נ5�n��`�ok�����xς18��%�ڬϳ�I@��k	��߶��sEy��KK��i�������l�fo��?� ?р{�,�� '�����5�C4�K�Di�!���p��^����Ω^0�K#�<�\�� �Li���f��㋻�p��!�L�l�a���4�Y x`��ܳC�p^�-m���翆��r�@��u�UK������Z�/�6>�^�7����ƀ����~'�Ki>�7Tװ��s�=�Ao~>�w���� �akd�d�!��xņƭ�>1�$/��#ɔ=�16��y�Wl���;z^�ԫdfk�``��l0��N�==��+��/���g��$����ߗ����6��e�5����{P��_�$��=Hj���~�&Di��2v�\3���D�Ha���p�[�C2������Hڒ5�c���?�2�����2��|n���חF�mƶ���o3�>�懦����Q&�+#�CP�$=#�C�f��X![9��y�>7���ޒ��ϙ �ǿ`���R��d�.q�{$o!�(�>�u�]^3�����3���s�k�Vnh[n	#A62���u޴=�B�Ξ������y/��,KK�>�k������i�]RR���2����!\SMƮ��i&��5cs��Ȍ�u�2I1���n��[�<��q��ƙ�q�@���Ϳ���fa����3����|��k�I��gl�y	�hn=�| Ե���.���<na�[Ӧ�WB6���QQ�J@��1���$LF���n�gDy�U�=���#��,����eBm����<eD}��z���w�gDl�F�FFĆ@U� ����̒�y}��ݡ̈�ȵPFc�O��9����Y�'����M3�6d��2B6��s�\���r熗;��-�t6Ia����Y�2��-$������&�'������6ҝpw�����F��Ɔ�m��m��d9>F�?���#Lm��������5#,m�Z�$%wΌ0���\;q$G�G��5����>GI
��#�8�����ڿ�s��R�È3ɨ���Lq4G�G��ԯ����{ߑ0�`0V^��x�vĩ`T�X뽸�݈��� oM@��aq6X^�/d#��o%�Iy<֖[�����b���~뾿�o���g�� 1��4��_�N��:��ߨǶY�GWYQ�ol\(-�o�q��Q+�H��!�s%��,4�,4�e��gW4�,4���+lq���(�7�(4.)�|�%��Լ�0��~�� ���y�p�Fj��s����4i���V�� ]oP �|F�_�����Ng��y�8R�CQp�
c#�RlD�&lr�����l���B_��ɠ ���8C�A�����z�ࣸp;�a�|���Q	T�]�����c�A�>׋<7f�Oǖ�1��@���Ѡ !,r��r�ޮ��w��������б���?������� ���A �]�l#>AJO�1�"���O�7b5R7�3[�_N���\t�
���Ũ.ϪhhԪx~<�z1��7�l���.-�f�2( *����O;kt��d���7��o����r�xۡ�	�_��ٻ7��CmT2U�C��fī� �K�ك��@}��}pνF����������ON���"�@$����Th\w�Q��9���cmt��������8B����C4�jV��Y���A��;�������n�|����
d�?9����{w��ǖ���^6�"0�aT�<��s�;���Vm�3�o���vz��]rW�O�х|���Z�p�oh�d��þ�
οx��O�������Gw�����rp��R/�(7���=z��X5���ƗZD����i�:��w��FM���@?̧�F����/��ѿ������ࡾ�܇���(�3�?v���I�ψ._7�������B}�V�khB�w�j���-qƥJH@��_	b��_�U��2����`��!�Z� ���j������v�,eW	8�Oq��P�#iq��hK#��~pM��V�U�z���IGB\I려m����d��L�RA]U)����=x3-�wX���e~X���u����f���"�;R����dC|� �eȨi՛��p����|�z��I��*��1݉� ��PL�p]kF�哏ޝW�����k�FWɘ	�χ!T�,.�ƺ2�*�F���UJ�w�Y�"��НoƯ8^=?��a#��y��9�-�R�':/�*�����.�s���
��;U�<�,�ɨ�.���)��K�,2m3fw�T��,M����
{�����*u=�Ǝ�a1�����}    �|�@x4�#z]/��cFF7���=�F��q�n;����t���oW�Ogj0 `������>7'�d5m汳M�u/��_ù���E`���[l���c����t��a�x��i���2�9��lȾ,&��	j��ȯ��1a����5�4�eX��."�
ф�3��AJƕ>�
�L]��)Kz`I<iT�P��2���}c)f���S�/��`_��[�\���<XȖ<����ޠ�$���5T�\~�	DȰ��G�7CX�h�A�t�_��EOc;]��m��ՙ�������F�1���nv@����jf��J�:��Y��YlZ4�A�Va`�R��=+��eY����ٍ���BG�8��o��+��-?%_��㏦�a�
]<��`�Z��6P:̷NR3���UB:۩)��F�� �	�� }}}����i�oX��i�e�
0�5`� �t>liH+�[8l�s
 ���oP �VB�,��"	�0����_2,�<�Ont�ջ {��{��z�s�eP�#_�IM�~|=��E�7�O'a���Pe�v�X��7Ĕ)Kn�_�L���P%���o�i/�Q��ܺRƥ�k6��!�*�R�c>�κ��@b�'PnP�<̙4ςAP�P`�\����R�kg�3U�eR�]���g2�a��6����>� ��eG����M�p'M��Se%����,;�a�˯w����z	������;���<��I֍�P�fK�p���@3Wѝ8�aՅĻ���7ܱ=ܱ݃(==|���}�Onn1#{���3H׬���Ͼxy�M@�����i��=+`�K7 ��� &i��w�P��	 ��H� ��Ze��Aj�ܕ�	���Q�%p��w�Iԟw��N�gϝ��z���pE��;jx:��]=|��9�����L�Hy�zPz]J+Ųw���Ka`�J��	����Ow��pk�pk���s�|���ڨqE�7`��V�Uj}���%���>T�X����* ����nؾ������ٮ�<��}gl��H[��~��!���#7��p��7%!L��;���������%;����?����\����q����zxD�:���K)��Ik�k���	�����z8A+�ǝS����������O7���%<3vˍ��el���@%�å��Fl�Q��<�2�΍�e�[�}�[e�fM�s[��yx��[�"6J��fq�El���yG�|��["�b��N ���{�ҙ���GW��ءcc��ءcI�q��*P�sčxwؚ͈��*ˠ&N&t\Ѳ��rt5��-:֫�:�>�Y�#6�h[�N�{��Us���&����!��G���.j<�.�!���.{�}��ѩ6b��&�%�5� I�F�>uk�d[7� bˋ�-/bˋ��߻eTW)6N"�%ڄgGψN��AU����|���0�5n� ��y��q�#��ɖ�H�a"�����gBM���s/��C��.Is/�����H,I�>�u��C���ت���uoE���D�qUn�X"t�X���]D��0�pL��z2a i�dV%��TȘaad�j��}�c�"b��&���`t��.�о��=�@D PԠɡ��o20-��/w-�yDL����O�R0η���A�o�8"N�ޞ��"���	��6���c�	��KX�9,5��n���'�'���@��Y�d�1�hA��5;s5��ˆm� ����1�&�\&��#1&��Pæ�)ߍ�Q(Q(�ν�����xc�u� ��N���ۇG�^WD�I����kG��|�$��'�!�%����<�6�s�?�^�);B�:�$cn�`x�GD��@v������	��~���"B<b)+�e�5,+�a�n�EDx�sw?�z<A6��!@Ԏ	���v!���2A<�fI�hç���ێ�V�"�9chӡJ�<$7��O��&"�$6bM"bMR��?�#�$Zl�Pl�1$�=��xa%XȪH��&�v�֋���QG	���/Ј<�(�A�UF��D�d!��A����H��^Tn��*BB?#b?v�00��">�%ٲ�xm��0�w�"3�1�U&��)vh���/��"�8���|QXd����ܴ��@��/",%6�R"�RB5�+�t�5���>�奼6$��DS�����:�(I��QI����)�L)]�!hGv�1"0%Z����w7"@��/�-��#��jP Ծ$�`~Ԓ��:�`vLfS�1��¨,����僷(&����7���ɮ�z���ʕZe{�?�F�`rԏ�������	&�T-��M�8Z�Z=t^�Qx	�'���'w���o��S�u�	ߟv�F%�@y�U� ɿ��m	�Ϥ����˼�\���	F��2������(d�J��|�I��3�-�gD�����H�h�"7�aS}Q�P�4�sA�!ԅ*��y�"A�I��
G��I��@��
����k�h�S�4X�Æ��ڹ���Ff̒�`5�uu
��D`u+h�W�6�i+��a1s4V�����+���n���wǳ�P�1���)%�s�,}ӏÃ��ߒ�����"�g��U�|���ma{��C`�j�t��D���$R�W�>�K��I6�����U�V[��]�%c�<^}Gq�mlI'� ��j��r�����q�u1b���p�/;��`dό�����JE��r����V�	�W*6( �ԏz-����Ao~��	}�������r���r��-Ҩ�R���+����](��E��;Q�ڈ�nZ=��b$�^��mu�ʍ�	�w��S�o�M0�Elx	���6������iea��ٿ�V��{��Q,�¸����`���@�?�:��f1( Z�-a�	`�*g_���F��,�_"?\��3���:� P��\yI �(��,/�bP T��nm`�;��(�Z�����*�+� ��h��~t�� �V�w��ŏC��jQ�I��v0��M�Y�Г\��L��~"�� uJ�Z�phT����أ�l3��*!��{_,=���7��K�)Bl�0)���pt�AhLO\2@eҎ��Q����W(�1�� �`!��d�v0X��=Y������<���2O/�o���k$�!��J!�(��w:�"�Q+/�j�p!���6�k�iN,��%�-�C�a�EJ1y�6�*Hi�%�������ǩ����oh�`PBd��3s9�>>껆�:ȰN�B�:�0xy� �f�1=�-���ƕ�~��:Ú��L�����^���:��%�[�t�������{
� ��o� C�>��5yjd�8�)��yv���Rʕo����S2$7C?�(ȐX��3�v�Z��Gl�G|(�\fD�q/� /�@ZJRN]�x�{�`�`��^�ƞ8��F��e�n<ڃ%~�:Ènk�q��jk�b"����wII':;G�^�+(��p�<�!a�%��?�'Ȝ;�8��m0~�2�[�����KϘ|�����[����.횧8�OpϦ<�{>X�����:a �F�|�� ����}~4�0��#���a����C��=��= ł���J��[�i{p�]nM�� ���f1�W����E����2|���k������W�}�������B�FIy`�^T�[��~Ӧ��o�it~��Yx���?��e�z������y����ޫ7}r�H�xW�y�{��[�Ody��[��Q�^��^������%PH������]?9�:��`���k}����8+On<� w��ՄC.�HM04RHM �2�� ǹ}�����l�%Yd+��IR�R�
R�N�9 q��j�׼��+�o����@[��{�N���r�c8_=�j3DW�*3]k���A�Ȯ�p�7
2��a@�0 f�<?i־�� Ìx��0f��z��G�E1k�����<��vŬ���-,æ�5����Ov�YP�5�����+Wl�fhO��P�Uy��0j�@�    �����fX3���]�$_�A,2]1vK� �g���a��f{�vOY�̬�;�H3Ö)�2���u��<���q������Ө�W�}�7�uB�!_�3��y}������ۼ��s�ѻ�og�0�*~˺����"���2L�V�Ӳ)����C�-Kr�Q5�eczW=ðjuM�ݕ=��kZ�����J�e�0���@jO�����0�f�-����3�-��eV�%�Z�-��#f5$���f�l�9���m�k�d�̰��ra��ϰ�f�"���$}|8_}=�w�f��r1
�E}�3.qe5q�z�&�q}�7��Y���Ɠ���z��"c�+'�rO����X�)��1T��ڲV��r���6�_?�oK�a��aqH*ڑ��Fv �հ3����942��S�"���y�m!����=ݏ��0��V%�	�������H�at�w-&^m�ܐ�H���V�)T����LߛN��k�'8�)������ō��(���ih\�$OV���O#Us0��#��!�gI5����ـ��~��w�������!�0	����q8�	��$�Xg2< h�`�����/��zU
��X*��ae+���)Cdy>Gh��w���m~�.���eK������x���F���/$l�P[�oF�Zͅ!N�R�� ���Th.��J}>���sX|{֢�o���3{�Н��>�*(9k>Hܹ_eL�*�u-2VB:}m�F#���o��
�u�̡��FH
�FZ�%=w�Q���UY��W������ۭz�|K�/�,.�Y2�yǋ~ 5#z3|wB6of8����2m��.�����2�vZ��Us�1�G�����ε���O�C#Í��]��z3y�Z��i����-����4�]����{s~԰�M���I��w�U��j����?�� ��@M�Ը���l�7ܝ}ao7�O�I�2{f��%,�~�
J�[�Ch
�I��t�W�����%��{�+^���
fx����lV�)��鴃W0Ç�����D���b��f�q�b�Ir����fA,�!p>y�?)�l�;�LS��[���^>�!�HƮ"�<��ݑ��Րj������h���hn8D3��Y_�ָ�<&���P����Y��
���K>[b��THKy|C�h (1�/���Ӟ�jgx@����V�Gl�aI\�j8?s��̠����G�nƆ�f��F��L�$a���U#�7Ώ�^5�3�W�,���������͈�p�Xq�GH���bz�#�6�~���t��ҍ�����������]�%1@#.�n���_ qE���2�=�:��ۡ��vG���6��Yc�~�~�Q/���0Q;@���}��j�`~2�G8�Fug�$��*���f��7�}ɳ��`��j��T�4�C%��㫛
`��:f>z\����#<S��#��HFm�D$��o�����k��k�s$Q���h^+��zH��e�F8�F�U}��-�JT$z��

#�Y���v�s��.-�?Λ�����-k�����>�ͣiA��-�C_=q�R�t��G\�,ȟO^�D�N���67a����x�&넭mBF��mV�k��M��*�J���v�i�{��=a��2/�@&�u��N���	�v����/W���ϩ�^�!��M��02���M��j'��D�����{�㶫T�l���G��z
q�Ǆ�C�M~���b�A?����R��9ɣC���w�.���7}�w�@z�3�w�>9J�Y�z��\L�b�r1it��&��T��"Qȵ�	��t�n��	*Fe?JAG����E$Vp��1�$&ìô�@����OZ'��	�G鱛��)��yL��91NP>6�����f/'T��|�v��'�XFɳ��dB"�*&Z�sB2A��G��\A�� 	t���^���#M�I�8���\���uI�n|��\}o��$��4Ae�Utx��4�J���c��u����PMP���u�3�rYMP�&F�9���y�.5�p"u�z��J�/w��"���5Xw�(���8B:i�]�z8�%/>�� o�fͿ���59�o�ӗ�AT3֝����'tX�KM��^��rT[��$�"K�o��~l�����6Cc�'U�Mw���ۯ��������aKZ��fS�W�2��◍��|���Hv�5�G�M�Л,��!`Bl�P\]�X|#2]��j'�M��4�<!(O�wv���\h�8޻ƀ	!y�6"���O�˫v��N̛p�܇���%E��i`B,��n�����ML
_�?�f�PO�ED���'�E6z>�Rhl��0�� _�c�o��n11�D��L��[���_�bWe$��IaT���8f��u����H9a���l �T�\���j�*]�?��KX)x��HC�J�r�MX,��o^�
��Z$�!l�$��x���	!���g��V�oW��S�G�2��n��"ayH�!$�N`�5V��H�u����*΄X��R��� )���	�s�:sЧ�ii��K����M��t�`|k�@��+�;�����T�0�⃽ޑ2��6mK�o��/��$O������.T�]��	 &��(�s�HL~��]���Z�'�M���	}��[��`B0ߴ�B#kgƸYGsݓM)c��`zvBP����k�a��H��	~�β�Œ�O�����&B��x�9��w?HE�	qYS#.kB\ִN�����5i�����I��(��	���J���F�l�X�?ɶ6BPku����U��G2�FHh�����0!k������h�^�9sGNc�7x��t�l~��ʩeEC�<��{͂Ǔ�z���C�
��Q�'=�b�ER�	�Wn;o�ۄ/������6���Mr�os�Ƣ	î`�ˮ�A˙tn֗Є�7�%{
UB_��ljN!l��Yf�н���hBX���6�����qa�|9�Z"��g�%��*���#�|�{`C,؛w%��`��$��&m%pܺ�0!LA��I��	�`�e�G���*$X>��-����u�gn�ELئ���1axY�2�Xܼ,]Lf2���"X�����65b�&ĢM�Cb������6m�a�a.��&͇!�L��&��M6�`��h��|�OL#BLZ�}]i����ҴA��"$MM㺿����(U�e"$��W�J�;�9�Qm(%Li[�d��2v-hF��4+K2�+��h����O����<OHK25ҒLHK"Х4!+ɴN�A�g�M2��~��6�(C��Z�$%�����U AI��}�6
h�.a@���;٨5��E�M�.Ti���qB�*�F�B�+2����'�
�3<��$�GҺ�r�
E�C^���k��$�#Ȳm<��tU�B��GK�^9@��D~â,Bםo�5�.��/�Z�X�`��a]�odB�+|���;�����A��xtj��DY��L�t;��!2����H��i�Tl��lg3SR�|!�0"H8u�<7OL��Ow��,�vBƝ����d�ܬa����B����~
@�Iaq�7�C� �]ɡ[����L���P�-��� wU��b��*h��k�F�`i�tj
pVU��/Qx�B�{k��G`f[���8�Gϋ�'�����p�y��[߱���GN���p5��:S�_5E�p�sҍ�8 �y%��+F+n�߰~Qq�z���ep����%\�m��?�_�uH�b���
/Ħu�X����M3��S1_Ha+=R<O�:��p@��B�M?�����,gJ���]s�'8��ҩ��'qE���� y���A�>��g���D�\ٯܒHb~A��c�B��7ύB w�Q���pS8��~8��	0l^��;ty	���(������m�b�BR5K� �d}R�$�M��{t�����_p��i"�F�Z�F]g:�ܪ������d�_����(JePT�=�쬉�>�xy�&p� '�ˋiYr���:�B�?�TJ��lG�0ZRl�w�\�����O�J�4ς߯�P_O��|c=���X~E��?�f9�&pv���1T    i\=�J3��� �	SF� ��D�w���T�dZ%<ia�{/B��_ԫ�$�`�zo�}�:a Z$ۅ���/>����_����N�u�O�����Η/{�D�x�5S*V���מٺ�Џ!CC/
z-��>�*���[J��Y���� td���l�/pxbcj�@Y����p|������㪷���fF���� ;��h�v`����S��&�/~5%#H�h�Lڼ�[nN�a�1G�)��Z{^���|�$/�������w ��>�\ӡB��ƒ��"&�M�Q)�o��&TT8����n��Uh��xF^���B�.~�@Q%'��6F��P ��AV��n�#��&��,#���V+FL���_ ��{F%3H��X��cO>���DN)#���L�ʪT�}�sfUd���%���8A�4C� h��O�dkc� ��������� 8ESE�	x��5�CJ���l���q�t��m&|�!��Sm�O'@X����E|<DB� A�W�!�p���Dɺ�e΋5��������%p�֐oFRtX�~�byy=3�Er8�@�a5����w������w���������L��R��!�Ġ�E+��e�$�
�g��/� ��*�K����fʤ�ǳ�@�)�{�
��x�)	�/ލ�zpZ���C���Ï�[��`I2�f�H�k�[-�g&D�����y�����AvgփSmmV"ܰ~�k8��!�2߲=ٿ���V ��X�/��ϟ��Y|̥{�H�<r�M�����ח����_��0F� �ܦ0�wC�lc#�΅�d�S&�A2I�	0�U�͵�� �.����d
W�Lqas-���-�Z,ͱ����~�/E���z]0�P��]5��+�Ik���S�É���!ʾI��hUc�C��_�M5���"�g-a�|�/i�qr��B��N�
g��G��P_[��.̛p��΅�S�y����^0ow��\����|����f�`��Ӽ���y3�{��S�e��Dl@@럭��js�<�}�l��g���� 6,������#L�A�,���!���~1���,���-����G)3��SOo߄���>��g�_��7V�}����ѡ��Y�Z�
��~�G��jch|���?������Kb+�=1�m��U��l�6( Z��N�c����>9�T����W1=;�,#�r#�;*�����j�A]���\A:�{k��̨i������K�!������k�2B�l�1( ����S��n��Y��~����ٷߝ^�32���k� �JAjq$� ���o�Y�Π#B��K>��[�3UR��|c��|ӗ䎾�+	i���ư�^��aC�$ݙ0���Π h���Y9��j���ȨO�h`(7�|&��Re��Zo�������7�ճW���qyI�f�m��2( ����^�5�&ig�o���?����t��k�j�|E��;���G5���>H^����q��gz0z\:b��T���<��ĭ�`�a7�*��㳤n��e�56,�:6�N�{L�]Cմ=�@�N��@+Q<?�������:f�����[w���h�֣�n�c2��e��/�lȴ�9'~D���~�v�:cw��9w//���6.�`㺃��Y��[L�F��*�_���X��=XE�Y��觲6�[ɷ�u\:Zv^[jt�=���Y*�2��By]x�6^��6}��B5�
��}8�(ƭDƖ�.-�ұ�S�s}dZ�`y;�Y��U0hʭG�2���L�շ<�����{?ꫤ>͝y<�7�O����U�;��� nP ��׺쏅y'Y��}�MG���b�a���"p������U/]��似I�V�4�Y���t.u�v���nYW{�<��붜�Q�u��Խ�dh�u5$���'��>W���K]V�~��Q���e�k�ט�f������+��7㎋��b�kF7{��*��/����UVW��rۍG��º�=̇���	�Hkֿ��4�c�s{E{�@%R�+�md��6���1���0�q�F&�j��9��s�7�]���1���¾RW�#������ѣ&��
a��W`1�����'��;ˈYZ�+��]�ǳ@�ޥ;��<�L��L"�dTW��/)�Q=(����ܸN/�=r5-b����aw��ux� ��TͳwQ�ȼyK�D��t��2i9���K�{q�f`U$����UE��Ui��h`��������X�L�~�����0|X}��sը*n��,���Q�P�-/�iy��,���gվqV�qV�U3T�ݍ���qZ��˕�+�`�8��Ugg����.}��IK�o���{~�1��Y�n��5�L���PY{�'����ſ���C%�U<o�PY�6��j�=d�顤���ڿ�����Kʀ�����PP��p�7$�ⴴ(�F/�_���>��kzh}C��q�%_6�:@�\�C�衻\��݁=4�B�c��$4Vaքn�D_F��s�2��r��'*K���N@��#�z(�Y��=���Ʊ�7��*=6�������{~�Ȩ�\z���-�n�"0���ͅ~A��/`���je�s}�ՎEرv���y���?Yo�ƞ�gD��=��t/B���đxZL�~WF�y��t�rA��E�-FcX?(Ơay�����=��~�_�����#��'�h�����o.�Nl�7���Ʀ��$����f\�Ş���e��Gl=ю���e�8)h�P���|{�R�z�Ƴ�f���~����^���D$�C2|g��Y��,/���Ds�_�F�A6�HITވ=(��T�j�jGlCq�ć�%XW���6X��9�>2�-�|!���)s�,�$���l$��R{��*����lE�C\}��X��NF���bp��2Y;\c���އ�㟤�93D��`���㷣]���2��O��ˊ��Z�w�Q2E)Z}�����NFӍ3ht�i����
4Ԟm-�}W�5o�?��8Z]tճ��n�h���P�R�I�K�� vO�d��Dk<�l-�J�n#?	�'��F~R�������O
j|��5Ӵ{j.�g�|�z~j� #����&#�Ɉ[���Pjk�Q�~����Gh�Qh�̉X�c�K��lku��^T�2(Zj��� 5l�Xx��D3�����42lH/i�q݆�>�R����	�k�1�u���v����O�>��U8R�዗Iϸ*��G�6���r�%ZV�v��?�u("h(6��"��*��\�rD�P��"�-Cb�"�����~$Wo�� u�_�N���	SC���y['H�V���7F�	�������*j���ã��%�R㐕p��ߘ5�(*��&�R98�愄�U�������p�n���<Tx�������=	�d�{�p��SO�3�w��Wi���Z�p���acP^�M�P���L��O8��s�$(������|z�r�_�`Ov֚[m���N�!z��.�t��Ǿ8�p�J�cW±+���&�1��L���0�_q?}OK�	L�+q][�y*��ϻ�eT%�����Q�̯�ge�~v��e(5��'m�W�	 A�IЇ�����$�H��x<���&u=�]5%A���[X����vE3�ٴ��:c5��G��Ӧ�N���	�6!rM��F�j0qj%�r��2�h�FWQ��-m��z�46���?�"�q�E<�6!�6i|�AM���jc�#�7��Z>��]]5!�6i,�F���k�t��B��i
�\/��.�'��B޹��K���V�?��������(Z�TY��iV���������g?���RظjSl��C�'Iu3o��jy��9=�NR��-��A�\Kv�lT�\�x����@�Κ+c}���:��ze�l�4(T�U���w���U����0������셳AJ4���1(�Y��3tآ�������˫Z5��0x�A�<�NO��t+���c<���@%ݚ�(��U��~�D�*��=p]���7�z�y��    >����\�B�<��y1O���؎1YK{z�j�w���u�Q
�PI�lW�}������]���x7�����6p���h�i�^�؏�owO���t�+Η�ky=Nn�E*�Z�u5��XEu��jF'�PݗPl� �RwFu�����8#��PH:w���IM�3�]/������N����v�V��w��q�>]�oǻkظj���+�d�������;�"�����<86��=/6���=� ���į�^�l=��S�{Ķ������ۊ����l����)�C��j	�/�El���/0nz�Zv���r�x�BZUX��bP֟r�w3k� D�η�
՞$�p��c�\��1��.���*~���_�{'���i�H����6��,-qk݌���Э��V˵�� ������{
��I`Ls��I`\5Әa�Z��j�P5p7��	�M?��ēy���35�Lٌ�q�Ϡ�� ^�3DK������s��б��:J^$e��y�"���\�w�z�e~y?��� T������q��E�x��27��7(	T_�Dp��Ӧ�e���+��-�E�:T��Y
���j���U��.Y9mzuG��tUX%�D��8z}�)!6N	����$�:PUA�����ԚnX�aU���R��X�'t�����t��м<W�f<����c��n=uC& _w/��gY��,N��TJ�6��V������D0�
��0��{\��\�-6Bc��~FZY�kt҇�o��R���0��������Y����|@��x��)�f丕�ebp�$�L���ح�;��CHfi�7"��WIAd/ͤ��~Ӳ��e2b�D�6�α����xjϮ�1s�ַ���	�E 9�M�=���!��`����zs��!��=�����`u��<���&����W����2H�>�I��a�}3�����k	և���Ğ	��ڽOgn����`��Ѕd�s��;��'��C�m[2�\9�`�%�`�sG���)�	v�>i~.Bu��F�~�`�0�T�H�B�n%�KDi� � |YvQ%է���/�Q���q�`��w�*7w�sM�E�g��,Z�銖`�X�_/��5x�!J��$X$�֠΋�/�`�0qW����Kʨ'�$V�[�?Pz��_���o^�5dz������=�ܿ�<0�:a��M���kBjX�	�y���l��(f�N� ���c�
!#͐����&�;��ڠ ~���`�����N�)��M�w'z���T[�%#a<�� ~~�5<g5�+V��d	M�Iso��*��|!����)T1�U�b�gYׇ*�����5��髜�%~�4Z��xB�	�NȞ�UX����*�O~�
�Ʒҗ)w���v)LK_=5�ޝo9���;�{����s�YE5�(K!G�uW�t�t�:���m\yvPA,,\à �v����1�oc�,xֈ��.X$�cֱ���>l"+<��hY���t\#�����@#��Mbgx�YX"["��8BN�/�C=�K����"!a� ]�Ή,$c���D@�Z�a]��$���Ɍ�A^�]�Q�$����a�I<�A �+͞�Aɵ�Gz86x�/���2�B)�D.m)���2]Y�M?5l�@L�*��T,��;G�`�7r��[5�{���x�\~�?�䏛�0��I��0�������;��e`h�4��Ӡ<Y��)�`�OþA���Z��lpX6�''�ٰ��YXA��U�L�榆57����aM�rI>��`�ݲ�ݥáf�z�@	F�7(�b��z�D�`�=e��Et?Kt8K��N���G�[2k�۰7~΋��
ժ_<�\�i�h��J3�
��U�����Н7�Eׁ��l�������Q@�rܛ�cרh?��|���$՟�-�[�荧�'�N��W���<W�:(d]���7���&ހ~�4�`[�#`�Z�A	��ͫ饌�
FC �Ȍ��wz_��X#^0���aXռ|Sg���j��0��`�����s���.�#>i|�!���s���݂9��X�7��w�kBwM�vׄ����	�5��]�kz��&t��o�+{�畒+8�wi56���z׊�mYһV�m��޵�loPһV����޵�l�,�� -��-3( �ll�P���!@S�"c�]K P�� ��� my�2@a^� ��l�P�i�4� ]��몶ʲT&{�?W����A�6��q�q�3�v�C�ԯ)f�mԽ*adY,���w��?(��Hy8�����;w�8C���r�!R
ay�h��a���j^�?����g�3( ҳ���c)�����q�դv�׈��,��z�%�$0����u)�8Ɩ,z����kx4}�ƻhoȴz�g�Δ�1TaH8����=���]�9����SU�+�|��D�Љ����'k��|���� }68Y�z���_�{��5���2�?7>%6�SeK�J��@�A_��u��J�>c��?�C�Eq��%�!8nG�aG��q�;)2�|�=�k���=DȂ����w^Z'� M�)���5c����O�%��^�|�v�R���@��?��˒گ���]\I�W>�0�N��*7i�1Up�s��W	��*������%T��	��-�}N"$>���	y�n��[�W4�{YxĚ�!�D������r�z��S��|�����#s�t��a�%;�?�"&El��1r�d#������DL�H��6-ϕi[�
��5TIA=��RD[V���~�M"�*-M��;��s����}���C��g�s�>���a��a���RW�d�$AC�ʕ0���)�V�U���?{�w����ϺjPZ?]�;	8��D�|7M|I�����r����I���$��tn�ˤG@o�O�w�"��U@��A����$��ܐkc���r�ax�U͎��W=h���"�h
�)ퟞ{���� ��uUX����n����L���G|�0k�5��5X ������f�Ā�:���D%0G�O\n�7sf�'��=<�n��sV�H<h�1��p�o`6���Rz�����[�b`�b�!��nJՃ��/����M��/�RʿYM���!#��U0CH��|�d)cƲn�������.����F���[ɽ�G�~_X�5#�~��/��>�S����n���.,�&F��(sݫ�cԸ<v����e�'=l�}æ�æ/�(J��zX���|��i׃����I56.�x`��� ��D|\�� �I{��w��M����h��8AJ��ߗ�b8AV3��y���SV Tqټ���/�U�)t+��  �z޻t�M!�3�5���/M�I����Ī�+W������+V��y1 =�$�s=�RmL2%��
|#B]=�qW�d0eW!A͂��<��gƦ���iM�{���5��$Q��uk�8���7��D�E����"����^�>�/��U$<S��#����<D���D��&��+v�m��-�\���+|CA�-:n�0EI���º���GIT̽l�n�A�*X�7LIx�������K�������rԀ7W%�?Wo��4�:
F�5�7%x����~D�\_[c���
o�6������./�ɆGW�>�8����B�/Y``�d �"��C.��,�9=4����ЗܵG����X����+^X63aK}�%j�E=l��6�`py>�a\�e�aw?k��d�̾�V��O�6�	���_\��a!�h\���|߳
�F�oH2G`w�[V���%�0>�����TQr%5�Xߝ�PM/���[��P��8˄���1ps�a:6��F�����i�}T��0�H.�iD�@	�ףԀн�_�a�5���l%l��[ev�?/PdP t��hcS;�?7F������ʎ��GM/s`A-��
J�����th7ǧ�dC�p�k$�߶[��=r���+������������p�/��;;�||�NQ     ��}D�����]�7q"�j4�*/�t�`��u�V�}բ�<s��h��5��\�s��h��������
��.l�V��0�_��V��0�"�ɭ��]��4<��
�o�֌����ȏ.��o�gW��V�}��&^D@Hl�D�D��cED��{| ��a�X]��*oDLZ徏���hi�>��ވh��5�W���V/28����rA!�5�޿5[�E������y��x7��QU:��#I5kd����<(�ԅx"��V�XQC�wa%�yJ���U&�1���\�/����P�T��g�I���5�R��-�V��|�1��>��Y��$��m,H=�z�+�hظ`��J)Kf1ח�d�؆!���sB�Lf�F��}�22S0����Я>�o�}��1�ۼ�U0n>c�DXd�]���==�^Ur����7k�0�?i��ʉ$�?F�8�Ɨ"R�������M��[��jFL���༪��E`����1�$"Ŝ�죇�ѯڕ�wr}�f�N)+e���{-i�^tZ��'U"���z�U!lZe���8ZPK�]��p�8Q��tU�U��]�cH����㞉��Zw�W���*��
øN*�0-m�Ρ���W����=D
����+Zf��Y�%>"����2( B��K���X�$G��2���_&k����$��ҷ���0c����Afn�q�tqM���!��9��1�zF��ηOoh�)TA]�5ސ�e�x�G��el��"���@�D�3UX�h�{����8�8Q�e̋y��n0倘�#�rdv�X+��媌L�u�$"���s�SA1?1̀7��$�i��#�qj�܀�5�m�ŃJ~RE�X@��*�:�YEW���hO�K�<l�G�B��:����מ�CXd��6>��}�$/`���t�´��ys�����.�Dw�A/�}���.�ҍ���n��������Y2&;�늈��f1�Y�Uɫ=Q�3�{n���=#���ŽKץ�IN]"����+�G�b+"�+Z"��i��V����.�<��(�
�o�9��<]}l��@��Mc_̡�v��;N!��Ю���Fŕhe9�[x�<^�`Ut�2K�	ZE���=��7��I�fh�sn��t�I��y�n�ʏ��G�s��GܲY�m���$�8���H�W�b�%�K�	n
����W��-3͍*JpT�R������@p��~��D���:|�éY8�=��rsL�wB8��ΚU.���"�}����O6����`C<�I��|��{�쒾#,�Q�ۿ�x�?E��9�M����MT�/EBN'���qU`r��)S�{�oQ���Ӫo��9�K��=yVc�J-��7�g�a�r�@�o iBX�F&8�&�}:�}p���@�+�?}Cq�S ��'�3��Hk��9�$��p���P:L��.V������/��R������L�	������p�K`���:��p�"I�=	�A��\����:��ڝ�
o�k`�M�*��!��~�鋷�'��PX	�'д����H����ê7	�L�r+�wPWţe��Kt�U�|R��7�����7����]����H*e!X������*��죿����_�Ƙ�X�>�@~:�Y�H�D�VHZ��<Z��ޓݦ��e|���GH�B;7�7�"�9����'HZ�z&a.	~�T�g��J�x�p#$#�#��b��@K\�ty��<#�m�\/a�cd�Ud���ʧ(#L�]��ͤ�IinɋW����2qİ�"���r�9��"����ߒm���p�����<b��>�����.��U|w�����I"V��z^��ƂQ�dY`z�4sG�D!�pH�G�&[�}ڸ���饹�E,+�i1�/]q,V�v�!�������>��Pj^=Op%��M���
��?����0�"$����n�/ ��|��fb�򆥶��������8�*�-Ƿt����n��B���0����#�?ĉ�jmڒ�4�B����I�c��tW��-	)T�Y	�/d��P6�w?]S[�oD��k�O��-�g��1�������)�+ي�vC�����m�	W�����wL#J]XuW9��
�FW),I��^��*uh5�]O�yА^�D.���ëH,��SWCr[	S岊�'�t������~�%f�#� A����l������k x���W2Q,��1��H
��=`Յ�/u݁:
�i��"�j|�K�ZDXaW-�%y��Xf�W�/����$�At�:;�bB����;Ź���ޞoOZ�²��O�Q�q4���n*4՝�z�b*O����]���Fl�ɐt^�Md��r^_k|�ImMϸYp�F�Ϻ��ǿ����wh::B�ue�>��n�@�~.y���_q��E�tN��<�ABꃤ���ز��Y���b�6b��V�����׈�9Z�2�rH��/�CR����
R(��{:�	?b��w8k%�LȂ���������C�w�/� /�P���Z?�	44�Kp������3�� 	���a/d�"��	��k#o� ?���Z�>��� ?��(ӂ�����Z� _P��L�t�;����i���q��&�%�!Ѭ8�TV�`3��ϖ�7?��)��$:���m���ܝ�|!C�2�2����S�i��煻����1����f�d��!�ڥ��p�d0�����ʥ�,D�0!k�7�p�(�G��(jH��!��A�d�s��9t��N;�'��M�U`Z)@��:�-����$B��kh���K5���&c!�r>yσ�u?���r2��l>��jf��¯T^�xl�K�᝱�*�,��D�XTsM
�I*cA�.s�ǌ�T�����Ks�"ZZ�����JJ,�@����Q�XD�ǒ��Kg^�#����lfl4�$���t�������"��H���f��02\��4���=ex��3�;_Lw���[��#��
��~�(�d.D��`rc���`rM�|%���b����s���du-�rƮ��ķ�f�@�K�t�!�؀��6E���}H�t�r�I�_q8o�E3u�խô._Xtj�N`�s`}η����2���٘�1&��6�K�Q���ڬ�~^Z�F2��Y��ϋ�d.�j����=�	5'd�o�'4�s��H��|�SIGN��e�ns�\姪�p�fx���Η���E�7�����hsUb�6s�w�e�p3<�7w?�I؇�v�'��������nw�}�^��FU7�`�^��������C�{y>���_DL/���pe��X�̑@�?��:H�V�3뭠�g9�>k����1�N�[M2\�����"b�-���!b��[�,é���W�!�`��f����Z� ;�( ��l�!h��KݹA��K���#S2A`i���w?�� dڼ'�i��	�J�]���Qtm�I���m�Y��y��RSIL�N��y�¥P�c����������X�8P�_�f,�t90@�!Ç��N~ۜF�²y7`����f�|6��dK�p'���:��Vx�Zoy,X�CA�Z���g���+�z/�uQ ù�����7<�(͸e�WWaH {��5KZ��*[�_$�>�ъ|�O[~�=yq�G㭆�_5�1��F� ��|Э-c��!=u����t]�̋��3F~�FD>���`�=c���4���>��g_��ܢ�BN mjκ�/��X�fU.l�͡
��_%XJ�Mݚ������o��9�B�tm9��9,R�k2��"?X���4�q#�wv�&7���U���D��]pĄ�n�7�@<�/��$�Y��/��*ù$��#�a��T���u�)�#��2ٿ7lF���y[�o�:0bj�%b����Ⱥ��U���	��y��:�Ԧ'p�b��w[@�B(#�@_��\ٶ���8AL�V�j���H���� �	N�?*%#���;i�\��O�&;��<]�T����e��΍��)��
~�"e�`(K@��)�s�2mW
vOG���:ה�jh� �  �(RY{�+2[�}
S������*�d��Or�a��2�])f@I�:O6w�A�k�}��<>0s+R_�E����U���3rU� ���� _�p�#�ɾNI~-������Z�
�J5�����!s����r���ʶ�7�r��ޛ�R8Z�rǎiFHk����/n����������U��y�Q�Or�7#õu�|��]M�p�y݆�#���E� T��%0'��J����nD��U`�4�-[��-���#�����|`��;_�?��\/�ޔtTw~�å����-<��g,!#_��R����^(D!�w�1����!IxF��Fu���������ڮ�+�����V��u�T�$[��*Yw�'ߵ����o�Cz��7�c�U<��D}�U8z��OC�J��0�tON���5��ϦίЅq�x3���]�!��;&��TF<>3#�zn$T�H�.�%��ݪ#��X��l'���-O·Ȳ.<����^=������9���Գ&����|�������Ԉ���]�Q�t���G1�P��jg |��w��v�qÿT��T]G��9��P#�xF�q�><=�c�(D>h>����\TI���%�/����	��F!�!��}�Ґ��y(������O����#��%�G���%.���-�1Ta�UJ�l5ݝ��*��$���Q�x�(������*���?�����2���     