PGDMP  #                    }            call_tracker    16.9 (Debian 16.9-1.pgdg120+1)    16.3 )   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16389    call_tracker    DATABASE     w   CREATE DATABASE call_tracker WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF8';
    DROP DATABASE call_tracker;
                call_tracker_user    false            �           0    0    call_tracker    DATABASE PROPERTIES     5   ALTER DATABASE call_tracker SET "TimeZone" TO 'utc';
                     call_tracker_user    false                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                call_tracker_user    false            t           1255    18522    address_summary(integer)    FUNCTION     V  CREATE FUNCTION public.address_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.province_id) INTO v_total
    FROM tb_province a;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Address summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT 
                        (SELECT
                            COUNT(a.province_id) total_province                    
                        FROM tb_province a),
                        (SELECT
                            COUNT(CASE WHEN a.is_active = TRUE THEN a.province_id END) active_province
                        FROM tb_province a),  
                        (SELECT
                            COUNT(a.district_id) total_district                    
                        FROM tb_district a),
                        (SELECT
                            COUNT(CASE WHEN a.is_active = TRUE THEN a.district_id END) active_district
                        FROM tb_district a), 
                        (SELECT
                            COUNT(a.commune_id) total_commune                    
                        FROM tb_commune a),
                        (SELECT
                            COUNT(CASE WHEN a.is_active = TRUE THEN a.commune_id END) active_commune
                        FROM tb_commune a), 
                        (SELECT
                            COUNT(a.village_id) total_village                    
                        FROM tb_village a),
                        (SELECT
                            COUNT(CASE WHEN a.is_active = TRUE THEN a.village_id END) active_village
                        FROM tb_village a)                 
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No address found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve addres summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 9   DROP FUNCTION public.address_summary(p_user_id integer);
       public          call_tracker_user    false    5                       1255    16399 �   audit_logs_insert(character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, timestamp with time zone, json) 	   PROCEDURE     �  CREATE PROCEDURE public.audit_logs_insert(IN _method character varying, IN _original_url character varying, IN _user_id character varying, IN _ip character varying, IN _user_agent character varying, IN _status_code integer, IN _message character varying, IN _error character varying, IN _duration_ms integer, IN _log_type character varying, IN _log_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP, IN _body json DEFAULT NULL::json)
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
       public          call_tracker_user    false    5                       1255    16400 G   business_delete(integer, character varying, character varying, integer) 	   PROCEDURE     U  CREATE PROCEDURE public.business_delete(IN p_business_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5                       1255    16401 S   business_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.business_insert(IN p_business_name text, IN p_business_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5                       1255    16402 K   business_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.business_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5                       1255    16403 e   business_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.business_update(IN p_business_id integer, IN p_business_name text, IN p_business_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5                       1255    16404 D   call_log_delete(text, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_delete(IN p_call_log_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5                       1255    16405 �   call_log_detail_history_insert(text, text, integer, timestamp without time zone, timestamp without time zone, text, boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     )  CREATE PROCEDURE public.call_log_detail_history_insert(IN p_call_log_detail_id text, IN p_call_log_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5                        1255    16406 �   call_log_detail_insert(text, integer, timestamp without time zone, timestamp without time zone, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     \  CREATE PROCEDURE public.call_log_detail_insert(IN p_call_log_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            !           1255    16407 �   call_log_detail_update(text, text, integer, timestamp without time zone, timestamp without time zone, text, boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_detail_update(IN p_call_log_id text, IN p_call_log_detail_id text, IN p_contact_result_id integer, IN p_call_start_datetime timestamp without time zone, IN p_call_end_datetime timestamp without time zone, IN p_remark text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            p           1255    18473 �   call_log_history_insert(text, text, integer, integer, text, text, date, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     v  CREATE PROCEDURE public.call_log_history_insert(IN p_call_log_id text, IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_follow_up_date date, IN p_is_follow_up boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
        follow_up_date,
		is_follow_up,
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
        p_follow_up_date,
		p_is_follow_up,
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
 g  DROP PROCEDURE public.call_log_history_insert(IN p_call_log_id text, IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_follow_up_date date, IN p_is_follow_up boolean, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          call_tracker_user    false    5            o           1255    18472 �   call_log_insert(text, integer, integer, text, text, date, boolean, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_insert(IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_follow_up_date date, IN p_is_follow_up boolean, IN p_call_log_detail jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$

DECLARE
    v_call_log_id text;
    v_msg character varying;
    v_err character varying;
    v_status integer;
    v_detail_entry jsonb;
    v_detail_contact_result_id integer;
    v_detail_call_start_datetime timestamp without time zone;
    v_detail_call_end_datetime timestamp without time zone;
    v_detail_remark text;
    v_detail_menu_id text;
    v_detail_contact_data jsonb;
BEGIN
    SELECT * INTO v_call_log_id FROM generate_id('CL');
    INSERT INTO public.tb_call_log(
        call_log_id,
        lead_id,
        property_profile_id,
        status_id,
        purpose,
        fail_reason,
        follow_up_date,
		is_follow_up,
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
        p_follow_up_date,
		p_is_follow_up,
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
        p_follow_up_date,
		p_is_follow_up,
        p_created_by,
        v_msg,  
        v_err,   
        v_status 
    );

   
    IF v_status <> 200 THEN
        message := v_msg;    
        error := v_err;      
        "statusCode" := v_status;
        RETURN;
    END IF;

    FOR v_detail_entry IN SELECT * FROM jsonb_array_elements(p_call_log_detail)
    LOOP
        v_detail_contact_result_id := (v_detail_entry->>'contact_result_id')::integer;
        v_detail_call_start_datetime := (v_detail_entry->>'call_start_datetime')::timestamp without time zone;
        v_detail_call_end_datetime := (v_detail_entry->>'call_end_datetime')::timestamp without time zone;
        v_detail_remark := (v_detail_entry->>'remark')::text;
        v_detail_menu_id := (v_detail_entry->>'menu_id')::text;
        v_detail_contact_data := v_detail_entry->'contact_data';
        IF v_detail_contact_data IS NULL OR jsonb_typeof(v_detail_contact_data) != 'array' THEN
            message := 'Invalid contact_data format for one of the call log details. ';
            error := 'Expected "contact_data" to be a JSONB array within each detail entry.';
            "statusCode" := 400; 
            RETURN;
        END IF;

        CALL public.call_log_detail_insert(
            v_call_log_id,
            v_detail_contact_result_id,
            v_detail_call_start_datetime,
            v_detail_call_end_datetime,
            v_detail_remark,
            v_detail_menu_id,
            v_detail_contact_data,
            p_created_by,
            v_msg, 
            v_err, 
            v_status
        );

        IF v_status <> 200 THEN
            message := v_msg;
            error := v_err; 
            "statusCode" := v_status;
            RETURN;
        END IF;
    END LOOP;

    message := 'Call Log and all Contact details inserted successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to insert call log and contact details. An unexpected error occurred.';
        error := SQLERRM;  
        "statusCode" := 500;
END;
$$;
 d  DROP PROCEDURE public.call_log_insert(IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_follow_up_date date, IN p_is_follow_up boolean, IN p_call_log_detail jsonb, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          call_tracker_user    false    5            l           1255    18396 T   call_log_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     @   CREATE FUNCTION public.call_log_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$

DECLARE
    v_total INTEGER;
    v_user_role text;
BEGIN
    SELECT role_id INTO v_user_role FROM public.tb_user_role WHERE staff_id::integer = p_user_id;

    SELECT COUNT(cl.call_log_id) INTO v_total
    FROM public.tb_call_log cl
    WHERE
        CASE
            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_id' AND p_query_search IS NOT NULL
                THEN LOWER(cl.lead_id) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'call_log_id' AND p_query_search IS NOT NULL
                THEN LOWER(cl.call_log_id) LIKE LOWER('%' || p_query_search || '%')
            WHEN p_search_type IS NOT NULL AND p_search_type = 'purpose' AND p_query_search IS NOT NULL
                THEN LOWER(cl.purpose) LIKE LOWER('%' || p_query_search || '%')
            ELSE TRUE
        END
        AND cl.is_active = TRUE
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE
            ELSE cl.created_by = p_user_id
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Call Logs retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(main_cl_data)
                FROM (
                    SELECT
                        cl.call_log_id,
                        cl.lead_id,
                        CONCAT(ld.first_name,'',ld.last_name) lead_name,
                        cl.property_profile_id,
                        pl.property_profile_name,
                        (SELECT COUNT(cld.call_log_detail_id) total_call FROM tb_call_log_detail cld WHERE cl.call_log_id = cld.call_log_id) total_call,
                        (SELECT COUNT(st.site_visit_id) total_site_visit FROM tb_site_visit st WHERE cl.call_log_id = st.call_id) total_site_visit,
                        cl.status_id,
                        cl.purpose,
                        cl.fail_reason,
                        cl.follow_up_date,
						cl.is_follow_up,
                        cl.is_active,
                        cl.created_date::text,
                        CONCAT(uc.first_name, ' ', uc.last_name) AS created_by_name,
                        cl.last_update::text,
                        CONCAT(uu.first_name, ' ', uu.last_name) AS updated_by_name,               
                        (
                            SELECT json_agg(
                                json_build_object(
                                    'call_log_detail_id', cld.call_log_detail_id,
                                    'contact_result_id', cld.contact_result_id,
									 'call_date', cld.call_start_datetime::date::text,
                                    'call_start_datetime', cld.call_start_datetime::time::text,
                                    'call_end_datetime', cld.call_end_datetime::time::text,
									 'total_call_minute', EXTRACT(EPOCH FROM (cld.call_end_datetime - cld.call_start_datetime))::numeric / 60,
                                    'remark', cld.remark,
                                    'is_active', cld.is_active,
                                    'created_date', cld.created_date::text,
                                    'updated_by', cld.updated_by,                           
                                    'contact_data', (
                                        SELECT json_agg(
                                            json_build_object(
                                                'channel_type_id', cc.channel_type_id,
                                                'channel_type_name', ct.channel_type_name,
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
                                        INNER JOIN tb_channel_type ct ON cc.channel_type_id = ct.channel_type_id
                                        WHERE cc.menu_trx_id = cld.call_log_detail_id::text
                                    )
                                )
                            )
                            FROM public.tb_call_log_detail cld
                            WHERE cld.call_log_id = cl.call_log_id
                        )::JSON AS call_log_details
                    FROM public.tb_call_log cl
                    LEFT JOIN tb_lead ld ON cl.lead_id = ld.lead_id
                    LEFT JOIN tb_property_profile pl ON cl.property_profile_id = pl.property_profile_id
                    LEFT JOIN public.tb_staff uc ON uc.staff_id = cl.created_by
                    LEFT JOIN public.tb_staff uu ON uu.staff_id = cl.updated_by
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'lead_id' AND p_query_search IS NOT NULL
                                THEN LOWER(cl.lead_id) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'call_log_id' AND p_query_search IS NOT NULL
                                THEN LOWER(cl.call_log_id) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'purpose' AND p_query_search IS NOT NULL
                                THEN LOWER(cl.purpose) LIKE LOWER('%' || p_query_search || '%')
                            ELSE TRUE
                        END
                        AND cl.is_active = TRUE
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE cl.created_by = p_user_id
                        END
                    ORDER BY cl.last_update::TIMESTAMP DESC NULLS LAST, cl.created_date::TIMESTAMP DESC
                    LIMIT p_page_size
                    OFFSET (p_page - 1) * p_page_size
                ) AS main_cl_data
            )::JSON
        FROM public.tb_call_log dummy_cl
        LIMIT 1;
    ELSE
        RETURN QUERY
        SELECT
            'No call logs found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve call logs.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 �   DROP FUNCTION public.call_log_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          call_tracker_user    false    5            m           1255    18431    call_log_summary(integer)    FUNCTION     �	  CREATE FUNCTION public.call_log_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.staff_id) INTO v_total
    FROM tb_staff a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Call Log summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        COUNT(b.call_log_detail_id) total_call_detail,
                        COUNT(DISTINCT CASE WHEN a.status_id = 1 THEN a.call_log_id END) total_follow_up_call,
                        COUNT(DISTINCT CASE WHEN a.status_id = 2 THEN a.call_log_id END) total_success_call,
                        COUNT(DISTINCT CASE WHEN a.status_id = 3 THEN a.call_log_id END) total_fail_call,
                        COUNT(c.site_visit_id) total_site_visit
                    FROM tb_call_log a
                    LEFT JOIN tb_call_log_detail b ON a.call_log_id = b.call_log_id
                    LEFT JOIN tb_site_visit c ON a.call_log_id = c.call_id
                    WHERE
                        CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No call log found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve call log summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 :   DROP FUNCTION public.call_log_summary(p_user_id integer);
       public          call_tracker_user    false    5            q           1255    18474 �   call_log_update(text, text, integer, integer, text, text, date, boolean, boolean, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.call_log_update(IN p_call_log_id text, IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_follow_up_date date, IN p_is_follow_up boolean, IN p_is_active boolean, IN p_call_log_detail jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$

DECLARE
    v_msg character varying;
    v_err character varying;
    v_status integer;
    v_detail_entry jsonb;
    v_detail_call_log_detail_id text;
    v_detail_contact_result_id integer;
    v_detail_call_start_datetime timestamp without time zone;
    v_detail_call_end_datetime timestamp without time zone;
    v_detail_remark text;
    v_detail_menu_id text;
    v_detail_is_active boolean;
    v_detail_contact_data jsonb;
BEGIN
    UPDATE public.tb_call_log
    SET
        lead_id = p_lead_id,
        property_profile_id = p_property_profile_id,
        status_id = p_status_id,
        purpose = p_purpose,
        fail_reason = p_fail_reason,
        follow_up_date = p_follow_up_date,
		is_follow_up = p_is_follow_up,
        is_active = p_is_active,
        last_update = NOW(),
        updated_by = p_updated_by
    WHERE
        call_log_id = p_call_log_id;

    IF NOT FOUND THEN
        message := 'Call Log with ID ' || p_call_log_id || ' not found for update.';
        error := 'Record not found.';
        "statusCode" := 404; 
        RETURN;
    END IF;

    CALL call_log_history_insert(
        p_call_log_id,
        p_lead_id,
        p_property_profile_id,
        p_status_id,
        p_purpose,
        p_fail_reason,
        p_follow_up_date,
		p_is_follow_up,
        p_updated_by,
        v_msg,
        v_err,
        v_status
    );

    IF v_status <> 200 THEN
        message := v_msg;   
        error := v_err;        
        "statusCode" := v_status;
        RETURN;
    END IF;

    FOR v_detail_entry IN SELECT * FROM jsonb_array_elements(p_call_log_detail)
    LOOP
        v_detail_call_log_detail_id := v_detail_entry->>'call_log_detail_id';
        v_detail_contact_result_id := (v_detail_entry->>'contact_result_id')::integer;
        v_detail_call_start_datetime := (v_detail_entry->>'call_start_datetime')::timestamp without time zone;
        v_detail_call_end_datetime := (v_detail_entry->>'call_end_datetime')::timestamp without time zone;
        v_detail_remark := (v_detail_entry->>'remark')::text;
        v_detail_menu_id := (v_detail_entry->>'menu_id')::text;
        v_detail_is_active := (v_detail_entry->>'is_active')::boolean;
        v_detail_contact_data := v_detail_entry->'contact_data';

        IF v_detail_contact_data IS NULL OR jsonb_typeof(v_detail_contact_data) != 'array' THEN
            message := 'Invalid contact_data format for one of the call log details.';
            error := 'Expected "contact_data" to be a JSONB array within each detail entry. Problematic entry: ' || v_detail_entry::text;
            "statusCode" := 400;
            RETURN;
        END IF;
       
        CALL public.call_log_detail_update(
            p_call_log_id,             
            v_detail_call_log_detail_id, 
            v_detail_contact_result_id,
            v_detail_call_start_datetime,
            v_detail_call_end_datetime,
            v_detail_remark,
            v_detail_is_active,
            v_detail_menu_id,
            v_detail_contact_data,      
            p_updated_by,
            v_msg,
            v_err,
            v_status
        );
    
        IF v_status <> 200 THEN
            message := v_msg;         
            error := v_err;          
            "statusCode" := v_status; 
            RETURN;
        END IF;
    END LOOP;

    message := 'Call Log and all associated details updated successfully.';
    error := NULL;
    "statusCode" := 200;

EXCEPTION
    WHEN OTHERS THEN
        message := 'Failed to update call log and associated details. An unexpected error occurred.';
        error := SQLERRM;      
        "statusCode" := 500; 
END;
$$;
 �  DROP PROCEDURE public.call_log_update(IN p_call_log_id text, IN p_lead_id text, IN p_property_profile_id integer, IN p_status_id integer, IN p_purpose text, IN p_fail_reason text, IN p_follow_up_date date, IN p_is_follow_up boolean, IN p_is_active boolean, IN p_call_log_detail jsonb, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          call_tracker_user    false    5            "           1255    16410 K   channel_type_delete(integer, character varying, character varying, integer) 	   PROCEDURE     y  CREATE PROCEDURE public.channel_type_delete(IN p_channel_type_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            #           1255    16411 W   channel_type_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.channel_type_insert(IN p_channel_type_name text, IN p_channel_type_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            $           1255    16412 O   channel_type_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.channel_type_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5            u           1255    18525    channel_type_summary(integer)    FUNCTION     ;  CREATE FUNCTION public.channel_type_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.channel_type_id) INTO v_total
    FROM tb_channel_type a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Channel Type summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        COUNT(a.channel_type_id) total_channel,
                        COUNT(CASE WHEN a.is_active = TRUE THEN a.channel_type_id END) active_channel
                    FROM tb_channel_type a
                    WHERE
                        CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No channel type found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve channel type summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 >   DROP FUNCTION public.channel_type_summary(p_user_id integer);
       public          call_tracker_user    false    5            %           1255    16413 i   channel_type_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.channel_type_update(IN p_channel_type_id integer, IN p_channel_type_name text, IN p_channel_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            &           1255    16414 W   contact_channel_delete(integer, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.contact_channel_delete(IN p_contact_channel_id integer, IN p_menu_trx_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            '           1255    16415 k   contact_channel_history_insert(integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.contact_channel_history_insert(IN p_channel_type_id integer, IN p_channel_menu_id text, IN p_channel_menu_trx_id text, IN p_created_by integer, OUT p_contact_channel_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            (           1255    16416 c   contact_channel_insert(integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE     8  CREATE PROCEDURE public.contact_channel_insert(IN p_channel_type_id integer, IN p_channel_menu_id text, IN p_channel_menu_trx_id text, IN p_created_by integer, OUT p_contact_channel_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            )           1255    16417 x   contact_value_history_insert(integer, text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.contact_value_history_insert(IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            *           1255    16418 p   contact_value_insert(integer, text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     c  CREATE PROCEDURE public.contact_value_insert(IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            +           1255    16419 �   contact_value_update(integer, integer, text, text, text, boolean, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     [  CREATE PROCEDURE public.contact_value_update(IN p_contact_value_id integer, IN p_contact_channel_id integer, IN p_user_name text, IN p_contact_number text, IN p_remark text, IN p_is_primary boolean, IN p_is_active boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            v           1255    18550 I   create_role_permission(integer, integer, integer, integer, text, boolean)    FUNCTION     �  CREATE FUNCTION public.create_role_permission(p_role_id integer, p_permission_id integer, p_menu_id integer, p_user_id integer, p_description text DEFAULT NULL::text, p_is_active boolean DEFAULT true) RETURNS TABLE(message text, error text, status_code integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the permission already exists for this combination
    IF EXISTS (
        SELECT 1 FROM tb_role_permission 
        WHERE role_id = p_role_id 
          AND permission_id = p_permission_id 
          AND menu_id = p_menu_id
    ) THEN
        RETURN QUERY SELECT 
            'Creation failed.'::TEXT, 
            'This role permission already exists.'::TEXT, 
            409::INTEGER; -- 409 Conflict
        RETURN;
    END IF;

    -- Insert the new role permission
    INSERT INTO tb_role_permission (
        role_id,
        permission_id,
        menu_id,
        description,
        is_active,
        created_date,
        created_by
    ) VALUES (
        p_role_id,
        p_permission_id,
        p_menu_id,
        p_description,
        p_is_active,
        NOW(),
        p_user_id
    );
    
    RETURN QUERY SELECT 
        'Role permission created successfully.'::TEXT, 
        NULL::TEXT, 
        201::INTEGER; -- 201 Created

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 
            'An unexpected error occurred.'::TEXT, 
            SQLERRM::TEXT, 
            500::INTEGER; -- 500 Internal Server Error
END;
$$;
 �   DROP FUNCTION public.create_role_permission(p_role_id integer, p_permission_id integer, p_menu_id integer, p_user_id integer, p_description text, p_is_active boolean);
       public          call_tracker_user    false    5            ,           1255    16420 L   customer_type_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.customer_type_delete(IN p_customer_type_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            -           1255    16421 X   customer_type_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.customer_type_insert(IN p_customer_type_name text, IN p_customer_type_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            .           1255    16422 P   customer_type_pagination(integer, integer, character varying, character varying)    FUNCTION       CREATE FUNCTION public.customer_type_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5            /           1255    16423 j   customer_type_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.customer_type_update(IN p_customer_type_id integer, IN p_customer_type_name text, IN p_customer_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            n           1255    18432    dashboard_summary(integer)    FUNCTION     �7  CREATE FUNCTION public.dashboard_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.staff_id) INTO v_total
    FROM tb_staff a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Dashboard summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t)
                FROM (
                    SELECT
                        (SELECT json_build_object(
                            'total_project', (SELECT COUNT(p.project_id) FROM tb_project p WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_developer', (SELECT COUNT(p.developer_id) FROM tb_developer p WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_property', (SELECT COUNT(p.property_profile_id) FROM tb_property_profile p WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_staff', (SELECT COUNT(p.staff_id) FROM tb_staff p WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer)                                                    
                        )) AS dashboard_summary,

                        --- LEAD PIPELINE SUMMARY
                        (SELECT json_build_object(
                            'total_lead', (SELECT COUNT(p.lead_id) FROM tb_lead p WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_lead_current_month', (
                                SELECT
                                    COUNT(CASE 
                                        WHEN p.created_date >= date_trunc('month', NOW()) 
                                        AND p.created_date < date_trunc('month', NOW()) + INTERVAL '1 month'
                                        THEN p.lead_id 
                                    END) AS current_month_total_lead
                                FROM tb_lead p
                                WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer
                            ),
                            'total_lead_previous_month', (
                                SELECT
                                    COUNT(CASE 
                                            WHEN p.created_date >= date_trunc('month', NOW()) - INTERVAL '1 month'
                                            AND p.created_date < date_trunc('month', NOW())
                                            THEN p.lead_id 
                                    END) AS previous_month_total_lead
                                FROM tb_lead p
                                WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer
                            ),
                            'lead_percentage_change', (
                                WITH monthly_lead AS (
                                    SELECT
                                        COUNT(CASE 
                                            WHEN p.created_date >= date_trunc('month', NOW()) 
                                            AND p.created_date < date_trunc('month', NOW()) + INTERVAL '1 month'
                                            THEN p.lead_id 
                                        END) AS current_month_total_lead,

                                        COUNT(CASE 
                                            WHEN p.created_date >= date_trunc('month', NOW()) - INTERVAL '1 month'
                                            AND p.created_date < date_trunc('month', NOW())
                                            THEN p.lead_id 
                                        END) AS previous_month_total_lead
                                    FROM tb_lead p
                                    WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer
                                )
                                SELECT
                                    CASE
                                        WHEN previous_month_total_lead = 0 THEN
                                            CASE
                                                WHEN current_month_total_lead > 0 THEN 100.00
                                                ELSE 0.00
                                            END
                                        ELSE
                                            LEAST(
                                                ROUND(((current_month_total_lead::numeric - previous_month_total_lead) / previous_month_total_lead) * 100, 2),
                                                100
                                            )
                                    END AS lead_percentage_change
                                FROM monthly_lead
                            )
                        )) AS lead_summary,

                        --- CALL PIPELINE SUMMARY
                        (SELECT json_build_object(
                            'total_call', (SELECT COUNT(p.call_log_id) FROM tb_call_log p WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_success_call', (SELECT COUNT(p.call_log_id) FROM tb_call_log p WHERE p.status_id = 2 AND v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_follow_up_call', (SELECT COUNT(p.call_log_id) FROM tb_call_log p WHERE p.status_id = 1 AND v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),                    
                            'total_fail_call', (SELECT COUNT(p.call_log_id) FROM tb_call_log p WHERE p.status_id = 3 AND v_user_role = 'RG_01' OR p.created_by = p_user_id::integer),
                            'total_call_current_month', (
                                SELECT
                                    COUNT(CASE 
                                        WHEN p.created_date >= date_trunc('month', NOW()) 
                                        AND p.created_date < date_trunc('month', NOW()) + INTERVAL '1 month'
                                        THEN p.call_log_id 
                                    END) AS current_month_total_call
                                FROM tb_call_log p
                                WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer
                            ),
                            'total_call_previous_month', (
                                SELECT
                                    COUNT(CASE 
                                        WHEN p.created_date >= date_trunc('month', NOW()) - INTERVAL '1 month'
                                        AND p.created_date < date_trunc('month', NOW())
                                        THEN p.call_log_id 
                                    END) AS previous_month_total_call
                                FROM tb_call_log p
                                WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer
                            ),
                            'call_percentage_change', (
                                WITH monthly_calls AS (
                                    SELECT
                                        COUNT(CASE 
                                            WHEN p.created_date >= date_trunc('month', NOW()) 
                                            AND p.created_date < date_trunc('month', NOW()) + INTERVAL '1 month'
                                            THEN p.call_log_id 
                                        END) AS current_month_total_call,

                                        COUNT(CASE 
                                            WHEN p.created_date >= date_trunc('month', NOW()) - INTERVAL '1 month'
                                            AND p.created_date < date_trunc('month', NOW())
                                            THEN p.call_log_id 
                                        END) AS previous_month_total_call
                                    FROM tb_call_log p
                                    WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer
                                )
                                SELECT
                                    CASE
                                        WHEN previous_month_total_call = 0 THEN 
                                            CASE 
                                                WHEN current_month_total_call > 0 THEN 100.0
                                                ELSE 0.0
                                            END
                                        ELSE 
                                            LEAST(
                                                ROUND(((current_month_total_call::numeric - previous_month_total_call) / previous_month_total_call) * 100, 2),
                                                100
                                            )
                                    END AS call_percentage_change
                                FROM monthly_calls
                            )
                        )) AS call_log_summary, 

                        --- CALL PIPELINE BY MONTH
                        (SELECT json_agg(monthly_data ORDER BY month_number)
                         FROM (
                            SELECT
                                TO_CHAR(months.month_start, 'TMMonth') AS month,
                                EXTRACT(MONTH FROM months.month_start) AS month_number,
                                COALESCE(COUNT(cld.call_log_id), 0)::integer AS total_call_pipeline
                            FROM
                                generate_series(
                                    date_trunc('year', now()),
                                    date_trunc('year', now()) + interval '11 months',
                                    '1 month'
                                ) AS months(month_start)
                            LEFT JOIN tb_call_log cld ON date_trunc('month', cld.created_date) = months.month_start
                                AND EXTRACT(YEAR FROM cld.created_date) = EXTRACT(YEAR FROM NOW())
                                AND (v_user_role = 'RG_01' OR cld.created_by = p_user_id::integer)
                            GROUP BY
                                months.month_start
                         ) AS monthly_data
                        ) AS call_log_by_month,

                        --- CALL PIPELINE DETAIL
                        (SELECT json_agg(monthly_data ORDER BY month_number)
                         FROM (
                            SELECT
                                TO_CHAR(months.month_start, 'TMMonth') AS month,
                                EXTRACT(MONTH FROM months.month_start) AS month_number,
                                COALESCE(COUNT(cld.call_log_detail_id), 0)::integer AS total_call_pipeline_detail
                            FROM
                                generate_series(
                                    date_trunc('year', now()),
                                    date_trunc('year', now()) + interval '11 months',
                                    '1 month'
                                ) AS months(month_start)
                            LEFT JOIN tb_call_log_detail cld ON date_trunc('month', cld.call_end_datetime) = months.month_start
                                AND EXTRACT(YEAR FROM cld.call_end_datetime) = EXTRACT(YEAR FROM NOW())
                                -- AND (v_user_role = 'RG_01' OR cld.created_by = p_user_id::integer)
                            GROUP BY
                                months.month_start
                         ) AS monthly_data
                        ) AS call_log_detail_by_month,

                        --- CUSTOMER DEMOGRAPHIC BY PROVINCE
                        (SELECT json_agg(demographic_data ORDER BY province)
                         FROM (
                            SELECT
                                pro.province_name AS province,
                                COALESCE(COUNT(l.lead_id), 0)::integer AS total_lead
                            FROM tb_province pro
                            LEFT JOIN tb_district dt ON pro.province_id = dt.province_id
                            LEFT JOIN tb_commune ce ON dt.district_id = ce.district_id
                            LEFT JOIN tb_village vl ON ce.commune_id = vl.commune_id
                            LEFT JOIN tb_lead l ON vl.village_id = l.village_id-- AND (v_user_role = 'RG_01' OR l.created_by = p_user_id::integer)
                            GROUP BY pro.province_name
                            ORDER BY pro.province_name ASC
                         ) AS demographic_data
                        ) AS customer_demographic
                ) t
            )::JSON;
    ELSE    
        RETURN QUERY
        SELECT
            'No dashboard data found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[{"dashboard_counts": {"total_project":0, "total_developer":0, "total_call":0, "total_lead":0}, "call_log_by_month":[]}]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve dashboard summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 ;   DROP FUNCTION public.dashboard_summary(p_user_id integer);
       public          call_tracker_user    false    5            x           1255    18552 :   delete_role_permission(integer, integer, integer, integer)    FUNCTION     4  CREATE FUNCTION public.delete_role_permission(p_role_id integer, p_permission_id integer, p_menu_id integer, p_user_id integer) RETURNS TABLE(message text, error text, status_code integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the record exists before deleting
    IF NOT EXISTS (
        SELECT 1 FROM tb_role_permission 
        WHERE role_id = p_role_id 
          AND permission_id = p_permission_id 
          AND menu_id = p_menu_id
    ) THEN
        RETURN QUERY SELECT 
            'Deletion failed.'::TEXT, 
            'Role permission not found.'::TEXT, 
            404::INTEGER; -- 404 Not Found
        RETURN;
    END IF;

    -- Perform a soft delete by setting is_active to false
    UPDATE tb_role_permission
    SET
        is_active = FALSE,
        last_update = NOW(),
        updated_by = p_user_id
    WHERE
        role_id = p_role_id
        AND permission_id = p_permission_id
        AND menu_id = p_menu_id;

    RETURN QUERY SELECT 
        'Role permission deleted successfully.'::TEXT, 
        NULL::TEXT, 
        200::INTEGER; -- 200 OK

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 
            'An unexpected error occurred.'::TEXT, 
            SQLERRM::TEXT, 
            500::INTEGER; -- 500 Internal Server Error
END;
$$;
    DROP FUNCTION public.delete_role_permission(p_role_id integer, p_permission_id integer, p_menu_id integer, p_user_id integer);
       public          call_tracker_user    false    5            0           1255    16424 H   developer_delete(integer, character varying, character varying, integer) 	   PROCEDURE     ^  CREATE PROCEDURE public.developer_delete(IN p_developer_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            1           1255    16425 T   developer_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     x  CREATE PROCEDURE public.developer_insert(IN p_developer_name text, IN p_developer_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            h           1255    17074 U   developer_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.developer_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
    v_user_role TEXT;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

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
        AND a.is_active = TRUE
        AND CASE
                WHEN v_user_role = 'RG_01' THEN TRUE
                ELSE a.created_by = p_user_id::integer
            END;

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
                        AND CASE
                                WHEN v_user_role = 'RG_01' THEN TRUE
                                ELSE a.created_by = p_user_id::integer
                            END
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
 �   DROP FUNCTION public.developer_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          call_tracker_user    false    5            i           1255    17075    developer_summary(integer)    FUNCTION     	  CREATE FUNCTION public.developer_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.developer_id) INTO v_total
    FROM tb_developer a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Developer summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        (SELECT COUNT(a.developer_id)
                        FROM tb_developer a
                        WHERE v_user_role = 'RG_01' OR a.created_by = p_user_id::integer) AS total_developer,

                        (SELECT COUNT(a.developer_id)
                        FROM tb_developer a
                        WHERE a.is_active = TRUE AND (v_user_role = 'RG_01' OR a.created_by = p_user_id::integer)) AS active_developer,

                        (SELECT COUNT(a.project_id)
                        FROM tb_project a
                        WHERE v_user_role = 'RG_01' OR a.created_by = p_user_id::integer) AS total_project
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No developer found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve developer summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_project,
            '[]'::JSON AS data;
END;
$$;
 ;   DROP FUNCTION public.developer_summary(p_user_id integer);
       public          call_tracker_user    false    5            2           1255    16427 f   developer_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     y  CREATE PROCEDURE public.developer_update(IN p_developer_id integer, IN p_developer_name text, IN p_developer_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            3           1255    16428    generate_id(character varying)    FUNCTION     
  CREATE FUNCTION public.generate_id(prefix character varying) RETURNS TABLE(id character varying)
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
    ELSEIF prefix ='STA' THEN 
        SELECT COUNT(*) + 1 INTO total_count FROM tb_staff;
    END IF; 
    LOOP 
        -- Pad total_count to ensure it is 6 digits
        total_plus := total_count::varchar;
        WHILE LENGTH(total_plus) < 6 LOOP
            total_plus := '0' || total_plus;
        END LOOP;

        -- Generate the unique transaction ID
        IF prefix = 'STA' THEN
        	txt_code:= total_plus;
        ELSE
        	txt_code := prefix||'-' ||  total_plus;
        END IF;

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
       	IF prefix ='STA' THEN
            IF EXISTS (SELECT 1 FROM tb_staff WHERE staff_code = txt_code) THEN
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
       public          call_tracker_user    false    5            4           1255    16429    get_business()    FUNCTION       CREATE FUNCTION public.get_business() RETURNS TABLE(business_id integer, business_name text)
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
       public          call_tracker_user    false    5            5           1255    16430    get_channel_type()    FUNCTION     5  CREATE FUNCTION public.get_channel_type() RETURNS TABLE(channel_type_id integer, channel_type_name text)
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
       public          call_tracker_user    false    5            6           1255    16431 #   get_commune_by_district_id(integer)    FUNCTION     o  CREATE FUNCTION public.get_commune_by_district_id(p_district_id integer) RETURNS TABLE(commune_id integer, district_id integer, commune_name text, is_active boolean, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
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
       public          call_tracker_user    false    5            7           1255    16432    get_customer_type()    FUNCTION     <  CREATE FUNCTION public.get_customer_type() RETURNS TABLE(customer_type_id integer, customer_type_name text)
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
       public          call_tracker_user    false    5            8           1255    16433 $   get_district_by_province_id(integer)    FUNCTION     u  CREATE FUNCTION public.get_district_by_province_id(p_province_id integer) RETURNS TABLE(district_id integer, province_id integer, district_name text, is_active boolean, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
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
       public          call_tracker_user    false    5            9           1255    16434    get_gender()    FUNCTION     �   CREATE FUNCTION public.get_gender() RETURNS TABLE(gender_id integer, gender_name text)
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
       public          call_tracker_user    false    5            :           1255    16435    get_lead_source()    FUNCTION       CREATE FUNCTION public.get_lead_source() RETURNS TABLE(lead_source_id integer, lead_source_name text)
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
       public          call_tracker_user    false    5            ;           1255    16436    get_province()    FUNCTION     �  CREATE FUNCTION public.get_province() RETURNS TABLE(province_id integer, province_name text, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
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
       public          call_tracker_user    false    5            <           1255    16437 
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
       public          call_tracker_user    false    5            =           1255    16438    get_user_role()    FUNCTION     l  CREATE FUNCTION public.get_user_role() RETURNS TABLE(role_id text, staff_id text, description text, is_active boolean, created_date timestamp without time zone, created_by integer, last_update timestamp without time zone, updated_by integer)
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
       public          call_tracker_user    false    5            >           1255    16439    get_user_role_by_id(text)    FUNCTION     �   CREATE FUNCTION public.get_user_role_by_id(p_staff_id text) RETURNS TABLE(role_id text)
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
       public          call_tracker_user    false    5            ?           1255    16440 $   get_user_role_permission_by_id(text)    FUNCTION     p  CREATE FUNCTION public.get_user_role_permission_by_id(p_role_id text) RETURNS TABLE(role_id text, menu_id text, permission_id text, is_active boolean)
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
       public          call_tracker_user    false    5            @           1255    16441 "   get_village_by_commune_id(integer)    FUNCTION     i  CREATE FUNCTION public.get_village_by_commune_id(p_commune_id integer) RETURNS TABLE(village_id integer, commune_id integer, village_name text, is_active boolean, created_date timestamp without time zone, created_by text, last_update timestamp without time zone, updated_by text)
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
       public          call_tracker_user    false    5            A           1255    16442 @   lead_delete(text, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_delete(IN p_lead_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            B           1255    16443 �   lead_history_insert(text, integer, integer, integer, integer, integer, integer, integer, text, text, date, text, text, text, text, text, date, text, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_history_insert(IN p_lead_id text, IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            C           1255    16444 �   lead_insert(integer, integer, integer, integer, integer, integer, integer, text, text, date, text, text, text, text, text, date, text, text, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     Z  CREATE PROCEDURE public.lead_insert(IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            D           1255    16446 P   lead_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.lead_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
                THEN a.lead_id LIKE '%' || p_query_search || '%'
            ELSE TRUE
        END
        AND a.is_active = TRUE
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
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
						pr.province_id,
                        pr.province_name,
						dt.district_id,
                        dt.district_name,
						cm.commune_id,
                        cm.commune_name,
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
						a.created_by,
                        CONCAT(uc.first_name, ' ', uc.last_name) AS created_by_name,
                        a.last_update::TEXT,
						a.updated_by,
                        CONCAT(uu.first_name, ' ', uu.last_name) AS updated_by_name, 
						-- a.updated_by,
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
					LEFT JOIN tb_commune cm ON v.commune_id = cm.commune_id
					LEFT JOIN tb_district dt ON cm.district_id = dt.district_id
					LEFT JOIN tb_province pr ON dt.province_id = pr.province_id
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
                                THEN a.lead_id LIKE '%' || p_query_search || '%'
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE                  
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
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
       public          call_tracker_user    false    5            E           1255    16448 J   lead_source_delete(integer, character varying, character varying, integer) 	   PROCEDURE     p  CREATE PROCEDURE public.lead_source_delete(IN p_lead_source_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            F           1255    16449 V   lead_source_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_source_insert(IN p_lead_source_name text, IN p_lead_source_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            G           1255    16450 N   lead_source_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.lead_source_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5            H           1255    16451 h   lead_source_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_source_update(IN p_lead_source_id integer, IN p_lead_source_name text, IN p_lead_source_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            d           1255    17065    lead_summary(integer)    FUNCTION     �  CREATE FUNCTION public.lead_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.lead_id) INTO v_total
    FROM tb_lead a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Lead summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        COUNT(a.lead_id) total_lead,
                        COUNT(CASE WHEN a.is_active = TRUE THEN a.lead_id END) active_lead
                    FROM tb_lead a
                    LEFT JOIN tb_gender g ON a.gender_id = g.gender_id
                    LEFT JOIN tb_customer_type ct ON a.customer_type_id = ct.customer_type_id
                    LEFT JOIN tb_lead_source ls ON a.lead_source_id = ls.lead_source_id
                    LEFT JOIN tb_village v ON a.village_id = v.village_id
					LEFT JOIN tb_commune cm ON v.commune_id = cm.commune_id
					LEFT JOIN tb_district dt ON cm.district_id = dt.district_id
					LEFT JOIN tb_province pr ON dt.province_id = pr.province_id
                    LEFT JOIN tb_business b ON a.business_id = b.business_id
                    LEFT JOIN tb_staff s1 ON a.initial_staff_id = s1.staff_id
                    LEFT JOIN tb_staff s2 ON a.current_staff_id = s2.staff_id
                    LEFT JOIN tb_staff uc ON uc.staff_id = a.created_by
                    LEFT JOIN tb_staff uu ON uu.staff_id = a.updated_by
                    WHERE              
                        CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
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
            'Failed to retrieve lead summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 6   DROP FUNCTION public.lead_summary(p_user_id integer);
       public          call_tracker_user    false    5            I           1255    16452 �   lead_update(text, integer, integer, integer, integer, integer, integer, integer, text, text, date, text, text, text, text, text, date, text, text, boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.lead_update(IN p_lead_id text, IN p_gender_id integer, IN p_customer_type_id integer, IN p_lead_source_id integer, IN p_village_id integer, IN p_business_id integer, IN p_initial_staff_id integer, IN p_current_staff_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_email text, IN p_occupation text, IN p_home_address text, IN p_street_address text, IN p_biz_description text, IN p_relationship_date date, IN p_remark text, IN p_photo_url text, IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            J           1255    16454 F   project_delete(integer, character varying, character varying, integer) 	   PROCEDURE     L  CREATE PROCEDURE public.project_delete(IN p_project_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            K           1255    16455 d   project_insert(integer, integer, text, text, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.project_insert(IN p_developer_id integer, IN p_village_id integer, IN p_project_name text, IN p_project_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            L           1255    16456 L   project_owner_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.project_owner_delete(IN p_project_owner_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            M           1255    16457 v   project_owner_insert(integer, integer, text, text, date, text, integer, character varying, character varying, integer) 	   PROCEDURE     {  CREATE PROCEDURE public.project_owner_insert(IN p_gender_id integer, IN p_village_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            N           1255    16458 P   project_owner_pagination(integer, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.project_owner_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5            O           1255    16459 �   project_owner_update(integer, integer, integer, text, text, date, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     s  CREATE PROCEDURE public.project_owner_update(IN p_project_owner_id integer, IN p_gender_id integer, IN p_village_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            f           1255    17068 S   project_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.project_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
    v_user_role TEXT;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

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
        AND a.is_active = TRUE
        AND CASE
                WHEN v_user_role = 'RG_01' THEN TRUE
                ELSE a.created_by = p_user_id::integer
            END;

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
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
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
 �   DROP FUNCTION public.project_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          call_tracker_user    false    5            g           1255    17072    project_summary(integer)    FUNCTION     	  CREATE FUNCTION public.project_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.project_id) INTO v_total
    FROM tb_project a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Project summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        (SELECT COUNT(p.project_id)
                        FROM tb_project p
                        WHERE v_user_role = 'RG_01' OR p.created_by = p_user_id::integer) AS total_project,

                        (SELECT COUNT(p.project_id)
                        FROM tb_project p
                        WHERE p.is_active = TRUE AND (v_user_role = 'RG_01' OR p.created_by = p_user_id::integer)) AS active_project,

                        (SELECT COUNT(pp.property_profile_id)
                        FROM tb_property_profile pp
                        WHERE v_user_role = 'RG_01' OR pp.created_by = p_user_id::integer) AS total_properties
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No project found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve project summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_project,
            '[]'::JSON AS data;
END;
$$;
 9   DROP FUNCTION public.project_summary(p_user_id integer);
       public          call_tracker_user    false    5            P           1255    16461 v   project_update(integer, integer, integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.project_update(IN p_project_id integer, IN p_developer_id integer, IN p_village_id integer, IN p_project_name text, IN p_project_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            Q           1255    16462 O   property_profile_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_profile_delete(IN p_property_profile_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            r           1255    18517 �   property_profile_insert(integer, integer, integer, integer, integer, text, text, text, text, numeric, numeric, numeric, integer, integer, text, text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_profile_insert(IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_property_status_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_price numeric, IN p_bedroom integer, IN p_bathroom integer, IN p_year_built text, IN p_description text, IN p_feature text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.tb_property_profile(
        property_type_id,
        project_id,
        project_owner_id,
        property_status_id,
        village_id,
        property_profile_name,
        home_number,
        room_number,
        address,
        width,
        length,
        price,
        bedroom,
        bathroom,
        year_built,
        description,
        feature,
        is_active,
        created_date,
        created_by
    )
    VALUES (
        p_property_type_id,
        p_project_id,
        p_project_owner_id,
        p_property_status_id,
        p_village_id,
        p_property_profile_name,
        p_home_number,
        p_room_number,
        p_address,
        p_width​​ ,
        p_length,
        p_price,
        p_bedroom,
        p_bathroom,
        p_year_built,
        p_description,
        p_feature,
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
 I  DROP PROCEDURE public.property_profile_insert(IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_property_status_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_price numeric, IN p_bedroom integer, IN p_bathroom integer, IN p_year_built text, IN p_description text, IN p_feature text, IN p_created_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          call_tracker_user    false    5            j           1255    17104 \   property_profile_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.property_profile_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total INTEGER;
    v_user_role TEXT;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

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
        AND a.is_active = TRUE
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

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
                        a.property_status_id,
                        ps.property_status,
                        CONCAT(g.first_name, ' ', g.last_name) project_owner_name,
                        pr.province_id,
                        pr.province_name,
						dt.district_id,
                        dt.district_name,
						cm.commune_id,
                        cm.commune_name,
                        a.village_id,
                        v.village_name,
                        a.property_profile_id,
                        a.property_profile_name,
                        a.home_number,
                        a.room_number,
                        a.address,
                        a.width,
                        a.length,
                        a.price,
                        a.bedroom,
                        a.bathroom,
                        a.year_built,
                        a.description,
                        a.feature,
                        a.is_active,
                        CONCAT(b.first_name, ' ', b.last_name) created_by,
                        a.created_date::TEXT,
                        CONCAT(c.first_name, ' ', c.last_name) updated_by,
                        a.last_update::TEXT
                    FROM tb_property_profile a
                    JOIN tb_staff b ON b.staff_id = a.created_by
                    LEFT JOIN tb_village v ON a.village_id = v.village_id
					LEFT JOIN tb_commune cm ON v.commune_id = cm.commune_id
					LEFT JOIN tb_district dt ON cm.district_id = dt.district_id
					LEFT JOIN tb_province pr ON dt.province_id = pr.province_id
                    LEFT JOIN tb_staff c ON c.staff_id = a.updated_by
                    JOIN tb_property_type d ON a.property_type_id = d.property_type_id
                    JOIN tb_project e ON a.project_id = e.project_id
                    JOIN tb_project_owner g ON a.project_owner_id = g.project_owner_id
                    JOIN tb_property_status ps ON a.property_status_id = ps.property_status_id
                    WHERE
                         CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_profile_name' AND p_query_search IS NOT NULL
                                THEN LOWER(a.property_profile_name) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'property_profile_id' AND p_query_search IS NOT NULL
                                THEN a.property_profile_id::TEXT = p_query_search
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
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
 �   DROP FUNCTION public.property_profile_pagination(p_page integer, p_page_size integer, p_search_type character varying, p_query_search character varying, p_user_id integer);
       public          call_tracker_user    false    5            k           1255    17107 !   property_profile_summary(integer)    FUNCTION     �  CREATE FUNCTION public.property_profile_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.staff_id) INTO v_total
    FROM tb_staff a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Property Profile summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        COUNT(a.property_profile_id) total_property_profile,
                        COUNT(CASE WHEN a.is_active = TRUE THEN a.property_profile_id END) active_property_profile,
                        SUM(a.price) total_property_profile_price
                    FROM tb_property_profile a
                    WHERE
                        CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No property profile found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve property profile summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 B   DROP FUNCTION public.property_profile_summary(p_user_id integer);
       public          call_tracker_user    false    5            s           1255    18520 �   property_profile_update(integer, integer, integer, integer, integer, integer, text, text, text, text, numeric, numeric, numeric, integer, integer, text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     *  CREATE PROCEDURE public.property_profile_update(IN p_property_profile_id integer, IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_property_status_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_price numeric, IN p_bedroom integer, IN p_bathroom integer, IN p_year_built text, IN p_description text, IN p_feature text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$

BEGIN
    UPDATE
        public.tb_property_profile
    SET
        property_type_id = p_property_type_id,
        project_id = p_project_id,
        project_owner_id = p_project_owner_id,
        property_status_id = p_property_status_id,
        village_id = p_village_id,
        property_profile_name = p_property_profile_name,
        home_number = p_home_number,
        room_number = p_room_number,
        address = p_address,
        width = p_width​​,
        length = p_length,
        price = p_price,
        bedroom = p_bedroom,
        bathroom = p_bathroom,
        year_built = p_year_built,
        description = p_description,
        feature = p_feature,
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
 �  DROP PROCEDURE public.property_profile_update(IN p_property_profile_id integer, IN p_property_type_id integer, IN p_project_id integer, IN p_project_owner_id integer, IN p_property_status_id integer, IN p_village_id integer, IN p_property_profile_name text, IN p_home_number text, IN p_room_number text, IN p_address text, IN "p_width​​" numeric, IN p_length numeric, IN p_price numeric, IN p_bedroom integer, IN p_bathroom integer, IN p_year_built text, IN p_description text, IN p_feature text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying, INOUT error character varying, INOUT "statusCode" integer);
       public          call_tracker_user    false    5            R           1255    16466 L   property_type_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_type_delete(IN p_property_type_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            S           1255    16467 X   property_type_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_type_insert(IN p_property_type_name text, IN p_property_type_description text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            T           1255    16468 P   property_type_pagination(integer, integer, character varying, character varying)    FUNCTION       CREATE FUNCTION public.property_type_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5            U           1255    16469 j   property_type_update(integer, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.property_type_update(IN p_property_type_id integer, IN p_property_type_name text, IN p_property_type_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            V           1255    16470 O   role_insert(text, text, integer, character varying, character varying, integer) 	   PROCEDURE     O  CREATE PROCEDURE public.role_insert(IN p_role_id text, IN p_role_name text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            W           1255    16471 ^   role_update(text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.role_update(IN p_role_id text, IN p_role_name text, IN p_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            X           1255    16472 F   site_visit_delete(text, character varying, character varying, integer) 	   PROCEDURE     e  CREATE PROCEDURE public.site_visit_delete(IN p_site_visit_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            Y           1255    16473 �   site_visit_history_insert(text, text, integer, integer, text, integer, text, timestamp without time zone, timestamp without time zone, text[], text, integer, character varying, character varying, integer) 	   PROCEDURE     c  CREATE PROCEDURE public.site_visit_history_insert(IN p_site_visit_id text, IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            Z           1255    16474 �   site_visit_insert(text, integer, integer, text, integer, text, timestamp without time zone, timestamp without time zone, text[], text, integer, character varying, character varying, integer) 	   PROCEDURE     3  CREATE PROCEDURE public.site_visit_insert(IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            [           1255    16475 V   site_visit_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.site_visit_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
       public          call_tracker_user    false    5            \           1255    16476 �   site_visit_update(text, text, integer, integer, text, integer, text, timestamp without time zone, timestamp without time zone, text[], text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     K  CREATE PROCEDURE public.site_visit_update(IN p_site_visit_id text, IN p_call_id text, IN p_property_profile_id integer, IN p_staff_id integer, IN p_lead_id text, IN p_contact_result_id integer, IN p_purpose text, IN p_start_datetime timestamp without time zone, IN p_end_datetime timestamp without time zone, IN p_photo_url text[], IN p_remark text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            ]           1255    16477 D   staff_delete(integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.staff_delete(IN p_staff_id integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            ^           1255    16478 �   staff_insert(integer, text, integer, integer, integer, text, text, date, text, text, text, date, date, text, text, text[], text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.staff_insert(IN p_staff_id integer, IN p_staff_code text, IN p_gender_id integer, IN p_village_id integer, IN p_manager_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_position text, IN p_department text, IN p_employment_type text, IN p_employment_start_date date, IN p_employment_end_date date, IN p_employment_level text, IN p_current_address text, IN p_photo_url text[], IN p_menu_id text, IN p_contact_data jsonb, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            _           1255    16479 Q   staff_pagination(integer, integer, character varying, character varying, integer)    FUNCTION     F  CREATE FUNCTION public.staff_pagination(p_page integer DEFAULT 1, p_page_size integer DEFAULT 10, p_search_type character varying DEFAULT NULL::character varying, p_query_search character varying DEFAULT NULL::character varying, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
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
                THEN a.staff_id::text LIKE '%' || p_query_search || '%'
            ELSE TRUE
        END
        AND a.is_active = TRUE
        -- Apply role-based filtering using the internally fetched v_user_role
        AND CASE
            WHEN v_user_role = 'RG_01' THEN TRUE -- If 'RG_01' role, select all
            ELSE a.created_by = p_user_id::integer      -- Otherwise, filter by created_by
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
                        a.first_name,
                        a.last_name,
                        a.gender_id,
                        d.gender_name,
                        pr.province_id,
                        pr.province_name,
						dt.district_id,
                        dt.district_name,
						cm.commune_id,
                        cm.commune_name,
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
                    LEFT JOIN tb_commune cm ON e.commune_id = cm.commune_id
					LEFT JOIN tb_district dt ON cm.district_id = dt.district_id
					LEFT JOIN tb_province pr ON dt.province_id = pr.province_id
                    WHERE
                        CASE
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_name' AND p_query_search IS NOT NULL
                                THEN LOWER(CONCAT(a.first_name,' ',a.last_name)) LIKE LOWER('%' || p_query_search || '%')
                            WHEN p_search_type IS NOT NULL AND p_search_type = 'staff_id' AND p_query_search IS NOT NULL
                                THEN a.staff_id::text LIKE '%' || p_query_search || '%'
                            ELSE TRUE
                        END
                        AND a.is_active = TRUE
                        -- Apply role-based filtering using the internally fetched v_user_role
                        AND CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
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
       public          call_tracker_user    false    5            e           1255    17067    staff_summary(integer)    FUNCTION     �  CREATE FUNCTION public.staff_summary(p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(message character varying, error character varying, status_code integer, total_row integer, data json)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_user_role TEXT;
    v_total INTEGER;
BEGIN
    SELECT role_id INTO v_user_role FROM tb_user_role WHERE staff_id::integer = p_user_id::integer;

    SELECT COUNT(a.staff_id) INTO v_total
    FROM tb_staff a
    WHERE
        CASE
            WHEN v_user_role = 'RG_01' THEN TRUE 
            ELSE a.created_by = p_user_id::integer
        END;

    IF v_total > 0 THEN
        RETURN QUERY
        SELECT
            'Staff summary data retrieved successfully.'::character varying AS message,
            NULL::character varying AS error,
            200::INTEGER AS status_code,
            v_total::INTEGER AS total_row,
            (
                SELECT json_agg(t) FROM (
                    SELECT
                        COUNT(a.staff_id) total_staff,
                        COUNT(CASE WHEN a.is_active = TRUE THEN a.staff_id END) active_staff
                    FROM tb_staff a
                    WHERE
                        CASE
                            WHEN v_user_role = 'RG_01' THEN TRUE
                            ELSE a.created_by = p_user_id::integer
                        END
                ) t
            )::JSON;
    ELSE     
        RETURN QUERY
        SELECT
            'No staff found.'::character varying AS message,
            NULL::character varying AS error,
            404::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            'Failed to retrieve staff summary data.'::character varying AS message,
            SQLERRM::character varying AS error,
            500::INTEGER AS status_code,
            0::INTEGER AS total_row,
            '[]'::JSON AS data;
END;
$$;
 7   DROP FUNCTION public.staff_summary(p_user_id integer);
       public          call_tracker_user    false    5            `           1255    16481 �   staff_update(integer, text, integer, integer, integer, text, text, date, text, text, text, date, date, text, text, text[], boolean, text, jsonb, integer, character varying, character varying, integer) 	   PROCEDURE     ;  CREATE PROCEDURE public.staff_update(IN p_staff_id integer, IN p_staff_code text, IN p_gender_id integer, IN p_village_id integer, IN p_manager_id integer, IN p_first_name text, IN p_last_name text, IN p_date_of_birth date, IN p_position text, IN p_department text, IN p_employment_type text, IN p_employment_start_date date, IN p_employment_end_date date, IN p_employment_level text, IN p_current_address text, IN p_photo_url text[], IN p_is_active boolean, IN p_menu_id text, IN p_contact_data jsonb, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            w           1255    18551 I   update_role_permission(integer, integer, integer, integer, text, boolean)    FUNCTION     �  CREATE FUNCTION public.update_role_permission(p_role_id integer, p_permission_id integer, p_menu_id integer, p_user_id integer, p_description text DEFAULT NULL::text, p_is_active boolean DEFAULT NULL::boolean) RETURNS TABLE(message text, error text, status_code integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the record exists before updating
    IF NOT EXISTS (
        SELECT 1 FROM tb_role_permission 
        WHERE role_id = p_role_id 
          AND permission_id = p_permission_id 
          AND menu_id = p_menu_id
    ) THEN
        RETURN QUERY SELECT 
            'Update failed.'::TEXT, 
            'Role permission not found.'::TEXT, 
            404::INTEGER; -- 404 Not Found
        RETURN;
    END IF;

    UPDATE tb_role_permission
    SET
        -- Use COALESCE to update only non-null parameters, keeping existing values otherwise
        description = COALESCE(p_description, description),
        is_active = COALESCE(p_is_active, is_active),
        last_update = NOW(),
        updated_by = p_user_id
    WHERE
        role_id = p_role_id
        AND permission_id = p_permission_id
        AND menu_id = p_menu_id;

    RETURN QUERY SELECT 
        'Role permission updated successfully.'::TEXT, 
        NULL::TEXT, 
        200::INTEGER; -- 200 OK

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 
            'An unexpected error occurred.'::TEXT, 
            SQLERRM::TEXT, 
            500::INTEGER; -- 500 Internal Server Error
END;
$$;
 �   DROP FUNCTION public.update_role_permission(p_role_id integer, p_permission_id integer, p_menu_id integer, p_user_id integer, p_description text, p_is_active boolean);
       public          call_tracker_user    false    5            a           1255    16482 K   user_role_delete(text, text, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.user_role_delete(IN p_role_id text, IN p_staff_id text, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            b           1255    16483 c   user_role_insert(text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.user_role_insert(IN p_role_id text, IN p_staff_id text, IN p_description text, IN p_is_active boolean, IN p_created_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            c           1255    16484 c   user_role_update(text, text, text, boolean, integer, character varying, character varying, integer) 	   PROCEDURE     x  CREATE PROCEDURE public.user_role_update(IN p_role_id text, IN p_staff_id text, IN p_description text, IN p_is_active boolean, IN p_updated_by integer, INOUT message character varying DEFAULT NULL::character varying, INOUT error character varying DEFAULT NULL::character varying, INOUT "statusCode" integer DEFAULT NULL::integer)
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
       public          call_tracker_user    false    5            �            1259    16485    tb_audit_logs    TABLE     �  CREATE TABLE public.tb_audit_logs (
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
       public         heap    call_tracker_user    false    5            �            1259    16491    tb_audit_logs_id_seq    SEQUENCE     �   ALTER TABLE public.tb_audit_logs ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    215            �            1259    16492    tb_business    TABLE       CREATE TABLE public.tb_business (
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
       public         heap    call_tracker_user    false    5            �            1259    16497    tb_business_business_id_seq    SEQUENCE     �   ALTER TABLE public.tb_business ALTER COLUMN business_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_business_business_id_seq
    START WITH 324
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    217    5                       1259    18440    tb_call_log    TABLE     �  CREATE TABLE public.tb_call_log (
    call_log_id text NOT NULL,
    lead_id text NOT NULL,
    property_profile_id integer NOT NULL,
    status_id integer NOT NULL,
    purpose text,
    fail_reason text,
    follow_up_date date,
    is_follow_up boolean NOT NULL,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
    DROP TABLE public.tb_call_log;
       public         heap    call_tracker_user    false    5            �            1259    16503    tb_call_log_detail    TABLE     �  CREATE TABLE public.tb_call_log_detail (
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
       public         heap    call_tracker_user    false    5            �            1259    16508    tb_call_log_detail_history    TABLE       CREATE TABLE public.tb_call_log_detail_history (
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
       public         heap    call_tracker_user    false    5            	           1259    18457    tb_call_log_history    TABLE     �  CREATE TABLE public.tb_call_log_history (
    history_date timestamp without time zone,
    call_log_id text NOT NULL,
    lead_id text NOT NULL,
    property_profile_id integer NOT NULL,
    status_id integer NOT NULL,
    purpose text,
    fail_reason text,
    follow_up_date date,
    is_follow_up boolean NOT NULL,
    is_active boolean NOT NULL,
    created_date timestamp without time zone,
    created_by integer,
    updated_by integer,
    last_update timestamp without time zone
);
 '   DROP TABLE public.tb_call_log_history;
       public         heap    call_tracker_user    false    5            �            1259    16518    tb_channel_type    TABLE     /  CREATE TABLE public.tb_channel_type (
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
       public         heap    call_tracker_user    false    5            �            1259    16523 #   tb_channel_type_channel_type_id_seq    SEQUENCE     �   ALTER TABLE public.tb_channel_type ALTER COLUMN channel_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_channel_type_channel_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    221    5            �            1259    16524 
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
       public         heap    call_tracker_user    false    5            �            1259    16529    tb_contact_channel    TABLE     V  CREATE TABLE public.tb_contact_channel (
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
       public         heap    call_tracker_user    false    5            �            1259    16534 )   tb_contact_channel_contact_channel_id_seq    SEQUENCE     �   ALTER TABLE public.tb_contact_channel ALTER COLUMN contact_channel_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_channel_contact_channel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    224    5            �            1259    16535    tb_contact_channel_history    TABLE     �  CREATE TABLE public.tb_contact_channel_history (
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
       public         heap    call_tracker_user    false    5            �            1259    16540 1   tb_contact_channel_history_contact_channel_id_seq    SEQUENCE       ALTER TABLE public.tb_contact_channel_history ALTER COLUMN contact_channel_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_channel_history_contact_channel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    226            �            1259    16541    tb_contact_result    TABLE     :  CREATE TABLE public.tb_contact_result (
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
       public         heap    call_tracker_user    false    5            �            1259    16546 '   tb_contact_result_contact_result_id_seq    SEQUENCE     �   ALTER TABLE public.tb_contact_result ALTER COLUMN contact_result_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_result_contact_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    228            �            1259    16547    tb_contact_value    TABLE     q  CREATE TABLE public.tb_contact_value (
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
       public         heap    call_tracker_user    false    5            �            1259    16552 %   tb_contact_value_contact_value_id_seq    SEQUENCE     �   ALTER TABLE public.tb_contact_value ALTER COLUMN contact_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_value_contact_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    230    5            �            1259    16553    tb_contact_value_history    TABLE     �  CREATE TABLE public.tb_contact_value_history (
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
       public         heap    call_tracker_user    false    5            �            1259    16558 -   tb_contact_value_history_contact_value_id_seq    SEQUENCE       ALTER TABLE public.tb_contact_value_history ALTER COLUMN contact_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_contact_value_history_contact_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    232    5            �            1259    16559    tb_customer_type    TABLE     3  CREATE TABLE public.tb_customer_type (
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
       public         heap    call_tracker_user    false    5            �            1259    16564 %   tb_customer_type_customer_type_id_seq    SEQUENCE     �   ALTER TABLE public.tb_customer_type ALTER COLUMN customer_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_customer_type_customer_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    234    5            �            1259    16565    tb_developer    TABLE     #  CREATE TABLE public.tb_developer (
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
       public         heap    call_tracker_user    false    5            �            1259    16570    tb_developer_developer_id_seq    SEQUENCE     �   ALTER TABLE public.tb_developer ALTER COLUMN developer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_developer_developer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    236            �            1259    16571    tb_district    TABLE       CREATE TABLE public.tb_district (
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
       public         heap    call_tracker_user    false    5            �            1259    16576 	   tb_gender    TABLE       CREATE TABLE public.tb_gender (
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
       public         heap    call_tracker_user    false    5            �            1259    16581    tb_lead    TABLE     �  CREATE TABLE public.tb_lead (
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
       public         heap    call_tracker_user    false    5            �            1259    16586    tb_lead_history    TABLE     �  CREATE TABLE public.tb_lead_history (
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
       public         heap    call_tracker_user    false    5            �            1259    16591    tb_lead_source    TABLE     +  CREATE TABLE public.tb_lead_source (
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
       public         heap    call_tracker_user    false    5            �            1259    16596 !   tb_lead_source_lead_source_id_seq    SEQUENCE     �   ALTER TABLE public.tb_lead_source ALTER COLUMN lead_source_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_lead_source_lead_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    242            �            1259    16597    tb_menu    TABLE       CREATE TABLE public.tb_menu (
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
       public         heap    call_tracker_user    false    5            �            1259    16602    tb_occupation    TABLE     '  CREATE TABLE public.tb_occupation (
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
       public         heap    call_tracker_user    false    5            �            1259    16607 
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
       public         heap    call_tracker_user    false    5            �            1259    16612    tb_permission    TABLE       CREATE TABLE public.tb_permission (
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
       public         heap    call_tracker_user    false    5            �            1259    16617 
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
       public         heap    call_tracker_user    false    5            �            1259    16622    tb_project_owner    TABLE     s  CREATE TABLE public.tb_project_owner (
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
       public         heap    call_tracker_user    false    5            �            1259    16627 %   tb_project_owner_project_owner_id_seq    SEQUENCE     �   ALTER TABLE public.tb_project_owner ALTER COLUMN project_owner_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_project_owner_project_owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    249            �            1259    16628    tb_project_project_id_seq    SEQUENCE     �   ALTER TABLE public.tb_project ALTER COLUMN project_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_project_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    248                       1259    18485    tb_property_profile    TABLE     &  CREATE TABLE public.tb_property_profile (
    property_profile_id integer NOT NULL,
    property_type_id integer NOT NULL,
    project_id integer NOT NULL,
    project_owner_id integer NOT NULL,
    property_status_id integer NOT NULL,
    village_id integer NOT NULL,
    property_profile_name text NOT NULL,
    home_number text,
    room_number text,
    address text NOT NULL,
    width numeric NOT NULL,
    length numeric NOT NULL,
    price numeric NOT NULL,
    bedroom integer NOT NULL,
    bathroom integer NOT NULL,
    year_built text NOT NULL,
    description text NOT NULL,
    feature text NOT NULL,
    is_active boolean NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    updated_by integer,
    last_update timestamp without time zone
);
 '   DROP TABLE public.tb_property_profile;
       public         heap    call_tracker_user    false    5                       1259    18484 +   tb_property_profile_property_profile_id_seq    SEQUENCE       ALTER TABLE public.tb_property_profile ALTER COLUMN property_profile_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_property_profile_property_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    268            
           1259    18477    tb_property_status    TABLE     6  CREATE TABLE public.tb_property_status (
    property_status_id integer NOT NULL,
    property_status text,
    property_status_description text,
    is_active boolean,
    created_by integer,
    created_date timestamp without time zone,
    updated_by integer,
    last_update timestamp without time zone
);
 &   DROP TABLE public.tb_property_status;
       public         heap    call_tracker_user    false    5                       1259    18519 )   tb_property_status_property_status_id_seq    SEQUENCE     �   ALTER TABLE public.tb_property_status ALTER COLUMN property_status_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_property_status_property_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    266    5            �            1259    16635    tb_property_type    TABLE     3  CREATE TABLE public.tb_property_type (
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
       public         heap    call_tracker_user    false    5            �            1259    16640 %   tb_property_type_property_type_id_seq    SEQUENCE     �   ALTER TABLE public.tb_property_type ALTER COLUMN property_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tb_property_type_property_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          call_tracker_user    false    5    252            �            1259    16641    tb_province    TABLE     �   CREATE TABLE public.tb_province (
    province_id integer NOT NULL,
    province_name text,
    created_date timestamp without time zone,
    created_by text,
    last_update timestamp without time zone,
    updated_by text,
    is_active boolean
);
    DROP TABLE public.tb_province;
       public         heap    call_tracker_user    false    5            �            1259    16646    tb_role    TABLE       CREATE TABLE public.tb_role (
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
       public         heap    call_tracker_user    false    5                        1259    16651    tb_role_permission    TABLE     :  CREATE TABLE public.tb_role_permission (
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
       public         heap    call_tracker_user    false    5                       1259    16656    tb_site_visit    TABLE     0  CREATE TABLE public.tb_site_visit (
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
       public         heap    call_tracker_user    false    5                       1259    16661    tb_site_visit_history    TABLE     o  CREATE TABLE public.tb_site_visit_history (
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
       public         heap    call_tracker_user    false    5                       1259    16666    tb_staff    TABLE     p  CREATE TABLE public.tb_staff (
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
       public         heap    call_tracker_user    false    5                       1259    16671 	   tb_status    TABLE       CREATE TABLE public.tb_status (
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
       public         heap    call_tracker_user    false    5                       1259    16676    tb_user_role    TABLE       CREATE TABLE public.tb_user_role (
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
       public         heap    call_tracker_user    false    5                       1259    16681 
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
       public         heap    call_tracker_user    false    5                       1259    17018    v_total    TABLE     �  CREATE TABLE public.v_total (
    lead_id text,
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
    DROP TABLE public.v_total;
       public         heap    call_tracker_user    false    5            �          0    16485    tb_audit_logs 
   TABLE DATA           �   COPY public.tb_audit_logs (id, method, original_url, user_id, ip, user_agent, status_code, message, error, duration_ms, log_type, log_time, request_body) FROM stdin;
    public          call_tracker_user    false    215   `�      �          0    16492    tb_business 
   TABLE DATA           �   COPY public.tb_business (business_id, business_name, business_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    217   e      �          0    18440    tb_call_log 
   TABLE DATA           �   COPY public.tb_call_log (call_log_id, lead_id, property_profile_id, status_id, purpose, fail_reason, follow_up_date, is_follow_up, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    264   �s      �          0    16503    tb_call_log_detail 
   TABLE DATA           �   COPY public.tb_call_log_detail (call_log_detail_id, call_log_id, contact_result_id, call_start_datetime, call_end_datetime, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    219   Bt      �          0    16508    tb_call_log_detail_history 
   TABLE DATA           �   COPY public.tb_call_log_detail_history (history_date, call_log_detail_id, call_log_id, contact_result_id, call_start_datetime, call_end_datetime, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    220   �u      �          0    18457    tb_call_log_history 
   TABLE DATA           �   COPY public.tb_call_log_history (history_date, call_log_id, lead_id, property_profile_id, status_id, purpose, fail_reason, follow_up_date, is_follow_up, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    265   kw      �          0    16518    tb_channel_type 
   TABLE DATA           �   COPY public.tb_channel_type (channel_type_id, channel_type_name, channel_type_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    221    x      �          0    16524 
   tb_commune 
   TABLE DATA           �   COPY public.tb_commune (commune_id, district_id, commune_name, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    223   �x      �          0    16529    tb_contact_channel 
   TABLE DATA           �   COPY public.tb_contact_channel (contact_channel_id, channel_type_id, menu_id, menu_trx_id, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    224   ��      �          0    16535    tb_contact_channel_history 
   TABLE DATA           �   COPY public.tb_contact_channel_history (history_date, contact_channel_id, channel_type_id, menu_id, menu_trx_id, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    226   ��      �          0    16541    tb_contact_result 
   TABLE DATA           �   COPY public.tb_contact_result (contact_result_id, menu_id, contact_result_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    228   ��      �          0    16547    tb_contact_value 
   TABLE DATA           �   COPY public.tb_contact_value (contact_value_id, contact_channel_id, user_name, contact_number, remark, is_primary, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    230   ��      �          0    16553    tb_contact_value_history 
   TABLE DATA           �   COPY public.tb_contact_value_history (history_date, contact_value_id, contact_channel_id, user_name, contact_number, remark, is_primary, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    232   �      �          0    16559    tb_customer_type 
   TABLE DATA           �   COPY public.tb_customer_type (customer_type_id, customer_type_name, customer_type_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    234   
�      �          0    16565    tb_developer 
   TABLE DATA           �   COPY public.tb_developer (developer_id, developer_name, developer_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    236   p�      �          0    16571    tb_district 
   TABLE DATA           �   COPY public.tb_district (district_id, province_id, district_name, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    238   ��      �          0    16576 	   tb_gender 
   TABLE DATA           �   COPY public.tb_gender (gender_id, gender_name, gender_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    239   ��      �          0    16581    tb_lead 
   TABLE DATA           `  COPY public.tb_lead (lead_id, gender_id, customer_type_id, lead_source_id, village_id, business_id, initial_staff_id, current_staff_id, first_name, last_name, date_of_birth, occupation, email, home_address, street_address, biz_description, relationship_date, remark, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    240   ��      �          0    16586    tb_lead_history 
   TABLE DATA           v  COPY public.tb_lead_history (history_date, lead_id, gender_id, customer_type_id, lead_source_id, village_id, business_id, initial_staff_id, current_staff_id, first_name, last_name, date_of_birth, occupation, email, home_address, street_address, biz_description, relationship_date, remark, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    241   ��      �          0    16591    tb_lead_source 
   TABLE DATA           �   COPY public.tb_lead_source (lead_source_id, lead_source_name, lead_source_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    242   �      �          0    16597    tb_menu 
   TABLE DATA           �   COPY public.tb_menu (menu_id, menu_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    244   ��      �          0    16602    tb_occupation 
   TABLE DATA           �   COPY public.tb_occupation (occupation_id, occupation_name, occupation_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    245   o�      �          0    16607 
   tb_payment 
   TABLE DATA           �   COPY public.tb_payment (payment_id, call_id, amount_in_usd, start_payment_date, tenor, interest_rate, remark, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    246   ��      �          0    16612    tb_permission 
   TABLE DATA           �   COPY public.tb_permission (permission_id, permission_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    247   ��      �          0    16617 
   tb_project 
   TABLE DATA           �   COPY public.tb_project (project_id, developer_id, village_id, project_name, project_description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    248   ��      �          0    16622    tb_project_owner 
   TABLE DATA           �   COPY public.tb_project_owner (project_owner_id, gender_id, village_id, first_name, last_name, date_of_birth, remark, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    249   ��      �          0    18485    tb_property_profile 
   TABLE DATA           U  COPY public.tb_property_profile (property_profile_id, property_type_id, project_id, project_owner_id, property_status_id, village_id, property_profile_name, home_number, room_number, address, width, length, price, bedroom, bathroom, year_built, description, feature, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    268   �      �          0    18477    tb_property_status 
   TABLE DATA           �   COPY public.tb_property_status (property_status_id, property_status, property_status_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    266   ��      �          0    16635    tb_property_type 
   TABLE DATA           �   COPY public.tb_property_type (property_type_id, property_type_name, property_type_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    252   .�      �          0    16641    tb_province 
   TABLE DATA              COPY public.tb_province (province_id, province_name, created_date, created_by, last_update, updated_by, is_active) FROM stdin;
    public          call_tracker_user    false    254   ��      �          0    16646    tb_role 
   TABLE DATA           �   COPY public.tb_role (role_id, role_name, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    255   ��      �          0    16651    tb_role_permission 
   TABLE DATA           �   COPY public.tb_role_permission (role_id, permission_id, menu_id, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    256   %�      �          0    16656    tb_site_visit 
   TABLE DATA           �   COPY public.tb_site_visit (site_visit_id, call_id, property_profile_id, staff_id, lead_id, contact_result_id, purpose, start_datetime, end_datetime, photo_url, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    257   ��      �          0    16661    tb_site_visit_history 
   TABLE DATA             COPY public.tb_site_visit_history (history_date, site_visit_id, call_id, property_profile_id, staff_id, lead_id, contact_result_id, purpose, start_datetime, end_datetime, photo_url, remark, is_active, created_date, created_by, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    258   ��      �          0    16666    tb_staff 
   TABLE DATA           Q  COPY public.tb_staff (staff_id, staff_code, gender_id, village_id, manager_id, occupation_id, first_name, last_name, date_of_birth, "position", department, employment_type, employment_start_date, employment_end_date, employment_level, current_address, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    259   ��      �          0    16671 	   tb_status 
   TABLE DATA           �   COPY public.tb_status (status_id, status, status_description, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    260   6�      �          0    16676    tb_user_role 
   TABLE DATA           �   COPY public.tb_user_role (role_id, staff_id, description, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    261   ��      �          0    16681 
   tb_village 
   TABLE DATA           �   COPY public.tb_village (village_id, commune_id, village_name, is_active, created_date, created_by, last_update, updated_by) FROM stdin;
    public          call_tracker_user    false    262   ��      �          0    17018    v_total 
   TABLE DATA           `  COPY public.v_total (lead_id, gender_id, customer_type_id, lead_source_id, village_id, business_id, initial_staff_id, current_staff_id, first_name, last_name, date_of_birth, occupation, email, home_address, street_address, biz_description, relationship_date, remark, photo_url, is_active, created_by, created_date, updated_by, last_update) FROM stdin;
    public          call_tracker_user    false    263   R�	      �           0    0    tb_audit_logs_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.tb_audit_logs_id_seq', 9154, true);
          public          call_tracker_user    false    216            �           0    0    tb_business_business_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.tb_business_business_id_seq', 324, true);
          public          call_tracker_user    false    218            �           0    0 #   tb_channel_type_channel_type_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.tb_channel_type_channel_type_id_seq', 6, true);
          public          call_tracker_user    false    222            �           0    0 )   tb_contact_channel_contact_channel_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.tb_contact_channel_contact_channel_id_seq', 183, true);
          public          call_tracker_user    false    225            �           0    0 1   tb_contact_channel_history_contact_channel_id_seq    SEQUENCE SET     a   SELECT pg_catalog.setval('public.tb_contact_channel_history_contact_channel_id_seq', 106, true);
          public          call_tracker_user    false    227            �           0    0 '   tb_contact_result_contact_result_id_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public.tb_contact_result_contact_result_id_seq', 40, true);
          public          call_tracker_user    false    229            �           0    0 %   tb_contact_value_contact_value_id_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.tb_contact_value_contact_value_id_seq', 249, true);
          public          call_tracker_user    false    231            �           0    0 -   tb_contact_value_history_contact_value_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.tb_contact_value_history_contact_value_id_seq', 138, true);
          public          call_tracker_user    false    233            �           0    0 %   tb_customer_type_customer_type_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tb_customer_type_customer_type_id_seq', 2, true);
          public          call_tracker_user    false    235            �           0    0    tb_developer_developer_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.tb_developer_developer_id_seq', 19, true);
          public          call_tracker_user    false    237            �           0    0 !   tb_lead_source_lead_source_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.tb_lead_source_lead_source_id_seq', 3, true);
          public          call_tracker_user    false    243            �           0    0 %   tb_project_owner_project_owner_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tb_project_owner_project_owner_id_seq', 4, true);
          public          call_tracker_user    false    250            �           0    0    tb_project_project_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.tb_project_project_id_seq', 5, true);
          public          call_tracker_user    false    251            �           0    0 +   tb_property_profile_property_profile_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.tb_property_profile_property_profile_id_seq', 1, true);
          public          call_tracker_user    false    267            �           0    0 )   tb_property_status_property_status_id_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.tb_property_status_property_status_id_seq', 5, true);
          public          call_tracker_user    false    269            �           0    0 %   tb_property_type_property_type_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tb_property_type_property_type_id_seq', 4, true);
          public          call_tracker_user    false    253            �           2606    16688     tb_audit_logs tb_audit_logs_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.tb_audit_logs
    ADD CONSTRAINT tb_audit_logs_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.tb_audit_logs DROP CONSTRAINT tb_audit_logs_pkey;
       public            call_tracker_user    false    215            �           2606    16690    tb_business tb_business_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_business
    ADD CONSTRAINT tb_business_pkey PRIMARY KEY (business_id);
 F   ALTER TABLE ONLY public.tb_business DROP CONSTRAINT tb_business_pkey;
       public            call_tracker_user    false    217            �           2606    16692 *   tb_call_log_detail tb_call_log_detail_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.tb_call_log_detail
    ADD CONSTRAINT tb_call_log_detail_pkey PRIMARY KEY (call_log_detail_id);
 T   ALTER TABLE ONLY public.tb_call_log_detail DROP CONSTRAINT tb_call_log_detail_pkey;
       public            call_tracker_user    false    219            �           2606    18446    tb_call_log tb_call_log_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT tb_call_log_pkey PRIMARY KEY (call_log_id);
 F   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT tb_call_log_pkey;
       public            call_tracker_user    false    264            �           2606    16696 $   tb_channel_type tb_channel_type_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.tb_channel_type
    ADD CONSTRAINT tb_channel_type_pkey PRIMARY KEY (channel_type_id);
 N   ALTER TABLE ONLY public.tb_channel_type DROP CONSTRAINT tb_channel_type_pkey;
       public            call_tracker_user    false    221            �           2606    16698    tb_commune tb_commune_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_commune
    ADD CONSTRAINT tb_commune_pkey PRIMARY KEY (commune_id);
 D   ALTER TABLE ONLY public.tb_commune DROP CONSTRAINT tb_commune_pkey;
       public            call_tracker_user    false    223            �           2606    16700 :   tb_contact_channel_history tb_contact_channel_history_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel_history
    ADD CONSTRAINT tb_contact_channel_history_pkey PRIMARY KEY (contact_channel_id);
 d   ALTER TABLE ONLY public.tb_contact_channel_history DROP CONSTRAINT tb_contact_channel_history_pkey;
       public            call_tracker_user    false    226            �           2606    16702 *   tb_contact_channel tb_contact_channel_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.tb_contact_channel
    ADD CONSTRAINT tb_contact_channel_pkey PRIMARY KEY (contact_channel_id);
 T   ALTER TABLE ONLY public.tb_contact_channel DROP CONSTRAINT tb_contact_channel_pkey;
       public            call_tracker_user    false    224            �           2606    16704 (   tb_contact_result tb_contact_result_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.tb_contact_result
    ADD CONSTRAINT tb_contact_result_pkey PRIMARY KEY (contact_result_id);
 R   ALTER TABLE ONLY public.tb_contact_result DROP CONSTRAINT tb_contact_result_pkey;
       public            call_tracker_user    false    228            �           2606    16706 6   tb_contact_value_history tb_contact_value_history_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_value_history
    ADD CONSTRAINT tb_contact_value_history_pkey PRIMARY KEY (contact_value_id);
 `   ALTER TABLE ONLY public.tb_contact_value_history DROP CONSTRAINT tb_contact_value_history_pkey;
       public            call_tracker_user    false    232            �           2606    16708 &   tb_contact_value tb_contact_value_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_contact_value
    ADD CONSTRAINT tb_contact_value_pkey PRIMARY KEY (contact_value_id);
 P   ALTER TABLE ONLY public.tb_contact_value DROP CONSTRAINT tb_contact_value_pkey;
       public            call_tracker_user    false    230            �           2606    16710 &   tb_customer_type tb_customer_type_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_customer_type
    ADD CONSTRAINT tb_customer_type_pkey PRIMARY KEY (customer_type_id);
 P   ALTER TABLE ONLY public.tb_customer_type DROP CONSTRAINT tb_customer_type_pkey;
       public            call_tracker_user    false    234            �           2606    16712    tb_developer tb_developer_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.tb_developer
    ADD CONSTRAINT tb_developer_pkey PRIMARY KEY (developer_id);
 H   ALTER TABLE ONLY public.tb_developer DROP CONSTRAINT tb_developer_pkey;
       public            call_tracker_user    false    236            �           2606    16714    tb_district tb_district_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_district
    ADD CONSTRAINT tb_district_pkey PRIMARY KEY (district_id);
 F   ALTER TABLE ONLY public.tb_district DROP CONSTRAINT tb_district_pkey;
       public            call_tracker_user    false    238            �           2606    16716    tb_gender tb_gender_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_gender
    ADD CONSTRAINT tb_gender_pkey PRIMARY KEY (gender_id);
 B   ALTER TABLE ONLY public.tb_gender DROP CONSTRAINT tb_gender_pkey;
       public            call_tracker_user    false    239            �           2606    16718    tb_lead tb_lead_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT tb_lead_pkey PRIMARY KEY (lead_id);
 >   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT tb_lead_pkey;
       public            call_tracker_user    false    240            �           2606    16720 "   tb_lead_source tb_lead_source_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.tb_lead_source
    ADD CONSTRAINT tb_lead_source_pkey PRIMARY KEY (lead_source_id);
 L   ALTER TABLE ONLY public.tb_lead_source DROP CONSTRAINT tb_lead_source_pkey;
       public            call_tracker_user    false    242            �           2606    16722    tb_menu tb_menu_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tb_menu
    ADD CONSTRAINT tb_menu_pkey PRIMARY KEY (menu_id);
 >   ALTER TABLE ONLY public.tb_menu DROP CONSTRAINT tb_menu_pkey;
       public            call_tracker_user    false    244            �           2606    16724     tb_occupation tb_occupation_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.tb_occupation
    ADD CONSTRAINT tb_occupation_pkey PRIMARY KEY (occupation_id);
 J   ALTER TABLE ONLY public.tb_occupation DROP CONSTRAINT tb_occupation_pkey;
       public            call_tracker_user    false    245            �           2606    16726    tb_payment tb_payment_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_payment
    ADD CONSTRAINT tb_payment_pkey PRIMARY KEY (payment_id);
 D   ALTER TABLE ONLY public.tb_payment DROP CONSTRAINT tb_payment_pkey;
       public            call_tracker_user    false    246            �           2606    16728     tb_permission tb_permission_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.tb_permission
    ADD CONSTRAINT tb_permission_pkey PRIMARY KEY (permission_id);
 J   ALTER TABLE ONLY public.tb_permission DROP CONSTRAINT tb_permission_pkey;
       public            call_tracker_user    false    247            �           2606    16730 &   tb_project_owner tb_project_owner_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_project_owner
    ADD CONSTRAINT tb_project_owner_pkey PRIMARY KEY (project_owner_id);
 P   ALTER TABLE ONLY public.tb_project_owner DROP CONSTRAINT tb_project_owner_pkey;
       public            call_tracker_user    false    249            �           2606    16732    tb_project tb_project_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_project
    ADD CONSTRAINT tb_project_pkey PRIMARY KEY (project_id);
 D   ALTER TABLE ONLY public.tb_project DROP CONSTRAINT tb_project_pkey;
       public            call_tracker_user    false    248            �           2606    18491 ,   tb_property_profile tb_property_profile_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT tb_property_profile_pkey PRIMARY KEY (property_profile_id);
 V   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT tb_property_profile_pkey;
       public            call_tracker_user    false    268            �           2606    18483 *   tb_property_status tb_property_status_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.tb_property_status
    ADD CONSTRAINT tb_property_status_pkey PRIMARY KEY (property_status_id);
 T   ALTER TABLE ONLY public.tb_property_status DROP CONSTRAINT tb_property_status_pkey;
       public            call_tracker_user    false    266            �           2606    16736 &   tb_property_type tb_property_type_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tb_property_type
    ADD CONSTRAINT tb_property_type_pkey PRIMARY KEY (property_type_id);
 P   ALTER TABLE ONLY public.tb_property_type DROP CONSTRAINT tb_property_type_pkey;
       public            call_tracker_user    false    252            �           2606    16738    tb_province tb_province_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tb_province
    ADD CONSTRAINT tb_province_pkey PRIMARY KEY (province_id);
 F   ALTER TABLE ONLY public.tb_province DROP CONSTRAINT tb_province_pkey;
       public            call_tracker_user    false    254            �           2606    16740 *   tb_role_permission tb_role_permission_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tb_role_permission
    ADD CONSTRAINT tb_role_permission_pkey PRIMARY KEY (role_id, permission_id, menu_id);
 T   ALTER TABLE ONLY public.tb_role_permission DROP CONSTRAINT tb_role_permission_pkey;
       public            call_tracker_user    false    256    256    256            �           2606    16742    tb_role tb_role_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tb_role
    ADD CONSTRAINT tb_role_pkey PRIMARY KEY (role_id);
 >   ALTER TABLE ONLY public.tb_role DROP CONSTRAINT tb_role_pkey;
       public            call_tracker_user    false    255            �           2606    16744     tb_site_visit tb_site_visit_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT tb_site_visit_pkey PRIMARY KEY (site_visit_id);
 J   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT tb_site_visit_pkey;
       public            call_tracker_user    false    257            �           2606    16746    tb_staff tb_staff_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.tb_staff
    ADD CONSTRAINT tb_staff_pkey PRIMARY KEY (staff_id);
 @   ALTER TABLE ONLY public.tb_staff DROP CONSTRAINT tb_staff_pkey;
       public            call_tracker_user    false    259            �           2606    16748    tb_status tb_status_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tb_status
    ADD CONSTRAINT tb_status_pkey PRIMARY KEY (status_id);
 B   ALTER TABLE ONLY public.tb_status DROP CONSTRAINT tb_status_pkey;
       public            call_tracker_user    false    260            �           2606    16750    tb_user_role tb_user_role_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.tb_user_role
    ADD CONSTRAINT tb_user_role_pkey PRIMARY KEY (role_id, staff_id);
 H   ALTER TABLE ONLY public.tb_user_role DROP CONSTRAINT tb_user_role_pkey;
       public            call_tracker_user    false    261    261            �           2606    16752    tb_village tb_village_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_village
    ADD CONSTRAINT tb_village_pkey PRIMARY KEY (village_id);
 D   ALTER TABLE ONLY public.tb_village DROP CONSTRAINT tb_village_pkey;
       public            call_tracker_user    false    262            �           2606    16753 -   tb_site_visit fk_site_visit_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 W   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_contact_result_id;
       public          call_tracker_user    false    3486    228    257            �           2606    16758 =   tb_site_visit_history fk_site_visit_history_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 g   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_contact_result_id;
       public          call_tracker_user    false    3486    258    228            �           2606    16763 3   tb_site_visit_history fk_site_visit_history_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 ]   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_lead_id;
       public          call_tracker_user    false    258    3500    240            �           2606    16773 4   tb_site_visit_history fk_site_visit_history_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit_history
    ADD CONSTRAINT fk_site_visit_history_staff_id FOREIGN KEY (staff_id) REFERENCES public.tb_staff(staff_id);
 ^   ALTER TABLE ONLY public.tb_site_visit_history DROP CONSTRAINT fk_site_visit_history_staff_id;
       public          call_tracker_user    false    259    258    3526            �           2606    16778 #   tb_site_visit fk_site_visit_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 M   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_lead_id;
       public          call_tracker_user    false    3500    257    240            �           2606    16788 $   tb_site_visit fk_site_visit_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_site_visit
    ADD CONSTRAINT fk_site_visit_staff_id FOREIGN KEY (staff_id) REFERENCES public.tb_staff(staff_id);
 N   ALTER TABLE ONLY public.tb_site_visit DROP CONSTRAINT fk_site_visit_staff_id;
       public          call_tracker_user    false    3526    257    259            �           2606    16793 C   tb_call_log_detail_history fk_tb_call_log_detail_call_log_detail_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail_history
    ADD CONSTRAINT fk_tb_call_log_detail_call_log_detail_id FOREIGN KEY (call_log_detail_id) REFERENCES public.tb_call_log_detail(call_log_detail_id) ON DELETE CASCADE;
 m   ALTER TABLE ONLY public.tb_call_log_detail_history DROP CONSTRAINT fk_tb_call_log_detail_call_log_detail_id;
       public          call_tracker_user    false    220    219    3476            �           2606    16803 :   tb_call_log_detail fk_tb_call_log_detail_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail
    ADD CONSTRAINT fk_tb_call_log_detail_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 d   ALTER TABLE ONLY public.tb_call_log_detail DROP CONSTRAINT fk_tb_call_log_detail_contact_result_id;
       public          call_tracker_user    false    219    3486    228            �           2606    16808 B   tb_call_log_detail_history fk_tb_call_log_detail_contact_result_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_detail_history
    ADD CONSTRAINT fk_tb_call_log_detail_contact_result_id FOREIGN KEY (contact_result_id) REFERENCES public.tb_contact_result(contact_result_id);
 l   ALTER TABLE ONLY public.tb_call_log_detail_history DROP CONSTRAINT fk_tb_call_log_detail_contact_result_id;
       public          call_tracker_user    false    228    3486    220            �           2606    18462 2   tb_call_log_history fk_tb_call_log_history_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_history
    ADD CONSTRAINT fk_tb_call_log_history_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 \   ALTER TABLE ONLY public.tb_call_log_history DROP CONSTRAINT fk_tb_call_log_history_lead_id;
       public          call_tracker_user    false    240    3500    265            �           2606    18467 4   tb_call_log_history fk_tb_call_log_history_status_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log_history
    ADD CONSTRAINT fk_tb_call_log_history_status_id FOREIGN KEY (status_id) REFERENCES public.tb_status(status_id);
 ^   ALTER TABLE ONLY public.tb_call_log_history DROP CONSTRAINT fk_tb_call_log_history_status_id;
       public          call_tracker_user    false    3528    260    265            �           2606    18447 "   tb_call_log fk_tb_call_log_lead_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT fk_tb_call_log_lead_id FOREIGN KEY (lead_id) REFERENCES public.tb_lead(lead_id);
 L   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT fk_tb_call_log_lead_id;
       public          call_tracker_user    false    3500    240    264            �           2606    18452 $   tb_call_log fk_tb_call_log_status_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_call_log
    ADD CONSTRAINT fk_tb_call_log_status_id FOREIGN KEY (status_id) REFERENCES public.tb_status(status_id);
 N   ALTER TABLE ONLY public.tb_call_log DROP CONSTRAINT fk_tb_call_log_status_id;
       public          call_tracker_user    false    264    260    3528            �           2606    16848 $   tb_commune fk_tb_commune_district_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_commune
    ADD CONSTRAINT fk_tb_commune_district_id FOREIGN KEY (district_id) REFERENCES public.tb_district(district_id);
 N   ALTER TABLE ONLY public.tb_commune DROP CONSTRAINT fk_tb_commune_district_id;
       public          call_tracker_user    false    3496    223    238            �           2606    16853 8   tb_contact_channel fk_tb_contact_channel_channel_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel
    ADD CONSTRAINT fk_tb_contact_channel_channel_type_id FOREIGN KEY (channel_type_id) REFERENCES public.tb_channel_type(channel_type_id);
 b   ALTER TABLE ONLY public.tb_contact_channel DROP CONSTRAINT fk_tb_contact_channel_channel_type_id;
       public          call_tracker_user    false    224    221    3478            �           2606    16858 H   tb_contact_channel_history fk_tb_contact_channel_history_channel_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel_history
    ADD CONSTRAINT fk_tb_contact_channel_history_channel_type_id FOREIGN KEY (channel_type_id) REFERENCES public.tb_channel_type(channel_type_id);
 r   ALTER TABLE ONLY public.tb_contact_channel_history DROP CONSTRAINT fk_tb_contact_channel_history_channel_type_id;
       public          call_tracker_user    false    221    226    3478            �           2606    16863 @   tb_contact_channel_history fk_tb_contact_channel_history_menu_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel_history
    ADD CONSTRAINT fk_tb_contact_channel_history_menu_id FOREIGN KEY (menu_id) REFERENCES public.tb_menu(menu_id);
 j   ALTER TABLE ONLY public.tb_contact_channel_history DROP CONSTRAINT fk_tb_contact_channel_history_menu_id;
       public          call_tracker_user    false    226    244    3504            �           2606    16868 0   tb_contact_channel fk_tb_contact_channel_menu_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_channel
    ADD CONSTRAINT fk_tb_contact_channel_menu_id FOREIGN KEY (menu_id) REFERENCES public.tb_menu(menu_id);
 Z   ALTER TABLE ONLY public.tb_contact_channel DROP CONSTRAINT fk_tb_contact_channel_menu_id;
       public          call_tracker_user    false    244    3504    224            �           2606    16873 .   tb_contact_result fk_tb_contact_result_menu_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_result
    ADD CONSTRAINT fk_tb_contact_result_menu_id FOREIGN KEY (menu_id) REFERENCES public.tb_menu(menu_id);
 X   ALTER TABLE ONLY public.tb_contact_result DROP CONSTRAINT fk_tb_contact_result_menu_id;
       public          call_tracker_user    false    244    3504    228            �           2606    16878 7   tb_contact_value fk_tb_contact_value_contact_channel_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_contact_value
    ADD CONSTRAINT fk_tb_contact_value_contact_channel_id FOREIGN KEY (contact_channel_id) REFERENCES public.tb_contact_channel(contact_channel_id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.tb_contact_value DROP CONSTRAINT fk_tb_contact_value_contact_channel_id;
       public          call_tracker_user    false    230    3482    224            �           2606    16883 &   tb_district fk_tb_district_province_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_district
    ADD CONSTRAINT fk_tb_district_province_id FOREIGN KEY (province_id) REFERENCES public.tb_province(province_id);
 P   ALTER TABLE ONLY public.tb_district DROP CONSTRAINT fk_tb_district_province_id;
       public          call_tracker_user    false    254    238    3518            �           2606    16888    tb_lead fk_tb_lead_business_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_business_id FOREIGN KEY (business_id) REFERENCES public.tb_business(business_id);
 H   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_business_id;
       public          call_tracker_user    false    217    3474    240            �           2606    16893    tb_lead fk_tb_lead_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 F   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_gender_id;
       public          call_tracker_user    false    240    3498    239            �           2606    16898 .   tb_lead_history fk_tb_lead_history_business_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_business_id FOREIGN KEY (business_id) REFERENCES public.tb_business(business_id);
 X   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_business_id;
       public          call_tracker_user    false    241    3474    217            �           2606    16903 3   tb_lead_history fk_tb_lead_history_current_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_current_staff_id FOREIGN KEY (current_staff_id) REFERENCES public.tb_staff(staff_id);
 ]   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_current_staff_id;
       public          call_tracker_user    false    241    259    3526            �           2606    16908 +   tb_lead fk_tb_lead_history_current_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_history_current_staff_id FOREIGN KEY (current_staff_id) REFERENCES public.tb_staff(staff_id);
 U   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_history_current_staff_id;
       public          call_tracker_user    false    3526    259    240            �           2606    16913 3   tb_lead_history fk_tb_lead_history_customer_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_customer_type_id FOREIGN KEY (customer_type_id) REFERENCES public.tb_customer_type(customer_type_id);
 ]   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_customer_type_id;
       public          call_tracker_user    false    241    234    3492            �           2606    16918 +   tb_lead fk_tb_lead_history_customer_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_history_customer_type_id FOREIGN KEY (customer_type_id) REFERENCES public.tb_customer_type(customer_type_id);
 U   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_history_customer_type_id;
       public          call_tracker_user    false    3492    234    240            �           2606    16923 ,   tb_lead_history fk_tb_lead_history_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 V   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_gender_id;
       public          call_tracker_user    false    3498    241    239            �           2606    16928 3   tb_lead_history fk_tb_lead_history_initial_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_initial_staff_id FOREIGN KEY (initial_staff_id) REFERENCES public.tb_staff(staff_id);
 ]   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_initial_staff_id;
       public          call_tracker_user    false    3526    241    259            �           2606    16933 +   tb_lead fk_tb_lead_history_initial_staff_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_history_initial_staff_id FOREIGN KEY (initial_staff_id) REFERENCES public.tb_staff(staff_id);
 U   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_history_initial_staff_id;
       public          call_tracker_user    false    3526    240    259            �           2606    16938 1   tb_lead_history fk_tb_lead_history_lead_source_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_lead_source_id FOREIGN KEY (lead_source_id) REFERENCES public.tb_lead_source(lead_source_id);
 [   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_lead_source_id;
       public          call_tracker_user    false    3502    242    241            �           2606    16943 -   tb_lead_history fk_tb_lead_history_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead_history
    ADD CONSTRAINT fk_tb_lead_history_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 W   ALTER TABLE ONLY public.tb_lead_history DROP CONSTRAINT fk_tb_lead_history_village_id;
       public          call_tracker_user    false    262    241    3532            �           2606    16948 !   tb_lead fk_tb_lead_lead_source_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_lead_source_id FOREIGN KEY (lead_source_id) REFERENCES public.tb_lead_source(lead_source_id);
 K   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_lead_source_id;
       public          call_tracker_user    false    242    240    3502            �           2606    16953    tb_lead fk_tb_lead_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_lead
    ADD CONSTRAINT fk_tb_lead_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 G   ALTER TABLE ONLY public.tb_lead DROP CONSTRAINT fk_tb_lead_village_id;
       public          call_tracker_user    false    3532    262    240            �           2606    16958 &   tb_project_owner fk_tb_owner_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project_owner
    ADD CONSTRAINT fk_tb_owner_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 P   ALTER TABLE ONLY public.tb_project_owner DROP CONSTRAINT fk_tb_owner_gender_id;
       public          call_tracker_user    false    239    3498    249            �           2606    16963 '   tb_project_owner fk_tb_owner_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project_owner
    ADD CONSTRAINT fk_tb_owner_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 Q   ALTER TABLE ONLY public.tb_project_owner DROP CONSTRAINT fk_tb_owner_village_id;
       public          call_tracker_user    false    249    262    3532            �           2606    16968 %   tb_project fk_tb_project_developer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project
    ADD CONSTRAINT fk_tb_project_developer_id FOREIGN KEY (developer_id) REFERENCES public.tb_developer(developer_id);
 O   ALTER TABLE ONLY public.tb_project DROP CONSTRAINT fk_tb_project_developer_id;
       public          call_tracker_user    false    3494    248    236            �           2606    16973 #   tb_project fk_tb_project_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_project
    ADD CONSTRAINT fk_tb_project_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 M   ALTER TABLE ONLY public.tb_project DROP CONSTRAINT fk_tb_project_village_id;
       public          call_tracker_user    false    262    248    3532            �           2606    18492 5   tb_property_profile fk_tb_property_profile_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_project_id FOREIGN KEY (project_id) REFERENCES public.tb_project(project_id);
 _   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_project_id;
       public          call_tracker_user    false    268    248    3512            �           2606    18497 ;   tb_property_profile fk_tb_property_profile_project_owner_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_project_owner_id FOREIGN KEY (project_owner_id) REFERENCES public.tb_project_owner(project_owner_id);
 e   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_project_owner_id;
       public          call_tracker_user    false    268    3514    249            �           2606    18502 ;   tb_property_profile fk_tb_property_profile_property_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_property_type_id FOREIGN KEY (property_type_id) REFERENCES public.tb_property_type(property_type_id);
 e   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_property_type_id;
       public          call_tracker_user    false    252    268    3516                        2606    18512 5   tb_property_profile fk_tb_property_profile_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_profile_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 _   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_profile_village_id;
       public          call_tracker_user    false    3532    268    262                       2606    18507 <   tb_property_profile fk_tb_property_status_property_status_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_property_profile
    ADD CONSTRAINT fk_tb_property_status_property_status_id FOREIGN KEY (property_status_id) REFERENCES public.tb_property_status(property_status_id);
 f   ALTER TABLE ONLY public.tb_property_profile DROP CONSTRAINT fk_tb_property_status_property_status_id;
       public          call_tracker_user    false    3536    268    266            �           2606    16998    tb_staff fk_tb_staff_gender_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_staff
    ADD CONSTRAINT fk_tb_staff_gender_id FOREIGN KEY (gender_id) REFERENCES public.tb_gender(gender_id);
 H   ALTER TABLE ONLY public.tb_staff DROP CONSTRAINT fk_tb_staff_gender_id;
       public          call_tracker_user    false    239    3498    259            �           2606    17003    tb_staff fk_tb_staff_village_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_staff
    ADD CONSTRAINT fk_tb_staff_village_id FOREIGN KEY (village_id) REFERENCES public.tb_village(village_id);
 I   ALTER TABLE ONLY public.tb_staff DROP CONSTRAINT fk_tb_staff_village_id;
       public          call_tracker_user    false    262    3532    259            �           2606    17008 #   tb_village fk_tb_village_commune_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_village
    ADD CONSTRAINT fk_tb_village_commune_id FOREIGN KEY (commune_id) REFERENCES public.tb_commune(commune_id);
 M   ALTER TABLE ONLY public.tb_village DROP CONSTRAINT fk_tb_village_commune_id;
       public          call_tracker_user    false    223    262    3480            �           826    16391     DEFAULT PRIVILEGES FOR SEQUENCES    DEFAULT ACL     X   ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES TO call_tracker_user;
                   postgres    false             	           826    16393    DEFAULT PRIVILEGES FOR TYPES    DEFAULT ACL     T   ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO call_tracker_user;
                   postgres    false            �           826    16392     DEFAULT PRIVILEGES FOR FUNCTIONS    DEFAULT ACL     X   ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS TO call_tracker_user;
                   postgres    false            �           826    16390    DEFAULT PRIVILEGES FOR TABLES    DEFAULT ACL     U   ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO call_tracker_user;
                   postgres    false            �      x��i��Hv �9�+0��{7	��)��ZU��کn���G��icD03�� �IF�_w��x�22�N+e"�;��}�7��?����������[�����.���/�O��כ7�7�z�����|��9��V�EJi���Y���/����������0}��7�ӿ�����a�.��2� ����Tf��ҿ���wx�w+��|�X*/�M�~�"������tt�	��\d*%�f����s���_�����w"j�I3����y��W�n7��o��</����;��?���������3�n������c%#�����2l��� �7e�W%�R��̨)(#�x��A���� i,����4MC�I���f|	KPm�o �h.b;�F�7��L����b��JY0%m��Ø-�J9�/mPA�A����7��$�_D���\��#MI��e@�!��	TR��$��RA��E��m���R�Ҥ���￩{����i�y�|x��o}����q�q�e8c5�o�O+���˧���S�?���f����zy��R�*�8˲�7�_��4�P��W0�e�IY����n�&^i�p)��ظn��yE2�'eܡD��^11+ǌ�R��.�*P�� 2���9]�T?a��J�e�x<���t��1ӱ���-(KUn=���t�/�P/0C.Ԡ�a��˱���K�i������M��vUE�
ŉ��h�����%��p�
�ϔs�+(� ]���2ĽS�X��I���R']+PR�Y������ecy;���I�U�g�]\��(�*��� ����a��?�G������.�H�(�3�W �)��ܺ
�;�;��������~5v��@�� uJ�;)bD�ON��
씔�"�J�	��nc󔗦�J�@~z����
�Yt
��XKDzk<:���:���S��h
��V�À[$3Jh�!�b�h����˻{���j���>-4ϟ�������>�k��\?��毩>��q����ݯŷi�4�#�F��o�i��|����jH���~�|Xo7�S�e�������z�В��~c :���#�����a�n�Y�Q�/�)�hC>^j��@'�hՐ2�f���)�F���F ��Ti����s :�v2�����utF���w4��L���F.�y}��>��ɷ_'�G���_��/�ا>A��`�Jp�f�FM �*T���i���$g�٦�F�1���q�q��,w��9�ɋF��z�zx��(u����!�3�Y,��@��e&=/X�����@UH,���h�T�"��)��v�����_s��.s��IR�J���2�4�5�J�+d|,{��h����8K3\ځ,���|6�J%>
uѳ�Dl!Z�P ��n.''[d���\Ea$�!B/��H uSm\��<���F�vvSXX"2T�|`�E�h`T��E�R�K��T��iT����'b�H�-���I�l*S쪖�H�A`�����z�ʂy�\Q �jxEJ	6�R�2��c�(*ا'��������TZ�<K5h.����'��s���tQ_胔z6I	+���+��]��J#�-� ��ll$R�-�H��A`����%��8�w_���5�H�I�"��U�1`1*��rZ�qZ���q��;���D�<��n�z����~�hB=n�7<�ɟW��*��n��C�|xZo�����x������~燠�h����C���gc �ҩ�#�<�& ���Zq��;I�P�(ܕ`.Qq��?�4�v+-x�_����<$%�rg.�n��?����;���Ն��u&�;�C$��L�M���K\��ָ��٥�-�܈��3��t��j[�K�"��ζ%=�u��G�ɓ�� �k�t�$n�]�N�`8U�.[�jI�qw	��\j�=I3ZZ�r
����}9��(��۾�eaR~Z�jS��Ë��V��j�n~M>hI?^��gc���6 ^
2��Eu�g�gxQ��`��RYk�vNev2S��u�TU��Q	�n� w���H�q5���&g.j�N9�ϙ�I�*�8�K�$�..�����h�����JmNA�0'ߦP��T�f���%����P+9	d�$�)4:��$�J�a���U�Փ='�3]Q6�/̍?(U?�n��^�E� �c�27�"�B��E�,�LE�^�	
��P�S�[n�䨡⶞�F���(���@/�$rU�(�Bs�I�{5F�����/(���Z�\{M	b3_:�6�n�ĝrzH�7:�Qe�4-jXԍ
kb�(���.t��A~��
]��3��s"P�n�}; �!͸�̕\�N��F`�1�z��N��^����9�*��B�+[o���9���]��jr0O�	�6B�R��F����HL��Z*h�
��4��p��8"r��9�Q����/iI27�O`�Rc��k�2l���
�9��g﹗�4��H�D�W8�Xw��@�#�`��M� ��T�8�8sS�q�^�~�R���sDLٕ�ק]Hǖ�Q)6V���?��~(%�??о��=}�������hi�2?�}
�o�g�\��5�Uj~��@p�߱Ѿ׭�r6�ʦvR;�F9ر�~T��[��IY�R��D�0:�Z;�鲽J��4P��MK�����o諌% j='�p>��D��$C)"=|�	�@�k	"���i��[�W�w%��R�9N5�!U�����n>�wO�u~�����}\�?�u���m��}��=��>�ah`��`���q9�3[���0�f��9��Ь.c2A�'=r2`�Y�e���L0�kpdD&v/+Ãf�ڗ*>�O��f{�r�p�)�S���|����X����ˆ&.�Lj`D���،�J)������&%[�30�>�s�Y��Db�ȿ��cQo�R �<#&���v�q���aY#�[&�]����$xN7��̞����� �_e$\��F9��8�0
��o������v��N{��m������v��F���r��h?��gfy�*�a	h|K U�i���4��C�!��LO�R�CZ%'��B�	�a�R���k��R��׮7�:M_��'��<e�׹E�_[�U}�OA��I=qb�^:�#n~l�8���ϲ5 ��Ê���6	��֮�
�w�#���s�1S�ЀO�\3[��P�@oǇ�FoY_ב#L},CL�B3��v�r8�/�(�E�S�P[��On�f}�!�7fݓ܀��#�O���2߹A���g}09[��f�1"~�v� �q�Ai�/��V�Y�J��gN ��p>�>�{v�u�uN�p�b����S��h�+I�:+� �* gwO1XL���t�_e\����t�ch�!cX�ј�v�[��_p�@h�d��c�g��23=��]�XƟ���	�E͆�*�ĭmEqG���b����'2|:�	e�j"�����<�kw��/������=K�4;exIf�(�}�W	iB^�x������/�ݯ�l��ov��n�����$+�dyH�7��.��?oz~����(n<�Gp�S@^R k��T9X����2�=�w��Ճы��F���͏��ϛ�&����ؒ���?�uD�
�A�J%���9��Ο7qT�����	���������*��+��ǒ�Ӗ^#W�JMĐ�F	 �߱�?5�j&tW�������Â�qu�P�K�r�P�+/� ���}x�ܛ��Ĕ*�����u��K��,h��8�����B����
@�)�%�F�^��E7�^��R|���U+�rAD*p�v�� -�p�iC�t�VM{����x&�
� 5�4K9���-���-�o:F��<��UxpO�V�ve/�͉�y<]ۂ@��8���� ޓ��)b�954����F��5.����a#�<�g��Ҭ��ќY�G��!Ї�fO�#9��2L�+*��� �*�0��OF��8C\9�9���e~y~zR��3���DU�G�IY��z���/?�v�Ӈ��~���?��[���w,�����    ����7�:4�ڈ4����O�UBQ[�qB�f*����wv`xYl
t�rB`7�(^���e�T�y)�{��� 􄰪&�T�y/"|	�׌��W�G��P��0\�j��;$y��djAj�h�ԡ��Es����\f5��~�|�1���J�!`���&>�,�=9Y��5�a"��PY%��@7�ch1uT@�7Q���o�������!�����|��.4:U�f���m��Sq���n<,��(`��au΋���Gw�F�>�}��<$O��h��e����z�Op���V������<�V���W-�V�Crs��4[�;�(�W��?��2�İ`�Fx������'��Z���SR�;jt��r���/�D��C�([`�bW��I��A��t���~Ҫ���`V�y�};q	2R�c�j D���"q��X��\U3q8������:jD�l��rɳ-�5nK�Gb~�.�4�Iha����k�t�[����n���؛痻��}��ݪ�����ANU�łg����̂Btbn��s;bx6�$�h;�?�������8,�*�9��:�o���[}`���ݭ�7ɏ�_M��^��6ȇo��q�����2�`�ϑS(�?bM��2�!b��� A=�PnJ�O5#hr��K7�ó��8�phj��H�7�|a;�:����lz�Z9�v�70�f�hlh�U�<%>JK�>��v5-K�=�;%.�� �#s&\/�H����?����)��.F�y�W �O�l�W��A�cKg���a�Q����C�+�*]��7ƈzq�9]�M{��q���X��o�'S-ը[��Yk�a 2<��TC�����0��2H�@3]��Ǎ����21i�:��ht��Y7	-��$���X8�\0�E�I�Ֆ$�qw�1�h��@��&)`v$x*\5:n�C-?j7��.N���5��9�`��E��"�|F�Z7��JHZh�dS�����h�v+�s0��P�eXܐm�Q��w�b��u}Ι�?|s<L|�y~9l�4K"p�,�8dk_Q[nQ!(�a��uC1�D�����l��e<9a��������P��︮�BO\�{,��3�y�},�)�+��¹�@��67���q�!�������n߷�[�_�����x_DO��V	��3m84qa�	:<ń��$U���Cs�C{ڇT��q@�_p�1�P�i���7%�f��7�E���v@�x�xv�M�]QëP�n"�,�uADhWl���Ol/��F��䌓l���+���JyW����f�����/�Z��h���P��x�O�҆�j�|���n��5ӆ�fSAr�}|y��ç�&Y��lr^Z����j���4̋Kx>_8�tx` V'�ӳ�.|��َW�Z������e#�A��w,�9H3�y��U�ƀ�t�QY-�."���u7 ��e�%�T����������fP�?<506��3M�Ð�����|��*D�F@�m	�) Eg!�:>��Jx�`l��+i]�CY_-#Vjh��l��4��E(�l�Dr�^w	��e��
.
�L�N�l�e���v@{�Հ�{\e�vH2	�rM�	I��Q5B�n�v�k�3�IC��;�4;��s�j�E�z���#<16:𱉍n�a���s}P�YHI�KTǽ�R�B���췇P&����� C�����G$@��@4|s��0-����&*�e��P?c����2�S���Q��ރi=����1>������P.Ƴ:Z�����\�	��b34(��@��T�N'�E��ڡ��
���G�x�=��5%5���ν'Y<����=lf縺t*i�Wro�>=��)4U�����ix�T��2�dx?l_6�?n��`[S�O~^>٭ϻ�O���o��e�i�h��c�T3��xi~A
�-�L�RaI����m�vΦ�@�-'$���2ss�r�p�I��0 e���b�|�6[W�Y����#�0�QV�/�y4��&:��&�t�R�
�ax&∤W�����z��/C�W��G�;��@�6/�����_�3S���١o!|�&���@�����A����- ���V����ۛ�/����i	��8��v:�A��Ҹ��E K[��݈B�B����S��IP��=u]YU���<��{i�:p���쌀�
/�˩p�v��W��cw�u���T	w�pǎ����=9J���ʏ_�N�aD���6��/�K�9�%�n�g^��!&��1��+�j;�+(���Wl��!�K�Wb  l�P�^��bӀ�If���ZL���(��x�"�$��#b�����X��� ��D��	8�Ҭn#�0.��$�W�xi\:[��73HԵ��KM����6�Χv���
b��	��it�a�8�4ϲ����NK���B�4��?.��*5J.,CFQ�`��e�d2������H%rg����>�E���{���\��U@�*�Z-J9�P���A�a�����Qg�ëh�$E>DGQ�APw(�����$8dn<�y���ۙ��Y�!}�67�]��
���o�sP�~�	"��\B�tVI���e��థ}�	�K�r��j'(Uh�*ҹ9k�DSm|G���L]���K�v��hTH*�H7�Kr|���u:ڣ5--Ν�M��>�:_����n�V?��d��sJʬ�).�� �C-�,�]�̐:��ڙt��	�צS#zL�{oL9[;W����X���0�xC�J'�j'N��gq�b��N��1�7��kܧ^�I�B���l�W������zcg�AL55Uvb�\`�"Z�hh���jE�d��O���j���tkF��G����s�?6OKۦ�M�}�:�������
��lm�ږ-�Dg��Ct:e�[�RLF=d�m5�$��1%��a��/�2.}�M=n^�~SLw���X_�zn��'���`(����#�q���00	��:��{��
yq� <8p,M(k�Ӊ��lo`\�Z��%@,g��xm�w�D]�Q�>�ǻyt�N0(�5�8K	e�L�}�J-S��wm�wej�0�*}ܨG�;��
D*�3@�Of����S�ej��R1������*}����6*�@s��,SQ��5����يN��b����K�T���h6�FA�i�pG��f�2U�a��Lm6�&���EmR��>�Ş�[D*�N"�Nb�7U�g�vR3��o*�,��}gs�ɋ�H���*�᱘*-S'�����l�Y��>2sAk1��$��$�I���$Շ��}Qe����|����P�q�|x�z�̕Vo�sLL��v�[�B��\3�:K����*}Kn�L�q�
7�L�lw�m|�{�$32�e�����*S�DJ˄�QpR�#)����˄�TX�@�	(�٣&9�h��$r�N��t��t��`����V]3:_ֺb�
��7 d�U7V�������29j�Z6�ta�9T�5'��_-�A�8�<4i�mR�����U#�n:�^WTۨT!�-�B��J�P�3�����^�jd��-�B'�@g?t�s
Q��{�h�au{hmpԞ�@���F�U|����ڵ�wڵez�X�E�@/� .S�j�+�][F�N�}g�J@''����-�LGÌUX
�H��L�v��w��4VS�ݭ&���Ƀ���$UaB�9�	҂u����u���6��W0!Q�ǭ�$j�:,�X���� 2T_�5T���+�~����<����VG�,4/�͈�T���:���TZ��?cs�H��i�&մƯ#_��3*A[�N�}g���+��ǵ]�l�I�u�X�MF�V]����M-�w���=���;�Nb6ɬi�G'�
;j�֊��l��ljþ;[�`SN�_'1�dZ��Y��k,1��0к��~\�߿<?n��?m[���/��`�+�5 ww
�;%���*X	X��e��[C�X�WY�����ǵ{��^�}��g��)<�w*2�0��vF��nA/�'����
�3h����Ǣ���d�X`P&�@���KB    �1/N�k~'<�VŤұ� 7�p0fSѹ
h�����>]�/���Fu�46e�#��
�T��46%	-"��alh��8�12�Oc��b/'��
p��y4��QMP*�Y�A.�Y���㬓�8���B��r���W���x�؝ƫawTW��rn����>I$��#d@b����"yv+X�ɕ�"��e���4���br���;�����9��{�f@�cָ��쮣bYx_�9)8�f*Eǳ��w�����lO�-�Rw�ڌ�h��D4Ќ�D����8K�� ��籬"	+dK&� �Ø�*!�C�5_d$UQ-nxZ���0L��ba�f���9�d;+�%��-SF���Yd;�W{t�����r��)<B�!5Bm$F�^ij3�1��[/{G��A3mR2t��΀ђN���D�-�9��V�$����Q"/�	<{�G��yi	A�5k�K��/2"��l�<��I�T|�S�dP�]ڎ���F���ȠNȈAȄ��-��l�r��A��l�̋���<�t�&T.ق1�=J/m�c��Kd|�7�Z���Y�呺!��*Y����q(��u�Yٯ�Xa^���6nJ���1b*ac�'+r��xtBW�RX#����ш�ǮOD���,[R�xA�JF�B�1X���sЩ{�s���>���/�*����.v���ɩ�1���3m�N�:-{�A�r�L�|�y#@-II�9���>>X�@�J�^�a&�^��	p��Y	�̂6�4�>���*,�aa�"E�N,��0����^- �y9a�R{jf�ǲ�
k{��2����0w͸�K����2 �Y+��n�!���&��2}8ݎMʻTb@;j��We�+<�\���۟7!���P�I��
ᚯ*n�~�O��G#]��L�͇�n(o��@?|\�gr���1��~��[�����[=-w?��{>������O���Cb�h%�_7��/���f��"��n��BZ��g�K>*�h�D|JE��\�Yc�����!Ųwz��9Ъ��Z����
�e����w�o���R{$�MrX�=�����m��ۜ(�O����������&�q�kr���5rkS����[�[�ӷR�AP�A�0L]�w�FX|�{��A��A�S:�)q�'(︒06�'{�P�Pb��Q��#\U�(�(�����������6u��̈C�ߖ��wp�c�ǒQ"�&,�Ti�N./��!�Q�z$�Y0���YTt�w,
�/,����^��Kc�~"�1��Q� �
f��j%Vq��+��K��T�1'������J�ɑ���G��$(��Y�M�C*�+{Z�,���n��Ъo��v�j<�����x��h�ѠД��4�hW��e5���^粠���ԅ�	��h]�}��&�Z�QW�Qx����w�8�1Ȓ<��Fib�s-�L���\
O�������Y#�D�/���cɡ���f;w��
c�m�Kn���'�W��P�V�"�f�'֏z�yPb7K	ZZ��vYT�{�qh\I!�k\��#"G3zͅ�&R�mJgw�v���"ߋ��YK!�+%<�m�?IQp�H�AM�����9$fV��E:A���}"e߮E���T%ץ�e���%1�dK�n�������ž�p�K����\Q��[��bu�l�K᰽�ʬS�&�nK46Y{BQCdג�H��1���Ղlf��}��O���˒��ii�,�r�ix-�)
ٕ�-��e��rx)��2�	4�9��LI��@l�\C�Td7`e�*��U/b��-��!$PDX��3E�Uc}1`��}tcE^�~>:��)��,�W.�=F���\�Uht!T �;��r�l���Ḑ����s1/4`�D��rkcW��0�SW`7�����(�B��s�}�5��>FH�9�a�`�i~	0�$��bl���es���f����-��1p�t�p@}M��mý����lҒB�r\cw�r6�R-����y_���Ι|�Ӝ2�2x��hH�@�a�<墖�x07;t�FE�{' ���)�F�0x	@YI88ͱ��Pj�N�y�n[�tFkʫ�W����<M��y[V7}���7������J�(��>�<m��#�~�G�ў�j�p�>X�Y������74ssn�ɜ���iCX�@g�Ryѳ���G��*�k;����z�9^0.���S�$��5��k܋���̀�G�n���=r깘2�����5P;4K��	Ӥ7�I/V�5��!�>�X����xk���bh���y-�io^�^����m�z����Z��:��[��5%.a�+š*[ظ�72o��*�j�`��R�`��14�.����vjS3[/��I�����p�W�k�@C#��ӱ���9�v.9nI��BӾ8���H���ѱ�J��~��s8�� ��e��f���m��/�M��ӗ��'��+�𧹥�/�aK�4�ʌ�qN��4��Ҿxt<]��9V�����*� �sZHK�]����3�w�f��3�H�$0��I2}�.��7�u����H$`�%���ס=�9(5�y�i)2�x�$���e@���_
������0Bv��_o�@��3���I��$��E�I�k��gE��o��*���шjxY%L��ky	��NC�~eƊ��g&#��
��R+�۩��_�CK˟�3KC[��n��"����������O��*s�h�(b���tp�e�|������]�:+_��yxy~\���d�<��b/���rG�rw��g�+7����C���F�������Ԯq���?hR���H'��U�"����u�����m|d��N������g��zs���4���I͘�*�P�ű8:|_�����OO�6�Z�ѕǤ����^܍͢Pd�a44L��OQ@�Y�"�NDq��Ĵ*���3��s��v"cP�(>m�8���~�(�u.�Db�����l�ҡÃ��dx��4�(ּ�XY�Y�����"mx��XH�P[���`C�tf��8��KLC���6�rz����5D�RZ 蠥H�X��e�����^Մϫ�T�p,���݁p��T�u�=/Wlۧ�����B���Q������~���_w´�<85�C̄��	RT�9T��S}d�\�w�Z�@^�����$Dh�jU5����t�E�_җ��k+�!�b�K��ڄ`fV-ӵqNh]MB#*��/J����PPRScT%��14��8�@3�j��5�I/���3���~�Ҟ3܎��"mǩ�H%5�ͧ1��q$�ʊ����o���zW�G[v�N��ӕ�M=�%9�Oi�K ��: ��>`�4�����MB����0V������^x'ĈRM����������C�S "��3���HѴ�,e��N�\���[c}YOMĴ�ډ�����R%��zG4̏�b��A���\��2�>��azDlpO�C��q�e��`�o<�A�|g��Ŵ{0���z���CV֭��R�/+� �HbB�5��Ns*g�ő�`Tk"t��
(�(Ʉ�K��{F<�2(ۓCMR���T����ǰ�/kN�x
/���O��;C���JY(G��S�.�+/��C���'����#y�	�09��*^��`�j��@��$������
;����%؂�t�Ƙ&�����W�l��n��w�u\YX����єP����!��*]x{�D��s{����d��p�-�Q�0�A���#����%5!�.p�j�*����N�?�mx ����?���2X||1]���Rn��E��D+ׇ�Q����<��C
�E��%�yê�1v�yX����f�"�.�a����^���'�)�!UC���A�NCC´�K�멆@S|��� ����`�FJ��re���Q��_"�T�ޯ��QT���/�������$�D��~\�z�ǭ�ӟ^���ջ�O��֮�(��ӣ���kTM����!�k�J$

~�2A�r"�퐶p    +���a{����V���9^MS��@��gߝ�w�vxoPԍ��8���� ����7Έ� a�`�4͘��q�Ϛ�vM�z�� Nu��	�v���	����H/J�˳��`��L�55��wWQ<�qi��5�Ez~:Z�v������R����i��8���9Y�1I�m<-�rv���i�����+��%���³�a�#��8�a�)­W��ٍ�ز�i����a+�G"����x2�i�}���i���8�w���O��9c��⃦XA!Ag�\Up-��T�d�RQ/�]���?l��~J����g16�fZMA��� ��e���)+]�	�g�z҇�vp3S�;�5���O�|�kN@�S����5���7$fE3�
� ��)W�ܼ(2��l �l�cr�w�5��
�)`k069T�����X��-�1Uxp���"�;�c��?J��4S�8k~,y�n���`�FDy� ����'�\���A�G���鿘�h~����$�lo2J5m�G�O��^�O�K+m��>��(#QYZ�1z��ojC�ۧ������agf�����8�!Hi��T� <ř;�_����"L}�E��pNy�����i�Fy��(�+��]	?����T�ysK��§Έ;��;>m�Nn�n�}:~R��|ŧ��)y^m>��?��)λ�6��q����hsz�{�t�Τ�����5<�_�Υ�(�:o��'������A�r��'n��?�*�hna���+��q3��l��,�G9�����#�L���
P�h��y���O
?l���ld""��/R�p���Eg�|ec�Kp���Ͼ�Rw8�4�_�xAI��j���^z4&5��o�q��d��P[�H}f˟�Ҟ��'!�h613o�2-^Nړ.љ��?���M2��w�j-���v�Z��)��y�~�����3־��קG����筋S�7�����&�Z)�L��n]�2����5�B�9�L��s���M� ,Κ��^�8��3na�Q��O%�* Q�s�T�Ӄwˌ�7�*0ĮAg<E�+f����>TT�k��sW?���	c�>�pD�8E����
!�τ>2xL!�Ǚ�I=��-�K�&�qxQ͘��J��"�)��H�N 9;�d�8���£�N`�J�
?�U9#�yT�\�.S���s�ʜi���`c�҉ W]F�Wc8��1�LS!NC�pJ]���Vv�I�캂\ڰE{"�ի�ǵ�d͑��j-�5}��1�3�\��>h��+e��F�q[y9�.hZ��
/V_�V��l�*-$��7�:z�����|P//1{TE|�6��6��*Gi�XbM������֥�Z{a��[��J\�aY$(��BR�lT��]����X~XЉ�����P"���-ؚSF�I��.1a����b��j����=Vx�hh�Z�.R9r��uGſ�V5y:IzA;sX~���XIR��h��0�Q�0qx�Hח�|x���d����CС�C�˨_�xMy�㕯U�g}�dS"��B��3�@��9U,f1f����ê�<������g@N*O���<������j��!��Q�O+�3f������z�ۆJ�w�FĞ��~]�����������j�IeJ.�ެ���yR^	��P������ּ��5�i,���}��YfR>����Cg�揭s��+>�o"<-��=��F����}׊c�#H�K�z�ᕥfM�*0�8҆��5������ ��<Ef��?-7��c��E��L��F�R^λ(�:��A}w�'��׎�8����LEM�}�5E��@�J��mru��(	�B�7��k��;
'@�ӵD@��Hqȭ`�"�9.C�D�}q���nDS��&�$&D1���̌��)(���� ���~2�?Y�M!�m|?�~9��_��ce?���~�X��Q�% �2�H�����&&�ǣ�3x��$�ז��n��w�f]�u�-5ֵR�Jy7}�ÛW�P<*3�Z��e���z�����t7=Y?e�S�|��2��5|F2���ά'�JOB�)#�~��!X����jGx�~�Ȃb�^J*#hG�^@;�a�wA�mxy�8����~�1�y%c+���I���ۤm�K�EAL��[-���=�QPA�՝�U�LQH�O+��XˠcS��c�:�\Rw�.g��j�쇣Gn����7V$j��p �i�-��dtTX�c�'@:�.(����#�Q2|vA)$O3������~u����I�|(?l���b�{(��i�U���9,b���0�9ӌ�qjZ�Hg��(��F�t_eB�Iq�S&1Ӂ��x
Uf��VUx�HwS&@]����: ੡c�S6�����fr"�2�ӧ�f��1gl��l�8	F��{	'!�(�IA&��-O�&����IE>�P٫�>-�`�ND_�� �cO�pڧa>u�р2T"q�1e�)>ę/�hLP{��dAEQ��*�Rc���&[x��a>r�1feҝT=І�"�)�c)9�7�f~sF����O���w�ϝ�����K�a�Ix��4؏�7��a����$�
�_h�W�s����{d�.��EK�$ڙ��늫ݹ�Nl���X��L����U��Z��&�V��Fd�.�h���ȪK�Ui㢗�=���`��p*25���EV����3�Wd!�,sp�X"o���g���d�L�o7����k�i#��gz��)��)�2W}!�ez��Z �b���S^�䊖n9�%Wݤewp8s��[r1��U��А0[`�۪q����p?�\MQ����
}�_�'�e���Ԃ����|���K��",ZJ��h��/���hi!C۠Ԃf)es'�e�qE�<H��o��[o�'�悖��Ϗ��^��DM�������~�睡�Q�!@rs�5��^�;�"�f���l�
��,3�ap���4��"W���@eu��/{-:���g��C��(X�V�躊����2��	�V)ɾ<�躄���n9"�=j'���T���ݽ�����pphBq�ܲI���sG~E��X6U�gS�(��"�&�MC�3���VW�[��,�	x�ˈ%�Ëqr���%�C��(e:��8�p0'q�NF�`���������������h9"]t�󭗾�J�&)Nv%M���7�������	{�����L�{�@a]�W�>��hI���Y�}���+n�r-G��p�9���y��4��������i����df<T�<�����=�T`5*XER �]���iD	�q`�]��qJ���O�f�����>�t��<.�.c%���L��!LҬ�J�uϥtO�dU�i�=�h�x��������������n����XS��ɏs�[+�%(
��nVz*<ߌ�ތX9��2��(O��r��2����,"L<P��a����X���#�j`xXs~ި�?ǹ�D�T��P���;��f�;��u�	���氼��]�,��&�5IV���T��/���f����=:��C��������&�q!o*~���3��m>�y��O-Bo����?�~Yj�����S������|����K>,�����yOt��$ٷ_kT���(!vL�������W�F����K�i�@�K�
�K�(�R��;��%�){��nA�R���ȇȧ8����lL��rJ���Tij۶�}�>�7������z�1��'����}t��"G������T
i�&Ev���4˼Y��2��̋��j��� ��YpE��˵ȓ!S&Q�Atx01��2f
X���H�L�Fڤd�����
g�?�Th�Q�T#T��������ǭ�|g�ș<d9�m��"�0#JPJ�`R'�����7��-M�;�G��Zr֒�d�L]�m�-�Ϻm+b�����I�q.I6<yaa�������\T��׹E~A"�B.Nµ������
�₻1+Y$�
4�(_�,�s��,�fYT'�X�4Q���-��D�wM����I�G�	#�    �\͹��E�,��E�RBmW��,RgS�+��S礱X����'sX������,�faT'�b�j��n�}+�N���fݜk|a���*(w-ae<Ŕ��hF�0�F�B�mw�~���n{�zx�{�o�R�߼l~�l޼M>������}&�%=d\�ҧ��{u�h�T�)l��瀲XY�p`�*��RF�aV���ul�����i��_����mg���n.ԕ[�b��΂�Zd��Q�۝Ь�ft��x�T\���<�o͔#A_6km��:׬��9%�c�H�H��@��O|y��f%1+�.J"V�����J������K���"2-wMT�'A�L7<g�f1�:-u�ru�����!)P�7��cus+w�2	�GK_Sj��!� ��:�Y �	�h�떻��:�P雇�����Y5����b��O���~�/,'�齆}m��n�{��?�FK����gE[DsԬ(��K�f|W���x�[�a�cڛ-Lc0�7�%1i�7��9����Z<ZN����C�ˡa�)F���8�g��t�ݝLq֍����ƿ�h�M.�O��a��֖���y�c���c"Zj�����H�zc�_r����F�*���D�f�4�Y �
�hi���;�aE�wy� ��,)�#2��kX��4�3=��b1F.'�"ezZ��d�!h��!7�ADJZ��V��l�s�rl�cur,R������#V斛U��A�b���ɹ@�5\�����,��Ë
��]����b	%/s����N>qɧ��s�\6��b
Llf!A,���*R$Ÿ��Ui(�[�S0Ǝg-Y��dth[�X0�J�Gm�*��,h	�ZP�@,Ubnj��H�(R�]�.�U���;�ӌ��J�;�s�� ��6�X@1Kv�^�/�q�(_�^�-�����2�������?��ϟ�o'Kͤ;�fo��vc�[��חCy�iI��@�Pf�a)gn���� �����``͍�u�w+�����̾�(B@�m��R�29{ƳB�z'��/s�iFI����)����>�­�~u��=T�00��_z���Jf�d������R��iN%��NE*�m���S	l~�/������#��mW�`ھ#tԨ�j)�����nuح���� A4�n�
�j؊�Hh��,�(�0����4��g���`@�O���xU�@������D���^&�A��s�~�
�wt �����"����+E��HC��&��ؚ�e��L���a%YJ��՞x6�gS|6�U,S���NU�(�䘑҅�UԼ-"!#u�No�R$ո�� >���Ӗ�a ���ߒk���N�O�}�=�8��� ��Y��c����QoA�������GQ���3� 4Ub������hA��LirY��� Q�**�B={�H���gQ��Z��$;|�rp�xu�	�|C�T}�qǘ��cLZp����X��@e^4F5�X�t�^��2o<�pT��A<S�4��Q����6��95�قr�pKAg��1N�#d\�R9�͈�F5[��XV_}�h�|E0��d,T�a�{57$qԨfҐ�@D�)�\�=0@��A	=�-��jd�`�#1�h�ą�%���%��^4f��l�v	3	ۆt�Ӏ:�H�Z *hr��W��h�Ĺ$Qm���!��r"`�"W$�B�3�8�S1�u�IL#�gP�A,�I@��g1�JP�`P��fv*GM�J�iC�S�� -��"�yL������@)�a�������6���D�h����L����5���;�_r7�S��?JB�u4�&w��5h̀_ҝT
{����a҆"����Z>����w9���6C^�C��WڎI�t��,P:�s����S�YhC��S?\�Q��P�F�TFyP�����*�#ϧ�]�V����h���ʜԇwZ�1�dH1E���
�,(�ߩ�x��?l��o������ew��J���e��h��'덶���c7Kn��<�v���+k�_�������y^�nn.~��8�)���jufiޭ���a��߭��_�[=�/�Z?�ں����^���z5�*��0�%��4�<)4秨\o��Ǘ�M�_eM�5�.?��$�����n��w�|����Xqc��$@?����vJ%2T�̵y�`Y�P�,�Qq�Ǔ��ɾ�d�\aK3�,�G2Jz��߶�������g�i�RTͺ|-�����e#/�7�zq�6ª������x}2y�A������f��Z�i��� �	7�	1&q4 ��a���2P;kPi��*�JU<k�+ռ
���f� �w�.H� b���I _F#&e%8(��L��;�M4,bR��n�0�ta�L^��(��7nk>�~tm3�f��E)	ok�{�/UX!U�K������8��8�O��b�h��pX�iw���������W��?�x[|��"� ��Q�I-0I�*�3#}�O'�l���-�X��"9�~9$���|Xi��cT�:jB�RA�hC��<x�������癹V�û&��RR7M��l�]z�C�H}�LJ\�9�Y��j=L��~H�K~A��ߖbg�I�Ha4M��,���R�=��%�,�$`��Z�%����K��};;8=0чp``���)"b��.A8g�_�dG�ǽ�s��KF��4.�Oq�}��0�Uc�Ҍ�n��zh6�?���y�qov�7\��K 7V]�X��C�xAe*,�^�H�p�U�,�^��4V(��S}w�I��W���o~�_�3<E���*dvb�G���Қ�V�ZDl����,�B��hZA�h���B4cr�
��:���4#��lD���(4\��B-Z	�Õ�Kn���W#��J�\��p��Z;�O�|�{�E����z�O0N����a�ۿM�^�����1r��3co��-���ޙ� q�]5��rs�<�?�)���;�|�e��sG�5��Yl^��T�.��7�o�,3- w�*R;��(�lǀ�R��,�fY5˪��*RB��UV�T9I�\b�{k��F5����QǑ*x'K|����т ��u"H��A;���EFS�� �֙�NX`�EJH���i��ʙB���"�'�Q��R�	���z��:~�k6�?#�%"��mW�����ѩN$P_��"yC3�T��Ќ�9���ל�y5�Le��4��8�y}��|�u�_i[�\�!�~u��=T��Ձ���nz�B��j^��I�1�j���44˴Y��2-T��\�z���e�S�
�1F}�a2n�bWREQF���yF��#�<��Ѳ�ᣢ���xm��5�1��8� �GnJ�$�bZL���AЏFc����"Ą���s�x�:|h�8֢��K޻�Cb#	�Z"�~�H�!�Y���i%b�iC��DN�((B=#&��v]�HU*ȸ+�D��r��h�G�CۭmF}�C;�R����a�:�=�*��,y`�@.2���^�)p��,����,��w�����s����)`!��MXS1��
���)��P1�Zp�V ��?C�vg�f�6��[X��程n�����0W��bkr��,8<AM����aF�VõZ,����K�7<���~�z�0���|ۼ'�Qmk�$�E�=L��(�����,���X��[.��&�bx�F.Vܼ?)�[-¤>ǡM��TJ踞�l.<��s'O����p_�Ԗ���e8�EĦy+?W�-#�I�G���s��'�c���<�a��&�1z�lm���fm�V�r�/hm�s�s�©���;ehM�U��(S��%�,�6���l��W��(+��@��I�*8'GL
��/����s�����2N�B�4�7�|����Ʉ��wŪ*Cp�&�ܤ�"6��s���T"� ŗ �W���rh
԰�5�����'c)��&� ��������#E�(~� 2c��;�p��(��~���7f��r�п�_������'���>�����mr��jP�$3�����wv�&��ݬܫ�d��3�i��E&����������j�q�|xg�,s'��٬~y^ݛs�a�z|H�%�7�-?%g�    �%�-�Z ���
G).�<<I��KD.(J�g�^��0�W�(����f�,C _K �,?���"[��7X8py��	f���"���)�Lq�De���m-��[�2R9Z�����s��z��Ϫ�	��!n ��D��ݦT���g�?��/@��(�����Y��n#�`�ъ6�ʥ�֢c�E��"�n.w�4�֢ӎ�Q��歿��>�+u���"M#��f���&��{���:��YoF֛��涛=��\o��֊dÙW�Q:n�X�f<�s�r³"���ٴ��B�[-���!���'O[-�W�<��j�br�tL���ա(ۿA6-��N�E��oO�u�h6ׅ��!�%�,Ѿ ��2�?��U�5V7��邨b)ԧ���q�4w��k�4K���J"��%j�bi	��e�,#g�[F�H!붛�Y��GeO�l+�8q&)�2Y3%d��!Sf��,ngq;���6�H�����[$��+B��)�$	
hPJ�7c��v���m��R���/o�_�����Y]˅�e8͸��rI�t��R�@��9�:��Y���rIm7{��]jDV}C�q���M���c�d�rx~9T>p�b�K�6����c��}|ч�`~È��w����q��ö��,,sUM4V��lB�Ae�TΦ�,g8@�j(m��}���d. T����Xi �B6��J1�YX�ª��b��@-7����s	��k���bҢX�hǡk�:��YX���KV��(-7����`yO!���Z��*Iڤk���r4j7R����8w+�{zs���u�3�kYe�(,�fl�L375E1~Ax�wY�F��>ֵ�^)LJ���X׾���� Gr��%�u	;�a`���KS�Oﺄ=��9wT�_��f�a���0Tj�����	�aT\tx��V��U��׉{���-�߯���,9~n;���T��+f8K��+��2{,�=���f�Z�p�o�gMO���I�}��X��W`�B.�0q�:�\A����9�l���9U7��Y<ϑ��nv��7�lY	��7ɣ-�X��p���R�ƍ'��kT�;œ���%A$uw<R�U)�&��4ed�0�Y�hJ��im��}u�uM.8vaq�Z[�u���R�q��h�@W����owX��Ʉ�!�
]S�Ҋ�`�b�"o�)����pm��phˆ� ��C�e|����Q0��H��m7��*���� ҫ��پa
R�_5�����]�}1��>\����Շ���a�B'Fݹ>�5�^0ۇ��}�I�k�p沯2b͏F/4F��)BtT�YF��i��@L�LN�eD� �J2�ɡx�����l��� L�� �����}.��SD�N�Q"2���r3�_0~����؛�n]��E�M��k�P�f�6�\���u'�k��N���Ϸ��}�����lp,� ��E�����F8X�Q�R%f�7��Y��y*�����������E���T��k,�J�H6� �4^p1�Fots+Νj90G@�@����,�%��H�������Vc�f�����|�i�
>x��B�2b��y��τT��`L�+t��y�'͘�*yZ����ڭ��'��a�ۯ��(ߟ,�O� ��C:����ۖ4L҅=�����L���v����y�����o�*�S�#_�6
\6't!��<�s�f�k��)o�@����
2��Ј�8J�XP)N3��j$,�֛Z���~����6U�S~��5�wU�͊�Q���i(.C:�x�b���#�c�=(�(��ݖyd�"S\=�R��u�
�Wx�D]<C�<���r��T�y�4ƽB�KROyKň���^�4^Fz�>X����\"Xa �
�F�j��ۧ����*��RÔ	Vħ�i�2_*Z���zrʨEfV��$j�C�	���0D���@S��V�2�k)C`�k��#���Y9�2��߯�w?���n% Ă���>b��T�`���=�ϫ���[��9����s��>PY�kv������/���ޠ�meLʷ��Mj;,�H��O��a����o����� k򞕕D�"3�-�y�>���P%|w��px�/޿�D��۟�-�n-�n��J���c5��Ub�f�Xc��v��v�'��d��l�q�dkc��4?�����P��Z>$߯��b �����xJD�~͏#��	�+Uƞ�7� �֯�!�F�����U���Ta���@���(�adi�+�r�j��S$��L<�����0b�e�
ּU�J����t�H}l�A���9�'p�Xf���	���N%��F��u��x��Ri��eeFw�L#c�Q��"��P@���)�ڲ��|`"Ea&��O�����<��U3R���:0Ԇrv6�)	�yC�䱒Ԙy3	^�يX����EXX�I�����u2,�L=���؊�ç��*�G���_�R�}���*���(�J��7�������������n�8Ӡr�X��Wy`�=�P1�����!�`nw�8	����'�8�^����� W3�����W��XР�,��2"2N��fh,���szʨ5ﰘA
�d�℘2�5�6���f�����U�������q��y�6�/gs��,Q�j�/���C���2��S�r$����7S������t/�\i��Y�פ�[��o�+��~d��Y���hT���ޙ�@q�\��v��C#��5
�E��T17M9���^���8!��p��i��~H�G���,�%���%��,GU.�
������W���J%��~�a������Ʀ5���^]�^��)NH�`[��ľ��Y��d�4n?��L����ZeT o�;��(:쎟�x��(䠙
�0ܤ,�\p�������)��W�:�%�ZG�v���к
Iw��O�����A���"L1T��c�-��D���V�T<�Z���낓��ݭ'͍�������R�[�?n�W���2M���xK~�|��i/��
U��G[Tr���Q����L��-a�fS�u]ƨ᏶cuE��Y�N��x��(D�(P1꣋p�No�W���4��k�����)��nd݉��Ht���d�^�WɎ���$����NP��Q�k����0��?�W�O����	*UKJ_��2hp@�z���P�`n��4��P0&A�Y����I�6�����T�X��l�8����8Jh�"b�PG����}�i��}3ዙ�I��T�C�a{
5�v��`g��v���v������J��j��j�"NV�U��A��N�i4m5���`�$��ݬ�~h�����m���nN��#�jCh�(o��-�'E��5:baRn�y}�,3^���Q}���ub,6�k�����J�wI��$�l�P����4�Ż�2��ާ\��-�a1����)YU���v�ш����������c�	��_�BY�]^�3��#��ڪ8ѻ��(����*�G+L���\�@�]k"&�MB#2�K6**��j�q�EA�JX�-9b��	�R�GfiO!*�=Xʠ�09uH�*�H��Q�%���iŏ�����W�
����Z�wNq�:[��tw����<O�p�p*�fϱ���o,���G��&�j�T�Č�g8�L!*R,
ߧrc-�ᝃ���/y�n�=�#�����_WI[����J�l�4������i�:A>�#XT�PYk���H��r~n��_��^N�� ����U��
�%,w�u��g��Q����`Ϻw!�=C�P�V��i�*%�@��j~W�l%���ж�)Nb�
f��J+����[dkS��:�-Ԉ�r����g��z7�L�!>$*Q�C���Ƹ\�;���Q\�{�Q�<�]�%�{Tye��Rw<���5���V[^F�1���C^r�?�����ॻ�!F�VZX�)JI��?O����P��SGO-u(�)$p5�8�'�̀����*��W�q]��ع���'���W`���
5/�I��Vv�[���71Nq;��yi��@    ޼�71���U�y�MC#w ��B�O��rYP�����q4�d(O�\ �J6�M�z|���>!���'C�3�*j�H�-�� kq���ܳ��t`�VQ�G-'��
D�\U"+:0z��F+\^b�
1r��1t*�{�K
�Xr�Ȫ]�gh�|��N�ٚ�!��V^�>����w�P`'�9����3�xA�ZԩP�c�5�C�/e����|���4���� �XFC���Py������8_�ꦇ:�)�)�&��e8Z`�R�=���`��C�z\��l_���8�xE7�X�¹��c���&[�}�`ANE<KcZl���f/�k���Ō�E��t�ŵ��~��f�?l_6��W�fc`�	<h�8��Qx�y��q�qp�	�f`1)VUF}�/D�h��˾��8%�D��A[�N-�����T��7͒�㝱�m�8��8�9�߭o�K��?��6�(4����n���O��f�hU�$��l���~����?4��˩�Ne������wk�M_���Z?��������g�X�����v�c�]�v���*�ռ�U��� ��[>}��ƹ
M��:����g���Ŀ2}g+yn��
�Y�5/��{�d�kj���*��r`�W!�<S�+S;^�<Ź����6���nN~��_ �O�O�V)B�3͐;�iV�f��R:�/w�� }��Akc���>�+�G�%(��4�4���b��b�K�Fw�_#
�2���B�|�c�0_ C/����K��g�	��d��f׮D�4����Hv�ſ2C��-@{����m+7��ظ�l��b&��i6B���]��ޘ�"����KK.�J�ĵ{�s��t��=R1�~4iSд4��L񷘥�,��F
���\��J��*�]�wjZDD��@��EFS��,fip5� f����[@��]��0�5TOa��Jy9�t��4�i �q�_�Ҁ�Zq���q�����0^WfJ���m�N� �������l;AC.G}bq�x�1_;�#3����1Q�ƞ/�^1��v��ؑ��(�ߋ����r_�Gq~"h�W4#)Ψ_hS��R���6�����(�(�4�.xD�A4����E�R�=�и0	�g7f��o�׶��{����9�S�C2���`$T�F��@��3��g0	����N��%9����CbZ�BF��4��D�Y�_��i��������a6n�ˡb��CU5�D��f:L����E�*⾋�FL���\;�&O��٥�^�Ecb�2��`�.��d��Z���\h���{X�A|g'aAqj��l2�g�g��x����pnt��m�@������x�^��M��g�X���;W+�q/��z�X����a�p]�kYPXׂM���fa?�q�.�[y��˓�}HK�m���;{�߻��7@�ןG��pPۈ�����������n��<�c~/��g�}��}yH�?@g���1ZP�*�% ����n[j, ��Ȧ�f�j,����Q�˲�%��NJ?��[ ��ۗ��f�����~|\�לJ~��f�v���o7��c�$��������[���w�Ϗ�[�����=#"%<�������wo�����������M����j��if���y�a�[��,�x������V�_+a ���vbF~�\J�f��S�{�M��S+��OO����ZF�v�����=<�7峕-�X�,��4�(*1J�e�����7�_��3nWC��3&�^�ܔ��LY6S��!�߉]�*�s�j9�w/���|�H��c��Y���;�㙠�Ojmۉ#,I3�2�L���'��S�D�������2)U�r�D\FQq�8�RU�g����xJU��ϑd�>�����vHk�I�����K��W@֮�T��A��Ŵ�+ �֯K�8���#�.d����S�0��T��q*T�1�����4�����)% YM2��~���_U�~eA��'�x+��j��|�A�n�L�Y�$����X[럢�~��z�<電��J�/�R�W�D&�˝~�a�ۿM�^��n��!�<;[��&٭���֜O���@��8�~�.�D�R���eh�?[0��YJ�*a��V_Rk�TQe�>�rd�!��
�q�2�FaԧV.�a�3Y�� �N=�����`bZ����o
�/tH6��/�>W���궛U�|]#�mF�m��U�`)�:e��P	2��E%`=C��<W�������&�0��]a;��9���0j����T��\m��� �ł�T�޹T�_-1NxOi]�E��량�����N�����E��ϣgu��+DQX�<��� M�=�N<9[b�_09Oc@�#X��t�|"��~���t_��[?_4AϢ�`��H�{O��Y����+u	�<������eѝ��p|�jm���!�fp�P?��Á׫%�)�U��_!�T��jΥ�2Rp��V:�E�䠒�sj�*t�KSB�)Ϙ'眜�Z��|F9*�X�k	�CvG���z��y����L��}�p���/���Jv�J�3g���θ�Ϋ������!ɃV`Q��/�i�k�?��Y���,��糆���^�k�dFQ���T��C���z��#nYk=AC�������ݫ#u����Gm��h�[�M^�cZO����:c�E{�>tNX����X�2��Էd��������!Ʃ�G뢦��<��އ���\�؝��|�;��u3�+D�~"a��q��v�H9�)�	��%Ʃ�Y;_�E��/Z!�3�:��Y�b�JZ�2_�����x�BRT�<�T���v:W�
9/�{�<9��1%Y���hN@���|.��yfr�V�Vo����Ւ����ڡ�@�yM����l���B
�QUT2z����;w�L`��_Wf�tμa�Ѧ��S�%CF�G�bsE^A��i��e�q�	ڹ.��R/�T��y4;�]�E��n�:O/����1o�ٗ�얎�}C���� �S�j�23;_��.�1/��z�l���4#��qrѭ�����U� �ud��U�Α�Ȍ���37��JgF����\W�VE�2j�\s|pꓚLf}S������R�\��OKE|[*���j���{��|�r�_s^Ǵw]G}�(�/���S ���?=�/1��H7�g`�uNQ���.��E��)N	�-���0��$��t"|`��٢A�*�����r�<�sK��+�w���פ~�K����D�
v�o�$�%F5;�U���8�YSjz�Y؁sσ�=�o�v�fN*����ߡ��G��`��8lG��sl`d%6g�ӊ>K�^�/���i��� մ"���l�!��+e�L�N��t�6BU�#|�[[�~~7y�x��-ʑ�Θ�E_ʧ���Ǌ����BJ�$��$%�'�jf^9{�7��=U�E"��z�����X^uȺ[�\�90],�	[J�=CW�Κt�ad���lxbap���岨ݥ)ӌ�[�����c㟠!��p�7?l����3�zP���)�B��ԏ 5eٗ�9dL/���Oj_����Q��(eY��57�u��󺈊#�V�^i��8�t������8���U�[�р=�W�Q�`&�����{�;�L��]�99�����{�����8�kR���9�ҵA��zG���oK5��y�/2C����u����5n�	�j�}��3.;���Fa�}��t��<��+me����i�B�ykq�*�-�E:��t���9��� ���޻�Hrق��/rX�^@�{����!w1���hV�
�bW6��beM=HQ���ȈH��LK��GGx��!.�duW�qssw{��N�t���"�2��%J���8XwB��S�H�nA��XIf�_`��I�$c�nx"���B(R���Q\�k5#�%#e�5�{{��� ��s=�,I�E��%k�P1Y��܀i���%d�?��C�����%_l��}���x�W���^�8)���g�;z����VKm;E��1��)�\���S#�^��    I�PK+���|��ԙ}�cP��L����-�U��,����י�����ڻ�8*���3�����b��-J��>s�Q �5�j�����/�
�UTT�L��(��*b/��ܥ��x(�=��X��*�kYh`�ԧ^1+���m����X��'�YUze
+��D�Np���>Jh�PT�@���&�u�M�d�)6-��k>�j Y0z5l�F����x��<�M�'��g 'g��Ms�[����e7�8����$c�^�LDM١Y�9�y�Ђ�N�q~��$6��B�}�ⷜX��^y��9�ά�ri\QJ4�|���>����lMU�����#��y$�v�J���H��r�/}⭩�zEqbQ��쥑u����xK�W'�y�	�cq��;�m%�D0�j)�tl�	��4E�h��-U��9[P�O��'�3ʱUuv��T� �>eO�=�����Q���\�ffp<��������9u¥x:�[T-��*���sR�U���gׄ[PTd�;H VFICթ34d�c�-�t7}(�q�T�2����#@�44?�J��@	��"���qe������r
��e>��\Ф�ָ:�j�V�yn*e!al���R�M���z�J@u�=P�ɨ�,�.ı��Z�-l��o�[��HU�G��b�p��2sҀꖞE������Ǜ�n6�-�=�1��4Z���u_���N]-KQ8���o��M���<�����.=�n�>~���G��z]=�����d3[���� mnlO(5G9KJل�Y�Z}lg蹕�mf��z��]л��?�|��bE�p�d�uX�Ãb�b����� �Tisv�O�̇8v:CaW>��:�h�����
���U�Si��w��}$6����5�ک�3�"�-��jҦN��>\|�r��|��c��_
�(UxV յ%Gٻ�ѻK��΍3KӶ�v�īKgF ��1��,d��ʑ��_�z-��^t��S��7�:0B������Pi�;�2747�C�nT����i���%�����E�T4Mϸ�T~	\�yx�[W��T+4c��5痿aҘ�p�����n�q�g/=���P�6{����M�ۀ���-��}C���R����Z�,�G%�02�}J�P[��������quPj&G���Y`��y��K������Z+]�58�X~_o#�,�R��� C�V\�T㪰�ϫJ��1�݋sY�Bei9����P����9�QG���D1�r~)�?�0I�>Z0��=58nA���i�,�|��W����~��μ�������,����������6yvq��� ����ӣh�ԅ��m�� �`*��@�I�����&K�w�o�ю���@�0ͤ���~V=\�E3�U�8s�Ue顀�٘u��]��� ���3Q��Y���A��pI#Ǯ[+T�N;Ӻ�<H&��2*�N�����3X=9VRR6�O 23���Z���F7�u)6��P�v��]-�����Υש;TH&{�1�_�q|M^d�1{g͏���xO'��Ҹz]oL��ܜl�M��B3�s���7PfVׯ6�3��UY9���hh=�K�j��w=���_�����i��\<>�?�n_�Jj�����{X����� ��.n׫����e�����K�����y�Q��E}%jm֎R���O��_���&N��9?Ǐ��9�K%���[-8�8��r_ٴ�U]�l�R��p����.�5���6�IA%��xt�s���I����%�Qy#�F/���L�˿/q�J����p\o������
R���#���pwEps��ɽy=��<\��u�j7]�kU�d��..�6�� ��J���y���'���آ\W��K]�/�F<�|����V8&o�y��ϗ�%;b;H/E��*`�З�I'�殏�I;T�E��צvU���Eb���)�F|�񵉄�Q׈����e�j�n����,�Z\������ǇŻ��F�n�S��DޥJ��ShfjUT��Pc��F"�܂��)�*uY����x��"��J��ܗ=rO=�T�F�M���j�^��� !J>�2���2���Z;��{m3�����i1��)z@����m�U	�2 !%�4�u��ٻ�)6�R!���?tv�x�l�w�ghbEH��z3�{�K:p%�v�Ip���ޔ7����P��A®�T���5j�E�+�ltf0=�6Sܛ�[��g�֛\L�cրr&���`|9aQ��qU���% ��j1��J�%�F�.���@��U{_�
ָ�6T���P�(	���7Ǩn{H���|�'	@o	�ea{�a��jw庥(�ٕlm��s)��l?�K�R�i��|��y�/_/�˹)S��߭>�Ɵ��cg��K���V�(\˺Fk��Y���QG�^o?��\�b
5A���[�i��Nk���x��"P���7E6�������ɳ�Z��CC�I�43���}�]�,G��P�C�~��jriDQ���}�j�C��(��m����A�i%�ݔ�>5�d����ߥp�E��ù;�v���M��R���{F�����D-j��[j��Z7�*t*&}�Z�3)4t�9�9�vl�FM�S���d5�iQI*A4�����&�K�#"R��}~9�d����ޣ�A��.m�=��-Z����@L�	t{�{�`ܚ���$?>�N-I*uf�Z.�
��x�z�"������
���P/T���_l��OT�?�~Z4����a�r���j����;�	�?ݭ��O=/>��Vw?<,�����˞��a3.�}�ۇ�?���an�
e�'Y�Vun���������!�-&�(!� �$��L�j�O����&�(�"��b�I�>�*z]8�&�C�E' �n�"5�ZT+E��gm�����U�z�{HvG
\�N1��
%|�I о���0�*��Eٵ �5d�"�ws6�	�Z�G�x�S6�䟁ļ��l��Cg��Q�XLv�� 4`6YO���QLR���܆&_F�ɳq������`9�VB��gC��ʱ�T�Og������̞�n�h �à����kn��1�*���L�n�6�K�@�/z�J��C����%ۛ�����@��&h=���~�#�Y��"yN)R�_~��hxQ��]G�|�{4����~\=���!��Ow�my��r�/7/��P�~|}z\?�߷1i[���S]��>���rr%m5HI�,;]߁j�ߎT�5�nlj�ګ��s�+>P)j?;8G�}"�����T�"m��S^L�R:(����,��us��/�O~���m E��P��5�ז�@]g��j˨Қ�c�\[�`�� �{T��Me��;��O��Ʈ]kT���Di�̗�n+��B�~�]�;���^���,.�	T��V=��4���p�n�\�pg�Δ�bs$�1/��D��ܹnno��_���i�����)�Tڸ�K�xdE�ŕ��w\�vt
U��[I��]%C����1��se�*tK{��.2��fA����{1��	����r���p\?�'��x>�#RG�?K v�$���������u������z_�Ug�CG�p�"|%i��v�!Ys.}�\�˻)�<}f��.~�5SL��5�c�ʵ�X4�:I�NSJ+ۗ��'��i]W܀RM�ə�[{]TU�~�*�Q�c����d�h�6B@4�(��,����VM� 3��p�v�AUh4S�9Z�uR�(oc�3�s���(4jZfq������ό�얇�/%;�����<I��#yZ�L2"u��^�|9�u��K�?�f�l�r�`�$	TV�?[<险�瞣�kŭD�g��ӎe�zv�l8�j2�iܾ�X#����M:���%���0��Qڭ�$gT�n�ȼ�
�#D?�;��E�[3��\�g�^�0����MC��&�7��Ǜ�n^�����k|�.�����oy^<�^��V?,�ɽ�*�"X]�/���P�6����ٵj�Ee��������'�u���u��bN����������_�~Z�[�?�-s�ٗ����W��    8�s���&*�V��t�u�h�3�I��t��&�"��Si
(�d5Ɂ{[SW����'?p�+��}���j���������������7�����u~s��Ǧ�f'[�+<�x8�J�=����W�"�B��9�AŪ��~�9��&k[ɘ��l@�mu���"��s~�����b�ݷ� ��i��LV�o;0@Rb#SS�t��l�j*����)�=��/�iP�n�t�fI�zD	�O�����O����,�~;�o��d)��+�G�>Ǜ �{#9T��W*@iK�q�ab�i��]CV��^`��f��K	L;w�:�G���t�/���6��4�J7��Tj�~h�_���?�iH����]75����w�/�B��7�'�5��lۜ�+P�Of��5�w	S�:�?6�l4�����{F�s�2)V��W���3`)d[s��>S>�=Ւ��� "����αŐ>�$�Y&3tҰ���l��I�r}�Y�d��K��H�}��i�N�	}(2[r �wW;��� 5�l�>#�ۤ�J�t;N NNB�#i�6;ב "9R&��"Rd�5�O_�����~>����>Y�iS���ͤF*R���D|�ýS�E��n�
ad�>z��!��Na_E��]����������{?K�>�kb�az$dh� #�C#��"�L���{kRo�����F]�Y�wͲ{��b�/F�rh9�����^��,��
�N�%Z��MA���Ue�$�֑e�WeӁ�l	��UhpfbFv:����M.�_��i]��.�UI���)K� ���P������@k?%cv�R���섋�M6��D���N�&Y�t�ý6P�h|<���mѼ�@�Pp�I�&�J�	��)��l~��)DT������9�&ۦ)����&=9]�������[����g���EG��"RD���>�4�(5�E�6���3�����d��KLZ���HJlր��Hz����s*՘ �������H
�4��}=��P�ً���Tg���R�p��r�y����G�*;o��o?|��^���.u�rP�P�i�uY�-d߲s������#P*�
�����3���̿{V2ם+TwN����CEKO�S̓���~��t5Of�+��6:X�{x�P�Q���ةϺ�&C�����I���f�]�u-�z[�ޓ+������8-�e�+��F`�����ù��JʻvE��un꙽���G7).�pM����tF��\JY�
��)�$ ��IN�6�Z���2��+ב�=y�v�{_l�ON� z��2���>��Qc:�
)�޴� �<��'�Q��M;	 ː���
T�V�/Rjsv![�B�<?=P![�#��s]�������P�������}Ht� �*�iP�e���qKc�֪��	6	f(�Dk?E���LS8Փ�]����%�#ko)5���3��M���'��Y�p�(���d�u�[��"yV�Z�����¢m/&ٚ̬
e�����[Ӵ;z��FЖ(&z�ea���g퓿�iw�ܾE������3m�;�O�w��kJ���o��D�z�̶���ڧ�;zދz���3!����H�i�Zqh�5#*x�iF����X�����s2��Y����!����R ��E-���4k@Ye�7=ň)'҃s=`���7Z�S,��нV���D�biw���P��\��h���5�r%���@�g;���j��/>Tz>T��N�-�%&Z�Ю(}߼�L�a��|d u������1���U���e���z)98[��
	ڻ2'&�s��g5rҁxf��;Sׂ
<DZfb��}%��I��n ��(0"kZm+��Wv"�8��F}� �͗�¤!�(�N�gK�����p��Y�n$�J�J ��ϕ�� �2�{�j�Nȕ�&7M���edb;�x�fO�QϏ��� +��H#�߃c�����d� �;��a+�W��ɘ�`2z3���`#]A{Z�r������L���?fd��n�/Djy��4�R�a��V�5@+�_�⭑�{�]����ß�UE��E����-�nu�|O�\�gQ���]jY�A'��z�R{{f���`�����~h9��MOP7N����$G��f��7۷L~���ހ‘I˜�;������
�T|�����ʄŗ�� i�ܺ|�t|�++���'o��Q����d��[�/�P3,>%���aԆ��x$;X|J н�.ٰ� �򻶊��f,�S̥�2��5�{���	��<�,e����0���#:�_-<�'����m�Y=��>-�au���xf�d��r9Dx��Ś�g�5dh�ain�ġ���5��i�cUԺ��6r������¥�%Ƽ:�-d��7h3�T�8��� K�f=u��V�^H�WW�N{.	x����R�
� ��GުY7�渚u��\ݾ>5?���������q��xY��巋���t���)�k���~|\�|��y����d���*�7���uݿ��y��=��Ò_VO���w?��������}��7
hS(9I����.���V�'�4␂����Z�I�]n��M{d��� ٥8���P	�g���;2`�Q���7��p�J���,�
Z�Y�I��]�u���X�s`��<w�5d�MI��4L��Z��W��%s\�?���.�1�ϸ�M=Cm�L[\���nZ��e���ᒚ�K�tv[	L��2�|��j����hJ|��'������I ���h\x���`�V�V���d"�B�\B�1�Y��Wy+k�-���F�72��D_(�m�n?�Uz�
K���1O^+*r̳+����:�
h�<�R�˥���*C�ն��GEడWO/�|����}[T��������3��_����nlږ��T�ç��wˇ��������>����俆�*n7+u�j29{}z3	�T�>����
	JNRb�,M�Qӻ▼Ę4��D���$i�7l�N�UV�ӸkGW[(�0d�H�����j��Am���ϗv�Vը�� �]��S6�� �{L��noʇ0N�����Ac��d��ј����=�E�ܲtF���%t~���ی�ܝq!9dTE	!�O�d�MV�}�};;�}0��-���ai�6�l2㟌�\���xk�dN�	&c<�/PLnͅ&Y�~�C�=�1���egN�w�d���5���������|_��1��^p��c2�A��ff`u2���
)a��w�讟V4}�W�ՈT�X3��4��l����0K���@= *r�qwB���bu���Yx��S̩����W(#�Ü_l�c��'�/���&I�m7=��ëOa1ybmchbm[�3(	:��|��x��"��<����F�7�ET��R� ��¢� �`��	 ڋX{Sa�P?	ޮ�R��&;2f��t�-����3NM�s���Y� �|e�.�& 5�h�gz��AǼ��ɥ~�D�UЭ��%qo�hYA��&�I��֜��'����Q%����i�fm�(����&��[|��W���`���V�w}Ei�	-W����]OQZ;S�_��P
�3ד|���
׀0Dޘ��.]u@�T�Ę翢������M2�'��c8�De�Nz ;��,��Ƴ31��'ƶC����[�� ���G"m�2������H��I�͡�����p�'g.c�ղ4�L�w��'���[��V%��A��%��s��GR�v��c7��&�E 6��Z�� �t�B>�I���~�4ؘ��{f�$�M�A�"+$��~�j��
������m&��\C �D'g1����p0'�d����^�����[�A���Cɘ�;�Ys�f���e`7)��>����d�M������>4�A�BA�Zw&KٛV#�m�f4�`;�cM���sop���e�_7�":o7�lQEXF�{�{�0�LH��f�m���^P��:����k�u.:St�C���E�C/S�T���������4��Z�-<�ϥ}p��bQ�����7V
]h�w�����~�(Py(=    =���L[��k�>ہ8��+$Z�I��|5�}یt�mF�"�.:P����9"+���k��.OZe.e��5-W�A�}�lPՙ��\'5�8#33�s��ณZCM�'�*��
I����,D��`$�"ンn7��oAC\5X�/@w=5��/�� (�𻷠�Dd-in�V��nY�䑔������ۂ.9)m{q���M��<]���4������c��D{�=�߽&�sS��}glӿk�*<&{*����rEҗJT�U����U�};W��P��#��>rr�Z:��S!`=�i�-�k*5}J�O˚���[PD!"�Ή���� ��u�/�0ȼ[W¨ �<�}���U��R��J��JJ*T�%�Fų��5�%�m���ʳ��]� -BS��:;��^ږ/J$˗��'�̀�'7���޶ �2g�.Ql 	�9.�%60���R/���5�}Kn͎�����X:01��~�hą�%���K�/��?S\`���*��C�����@�~	���I
�f��Q�[;�{�5Y"9j��a2wl�3|{����������?}s�4�~[�=�,��d�6��Q���K��e�E̛���ǻM��-�>/nW���c��8`��NCEs�c���Z|��ltP:�1\s��p�)�~�S�í���=�ޤ?�Ks?7�T&�t�J>{ Ù����A/ŕB��3S�n7�'WsdUU��'���$W�6_%�2���e����dP�1$Ki&�>�#k2<�μ'������i3^V�x�㡲^Mx��M�ֻJ;���J�
5j&�4L�W�Ѹ���0y��0V�v��<HC��҈�}�WZp�M��� UE9iۓ�H�%ɺ���}K�ht�l�K��x���%��V�4L�{:�϶����5+�k5w��EfO��k��w�b�̚���Uղ�D�d��/�5�l�m�	����6->X�u �/���;�k_��*^3��e��?���]��x�1����T�:��}}�1��D�ῦN"���̊flF��6{G7{�}/3����G᤯�H|ƶg�Y�pG8~�8!fz����*\� �ȸQF�Gc, b�*ֶ�[�_��*Ux�bSk�вo����z�xOÉ#�r^S�EI�����<�ݽ��F@���z>�DY�3B���VG�g���r�-��<b�D�3�M%�j�'J{�hVMS��[���6p(�n���9�̔��=#w��,@�����s���~z6a=��@Ć�*Jzʵ�U���Wfw�=�{�.���T���tp���+p(�y�i ���뮤ԭ���H���M�X0{�g��h���c�>�Qz�ۚ���4��.�@��R��:16�l��Y/:���N T��n��k5�QF�� +T�C$ًvS���y��@wG�12g��c��]���J�z�V�;����d�&w#�m!�$�1��ؗ������OM���5�IQ�����p�e�)��:qͿ*�#�B�%8�z��=�rz�������l�����N���MЃ�()���ɻ�}�W�.K���f�Y��x>U�B��f�r��>�^��꾍���ynUTj�}���	m߭�&������%�,���%����<��	%m���a��|��)�<�5�DYu������5ƨ�0p�>���ߪ@�͆9};wh|�o ����;|+�,f9�х���w�v������L�n�܈u	��j~Tjln���@HN���V�*6�G��_�,��u�\�2�l3��K��I^ۗ0�����s^UX�b�}	�f�-�w�E�n۾�I�e���)*�!�l_¤٢�'������~�͓T�忦,$J��ޏ�yb�M9t���F�l��`��YJ[�wv0� ݍ�dKP��E$v��	�+��7���v�A5�r�R�p�U��Tv*7���a�3��zkZwV����y���%�9)i�ꐲ�:؏ҟ�fh�ɫk2V�9I���/#����\Id�@+$L\��DL?�y��Lmj�(��<�}�U6��L\/���1���̨g��.�P<�<2�,@���39*�B��M*�jP��$���U� �����M�{�Lr��Qt�ϼ�=�9���b�ג�ف�pJȴU���ӽ:m0BƧ�
�n�h�G-�դ��GȞ;�����gC�`���PʁKϰ�2D�b,��K*8��Q٧r�ID	�ʨ��;��`ϥta��{Xf���q�N�v�j��ٳ?s)H��Bn�e��8�9�}|���̎�n&B�n����Ba�ٯ?wl��a}aJ����DD@x�,�5e!Ph`��gp{8�b��ƚ'��{E�����ƚ'�=����V���?��!�o^_>��_�p�0��ԝ�GvY�p��lу��x�������LH��}�k C�Ɂ��$�R��k���%Dr��^��6b�}�^&���tP E�o
g�Pə�Z{����[���:90v���>� �.�e�`m*e����-�,\�iu�V�ε-tJ}),7�����z��T2�,�]lG�N&��Yv��k�<��sM�`�P�$RU�͋�T��Etn��;�����a'1_25He�4����5
Z�w��h�'��c��B^����z���qe'YrZNx�n�>:�8�#Y?��s�t�O�+��������C[�	�������ʹ,q��Q1��/С4~xy��#X ��@3k`�
-�B �}
�Q ?�<ϭ
e���(�'���m0��hA���I��Fs��f9���e�2Ӌ�����a�"o�Ι�藌a����\�{����[6Qk�0r�ȳl��Bq5�n�0����1��O2���AՖU�M6�y�d��M�U'c6���/�>yE�6x���;#��f�����&��J�֗�&��r�Rj�a�"F�G-15������ՂTi-�����~�����~���a�����˺�#�o��/?�<|���r��+�.�fY��l������Y�O������&�o�\݅e��Z��ꁏ�C�x�ws~�Ce�b�г&��o"�uĔ�3�,@�#���8��&æ��1�ڇ��d	��vp=�I0g\Y���p#��أ{<�;��k	Wy�|� �)G"�b�f�&2٧� �P�WLy�ѐ���B7�,��Or�Cz�UbB�3~����P��5�zP�<h&���lD�	���ٻ�E�CL-�2p2�ԣ���nB0~ZW�2j:\�H=�4L�FW�B]��0�����^��l2{�PB�$k�^Pt���1�'>Н�sʶA	u4���yw �X*d,�|Qf^�N���=MY�M���PB/�Xʲ����s�}�+���wL�8�cd�����^�ߚe�G���)aZ�8KN���u[�J��F�sXe����ϚW�W�rG�|s2/�;���Y��LFg)-��J��9�7��9"&Պ�X�]ˉ�ސ��p2��uw�FLb��3~:�&�,�{�D�8��b��/]�ʓ`<�_�,-��hrTQT�Sl\�vd��NR::���P1��Y��Ϗ�
���;{8w|4�bGC���pN���VWT�Bb��Xv.���ͤ���?�,�ժ��y�D�������N�$A�.����9�)j�"u�3�G����j�!���{��,�y�+,$4Dɔ|�;��nW@X�L��N3 <����
W��sF�����\֢��۩�e�.�.\���r�G�Scw��k߂�^��W��s��G�6*�Pᛄè6T�ǔ^�����.� �+0y�6�i��@�G25(���≠G
^�[%9LL�E��5G��h���oJd8�|�2I
��ݝJA��cC��"Ǻ��(w�I=!\��)��fo$���tr:�o6��h�%���:+����<s�K|75hw�=u�7�s%�7LJ��6dd=�'R�9o$�,�j�|H]:P����:����������z%S��H�Ƒ�xGc�xk��n�??/��`YQ�n>��w��[��D��c�o�v�eQ)��$w���ų�kD���������G�{R�NN�ڜ�7��    w�-�Gm1��Y���n���W8Ai��d��}�AO� ��x�2Z��R�A|�k�9���a�'!㡩�T�Nc���c��^�k��
�LR�9b�T*!œ�0��R���,W��jS>)l%�G�M>�!`�����}�5�z�a����}�V�f���
� ��6��n�����=�Z���D�c���W�z!6�r�����\�j31,Qc\�Y��saUH����3�'��4(K(r��|Ze_!&�H�aր�H뀮�B�4��=k\����t(����&:T�ԢE���²����I��&c6O�����)�����<�i�d�޽9EּBk���7��݅8���4�g�N��0B�4qEjv�@/gR�:�YLm�p�tŔ�g�u�sM](P�(���:d�0NΞ�-�;{P>�j1����N�݊YPlP���Pf;(_
R'8gB��N�Ҿ��M�;�>��������T�#���}
�پ�pH{&B�B�����6����qō �L@0�o6��bB�3���ᄣ7&<��q>�:�iD"v{Kg9
H�O_�	:�!ә�q\�t���{#.+r�ܿ~��_O��	����l��1�l��+K�6�ϳE�纮��H��fhOkF�Z;�p��,�,�9oU�9o����b�jF]�������L1f��Ný!&4�ѥr�G<x�1�L�0��W�Ja��V���j�J�ۣW_�����g���T����U
 �X���e��2�,1��c:�{�j� ������r���`(��4����F/K_(	ײ��s��`�%[Z�=��b��q��_�2����Sll�V�U|Ύ��*&��-����-C|�K������af�0+B�0ۖUZG�A~��_=�}�_��~�~X}��y��n��o�]?��x������]�J�кG�A��]-�\���h��+?=��eg>�5F�}��L9=X�ǈ�*��[�J���O�a3���n	`���OU#���<=k`w���j��
����w�Úe)��,|�6O��$������N���J��I�R�)[��*i1�dZ���]��yd̸���&+IKY'�E�:�֗C��t:Ƴ���5�z�|2H����U"o���5��C\&u��8���X&g��K *�ȳ`Ɓ�'�9��q��p<i�#U���.��hXQ����mUfZ��;^ԅ�4�����	з�����f玥��
����r�( .	1��ܨ��y�" 
����'�}����2�s��	0�y�.P�:&x��=��Ү`�e�����0���L	%c���>�![������R3�ex��I-�F�
��F :�Q|�)�����^!��,$P�HZD<c{B'V���K*���Y"��ު(Q�[L=c{�{���!o6R=�,z:�YJB/:��Ε�Z��p��BM#��}>�N�^�m~���d��u_�N��ss��*]T�Z/c�N�p|���g'�%�E�DeL�=�#wT�K*���W�ޞ(-E��O�dh�$���0���P[�Z�bP������Ƿ��-�?��]<7_�����/�Դ
������֨-�THOs]��s�.h�aޥ�P�Թ��w-�G��x��]����X��7yI�w���T�θ��{�g����c�=���e*�f#rR'<��J{[��C���m�}���@�)3)>k`����j0}�:�L��<�*0IIӗ�k��rt��,���&&gZ�a9���p�ٞmbsŶO��X���2�Āpt�l�<��0��F�n�|a�pp巓�ST�PH��m�պ��I�
�7YvR�<-X.�GCk6�ژ���%*���-�责�Iz������K����Ф��b��3�s���n�h��@����Პ�@�kR�8áI��v���\�]d�d�p���d��8]~�� ��un�E�J�{�)v��i0[x����vV�f�l����wd)*�ً"G�1��z�8,��^�.�]ʫt8���3o�kc-�p����a�L~�<��Q��/m�<����8z�����I���:��#�sŖ�Q� ����{�H�gZy��oUT%��v��n�1F\�	���J�T��
��vA��-�hv�禰zoU���rS�E��-��:�'l�<+,��e!<�/���������1�Bc��R���������F��{�VKY���t�Ǜ���O�gB*m�_k0tr`����PT�f@�L�G_Vov��e5���p���+��cgր�&��:j��!\�N�RlWBÞ�p|&soT��Dg~�����Vbk�*��]��l�.�i�:{{��"���0y����qi�*�~�֡�H����	& �ެ�Sm�ԣx��V���x7�V�.�+0{ ���ho���Y���B��� �� M�ҽ�O�do�Op%�Eϳ?�7�s���*&�~��� �mX_�,S��z��i/\WH�v���������������Y��d-��=*&p��>�	���OO7�,�����w��z]=�,������������o���?~wxm$Z���~�k�p{���m �+�8Ohٍ%-���]Q�,f9�6E}%*�z��=xs�t�)@l��tT)��
������f�"ۂ�������+��0Y���z!���e�m�D��]�6��?~�z���z������e��yu������>
�C�����'��~ճ��F�R��۳+�)ٳl�ز-�e�^���L1��oUX�R�g/�|��6���u_2_��+��' 1ˁ�(T��e>t3�=B�c(��\�;�e�R�����<Rg�.�I�ՠjaU��w�5&{t��T7ݹ�^���ָ���[�i��d�f���ͪ�哱�}Z���R��Xݣ��,�D�綶�p��I���]/5���i�y��A.s1�Y�� ��r������|����GTH���g讧�����.u�O�m�z�#���0yo�c��4&K���>���b���>��^�R�Dy��5�f~@�>R�<��.�j�K���/�@6J\u�5��a��;����������M�Fc��3�sW&�,۴N���H��4.��hQ�TFO��>��mW�B���g��X�T��^�����ݐt�G:6IA�4�'ߏ�h#��0y��[kd�D���t-Ӟ��;kN�Wtk�Π��`�lo(S��5�=c:���H ]���eY���\M�Y�������+�=k|��ju8$c��b޳�=���ڜIoj��
��	 �p]���G\bz�ڃ3&d�EG�ܣ���e����ţX��89�d�Xeb��3��]pb_nQE��ii�S��`�69�J?ܬu��~���i��O���scƧ���_��Y�Y�v[Kt9�<�f���GX ���N&�7Ro�bv2f���9�mL@]}.��.b��W�UyL�쫐��)�ơ�7�)3�����D�Y�~�� T����E�I�!b��Oˎ'�x}`<� b���E��q��W|�Yt^�R�EZ+\A�Y�5 x���u8`����}���_L|ր����h�+��Ŕ�g|��)\�H��4.l��)Jo's��[�ݘ(�����m�`��P�PU��Nc��ZN��[���@�T'��z[�)!�ƺsH% ��t�g@�p�{���K ����{����L��L��c�l�C{Y$�����_��0hD�T�N#�s����j�a_P�jNJF��VtԐW�d"c_�Q�ʃ:x�(����<�p�9�-���u������ƥ� l�#��#2�[|�cGg��sܵZ
Q8��̔��:}Ӡ�4���g;)��꘴��d_ P+�t��bt2���%��Bs)N�{NMZ<�/��)w�z1�_���Kw'�N�����j����N#�p7�/���w.(�A������p8�i��dB{���7��9ACƣ��.��oa��(Whx֙;�f5��w���J��ޕ��'�V�Ei�Z-�*�    ���\i�Y{����)(�꘮�SB�-�l3Z:&�<c8w��ǜT���ڰ�i'���f���k-��̵�o6�LH�4^7|�Q|�j��\�!IC��Ng���%9��A��r��"����0K�&���p$��p����1��gZ�8D|@����gO�vCOH/>WVP��1�]�LTbsl�ƣ��/�Io`E!?S��������Cw�ܽ�=M�"P��Eq/����Qt�O\���+!��$�g�?\�΋`S��g}�(K��i���+yi]	e�i)��J{7f�_��E����;�Q��C�Pw�A���Nc���A�z����A�?@�I��(��������N',���3יwEZK8�ɕp������ꌇ�L�枰~^%�B)ȭ�DQ3��B�^�y��ou�����9;�B��7�4��
8ߑ�a���� ��I�s�D�V1����~ܷ���A���v��bwg9lΘDhv��	܊��v̀�ZXo-�����M�;'���~׷�CP�U��S�B!j���b�ϻ����^��͡���U�%6��5�28;�ɬ��
��sy'�[z�Mn�ȓ�ܝ���Y���]$�ͤ�z�M��U����~g<ߗ�C$'�υӀ~��������T�|tr��.�Pމ��M���Jp[��p�Ypv�А�����}��#�w�"���QϨ��UMJȦ7������rY�G3��b�Wxx�Z�ix;$��E�z�=
��������$�Њ	���9�V4�C*��G/��R��|��l��[�q7�Z�iMJ��L�]�+$"��r�����z���Tqg�*�I���;{8���TtPM�UҘ��Ri��d�l���H=�4Vz7���
�LP2�~�6֣QZ36��@kД�gYiM�`r�S��lc<T�)���z�5\�����hN���m�S=6U\ �W�˔��z)x��vgNޱ�U�Z�HT
��d�3�n�C��W*t�z��2K�
���GM��ݖK�4m,��lb��3N��	b-����� �|�$��18��:�m��<C^��`g����Ǖ�1��B�!]�8>��;tnNn��"��:����s�qx�;�Ki߸�#�����.b����FLhu��P�ƴ�b����ZA��q̙�����cJ����]rN�RG5<�ia�d��>UB�=O����Ҹ�D�R�4ù�ɥ��B#T3�N��NR.5�ɝh�@���,Yۀ�Z� �EN��.#t'j��,�E���C��Tfm��n5���l�ړ��i��n��^j2+�~ʹ��u�Nc��vx�t�p�i��:t�c(M��ːv&�����ڇ�J���I%�4<���(�N*��lp���eYx�<*K,]������f����%	h��|�� 2x����M�0-��̳�o6�S���%��� wjh����=���b"UT�K�]�1�!�4=UA�[�!4ǄTg��Aߗ(:ev��9��<zp���p��.s�x�@�:�P�G���T�xt���s Z���4�i2f�>� �Nj���]_��E�Tc�i؞9�^��7���ʈB��	H��v^ҭ��"L e~�8��n��2-9[l�f;9�+�<��r��^����GΩ��"&)��F�`o �ON
.�ar���#&�<���V�iq�s(�y^��笽��P�:��9{������q��6�:a����:F�?��p�p�r�~8l�鿮??,�^�0pޕ��5N�7߮�_~�y�����.��
���ڿ��y�zy�[���]<7f|z�������[v�q�Ei�Z-�*,�J����7�˷u4ƐPϏdhZ��>�=�=}5Ⓤ�9��[UQ��WZ�5{��xA�xA�7�/��߯�<��[܋�kN��k��?<�<?��~�?Ric��Z�!�c�M_���5(���2��z��	��fKUaF��X^&ßE=Q�ĎPv���U��1)�q�;��P�2~@��O-�r�1�۫ݬ�*?��m?�Ce�p��(��:�A��A��5{ktLyvƮ���Eg0�����-,u�¡L��&�1w�bw<T� eaӨ'�wQ	yMZ�5�g��O�ڪ��g1G9�	H���n�X#q�U����>)^���� hq�/���E��Q����Ӗ�'��,{�����7,��织���ϋ?�)XS��[������V�7����mAڇ%)�fք����B��o�MꖥY����Ғ��9��P�N�i�5�
0y����{�����6���T�I==Q����	������p����^�S�����o����Ř�msӖԾ�[����z uR�1���P�69w"ھUz3P����h�d��UoW=jh��d�gH������25-�+;��8�KB-�*�@�p�%f��P	�:R�6����-���ԃMV����
�0!�����U�h������P�C�j���R'ԀZ�����`E�4�Z ���Z�9���l���<�{q�['����i�Y���=�6�(�� K˼&��|�a�I!�4V��uU�h)�dֻ��p��eSg�gl"�hQ��|L�u�p�Y�N��2��E��_4�%
J�bӤRc8�@����Z�Ϡ��2�qJ0^*��?l�O!�R�5o���
�_�]��7��}�z�6��ݙ��칓�%��Ү���DٞܙØ��w+?�A>�_M��?@��V�W��U��A���B���XX����!g�PeC����`���s����աF�C�#�W��绩@YZ�5�N�;� �;K*Ʀq@�]I½��M�dvwEc8��#-�yϰ�۠�N��bw����+���?�<<��[�ѿ��v��;��SYloʮ�tk*��oݮ��3�T1Mc����j[���:-a�Ll�;;�d1��Y���B���M$z���Sbz��BKP�%��!ESY�=�U�7�Cz���dXK�)n�Uȫ�l���9t�e�m��ҤC��j�9�|��VK#	����Z�p�y�T�Ě%�\S9����4�,�䚈���\k:�zZm5��({�������k�.����~�$s�Z.���KƖt��5��,��[������&��F��5�>��Z�;�4k�"Y�Cj����^�%�J��iɿA숩@��A�� �!5 ������M4B�Y���GF[`��k��݃5�h�5&�8k��>�{�g�^�#v�C�a�f��@�O�_����9�A���ȄC��C�۴(d2�P�394i8=�F20�ƣ%�zKo;P?-ژϸ�.�҃��u�y {C�fW:��'CZ`Q���6�'�#%6�1�K4�����s�uG�6���|�=� � �8� UN��S	0=3!�ޢ�*�5s!_"�I 4_�{���&�X_��WQ·u�{��iu�B�	����������
�fuYU�׍\���o�{}x�F�B�Bq�U�B/�m�E#j�D��+Կ���|�/3�q��?4a>��^��JY��wN?x�p�rws������'����V/��{z~���h�>	_�f���}w`������������WU��2�_�ŝ[�
{�����Ǜ���û�����o�}|hş�Ϟ_�V���O���Ǉ���ǧ�G�<��7��������.O��<���������ק��W�"��J]��~x���R�e7������<Z(�~짛������6�k��v�U�O>�������F��y����������>x|����n�����������o�k���öl1���?�����f�2oɧ���կ�Ͼ��<S���_��t��|l�ߦ���K��ZӺfk�����7,nn�Eϋ���k^V���&R}
��K�ī�\�� �.N���$J��W&�dӣ��UW9\�Wr���;\��b����PG�z����a�ЧfϏY�����{���v-�߿�����mVǠ�������	���u��ˇ�����J���V�y�zy�[�th	��tE�O���1g<=|���==    �Ӧl��������������E��E����-�nu�7���hйEi�:�-\a����9�<~���,�fo4���8�-�_��,ϱ}a�!�:���n.��{����8���u�<J ��_�*��B�r�{5B����֪�e87�>ѳ��C�k�Ҽ]~������{Y���d��JS���z�׷��:���-:�`������~���i��^���rR�B-�YS֓ć�Y��C��߀BM� ��}4F xn�RA���'���'�վ�Am�����j3+�۴��MF��W:�K�!�J�m��kE�/�p8��d6h�c8�0�VuUT����M��'ۥ�K�_I@vƗԐ�c�<���B�ʢ��3�쏽2��R�8,�+�1��KY.�*�Ҁ� #Q�!��5��ڍ�v��ޢ�c���ׇ�17w�y����:��&�s��h�#�-�g;�B�����������:87i�=4g�D�'x�y~�y����nʍM����o�����l�WE�*XM3\�T�Z��ip]-G���3a�	y�ܵ���sז�]7�#���I2w=+`y�-+.\��d�zV��[�<�](�`�+��	�-Nn�h�o�,E'�}9oR�ծ�2�����M�����;!�U����|�������1������/^&Ʌ��L�����y����:F��I�w�K[B� �@����Iٵ��=7`;�xzj����y�m]��
qL��$�҂�_D0GȤ2���J���-
Z��&��p�����M��P�0sc���1��{��
zcā�nU�+�a9��y���E7��_uu���R�l'�ڢ��moF�7xxս��B��PJ��n�n~�j�vP*�W�mAu�J	mA*7\��[�O��]h�F�^�U�u�ޞu���{T��v��<?���Y��"�(�;��a��ն=E[z<l^IfF���U\�O�hĲ�d�ʼ���?t����l���9	y���$R�v��22$T(hE�I�ۻ�c>��s������XL5�̀�2x�߅�Ak3f��M���)�Q斒#q�;�n��8,R�������ŉ��B�zԼ�6�'䞘w�ǧ�Ow	&��� +����,JEXT3���1<�}�`��'�J."����Vy%`;�~Bj��M���+��OşW����.����(=�w݀��P�`�����t�wBZ{�?
��Z$�Q�M�m��IЭZ��*2w{�̤�o!v�-�,G6	kl��˜*�m����U�fD�$���+�� [*e:�ߊLv��^�+FˢҠ5��NͱY�;�"�h�{NQ���)����m�:�Ff�~�M7���O}�D�x��Z1zTl|���V�;��:����E%l4��hv�V�C"��+)m����"�T��=qG�mw[֖p? �b�=�v�H�c���8L�P궣no���}� �:��a��8Q�#�:f��<�����̀�#����?e7w}9�3�:D��듹V(��n�
��>y�U��E�}�<q�yk�olx��CidY$֖��
ƉH*��ٶ�Z���6:�l��6�q��{��a3O7x�E&r�Րǅ�n_I�v��=-�Þݫi��?x�gL���a~Y�Z��Ƹ�f�����DM &4h�>�P�ے�T퓅��6Hk�Ͼ�<�!���P��dyb���l̔� c���yǾi�kx$� IV����)�:9�M�,x�Q��e� WAǀ#��c�n�֥"��y�������t�SΣ� ��rd	,nsNp�f�P��{K��P�����ܸ�6�M�*�Dn�d�����C	��.�A�ވ�B��Y�/��B;-�+�^#%ٓ�X��p��s\ۀ� �i��4�`���/\_�ia\��TzJ�q�Y���31m��J,b`=�(�#�1�
�uSČ��	�+�Y�������Md� S�<Kw-|�M��u�����S�e4o	�f�Gez�5!y�G�[�/�W������2pC�'_���-U�*y�tw�z~��x����j�������eݽ����m�c����|��쾊H�TK!���}~��7_�;��v|�U����~@�5�E��Ͽ��0��:���s�T���w;5k�FѪ�f�{�.�u�;����M��4Kd�iWE�3.\έ��,Lyj
3���=6g�W
2���O{���k��1?{����-�����/KfܰK>}�oY��e`�7=�Ѭ��~_�%߽Ma��9��{�e��7�{�,:�a؛ח�������h���{>��7��?����icw"�r�[���Gw���BC�f�'9Z�X�Yӌ�]L��2�ͻ\�G�>uͬ@s����b��RIcG{�وS�K"π�-��Y��"�@����3�\���/�! .���0�e��7�<�,Rl��>��@Q*�ڌ8���D��_H#��F6bY�hy�Ҳ��F��n�f� ��ŀ����so_��;�#�=`�mD��l�& �"i����F,ÿ�ei
�.�ߍ���F����a���8�����m��%)�u��_�l��9?�U����/��n�˹Y$c�7I�0��B�*Sy/����dI�ik+m!`���o���F�7��a�$$Q���M�b��-�(d
dBdW�)��}}dw�?JH^N�ö�O8}dBDW\���ID�k�p�l��LD��p�#:|vwx%�z�p(ʫȎ [L�4Æ/=tu]wP= ��)���	����.��nx*">7�M���R�DQd(�1�Ȧ��
�����s=���q�z���o�t!�-G�G����;+��E����ƣ�6ᠭ$��/7�>]3Tڔ^a��^���|�����Z�����T�<�Y��:l�������!ʣ�*ɢ��8��&Y��}�t)�TkB���Bu}0-Dl�u �V�/di�ܯ>�<��&�^�/�B��0Kc�J@6rped��Z~�wa[X#����o�F�m�!|�2|���se[8�L��f�ٞ}(	�������H&�/_绶��p�j��O�����p*���*��<S��N�����1�/�\��/���{�} �@��A@��Wˠ	���\_I=֘���}/O��f����V��t|��Bl�(�H6�������V�1Gs$������G� �����5S����98�Ǘ��7V���EW���E���mK@@9R��(�R�h�mk��_U��tS����h@V�ցٖ ��_C�Z�������[4y�N��1��j��Z�4�����,��[��$�v�{��� 1������a���{溛Bq�+�a���Xtpk�g��
�Z�d�V�+TwQ��B=��_�Gt$�kG��a��@��yn���������6�<��U4�R�XF�ԉf^l�(�8"xY�^���_U3+�� p��u�맖 r6}E##�:G��/�r�}Y^V���+�Ō�%�)~�4���-?n��+���Vf��ơ��ݡ�2�)�@�]t�(�6a��Ṓ.)��M�ٻnӁc_K�����{8�B�bfD	�m+4�d�0P�P8�.�#����&�Qc�Hl>��YH�7~�7F�я�Pj[)\dL}9�'��A�b/5?��� ��(�V�n�#3�}H�RY�F:2�v�ORD��ie��|o��`�{#]��89���}���<<cO-�R�6������"{�Z�Z��1`��w�˸=9�Ƭ�����o��"�D�a#w��wj�`��W((:�ܜ'��/�_�3^%��LD�wBY��3㿍�.7�]a�K�������"�ᕅX�]
s�p73v��+m��0��Q�hu��&�-�-���� d��m���J�n�s������C���VKa7���Z�zv���M��V��Ub�[I-�����Hz�6�E�W�.�Pي�V��Yā�^Oo��Qj�'djC"��b�����\Cݨ�MR[(��(�G�e��HG_�E��~l=
��=�����gC�l7ⱴ(U⣗i�4���d��^��V���{(���0�9��fI.}w�Ũ�B}    )"'Wx$�`�1�������+��#5�q���+����hY�!L����<��qoϤ`���f�^��P� �D;��Wd@��8�C|!�4��ِ��L��%u�T�u
xB�̌ݼ�|~��^o�~��n��[�<��7��?���τ?h�d-��J�="+����Gr;6,V���|�'��?4ʪ�+t������7�Э�����,�h��.^G�&�ub���x��r+O�'��1r�8<\����.�'���T�T��5���`;��pj�2���p��x(1��!��<��1 V+9gϓ���]M��a�j�pf� ,��kt1�_�iR�#o��P9�q�7��D�Q��V�8��P��q�p�9�jf���FR���n}=�J�O�~��Ǜ�_�R�)�k';�P����\
U\��y_�j�˸j��!-(2'C
�-�48Mˌ��	�m�Q��=�g߾�Cd�M ;G���s��@�}c�F#�L���]���i�tp�t8y����)�<�6$>�h���䟑/�>飣�(=��|6.�ђy&"��������R��f�;�f�|T��Ε�::�g����L����"�Tmr{�!����w����6�!�Q%�z�=�Y@��K��R��A�_B`ͩ���kH(���":D�\�	��^�nU��k�.�G9HU�����-���e��2'���P�^-hB	�f"Γ<� z�*��
":Zrn�d���*3�����迁�B�*s��8��c�z�9[|�gB��:'�X��VRv�H�}����M����^��)Z��Gf����e���G��G�E�ۆ���|����D��{�Uw,���2��y%��ޟu��CZCa5űF��&�S�m �X���c;z�}5rª-YB03kE�: �|��/]XZ�g�yz�*A��F<�D��Ɛ�Ft4p7n/Q�X�C@�Th�e��>'����u�Jd�v]D��p�5�
�@\���祆[���0��a,s��D�9�|:����dc\��&�5-^� ��S���=�����>v��� �2��=����r��<�u>�pc�/NL9t�&��{4U\�?��t��zM��# �//���u�����z0_�Ǯ$5;��l�b��3
�\�w�#��<9#�"�4�@��d�elG�Q_yCh/�֩dh)�2��PdAl�%�(�o~^4�<��5�Ɏ�y����������͗�/w�T��}�o��37�E�ˏr����`��taz��1�F���E�k�:px�Q�h�G�Y���-"�7��X�B��Nl���J��U�&��W�T)�3�� ���K�=ݠ�N�z����$�c�Ń.�z�Hf��x����\�X��-R�)��P�٩aۛ�Yo!�[��{<�\L!N�`�������ɓ��Ao;f,-����)�Z�򈺂6uż�ϥ_�]�����m��{M��\���飼�dͨ���v�8�6̐��p�'���5TYT~E\��~T:q�*�Pi��S�@,^?-�$u�M�5�O�z�{,�H��*�4�QqM~?��) 0*6���T��a�D8���)O���c��u'_\�48��
̹��6$�v<s+?֢��:?Sz���8���6���&�W��>Cf��fL��]?pՁ��9R@�2�eк��Ǧ�r�e@��-��f����\��EL�*8�bW��-A3C�7:�A5`���羚ޮ�tԐ]�f��x�wp{	7:a��>ӫ=4�	��!6ȶ�,�e]D��~�%O�#�Z��������v���S���i�����մ��yc��vP�<�� ����=�K���A>M_oo^&��j��V٩{�c��߾�t�����q>����>�{������tŘM>���M�>l���u������OO���ۙ��㻇�����ݏ�����������:[!�JU����-c��x�?�>n��?��ϫ���`Ǉv�5U�痧����g�����������c����V����������~���M�����/7_ꟻy����~��^���O7�����bw����Cq�^���f{J!UpN��o����w����=x|����n�����������o�k����׶Xn���O[|�A��/�ts����/���7U�g�V���n~�������t�����/�O��t�Ӫ��$r�^-nn-�ϋ���dG�x|�� �j¬PmTᮐ����"�{x���y|�t���{�.���ge�S����"$�3U8߿�Bjui��i<S�w����~��֯�ل���s�*C�siSg#ͩ�.�G��h3Tey\�@x��f
�*V ��Ʉ�l�V�b..s]�6>��.�E�C��xe��Z���l�6��M^�T�� E�u~=s�#ɐ�ڠH�_�|��k8us�6���O��I0���T(n�#��mQ�Wp������l?zݮ�	����~�{xU8w}޸��o����ByQ��'%���R�L }���/J��[��~�L��,���K��U-Ί�d���%zD���f�r���d��^JUT��r�������sI��֫��b���M���k���e�oM�5E�c�m;��ƿ�c���f)��1<��m w��y$�ɶ�f]<!t�-[�u��a���9!e�jIҾ]?��x������]��Z��G��<[uj�$�;�w�Ѽ�DW1H��ۥˏ'fT���(��xWP�T��t�o�F�p��x⻷*Jw�Kew��W�����UH9��W��m�.������׸x~9�W::�Y���]~*���T"��w��I=2t�k�F
M��\�c�w��m5����9��� ]^�
�������wx�_��]6�_�l���'a�$�����d;�E���4��Mɏ���;������OJ�w�,Q�򅊲��I��ǲ&a���Z��L����<Y���7��*?3�>~,����R�W&��uY��:|U~d��[q�B.xw~c�[��PZ_�T<,C~a�Zw�e�R~��"���E�H[�����8r,��i`���#�8���G����	���gty�R[�ߣ=H���f�̶�V���ۧ�����������W��W���/����sX-�?F��7(��?.��N��N 6�oy�K�:5`�5ƾ�2��m�e�� ,C~�8A�0�,�W(~�.XI&pZ`�����z���]0M��/�>���5��a�{�f4ٌ�,R��w~����%���UEi$ �߬��QS1�k��R��e�e��:Ǩȯ�KЖ7�䶅� l~_� ��h��("�8l]�0W�eːߗ=�+鋟m*L�;�/��-
]]�~�ߗ��gm�n�<�����om
�.^�k:�J�'&��Y�k�I���OL���.�z�.��7+][�,R�8M>mN)N�s��]4r�2�X��Ԕ�Ua�
d~�2������έI�W/�y�ִY�
N��|�W�v����ѯJR4�Tm�������jC��b���;?z�-�urk2?��aF��U5U��ps���������(g)x��}�9�H~���o�c�����}!��@�o7��߷ ���� �����9�^��.����|#�� �%����t��J��*U���g��L�x�MH%��~��/��x��}?��Y�JCύJ��:���H��4���������6�����kw��A_��A%�
�v�d�T�x��U~�����czW n�>��{ԃɖ�f�*i���x4�NJw��N�<��9m�E�Ei�ֿC�����p��y���q��wW�6��`�$,�c8+�}�{�M�c���
*:Zg䚽���ު���R�]Uw5b{jhKߊ�_n>}�f���)��:�����k�5SK}�<5[���:7�B����b�̵��{�]��2Uۋ�������������z����(���u�PN�u*�v;��@Fjm�Hw<����>��v�������%<O	�^y �� u�C�f��]-Ҕ�Q�Ig���λ��k!������o��.�    ���p�-����Ǘ��?5�s/Gn!T-�W��<����yVh��Zj+���P�����{�e����%|���L��v�C��\7.���^@�|ѥ��N�χ�B[ <�
_�vrmG�D�4����U��t����q{�sp�������#|˹�e����9p7�$e�O�b����Jaǒ����)�a�t~k�M>��盫�L *��Pe��6��T��Rp5T},��b�!(��et�EKɅ
��Ba��Ur���C����Q���P�������-�f�mQ�j����45�������_gd�Lُ���㌾��Q6uŲf*mre�[Ӯ��=9�U1+��!�)�APz��U�~X=ܮ�����£=9�3n�o�F&����^�;��NrSf�؍G"oڔ�U�g�2�S�X�dS��R�fЁh�V��-#7��Al"�t3��+��>��;>��3��֣MN^PǶ�w�4G�	7f:�p3��ͅ�%ZB�7�%�Z��u����l�v+O�fژ��(,y%��5'ǌ��?zTh^-����SU�"���L˼�ٛ|��qo�Fݻ�����\�B���lQO�0W�Qᶛ�=�v���SG2=]����s���[NJ~;��bˊ��]w<:�QRB�d~�-�?����L/մ�dy�*�%�
0F��aܫX*# 8��͔�
��������p�o�>�x_��B�\x��������3!U8@��z�Z�.{9Iv�� i$+`<�L�����uwqJ�o��r��K�Ӧ��
���Z�d
#!c����*���IUOlHW���]��>��D��C�IH��������)����p��,��A_��2��0��?:A���>n%��v�e^G6�Geg�P}����}���J5������P��i ���E��9t��WZ�|nE���"x} @nF�X�;���p7���e�,��o�Hd�D:�4x��d:�V�:��.�֘I^��f&w:�� ��D��?���(m?�?R�B:8ѫd�y�VJ�i��R��.)J-�^�U��OW�5�@����� �6��]ld���?�moS
M-U�e�F����c�@@P����"SK�@���j��[�h�x\�q���F"�K�c��[�C%�DRg;�g(���DK�Բ���S�}��H�js�oT�ȑ<��RK��!t@��&t�����,�S9<��s�4��d��Z	V�?$���i;*o�(�[
��3�W2YΐM�X8���,�m}��+t9[C�V5�'P��(z�3��[	Đ;P� 5l����p��{���e`<9Н\��n{�:�X�4�
0�����5���d����_���Z��P
q����;����?�v�8V��r��!�+_n����TJ�}6^���%�u@ɬiMb���BWn��0�ʩ!�fo	R�����I���溱p�q��2ʄK[�:т��\���u_��[�+iε�2ϣ����=p,�.�����6�n�qf5Mz����np��ppŶ� � ���T�'�͏Rm�������d����+Q(����<Q���p���CBD�G�������}3mif��R�p��рq�p3�����t�O��v�^$BB^^Լiܠs��Z��7j���L����r[��7D��ԅ7���Ik�xzc�PBj�/�nSAs3���������*��b���Yb;�`�@�1�T���`�js��)�٫��<Z
{t�D��Q���&J[���� v���T,�R1ק�G03)A3�4e(q���*p3k��;>�}p�_���pó���4ǳ��W�����d���H�K�})�HG���Ͻ��s��Z�{�{E�(S�QR���[��d�`������I�7F)��&o�����
M���ظx�s� c(�Qm�^U.{����� _�(GԊ�s��f��#�8��N�v�H�+����k��AS���`�I���M�i�y �'�H�b@R�A�>}������y��#�5���\0�}v�#(�EP2�����B�Ϩ����	7!�jv�q�!i���
.ςY:��˩��sI[x`���!������@J��=�[2�W��t�T� ���u�t���O��G�{R�a�_�?B(X}|Y�.>ݭ�o_-�/I~.J�~��w���(T�0�diめ�²V�0���~�q�v�W�=��r#3U�(L2���
_(�I�)��6�h�/57��:� *0�$���Euu"X��*�9m\�q�TEN�Í**�l��E���G%rXu��WU�#;��)���ޮ�q�H�����k��.�����t���_����p(:8�-6���ؒC�� U$�@���Z�b�F�����|�I�<�@�L��K�m���Sߎ���9%�,��x�9kxl+�D��`ep�ק��4�:c#��d��3���ꑓৗ=��X�|�x��{r�x,��`C��v���V'���hFO�܈"먥L��k,������w�*�W�TĞw�Ŧ��v�d�
8�\�$֎At����d����wF���%(��'��c<E簠GM�\�\����Đ�� u:���pJ��'��v1�O��kb�GAr�y[91>-��}��|�b�g����=4��S�,5��X�Ō)�X�e��><�������U��|�取��~9_=��+����b�o�ً1�������v���#�s��am�����/Go��o�d-d}6z:�����+����b�<&�w_�����=o�o�+�ƭ�y�.V�+w��oO��r���^�۟���>��귟7���y��������~8�@��wT�2_�⃮��>S/z��?��=�m��߿><��?����.Sg���������l�6��7�u�!�e�$Os�m��f²n�S�>w�)�M��|��z�e(�y�7u�u�(�R͞}滛�����5_l���@#)��N`��`S�~ Q5��F��VV(���kz����N�
�����Z��,�^�=�����ϟ�� �u��,���Жɂ�9�eCI¸�Mq������� �� �eƿ�h�Ej� <��o֍�Y7�kŻQ�ޫ:�-e�qd����� i*�ps���� ط�����_`�S�L�Ty_��;���
�T�}�)��@��&f��K�k=p.������+�(+��Z:E�W����r1�� ����2nn41�\�Ss�;R��א�#���&w4^����@2x��"�j<bXУ�1��]S���b��|*��x�l�O�?of�b�|��/��h��smG�o5�3,�q#/���U��(��x׏�L��"��s�!Uj{��x�aA��%Y����agɼ�&�]òn�0��y������浑�6�4�2���kz�4�!-f��\�g
$�^�R)'��ۡg-3���,�S�f��`�k�����B�16���}s�����?k�}t������Ë<aX�:ҳ�����/�hw�L'Mlr֎�.������Y�9g�A�g�q�O�C�"�V��N�,��	������'U��
�8�$`��)�	@�	���i�T��~秐���5�.���I�7�8W'td����
��Cq%�μF�+q5|�P�����L��;h_�����/�d����e��t���~��sɼH���L�	��k�4���T���~36�%����G�+��G�N�r7����3����@d�Q�T�V5#����F���C��rư��_cCY�����J�rXw���D�W`�:K��56�U5��z"��f+�#�1~&�j0��L��kl�}�x��b_u�Ktpco����I�0�8oPQ��_���r_P%������TS���j3{����϶���n�~�?�J���gWJ����5�n ��K�U~���Ƽd�Zf�#�m���m��e�r=��0�.����_KO�����m�5��������5_rj�#���y��=~�`�j��^�X���C��9����>,_��W9�>|)�V�YFO&O9q���?P��,~�e������߾�i:���    ���z@	���N�?�w�Ƌ��a�6�}�??4(��rW�}٬o�a�A\��rX�^6+c��l�Y���- �8�p����p��#�v[�0�:[�X�l�0F-Μ�[��v�Ƣ]�e���Ga"Ŝ��X�j�p�y7�Y��q���~�I��󆅑lə�}d�#������}�Y� �I�t�����u���9s.��Tb��8�zY�^���靌�w�g��V<"��Z�
k������G�%"��
��*������
UIq{��c��,ʿy�~��H��U����7�Z(�$�$�M�+�po���M�� �M�����9����4<�Bd�*G�Q�������#~��@o����]�)���k8�x�(����g �ʿ�(�	�S��TxfFv-/��9������9F�� .?0��ם�vW��ǣ�p\<��fD��녫�l��m��qSm+��h�5�:2�|DsX�-P���/�t4W�쁼̷��$!�b�w9�%$Wx��T�ջ�s���m�������S�^ou�B�u�ܢf��v����5��I����Lkr����^+Z�b��kR�M����Z?���ć��}nsԣ�3}d$�W+�5�����S�B�3�:VV��Zh�@��Z��(5�t"���Y5����.�a�v�lg�<�(�=��0���&���qB3n�ms$�����p�k��o��>\�Kr�".`�v���	dT++꺾�@?�D`h��f�Nt݈Vh5��^h؞g���=5ę����D�B��y��,����B��<���9��&�H!!�Co�ix�GN	1o����e{�F§���:��)���Ye3lЂ�K�� 2X�dd�I�v� �� 6?Nx����He�ɈϡS٩�HU�	ɥ�a��D!���SR��XF!�w�i�7���>SZ��c[��6im=hmpfa-iŗ(����<^j1�g��atP��W��HfΩ
ɴ��C��:�K�>�r	F�ªT8�DZF���o�� .6vdq���!."���"�r��-2�!Xw5M1n��X��~)G[�	e�2� ��x̓�,���dEȮ�8���5�$,�&�zL�#1����r�1�xԓ����@s�2#���G��u�,q�9")�=ƨ�Zd�9��`�Mk�Q�����ih�`��N?IJ:2��@���,�y�V8e�$�t������������IG���u����E(���Y�Gg��P�Q�:�8/ve�C����WQ
F����A����
f#}�����"qlܬ����85,&�˖�6�L�e�]���]�3"'~�;���f��K
,|��y�u���Ow�ٽ�E�{��f��:�`�(���f֒Ρ�N����x%�՝!Sӓ���At��m�Cd�*���/��H�ڝ�Hj�T���U
6<;b��%�`9��}'\�v��9����ֽ@�Z!i��=�n^C��:~M�
YI��ګ,� X1��N���O	X��8!I���iD�p�W$�٣�ݥΖ`��@� (�+�F͊�L,j���k�(�3J�e���Df�o��A��D���ǻ��rK��"�i^���1g��Z^���:�<#��9�Nw`��.�m'�lZ����B���&�ܤ_6�m�{�{8F�]_����+|c٨`��I!w��2���0jꔉ�k�n?��閳ګ��V�s�}i��r��Z�ٸ�J��r�����,Qxs>��;V[s�����u��ĺ�����c�%�m��N�;eMzQ�͗��> ���4,��H]��n�����P��sF]��9���AVm6.�H����P	3Z_��_�g���7o�[���{����RǺ5|��:��Q:!���yD�i9;IQs������
?��	Ku��T?U�>�9�#\��f�Y�gN	o��*/Ӷ��b���*���@�x���o���d�8b ��7L�R�N��PVu7o�I�A�ql��[D��>>/mO@۷g^q!G��JMrn����J~�FQ�a��Y��^�bg����	�q���t���W��)e��v7���Eޞ�'��1U�ܫ�Ti����_\���.�A멺��BK�֪�G:+�?!�<����E'u�8*X�S
���J]?����3�!�dN<�6i�beIkl����:P"�C����o�ak�E
�:V��c��F`A� �S [��D�[��.ҹeJ�,*K_0�Yk�L4s�x���)O�}Sɱ�~nAD�&�O�ƽ��$)�N���*�yo��7��DHd�����kF���Xխ9�8��zi���n�=��J$��D��y��uq	�P���l8�X3��H�\ZA�>�ѿ��_Q��Y�j.�uX�y;)[~GaBD������g��B��AR`]�ZЙ#w��۽Ê���A/̍�	s�a�}�އ"o
�jR�$B7z�����r�nX��f��7-�e}C�j�l�t�ɤ].�����)��l��56�$��h9a�� ��E����eRt5�M�>��p�ss�gI�$�w�@���u6��?<��c�\¡�0�i�D�(�l\|�@$��#e	�=���۷o�;��4�x�Gɫ�B1JX�oZjT8�	��*0w��D�iY��tzq�dUZ!�%^��y���T%)%7INұ�OB3N��ݩ��jR�`�x���!��j3��''ǌ�d(\$��k�kF�-ۼ�W�__�� �����FD�%�Hxt9�Z9Z-l�Z{T >tb���L�)Z��yˬ��Y�"5�7,�nm*�t�)��ҳ]����G٬u�|T}h�q�6�Aˑ�kʠW�,W�Sd&-�D�[)���<��biY�-p~�W���A���mi6��Ahh���%�-՟<����zzMp���%
��u�S�	�a}݅jH�K�ٵ��X�Z��4�r���bWY�q%m�3/Ja�,*>\����<�|e� ��j�6MJ�+R�Fm]=EoT� Mש#�\����v.}Ӕ�:!eVV��!y���_Xb	ALQ�!R�j*b��(��l��W�M�Q��2�����p�O�eUf�TZ�Θ�ǐ� ݤ�Eot�{\I�O%,C��l��f�ZY��%�GT�Sv��{����7+�2V�͉"e�b��7�ȱL�fJټwx~�ϝ���Z"��_�8펵�PS�Q�!�{'��`�%/!4/�j��`^51�:E����n ���Ƚ��
	n79������@8~��U���程��哤d` /����1	�wUJx�ԉ�6��<G˝-�@;�wl�8}β�����mz���'�ړ�;��-X����ϰ�LhB0^�S��ߘ_�)�M�p��ib���7��@��Ԏ:�xf����MW7;H�w�{���}���ڜH�I�qR���?zp�=Fⶇ��.��h8ʵ�ⲄP@�,��
��_cm3��EXk?\�"��W'F�s�.r>PN[��f���)��"�;Ͳ�\oʅf$6��s���{� ���Uϝ�I ������0����=��3�cl�o#J!��2V��{;�B�` �a�.4;�l��Sx�Ƞ�G���=�:Ҏ0�4��(�J ���4��w2����퐘�B	���%��0�踳nx�k����O>L�d�����|�>��1��%:���)FBo����؍5�`��Z,�!�~:�k&��9s0DF�&t'B�(,g�EF\;o��tO� X��p��k:��sDS�^"�j7�:�O��m�XZj�0��~idl�p�o�:5����U��EC珌���F5�"j���P�V��|�c
��#�ỳs���cn3GF���f(d��(A,�h��;c����B���$��I�%�����e(�� :EX!
�=Fw�In�p
Mt�����Rb�툟Dl���� y�Zi�v)�Ǧ݈�-0Z$4�Y�������=���=��j�5�h0F��8�xl�4s�fZ;�ch����(p��:C?�|J:B���"f���q�Йn�5���DA�{�NV�>��W��Y�Q�SYS�c#    N
$7����mg=ԫ���n1/HDM��
sb�@�)�&i�5ô\)>��=ԙ� �qN��
r�z������S����g��%��N���"�#�p�!�Bs�a�V�U�bר�R��vtN��=й<���֢N+�ې��9tX�gVU�	���dn�xm �o�	�0ڐ�@F�2���H+�F���UQVW`ڰ���+k��X��H���\-vo����l֋?�}��7�Ȕ�_B�bBvN�kl������_jV~��Ky��
�f��D3�X5�����D~�(.2*>�/�%7hlĒT�˅0�迁��^���}c�[�D�#K��T���ç�v�����_���r_x��՘h���Ϭ��#߯V�������������_��#ex�|}�r1/��}\|�2�e�9�ⰓR�%�ϥ*޺�.����~��}�r��/��ǹ<m>=}\n����ё懕�_��1�ݬ������y~>�`�m��e>��z��a�:;��|6�|:�1�Yoև�v�؟>�����e�{�.��׭���]����>/ߞ�{�-͟�o�=u��ؚ�v�����̟/���z?��;x����|v�|��|uX����Of�;��b�|X��g����/ի���*z�e�:�/1x���/���e�28�f��ڼ�m�[g���]������������S��E�0��z�s�Z'gfV͎��f��5����b�K��!c�r���e�� j�Y�֙(N$�^9V	�_���;������{��̀;��M1J#	ǽI/"�/{�y��3����r�h�mm	��<���^�@]�cdn�Y���/P�p�0�#�6����Ng�v��R�4��7��؉�ȇM�7HJa�Y	 ��dP_8����,�^��K6�#ܳe�+$�Y(�_���n!vq�kE�gQ����y�'3�U;t�1�/ ��K�#���éo3��(��Ar{9S�IҷAb�;s�r�|ݹ<�a�d�`� �5��R@t5iK>��8x���1.��`b�'O���,V+���?�6?-�ո~������_���|����B��G"�RkZV5z��|���f[�')�BS�A`���^t�L[��<�N�H#;AL��[xz�,��Ö�QK��z��R�l�"R~�⒭y��),�=g�݃x!�Ӹ�hVS[�ۢ��p҃iB�-���P I5�
�@
�RUf�ܑ��./4�qs�v�t��������*a��N��e�͑�D��z�䑲D��s�7G�2n�0X��0���>�S(���S@_ǉE3z(����۬)f��"
$�C����*���&	:�΢b%*�ʩ�'�
o�Y_Ap�<r�;vo�Ćv�D^suWe��JR9�HvH�83��1�&c���a�wlR��eM.�����+Yگ%QL�*6�)�!"p��8K h�Xr�`����q�ņ�h��vC����<���~%ְ�I:x��T�KG)6�f�"�Y�9�3u���2o1̢�ҵ-H�t�v��J!p˙�U��g�T%B�+W�Z��).m��`��Q8s>�%W71�+Ii�����x�(d�Vw�3�������$i�R�-iUړu�t���$S��Zj2 �;$���`ɒ���s��G,�pH�����)>:�CM�6�������RS�����p������n�G��VfTʡ��e:,����In2Gx:^���Oe��hKc��H�b�!�' i��H�L�a{A/�xK/�c�����_�������f��]�Nr�DHK����YlL&�&[�֑V2hUGCՓkE]W�JA�T��ǜ�⥊�~S�9�_�#t�Y��z�t΢$<z�Sѕ�s�X2d�w*	S��K�VdȊ۩@xѾ�C�@3[���i�:q9g�����WW�Tܞ�!P9g��%����Iźx�N���$�B�Ζ�q���\\�#QNSns���i�.58g�/(�yr��M�%S��\ �!
s�&��}Ɏw%>Kn��}��w�76݂�y�@k��Y<!Ҽf����:���3E���	���+頩	�č��ބ�@7nҽ�j�&:�
�ҭ�*��m�$�<�~��1�������FZ�#��&�9�1%vB��rz*�J�)���p�~֚�S��6�u�o?	w��	�V����,"ۨ	�p?s�ʮ�p)�}&�K�r
{V���;τ�u�]v�'�����}�=Μ����b��\M��8������5^G�,%6zr����D'12:x�8��`,�e	\��wĤ	c6�7O5��"�'�y!�Esrc�(?>��rWf��	�AY����?eW�7��z�>?O����u�@%D;ܕ
 ��U�ćD���̜������^�Ib�퐥έep���*Gg��xs�RÐ�@��6됭���`P�
כ]���ld�gI&�-����b�oȚ}X:�ؓ�//�I������l��5e�Y����L������
lfe(2�d�V�Pd�������i&�SӞ�z拋k�:͝^�p~{�]d�e�uf�Al-�lR�;)��,���7��vx{�����I�1DR�����o>-��}�w�Zl���ⰻx5g��~f>��ۏ|�Zmf���ss|>��뗹�H�._��\�򊣸}\|�2�k�僂АR󸺌�ϥ*޺�.���:�W�`�^�������6��>.����_�#�+c���ic^�Y-
��'���h����� #m�5�,��/׳_����|���q���#s�o��鳏�ߞ^����|�ڜ��y�.V��w��oO��=���Oη?玺{[l�w;lg��lg�_9 ��~���w����?�����ؗ���tg����w�����z��>͟�_�o\�c��ٗ���f����~ǿ�����ഛ�7k�en����vi>����~{X����?O�˗f��|J�O��53�jv�7+G�x�j��p�>��.��K~�4�'5x��p�؝��PHS��c��9�ױ@/ʍ�:u�I��=(7���4ɸe��f��2n(��#F�&63�q�;7\;)v0�"� ]r�4k���CD�<��(�����eR���e�{��(�koU�b��`�-826q��p9(.�����t��a���ZM��*@g�mS��B2.5/�9�~���;r�kr.�q�A~�V!a{��K��-z��Z"ـ�C�}�{{�2W.G_�'��Yŧ����87!��M<̓1�6���>-W�݇��jc�����o�7���N�äq)Qvl��_c�����,�R��;-^���h3d>X�6J��J\����e�j���_f(qŉ���~����$}L�G��N9�/%�5���+�,�ݳ#mSZ��vf@�P�4f�Ep�y��
�G�5�SB;�4w�(@�����.�2c�J�j��e�p�]r�����W��A����?�g�0e�l0�f��Y¼�����#B>FK���Q�7����r�̮�:�yfH�Y��(�~���;���8�x��ͮ�`y�gS�ޢ�k`�1
�'�I;���� 6�?�ޯ�G����w��}�wd�90W{a���/
�H�$0V��K��/WAM���;�Z�r�F{��ǱM��[��F�����=������--���%�ۤ��!���h�(��2�}��q�L��I����.��ZOl�[i��VX�m��6t�f��8�`�6�s*�t�u���}A6��bX�S]\=��ԣ�MQ�^���:��f(�щQ���2c�Ή������!��v�+Z�`;RR14l/�ٲC��	9�'䢾�B�7釗�ݢ�[����Bș�\��t�t�nf�)�yp�u��Mś>%�/��R�MmI��#���X6F��{t���n�X�E��9d�+�^Q�Ek�U�\|������h[p�U��ާE�t�䨅�ރ[C����q
)�W��x)��)OX]�`��!���t�-�*7���m7�0�����6c{��?7�׳o7;�EJ�Q=��n�:_����/͠�N���uY:K��]�����    ��;h|��r�y�~O�,M��$SI�=��6�ޥ�1�.���z��ky���*[;�<i��~ע���0M�Z�����9L��Z��4�il��ml��S	+��K@K���ȬrP#�
���QeF�ȬҨ�7X/��s)oB��뮢���#���kF��n�PFp����Չ�l�:7���Ok�"w�m��+����r�v�,Al�5`E��Vu"�@��7K[���[X0y��;v�bE��Xr=b\;$���*s°؎HE	�se�k-1��f]�xl�@�90����&��٘�Đ,��أ0E��g��|���Ĥ�r�Ñv~��[���*Q,k��/�.mdBE���0���4>ma�H~܄`���6w(��V�Mxշj�d��^�o|���$���l��N�."�Jc=���a@���s'tT_���yf1TH�T0<_xE����Rr�+�=��wO��9�L��m�5�h</<�USE&<u�{��է�($�Kj+����$~-7������z�W��fiC�\U�g�ȣ^�g�Vޏ%��d=h-�H���s�����?�6X/����ӣ�5X�m���s�͟j��Ҹ�1xC��u��@dG�h�X\�v���O��#��$�.�L.=\�*숹�\-�X�	�U\�*�2D���������X�3Z{8(s�$��D[�3X�ڷ�aZS�cTV��o(�F�}�f	�Uh�d��]�	(E?Aө��ؘ �8���S�8���fm+�A��"8��1��/��,��J���.�~��_�gncL�1�{�e�O�<7w�G��]�GR#� #rM�!p��@�8�,a��D���ܚuC���d@�He��Z2��e$5�ɨ���-�AER����*�Xˌ�]��´Bu�x��t�n3w�eT̴�'ᘉ2+�1RKE�PE�cS����M�]��H��EV%V�1�����ՙ��u��M�>��y���ȩ���S.R �Ed�Ӥ�]���n� T��V�@������%,�uWPa.5�V�� 5*����EEl\?��W�=w��[C�E*��A��ݷva�X�f�V�ʺn��N�_�K���asU��|�TD�O�����_�-X�|;8}��]U�[��|�	���ri�$J92&2!����/��NCm��_}FT<-2t<�ll���j^���J���]ќ�jH�J�UM��.mAZ�$�?�$:��ȌS��f=��m�!j�$������?C�aƇ�668���9�I儊-k(y�f1w��@����i�}�&&�&���	�pK�d�R�n�Q��ޭ�o^(&��tG +ԣ�� Q��)�Z1��&Ǜ"a��u'�9g��ު;�xs$,C���@S�ʌ����bg���f�2����HH����jiF����Q:J��rت1s.��v�"�M�E@e��8�YI����x֑�-#���@?�&�m�"sp�n4��[�cI	k!�G_C�e^;.�z���;��D'���&ņ^���y����S�?Z��/ qNH�Au��ɢh��"�E����4��J!:�r�Q���uؕAttěrR	]=ԥ#E{婥��V.�-e4Y,��Q����p��Xt�^��T��8�B�x�:��;�fc�BK���4�a�TKw$4;��O.��.mN}�V
�S��j�9��HX��I��9hkF�ֺ#��~�f�!A�ϩ�d��U!ꊜ:��؜����PŻU���28UV]Xl;�[ ���T���f|����R�wb�Z�sF{vS�0_�k������ZfCR�^ά�(��:"��S�ŧ����(����<�l[�V����첾Žߘ!J��o��5�G�6F�6���W��s���� �N�����yf٩���J����m�n�	i
�]�l7t��9��߰�0S)Ǘ<;-��Q��`x�6�z�T<�!ü�uL����"3W�k	
��Y1^�ZX��%PQ�1K��2�2B����otF���9��7��u��F�o�P�9�8K3�����2�N2�=7���8q�<��qn�5P]�#�UTr�YX��a4Q���U��6�����I�1K(�k���ǐ��_��j�F�_���Ő|,@���'�-V2��}���
�Y��n:��I*���	L��Qv �Z�H�B����Sk�8)%�$�LHx�)<��g�˻⬼C>Y2Np�<���n����_X�&�`L޿�/.��$5#�8�*�ܹp�WdB-��g3�	�,x튢�ݙk=6Ȅi˨�Q�}�k��a��,�~�x+?������F1��c����U��m��ç�v�����_���r_�3�������gVs���W���u��zn��f���_��#%+�|}�r�������><.�bI�y\���Ro�n��S]h]�`�^�������6��>.��<�S�#�+k���ic^�Y-
������h����� #m�5�,��/׳_����|���q��I�o��],���>.{zY잷˷�u��j���v�*^���|{ʿ���4r��9����bk��a;;�g�����"�q}��7O�m>���������W�����bƲ�5ʇ�������a��/ԇ���L�/�kʥ<�H�$����Or�x���y���m�6/��$o�r�l����>���ǿ���(
��]8�2_���<���gL��=Vo�٧���KuT�|l�[z�e�:�75qA��a9{٬��v��fm^����c���5�����������S�򥁱|�/*z�Jě�i=;⿛�#o��H���X|l���l,�_��mB"nS��������p5k�F����p1���������
���L������_�ּ4�SI��t*�H�#�ײ�!oz_�ѻ�S"S�Y	�L�����#2-�eR�,M�;�R9�RN�,�!��R9���Fr���F��udLq��3b<����#�)@�&cR˴��6��?��y+�H�p�𦃒��$i~)x֝��?�6�*�r퉕A?}<a4�m���s�-�=�q��챼��;�ڹRs
T}�_Q%ʆ�E
���5S�jX�G�/W"�%U_��	��l}��O�П����~���Ͼ_���y0���g����Dē�آW�̋Aq�d)�<X����/+��kS5gJiM;֡2�$��)d,i�Y�//�Y5n�d�0���@�|�T�:�rW'c�}D����r�AF�dzh\0��[�k)ʘu��j�|����9����u�a�:w��h�S<D�f ��?��.�i�
������\�,�M$/�m���\?���e�2!	OX�38"Eצ��م�CD�
O�N�x���y�#�Ѡ�)��������c��a_�������Wo|�fw�kC�"(�)��l���x�aG�������<z��*���@.��Tv��_���S">*@dN�,*��Y�Ӂ��%t��r��@EZ=P'HǑ�p>��$��%�z�U��(R�o�a�{�'T��uT��J�GO��g7����#�2�8�h�b#I5��*�0�@V#�V����2�i��3-�ì�c<�U鰦����?��Y���,u*cu��s�B8kS�H-7Tj�Sᝳ0'7��S���<���Ʋ�z�:���:9x �u�8��Qf�Q�#���<��[T��X#������ޑS,�+φ��o�KЂ��*�k�#������>��cy1.����ja ��Q	��� �(f���mr��u ����:m[����s-���Gx�����I�֓�Gc�|]�Dc*�g]�x[*F��D��_��	0^䀘�Ǳ� ��{E֠��(���J�ֻ���Q�ql_G�ob�b�\�g�i鼴��+�su[���@4-C�w$��Pm��]N1bg��t\ڦ�Q�E�%�[u?Q�%(C��@P��HE�����74��	��5��Ed�d�hS��;��Is����ƽs���y�mO'{6]�@75o�U�Aj����B�������~,!a}!X�U��pi�:�Q/<�
�@�k��h.���    B�M����r�G��r���ķ�{���.Ē��д�@��%T�჋}x�?w��l����|������s1�p2x#܇�sC��
�P��R��ʊ��� ?���Ȅ�5��Q(����WI�r�[Fb�6��F��v��а=gX7$�\�Y�'W��f�_��ڼ-�v�׼1S�� L���%
Kg�|��� ���y�yL)M��\;4�XAtuN��a�!n����K��PZ��^�`�z�f��Ό ��^�gK�N-���_u�q���'+/��K���(��=�C�&���Z)��ta�I ���F�GCH�\??}7/XB�1�B���U��1f�o$XN��)��v�v�QQ*	�vA��ʬ�O+I�K���N�^�9�sλh��k��c���k�3�r�)/Z&Ѿm�T�6^����?kl\�%Z��|4�ɸH5s�9Ŵf^2�s�D�a��F6[�W���m���x�>�)�\vP�s�(5^5wp�ҬI��VJ{�9<7�q��+b���\ڪ`=D�׫��C��`'O�+p]$Y�����eY����$oR�pI�9��m�Y��ڨ���o��8�76���H��!�0�	�za�jt�;d4o��i!�o�ĥG#���qQt
�5 �Y�����e��ن	�~�e�ҎUQ*�*fws��<�vɆ�Æ�)�Q9[[6Rا%��&b�	�w2�l0�]�Rk�c!�N�+�����`|�8HY�(2O��'GA-�$W���L��(�p�kI�:HhBx���
����FⓘL�s�r1\&�ZE�.U�)�vN�M�5~Y}�0�����8:����0�<��U�	UB��@3HP)uZZTX��ZE$XL�`�Ҝ�%p�`�9�T�I�J�l�2_i>�,w�>�/�c}]I{Ā�q����>"���,�����?�φ���I�^�n,�Jhv�%����kŬfT� �u�hX�S]3�֩s�IJ;4h/"N�Ju4QV���e�g�e��ú���:�8W�u�l2+J�~�S��!���l(u�ND�#����_�O�A|���g�v,� �̀:ΰ&yG�Hs�,��Dr¨N�,T&�꺵�ք]��"�)��;0:�P���	�x�q�6��<���%�E�튊%�����Mj/���*�P�X�n�#�Y]�h.�P�*8u3�m_r+���F��|��M%:�p�,C5
�
�#�Di۞ Nv����m����"��p�' �Abl��!0Pw*���Y���V�n���W��v�ҩ#��h�9����ø��L��pS�w,�Q�f�	��܈m���&�7>�b<T�[/��yY�i ً!pY��
YBm�SE���NB�
֊8�s��670��U���a:�V���z=I|�'�.Z�53���v]a%�<S*RCx^.�h�� S(��Ymzl�-V.6��M[,�"�u/P� �,y���_P��8H����Y��/�_�X�<:��5�O���i��
�dVO@���@}��\O���=� ȤЫ�@"�*(�א��f>C��oʯ��ss� �`J�)�pW�˂��I��^ �T���G2g���N[$����8Gk�屧�ؕɁ���o�0�ZZ�*I��X+E�ȴ��t�ޘ0�	�Q�}���.u�Zg�N�;̱Z����<D'����_������6l�0){�h-�f����XuV/Xg��:��ή�q8>/^U���
�=9Ҟ�.�tpd�0f��w���E�7A)K�r���������0kfIJmL���d��͡��ىEI|�r��)K�{C��u	��Z#��4!ϗ��Xm�HnK���u�����V��Q��H�`}��\ݔ5�]][-������-H������`.�&��J�=����m��X���JȻH�u������ r,�����Ĩ��\3��a��Oyɯ��g y*D.r�M�O+޵��#]��U���%���ySo�QM�U>�jG1ƞ�&�y�N7�O|���5��w�֬>fl�gh5�]��){:uO$��(9�А=��#�1�D8sW�4��3�<,�n����Vx���
�2U8a�0~W�U�'H�,^Q���+�K$��&���a-�7�yOͲ��i8R��Z8���\\V[�yy��I�!�e'&>�f�"�:Q�<R��d�լf��,;��Y��-�c�"QOvm�-�V�
z�Q�i�[æ�d�n���5-K�:���k']�1�"Y��I�b�����J�<��=��<�\8xS'Ķ���\��h�6�(%߆�a�U/���z�P*+������5;���U	l����@�֦o-���S0�,��x��=��b�`#��`�5SB��:�,m>ţ"ޯ���Y8z����Luv�y5���v��)�>�	��	3�N$�ߙ`�.�֮��W]N��b�U��^	s���Q�z�j������Zg�%�5#CD�|�k�f	��	�+Ȅ0�Ю��(oU�˒ԅY�4��qt
Z8y�Xw�^�����	��ᇿ������|��o�p�g�P},��"n��7���ݾ��-���}�X��{�z?3�Y��G�_�6���O빹���c�~��������9���R�I���;�zg��q	.�pJ��J?�|.U���v��?�Y����r�����>����q����i~XY���O���jQ�<��l�G�o��o9h���d����r����3��(��37��`&�b�?}�q����b��]���[V�o��U������S�uϿ�����Ϲ���[����a?�-^f_yp��f�y:l�|���v�>���<�6�3����P>���_�,����|�;��6f�|�}Xkʥ<�H�$����Or�x���y���m�6/��$o�r�l����>���ǿ���Hp�.��}���]�Aw����3&\̞���������:g>��-=��Yތ��� �尜�lV�P��z�6/{[��{zۚ�o}x�o������y���X>�����*�63�zv�7+Gޘpn�J1��ih���_�IC%�ux�PT��Aj��4de��^�Q��L��$JZ�I�.�7�M���-�Ƕw�;Cr
�5Ť͆3��q�)�Nt��l��:ԏ���O�8��}J�]�8L���2b`�U1%q�g����@x�{jn�U]@Q?�4��c�ʍ>)@��)�eK�&rM+0�#��l�[x%�3�/�Pj9PʜI�U�l�����9!@GS��Kgm���ɜ�5�n:iTc�k���Iq�^�p�g9L�ӫ�}��f�8�Nc �3WE���1*����2?�E�ʺ��գK�.H��`���=E+$/��Y����A�:}F욨�2d��|����oN��^����DFAW�/V]=Vу_f@���E쌑Tf����V3�n�V�Tu���t�J�!�`*�k�����]Y+�"��	�"���Z�}��ݱ6���[�3�T�*�u�[p0�~c�Ȱ���fHU,S[=N#�А=?P�&�։N��#ճ��rp*}hh��8WI�k�8VM$���[]:Iv�|�J��R|WUB�w��:�Z�����6p�|ih��87��lG�E���Bn�Zr�jC��WO�|��s[�*2����/8�`�g�#V1f,|��CX3�kBY��4mD��MIqmE}�������R�@r���Ә ���Jm	w�}+n�����0(���T0��r6HQ��y�О�r���w����N�)�?!ϳ7�U	X'�Z%`�	~Z��c��7���zcO����MX�9��81��~?�_`V~��t���/֨eG�+���
�<�5r�U�c�s���0Ɔ�*�@��q�ҍ��1�?�J�2�B'<�Q��?�2*�*�8He�L8�*��Σ�]�sZ�"/Y7�.�8>=h�Ʋ�"��j�*l~�óc�o��I
�Tt��+s#;�4�f>��C���`�]�G��#- ��i((\Z�\�v��"oI3��vG�GKH=|�zT�?��/�0�=���Ї�����LhM���KS�/Ȅ1��3�����N%u���������b�y[l?����d3�G    \�s�y=�v�p�c�\�HZb��f����zX�fT*1o��}Y:K���<8���3Z0ʯ�6�)	�V#������1�Q�����X�nŗ�)�ʧ��e�e�+���tp��\	�P�Y�)�xU�V�Z��q�{ז�u��+��eT��N'V"ʦ���D�e��N9�����s�/��;}��\!�鹄�]ť��DKq�48�Ԉ����7�E9@�Mp�l\����nn��i������#�
��(d�#�wC��:+�XS"���	j�c<C���`o���p1�n��.�u��)��S�W��̘yy�@��svx��}�����9͐�7���"D*le�m�-�S�
k�ai;L�4�c,6^h",��$�Lw+YA�@�T,;v�(7�<�ׯ<&6���<�V0N�~�:�Z'�L |n�x��mt������R[�{F'��jw��'���8��<�ԑ�a�7f.�J1�GN*o�P��T5܁�� �2���c�	M1e��b�͵��Д��%�)���c���	&+#�aRGx�?��{�KV>��޷�">*�NmW�ۈl��#�`��RN���n�1g��2I�р�E��	��"��)����	U���Df�nI��"��$�e˕��:u� !r`p[���f	���yT$UŢ��v���a�W�[z�AD����s�	�`�{7qc����c5C"�`�6(�_�Ml��yÝ�������4�s�N3��̈́ڟ�ʶ	<���`<�+7QKO�ʩ��{��L@f�����0�0^��;�:��O���BKw��,᥮��y��u��7�f+3f�Ӧ�T૪}sRrQ��o��&��9�Cv��Զ�j��䤀��:��T��ר9,���������E:),��x��c��:�j��1�� R���ʹBC�"��qtɜ�77�AY�}4�p�h��� ,3`� R[}rٳ�W���� ��[�6�̢����:�%�t݈"�@��� ����9n�Cf~I��[�>����~��P�A�f$��S�p��;�:ҖU6H(�َ/x�W2�S��X2�pq�DA��Gݜ�;�)¬Gj��������~q���\PV"v���7���ç�v�������G��2 ]�b��rWl_�q���Zc����#�����t�]��O�(q�x�^�����ܸO�OO��}�Q�,�L���Vf�m�Zq��|x+vJ��_���
�l��t�v�~kv��v�؟>�����e�{�.���^��䛇�bU�m�y�����/�5�d�s���w��a��~�y��ϟ��/����c�AU<؏}���]�A�����N^���'�GJ(�B*�~�?m>.WE�����v�7Vxx�o�߿��9��,�55n|������<��0���4_������ˡ������O����ߚ1�ߦ�AӀ����y�����0_Y��W��$5��_fG�w�r�Mf��R	U�&ʻO�aj�f4�๖�o����_f�%Pt_�5��l����OE?��]��"i8~���5��ڑ�D��bA�X�Vh�n��HS���FL���}�Ա b��t�b+��J�`&D.�b]9W",�6��W��!䦤���r�e1\���!Љιv� �n����?�FX�Ǐa���<(�\��2G�	w�8�h�Տ%��k�4���t.�M:7n�Cn�iW:�ο��B��n��)T�9D�em��;;-�D$���K����W��r�N5��Dc�0<�b���6�\���j9y�ξ>��A�����#���F�9<���d���Y�����,�v��K�}��Q6�OFI�(�b�5��Ge�C�.7�c����)�q4nĮ��7m���xg�uN���<;ݶr�4Qu�r3P0���Ծ ���m��奀�C���||�Y�:n�*�q�ϯ���Յt
���v�j�GS��� �BG<϶��e�5�c������gCĮY��ؼ|�i�� ��j;No���u��1��;�D��\tH�4�S���C�~��w�o�J�0��Jݒ�a��М�'_,ʹ��,<%֣u��-�M9L�c5���8��MOR��d��T�HX��5{�`8>�+T�tK������dN�f��($�N_�&�>N��	�x~�Q��������;|%��Q�$K����s��B�E�Z�ꑚ��+���QQ[}ӳ�Oz�(1�	y-���U�8�JsH5� /ӲD�����	~���k;�
$�,��@}J�����X_W�^�5�a*�wYjΜ�PjV�@5��VX��]t֪�Pd��ʢ��$��2�hT��ʌZZ�s5Jr54.|7߻*F�帺#O�m,r���b%�O-�#q*B�e�+s
�;8w[����h�q�D���X��>O�Y�ɢ+aQ�� !�E��Vj�$��u�UƙY0�-
!����Յf(ܡ����3
eU���[ƽ��1u�5�*4l/�-��L�1w1�.�wXț�޼�J�d�������k	�=�)����JqK�%Q�Ϣi�y�F���n\I�S<��uS��4�����R�fǳ	�T٤NO�y���F��,�Hj�d@<O�5�	mj�k��4����D�}B炙�@hy�v4�e~�.��l:��5�?/w��r=��Y�������T����~��-_fƒ��å�����T�҇K~�����f�<��|��m7��lV�m�ˋ��v��X�ݯ�:�~?�尘}yȕ��V�_�T!�?oֳ���a7=���
�;4�l����r>d����U��S~�eN&�m�#�b�i��`��Fy/��U��Y�F��χ������������y�9�������W?���_�,���ל�V��rt^ͳ�s�-�×���m����6���Ͽ���>y[���3 :���+lb>�[�r��g9,t���r���m7[�?n��PP-���f�rX�Jo(��Ь��{�H��/����g�2���}��Ͼ���hB<����_��_�W�Z�B5^�4��7��@u�o�g��k���P�5I�LBi�,��̂wuk������G�J��=۪��ݍ�wo��ud�c���CZ^:	ޱj.C���-�x�'x�xG���4P{�4��"�oi��]��u�E	.4d��`+�cjW	�׃�R�'7I������u�[2z7)^\�Q&���.�FLip����(�Z�YJ��Pp(t� ���7���Sy�����y��l�&#IƈM�tlZ�7�"��qUt�O:0���M �3��@��#��-H�)�ïf�8WQ�d����2�Ɔi��}۬�%Z8�2ǻ�����nB�&j<�uX�B��E�0G\3f��F�����,_!����@��F�����hYA��Ac�]�������I{LAc�yȾ]MB\sjf�
����WqgN����o��kf��`6�z7�At��)y��@p�?7�X����3!�9!6���8̉�[�g�!���vB����[�� Y}����R���Z3�:Q��X�/׿��4q�m�6���|�+ӱ�eY��KS$ڱQyO��RKO��=��`>�B�����m3�E|��	�Z;\��f6sN��P�e��m������+�-�V:�F���5���M�	���#��iK���B;}ݸ�7P�Fw�������aMH�i��#|E?�$�Ԣسa(�GB��Y0����E���V����p7v����a���w�n�E}2e\ȲX���˙C�\^���W$��zN=�fU�+%O��L��M���}4MTk��sDQ���]@��IB�A,���A,�QQ��gK�[I�c�bb���6�#(B
�� N'���Qd�����pZX�YOɧ�E.�u��#Om��<�J��nmnS��Z�!��z%�\Z� S��,�"�<���=����B"��e%-�S�����F��'ǻL��}�*%�E�pBD��N��ω�La�<���}�/���~���9e�rc㼕p�O��2��XΎa�*j�֝�ɹ�N�[?>\*�V3Ց��o/�ဪk���y4�:1�/-�N���r��/    ���窰$��S3����s��V�<?��G��_����悪��jg/TUO�}\�����=o�o�o��U.9�*޶��|��^O�H�I�p��Z�6B4U<t���c�y��lJ�i��R��*�|\��_(�~�s���X�k�j��n��g��y�]a��?�i��庫�4��o���X-~��_��֌��6�����?O͛�_Ǉ��§��Ty��|�2;����#oj�t�wW I�&8ZU�_�oY��#4fK��/3�2�\��̋����JN�����,nA�)�v�!k
 �pȔmA:��k������3�u� "".�"�ZF�m:��84�$�߸����ϴlj�QZ�×_���?�l���[�~�����ǏA�� �\�Y+��6-�ҕ5�E�k
��27�S�	��cn҄q�&(���ޖ�@�4#3/r�������CIO��]J��f�f
7�/�M�.56OM�Ȍ_h��	�Xx��7�>X�|�`1�K�f��I�c��K�=���&�������W,]	]�~2E���	�xQ�J
0^�R�X�g� D'�n"�k�0���_f������rz�pM��2PrKd}
�`c���h����H셇�u��`��,a�VmR����Dm'���X��~���<��B�-�r���6��\'�e�\J&�Ʀ�h��6��bk�i,:���w�U�Ƽ2�6�5bC���#�4�2�H�L�&�5b�����!R��GiF�w��jO����*!��=��\���Z�U>�����)�d�iGWD�Qc��s1���.؝5j��;�eA��ih _�e;���J<*��Nv�f�9ҩ#�Wzu�:�mx|�(�R>���e�Ëp3��I [uvH��s����~� �ǳ�]����P�h��V���w+��_S �v������h|�p����oJ���Y�
x�ln�ƖOi�8fGB�V��aNh{�b#I��!�r&SG�f���X�\�i$�j����0yY��v��q��HEys���=Ú��.�	���MW�e
���s:���GH�f=vW��n]����H��Z�����k����(%��(i��� <���^�灳t�+��L�q��U<J&ᡣ�V��H[�¼ʀ�gT���E�]��Rz���Q�)L؋�"oHS� �)Dg.z�$U�kΝ�\6���=P�/FZW
��̮]J���%a]�:)�C�@a�E8��(�o����e�T�r{�:[���@=D�5��T0����^�YS�J<M�U�d.v)���W�������+M�Ť��
���I`�qt棙��p�޷�]�e�DA�(yV3{��beȀ%<YBԵ��%<�XW����ĥp��ܩ܀��Cl��b�E<N��=�"�u�BȚ"25�!4s������mh������g�"|�yU\�,C��G9��ά��4E����.R�ϒ�fpd7�xo�6��:�(Ӯ� h�g�Yp�*V�diG�1�Xgf��y�`ɺ�El�WI�*-�ؼXh�1���8�	g�Ac(PD/��p�/�(�v[�u)��u���	a�.	�ms`��6���ܽ
J���}�l��9-(��CU��4��c��$5���~l�}]~�a�������t�����J+�����#kW~Զ��!p�}ښ6ۦ��ϠvÄ:����v~�L�n�N��D���ȡ���9	y8Q����pƋ�e(�yJCWf���/j�u�T�Qڞ���B���#�B��p�]�CC�܀KoYd�5^԰�Z�[�j�9�������KJ˜�{�{2��IYkX'�Y �(�y;֎�6��Z�s��Qg�;$����&�y�&�Pa	;��u���E&h\^�Mk9z�fC>\&ͧ��7f��4�џ�����t~���ю7^#�%���%20�މ�{�e�Y9�7I��lO�
��Q��c�k�4�N�VC��"��b��i<@D�����8X�9-dq>nN���lI��s��sZ��ݜ�����xLD��2�:�o�1�`��p�ds�lI2W,TX�?��������Ŕm}��k�Ȩ<�	-�O�.������p�뒏��~�ABC���-Wv}�e�BD�F��`���I�s�C��XS�2]��}�B��̩���.ں.��E�;4��g���(4�А��j���#��.وDϰP�RT6�J��I6���cȓ���*{f��E���UV�KjH�%5����B��b �/��� � ��n'�^x,t�c͚�-�޶���v�����i�Z|�^_��_����p�����}�Y8^ŴL�J'�a�ۿ��=��K3Hs��	i�/,�����i⦍;	Q����8I3'�6RM��8�ڸ�[�F�[��b���t�\�T�x�aeP���Q�$-�^�Ou�W4��p��8�Tf������I�nv�����m7F�'�E��i8����e\b�,�`s7G6�u�<?U17�sh��1W�y�6 aM3l$V߯�,;7-,�!)O��eud��,�p�@��u-4�/��;b�u�h�h����j������p�lK<�4!���Ƃ�kn�p�&��$�.f������{����+�Q�l3`�?�k���|��rs*�	����-{��)Od��^�!��.(!����5���4u��^3�\nG.���Z�n�CA�_0�k���̤D��׽�x�/q��I�-�n�;3����/3 %7[%�U��C� 	g�5�3��GBk=��A��>���O�ǋ++��O���'�+��P��� ���\<T�´��;��6�ڪH�Kc��f������#Q�\���qR8(R�RC�]P���CP%4�/t2;�_���L��t�.�+;R���|�Q�����ɜ��`,ݖX�[B�ɛ�I,����>r�>>nb�XlL�ZH��,��蹵��M���֯z���Y#"�k�|բ�`�8�w�#�2�p#��#��
<I�hS������2@�pM�7�N����|0i8��惝���������~q���<��*+�u�1�=�}��i���+<���jn���������B%�P������em�}x���W�4?>V�*����b��E�����r������}�|z�����s&�2��Ԍ<�ae�ܦ�7�χ��|i~��?sQ��fO�Y�����v�],���>.{zY잷˷������v�*޶��|{ʿ��ٚo���|����~�tخ��~ެ���}���ǿ����pP�c_��bW|���l>���B��d}pO	ef�Q��*�|\�
=����v�+H<<����ߜ��?���7>�[����l�}W���|��v������P����ߋ������o͘�oS��i�?��c�Լi�eq|��,r�+Ku����/�#ػY9�&�C�]���v�+E��xϵ���y<j�J?�̀����P�VֿU�9�V�b�pE��|LI��M�ry�i w�o�Ѱ҄+ä� �o4+��{}R��髗h��β1��O���-M���x0�2�p�P~��<X2�ff���n*-�6�j8f�8�HuF!No��Q� �[�� @��?��mk����f���NC�:��v�g��r�T�Av$~��{_ �a��@{��^ɿ�g�N����u�1o;�e��W�Ήlu���Ҩ��Q���H:�>9	z���:��Љ����]Ə�f������Z��V)ks���\��u���+3��wq���Up�+ٶ����j:
'��!է��C��������k�):�Ƹ��]�&4��=+ܢ��Pj�L��ż��X��6�G�Y*<�$���7�P�>�����*+��iH8J�&��T���	w:�QrW�!{N��'j��H̚^W���;`e�q_-o��C�ז#,C�J\��֌f�(e�HWl�(�&g�����2��{�0#���}����XfK�R�^;D.|��ɑ0�DIk$H��r�	�M�z�OBh_��8pd�f�@��݄ fd�5�z� �K�Uj�{R"�X�Vڢ��fJ%�ڢ��xM3�¸ۓ    s�(��V��e�?�(��*�2�k"�N}���+����fҁ�q�`<?4u�pʄ�g.��z�%�	e������v;�n�j�u�������nѨ/V��Vfe�Ģa��m�8a�c�ӫ&c���������Y�՘�=`��i�D1~�6AO�G;�ybMAe�J�nJ$h:�hfX�#O�|T߈(6^۴����t��(�m� ������ӹ���M�)�*J��Q�����;�M&<��� �@��|�Z�%����OW1]q�P��g�JC�	��'��)�X�nU����	i�%b��Zi9��[�!2�W/��jdBYQ�5����xwxͣ��T���c.��c-��H{=�᭲"V�\�Ȗb7���1>	n1_m�//hp�B�2!�3�Q�I�EX��X�P�̀���*���l&\,|�mC�:��ח�]0���N�ר�(i�������
A�rB����3�E	�2�Xٖ)0F����8�پI'	0WvP�\e��k'��ʇ�k02x���n,c���4�N�T�	[z#��Ղ��J�B����n/^�㊶x-�]�+�M[Φl<]��,�(0�|,�e��������F�.ة�-gh(��DZ%f��z�g�$M��Ŕf����������/N
^�r t�R[�ˑ�X_����V҉��sw< gUpe[�f�k3���fI�rr�A�Ɂx�/�K��8y��O7~a�N�e1����+d{�������7TR�Iنڋ-S�Pv���ĦnE� ��!�*��OE~�M��"?�vR��� v���8ϵ��m�X%X/?-C �X[�q�d�n��-=`j�9�䟹��[~a��}\%~픥c�s{��sk�y3+�����~)짛�%�h��Yj�xḭ8+hjQz#r�xz�a
Y��֯"'�e2B�E��\�����ɶ_�e+C��e��0~4)�(���3����Aw��ӭ�t�N*���0�qB{��NF�C�Bd�5����;,�8�n��:��QL��^&Ҏh[� c*��dif`'�R.ڡ�1X:,B]>���Z�Ⱥ�	i+���5�����H'�y�Y6m��$�u׹�VM�}
�ⳈVB��1�ίF�<����0j_�JP*vm�3A	�>�e	d����5������,:A)o��`yĴ�rq�@>�O��A��n�a�M	.s�;�^;:\ W"��U]dp�|aF%��;xT1�OrY�]uWq���@)>&���P � ������kd8��|5� ��������}��������(Q�А=�]�:������E��[f�l*X �3"�-��Հح�E���-�_�H%���H�Ո2�n��ru���YL7���ӄ���l�`CX���`�QiF�����WJ�Y����il%�������$��ܗ��B��8Q��HB�F�ģ�\���R�um7�̘�g����,(2;6�b9F�s(���Ic�V�V5�_p��H���"�-r�
16�i����jq*Κ���6��G]�� �Hu� �;�SX�9�i���{'\62 ��uW������gF�0wru$P��^L/լ�a!d��ԕ����	Ƹ3�Ɗ@�	Oo[S�i�az
Ņ�W[���(�?�����Cfו<��2w��X�m|�y��۳�vS8��Q�c�����d��ƐB�S�d�8��71�U<�6t�b���0Rg�D���2�Ϲ'/�m����s�~耦�bb�G�Y�L.J���-=F'�%�yB�uHX�w� ^跞�xBUu�37���)?w8�S4�ԃ���	���f�G]P+�r���\�U��� ���268��(7$cўB3���9�T�Q&�����I�ޞ�jֈ�X�ZI�������H��9
<�6l�:��[E>C���<��=���v�8El�*�� ���B�Ț�X)�ەE²�k��_�j��x���$$LY�x�۱�`�Xkxs�ֶ7+���]f��U"Ƕ�Ns�7����X��ښ�bj뾆-����I2�,Zl���iG�p)���H���I]S����["ݶ�5�e�����E,���H5�ooRdw%�Ս 7���,JAwM[�AI��)f��H���v��m��<��	M��N� �.<��q=�������K�`e��k�u}���O��n_�17Vs����e>��������	�q��2c��|�N�T��ݗn������ ./���r�:��i����r����Q�S3����s��V�<?ފ�f~��?�>���8��L��4�|�],���>.{zY잷˷���e�y�.V��v��oO�7:�"[�M�?��x���o��U��ϛ�~���q����?#���~��|uX�������u�R�Ĭ>Y/b)�����U����\-4wOoۥy����~{X�������c���q�#��������w�	N�ȧ�j������\��o���X-~��_��֌��6�����?O͛�_Ǉfe��W�j����/�#ػY9�u[4D�H{>�[�OjC�-�Y��-Z�����2�\"���F�2��a����X�w�z&�T&R�[�z~gC�w����R�%J��Jƺ>�FyBp�XN��߰Jn�X�Hh�B�z��i�3�]�Ŭ*�����`j:D�Ij���{JRs���t������X�A��6�:\Wg�,��pl�uD(�����-�w�Lc^������	��'09(4}�N�J��E˭�he�SG�!�^�Ck�-�w5͍�ut�P�δS��t�b�a+�ǣ�Ǖ5�V��kf*�oѤ�(>/A�6X*n-$�{��,g��t�~��`�;{��k�@�T7�r,�	���;+����[��0�+���� eeFm�8u,4�Y�p6�4`h�^��$�W��N��#A�WrdU����-Dc�53.l�-��oݴ �h�{#�`iƱ��iw�-͈���k���%O���9�@$/p�3����K��]p��K����D���JCY�6#��.�w«�p��S%�,�B�M����(b�����Np�?g}������bD�ư&οxB�k3��ňd��+�Z�O��h�A�ȯ<!>��y����Ƌ�Q[��<ݪ�ګXޫ�*շ��+m�p�.몽�S������c��k|��mp�z	ׇ�Q�D��.��g�|tvC���2b�G)�(-�N�DE��t��l��d�B�B4nԮ�r$E�P���		e|<�	��Mvŗ )տ��Ҧ�!v�,JG�FzU58�!���)ّ��²x� �c�tn��#U0��~�48�Бѳ���7���� �;����g��P9�69J�_���>�O��
�v�Ў�S9��T<>6�"];�۰Ru0��!z��vsV��$�ע�!��Q3{mWQ��w��x;�P5R�_�@� :����f�WE�n�.c�k͝9����g��ć��L����ձ#@\i��:������S��ŭ$2�N�y�۳c��w�0ZE:x�xW��{0���p����"��hv��n��� nZ�(��� o��8��4g��%�$@,U�[S�9IRqac��ס
WS.�m�9q8GI�F��f�V%��"�3"�-D��`�ki�7��>�83��cE��k�*� }l����H)�XuEwhmaF2�#����Z�Z�rȒ +�#�W����X'�ޥ��zp��;rP,���n_�٣y�ʬHH�n�g. ���pa�cù��N-8/��RV�DyD�|���t
2b����q�}��	�&;ݺd�"̝���͠m'7���(��)�T[�����庉q�=�,eN#���p�+���`��;=~��/MWN2�D�&HU�V���<����Ti4>��6�qj3���/(��Zb��̲k�Uvd0ǢM�f(T�s@z�4#5KYf�lUy�<������"(;�@ډ��%��E�p��<�fŵ�)�:�H`��"��*S�n4�k 6j)��܃���6F&x�.��~��}�ȸUDL�g��-�I� �/NU�E�˲�ٻ�z�j�-vE�JS�(7�N��l��
�	��y$    m�V]-r"̝���,y��\���~�W[�32_a�5�)W3@2w�!wIڑ�#�Q���*����]��H�%�<�"6����ow]\`��z�����l�^�QH�""+5���]ݨ��NQ��DiTPA���y���Tʏ����;&�)�J۷Dj?� u��c	��[�AǬ%���b3���HT�Ռ`$�+8-:˪��%t-}�)�9Ig�gR3��C�~����h�e�,�.�Dv��{,��RE��I���e	�A5�Vv�$	�7U%�p�kjJS}�p8g{Kd�8���V���z�*���m8�.邐	'(���J�n�M���P��,�ڞ���_��x�����ʤ���0Γ���u)�T��f�J%j2*��
�O��鱬u����NSfQ����i�0��Z%to��4cc���l�P���"���HܮK:��ȃ��H��4�E���G�!�cz�:P>L�3a��<PE���	A�r]O�46���%��8B7a��*Zi�*�k:h�a����z�y��}��u���������|���1 ���b�!e��v�u������ʯ�dRf��7D^dTr��&�iw�w̨@J�3��Tz��P�5tȰÔ>�9]e�Rz�Yn#��n��e��q\�J��G��p�zrN�6A���a���ɼ�J�������j��pռhiq^�<1$�g�������� �/���m�G�@�2^�� ����|w��{�N9�S���j������vu�z���~z}�yD�V/�w���+���Gۻ�Ý������/����![�`�r�\����V�]����_����U�k�?���W/�����i�)����r�������׻��>�}�����i�k�+�D������������m������/zX6�O�7;�B�/��u����ǧ򻯊nɻ�>s�x�yy���u�)~����/~�����}w������?0��w�O�����e�{�.>~���?�_V��-W8�Ǉ���_V������V{��g���[��B�'[�]��/_����_�ŭ�����痗����?���~�-���,�?����S��}[>�>n��n�����i����rw����/UŌ�\=����{Z���Ѝߜ���?�a}��ږ��w��b�n?�lVŋ��b�y}����~��������Źagn kl��pw0���\z�����Qi�J��%�yQ�h���L)�6�"��Ky�2�#�[]\eU=Iq>fUL�:�g�v���~��h����?�/��;F	2(��ܔ��9	��8�T�&j�Q$6~����3�21ٕP�ram�<�����T0��O�D
ѱ��d:��VV<�ߌv�y�g����	�O�nJ�>����xL��]��jr��fB
CU��nBC��U(�X8'u\	����敁�V����Н��i�v�T�k ������W�L��!�7g�D��l0$�!=�
I����?����j��������i_�>�V�CtOki���P|�����1���^ܱ6�
�K���ٗ쨥~��T�O��T��W@�ٟ}K��w�?_T5��ÛDxzV�/9��d�󆵩!IQ��QdS�o�_-�ʼ�\��?f�zL�"��y�}��h��=�e}o�p�_=�3�A
H��8q��#
���Q�;Rs�ې�j,�&p��啹�|^�綁�h�,�h�zt������W�� ��#5¶�#!������Uդ������c7���e�0k�2Uv7�uZvy�\�n��Z{�W�($5��v�vx1��c�ѧe�Î!���t�a)��d��`ͼ�
X�`�"嬀%�ż�8t����&;���ov���طr';Op��#_Y�A���y	��ޅ���vc�O�Ʌ���/���~p���t;�k�!=I�8"rRYɸ#�I�4�'`ρ�y3o��� ��h$�j�e�������Ho�>v����Cz��L+"����&�1���\�X�]� `Ѫ��Z��6�Z0Q�9r�`u��kIhN�gȸI��u��yŹ��E|��J#�Pa]7�; 7�3�3(&���A݃�ԙP��.u�9�G�������r�o��\����{oU�X�HƐ"K�T����'#��ꨍ���=UnĚGvLֵ0��X���h\r}=.�XO��EL˵r�u�8P\��ÎbB��TF+��%l�#G�@�	1v��D�16s�΃w 2���@Fy�����!l�����d�=�P)��J��[O��o�4|HO��ͯ#�RW���H�Ҍ&�)���p�Mq�k��6/���v�15�c��)�Y���`�t�H�5�U1߽Q���U�-.���m����m���16�i�\L�WvI1�����́m)��]��5��8խ} ��F�N���\B�	*����ut-������s2�B���*y&s�j�D�$:�.r�\^�ܖ+�fHD�>f�Ҧ�3�^�2[8)io$r�R3_��`u@e���xp�󱥻4��т0�X�8���+���65qZv�4�H����N�z���زarU��z�xG�poP©���T�[4�3���V���98�٫�r��rE�/���h'4��q��"��U�
�?X]��cmwi�'���ՐH��Z�6:�9���[<#�μNu��6���Ǌ�vEo���V���v$�8E�D�}��*�+�X���D��5��W�UJ	��H�i�������n���y^O�wJ�놂ݣw@zE�4.:��c��"��d���2�u��2�p{�=�bi#���)�KO�r4Sk�����m�ys�(e�e�wQMoy��b��Q��	�uvĶ�b�Nk{�$HXˑx��B����������;9R������G���Jv����s��r=�ޤf%� 2�Jޟ:����Q���d��z�JY]��e�:�����!vV�ҺD�L&���C:`��w������}��P�np��ln����3J�Pҝ*�dnm(<g].3��h(�R�`uX�8��]3���Tlt=�	�0 �h4^��{���I�-\e���Xp71������
lD��A����>F��ދ7C����d�o���H�i���7�bu�Q�Q=��r{`mP����9<&h���C�y��oK�"�������Gs��vxd�B��[�y�����Pv�M��C\&��aG(f��z���6x�h-�`?ێ��\ϟ���!��|xZ8� �l@<?y[㶢�R���<;,�i*n�� $[R�;��Z�d������ǧ��z#����_=���/����w�Ow�w��?����OL}2��/�&����4�FC�,�ۿ�7��Ri�ʖQ�SY�y�Κ��
g`�AW�Vm��]S���NfL������qGV���"�̎�x�ͅ�ҟ�(���a�{L���Nl�-r��:8>>Q�7�w>�6���������'��e�����_8>��/�����*	�� By�A�D�O�#�.�����y��p)�z^�V˧��������fW����\���ʋ?<��zh�������m���>�}���tعE��?�v������~Z������~�z)����|�a�������˧�����&������e�[z�<��y�~�-�w�_[~X��u� S�ڷ����v�������s��~~�z����gl�E�����S�����������������\��??�m�ջ����?��_�~�7��?�y��}����ߩ/U�m������������k������o?��?i���������
��-����ޕ�4��yC�2<���p�'u�!��9v�J�ңi��f(Z���%fTſ_�\�(i���"&�����6�<�(��[�� ���ԓѫ�	�c�!m3�j���;.�!�h�dzu?����n	���6���3S�g;b>/�M7�D?_�i�F�Lʖ�g'�F*�@\(��o[[�b�ʹ̇�[��&4�8�޲S[\���Z){.�p�h���!�+l��Bv�PĎ�����j��CLm?�J3��F
�����3�Q��28v����MK��t�Ȏ8S��3�b�    �r��y���	�M��S�v�hV���Â�=:��v������L��л��![K�t�A��"�G� ~w�i8��:u.;�N���D����:�c<%=�[������H���#�U�<��gba��2Ҥ]�\Ɯ����U/� �t9��Z�}�:��^It>���������矷GR٠G�-�n
Zf�C9#>���<�e�*�yS���œ�{(y^��.Gۨ��W��Vr����r� �P������k����@x��{�.��z�6&��]�������b�kh��g�? ��w��:����J�6�;6�5�Į2��1��j�
Wl��ݮAB"4���E�;6��]A�(s
cC�0���ţ�Sz��u�aL�ނ>�8�0u��+���h�j=�m��F���J�f�1.@y�Vl(��v�vո��=~c��\�߸[�O7NWL��lh_(�Ug(����Y�S���Z͍m��|Ne"����}��=�J�e��2��l�+d6Z����h�P��S��E5��`uI�5�G,�@m[˺yf}M6���Bq��a�A�:��ۖZd%���x�J�d����<#V#F�X����/�dRppI�Z�:��]p
 �r��\8>����cMN�+�@7�����f9>Do��	�$F��K��)�%�A4�U~�!��n���K�p�0�{%��ڣi�Jxj$��#U�a�8��]>@�c�2��si 
��f6 ֲh].��ta�A#��&�%�yC%s��>��%��{,�o�E@����)� �4��BE�Fd8�S+u�N�c�;-=ٺ�;���E����H;�D��!҈���/ڕX�`: J؞c��rߤg�+uT2t���A�d���X�Wc��@�1�3��J�B����O䦵Qd\�@���~�P0o�5ň@�l 
��u^=���_��ſW����	xL���s]�u�ͤ�69>�)65�ݴ`?���^���<遲0]Q%����N�%��O��sͫ���n���ě���fѼ_����o&�x���4<�N�̪(V�v
Հ�6��zf<���[��~�i_߱𪅚�,6��=[��T�9<�ɳ�lT(�\T���$;1������z!E�@/�K�Q�z!����y��;�<��|3= <Ld�E��-�.����I/��SZ���²Ԏej��$;��j[��x��/SSԅ�"P��Ĕ�\0��X�"��!���L�Q�r�!�X%�I:�Y�xo�Jc��=����vA�v:�y�����^�A������#���~&Hy�:�D��Z(z��@á��;i{����s�Z�<�;�&F��K %41�����>����K%	���^ǝ

}r��r�'Dbx}jz:b�x)�^$2���A,��(zj�Y#���b�6Ӂ�b��,x�F^�Sv���x�rj��9�_]P)@�k3!}m��Ѡnzh�E%�>,<TG$8I�c�ׇ3�����U�L ��#&|~]04C|Xb�n�i�h�-`ĥ}p��$V�邇���O������������f�l��/�w?����Ϊ����������ϻ��ſe�ZQ���;Uӓj��wt�&<��'�ǹc��U �ޙ�X#�����.�mur;\��<�VcU��Ѱ�a�	�ۿ���9mR�Հ@��+r�r��94E��(�B�Q��ff��iq�S`��
,Ƥ� Q�{��e�������s�o��Q�*��Xl�Ó�&�8OU����v�4,П��������ᠫ�w�;�͙L��dU�! ���X*����V��fL��O����&�R�z������w�E����%G�z�i��(%��؆�)��^oڵ��b�*�5�M��Zl߸q\��p1�u�4�h�^Ȑ��K���JNHǮyx�����H� k���S�cܨ��z���m�Z���'*<�F��L��H-�ګ�;27,��[�w��h��f
!ϴ@��|QC����
δ`<�uj%���)(�C���81�r����X9f>蝳(T'�B�#�OE��8(]���޹�{�˃}����,��D@��S˚I�ӕwZr���B냎��y!<��;/	�*cq΀�>��/��7�rw�����e3��j������n�\pp�����~�FZr�::~^<<:<@�o~H���2x$R��Ύ[O��B�u"����5_w0ny��JAS_�T����V�5�9��6ⱹ3l� �)L��o�Wq�\��HϚ��%���JuĖ��Ȱ���MP5&���ÚpFs�J�.��Q*��]Zf�5�2ǃ��ѥ�c���O1� ����P��_�]�T�R�m�����������Q��;�Ta9�#�b2*q�/��i�� �[�1rׂcS�%�s_�v0EZ�>�"6�k���vY0o��-��mjË�0��ee�X����+��	,Z�s�c����n>g�a�`�촄Yv��FJ$t8E����f<�ߏ�A�'��x�]w�Z��5�"���p4/�f�T�G{*O����7}	8��Q<��y#��U8�]��=�c��b�vP�L�V��6Т�\��Vt	I�2��꩷��eP��I6���^�*�.�M ���YzqE�1�L�K��;�Q25��fF!镱`��ⷣ�F-�Z�б(�՟sA%G��c�UpЬå�cL�P�<P���1�ӡi��I��x���!K5���1�\;����Ӿ�;�.J5Of~�в��se��B���z.�	t�������_㽴y��r	'�Mb���7�Y�y
�P��|��h.򀶃��n}ŉV��Msj���I]�F�s=lk�[��P��G��W�כs��#-��E�x����"��Ւ��,3>���}��%!�e�.K\Z1�!7����	x?즘p�%V��ؐp�������A��%���[Z-��mϱ�7b�F�!!�sPl�I�w-�g�ly�B-8)������4VXVcI����V�Xm���m�o�11�8U �9��¨R�%Fu���c��ɔd���M����a4ajֻZWu��;�F��P�5r4h̄h� �Tͻ�[[LLĠ�V���S���IU�Յrp5�G���%DB���
����Ti�"�rC�c���LA���bD��ᆶ[�@���Ќ�������df��ʚ�L�4}�&J�,�6�.��W�q��`��Ύo��ok�A�u2 2'�ʠ|�\T���ҵM�"�.�.1f�������1��,����G�@=��)����E���a�]ڡ�̂�n��B�P-�<ses�:�7ZpNfh2���1:�0V�sZf�3��~�H�Z���ae�LE��T�rw�i��P��<3&Xؑ�"l�vw����=|�v����lRM=P ~��܏�m��g���R�"�V:Fme������7���0ֳ�ۮn�9���Uސn>��ܤ*�C�nhc�u���~�i�m4̝��j�֠�X',s��Io�b�g�Ax���S����4��$�����9�_�i�m��[��fE�j�V:X�d$m
[*�<Y4�E��Z%�k;:H%x��c��4I�����πB��2���`yG�q�.�=�ɘ�A�}��:�'Ԓ)��3axGʱ6�Ci�἗X�)�������#7��!�f38EGtNq.I��^��U����s���R�upr�[KZ��7���e��cht0=��:7:6���FD��qZ�X��q]�����l�J���&���J��R*�2�dCC��mI����(KϡLB�{<��{��7�$���E_bZ>Q�
ڟ�.��(���ќ��������Ӄ���9��?�2������̲�e�q<e!�'*�giG���G���
W�';I�L6���V��C��5DtZ��\���.U��rp��@vp�4{+�8xz%�[�bl���hx��A�KBa^Q#})��( ��3�$�k�l��?Y����H���2P�G-��zv�y��g���(�S�@��    �:��A��	�j.U(ZS��F"�E�Zh�wr��sz��`�����j��Kl�mZ�\K�P&s����Pc�gb3��0�͘$��pҰr��������s"�-)m�%�fZ�Q�F�{��1�*&��ݺ����@jmBM$�&���(w:�����M9�e�@�{B}}�'�2�8�2���(���N<���7�"[��]3{̝N�N�.�v�:ۄN���j��MS�/{u`�f��$����j?���B��Yn���cD�F0�T�����U�v}\��
eG��s��7pU&B������U�)���o�h&��HD۷�&���p5�GE�k$�T�`6c: ���Zl�KC��9�0��cS�^t� B^�wu@Lg@�|�����VF�G��f-��2`��\2JWk�"s��>Mi� th������ ������'��8�kj�;ן1h{U�J��u��������������Od��+�#���5!�6W���+�L<i��C-s�8�Q���eC�(����S�сsR����m��	�"yf��D�X�9�~M��S+���R���ą���&<=�LI��.��R#� L�;�����Id9�$E��6	���M���R��/H�,$����\.���JG�R�5s2���\���0�r�=�`� h��s�������� �I�v{��Jf�C�S�������4��,XY��թ���j�Mft�[
�ky`Lf�����1�����{�U:��{�xER����R�2��0)�����7Ѥ}k�P��cW�!!d3)楻G0w��R�{X]�)�[gDb���*���{� ��8 ��X���j�Ll4T�r/�ة'qp�]y��a�x�:��P����������ϻ�_�ɤ��d(�Jtf�/|��F���_5����۫�gڄ)$6���>4"�N?��3��XQ(2o��::�98��_B�3t�#�{��a����������EӜ
ޖ(�1��M�F ��(1�A�8�W�*g�&�#]f������}�(֞�h�£��ߗ�}���7�h�F?-<I^����F�9�9�X�K�9P�³�r���Tf���P�q?�p-�� tH	k�s�E�2'7���=p�2M�Ś(q��t�K���:�\b���k9�L1)�w��(5��s�������a���i.��2��1��Y����"�-�拹iK����Kqt>��T�1�n�ޑ�aH�@��:��4���V���X��nM�G-�(Kf�u���m��h���QhІ����`�� )��<@vm�ؐ�	 4����w�ؤ�뙌��[L�\Y�`���]b	��r(����L�,GC��7�=�.��c�>D��w��^)�
�N#ݾP���ܔoMR�RJK���#c;xi>f2]��Ȧ`�"=�v�5UyO*S�b�m����PF}���� �1�K1ALsd��ґ�L/��� ��Pq�P#��	�Cs�K=KwXsF���Q]�����p�Fω���b�z�z���x8t���K����GKs�Pd.�9�J:�@��x }�z`4�T��d�]9,�J���F�L�=�Lˌ���tZ*��<X]�r�>Poے�dh�O�ϱ]��(v�g5���<<g����H�H��V���ӣ��X��x��yi?��v���9{\�s঱����r� Db�~6 ��\��c邀��?�����\�d���`dĪό`�uJz4lpư�����������z��������/��z�/ �}t�	�G�ci��?={Gz��=>�}^=>=�}W|I��,W�~��?��?6�`3��8` X�"�,x�2��.1�y���(@��T���gR���X�%�5~c6���g���ghUxZ(�,�lfepH�<�i���CZ˦C�x7Og	�BQ~���.�)��Ǉ�'�j���>�R+�+��J� �L]��K���������/�7���+�5��w�R ���}^4�X�J�ф/�����M�{����Y��'_�O���G�sH�9��������q����O��7�����+��'��w��u��w���~ V%YU׊�(<����a��K�-��5�L���蚆X�f���]�~zݮ��C8q;�wǎ@�v��	�����)�5+�U�n"��Ȏ㱮E��C��b���Z6K�Q�e������=+eb))���΢-��٣Kk��Cn��l��Z�Ml��نZ�i�,���sFRG_��;ydG�ǆlm� C/�c;j 1��829���4O.�%�>�Z}�e/ttK��G�'�&����4� R-�����F%:J�mElЊMH||�k�6񓠿Tf�b h�%��N�iL���-�"W�@+|�r��($��xR��q�2ƣ,��&UsM��\�����8�9�ٸnp���6Č!]�G����>�i�zjRphL(���镭�0�*q�����4�#~:hS��V�)= L2�bB��N�2�L��&�:���66���pǈ����Otfy�`jbn)����D�d����Hm�x�;������k��<�<hc�����,��E�cn?!-2����* �Ffq�p�|R����oƚ��^�S���7�ɼ_�ҙb�H�7���sÚ��D�,�l`�ie.�J��\Ј/o����M,�{����nf�6��63:0q$���)���ܕ�����G�����~�E#0�40ۢ��Ɍ�/I3ŨB�0P��xwV���Mk�����Z�j�ڠ���y�|\�ō�b�\fʘ�1��7e��Wy�+���1�����矟��_��?�7�`���yh�����;���.{y���{�O�ׇl�R&獷�,%ー�����P��3<�U$1%�6R� n{�΃����0Rڅ������$��U��.jT�p{R�Vh��-?n�(���3�a\�燡�{h0�^�ϫ�vwD��W����������e��[���yZ¯���m�Vwނ�w�r@��ć$F��}&�s�ck������-�݇�I�֟?�����>���u�ޮ��=�������vy��~Zo��?<�,7���ϻ��}���n����ݷ�T�w�_�_96����ny��]~}���� �E�f���f�_(�%��_yz���T~�U������>/����ͦ��C����,�7�{?>�vw�k�����^}��?) ^�=�<�R�a����)��/���v����l뭞��_������������Zd�������w�T̜���)����Ͽ
u���������W����?�k���ϻ����ş���P�ܣ\�]��m������b��~��S������?^W�_�ZE�s��;����i��zS�@l�~�����뻇�ն���s��v��e�W����b�y}��G����@�e�9:�g��烪?zܽ?���o��/���J$�*ϗ@���=����Ty!1+�w->dzZk�f�r��$��H�W��)9-:+�B��ERd��PG�#�O+W��!f���j>/�ct�E�ݯSЖ��2h�a[[������o�������v�������pA���}�6�\h;068�o&C�X�����~m7�"��5~ݲ=�(�jJ�=�eN��H������l������߿}}�/�����|�o�N�����?
1��]���f�Y�}]>}^o��3{��,��{�,�w��a�v��栄-�G;��o'��\f���$�D#�h���X�Μ��F�:�9Ahc2-y
If���g����L���_���/ks��/_mY������c�A�Aө�9R�<�b�w�燻��~�k9=�k|��C�d6�d�AӶW�W�Ȥs[��iv��mu�7i�{;�%L<-;�Dl��RZI ��Uu����d���Y_�~1�W����g�1��~o	~>/NJi�ﲋ����eيh��W5� �9%9����
}��c����t
h�@�Hu|�(�;�ܒ�>Um먩/*lM��V¶YTA7��C���p    ���Ƨ!H�1����c��t������ň8���4�"'s�D̵�W�1��d1��
Tx�0Y�x�k�w�$!r�F9LP�B�u�&d��s,`��TAUQJ"ͽ}Yf�q �(o��n	a����N�H��Y���c��[-i&�]���dz9��5��ul���R�������bƊ˧�p'>̥冷�J᜕h��V��V���LC�Y|43sZ1�/l}��n��Q=���ܩ��v�UC����g�``��a��a�|m9��=���g�)Ʃ+Sh4/C�\�i�Sh&�����66d�]�煦	��:.n;�6�����2q�!:Z)�b�Y#r�r4S0�v��%`�FE� ˁЍ�U������ދ&]G��Jvh�õ������[1-^lJ��f�����_x�B��UA� '�Y��Q�j�U�+�Iwq���������:����R��������Vי	&h�4�����e�C�f�P�[�[0��u�T��B+D��l�<�8$?]��z�����#|��6�����HV�	�����D&�Fd7�&@�3���n#�|�T�Y�aY�'g����-�Y��i�h6�X��a���S�q�������O��KR���ؙ᫇�A"O��ʛ�}}����~}~8�8�q,G�>}M��m����l�Y��Q�5����#��FR�`�,�Ө�ߟ���Orxy]�|oL^�i��D��T)͙����q�ܭ7w�����zw����v��[=�~����w>���x���o�ͯ�����	�J)�`����sn�l{�2Y��`{�Ƽޛ���h���R�[T�7�6:/؛m�x�Ϗ;���܊7��
���X�@2���� �}�>�}��U1쀛�Uӿ1�{��I)t���JlD�j�W3J��bX�O1�����h��ng/Y�&�����`��� ��4�M�����0�Э��W��WXC�i��p3s4�:5�8_��X���3�'�p�f��*~e(�ø9�5,�vr�NF�S���s>X݄��U�TKzD���y�L��.����Ub�A1,�
]X4���N&8�+�:�r%G���ģt܂�/�񵛃a�K Uf<�E��<�-�l�L��A$/R$�c�錉k�E���,�$�!Ti����������6�T_W@��p�0,������eq�	�#�?7G<,dx�z��v
�$����!�À�7�LdDG-�\�p?���$�o)��X�!��T�&r���;'��[�i�bB��E����-�J��dj�{�pK4��]����g_��%��� ̗є�G.�td���Nf�K_)�!��}j~v����$�d����s]�W�d)z�[Sb�W��I���I�2va��$Tݚs�	�-bᡨ:���Aޣ�������N�ۃ�1��v��A�Ww<��a-�jwG��5���Y[=�����ng�y��aA4Zhb�k�gfкM	�SU���c�����m��+oAs�n��qr�q!�>s�l��7���fŲj���z��߷6�Ey`�,ɥ��ӛ�lU2��L��`�},CO�(
:���������M��O�s���Δ�������u���dsH���u���{MՅ*�����on�u��vp�9bn)���d��6 4�u��n#,54g�NZ>��5�g>6��]�88�<JW}l��XQ�-0&o�kN��o9w�i��Ey��)�3z"���X�`ʲ�N����v������F\��V4�����N��V_�5h�Y�`3{NP�*e���h�f3�5�L(���։�6�.(.�P3"u���P�S�~��X+0�CL���+;�{gW��W��d����l@<���˥�%f�:�H��^5��o0���EΊL��e�r!ڴ;��k��m ���a�P$DS��"��R��UI���H�4E$,r	I_��jb�3�޲#s�1]�Ի���1���P"� ����t�_��$�/M��s�`��Ԗ������km�r����rg���\���Jpt;�\cV����[}���i�ܾ�J)�+��̘v�N�������0�8�v���i�I��������=�h	�P�⣑c{���",�"����~z���\���?����I��W ��`��V����b�w4��Wp ���T�)��z�U��eY-IE�� �uP�Mbh��(e �����x�}�U� 7^��y�Yp�jk�f�sĪ"ȅ?/��V��f��mRf�=�x[ٶ�W�����O���s�of#ʶr!}lP����vPn���W!��U=��x���8!�1J����[�yA������PPu���j�X�+����%��cE��e	77A9��Qt�;$&���:t��R¶�X�q6|Y�2�� ���[{ׂA"�;���]�k�B[8ԧc���:���T��o떉|ڴu��1ȸ�|V��~�� ��D%��T��+\����8MvGO�o�7]%d��
�Д
��.7�����kz�����_�_	���e��j�+@?,�_~Z/7��_�.7�6�| �_�_��~X?(
뿾<��Q�|���_���a4�B��%�N�����\���EhZ�v��(��x0qH�"�3-�j�=��\�'s��]��9�G�;L���M9�Q0�]�`�RW�p^q���?��R�S��Uⴔ�*-p�L���c�����+�c1i
w���)D�$8��x��<��T_� �/pv�LK� �Tӓ�>F%�`�9��?��|N�nrT�x��{r]n~[�3|����[&��%��8�]~C3�oOcQՎɭ�&�i��B#�`��Mϋ.���T����¦�E��:+��Ҿ�����Juv�����ܝt၁�!�42&c��F��는��N�dzatH�w\52��T89h�Q���������]o9�?�j��g��z<������.��9���å���ɭ>\��%P7�,ϴ��?~�qh���ތ�f2��^�.��z��Y�����ނ1�X���6��;��1��"$��]�3zv�Q��T��*iᏇ� }��v���x�׃��P:x�˾��7F��� �Ѽ^G�Zp�)mau�ej�;3�rzA�*E��eq�F�H�	���QΘ�Ó��&���/%g�����2n,35<��C�~jt�;�iи
/��'sT"|^i��ع+%td��3&C�O��9��F!�\��+����,q�z�&����I	�q �\��T_נb,��5�����+�+����R��NJ���Ot�ٕĠGa:)3�6iYF���P�hgut��Z]�D�F���ѭ�>'�;
*�`���������'D�ZЬ���`d��}3Z�� T�-��V�8r.����魦h���D��<����֮g+J����BFT�
��r4�&.^�D,�����x�Ѧ�Df1ڛ��¦ei"�o2k����]cA��������}<���ը�BڋQ���ߎ��@�v1"p���Dh	����roa��!o��;��g> � <n�G���TVR_5�-j2�b�|�w���~q3i�7��hPr�X10�՟�5��{��h,)�]ZV=��o�Z�7��VV�����(��i�2I%e!2g%�6
oZ���|t��_�����X����y��,�\���<��)�4P�B�
��jz?����O��f�L\���j� nj��o ��7�-!@�v�JEo�,��4/��e�W-���j̔SL��%0L�qi2U��To�=}x�l��V��	?����<ό1�1��0n�*j�9�Y��v ]�U�
�P5e�c젤�&�_T<���+�psy3�a����&��2�՟am���p��Q�ƶ�h��F"�\XB�I&�m�}��b pW�9�R�ؓM��B�'���RSn��e ����g�2��-�q1P�1os�b�ʽh�"u��S��l�A���cX�T���r�:�y W\:�G@��F#8E���]<#�j's	�Z��V��?�4[�w�EE@ԋc    D�6p�I���& �*��B+
�/����\��b뱊P���y��-�����?��.���_,������!����������9��x�����x����<>�>U*E�Wϫ�j�t�����֟?����2sN~���x4ta������ח}h���>�}���txnS|��n���;��O��zx��oV/�'<�(��ǧ�'n��^>����l�������}����z����y*��~��[������?>N� W�ڷ����v��������s��~~����������VOů���^6+��_?,v���߾�r�g�����W��x����7���������������T���ǧǟ7˯����9�6�?hZ���������շ����G�ӇZ˼[>?�̱�+��
f���VN���0��V��Q�7yj]���V)�ftAqN��Z��^��-���k� �mꦒzԊ�*B
eMƈ@�ʍ��/4�D�J�]��.��g�P���s�$?��4�m�2BP��Kb#�\�+x D�t��$�R��I(t0V�������e7��\�%0�bh�mt��מK$Lk����y��d.:��yQ�pFB�m���ygv)����'�k�X�	�*�.N��4/�2EsUxO	ћ����ړC���N|���#k`���`V�[&Q��Z�Tӂ����ˬ
$N���;�Z+ʇ�/�QtTz�\�w�q�cZ�մV��������ѽ�
�U1�՝�$����6�A�/��4��ؕ��W]'x����D���T���g�\_��kg�H
���\)}�o�kW��6
R��z��?�' ��vϖ���Ȼ��s�K�b�0��',Z)������m=/� �DU6f����YL�599�8��x[Ⱥ�@Ȋ����;j��=kϪ/�ݛ�c���d�Ե&�Kt��,A{ֲ�3Bf<p�����Յ.ab�6	B�!��?%:hxr�r+�+T7��8�����5M�ɰGֈ=ߝ�6�� �S��H���mc���ݏH.�I����yl�F���C	۶b"�v���c4NL��
e��e��.���ck��G3�@'ۤF�;ʋ_�NC�Mv��ܵ�.� �(�&y�^�ꁨ�g�Wd��(�Ux[�m�Ԅ����	�-�	=�o�B�9�y��������cN��2����.�����rЕ�4�R�p��m@�5�\Ҭk�bB��R��3�$WV���=�KO�ç��B��7���3�;����e8 M�zZs쪢������yRڴ<�E�NPЙ��7���XՍ\fA�cLlm�E�5���|:U��*�)��f�Ɏٜ�Z�9��Ws�(/��^t`y2Ԁe���*��c��f<��S�㓅��Gl���M�{d<I�E�#Mr�uX����>�z�.��e:��ZG��k<�H����gߐ��R��M0S���"a;3^��-�B���d��
uyC�vhF	�l:�w�]�gn'�R�Nw(`s���.G�j�G�E��%�@�;�AR���`�%K���u)`���I.��/T*�'�la�Ჯ��S�S��#@��"/�z��S�N��:Z����=iUL.�s<�T
�z�҈6)�b�&X%J7��Bm��oS^bW��Ph�м,A��lS'(�߁ԯ"��Q�=851�<�:����Hϛ����������:.r.�Xczu!	b��(�;��ysk���N֜��ѷj��	�N�V3�h���f��q�.e��q�>,ը�üA
K���{3�`ƀNO�.ή��_�xzy�xyi��7����	1��pB�io�.��2lt��+L�*�-��"M ���4;砿J�{}�L�G�;��cW���s�Ox��15�8�1���L~�&�A]ʤ����x�$�RRޠP�Q�������v�j^���u�kPU��V���wؗ�C�F�+��[Mj�U�Xe�[��B^�;��nwH�_S-��i}�-[Oo}��0\�	V�Ұ��lX��
V�$��:�)\���XNq��Ά!��E΋�����h��.�!�&4�6=����K�r���������[��.�ghWIiFm8�����j���)s)íc��'��h׈hը��aA���c���^1"Pk�����&�@h���;U���gO�vo�|ο� ��3��my�j��lr;ɹ�j2����fZ�k�ym�����z�qZSL���a����:R�	�f�m��=�:��]�=:_��Q�b��xep�����i�u<b����.�����[�uˌ��@�wL.�X0�I~�5��e���u�)~Ƹ��P�e\�+�'�D+o��+ �u���sk/�� �^��'�����e2#�rʆ�^Q�Z�΁'�,ʇ�������8ߧ�YE�4n���V��.)��������i���g�	�/8�X%
��^J�6K*h4�^blT�8<Ƙk�y��^�'u����$�H)*$Б��%�h~�2W������[=��tA�o��8��I��z��G�U/�2��=���4���3�E�J�W�j +{��2	��8�P�\q�)�MK�q�z�ʔ�%.���mM0�Vv�ɸ��'U�*݃���4����D^G�D\����Rx7����2���w��Q\d��=��{Mj�����i�E��z�y�ߴ��2���$�ҫ��J�%�����dא�=)���Zi�&���nH3v��f����p�=�N��<��n����&���E*����p���ib� @6�ڃݘm���'���7�G����\]�D�5f[`L�"�"���]5jR�Q�HL�n���?�=�Wi���<lwy�JeF��jfxc,���00������-�S�08�����ʑ�0Vn�y*ǋ{d���Q��d��!:�<���\��pAܤ>�&]����\���~�� x1�X� j�G�i�j�/LA�o[��2C-Lq�OH�m�CS�߲�8
S�H2F���E� �QcC�6������#{+�q�:3��V�	��_��/��� t��|KAԊ����0c�0֚i;��M0{�Zf:��^�	���g�&u����87j
<�2���sq�z�xZ�q�V��H��ь��e�yl����T��\+?!ۘRm+E}�s����wxań1�{u�9lG�)�	�s������~�r��z���-�o�\X���k�X����4JM9�Rc�!M�5f���h�Ʊ4��P<�X) �"�Et,J�n�5	O�)��rF&)&���h�I(�dp������s?�I�V�B�	f<}�%�!��Kp_��"�N�D٠3��ũ<{��ms|�n��/��s��^�gd��q�]MgWJ�׈a^:.0S�d��
17����&��Q�]�8���B�h�I}�PN(�fGq�3����&D��eB��5~W45�`���/���Ρݑq���­F�T8����2 ;9t���Bh��+��
�-.I��n���N��k_5�5��n�Vy��]
�S�۞<o�lfe��)+�!�?hK0M &Q{Fr��6 c"�w�M���r5��/cBʖx����gau��B�-w�ۄ���8�1�o�m+t��������`�_p��x�zN�v��եd����b�߼,AT$m(���t<'X�sbG��U��t��B^����nn��I�PgLi�����qIQی�v��5�h�Q����y3��
��
հ�+�������*>�tn�!�15V����ˠ����L�6z��yU��@��ьgt�4����oU˰)Cpҷ(	h4���kwSE~�  =�c�^�h�P<�2�]�ȍ��K�2��J�H�1��c¶6��}5�\���f��T�_=v�E���xi�9�`L0U~B$���-��#>����ݥo�(�K�߈���
u�T\GI�4��^�&�����d��ͪ
�Y��]¶�1�V�dL6MBÉ��    <Ϥ���.���P�	���K3�*��2���؃_���~��6�.њn��>a?�b�F ���q���:�:����v�NBn��0YMx�8��Lk�J��wFQzi���\���X{'��l��e�ԣ�L�^^b*:$l�0�.0k�����5zX@�;�[���6U�}�2(э(�ӳ�\���8����ij�:�}Y锁4�oL�)7�|,&������&3�?���I�lP}�6i8oF��4�n�B^���K���u�<��#���+љ�WX�q��(��.Y��A��d��z�ճ���|�ުج@�7<8�q _�Mϲ��k	�����}�m�ۊ��%�+%��nZm�@�"�Hj�(��&�K�&(��L�t|�ѫ����N�$ S��Z\8�,#���2��2�6;j�J;Ǖ��-�l봵b�����1�}h>f��*@ }�ň�9�k�^0qB*i��J��~��5��k�<��v��28s*圦O�u2��U��!�C�jr6f�5&C������7#L�V9G����"�{�&a���M\7n�K8���Lu�������!yp�tBS�N�"&s�EwqD�M�0N� �,0�]�"��4׵���Ź�%d�0mщG�B�r.R`8��r�奂���@Ņ��.��[CoF�xq;�x:i���oU��9�TMA�E3JyUb/2�h��	�C��h�4~d!��?bBB������X���+%?�P!��NEB�핏�������E�m��NؠlyC"R��C(��b���)����-�@P�NVr�(��pI�u���%������@������Jd�T�Oz\Ej$��z���/:��3]�Vh7 ��$rp年��X��<{��ف�ڡ����'��#5��(>�i��,q� �9и��@����<�G�0	LzN�N(��4�,šŤ,�p9�ˤIr��J�[��ͥY&tM	��z�����]o��2�`Z�]Uf��=2�й���m�i������$lљ�p��ٌ�ٯ^�3�{V��n�5h*�(�jX�����5�Dÿ*�;F����0�q����a!/-W���8G�`^��5/4Ij�v�*���_&e]�)x�s��Аp�c�F�����n��E�Le���O\�*������f�Te&��)����|�^��SP�#�0ͧxe&���*栵Cso�xp��4)n9�z�(�������47�O9�$�6V��������9�G�zZ��ϻ��&ԙ3���>[x>^Qo/h� �LJ�V��N�=�9�E�p��˜Pc�@��C,8�,��v7H��%��yE=�h{�<�I�B�z��$G(���r����%�1.2�_E���O�h2��/���2*�7/C�R�y�I0�$Tr%!ۀlC�9D���
����>=�����h�����X�"�5-�8�:�͒�����5�7���^�4MR�'�Tpv(t��Ne�S�/�v�T�h*�Ӳ�~�.�lp��:�q��չ
0$���nT.�{5D��i[sq��{O\�<�G��l��K<�\b)�0�طx�"���m�I�ݐK�7�� n��xM��I�M�5���`��T��� [�u�4qV��y;~���QaW �p{��F�-�3^f��թ�у'�Bp��I�O������$�tzE\�a����0Bhc�j@��v>�j�u&-x$��:�m���-�r;3�ݽ�T�g�V�=���֛���1-"��e�|�,���0��J�f����a���t�e�~M���gL@}����lW	l�6�[�xj��)3�ts���#�t�/�e�]���Pw�O�9����W��	(��D��o\��j\��m�8���'���x,���@�¢U���\!�5b��bp��	M�ƈ���l'4���	�J-�E�NhX�@紂���TRj���τFm��y�_.S7�Mf\�P�<�]G6�7 9$B�M�+jm����u��.�H���l�zR��O7���yj��S.��;&��LI������ܴi ִ�Q;�$.�S�%<�&3-��"[�#~�xH��M��:W
�^qߢ*�����Q��jut��QU�l]F��y-��B��s"_��>��F�t�x�
0�;���1쓰�Pr	$��c$�Ԇs+d�B5���J�S�c����tK-�z���jհ- 	�1��xF�l��V�>�������L�D�eB��`�i���HN��,M`�d�����P[H�"���Q|:���6Ĺ+GR�������Nrf�2k M��H@�PmjX!ޮ���a�f��L���� ��ki������i�[�������snl?���I�N*e�c�/�iNI�ݦ�Z8,��E�O{l�L8��	�ʻTl��6�m��<L�AHK=ʀ�ؐ=�]��=�y���v1�S��W�K�r��l���F�GH#���s������#�[&�q�n=���R�!R�D��K��\�4�}�knÚ�sW���c�=�-�k{����T�|��ZH�-r�Y>x���o�P|,�Hl���l��?�UY�|��aO�$��U��zK��F��hzr�A2!�#���<���z?6��Xh�.x3�?/� �����葏37��Gs0��J��#;Z-&d�\�7Ia�"�ûR���}���^zѷ�2�Cí׼7#���DWb'P���3�ʴ��O��nh*'GRX%
.SP�C��s�b�}$y�Ra+:�v��)X��7����q��cKr�ٛ�M���]�EuS��%�РtMm���]�bh�0Y�X� ﹊~[��9�c����g�Z� �[nE3-�r�z5�T+�� ��\�'H�`�h˃�N"��X�7���U2%��5��*fb�.٠Z0�2�G5M�@V�"���y�H�ac$���$�$-�=J�z����S`�#�����J�	M�|�4�����'4Iqp�5�6P��DЮzCU_r�'lם�8��Rh��!w�C��$��:j����3NVF[I�&���4_��3�Z�Ʀ���%��d�z��W��9��[�'�<i�Ȃl ����m-�����X(�A�ͣ{�Q=��6?E��s�k�D�p���,U���}�qm:���﫫xʢ��4ݳ���!�\Uy
���c���\N1��Ջ��������HH�m�2�1]���"�"O@�y6B�=n���dO]�䈛.M���D1������
o��}��&q&k|�az!6X��H�B�7U�4�f3*�@� L9JC�o��	c�B���}�������,b��M���H,^Q𡮠'53��
�A��ܲ0<3y[��(��P��J�e�+���r� �>f�r�پpT���P�	dz�t�yue�4�gX9�kh��
mx����2U��~��^�3��-�{k]AdB 	���1|#WN�:�2J�}��/��,���]!qm8��I�NbW�ɴ�X��c����O*����A`�|��e*π(u�M	ej0�J�Q��E�ё���[��i�q$�!+��1¡�k�"�cj!������g����������o6 �m ��Ktfҵ�^�!�]�kw�]o�Q�r��.׭��]&�Vn�q\�Vn27C�1��#��B�&T�$Ȏ�@4����<�T4^��\�s9�6�P�AR��F�8�:��Q�n�id���.�UIUyXL_5=��$�<dzԵ���T����<�a7���Ť�2�f�Xt-
6+a�9G�s1"P����8���+GGj�	�zw3avM��zl��P�-_��Z� `E��NB��~�&��6���ֳ�����:h���i�V�n;��6�ڥy�����[�¸ۓKeoV){[�NZx��R3���=��gІK/6CŞM���DvC�i�9@s�Ѣӂ�^n�trW��n���rskþ9��D��JV��0Lpţ���N�y��#�:����ŔФg��쎇t��*�{ 3�����*1�@���}t^|�D'�M)P��9��*��qQ�    ��S���hk[{��;5���4O6�a�rc[��-O��C6�Kt�[iF���/����%�> �h��b�<��%SZM��s��JNmU4����ri��@9�Қjd���hIE��I�PH<�j!��V���R�!��jUD�:�FX���ⓡ.�j��Q��{d2u��q�@Z-%iD��Zz��tf��K+̈́�L�ns�J���nu����[� �z��x���u^E�J���A��Ȧ�؃�t���Q;�����ݗ�Okl�ǵ͆�){��Ŋ���=�~��n���?c\H����)TM!\jٖ&���;�J�O�9a�`���3�����O�,�Wy�9��L$C]p�7������#�u%�=m��̩�����~���rYqY��p�bT�,f��j���SqAO�,�Wsq�E���="ۃ.�쑎aף�Ņ<m���؎Fߌ��3��]Pb,���Ƹ�usm��5OqNpftQ>m<F	�7?���e�7���+�x��rf��ʘ��kذ��q�F-k�k�(�Fd�I��G�Gv�x��5|o��TǪ�'������D�\ǑՂ۽��*�I�k�t%JQ(��W+����z��V(5`;��=.l�CpT6�X�
R��e�ukQR��R�q��2����G3Z�G�H��yr=J_M%�P��*.��
���ף��YPjG���z�����I�!�Q�u��(���H��q�N�FU��c��='ў���Q6��r׬������䠑����m4��\6�C:ˬ<+}��~2&f��qoOm>�{k+!��ה��{��(���/p�nY����܋��roω����
�r�fr7	�a���s�-"�:�7��f�m�|�8��l�w'�r���I��`b!t ��Ո�W��Z5vpW8G�[l�4m\{C�F`Oe���d�^Mi'&3�6���5�,q�y¹E��կ����_[�5�����V��9�"��ح���^�$h\�7>�8���q֏���[���	�x��.�)I�_m-(}Lr`� �/�:J`
��s���(>�Z�z�s�s��[���d	�JhͰU����e6���RdaA�[,5����h���'�8��D�p�p���+U?R�����f�yз���B/}YY^��y���0d�If���]�M�P�,y��)�Y�Fh��y��g_Y��\M�*��$J�|�qדVH5<�$:�cD��A���i��I/���α}Ϲ�1%��eeǂ2dGomB��/�<�"��[";��ₛ\�-��H0�^�&}PT�@ߺe�{��?ɵ1��4G;�bD���UR�"uf�xq�_�=G9��r�����m*�V�b�s�h�����-*&��Ewo��"���*DqD�Tw��p�0����`��w;�uXE�4��I	�a˻��)�+Yl�Ɲ�gM`O�$l��*;py��Y�{D�.�Au~��HQޭD�7�x��(�*��-�N�!76��*2Vsl��D��\Jc瑬D�,Kd�ʆx,��S���&���#k?���4�1��ds�=�G\�-;)8i.�<h��r���ʾ*d=�[	�����	�����v�F7ÝZ��5�Z8�[}�Z��&��̣�Z�t1k\E�j<�l\��)��&����
�H�D���D��{9F��K�Qݤ�4�?��JCѱ ɕXb��
ѭ�V�jy���<�L$v&5��EX(��	eԧ[ϵ�[������!ה��494/�vmB�Q��m
�Й���7ә@�/���J,7����2�:,��B/���?hN`2�4�Ƿ��k̵5���b%H�R;�s����,7�=�\	���n�nԒX
��:5���I ��ua�Qt�"�d P�����ǧ�ϫ��]Qo��E9��48��r���zS��q!���\,�	��s:st�q�z��6�F�7� ��I}l�a���4��7�R;)s	��xCHB��j��O$]��|G��St܋�`�ǻǶ#��Vr�F�e��q'�m��x�p�p2t��%�m�i��噂&v������<peb���g��9����E�5v�xC'���Kn���[Ok���H>�Jq\�������ty��ټ�8l4���aZE�>wbT��Ҏ�H��혾z���2����7E�F(�� �i�E�$��	?�@H�������_��h����	8�y����Ծ7�x� q��=�7��3�`"*�=���	��n����vE�@�Q�Q�đ�Ӄs،�A��z�]�/�L�K�
T��(G��t�(A0I&�@��]/� n蚐|��K\<ZkU!��2����H�����2P�M�nԃ�B���&�(B���C����@�`>tNt��9=�r]�#c�)SNJ���N�i$���e�\AN��z����9�&�\/)�^6�)���@�M�o�9������Q�'3��;�x������Y��4�6�5W^���y&e��2��x����B���<�dշ�qG.eR�Q{ŏ�)��Q٤wI�,�����[[���J���=ֈR$�?�?�Y5����?��QŴ��a�N_{�^��R�W�o�(�V[��=���y
���!1����fV�	*�y�8�lf�1�!a{)�v���{3��\/�x�sĔz�ų�T?V��iG�I�`�W�
�UН�#�ąlm�7�8"�0#�D[�[��
�z\ƈ@Mݴ���D�D��hU��6����S~�IC`�t��r���85gR�j%�]��>Z�hRV �8�G�z��q��5M
Xr!]_��n�=Ȏު-[�B�XY�I�J��s�$��A3)�j��6Ǿ�^q}����v��Z�c;"��N�oFE�~,��Uf��M�I�M��!�e�Y.r�qH勛�J(d�/��OP` ��v ��!U�t0��@S�k�X¶�"�e{�`<!�$L���:P�R5�4A+�í5p��i���l_%d~��?I�a�P5�WW�`2)�i���c��V	UJS�F�����lM���`��h
�q�/�'m��tR8�Py�cd�$��T�4ӭo�pzrߩW�G��ӝ�MH�NFKo��5t��̸�����(�y��T�Q��yN*�L�����.q�aX����#Ϭ ,�8�3)�}]�ۅ*��߬NaP�U��.�n��Ras.1&uF	�*���z�Ӽ�f~M�`�3&�&&C�h	
�ޛQW:��1�1AO�#���]��c:zer��m�����'�\H�	ӧ�����;k?)�����ܻ2�`�OW�*����Ǖ��h۰.3�||\IB�G/�t9�y�h,�G	"3��Z�9�Ҍ�V�Ǫ]Ӊ���X4GǪE��sV�����&:[�n`9�G�8�q3{ \Ł�@�>�!�Lg�_C��*�'��h_qiF�a��D��.47�����~��K�a�).q0A�$S��Nf˱W�4�e��<4���9��3C�d�&��qYn gb�<�ܖ6m�k��PacB��Q�辎o��L��G�逻&c.��ѳ�$ݛ�?Q����C��a�	���b*�!�̂��xڦ�"{Q	s�^w^���z�nּ���T��;�8͸���R��dHk@��qs�� Ji����81�m :^�i�a�:��q՗�!]���Lv��ג4����'�d'�W9�p�.�%9%kIe�֠Ls�<�AY���	MZ�4bb`p�՘�l�PK�<.s�s�:(�*n��&�Ǉ1a�b�������x3�ゞz);8;��4«M�=�V��j��V=ǣ�k�n��}�$�z8�Uǻ)I����nU|�F:��:[� v t���!�F:ϓ`��"*פ�U[�����	�{Kj'��'���a\�k2�|������������fp��������� <�D�;Vb���v�u������ʯ�P�X���.�i��#0��;F_I���8d��uM�ʽ�u*�M��$M�FO���N�U�%��t�3�k���0�.q�t\|E�g�:    �@y>޻".Cцω�fd�9>��7<.�i[��v�>���-)����p��_C����lB|���C�X������Qm�t�\�H/�2f3�	Ff(Z
kv4���g6���I 0Q��0�%ou����2�&�hJ�v4�w\��H�u��H
 ��٩-��On`.�I����� ��GS��E�$��,S�&����\���0h������h|����WL�[G3{o0���&[e/������^`����헟������f��qo�7�E��e��=C�DD�撂ҳXN�Q\�J׻�o�~�.	ft�Sc�����S������h=�jž����sx��2�2�x5��Edö��1Q���G^%�/ ��j��-���FnE=�x�.2i�A������h��?��fԁ6�oJ\�����\���#I!`�=Ҩ��1�%��ܩտ��SA�O�'`ѧ�j��W ��;e2.��I!��u��탭΄�G�����
�o�9`���H�'��+�xz~�p�Y4=��+uK�����T��6�$	��4�@i�A�����K*�Q��H mnv��vM��(H�Y�v�=ÈS���`����ʔ
����8�vtWcS�r���{�H��R�z��3g�R4,��,	6��*32��@,�w¥�W�-�?�W���wPu��g�h�_�1g<��_G�1�i��vv�e����14���֤W4���'�����ݽ��٘�Y�p�6k���h�i��u�7e��ɼ
��kCMk��WTos*.�WFt�(�|��CN�Օj3���'������=�_B�^0�I-ʧ��e6�|���j��[n����>-�~�V��O�����W��o�����L�����_����?>�ʟ��S7���ݧ�n��3|��y�[-��\8§��O?�6�/�G�ȭ����ۇ�.�^�߿������}���t��Ň���}���~���x��O�������g������i���/��Oŗ
���_�����H|����z����)�ۗ��e�������������7�_�������/�o���k�%{}yZ{����U�]S��roT���������������W#���篯���������~W|��ş���pK���}[>�>n��n����׻Y�?��^�%��*]���,�������fU�Q}X�6���}���M��3���R�|�������q�c��W���?^l��j�n��pw����Ħq���ǐ��Uf�ϐg|�|��!�S�%N��2�10�XlҦp�=
vp���q؈|,�T�}�y��
��J�Z��{�
6Ұ�A,�ܹ�}��mLEv����V��ђ�݋&�bD�<u�e+������C3e1BA��p��hw�s�m[�[D0���q@�z�����N'��7i��M'�"b��]h��"bɝi�}��/] vjj��&�����]���g:P�T�:"=6&'�CJK��f��|�`];���-tk��$�e��~�I	��'�A��p�s4:��'0��͊o'���]� �<GO�=�|K�	Zx x�%D�/r���:s��"������?����@�L�1�;�XH�&����?!NR�&O2�Cr{dG��Z�4��z�H��JE��m�iEz������M�W�4,%�~m�baY��H�3O3l��D��ZsSW~	j5r~d�������Dckz��܄��"��U;��|��ù,�5���p�T����8��4�Et�M
�In���7�!҈̸W���=܆�������Dkă4�՞V�˪!��� �]����Z��3�5 �qw$d��:C�R�����H�Ɏ�T�OC����X�V��1�	�e��>�r�/��������eO�x\��E�>�wY`Fa�	���-��\>��Z��2��.r�<�!�<q��)����"�`~�,�$E��0�u��(���i����V�q�%�ܞ�l�0�{�[+"�A�_L4!tmUb ��ɓ��bh�M��ϓ����"_��Kz4����c�D�v#[q-���s�T�H2��[�A��1E�u�_�BJ}�D�����V�y��}%�	�خ]�'@C��V_+"���I���8�qeqI���<%��<%�&Yl�S5e�{�*�e�\�)3�~g����T�l���=��O�����\�k�t#{噪�Xy'P����w�G���ޛ5��dg���/p�$�U}_0/�2w4�RM��d�dm40$ѕ����$��~�#p�Dx�G�=M��@�w?�Q�k��	����ۆ3�'Oͫ�������)C�]��>-`�8�i1Q�Yza���-�������G��	м�r�n���	�՛�U�9-ܣS^���V�m���nx4ނ�i���QQ���ȶF\E�p�q.�JF�]=-��㹎��5�m��ڔ2z-�~�7~z G�j����]�����L��U9�q!��ȅ��8��U�vvg�2D�`)���}g��xD%>V� 컍��!<�Ul*��C|r�����S�CH��Z��>Ue��9���m���g+�p6�$#Q�Ɉ�SɈ���A�o��nqb��ƒQ���������`I��م~�8�9Q66��t@�V�91�R5����J����oO�bQJ���Z��X��dѳ��f�@�N�8�Q/��p�ܤ��t��'��&w����Z���By��"Wb�p�KF�q��v)K�MX�s��7�F本�J�y9c��8����YI��L�ߔ����v۶]�:P�P�	�y
H'x3Kt��x�Ȥ ݷn�\��}^)�Dd���w��7Z/�p�-`��넴�O}�7Ǻ�blU����,^���jc�y3��8Ӆɒ������(��ِ�Nub$vYXV�MK�o�1� t4c��[i�������1v	4u�	���S16�
,�X��W]�PGQ ��|�C_��e��F������O�{N�hҪ�H�43%s�
�cd!�q�y֎-fRz�廛%O;���0՞&��[��t����M���#��b�W0~fb(��k]�o�gMC�,��
�"�z���ӂ�uTOٷ
3 �G�ZS\�g��#��!p��x95�m�"]�=`�Z��1�b�#���1E�~Tڋ����|!i枵� sܰy?"��;�/c[��ЎG;��o?��11��hl(>I��ƒ��󩫄��wb�����U�k�A�H!��u�M�(��㲶I
�J�-
��%9��wF��ד��SB]�y9��uw÷cӝ�u��X��n@��F_�������܄���2ȴ��\O��i���۲�;�m����]�^�u�rr�彃�e��.Lޡ$ �!��~����.:�0���>������M���f4�!|��Tns��"����Ϧr�<�
Ɯ�3b�洤-��,�:yD��F[1��ˉQ,r�_S��?�y��U��*􄲌�0�{���⍰������69<?.��{�7��uQO:�5�����i���k��u�7/=-�+�۬?��*۶�m�r]wV����+�Rq����z��5��y�_T�Y~�v�\�?���O���֫�j���e�6�>|\m��B�ώ��ǚ�_��1�yZ�$���f{$�����\^J�A�˯3��j=��a�uv0��bN��(�6i���v�ܿ|���><.w��s�qk�ʿ�]>����z�`��S��\l���{^nͳ���~�3w�7�6���f��p�ړ|��w���ͷO�ã9��{����ŷ�_W����W��sx~�1�fx+E�/����,Vˇ�⧟v�7�O��y�˦x.���Y�{���w����wG�ӣ;���m�tX��7�r�{�ΐp9{8<=/f��/���'K�ٷ���yo��:�A�����q�d���7k�a�+���ە���n�������\�j>|e`�^�J��R�5Of����H�ݬ¦�Pa�pe��νo��Ĉ�٥]IH�!��P`�'��#�%���j��}���BUV    ezo)Դ�ɳe�!�9vY��wa�(6&�P��S�U��I�$
ݔ|?�@
��U��W����­F�������bz�+��]g�HN3�멱��v(l`0&�w��`¸�~ox�ut�@f��ΝP������?�'YACq��u6+w(��}�5�D����8!��&��-N�,Nނ�nTۘ���!snr�?ߜۥi�'!sf�0�.]��Es�,r/})��`�aoZO��a�\�lu<
���7-��u7��п��<�(Գ/�QEK�d��Y-0)�)�V.ƥ�X���nܛP��p=����E;Wk~Z쀺Z�`rR����!�ё�6����mvw�}�q'i����K�^�r@|�Z�iQ,�GF���2/��a.Bܴ_��e��Hs���+M�8��X�rK=ֆ��A����s�*�+B� sN
.f�X԰�N^�*z�s�l����N4"W�@7Z��CR�Ekm'��~�#���&i�B�H>(���a,ޗDjO�}��}�'��E�%ybׁ��!x]9W��b���!E���bS�%��.�E��ݭ]�p��0�i*
LrL7���դym�FCFJ��3t���i�A��ZM�Ij�5Z��"OF:*a d�GDt�=�ӵ�rI��u�&�>���p��k�<0oc�V["�"�b[���k4��a��t�،�������q��	�-x�P��>�`T}z8D�Ay~O���7+	B]4�����-��)��xᆦȼn�j�-�H�+]4��k��6@P�nI�t'׷C��#
FhBd��e�(�qI�-v�'�loSf.�vV-��Nkì�7���(L�R�)�z��ԗ3����7��1"����T��-��ӏq�}[��b%�I�~���x�,v���dF��ȩ�2���?�I�}�v4�\��E���Q��>gO�D���#|�0;��]Qz�(��bm�S��NU\^Q�h��o�f��)�����z�T�jl*���ᑵ��"{�H�]�k���U�U����Ƈ\i5A�5�!p���̒��3�q'��Dײ�0N�5�$�ߪ$޴��Z`@9��qS��C�So#.���q��"�OG*�"	����C����kO�O$N������ܘ ����W��#�d^.�e�!q�y��\�~��!mc卜������C���w��D�P�Z�K�Gd��, �瘔C��I��x+��rX�(哾�0
��3��rF�i��d82TV���N�.��D�ר<����o`��	(�nM=�{N��#����yfPhh*N��&��;���
!&r7/S<'��4�ZqC(
�J9�!`��d�9m��T`�A�	a�\+��2�g��9-�_�CL4����H��|Y�~�Yzt��i�E������b���z�2 ɂ������9b��+�t�,rl���	厊V�+ȷL��|�����|˴P�
������v�M+��p��x|�������rZo�e�E�W�=-jE�pM�'Z�S���|O�8AQ�F���J�%m)X�(����7�K�ಽɝ�lq( ��r' ���^�o�SK�P����i����2x��(	9��
���=-�#X�D��f+����eZ0�y~M��ܮ���}E�o�n��i��ƕ���AR��K�d��9�K[��J��]F�� g�R�(���ug+/�91�Ņ DS�GNu�%i���������`�^�(]9UP_��V�~:�g�eȞ|��O��eo�,.H�w`m��m:TQ�w��,��A�LX�鈒�m*��"�ć��Tz22ހ�iA%#�{����HB�AJaaM<z2�5�u���9-�c�B�(ꘄ�6�*5xC�n7�A����v�m�6F�M��]LZ��<������Y%訑$N�ix�E �n�8nT�p^�q��%r{����a�1p�����8��~6��r�)�g2P7Q��<,{F����fKRT0W~B����!�gLn./��;8�w?�)�y��7z☐ƍ�� �S�{�߿�����5�ݣ�c^}Z�zѼV9>�'X ��,e���\~Mw/��z�dmD��u'V��&�n�����n����}�j�گO�_�d������j��� ��?��{�����H����ṌJT�d^�b���(��C�}c�,�{�e\>��><.w��s�k��n�|*?r�e���>��,D��o����d��߿{���o>��پ��ϻ����;�����q�^l����q��v���|��j5���icx�[�-J���_q����?:<����������n���x^�o�����>����?��ݱ>ƣ$���m�tX��7��c;�~��v�������i*�Qx��QX�><o�ɶ���ﷇ�߿o���OE�p��-�i�[����s����շ��k��`��<��l�~��ͪ�7V��yTF�0���Я
�8�,�̩3��H���kk.�ɛ��p���ݒ���~9����
ì�Aͺ�0���M ��M���g���o�O����h���Y/(mŷ(Y��mF�y��[�˃��NoY�G����_]-��}rF�oO�s�I��a\�`�NL�"�N�[.�H���K<�Rq��{՞���|K�8�K+D[]�f��H������tYm#o��ՅF�4^!˴��z)��Q�k��]�)	u��0�`�b�:cܔ�s$,v�������m���^{ЏW�=-�UG�6X���J9X&�a����#OFƫ���Q2b��UIpzo�ϴw����K'2�0�aR��1-�#dD�	�Pz�v���%�KA+2b�=��h��q��ikw�Z2��SLKӎ&�\},�½K@�d�W]l����%s�A�k�:�+5a��]�M�$=z*�	�ER
1|k�+a��H��ԭ�B
E]Jv��[7W�����TJx�^�d�QN�����<_��/ƺP��+�+\��V(8�\�6ǜș[�\y�
����2~��_�`������C��@���1BGU-8��D��*8�c�,�UK5�������]����C b\	�8�J�Uǀ@��~��A�⫝̸��F�4i�u`+Z�(g 6jݬ~�(���SD൴q(=qP8iӐ�J�g�y�qHr$&�NǙ6֍�_���-�nh�剹<SDw��U_.s�5nzKӎ��a�G��VMw@/��4b�iZ7[�ۛ�|,%L?{���i*no	��*��O����)�`���i/c+X�ބ�gc�.��2��y{-r��-<2ݱ�V�����d0��Z�����/Z3�������E�ܛN:Z��U��j�*0���n�0�κ*2\�ή&Qn�;�%�-�tU�F�73��N[y(��}ȝMtoUl���ZdcDr�p���S��w��8t��GsN���znqԣ�t�s��B�R��⢹��"�##���4,v��F�$*����n�������zb w+%�焛�f	�3
J)�R
핬�(�Nb�E��yM�d��7�b����`��e�6��a�����@���V��K^��.�q~{�</v��7�rf'1���
["���ۉ0[�-J��Ԉ�Q��"�9���Q���bk�H����S"~���5.��q�r3 �-���W��5��M��eK�0��a�סp��x��e�r��>��$F�ОV�*��h��t�v�E�m �F�c�j��{çW�c�TL,q�(����� ��p0���!�;Xٛ�6����q+���X�@��W~�`Sy����k�b4-�c��y8G����=�CUs�
��xa��q/�9�=��c��
٠�0��˰�����+��*_=U9w�*O�W����]WT�U[�66�&�e4PZ'�ܸ$>�7MP���:�O�[(^�|i�*1��{��,���)��zn�j
8��!?��1'�{Z)�8�3�Y3_����hZ�������O�*�Y�t��$y\�Nȗ�u(GY�r8�ݕ¥ԥ�:T���&���xG<�m�@�K���o�ʹ@��g�|S����N@�t1�PQ    |MO��'�|3�P�<܌���D��{�!�dr��0CA��O�=�!I�n��:Y-{V#���
h�
pm�-�2 AS��+X2�7��䵝�uvCve7�k�U���XX=����z�%���j��g�X�9'�z=5�R���>�>JX���yO�x=ވ�*NFp�Ǳ"��m�kF�Đ�^HW*K�X%���� jc_^(�Ү��L�&p,�*��#� �6�n�!�XsoN{�j���f.a�q��q�~�K� ���Y��i`�5�w��;;y���/:y]�_e�WNn3�s�4������U����2�zk��̱I{}��i���Xi:�iGj]x���]1�tYl;�^;�.�N�R��M����k
�,y�֠~X�� ���2�:�����q��T���|ͤv0������uWs�u ��Q`-���jtz����@�t�NA��ѥ^��v��بm1�@���Pi���������)ō��=�7LB�ܟlE��Y���=�gk]�^A�Y���k� �.�~��uG�.�[?�CE�o�JA@]H&\�x��C���hڤ�ܰp��ē�b���y�PRgr�?���:&[*�]UZ�
]&v�����vtx ��ii��u���R�>x�i��i�qF�_ '�����-Ӻ{��E�Y��r�K�5պ^��p�ɝ��T�\��� �	�.9D��f�{����$ �ļ�@�1���Cx�>Ɖ�˾�fN�K9	5���Ɨ�f㫹�S5ڻ�A~5wy���2d��ث;�o����8���&��f�e�mt��(��B+a*zR��>��.��A%,L�:kK�S�O��Q�ؘ�^��8��p��e�M�g�W�q~=����k�mx���ĭ����8�H l�k4�J��Q,�Ti����^�x%�ӂ>BX����b�2�AF�Vz�縗d���1�h3�&}���"�
	���N�LqB[%D��+n#ʛm��Q�AP�5P!ۑ!��Ǿ�z\��òda���XzSY�H%oG8<��B�b!W�}C�Ip˸�7r#�	�N�H"R�
.�/�h��P��{z7э+צ7�h�������7�x=N�.�I�tS^Q�;�^N*f�z�u5E���6_��0w�РE;=e�Z�Ȧ���� x<�S4��,�׌�T�!��rI��>1��z.Gc�����G�h�Kj��;t�������hB[]����s���	o�3-��.���C�
f�L�~2R����X@�2�f��4�[��Q>�ӭ7!)�?� Zɓ�p�G*L��g��ŋ�9�bUv�.t��&;f��_���D��������Z���G����Q�`×�83�=��U�#�G�����CZ+�7�0�N�ۮ��A�Z�n�.�8[�L!��~���D��8Mg���K�z�������u�����)̛X�͙����n��ĩ�M��5w�YYp��N�_� ��<��ȟ��/���n���,%���w0�3�{W���&���@��|�C;K���,.�/�h�e�ʠ7.�!�g0h��+��2aZ�ت]���db(6�$��Q,���t������*��r'��Y�W�3 ��4�ݑ�Q� ��	��RN��,�;���1-�EiM�[賂��/aA�y�Y��$�(���Ҏ�$���P�ۥ���VG�F���i�al.�I�H�#��f�k���q�a��?+�p�Ƚ��rȜ��{�ūi���-�9e�����)^�qQ5;�KMݔ��9����Oҹ�p�:;֒� D8M��X�_qi���HJS���Z5!�kV��q$ݔG�3D����*��l���ӂ�Uӝ�UV,k����F��&��&7m���(��p�=�ѓ"�'e�g�I��}���e���>BO�9���9�J^�8=+�K>�tNhA���}���h�6""���:�ۧ��Y�ckǸ���v-q�/�uW�{� ����7΅[&l,���,Ϗ���ޣ�Q�n��ʪ���{��ݧ�v��[������Ջ浪c��b~��w�R�l)P~M�u/%��˨�ϼ\g���u����r����/>}r�Z������-#|�|��q���>� )�'���i�x<�{��px.����K_�1>��~���o�˽�2.�x�_��������1���]>����z�`�{"��7|]l��1�l����}�/���n�������isx46�����׋o��������V���6�����*k��Q�Ɖ��?:<����������n���x^�o�����>����?������()��}[<���x�������oˏ��O��O�k���{���j��ykN����|�=,�����|�|������Q�2���f����H�ݬ¦��n��n�Wn�8��	52#��ɷ��uG*ŒF�	���Jz2+iS�/�\�G�+m��℅�](��ԛ=1Vs�Ā����Vcwx��msY�uYLxs:�
�p���.���w|a��e�0��&��X�]eVGEg��v�m�~H�r]��n��t�Y�O�,$� _�� +Z ���
�(l�Uaǌ�`�;�/�*φ@������(#�9/���2�ea|-W2�&7�$�$��{&��G�	h馔�ۿ ��Ɂ�;o�xg��a�
��������|����@���r{jH�\��-v�M`�����ﴌ��n�u����v�O+0����vM~Tَ�v�O�P��m#	�/#�Iӂ>:5�U���xs��E��u���w�� �r�AhX�/3���YG�m��P�)/�b��̠@ªw^P+�`��l��}G���&���l�UE�_�K�ʗS\;(������M%�J�ױG�`|͓�[눦7B�U24�ɷ�i%��l��yƊ�ק �[0޸�i����������k�Ţ�k�:%�ݕ��V�~�-�2K��1��RDdS�DFR (a|���>NF���w�p���2\۸��#'qÆ-R~��7�k{����m��`b�_���A|�S����jO9�gK#+tn�0Vh������%�`�HEF��`����n��sB+>{��#��]�q0wSʈ,P�{��q���<���_��h�N{���y������'轛E�s�JO16���*ˌ%c ��*�h��L��4�I 0Y�!���'�~�=��->|2����|CU˓^=���P��	���S�Ģi��GFJ\^���
팪����Kd�)�/��^#�%�XKv��w�r&C��i�u���AH�Pcj1i�P$�W���B�ܒA'�"&��th<�KL�N	�j��������B�u�2� �C�ļU����_�H*��TA�H5@��Ɩ)���ˠk���q6��]K�����2;d���v�L}��xd��>��1֫~:�j�i��x���\���P�Zo����Up������js>5ά��qZ�&�橲�1��l4����]�TGC7 ۤy�q]B쩅��. q���@t�Xb��Ǚ51�c��tn��<=�:�Ր�Jʻ�Pxh�[GpJCVj2��$V��H���!ͧ"7�FCV*i�q���=u��:�}N��R"����i�s!���Y���630�� ~ܐ@b[ �",�����K(�D�\\V��F�D3�lǴI@�Q+�V�`!&b�����"�`�k��-c p�@O�������i�m!4�0S�P���y�t�
/�����,QӚA�g��g��-9��&r! ���f	/������
���b�r��ۍ�Pܦ.�U�r2���8:� �.E�/	ܧ�K	L��))���'�C�*��:g�*W��1�(�ނ�!.�� [[�A��J���N̿�8�y�B�P���������]��t���k�W;��x�N�Xy�ݤ$r"�<�w��x.|J{��㈙��s��ؚy@w�1 tg�����㸅
�{���C"��p7mo�nEA�E��fs�����6 /�VNk &�s}oH�c�
��7�    ����-�d=HO����8��vD�����jϓ��:�춎��юgiOqD� s��;Ҕ�T���e��.bk������Iq����9�SU�	\#��4�[�n+,�!"�)����&6��K�9�s�%b_6�E�K<N��d�G+�OuC38�Xdb�G�>E�eyjP�x�o�J*�gz9g��'F��R���ft�"��J#j�%q�\���P"l�Y���$��@�$�qP��᎒���;��3�bb�'^�\(��n/���U8�Bz�/6���q�yw^ *PC��Kk�q�PL�8!��:���#���[a�
��8s-&F���zF��]�Gf�2f�'�v�T��#�p���F�!کs�k��"w��j#Q`�K>��̛�>4�舽�}��������oy��T21�c���h�t���șǞܱL��3m�T�M�3����pk��GDV�歇��q|-���EG���lh�� W�L��K�'v����.M�#�DAk��=�
�D'��ğ���.���E�ٗ��U�O�*��Z?g���Q�D���G��ag1g�pd��1x��J�I�P�%yBkO�Pgz�w�][���$���>\���`�����*��H.�64�~"�*�%$S�J��8Z�
�Vis���H5!�r��o��Mb��Aj�:@��O�����z�n��`M����u��e����K��ӊ%C:D���>	�mK2r�QBhR!хD�ZO''U�EGJ�
3�>�a�9l���'Ӫ"C�Ԝ(������ ޑ�;�mQ>���E�T�)�����sD���Q��%�|BúNDtv���/I%D\e���DM��HUR1w����i���Kz���_$.��Q&��+��-���+�� 1��I����K?m�S8]a��2W�QM�=jKoPa����r���]�� �R���	���	FQ�vu�k�)�Z�]R37��k4�0�P�J4��)s�4<���Y��&0�"�GXi�W	��I���)=Bd���nJ1��V�[1,���{�B�RH��<Y��b�����] �q���hct9)�.�dRBќ���quI	4$��p+sEH���dUR1���.�"����T�ĳ�nh�x#�rS��Ð�\���Fc,­�QH7d]���<�b���I|�Xs�8��'q��B;\;&� ��#҂e�_Y �q.̞Oȹ�S�l��P@��T�
a��C�c�" ϻV+x�˕��n��)��S|w~�5J=��=�;�+>$�����
���Q���|[���.sQ��q���59�0n�g�fN��Š�@
-#s��|:���%��R�*W��@�-m�3�ǩI�Pȡ��[
��*�͑�г�LCI?�~H]k-^ T�n��p:KF�n�� 0z+���B���2��Rʈl�Y ��&P��THt�t��W
���I�q�)i����vp�FӅW\F�wO[���;B/N�{�����E��tH=k�K�Q�P?cZp��ޤ�<'��L�Td���I�#4���,C��E��ݖ�j%#ғ��HH��b.i\h��uWPh�Mjm�@�HEHR �* )�.��	)�ʔ�c�H�)
��!�1a�H)&ļ5��v� v�v4`��	ɼ��B��b�����w�A�AR1�������e"��@�n21���g�)	��w71��̔�c��}\�+bc��'�
t���:=��!G�6'� n}���~�Yl�usz������5;k�C�eB��M���>�wU�r�w��=����w�]�y%��+s`��l�0�S>g��.�ɡﹿX���xR	��	�{��qGX7ЀYL�a?�Iٗ$W����U�"�p<�$$�\���PC-�-�Q�Jѻ�B@2<��5KY@B6ipP���`�]�"�aO/�a���������Z]��IJ78C@�v2.�s�:X]��(NL�������"��P��)�#$��9eY}h�X=�.t%�&��6�C�"������w�e'G���V	�bη��t��x >�}���`�,��y�����"^\ၼ!�"���\��f�n�t!��A�`g���2�r�!�)��6{�n����:+����P��	��2�?�?v����;7����Qo�m4�b���y�^�c]`����!�p�N*dAO΍�6��̕
Γ;��p�d�OZL�*[~m:d��vc~�{��Q�
��-r�4�0d>Rޗ�@xhO{@]A@=e@=���&#��oQ�tJ,#��;d2I�N���~/餠�1��e�L����R�*�PE�i����JB�MCa^ڮ�6��`O��"j���NE�9%��
h���vu8TX��舆A)I��g�'�aPJR)�RB�\�BC�$���:B��}��'&T��^t��P��,*f)��]o�DA���"]�k�_<�zb� UILrkK"pݓ�Jd"x�o4ݼ"$��i4p��:%�{�ay��J_�j�u%��obB�J:�cJ����%�>IŔB�Q�x�p��`����(���nw�D�L��Z�+ŕC�SR+(��:Eb��TP��'���Rw��r�TBB�]���k7u1l�LL(��P��'����IU��ܕ��oO��:B�=�a�HJ�Dѱ�'���I�B)�`���(�=Vtd���	���b-���}��k|��"�yL],�jhuD���O9��Ɣ��q�1�=%�2{?BO�{j��'Y�<=o�@�|rJ�L�G?�a�j��T"�)4p��(�{��K�pƓ�(F�:W܄��TLd0nb	��՗�Z���T���;���B�� �|���"g{ӻZ�R�߹}�F!��
�XpA����93��qmaVf&�]\�!��̺��a�Z�5�Q�J:`�c������Ўq� p� ݶ�:�M�}�U^�3�5�6)�`b��i]tN ��%�k7�Z��r{�3�I�+�ݮ�c�S�J�/i�zJ�e�t�cs�h!���U�T��� ���R�
�2�2H=���&%�`n��d�zJ)&֟����RO�I�2
Z�N���Y2�y9B��I�'�2�#�^ր��d
�3���2SQ�QM�I%r�qp��Z�:hW����h࿧������W�U9p�n�LC�9�bY�,K��R�
o@�d4��u!p��RF�s��eD���2��SI-e��+���'Y0�g��༧&��@
��SZ�:X�Zё{�� �=톤�˄W� ` SJ��i̲�qM�	�g̲ 7?��Vevk^)3p�SB/�5\���B_i������:>%��'C*p��:%m�H;WK8�D���F���KW� �O����|���SI��ӎ�M!i�����Dz"11Ъ9���*�%���bhMG�9���J	ɷ�RB�����ׄ��9���bB�2�c+p�S��g�h
���~�]��#��_N��	���L�{R%
J3mS࿧&�T7���O�	<�ު	ɤ���Oۅ�Ꙉ�{���z*����(��DEA�=1��%��*��u4�ڪ�h�ۅ�5�ͧD��yO�szpœ�'R�����>&��;ԓ��M�"$�'�i0�x��*O<���r�1�TA��qOM*��FBC�>�FIT�T�����U����KC�=��b���Ϋ$�SSJ�1�o?i��^&�P�4�[!p"SbO�e\��%K��I2E��Bej�Q<�Ԥ�u��2	�Y:�K���O{�F�:轻����#�{��KZ�ƑB%&T�ĻB�xO:5-��[���{C�=)��ڹ#�;��O������t�(��dH�c�^�ֻDD1��`WJ)1��e���`'��*"����JRʈy<�2�J\�ow���'J91	�⠡H�.$�b!p姼Jx�&�"��.�H�6%��Z(���TQ���F�i0�k	�
���Ea_y2х��=�lpx��X
�/B� ^<>n�Ǿ�f��y��#�����L�J� ����U[�� .�*�r�7�hUG��cXm�8J�2���     ���`SlEF����=O��3�EH���JP�0��^㠡���;�tp�'ӵ]%e�Γh�K���i���I��g.�t�8��]�/��z��%��W\':��4ͧ�X����*2�۴�y��OE9��1�^�V ��Y�<z[P��Py;"�a�SᐐL��ڀE��Էë�тg�C�^#��l��
O_�[1-�POR�v��(�elXG�N���2Ev�D��D:�;R�5ʏ��!�y~ 9do���z��j�`��C�:��#�Y�+3u}�I�!n�=�t� �� Q��m���"A�N6-"�zš -;cK�;��a���i�r�8�Җ�%	!��9�xI���p6_�2�/;�"�<��k�Lg
:�f�Q������Z�V�Q^ .c�o(G�5�������fBƼ�N�EG� ��H�p@� ��JD0�7=�}w�U0�)hQL&�\����z���O�A�ڀr*�!�^w��z���+�'�7T����ZF_�8(���#�ևô9t�i�l�oF¾�ag�I�M��������o�����5G��$ol��!m@���m��+K*R�4��bh�l���0��͟8|��d��D\�-�?�6�������ڱLL\Qvxp���^�w�v��z%�2��M��^��j��XA]|^v�o�_�~FK�E�7Evxr�q?��]*��MN��O�u���pV �Η��s{s�T0�1�H_��?��8���	�G ��n@0K1=8k�T��8/�7^Ac޷�	���˧���4E��Zh�Z�P8�Q��7 Eˀ��]z\CCmJ�#��(ӮU�(�֛�6?��IO_��ڤbB
s�Lb뿒�	m��5b��Y}C�f#�9�sjԄ�B�JRd=κ݊Mc�k���P�2�`4P7{Bثy�wT��8�t~�������Yt�V8�B��FP���ä��)�x+5�j�s��=�R��Q��i�l<��}m��C�E���T;��7�v; �>������o����ޡ�P�&���ȹ�qs��bU���羭���ю�h��t��d(�.A(f��6���i�毞�F`�US������d�/-�K��v!9���f�Fw�F��Z�Or@���@7��p$��bO��WB�ړ�Kv�i���#w��0xU|��
�I�a4g�.*ܳ��Nջ{���"�H�
.�A@�rƚ�ku���
n��\^��ou9���F���GH��z�me=k�pB�#O����Is�@;����uy�Csݞ�[{�ݑ}��r(W{��s�	܏=PvN����CI�@V���-�wI"�2Sg��VEm�Ņ�������O�ϫ���ڤ��Bs��+N�����y�������0���k5�p�.gwC8|DA�b::Z�E\Q"��Q�$&�Z�.����<�[��ֿ55R�9��z��kj�Ǌ�$�w�Vb2Z���H�\��2хr��5.�z�k�F@����O��k<����i�����.�g����$�_	�¹)�����m�Ea�E�(}e��Ù���k=����,.Y�]x�;��D�-Wm`oh�o��u!���ϙ��X&����M�y�;h6�+w5t�\�ِ���$�3ٸ��ĐmJ���*�)�Q��!��[WR�����J]Ј
[O�pTp�*�x�F�c�����k�rDq��<Ӆ3��61RE�m�0���ʻ��s�&�}��؎U�GL�x.��H'&���'$Q.p+;
�>f��<5仅��?�P�|�=@7.��[�j��%'����V	%�Ѐx��Z45B�m�AM��qA�����t��㦉b>����x0
 �e��\E<� R$U.�)i��6�_Ot$Zs��$�^]�
{ꚿx00�x��u���|U��+�a � ��iɇOF�{k�{°2���8�<��2�\�y"#���E(rxS�^��\����N���{�dXO�?���'F��:5ً�/W�(F��:5d�F��梕�j�1oG�'@ϼY*������������
�]�����^\8�(of�m̐]����+�Cs���0��t����ވ���{p7j}P�Y��-�SD f׺��v����R��a���0�8��t�����W :~�r�5����A�$\�\Je�j���7��$uP�w������IL��D'E��=��M�ȁ{�YN��i{R��Ю���r���U@%��* yC#���}�#X���;����t7W�'t

���hho{��!��� ��}�^��v�?c�	ڽ/ۡ:Wh���<xN��&�aK([o=] ��s���K||˱����0�ny+�e�F���:gګxU}��ܽ�:(2�TP�8<'0r���.rב� �p���c�S!�6$���3�u�@����V�3��KG�4�t�,�H��0��m�� �Jٚ��VMIH~�k4؏7�rb�ǉ	.��I]b2�Pˉ�*rhO�6)	)Nf��>8c
��XW̉9�y^�k&��%��,�g�@f�����)3lN>�|�	�02�0�Va�c>] �e&�!Ո�!�E�ȩ�b��G��0-�c�Dp�ILF1-Rŉ		��	)O�b�����.�!n�#����h���	��2��.DMszR ꨉG���$q�J��uN�?b�����U�c�&B�m�,s9��<��X|���W�l���,!��pU�H���v\�j���p�
F�p������~]li����|Y�~�Y�+&0?n�q��]��pX�W	Y�c��h���9����㺚�c�ə��:3WC�8��U�Ib�X|\�~jȶ���%���#f,�	�n�Aq� �G6���gJF�H^)"����kB)��*2�o<�(S���䑆� 1�����;�ي��{r2��=!�#䄔U4�u1�>!b�](�%	5)�:'��)d61 �O~(P�UJiWm@ ���6�sB����=�"���T=������pF��\�RcΠ�C�#�T؇6Ȳ�x�:�m�DAI�\��*���v#m`�tMJƜ�@���طFfcH��{�T�ׄ�Իfow]=�a���:C�-M�7�����q���^:����z!k+�O�ކ���ȘI�چ`�����چz�������~ѱ<��*������Ů��0������cO̼�`D�wZ��
����Sو�H�5hr�=BJANb.��v������z����Ы����Ej��4P�R��K��?�+�����h�i������t1DtȁIh���iኆYЃR\��X���Ȝ��1���Z�Ƭ~2�l�>�Ҭ���lK���=T�,b �]J8��r�	P��r̐���?,�;��~��s	L�~��?�����H^M\���H�ZI�]D����}f�:x�}�i̓� ݥ�:�,�t��i��p椢�WX�!�����=R��=�HAuf�w\ƪ3,d,�6}f��9q�,B���
�e�2C�Ò2~Y�;�sd���A$��I4�(�g��3�E�U!i�{S��S��;�=k/;,��!F�z萘X)�3��ɛ��N��ʯ�Y�ȼ����fD�<	��yr�	fA!R��3�.�`Ed��PӀ��u�����`�#2G���&V����[��4�#���p���_ �3Đ��*F�5Lg�/� )�\����\@f2k��զ3���r���_ 3"s|�ɖ�ծWS�Y�-��9c$���[in�-	��}̂l��a:0#�Zt��*���ly	vAb)s�m,��M�gݥ���|Qf{N�{�D\��s�D��"� ϗY�l{tX��v��uzsF���\sQ�*w�ISH�D^oE��\ynR��פ�F*�� ��y�mE�?}�m���)��0�S���Qʻi��΢�u�q�	

\��JB蠒0�U.���@&���B��B6z���q��B$m���)L�����If�c�"�    6�6�$BX�9��MrWcL�����)Q��"D��j�.!�d!��0U��!��I��*B��澅T����+�"A�`��o�b	��\.�a��nzȬ�H��}$.=�ϱ%@���P�\�)\�!FMȡ�(5(g���"�[�e��b����i>K[���	��/x)�&(�C�_����X~��p��r�������1Z0TR��ꡡ�]Υثb�E��j��p� T0t�:k!�Hw�6��d�������?�44��^c᠇ F=Eq�Xƞ��薉n9}5��q
���������M���U5)0r�[��ڌ�Y!E[������U�U�E�0�Nd!�9k'0�ډ�D�|�&N��x"��9�s�N3&��Z%�[�:�&��+0w"�\"�r��pB�:Ԕ���+���!mA�X��	�h<��5�c�FZ�g���n�cv����b�h�ְ�_�'}� 1�Lz���V�5�Hrk���oM\�<�Ir�tN���E�.���$�(ǳ����*����f�Wї���@�$;-�zO��.�E R�C�Q��'��G!R��n�͆��nVɝ��>K\ϓ�+ɝ�j�W�I������
#əG
��-�ҪQ�����rY����y��)����� ��� Ť�Ry�=��������ۇ�p$3����f&ܴ"̇�H�L�;�����!5P7u�F�;����f�ƽ�>�Ի��-�O������r�_&GCL��А�)*s�*�X���4��5sYj����/���7?��R��7k�|>�E���]}������442�ϼ狱i����W���yi���5��������K�/O��g���`�����r2�v���t�#g&�O_W�̺���#��.e�|����ݎ����F��z��jm�o߼�5(e����bU�Tm��5<S+0mg�����4k0Z>�f��l糏�՛}5�1�cf|��r7ó���|�~��}?�x�Ϟ�K�=�����r���{gV�-fY?Z���Q���6'/w�E���Y��y�K#��%�I$.RҶ�;����/��H"��B;<Yof�oNI�:⅊�4D�Cy�T�}˝��e�{�=��Ӕ,L�u�O����n��z}4�=	�l�GXM<�v_��fv�#:��_��}x��i�>��V��HK<_�}��J_���r0�g����]�[t�˃ڱ�2����e��)(b~�2�͞rM`�e���?<m>�t"B
��d0k�Q��c���+�K$��[B�<�M])j�q�O���}��������im��Y�_�q��Y�f��~���j�˯�g5j>0g7��w�4��t�
��f�[9��,��u���.����}�.!Ń╒,���̯�K��d�{v���.���|���y���r='��C�A����~������EЙ�R�n����z������WJ�(�g�9��k��}W
��2�Y��+��C��\S��H�����͕Ε��t��O�dj��.��d�cQ�G����[39T"b(�k��>/�	O\����\��[�c��ӡ������Eˆ�U=^g	0o�6��|Qq{�(%�l����l#���x^p�������N;��hh�%���d^w�%�_��u��t2�����Y�q7xl����=>�]�PޠǦ�tp�0���]w����(�|���2�Tϱx9i$���ͫ��f�>�ݵ)�t*�!uA�L��
��ka��]�]�&2u�Oٖ�@���y��,�ɪ�J]�.^���a �q$�+�VA�o��/��2�s!���2C�:��fЛ{���h�nf��f���f�6��c5&}=�A�E�n��sD��G_5';�]R����c�X{���]��M�����[��uP�F�bmg@��e�	��r+$kYԲ��N�a�	�*��嚶�D]HF�y�X�/W=ap���N@mAQє�=��Ѩa�$P|�D	�Ȭ�/��%�,�]`#��؅f��U�ȀJ�qq��׀ERh�Q��6J��Į�h�AS��9�r�B
^x��ӟl7�E��H���q;i�7��#��4x���-m]U�����Yc#\�A"���T��U�nvuG��C��'挕�>�r��LJr<�[����ha��m/��9?)�g\��>��'y�x�g�eT�Kӑ�zJ-�E������'$�ƆA�8zn0�_�_���x�in_y�in_y9x���y�����V����sR��W�ku	�y����~�y�۟�/����q�{خ�)�-Id^�d���]���~�X0���}��ц�t�'��D�{xt}���sF}9?�Q��ЋX�& Ctg���tA��ƆSOG�ߺ�Xb�,���_�Ll�G�d~ ��WOڑ5~"�e�R��̳�9#��i�<$bO� !�4`��H���C�.;��تPe�$O��#v׾	 }���?YΏ�c��C:�p��@%��6փs3�ٍ���:$b�� 0af;[��L)����K�/
Д�NU��Ѐv���ʾ� �щh�˯�fI�e.�h�r�)ꌇ��AN�@x�ĵ�	1On[�r�k׵|�S��q���g�r�X�!�2F��{�/���2=�+
��}��������������O��ݲ
1:��.��Hc�f�p�I�IW<�܎Bbww憚�[��&�c\h�9�d��٥Y2��>,̓���U=I���[�%"�{;gc�u͵pRP/egw�fg4ݺA"J/qQpAA1�����֑���d�k���1��*�b7�y��2�)����\���׳�fV=k�"!c�bA��vjn$(����sd�v�� 9�%GI�R���ns�>,��[��Y�ZoM5n���ǎa�TX�rhA\O1�khG��FǺ���4zX�K�����&vbN�/��g/�k��Dlf}��G�p��
�����J.L�;%���X�{�=Tv��J:إ��S�ESIW]J"��&�pza*�؉�J;��D,x} �F�1j��#ń��X��쌃���x8��-xi�>Ȱ�c�D�=��Tk	\7;S6g� TBq��a�v�^D��a�����	�����w����~���Ĝ8��V�7Iׇ{\>-�Ϧ�RԖ�v`�l���Ȱ�]�Cۇ��F.�����!R�����`��B��A�����R��<3g�N���9iG�7d���o�4�:�`:Qi�f����xC&�dw�m>�J�X����3N/�[�{d�m�t����a�t�����Ř�>VO�w��'c$>�&�������{7��ژ�2"?���Y�̱W��w:|;����D�h�];n��O�[F� �RgA^��m�'��{��X�]��iY��j6�ܕ �W�u{�1a/fqk8�ġ��V�����t*�$r}x\B&�8��J����)1�W��Y&~����8xIW|��f�����BL�u�ٍk�x�	�r{[ �k��]U"�<w��/T��_�3�M�c#(T;_#�שt�K�M����<�0D��L�N	�sێ��O�o�ґ�^���n����(sU�d�+#��uX|���i\ �7��.7+rt��m0��ͮR���Y(gMj�H.�Rp����0'�p��&��S��LA�F���N],ԯ�	��@��ӄp��+��ʜ\�u��.�/N�
�K����}C-Q�'F]��|�:'�t�����*�x�����Ue��zƉ�(��v��($>N�������?��!lMپ���S���fg��O��ls؛�=|���z���~�Ux���`�agu�M�������i󳱬+]g>��i���r_�@���~��Y�N4��;<��mR��<�v��*"�C���q���0�#��~�r���N^�s�4�����^�W�2Qi�~�m��=٬-I�.ׇ�A~���S?��ꩫ��MI�����]�F�_Ջǒ��;O*aBR����G�_-�4��e������ON�6�}�LEM\�nzA�ߖ���ṤE5#{ -H7-vK��&���X/�i������q.���c��i�����U]'    �?�<~��˻��'��/������H�2?p�ܫ�3�7c�ԔY+I�����}P�^����yA����A��R�
�޽�2��xS�~�=���z_kR�ʺ��l'��Ej�Uh��uB���K(/�v��At5Mw�geh4͉�#=D��� ���g���hl�5���9�#�r���5���CiAK��k�sxO<��r<���R�@��ǳӦ1^��Hhe��Mh��Rb#��!hG�'�0�[)Ǩ�+%4�(���]��4^��IʫȈ�\:������J5����a��+r�"��fSఝ��\�5�72$�
_A�h����	.$N<<7���΃'��/��/۽���sQ����Mif
�.����9E�i�0P���]'/z��ԧ#h����n�Z��������	f��~����v�_|4�ػŻ���:��q��?Z�|�,��7�j��=Mx����#�`�8!�����rv����	�\�"���&+2cؿKmX��+����<[�g��:�}%���>/�c��e�(����V*WϬ
)db�+s����>��W+����o��u��_�n��9ɢO ��݅���P4��!�V�B�]:���\�v��UY�\ߝ�g��j�%�+(R����n�/�.�3�B�đ�a�z�������T ��:w ���t�����o�ԹQ�&�g��v�w�K���ekA�㖻/�B���,���c	�n��sT�����A�3XD���t��2�.��"�5CJ�Zn��ѹ�	Zҋ5�ݲ��L�&t<�"
Ͷ���Գ��}}���Ɨ�Rͩyg��
�s�C��B�:��_m4�C�3��/��~�����X���P_���<ԓ8?��Y�C��,Aʥ̻s��e��e�O˼/'�i�I�z�6�N�����������&�
�Wjذpy����arai�aMf)���b�
ܡp���w(E����xw��G�D��r�w�2�h`X^��&zNu�� �
��)֌3��ƅu=��Ȕꆡ�z.�X��̗_���N�1P��A=^�z�X�إ6.U�(X'W��<�14���#�B��<.%&�Ð������)
ͯ���ͫ��:���Ă��J3W�EQ��gFąs6��	]0�A��"E~�<_�s�.�NE���C�j���#�\<d��]�%F�H��I���C]�N��{x*�;l��������8��������ӏ���f�v��v�q93{��X�?�?o��Kq���8n5����Q�]�tX�]�2����ǻ��6u%�-T^j�9�"P�v�97o��������zf.���=��PZ	�✗���60a"��s+��*Tn��-�_]�B�É�R�1�����[�P}�y(-.L�0;g�����m��\?Q�RR*�;���wK�Τcv��`�_�_V�z�~l��B��j6a�E�q��9�f�}f]ȴ�V(���:w�����
�<]Օ{��v�n�]JOj�a�i&���t4]��*���<W�E����&]�-<SqcQ�Bs8�<���q*���mNK��H�y]��n�x52
9�F2������XS�����at���U,��a̅2H�3�/��6��i!I��
��q�u��䊹�66Y����Y���_n��T�V_����w2�:�=��ldrA/d�i�]��ԙ�̮s�h���
,]Z�dNxq�/�G�ٜ�Z�$$gwqփǓ�v%��p�3��$��*��NLM��F�8w45���&��UWF�x`��P÷!K�.�R��#�j��yif��ʞ�P���2�n\~w��2e��EC]f��N+T,�Pu<�����w�aB_����&�{�1�/�8a�QK�)�{�@���k�v{�T�lXF�u�q�܅X�a�_���|f���X�a�<hZA#
�QS�wc���ff���1�`qZu�*�%�m7�Z�N{����D��f��m���fn���8�z���ΧQ�|l�y�������x��6��U�#ĝ/�J����F�Vk���!�������Ah���Z?n~�������?f�����o����>??-�c������95#f����?��w�ϞV?-g�k����g���ݘ�b�
d������b�:�J��ŴL�BՕ��?/v��7�23QF�K=ʃzt�S[��{EӒ�Hص<>E����V�z����yK�����u��_��+�����?[+�0����o��>�z�U��eC��S�T�Rj��y0u���\����?�g�F#ͮ߉|\z"���'�q" 
28+�H�}���������v��臭ɼ��8��b�Ǻ����E0Th���� C00tWd���w���n;#�y��v�k"x`_��#��_;BE�'���>��q�CRU�%�-�#�&�!J�Ԟ��HLj<�I��M*����l��6λX<��!�X�R�'2	�p�C��z��pN
!3Y�A���D���vT �4�V$�u')��]�����%��*K������q`t&#\�L D!�u���xC��@
�&w��'3)�.�-�N�]ݍ��ͱQb��v�O]L �[���hK��X�%���f�Ì���Y��:�F]^�y�Bp�\��%����/E�'n�P�ׅ�-R�< �5�ԫ$U��O��FWG��,u���.K�N�^O�X=b{Ar �YC˽�����MP�"��͡F�##�(�j��7Z��}��Gs"�7LU�ww��&n�����ݒ�?����f��@�F|��(�'�@�Z��--z�~`7܉h�	P�]���;��Y�dj�t���y�R�5ш��K�y�Y>���X�g42D�*�ns2�F�E/���ջ��(����ֻ��XN?�y��n���.sA^��p�UWP������Z��`�ۙ�`&�S��0w�-ws���h�1(>ief4x`j���������qk>���m�~�P��c�Y
�d�`��V��TB:$�#G �}G�8L=�����!����C4��]I�p��8ҿ��d,/��OXM�J� +y1ޤo�Y{�?�_�1���l�!d�M��!�H�a�A|�OK
�$w=��H��"��z	�d���aJD�i�/�J�C���--�ڑvi����!�Y/�[��;�����N���aC�;FhQ�G���2�m^��V���g^�׭�g���x�XF�� ��z���{�A�h$��j�.B���v��R�#�H����aB<�X�E���|�aZ�H&���W��--R���D�ʳ_����*m�1oo�[Z��bW%U��=�o����������ǦM�b���{8�0��x����y�Q(���ڸϑ��*�c�>�����]�q��?�C���mKl�+�6ꄦ19t]�3��b�ԅ$��
XvII�>.����.$�?�agJlUўJ-7�K_w��p��B��<f�qP>�v���UFn�(vdv"�+6`�]�w��+�TAS���;`8J��a�|O�m,��č�c,�;�^A|�!i0�_���f[�"�=��}.�D7.�q<I
�<#�>��^jҠ�BT,>���].�7n E�#�&�:u��^{t�*ϵz�z/l~^��ٗ�<Z�P2*:�z��G�kh��ui<���{��sx�1/m7���%��Q�O����_?.֟��?��_��zZ�?����Ya�J*CZ��������}\�x?��\l?|<��������r��]=[���LLv����'����?��]d�	�{`�Ƅ�jmN�o/Ѡ�hY���r�$�͑�Q���D��<��扷U���O�!��~�B�o6'���o0H�e:L7kp�zi۾?���h�k��0t�c�4�k78�]���4��EV9�.�fw�
�����f��Y�Y�
�v����\?.���js˂y3�DGH�p{eO��r�
>.�5-Clg�����}X��e�cc�j�l��ޕ��l�Z8\��x%������b�^>�>�k� u�P�� �    �tg4l���)�wJ�?e��m��XN�ҙ�*�t�^0|͏<آ^a)=S��ƛ�]��^�?Ú��^}r���\����#ʹ���	��W����vx�0�$~Z ���9uEl�����a�Z�;��q���r����>���Ĩ<{�&����#������z�{���	\k�S!^ 3�]_"::�D]�������l��Ȓ;&���V:�|�����N^�h
&�ƛh��Ϲ���td�|]��n�&9���i��ga�̓xns��ʋ���ݕ�G�!5N�ȓ��a�+2D�&l�L��8�<���Z�18/�Ъ���m����P�d�sh�8����v�(�N���t�#�.a{H���qdR��h8��b��+�@�����S���SD�˩��ϣ�����ҫ�Q(b~�E;����le��9e��t����,��o���̧hGy�J���Ue4�� 6�;����=���r:UA�@� iG8J������:gਾsmn�$�7{1�ș���[\hQG�]��6z�OA�yx~����8.�>Z�����߿�����5�ݣ�c^}Z�zѼV���u���ԇ�k*/ǽ�b�C�jQ9I�h�V�kR~�v�\�?�����֫�j���eK��O>���� ��?��{�����H�����yq��P���"�D�r�����r�\N�����/�;����������ݗ���P޳�ξ��b�SU���e��|8l��}��w����wO�ã��G}��^|;�u�M�_}�7���icx��a<"�2���+�?����O�����Y>��"�-?}=��䋇�z�x��]�����;��%���o���rW����|Y�2���a�q���{���,�Qx��QX�><o�ɶ���ﷇ�߿o���OE�ps�3��O������?�/�__}[��*q�ʣ��f�����nV��1��f*%C�w�A�e�D`�����Y��4��������:��h�G"���ΆJ�Q����=�J1v�y��^-�v6$r|��:�����O^zFƽ�����[���m�<����n�8>�\�V]�����e/��>���hw۷�(*�K��dPa\y�+�1��2��U�w������+� �����]])�r�#g��Q�*>��[�(~0�ͣ��À�����Jd�y0����yZ�=���Ux�W��摭%S���+�.t�X1f���46m�y���M�Dֆ�K"�&��"^,b��;,#Ǭ�&"G7�Ĳ�vkR8����ƳMH��:�@��ʞ��n��$^M:�@�S{�X���.�M"���H��30����<��ێ�"���	�X^�sD
D.�H.(�`�����"ą����q��L��E��+XҲ���Q;�vO���u�q:Dh������]ҽ3
a����a^t��9y�4�p�����p���՛ tx�L۔�i�[�ݛ7�
�8]�
͆6sw�\)����@�F�mM��wE�~ډ�+�x������{-( D��#:��ݸ�{u�]!�m0-�PymNֽ��D������@8RRO�9���;�뺵H{�
Y���]�|;v��Q���Bm �Y���^�*xG�}ǫ����U?~���	�R�D:��@�s9X��1��I��쒌^�-ǫ�$�{:�)���$*^eP��x���"`�pm��V� C��@�-`���ፂ��t����Y�s�,���߷.���{[a%J��d�辑��W)�U�ر|�D!�lz0�(��(��k��YX�f�2y��\�P�x���Cm���p����Smqc��n�4�ڍp=�q̭�\�+���~p�1��ď�Qm��Alh[~%v0´���Ym\i��ڡ	�}<#�B���[�e/£<�q��h+f7DR�)]��
�8�V����8�?�="�-0a�%OD4���uo�7�}�����M3���`�q��]��pX�W�t�`������i��!5Gl�e�������2sT�^No�������Pb90������T�R�\%f./W�͡�j`N5s1+���	�ޭr���x�m{oy����,��R��|o��Sm��^MK�� x��W*/>�:T�w�T���}".���ڨlN�x,�G�*��S�f�¬�ѧ֢H�A����1 �=�t+��gU�lt����@�l�X[w�ͫ:�QG]^ۀ� <*�Wm���um�{=ͰM{�C�d@�Z�7�eM�p4����d��*��I�m��#{/kţ�?�W� ��ۋ?:��{%]
��r�C������-
�E���<~��p7��⋮�����3�k�?-��b�J��,�ꫣ��[/^h�"#«��
��+1��#��
���|Gɕ�*�q0\~W�F1:'ƞZ�ѡ��>�QRئ���7�D�,������Г��k~�����-���C;P4n^��
n�:���˶ǐ���uG�q���ٵx�>$�l)��`��i:��#�:Pt����j��|}2�:o��2��.h�-��&����M 4=�0���!�8D/k�#�h�#�ֱ��̛��#7i�?��X_��Ґ�w�Y��Ø����������z�f����q9��a<�k\ɼ�(��+�6z$�Y��蕑`/��Ix]Z�;�&'0}s(-(�j�:�.�#-��%�8rf�i�����*��+� m�Y>���nÐ�!yd��H��v ���q�G��&��GEa����[@y0�m>�ۀn�-�BWsﶃ��T��5��*�\�:#\�l����ch)՟�	*X�P���)�C�d/^��gh�]׳���\�o��Í�]��f���C0�9�>|���|�$3z��9[����`~/�v��[�q��N��)F��z�h�"��O.��#6�ѓ��T�݀��!�	�
K�3ddAL��4X"r�hƱ$1o�Tdd1��؋)I��g��g��aooC����kkr#����_�ҋ�*����OI��*'���ĕ�ĥ���f�3�̋�*��{��}�5��UҴ8l�;�~�H���MV.A��*[7L��z6_�x�qͤ�˩%��o��o��-v;�Ϸf���<�n6�#���A0?�����f��l~a��r�����_�?�?�j�w7���ޯ��{�/|����?����Zl߽?����D�:��-���������C��}Ǣyh�EPL��T�	ҁ���zat�Å����U݂�ݲJ�M>6-��l�F��W)�����S�X���w[=$���ەJ
��O��ۯ�Z.a����Ҁ؊x"�C�A&�7z����f��~<w�%�����Y'���.Ss���sڣ~�Ѣ���9K4c�
O��ݴzKG1<e�}��p�o�As/-BD6�{ITd�ĉwx�OZ�Ʊ8/�eF��M��$}[�B�ȳ:H�Py�Bi��7�h�W��Mo�Q�ܱBE��uwJ;M��Y?`�*;�)��A�5-!���J�e�6�4Z3!����	B��VˀF��9fez�rF;<�.-~���غ�r�Y��x)򌹞�Z��~���%K���
��hڍ{"{��
!��*T��A�=��
�;r�*�>�Ǩ�R�Myxe,�s<�68s�)��Qg&D�҈����L\��:<E4-d�X�L���m,���,�@��"��Y<w����@��'b5�;����3����ڨ���=�-�vv��&�TG	9T��9%�ͽu�p��7:(E2�q���H��ي��hȜ�B���[T\���n��"D6���`�eE&�f?	���xd)<s�BV{}�d����s�ґ{��l�M�ي�!Ypז]e#n8ܰW�}�
�1���m�J�Q���fR�D�x�IEA{��}Xeq����L��K��q�6����*kЃ���;�D���}0[#-�/�/��P��4�xw�U���'#�u6��w2�x�Jsu.͍e����O,�t8Gy):dk���n��˒$\|WgE2Y*�*4�R2t���'Ft!{'!��+p{�    B��bAg�~xj��"����Fg7�`��!S5�^�nxh�ⰿ}s�1O5�P����Пa�O����fk�aB�TKZ����i�k�0���B8/�D��j���8m�do>G�����"o���-:K2�~I4�r?�<��w�g��bH4���)Ѣ3����*�17�I�+�m�r��9V�)ϔ��o�]��DWL�!G�*2i/	Ss���R�u{���Z.�:Yz���o�s� �T��|M_�:gJ ��HYy4�%��b�	���ҩx�k<��򔰏e_�ƭ֕8��]�ph�$Cθ�ٰ���j����a=�/qPe1/�������L	�8�7��=�?�fJTY����X{:T0�&�Q��u���1d�	�@��]��+q�;���#T/HP�p4���J�)���1ؾ��Ը͇%ɦb_Zp2��B�9<{�J�	�ɡl*��h��R9;��1X[���m�E��� ��2'�#`6�����h!}M�V޼5��:����X'3�O�7���cl�8��^`7�\�#���lA�'�qh��\���]�yxج�,�˭��0�5����]Ͼ߬|X538��}S��U�)1���Vh����T��K�K���'*E!��y���=��E:h�'���#����,���D�Q):y�C#�P��]�fޠ]{�����+����B��j9
����i���ivO�\t�N��#����8���7-���^6�(� &�	���2��'�}����wX��O�"-FNf�t�-��#O�L$l8!���T�*|�7v*%�F�oop�o��@�VeHG�:���j��/X�Y�9!�ۅ2�s��^�4�]���[$D_%��`띴�W�L@_QI������Ȍ�09hvV�*�!;��� �!�`�³��F2��ȳ�8�2���gM</�ɳ�9�?PPl��{� <��d-�������M��y�e-���(���q|�
�=�1�2�	Ax��x�|�|"s�F��m������[d� �ଙ�K�+����o0�7�f��z����zٖ�X̨���4b��&���^�Q�D+n���6Ҙ�>=b�=}^d;�c�92Ǻ��[@d��/�B���\���ldsI�x�x���u�����4_L��g�h��n ��|�M�� m�����9���|'���8�Uʜ�9�[ $+��kK%C��_W7�dDD�ڑ78�рJ�C����)�����V��%p-5���#�3�eȖ��KdFf5��I�v�쀟
Ʊ"����}-"��dI��H��o��`0����W�&�e�ֱ,�{{�:x��4��S�Ow_6�8�!��٪M7y���^m�;�0(�L���MIIf_U���<(�[�AM<3=��K�X~f���r�%s'~6�3��ͦ��Ii��-T��R��HwR0wR��̌�R9	�r��/OkٷJ���S6/6q�"$.�׺XA)�'M����7��u�Q��((pHc��4��P�p���r0'<Ary�3��C^6�q���5��P�0QO��e#/q����;���xX�ޘ�{�`�1�5��&�G�P���y�RGv<�l7����˒�8����P��io�P����:RN�(�䬠��:'^�Wr����iN��˾��<�H��޴�#'����a@�lE�GF�B�(���񖡰���E5ʭU��[����Y�&��TҶ�(�}�P���ĵ�4r�A�S( J
�ȄNhPb��+�Q�-�;��},kщ�qN���rs]�	q
��﮲�S�Bm�T� �\Oۄ��N��6%&&��1�&�s��d5hD�Q3O7�e�Z���j���J
��jA�B�%�(�����.0�h���D{�Y���P2��#q}{��J#�*�$�9p�LJ��D�G�~��>�0V�P�Kْ¹�`@Yj0�d��kN��g��#r��9Ma���bFb�ݒ�_�~�X&q�	`�7����p�3[�I��r�[��]�e	���H^;.s	g`;�V}E|�у����V��D����PBjm�|\�����F5��U!\Z�"PjB�����Y��I��]K)����nm��E#�y�9vHK	]ȝ���Z"��Noq���`,�yyl��%�p'�G2���3�(X�u�X�W�������b���\�k����'4��4�T�94iV�����..�U�'*��`e�L@�_k��mۛ���I�����E���no޵�E���䷧]��$��Hwʟ��=�����ӣ��>��}r��>AsR���c��w	���u	'/}C�k'�	S���%T�31�Ծ7��!��R
��Ķv*�$�{�V��p&-���T�3D�ʛ�Ay��;6;H Ƨl�J��l	3}�@z1�ڝ1<2U�i��^:�ğ=gV�o^<�CN^�Zva�z�UT079)zD�/1��K��ٜ�ŧ�u�����M�S���4յ����9*��R.������Vn�r(�p�K�I[�ɩY�"ӹKxd#�d@<�����
K�]�l�x�t擈�A��)E�+q�<�^D��M��'�!iA�������@�gh(E� I�w�;6��'��w`��G�7LW��o����$�.�.ᔮ���zdB�MWrT����H�'9!�'��xg)����Ds͠�Qb�5X��<!*d�"1��N��D�6��5��x9��,�N�q�H"������$d4L;Y�(F�m>�1����(�<ظ<V0���6}+�N�HPa����]]�$�i�r��2������ČSg*8�gVh�9����?�Q�����'E�H�=x�sc^�x���<�9�`��C$7�H�nm���k�Ϲ�b_�f(���������v��g��!$�.`(��
/��&�u�8B���Ө���A�څ�\��7gH��ZEy|e�K}�`���
$zT^��g���9q�r��3~+����Q-	<)H�' �ów�;�
�NM��n����m���J�i!ӓ�O6
O0�7*��~C���2S�БjQ����p�} �$f�w�=��e���>M����̴������p�w80�TQf֑̩����HԹ&�/�^�92�6F<�����:Zʝ]�s�Vϴ�&��]</̵d��kе4�ݝ:��ƛY�<�R���S=�y�:#︄Z�Q��\��C%�(RSH�8�^o-�&��|�*���.e#!5+������b�|�;<<,�_�CX��������ʇH-���f�X�:��wf#�`��庿o�3��3[.��p���[��32'���;v9�q�^i�ŻN!��I�E�g^
�q׀*�s�k��4!<��+h�� ��Kj�|\**��2�Qg�&�?�|H
r�������|D"��ضI��`�Y�G��0C�OC�7rgo}B��l>_�#��F����4�F�!�Gc�0(�D��z	�n��`��4a�T/W�����$�%�]/ѷ�K�D��I�<��%B陶\�%vk����Ⱦ�Rm���hѕ�I8S�5��
��ߊ�{]P���"EiB8�Eh�Uψ��}&���wFZ���0�'&p���h�Hz.Bp0F���h!���4�,I�.2|�]���>ŝٙ�)c�D�<��B�C�
,\��v̀z��u�QR8/<A;MO�0B���R���6��4������8~T��C�fv'b��<b;f;ݓFiҬ��o@ǒ� һf:�:M �Ӻ`��b�d��4;b�s%Es�r�Gv�2��C�^�x:�[�e_v_�h���8�s�rP�W��{M��_�=���l����TJ<�xG�� D�7�C�]��%V�kAȮK���30 aq�O?��.\�T�b��T��S�;�c��� �Ƥ �P��kx�o��etO�o]] �ܙ���4�]�D��Pv
��܄�Rq��"���<�3�bh;�f�\Y6 �!�bP������4�cy�o�S�,y��>ϒ9:�W4�ۋF��Hc������:ˤ`0G�"�tC�5o3    �HcZ��|T-r��EJ�+b(ϟ'r��/O�[�e5�n��F�� Br������4�i�N'�uYb"24O��BAY$u���Ȗd~�s�Qٻ���L�@�0J=E�􂻮Z��9�>�Na6t{39+N�z}蠼rY�	Ղ(����y���̉���W��޹�ev���S��2;����;�Z��k@s&�-I��|�:�(�*g� �S�K��>��*�%<�D��Ϗ�CǴʆO�D��On#7T����Ut�ܻ��4�}�C���[��tx�a���8�C
�u��-���B�26hK$��['re�p�	:�lw��GB�l�t��ٔʟ�e��������][�-7	�	�;�D{B�p3�� w�L"��nu'
SY���P��M3���թ��N�U��s�b��v*�H�a�af�R�U.�韹���!^���%=CRd[\�u}U� �ⰿ}s�1 �/��)�3���l���Qg8��b�����g�P�Ey�5(/���'�Pυʎ���R���Wo^�	W��ǆ3����#���}����Bp`�s������I�'~��⾱- �O_�ͷI�Z�zZ�&FTP����O"&8}�C9}�ܨ(o�'��DfRxG����Ulk�&1sR����T�hGǡ��ͷ��q�A�n�H@�G)L1����1�����K�#��p�#N9����5!�8�	�� By�{���Ia��ub���a����\��H��2������b�џ���Kn{2���'q����߭���MM
�ne&�� |Zh��k��б�,�T���_�6)�;V��SU���gL��ͤ���i]H*/����g�o&E���:�*�goL
���Q�U�\$��s7&s�$��9.vH�C��x��x�r�Z�O�\sR�����\c����_����w��9"���(��L3�KΔc�X�.�o��or��@��::c�~�#��1:�fj?yA�����mr��o��c�I�w������=k<��gՓ��;bU-�N9/\��d볟�Paq�Ɔ�$����D�l��%�XHCF*]& �i���V@*Q�7��P��4o�(�Cq�)=BH�A:�b�C���]�l��c_Rp2jwqC�"�M1�o�f���*�Ig���|��w��r$���7Tm��}'g��˻:s��U��FQz�s�|14dN&��Ƕ��<r�Y��BC�c�,���m�'� [�svT� �@^P����dtO���A�	_�n0&��'!d�Q'��m��9�q��&�v3/)�;���L� �iH�\o2 ��w��'��+8��T�����f��;�O�6S/1�;�F��5Ġ��m6_F��`i�r/Y�u�+=�4��d+��X�7}H�i�]�C�CC:��f��c�P��^�����չq���sMM����̑�T�q,�$�$�'���ϾA�zHBQ�$�w;��7�7�ecǍ���n0��bx��;Ȏ�7�Zs���	����z����e?��/��CՊ��xA���LN���#gD~��Xb��ьcIZ �2)D�Ȅ`�����}8!�g�N��;�څ߼':����?F�\�8W��n����w`:�m�*���� @��}��~���
m�"���f��j�:2��s)@���ے���M�����`[F�Y�-�E�1�e[��޼j6�q��Y�U�欤���+�����<<��ue�Gf?MoZ�{����I��>3��Q�l��L֌wT�\j��k�(s�x9#�M���/<�^JOV�aE}xW���j�bM���உ'3�́Q$F��CC1G�D����S
��?Ͼ�C
�duy �i�ݔ���Z��T�Ȗk>������ tU�p�T@Y�߉Jx��uo���B�ō@FX+b�K}�_-���~��\��=��1e�e�_�����O��]�-�W���7{����7�����~��؇����˻çwF8�OW��	��j��;�k����|m@7{޽;�Ϋ�~{X�w�+5 �[���}�u�Y�7{������Z5_Z~�,w�/�iQz�^s7$��gW�e������\T۟�?�~}��[�����>�-f�n7kK����P-�~W�,�^ժo���<.ޚ�}^�V�����W�Ų���3���R����潡ޫ�O�;{;U`��7��y�/����o�S�DQGS��)E~W���ç��Bѓ�������h]�W���e�`�Z�9��6۟g?�K������U ��|e)���-OY)8As��B�Oq�^���[�}uw���y���#��0bµ�U`.�8�>���5���^�7#�]�<�Vx4�i���w.�`S2���|��f㗍k�n<���bS#��-��m��2��R�	.(��Ul�:�ՙ�δ�3�ݼ��(�F>���ٿ3�^-�n7۹�_2wK���~��jP�e�a��Y�Kg5��z��m��~��ǟΊ-����c`#:�z���R��Y�f9��lX΂���˒�f�y	���2�{��t��m��-�p���z7����~��n<�� [�5�H��C��������=��01����;�I�9^.�"~��]�O/G��r�v;ۙ;�"�^�a�빫�<3������|��޹��+]�5LO���߾��_��w!_��z+|;�����B� �?�Z��C�=z!̫�uV-�2�k�ݏ�Wq5Au�z]�v��;���[���`�X#��.�K{�W��2��ƾ`/��k�x�KW^�Grb�(��O�8o�'�ȧ�@���O�	*�K���A�q�����j�--�TX�_C	�f�_�0ؖO��9��z��J��?\�Կ���~���[m����3�ͷ��,�'�����`�~��z�0��Zߚ�_�{{�pAp��?�?��W[�����%������~�ydu����m��0?~5'����������y�\�n�w���3+bZu��yخܣX���>�W0C�[,g?�����g?�r�*W<��F�a�X>>y����2�r���K���|�z���3�/�g�m`�ʐk�G3�����"Ct0�3Z�خ���� ;	 :��S�B�H1��
#	(�O��[ᖌ�Pi�����>d�?�[#�=2��ó�=�|���Ã%F��	?�X��(�W���C_6�i����Y� uu�A�*�d�:��O�S|w��?<�g%���(8r�l������t�^�߿;%���r���֛�l���n6�<2�f����Cd,ށ�O�/>U.���������Ŭ�tzy٣�asX/����yr�S��}�������q�|�4'��߻C\����_���c�H�������
_s8��3ru押�*�`��61W�~��P�����nc.>s�}�lWw׳�W_m`gvy���^}�����5C�a��0���q�π(���.�P���qͧ��ieW筳] � �%j��9�\V;�#9v����ho�W��B�P*�TA�̀��cU��j��?ΠTD/��UU����b��噶܋�杘��^Fڥ&�n�~�D�Mg��+�kP��)�'����Scݚ����[�h����2&�-Bƈ�i�y��z�	�-��M�Z�3�����)�+�폲?��A�V~rn䝷`H�=ǂ��b��T���!�^��?�T�愕7�;!����Xp�070��ٟ産��ۣ|Px۬��9)\L��ۏ����-��j�c1��M ��m#[��|h k�ڟ0��W:�r�#M��z�,��1cp��s,�o�K ����w�+�c%Eh�j�QD�[�������5�cU�c�Y���qKc���9f��Nd�K^�m�yBx����G�]�N'x����bK^�m�yB�cU��^~	�.����͛���k�����}'d��圲�SO�b�V������}mW΍~�(�׋���M��f����rh*;��BW�����[r�lQ���y�~u���V:��A(9^ ��L)�v]�Cw60�ʬ�̠����~��Zy�����0���8�P� �   �l�oY�0{��Y������k���}���y�yb^;������j�Oe����m��g����b;;�|��f������y�v��n�jz2g�i�jCFF�[RC�Qr�[��u�s�X�Cȅ��d> �U4kةy�*�5�B���r�f֫��<�!���{z�1���͛��պ!ea�u�p��g�mݬT��f=�zO�1 �T���t���W��������      �   �  x��\�o�8f�
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
���U��<�U�z����qOij �ZQ�B����) cW"Ȼ	^7�x�mk�S�l��@0F"���+�D�����%)R �2&��H���#�yӘA�6�;r]!M~0�J�|�<jNG�4��Zӛc�[HUG�B,��PM"�@f���Y�~� �@�(��qW�@�b�q����"b&~� ��=���kF쮷J���2�$��yօ�Mtϧ�A�� ;�qc��H8���]�_�,��FY��Ȋ��?�1[��?�T���WH���ǯy���m$�Y����]�?��E��_v����ϼ��4a�i��~���I2��4�G̏��Ċ�W�~!M�|�q$y�4�{�� �:$,��$��'�\�!�F�|�n�����1�v��CM(*�AL�o�k���'U[j��Ƚ&ElQ(<����<G��ԟ�9[�v�_��s�^s��*H�<�M�O������qqF3U�K����d�Í��w{�Tn������9N�� '"l�l�������#�Q��xN��=L�/]z�4.�?�D�;d�)A���Z���Os3�R��LE<��mq���?�������Ԟ�O��J���B�F�J�d�̀E���~m*X�i�����)�߿�y�����      �   �   x���=� Fgs
. ��MX�e�ʂ�QS5D�~I�]k/�d�=Q�^�rL
\�\V�l�U��������'H#(TV��Bm}D/4qt�vQj�{�I�<�l�'���׳=�\_��O[4Ic�(�x����`:鉴w,I����7�      �   >  x����N�0�c��� ���z:cbb������a&�n�B&C�M= ���i��K�$�<~}qD@&��Q�6�3}�C]�e^�]S���Ue���M]D�q�K��2/����Em�B�7G�Lp��8z�����C���x����Ys����f�:��M�u3�eӑ���rf��sE(4-l3Y |Rw�2fA����s5���x6�W�UT`�I�xNT�4O�0�W���,�,�&s��Z\�P�	_9��}���y[,#���)v�"��{b��R����^�T;Dvv,��:ǲ^�p��˚�:��O#�D�      �   �  x����n�0�c�
n���O[�˒%�W�	q.3a���?pSʊ��U=0��/�%�T�9A��,� 0����)��&���7��� �������F�m����~�ώ����ۅQ j�|#`�}+���K�#LJ2���܂Ȝwt`����R��uQ&�MU�:�^��cSu��LV�� T`�zޔ�f����X�Wx�-h��T�5�^*����s�RG���`������Z e�����o�rG��w �-�f&iN0>�8�`셎p)�u�� jg=�3���[�D*JS��.���T���d��㰗;�}���gw�<�R��V�Ć��v���.3����n]H��L<5G4�{p�_�J����� �HmU�,��*�N��[D���.�1�Q���V�x���Z�)7t�ם��$2m g� ���И�B'!?w���¦�󰅘N�?�S�b      �   �   x�����0���S����-��:W�F�81P��[0Cpлn��ߗ#EV('4rUx[z��6�B�C-�R�� �B'>�i��|�i��x�}��X��r��|\�ۆmN*�Q���[�~Rȳ����C���M)�v�W�|�B�|���`Cy���1� ��Z      �   �   x�m��
�0Eד��f�2�J�Ѝt��M��A���[�M�ٜ�������'��e���@�*G�1Y!���ӆ+@h�p���>�.�_C�ؘ�����:�b�2%�ѩ#��[��96���;>J����$_B��H��7�q��\��\�q����!�4�$��Te*����_U�      �      x��}]o�������ۼ]����x� l'�� �y�$�H��6d)����[�]�3����p��Y$��]����;]��s��{�:\�������`���u=������r��#PUAO{�����j��q+  7��yq=l6�)�����ݰ�/��r\���� ����]<��+�I�<�+��q�>�'�|}]�7�a��7P����q܋q��q\
���q?���t}���j�嫯>y��Q�W����K㿯ƺ`�Y���_��-�w�%��h5�����S�Ƣ�eI>.��`"M�?�L�ŝ��+�Efd�����W�����n�����wP�	��rx�G�_ؿ�m�`^��F�F�>�dn��5؅��_��x���`6W��������Z�����g��Xz�v�<Z�*I��hm{��/־2`<���Z� �����bv������jv�a�U&�K������1иZ�6<�:�{wu�<�M�a��}̇���_�s�lc���V��a��#6��wX�K���xDĂ�G��j�7�,���aܪ/��J�l�p��.�"�*�����pd)/����_��d�q��\(aJ)��(�A�TR�d�Q]
	������z@C�/�K0�I$c�׃������}>�b<r<���M}7����~��p>y��cԃ��ݰ�"� @o;��N��=H@�>?�O�	������~���Lhq���6�|�}^o����p���!_7��ߑQ�z�y7�~z��A@y.�]�=�ˀv<,����BM�Pm���qqw�z�_���aj`����hL���3HH>��!�ٿ��A��t�v3` �.,���(���^��a[ļ]�W d���x@�`�ny|X*�zE0{���ZA֫ ��+������~�o���ߋǟn?W��Su�_˙$`ȻVۣ"F���׼�OJĩ �U���jP����t���\��4f�|C<S���9�Tf��1��;wWU������s>I����+�f�t��df�7?�W�;��~�� v}��N��T���_�o�l�=���d�<��d���H���ᗻ�+H�6z��eZ�]�yt��P��ܭ\A�(������1�
2�A>l_�S=�;,ņj@ц�����o*�������+�=.����,7��a��6-(�B&�{�󘏉�-(x��7;��Z���0��{��@�%��������⃻�+���)P\<qZP��ė��_B}�l��ߨ]�yg�q)ve��v�!tV�&q�!ʗ�@i��a���QL��4M�}�����J�5Hϯ���;��F�Q"�$���S��g��϶���G�˄���Ko��eaS3�Jū�	?�fa5s5��T'������O'��U���'|*���΄�4q�Y�m��IQ�ay�-j�f����
��ϯNB� \&s�,�|7��f��N	4	�6]}ƃ�����s�����U��w�ĔT��ֽX������A�ޘ�f<z�Ճ�Yd��zP�xvn� ���N1+�*� �䃝�}��������|IV�^V��E@ZB����g�qp�$���z�_�7L��~��5@�5����N|6�ތ��F	l88�35v�e� �7�LJ?n=�	�DCe�H� Q4LB�2��_�6UfKm9j[����(ǳ,�g���зZ��?%��&sw�!��o��O���^�'���K&"^�@z�V��0���ݰ�7��Đ�B3��g�j�@N��5@�ʠ��3L�
� ��s4!x���(��`߫�Y5��J�!����bWC���e�B�����6wG����8�/w k�u��[J���:WC���	�5�85۱?f59�۽���c�	����y0��Kȫ��yM�o@$-��۝�j�5����W;'���&��0U%B��U���ۙ`j(�6n��v� - �/G9�qԔ��㨩D �Y�"�/MÙ��ըA��
T��`�������z5�?��>c�,:%���WS�����k���)0���N� ���A��|S�=ik�Tx�-��h�y�P��}�r܈hA��$�؎���Q�j%�@_3oX|�L���uP�V�4�~(ru��,����� � F��-��;o���X�B���Z�3��	�4������f������°.�('-ƿԑ�����޶k�$f�\j�d4���k�FIƯ�|� #I�J�y��~d�HCCV�թ�X�Z�X9%��rd�Љ�l�Q������;E��-����|]��|�bU">BZ|�[0b�˸�,�T)m�T�c�l�5���B�zP<;���ac>~u���c��ƕ]*��{y���w�d澒�W�W/K5�c��E�����a.���������!qb��D�@P���v�o�� 7�_˃<�;��	2'���&a���g�	�w��z��o��m�.��ZB�7�7��2�$�,���M��b?�f�$�v�~�w��!��`^CVK�`�����
1^c�L�Fh���I �fN15D���`Z�t�*e��o�j���|�X�Xzh�N�{/+�[�1�Sp�#q'ޣ��2�4.�i����Y���@���Z���+�^}������n�K!&c>BX��E� 	&#`�#���L]k��c�!R	-�^�����u-�\2���D4�- �Xܓ���_���%:�F"* � � ���ݘC}Ph�P��@!���agw�neN���j��6t����<��RBܴ��6x�w���R .��&+;C`ݴ��q[��n�@s}uk�@3�(-H�S~ITO���\TS��ȣJiC����^�PoJ#V�C�WE|]=;K@œ�����i�|�g�gom��/��Lj�"6�z�a�\Y,b�O�/Ԙ9\��_K?�l����j�������>5|$m����}��x���� ˜O�-��6p�5��d�*T�4Ü|V�o�B�xs�^�����@0��ڂZmq��`��g�(�U���E�@�$`���iA����~3��fЯ��	5p�5��*���D@�^ީф�G��i�e��>ɂ���tK��~�:в�*�߮
�;P�;�@��ҁ��d��X�;P�x��u�@�n�h#0o�� �o��" R�o�Gcx?��FA��-�����/�kjr����ű��k��2⫁:���]��F�LAj���Z�0nܚ�iF��˙���2Y���!I�*�(�ʰ�J4@\�?4P���H����˼;u":^	CE�y4���L����í�B	h� e���ԯʯ��/���qPG)�^Ʉ��e���wB�i�����0���,P��".����(�ϊ�&�.���@�Ȅ-M��%�W�W*I�����u��Bk!)���qK�B3������Zc-��r����&�~ޭ�B#�/QA��qa&(a�o!�M �z���B�Pw�����Q6x����j!����P��N����Q�ʇ����6P!o�ޝ��B8l!��Ω?-���_�X ��c�[�
<ka�	��f.���}�-d�vr?���Kl��[�ҸPBsٰe�W�eĮ��5�UZh!���L��Z�ڿ'�����:5vn1�|����E��{p���*0	Z}�K�A��>-����^���0$��<>u Uq���%�dH֯��4X���S�C�;w񴐨tn��_�=�,as��x�`�� ���`�����Z��x�9���w��ι�b�������Q�*���*�����Z�<27���-$��$d}�4��.��X����:ԛ"_�>�Պ���ZHb'���[�Z�b-¶��ʌ�B;�\�UA D�����_G�}3i8_�����N0ވ����4�E�XTsW�DV��q+�-���$��[ b=� ��"uI��S����"��Njޓ"tĲ�Oz���Y^��G-| <=���D-���h�4��a;�Ð�nN5�@�>�$j    ���	�G��4�[e�j!;�pjd�/n���M0�~��$q�%�obP��8���qx�$�Z}8^�� y�Cr����	��^=�۟^�?�Ǧ�mq~��.�A��܉�b	H���u��1؅۶�;k�e9u�l�"쌈%i맄�3b�F92�K��xNEnL��3��J�<3D1l)��@�o��a5{�eX�]��2��@=_�����Xd���B_;(��g34���t�: ���A��p�v�����a��Qi��{�V�Qx�v��=A�?
�y��0��*9����ɟb�_��Pv�A��J���0hi2&�l����0�]�Zo����4}��xy�@&�
�Y�O���!~J="�hٙΨ�!��Ʃˋ��7��v���'k�3kWҕ�迵�뉶&���e�W��*���r#�X�3�a<,=k,�6,E��Z;h ���$�n�,'BAz@>�X�K���v�;
���nB�&q�4��� �A��`��t͚��Yj���,��:H��Y�yuy|�ڄH�����!!��B �`��&K��0�ϕ���ZJ�`���^��3l/L8~;|^7��A��-�cL�xEv�(s��g�×v���ξ�A�8!$������P�A��A�5�8<�Xɯ�1�E��u��#�K����:�l��Q0�ŋc��;����yG^����.�Z}�N�� �wg�Y	�r��­�A$�����}��wtm5&W��A��j�R���	N��	�cL;���EP�E�/(�	l뱜��v�޽R�� &wS�ѵF$"����ݴ�@��a�S�my��=/�����R�*�d~�9dy;>ҋ�A��a8.��{,"��K�������:�6�8��R�X��J�YwH:�0�EV�5z,U���!�F��5p��I�;ǽbv�l�0�}q+!���d�Q����(���a�&`iu>�"^����F9a� G���A��DHq���!G�{JT �� ���f^�]�t���w�6^4���$�=Y���4���1������<Ǌ���Dc�|��ZR���L&i��sB��v�`:�{��"��x)^C���B�0����W�)o�_�P+�̃�~_m�8�&yh%|��5v�E����Ws�`�O��w��������@#�/��1#\6�|�o�.�P
P܁�jM�[�� "t��~��S1�s���I��5pN�p��r�{Ke�{ "M��K�"�o>�Z��:4h+�Z��=e޾Y�o�����0"t��4$���a��ĭ���o���WY�#��F%�G�='Ȍ�<B���~e�P�Lr-������G(BDi�q�6d�_"r�G�!ރgh��'�D�_��a�ÿ�>J��$��ƃ�1V��%D���V�dD�y� ��\0ڙ	tX���A���EF����o�h��f�=-��"�����@���!/�k�UiQ"fV�5Y� I�*B���ʔ_V�au�*�, �`] �/���<������x m�q���G:	�Y����,����:r�БoTف-�6ˠ"6K���x�]���X��k����EJ=1pV��/X�E:A�Thh�{�0����)��F�/qY�9zNO�����0�"6`�(��|�P�e&A�6O�F����_>�Z\�	+�NjX&������#��|,~� ��5�J|�x��5�d��"���S�����@	j��	Y�*-9A!�XR��T�D���{�!A!L�oC��}0�s��m��T%�����{�%(�6��j�>��6�U�0'�S������	�D�RF|Ƥa�Ḳ2N&�Q5�T�����y��>��[��f~��M�0?�tھ.gp�����	�����7N�~<B3���� �!b����g�O��HfH�ZO���$��	.!CT��	�c�ƌk���5�y�u~jL��j�G/�&hS�����Sr&�%A�A:�]����)�4�IIPy������Z8�l��b���P5�i��F�'�������k�\8ŷ6X�fJ1�������&JPbuku��i���p@ڞ?��锾��^��y�P)g	zP!~k�3�4!`�+�����4U�R�Y�ړΕ�>zGv��s�1��n$�;	���OnK��I���!�	�@��օ�� ���RI��oT��Q6	�z��>�R:�˓$� n��}���ǲ�)4� ��8R/�;;AOSP��vK��9w|�g����]$���9G�X�ZU�J���ׯJ�,ZKDz�T�!!�+M��T�q�H��`B]qZhfn��`�U�yӐECU�k��'��[Q�8��c���+u�h�T��'N�#�I�	��D7�o+�8�?X��4%X��� �9jV�v_��L�}���� 1��:d��`����E=�-��%�����k!��X8���Bs���Ql���~Z*	����2�=�Ν�y4��g^�HI����O�sL3�(�jpzvB������J	�f����Y�b�b̈́�#!ʌ�dP�PwB����H3��_��ݙ11p�퇃�n3��GG��y�.�㣋�1g��&�t�SkE�~:�CB=7GYY�E?a�{�q45L�VH(�6�'�"n�����E��{gm����%e'n� }/L	��?6H*�Ba���@���Z�;/j�:�r��fB:�Z�sߨ�C�	չ<�P�Q���蓂���](ll��	��̜���h�a?��]#���P��A�/ϻ�1�I�VB}>Q�RB9��f$5��R	���	�A5��P� ������Mf�bF�<gد��ץ^��Lh%|e���!߭"�j���{?�f�6��D2]�L�s��r�L���_�F��v��'����)�]U��Ђw����z���ߧ},CR{x!{����Ʈ���/�7_U����4�������_z�D~I����[��}=�c=R۵g��Έ'�z*m'=�/���^��|��҄0(w��оĘ?a���m�O�νHt��a�x��kz��^F��J�8�P��a�uo��<�S߽&��O����.�qp=��2k�-�&b^Q�-�PX���yU���ҿ���a��c�ֱrrG�h����'��{ьl U�L6�oHEH��Ui��Մ}��v �t�ʰ- �	h
�hS+-!��2[:Sp�����P��a+���&M�����
h?�*x �'���a�!�g���/� P �d ���^K`y*Y�jB���j ���Rbvl�d(#Q��N��%�4�A�:��&.n�b�j��]��Oa8qج���{�pb�z�=Ťؿ��"'�4�L0(��v��"a:��4!D(��p�4~���ZYvY����@�"����R�-�Uk�1ޔ�m!f�~L�)ғ�JU�2���s�b���Lyӷ8�5\Ei@*BP�G�T��`��h��+D[Y����nz�tݏ�tb*�2�Ҩta��e�����0+0�ޱi��?��N��J�FY�c�l�Q�l�jaSO��1�g3z/U�Q`bٓ��J�'3�q߭]��{-�2���]��f���Vl��K� �U>����$Tj/@�;[inh���|����t����>,��b#ĐP�e�o�X���߳e����P��~��'��Kw��t5���| _�"&�3��{�y1&�;���C?��T}C����C��nH�|?�I����v.-5�vv�(����5���4-����א�v��nm�#�YU������ǂ���3����0x��[`V��Y�������N	��v��Q�Xp��/��h9;������¹��l�ɆQ��|����4|�{#і*V�^�҄B���v+8�I]�[�"6��4�T[�
e��쓁-�B�4�7�d������(5�=V�a�5tX_n2��s'��Y��؏
��
݁m�����|��t�.�\98˗,̒�!Zұ!X�!!�s�?}E+�3��	��DB�c��_�v��7T gOEY��P�U+�r    ����Uv��@U�
Q���dJZyl��TP��DE�P��!�qx֝� j	*!U>�����&�Y�N��a����W "�ޕ��g�6y�6Z"=y�B`���X�����B������!�)+����N��ޤ�EP�~\	0�\�kO�v��O�>y����/}���H^����f�֡�v����V���5�� Tp���:����j�D�I��d�
|���E�X14(����3�ܭt�[6t��.[�c����]��"�4?)�m�B�ǅ���Q��<�iw*,#�!W�X��Ԏ�Y��}�Bi�5�=f��G�@�j;�J�dIo`b��9�8-=S�����}��_�.��ր��*@ؾ��o%�����%�Lm��/m59�E|S`//`������@�~T0�	ցM�b8���إ������H�8�bR;uM*Pa����Si�-ja*�wB+��1�屷�8�h��J�{呭� �H�z�����>���J`m��b#⽁Io��YN��~j�pCQ��^����B�����%�
���l~o_�?�%b�-Q�S��J��$a1��S�s gF��	̸�L�lIV����Gė_�@C��n"i�������h�\Ɋ)@wD�;�� �#S�Z܊3�.g�@�"+��Y`s�W'J���e�~`���g{���ތ/ț۝8v7����������Z��r[�A�%J�vh�ռ��<�%�ns\�z��i�;���"a����}h�h���K�QO,��P���¥®b��L�M6Ȋ#"���9�.�7%����g��l+�l�7����� w�~|ViH�|����t���[�LB�&P2��Jz]6�^D����A��\�����TӖs4��_����RZTA���"�~g���T[Pkn���t�A�խsBKMݜ�����e~�N�尞'-x�v~	6�B��>���}}2��gt\PUU������f��� x�]4��R��������g�>d��K9ve�d;2�|m��6d�
���� ��3K��M��e���<�%��ռ,�}��y�`��p��q�b�Мs֤e�}X
A��~d?�����-Y��!�����ɜ�Zl�B����I*��Y.!.E%�/0O�{j`S���*K9�D�X�F�?l����+�l�Ue���q�U x��+#Ł�
n;�K�1�Q�����nXWDy^���懬=Ʌ�I0����z�<E�w`K��>��w2��^MZ� ��h��p>4��/[��a�H��ݍ��XN�b���n1n] QH�0AfZ�T]�D�,0���9��8��qƙ���9�mp,�j��9��r��9N5-��5\ڦX�ƙ���9�"�>��NhJ�����v��s���~�%�ک�O�
��:�6�)㈅SsiI�vJ���� ��-�A�f2f`���0��^9 ��߅�̦7�]o@���l`��.�ByX:���fG����|s�h�[߄sa�M�����:�yzG�u�"�-�!�h��'��X//���aq��t$��۬�f�I�h���RZf�0����B`K�3����ٔ��sH�oy�G.�{��"�a�51�~��#��	ͥ�6J��H�T���	�Vړ�l��[�����^�`O����-eΘǝO4l*s�
�Dq��+����B(}�zұ������z��?�ݛ'L��=�9���3
 jB��.�PO��S��L�s#�S�.P$H�5�p�p)�.����d	�6���g�BQ(��������ؙt)40��J��8^�em�Hh� (��"����a�؍�^7tX��1�y,�h�)����OH�.pZx�����6�I�)9^3A�M��r~�ʡ�lU����/:&N�T��&ʷz�h�QcsV�~�K���4�$ ���0ѽD�*h:A��v��3v?I�(���u��\�>Q�:�rq�i=�c�Ϣ	�_t2P���[��M89�D}��[.�5�#��פRGW@���^��l�NӢ�:0=1s�&P�����!�,P�	��c������z8,tY`s�,�)TM�͈��t\���{luė��{E
�9jfS��h�$-8�uN��h������ <I�����"m��b�O���fa�'���y6���`�7u�0���&�QA�c�$�V�'��I��,�=����4Rd_�{3	2�N�4&�lP��e�|�;�����&eop �>eD��r��Q@y��t�*��¨! �{�	>���ʀ����v}��Qvb��>���� �U"';�a��ҰԎlH���X��4F��A�I��7�yeK{BS@1�[.��������ZME��sj����PPmA�����[�Z�	������,uZn��\I��Kl�ض,�H����M�e)=����T�M~tG�*�v�b����GA���,} �T���iD�n`����6>;�=x0�y%�
v���}��ٴ&���*fع�����{]�;��k���_,;� sbo�*��\���W���<�\1�Iajbn���ZM���dKJ⃉vL�t<�w��\`㕀�&K���F�ݱe�$bⰺ�ٍ�'t�R�� �Ǎ�X8|n�(��l�����l��w%s
�E��
@7��ʷ�Zke�g�|l�r��X����y������Ow|٩%�U˰����c-�}�{�`���yx������Ͱqq��`��Q^s��؋Ev�	������m%�݊���卜j��J�$(9߈��̌ćD�� �'w	��
���^x`��[���`�`��w�3�8_�\��U�5�����PQv�S[5\s��媨%�I30�С�{OڔL�rK��τ�%p3���Tfc���Z���S��/�w4@uh*�z�n?��G(}7�:ߑ�; bY�6ؿ�}Tc��&ȱ_v�����Ty�K�X"[x U�/�+�=<[hHY�m4�ǜh�Q�j�Tq��a
"V�{e
=��I
U�|59l���	m��ʾp�
,/ȃo��F��a�|]Č���
b��e.�) $��6��I�e��X�b؁} :�&�u�;�wHÙ?%;�K��� _�A �fX^��#=�E6-g����~�sM��[�"Jve����֗���T�J���� �~c�F�踘��7���0C/(�n~AXYj���B� 1���m,�̌K���b����sR��2	,�qR .XG�яG�.Y�.=
Q����50��<0����/5֖'$?aq/�
��'&s%�!"��?�U�1lq\��� ֝�j���I��9�C�Z	��������[��/�/�)��B!ȓ���4��� �T�[(�><����@v�!�\cw���s{D��羧;a~�X�H�����H��0:]/Rp���BJ��^'�["b�%7�%�A�X��#~v�TA�O�P&�)�1���/�Y���Zc0�/r^(�j��C�B�د��k�%$�MG~��R�hUL�z�?��@�&	1��7�ET�$���u�~��,�*�����(p�0��V�����V�E�	�I�Foa���xF��6�/�C �������&g���FԌ�~|Q�\��l��r�� �E�����#*�.>�#�U�nK��Y||�NK�X_��$j���?���^A/,�[i�lY�� �a��O�D����U����#]}@�?��������9��/��b���g	�@��4"\� �㭺kT��0x�@��0�n�ތ�:�׎�l�a?W�|����; V6�����b����Ȇ�s.R)�������4,�E��:�<�z������!�3rc�O,�F��*ǵ��a����'���p4��2f��R�}f��47%�ͦF������
S]`��7��`�X���M�7RDNJB�A>j�<Kl����~2����,�IDMDI|0���5ӫL*^yA&Q�MPV���L�j�*�N�K˵"e�Ok������
�� �
  �o9i�X-��-ᕂ'��1cq~d�'ktnӱzl�K%Ǖ�qY:��Oʞm�d���*�b<����?=�D}IDP�]�y�KD=�C��q�ejéN�t�P��B�~!X��������n�}�	2i��dOndX4��+R�8�g��YF�~�0!Q�7��.P�K�̰�.�b��x��%��aT{�Pow+�S��%r��1��v���Hs�Fc�/�LS5×Y��~&;���I���Љ�x��Ey����Z(L��u2����`���%�g*[��0[�����O�!gɈ�6�^�"u�e�_���DO��d1a x��ɕń��=��N�XɶbM\��
�L匿X��w�oQ`�w�V,>[�⳿e1e�z�f� �����Z�.f?'���,������0\s�B����9��� X{���T�t�0��u��wf����	�[��"��=��)�rT,��ʷ�x����V,�k?(^z�ފEy�PY�k�V��x���b1ު��e�v�cV,���iʾR� /pw�<ƞ��x��+bU�(oŚ�J��/�ǈr��v�.iS����H�Q�Ҿ�mkT����*� .�X��g� �V���E�ݔ�a}8���R������*J���4�iHl��B��0�� 
�M�Qs	���nDsF��l�
����<'/םp����?��)�j��E���mV,��qeX��2�Ҁ�b=e@Q^��!@��u3J}d�W���7��K5S�Q�T�C3 E�&���P�W�˩4�
K\�3�\`T@�H�����`���Bf���xǽS��TND�2� M)��=:n �3�{��t�D]&��KԨX��b]l���⣟F5���#���š+���E9�+�&��'�Tӊ������Y� 4 v�.��� �N����93�x͛QN,��NL�`O�,?�<�h^�EE7�<������A|s"�m���x"�j�dm����D'm��� K����T,�m?S���(.7V��zP���nq��+PCL�sXr��R�ku�q&�u'�%d>���bmn��c�,�}B���W�W�ol�Ƹ�	�NS�&7!�v(Iy���07q�A'v/AZ�
��v{���=��A�ؘ����XD�p�f-�G0?!�f���PY���G���6!��;裋N�X��~���-`l�"��W�2{C@5AK�o�����f�z5wL]nrG�����W�XV�����;Y��:�7�#��p
�OU5[`ڂY�׋���q��
��O�(�) L= &���.���4��͟��m�����~�o`����Ë���k�|�^���*���>�F��k��&�U,B�|�B���%�nJuY�\/PV.�t��:N��|<׃E��g�D�3���8' Y:N���N�8�s|�Hd ,�ϙ�$���8<u�t�~ݔ�����_��(�L��ܯ��P	 �9��y����iG�b<7ح�T�R���,}�?��'��λ�j&�qK����e� �;��b���DB�_J(�E����bt[&r��o։�B�'a��/H�H���l5��D�O ��{��?+Ӓ��|_?���q��m8zkf�k�4 �%��
*Y��0$9I
�\䷥���H�Sy�ed,���ug�'LZ���0>�m�P�M�)OV�mn���Q��g��;�C�S��?��>��4s��e?����N���W@�@�>�
 i���]��4����».��;���ӓ���f��y@|@��E��'`F�D�	��h�B]S�B\D�����~�����2[���)�Y^����2]�ɯSE5�L��\�z��[QK�����8lRc?��̶4���8�j��.�~6�9����MV��T����V�RP������z���^*@�&{�Th�a���M(r��=J�_U%슝I �A|��V�H�[d#@��o�l��-�m��RQ�FǊ�_jߵ��v�i	DS�@!D� �VbTDw���:os�ƱL����z�+11��a��U�]�׊5�1<��c�d`�BN�V,�i?W��z�"�*�����zу�1��wT����	���}�]��u&+�a6Z�a�IbN�~����%L�Xo�<��}zb��)'Y���Xc��f�r���5  k��*�� �Q�O��_�� �<Ίe5��-C�V� ��:@�/���\I���zp<��]�NFŪ���ǴT,�Q��O�hǊ�2afJ�����,�������*+�8cf^�
��TZ��F3V� ���kkT��:<�Bn�M��ϵS��J��X��b�T�j�c,�r���(���r\���Z�� �w�X��:��A,�A����[q+��	 �T�ՙ�̫X�� �B!���A���?�h&��8P������X�P(�pm����5�����X�������i���՝�Wt�d>��+� ��<_��j9k�R^�l))�p����o{U�#i�%��X:f(P[@{�$dq�K���A0~�ͫ�ܱ-�t�޻�8U)�]=�H؊�A0�u�Z��V,�a?Y^�\��"N�⩖�d<��F�tߞ����6��}�:��Y�j8r�ǥb4q�v����4���cNfqAF��R�3�g��������\
V(��U5�P��:��ߢY1�R�<���������      �   ;  x���MN�0�uz�^���b;��ر�Kp�A����f���.Q�������Y�m��0��*����-�B\�O ��R^�7�>�#mYQF��Z�;C���a���R�mRQi��BO�E�nt�w�Xŉ�����>'���샩R'�hK�<M5�J���՘!�~�ڞJ��eX��!P��.U}ɍ����TM�a�TV7�6H�v����
ŉ��.���Yr�V�x'ii���0I��-�i�y�n�)�p� �Qo�7���'��11����-~�i��)��RJS-n;$6�c7ʉS���,����      �   �  x���Mr�&�����������r�]vS�K����q��	��9��z������7�W�.�As1�T�?��$�����?��J?���esKM�%�҅�rm�,��p���E�7"t�N-#W�%!|L&�o?�ΉH��sQCń������ǔ�O��]%�	%�<J쨹*A�q�)u�hV��KDz$.��s�R̥5"=)aW�yϠԨ%�;陸�j�V���\�Э�H���ٟ˙Y���ۑ��+��P�a�!��XJ}��fS*�3D�#���OR������XK����J�D���h�{o�"/w�˲��P�����L�z{P�����������Z��[�2Q�"I�7։x��7�CB����k�<���.	HeJ����d��:�W�_@@Y�a>���`}�YU�W�n��%�ڦ@	K��wg��ȸ$m�H�$=k��q����%$�ą�/?Z!Od#�#��zvQl�4���gb�ګG����s�ZM��ҙXK�$���dh%���-����Oq�RV���R)�a�&"�]���T;J&#_�]�$"�]�t(�ĠI�s4-�G""��HCR?���Ku����7�rl��R�(�ց��f�BT�>�Q��XIG����5_˪��_霞>'�c�K�F��K�����SX��Z���پ��ӂ���s�7H-����"&��:��;Mo�M��ҙ����g��%��s�����;Wo_8{���l����D�����D�$⧃���P�&�+I:z�V��;wM���Hk`���q뛃�7�H�DD�띞������(nsS.��HD��G�OI��7�\�z��h�N�""�i���Ҩ�ј<77	,��F*"���c���9�D� ���ӽRh�������p����������EB�,��^��;���.��ɼB�V|��G=�q�F�
��k$b�}1~��y�xB$_J�?�l}@"�9�>a��.������q�����D�sD�?���˿���      �   y  x��U]o�0}�_q���-��(}�RR%@h�&U����f����ρ���)%�ă��=����6���!���o�����Z׈C�WN�4�%7N��qjn�qd~ur��p'4*�4��-Ơ	�K|5���f���F��#�˄s5�qMߡL����\G�)o�Rr�·�s7�����Lg����V6{�"��x]�-H&^*z[tq�����c�}�����b��^?���q����b�N�7Q�\q�^>��/f��x ])4�����u�� !�.C�f��#;(7w�]�-�0�?&�˩�"��*d�3��ʟ33l0Uri�\��Z�*�y	��!{
ь�-����̈�T����b��S �s�UR.�YS����R!<�%�@=�y�'�T�}��L�V�ْ��0�xN��,��|��0o��q�%9+Qn���#_���X�f@��R؎-$����_�Rύ>�Y\���;�jMĽ�����DmZ��5[wb*KDX��j���(9��o��& ᤤq�샬�4�󼔴����LI;)�RnJ�s��S�I ��S�_��~J�\.��4Ui�~Ji�A��O�	5W�4U�������Oi;ߨ�~J���Oi�@ri?m�j��O?����ut2�      �   ^  x����n�0Ư�S��l��U/�I��I�&��7.�[�I���w�hJ.�~��s>�� R����d�	�6֑��!/"��\�)7S	T�L�LS��#���{�Gin⟰X��҂�H�gz�yA��H8 ��"�\���[Է_',!� �v�*�&ø��}���a>�ajd�V���ٱ^�bBI!;�猶z�-��2�oh��Q��]X5��RY�Uj���ɷ����T4�:T�i�m��&�h��H�H릿���SNJ��%�UX*\&|�I/��H�AC�z��B�Uֳ8̸6h��U��mS,}��]������,�����e*�����f
{��u��A��iN�ˤ�gTO���U��p����9y
eҚ�D̍��ϸb`�5� �|mA�1����� b��й�)�7�g�U��ͳfP��Gaqn}B�_�!��CJ��%�/_��x��S�ɦZ+I+g�&��s���̺����	�8g"ߝt
6��Xn�G7��:>Ξ�W���sH�ـ�c��;N�l;I���]�t�����7�,*S8愀�C��a����-s���{6�L���b�      �   	  x���MoG���_� �r>��C[�Z�@�^rQ�M�D���n�_r�;��"�6�KX��;/%���Υw��Gm��<o������^�&�<`�)�����v2w����9o��J��3w��|7�����N�|we��}�<�p��ܚ��AC�h�O���/������߭/��T�9.*�[���q�_)��L^����ƀ6b��E��"�t��̮TK��Z����F#T�1CN�;��j��!([�)Ur��M��H!�T�-Ï<���R6-,rE+d;�	tW����'.K��2�H~?z�O#�J�$s)*�2����dR�p*�2�!��lH�
*��",�;�czV�E�P)�����8�`K.%$s*B�!��4���`0 \���~�@B&*IH�2��Ex�@��-��sB�%DҲ�� �����|8�$o#���p�CM�2�����>��@��::j�"D���*�>�.�D�N�H��%l�V���N���CK��\"�MԬ˽��Ğo	`R�2R2d�f/�M��9ڟ��\��I�D����dO}5��O]ǉ�� 䃲3Qv����}�_��EWZ��qJ\���1FD��=�وn���X�u0Z�E���Si���P��SZ��4�N�w��i8���l���s�l{I����7w���j0��_����t;\����˃Q�!����O�D� ���S��hGFAc5YI�,ɿ�(���(��:�GBɩ�)ϕO�W�>�`e�m��<ИK6��i���8D�GA�����&C�%Y�ԋ�&�xE�A��j=�)ljI�)�i�T�)\B�A����?�R�$'�>X( ��$���BiJٴ�٧��M�I�K���j ��FE%�2\B�A)�6����8t �ħ��M^�w�%��Բ�`���*َs<�Z|X�l��xz<�-�斮�������_ލ�ـ����]��1t�%����a%����<9��|�[V�د�tk�%� �©i��o�r�A��e��Q�����^�T��a�H-��xi�����Bڿ{?!�]G����X�0�U���o�qs>}��>?���o[N'I����j0�W�n�lzN�D�ɏ��1��i��,�=����O��\a'��`?��S9�Up"3:n)i�{g!>ݼc�)[��p�3��r����|w}a>m�'ɦ"%A}�)��l^�o.h)K*i�%�������GW�9;Z�H;���m�k��뢮�����ʚLb��������y�����fV��Daěe�l�W�l���Tr�߁;e�Xm���fف-�*�$,�o�|A��O�AЎ�]3m	&�ɚ� q���4Q �!W�L!�$v�/*�$0 ��0���M�fn7�} Ҵ���E��F]X�|�.��(� ��:[t���e��=���Ij?8v�܅�&T��~�s ���@��f�qn,���F��@Ι�,m�ss�ҫI a<40o�>͍�:�N�2�ɿ�d�e�O��E�{u�H8enZVn`Ǚ������3�      �   V   x�]ɻ�  ��n
���0�	1Ji$
��K��{[��y�+������k+��fx!	��2S���y�Y=�?c��)��H\"���6      �     x���Kj�0�|�\ ��ь�Ji�+4��篒k�ZЂ7��~y������~Z�;L�������%Q��ϺG�e��g$`#L�O홨�<���U�3��]+�8(�R��RP䢲*	J�2pe*�*JGʠ
k�wՠ�@1C��vd���2���_�C-BXW�900`A/��2���,���ps���bZ�~`�I{��g�dm3f C�҃��Abߍs����J>NǇ �,���+�u��G�n8���[����h���K⟟:�4M_���r      �     x�u�Qk�:���_��}�T�ۏ���7��}QQ�Vq�@��=GN�%��e�p��tf4�4��$:Y�����G�&����������f�zU��rJyt�Q��4��"(C��I�lF�b��Ӫ����v!9B�Mo�z�,�����wR-�C{�bg��K��C��;ݨ�^'&y��X��gf^M姃P��N'����&�4�g'�0���:����OÛ�L�x�20�$��R���'
��XUg��ʠ�?	/�T���Y=M�M��Y�^��hV�~l�4Dӯ�ۣ�FdI��k3u����v�$iA�g?�f��ll��Q=�I苠;Z����A��i�;"`�%�n��C ԕ�G�A���ay{��Bs}\~��S��|j�S,��O<W�Q�b
�R�7�;?��u
�R����=�w�o�!���K̓�2�),��2����#��)���z��:��:j�ٮki��6p��n��v
����"��8���v����U�S%�Ԋ�_��Pf0!K<�&�%�k_���x��e��h�;^ؗaO�{L*!�޳���u��8u�~ס�V��F��0f��(���?G��_��=���ўԣ=ؖDL���F
u	��i{Ѩ�p0H�I~��c?R	ik[,���/s8�'�0�X���%�qBK����䨧&��4(��ș��E����Z�aC��(�z��F>� ���v�Ñ�n�G�%߉S���nojN��0�@��H/�6G,W͟i�t�m#n��	z{�~Yq�����A4�v�*\,ش���Q�<�z��UZ��"Y�7�Dq�8]ER��}���lx A�?�]�i���ڋ���t�C��P��mJJ��D�N�+V��DBʄ�����L�+Ye%��q=:�ԋ{�DN�d�U�����K����e�z�w��J$����Q���?x�>D/dC��p�C	���Tq���dDʈx���5RЖ��H�q�&�ޓ��@B�+��0�5���Q`� ��(�7`{`������P��>�C�F�{p�ߞ!MHF�^!K^�����_ȕZ�Ad�����ۑ���l7�Ր���$�+k�3'�����wp��Κ�	�Ʊr��G�EvQ�]L#�5D��:5����V�Izv�:ȷQ:|�4�@���G���?���u`�|�hb�l���5�:�u�����m�5�^'�HQM�xFu�ϑׂ&tCot8�	y��݈���&���������|�59�&ӄd ���_�|aq	�^̻�i%+���ym��孉ʈX9Ҿp��u�`�O�Є䫾�M6��x�HY��Ũz/�B���t~��D����#��&��T#��8 &8���In��I� ��˱�'�S#7�&��+�#�le˘��ĕ,�%�Hz���4Y��'\�u�V ��%�d� �ԄrM^�L?C$2=v�u��!W��+��	㐟�����$�CCyR�����E~���ʡ�౎ N<�\�r� b�gD%5�\�{��	蚄޲"�$�# 2d�����FXDlJ��P'�K�<dy�AN⻔��%���ds<�g��g@�&�%���_�(�O�!��k�h;D�h�������� �ˋ�_Y$|�����Z1.�|�˃a9�c�tG�$���`0 N��l|�ב>I:�~�B����XnQ����<H�cM�g�p`B:�-���E�l(_ۈG�!#b3�{���0L���5Ȉ���q����%疗�X�7��k��	 �^P��42�����Pǘې��hOi�`4']Gq}r2b�s�E�ICH6Gc���9�6z.���v�iN���;�rA9t�k���,p;Y9{��r�f7a�m`���m�&���߾�lE���7��ތ�)��F߆[x�*秙p�Tj@��n�����#͐N'��My΀Cl{=̐�G�8���⬐/L�����9Ð ��Tx����2�r��B��{M�y&b �2r��#rM�@H=E<&b@��<TM/������6ƕj      �   %   x�3��M�I���,�4Q`�e�閚�M"F��� Ua      �   �  x�Œ�n� ���)x���ˀO]i�Q��R���u���M�����I�V��^j��0��o����5�?�輀�X�4���]�׽��l{{5�1br�<_�O��<�C���cP�SǸ�����dY�6���,\���� T0ʾ`���x��O{�p_��<s��(���p�f���@�R�y0W*�0�5g��A݀Ă�2P�B����aB��o?+�]�;�����l��O�P����v{;�xaFg޻�����N�	���G�ަi���n$���	����h����Q]o[W���G�$՚��,j���m�s��.{ommٹ:��nl��M
�{ C��a\
CV%�F��a���Ty��(�AʛjrQM ϋ!3OҎM���YC���i��EƮ����L)��h!�v����Vo�I	ݶOߴ8��{�0���T�99`*�J��f\�^�j��a�      �   B  x���n�0���S�1����ڤ�bҴ'�4yব~��O?���V�ҩ�R�p���'�P,@.���-G�H� 0��a��F��a�5��/�i��n������1|��4��ew����I�U���|�6�O�.F�rFS����[g��S�&ЈV��0n�ǳ��=5�V�1�} ��a`��%��g�N N(Gz���/���U���G&�`쉙��Ì��~���&DӌS$[�	�L�#��
H+�j7����i޺6�J����l��SQT��-K�>�Wf��Y�!6��2�tnw���J��*����tmU���}��u���q�ƍ�⭏��v��$�}CҢ�p������n�m�J� �n]T.K�T	�5�I��[[����I���������4������ݖ�ْu�����S+��H@*�ը��E�JfKg�.F�����a%�R)X�4�J�^M��`�K��Y�ܧ���n�պ0]�������H����+j�^(���}�ک�9��ZT�*m��7�I�@�@T��1�,���Ԉ����4�,�� ��a��/�4�x)l{\��Ő�"��X��o�6Fӣ%�^ChDf?tM��� Ot��]�b��a@9�I?�Ӗ�  �is��5�
O/H� u�D�<=5�9^��&�1����jC3��m7�1��Z���������"Y^v鏟K��jo��_��S>��|����r �i��}L˝�!-ᵔq����a�S�R��è<�C�����v|��}�ALE�]-��`���7�c�ܽ������7[      �   r   x�]�A�0��+�"{�%��HAnH�(��>Ҟf����������&��u>Z���� ���A�X��;��e��,մ��YD�8��eo��3��TE#�fu�8�x����,�      �   �   x����
�0E�ӯ�(Il}t�\X_���:h�MJ�*�{-��Y�9ܹ7;�������U�
�H.���`R��$�Dw��Q�$�TY�������`����:ЌV��,SFݰBC�XTui[D?���5�@,2�����Đ���6� *�5�}+t����Xж⇳�ˠ�I��Ĳۀ&`e�54>�i�A�i|;��#t��Q����      �      x������ � �      �      x������ � �      �   F   x���70�t��
���,0� �5�tq�qq�.k���Kֈ3�����!�3P��=... �#�      �   �   x�m̱� �������� Cd7�M�1r����H��������Q�\�;oUS�=��(�8?���Ȳ�_(j��I1��D�Mq��� ��O�M���Av ��3��	L�A7�~eլg�ݐ��
ww5J�I$U�      �   _   x�]�1� �z8���|�f�,6Fi,��^�}��D�S��gp?�ѷ19T���4�����c�h9GՉ�њ�Ĝ}.����?�8,,)���U)      �   �   x�e���0C��W�V%)�h����2�l�t���	�b��# �Bƀ��UZYK��%�����w[e[��Z�WJP
�	�:O]�,�k+��}�U�L�h]iz��'�c�1{t�}��?�L�R<����1olK+�      �   x   x�3�t,K��IL�IEb�pr����*�XYXp���gPjqjQYj
��_�1gp~N
���҄34/%�H�9?����4�$3?�~SL9}3�JR��SQ�����qqq �1G%      �   �   x�m�M
� ���)��2o�h�=A ��m#�.r���.Jo�~�x����nVh��W�����ep���T����F�n���[�{?�~�:��m}S�b��4��"���E�9&NFI�R=)����J
�O�9����1/r�2�      �     x�u��n�0E��W��@B�vi�Ee�ͤ�b<F����רUZ���=~�O�ȑpRGB~74���wŬHbDwE�	��n�|S/���?���py��@���;l��7�a�>��b/�ho���|:`�$���۱W�+a�a�TEl$[C�:[C$��tRgZ��P��eE�N��{���ڒK/��Djk���I~�:�ss�R�XA����d���˸�������A!)Y�~��-˼���g;m�(���e��'��      �   8   x�r�70��M�KLO-��CC\A@y#Nϼ�Ғ��yCNǔ��<L�=... K      �   k  x����N�@����)��vvP���(�DBV�HM�6ۢ��6��&i��;�?����jP�lz<�ϫAAc�m_��i�p���Y
,��,id�:���އÿ��`�`����1�iQ�.���O�A�qjp*8�Y�&�n�m�۹&Ն{Vz�����W�v����\"��B�BAa��,�օ>�p d

c���O�65T�J����W�]�}X�1�
kV6�]�h����\@&�jVi�Ңҧ�bp���['^J�1��t���q��g�B�լ�F�E�ceIc����&
ɰX�{2M����o� �РPPc�컪q]�� �РPtPh�ZR�9���6�����Ճ�R�@//�,��`9�      �   �   x���Ak1���_1?��M�f+�ڋ ^ڣ A�5���dE�ߛ��x���y����Պ:��6��3�6�M��w��1���n`sƜg���0�gDr~�L	�[1�J�FT�t�����D��:��9N�a��)P�]v���+�����8���z�����V`x����2��Gp��4T$��b�!V˜�wbi����d���E͎7M�UH`�      �      x������ � �      �   �  x���ˎ� ���S� ��`|�u9�,�itdH��\��ը�׎&��� ~��;ꂬ�.r'�pB���X����s=́��k��9��}�%���Б��Z���SI7}f)�R��n���6"{&j0pΜ��U<���3/��I��h��n��Z�>�������������׷rڭ�6�r�F�|TA!e�b��"D��+~�D@J �D;�;��x�ϔ��������%�5I�GkLS
�SX!���4�U
�"QY#�	��b��.�Ϭo(D/e�e���#�YU�l�P�G5Y���%]��a����f/u��#�<�<�Eӻ�8D8�p�/Bv��Ϗ�`���g�*gο�.x-�~��H���C>}4n����)��|�ʲ����      �   R   x�3�tK�����,�4�4202�50�52P02�2��22�33��0�����2�.MNN-.&Z�!�[~NN~�Bh�zb���� 4�!      �   E   x�r�70�4 C�?�N##S]3]CC##+SS+N�T�WP�D�q��!��	������ ��      �      x���]o�ή}��W�lN]��Շ�d��$c�~fc�}���a[2+����I��j�oj�g����լ/��"�M���� �^�����ޮ�ߗ����po�M����<.~���{��}�<�]~���߫��q�� �H�+�������qFԛ���i3k�	77Õ�{�����hi�C���������I7������|m��Gi�+������u��q�i� GjD����z��i�_|���0���+��m]�w��|u8��3I>j|���ӕ��J��@�F����t`�;��A�_��Y�s�e�^~���j|����Q*�z8x�ɭM��{�����������m�֛'��a��g��&����Az��n��`����㮿w���v��2���e�=��֛�E�Sg��~��j]tw��s��v|�v͚htb�߄|j�w����˒]�w���k�ѕ�^3���X}?�i:L���	ԍ���r�UF��A&�;�kb�9�]}��-�ݏ�߹f�9�%����v������P&��ڛ��یҥ�o��y��f��#xh�7��q�#���n�7޾������a��ֹ���ױ�~m�>�1f���=z�����[�]i����?4O��ٴ?^Y����9���#`��%���C�f=Ι���F����9������j����|{5����~#���`��t���|Z��֛kY*)��w���a�!������6�>����v|������w�={Z�������w�~~%��ȱ���z�L���q�͍��qH3�E����qE��q�G[Đ�'��L�5�L�m��WO��Gd�h�+�ѦQ��\^oh�Ě��o���P�n���u}��a�9A�Iuk.���q��]�J/k��ܚ��ik7V�P�/x;n�7ٜK*�t5�Z�#2���ͦ�ڦ����$Fw��ql�\�e3C��k�����"�O��`"�ud�!�ܴ�
8S��
{B���ig��X��E}3���5���?��>�W��I_��M���@��O�����ϫZ�|՝GL6�������:PT�����;�
F]����Y�4J������ힷ3�����r�y��t���#���%� 틂�Ǔx��
@��]�:�f	�;�ڋ�̓�^�n�U�Z�Qr�xpU����V#��Ñ~jEGՋU�Q�jq//�!�!jN���Ӯn�O�^X�S���8 �?�+k�i��ԥ��D+j�zDnN��4]k����v�Z�ơF�>��syx�݀���4Fv�G�\���J}"׫Yj\G�~ݿR�Ȁa1����Z�"����1\]��bh{�g�0��+���O��=��dh
ܧ���N�H)Õr�S_�+:!��k�*4��/��8ce��^S�u�j��ʀ�]Z��J������T딯��ϟ�o��éC�/o�5yi������#@��ףqi�q@���@�M߱Dz ��Ǎ?G�,����-�q#�ڻ�/ߎl��FW�O{�l�T��6�����`����d��2-L���Yr�nB��l*2���J�Y�ܸ�u��qGB�(��7������Ye\��ݚ�k.ܑ���� ����� ���7l��}�O��� �m0i>��g��q�aga
p�s�:�M�����m��V�h-Ʊg��i���o��o��0��:(�#1��#��?�{����zP����C����<�9�:�E.��h�2eJk����9�5J��6��:��J@8�B���V��:`�|Z���R���D:>� o_hΩ��Yu�����8���=c�o�TGA
p���H�{�V[�}r�P�=��U]z�Y��U�3+!�[�B U��u��pc��	�9�[=���v~�7�=α&��3z�e	Ňd��,}�z�����X�|���=N�z�Ԭ�)V?;ŢP�ը28�I�;t���g�������7�B�������&z���?߾��A��(���0N	�yu�pq�0�ڸ`�{������ݰ�a{�A��hȿn��[�]�ap�������8]�a�w�W�O�����7�}���^W����0]h�"n�v�H���8��E�,=z��r��=N���>���9�ݰ=�}�v  ����r��q�c�:��踚ܒC���{(��P@��l��q ���*�;g)��D���+~����&�Fy�3B �Q	��9�{8��,�'Qq(Ձ:X��^�Ã?�rZ�Á�둁�0�Cd����LU���q�ښӼ�H�}Le4W8<iy��Q�!@�C�~r�$�a�R�\��x��7�3:&�����1�g��P�߈/���_�Ֆ�Q�/�i�q��Y=��,�ń/�]���n��wr�{�$_ٝ�c#��誇�a���p�1BI�S4���a4�P�O�9�F�ٿ���FJ��p����y��%�FU��K6���<X�W�z(��{ڲ΍�ߑ|5��ݏcꍊ%tￖ͊�)�zS��$�h�,5��	����2_.x:S�&@�Z� ��3�������S�����*�AjSDhE�:�C�]$���D�C�p]�z܎[]8�~���V��)��S��$�����曳�G�Pg0�l"t)a��f�LғXO�Шޱ��9�h��������)-D1��ߙe ��sxT;�/}h�!�%�>#bf���%,#D;m^*��2x��5ow���m��9M;����S^q�@�8Zlt��-6"&� ?�-B��^�˙t#0�E��9�#�؈(��G�x��#�X��G�D'�ۈ��f����/4�I�&���fw�0b
6Y�+sMЗFcq����qe2L����������YIj�Jr.M���)	Cd|��盷$���u�D���+����ݚ8G��Q����]�F0g�L�u���*L�Z��Y4�@�4�P�J��z�$>9�G�~�}�m!�D�����sG-��)cPh����!1��WqO�dc>cH�o��ٕ1�)���?����:�a�:���j��2=�1��YCCFs�����<&�ݬ
��ԉ��_���+��58׉����yG�zEA_�XW[(�"���0�T|���"��W�+��Zg:�`�7Vi�j�.RDĵ����vy�8���FD�Lz`�ֈ��h�z*բ�r���,�$g#�����p��$-�Az�G�� �I4AD���T���qOO�#�<A��e]�����5��s>:���/l754qc���j'�#�wq'"�&jl��+��Т�q<`��K&"�F�����0.V;6����Y�E�Ҿ�Qt����7�u��;Ňp3}ޅ� //�Ch�7���D���7�`�� Cv��BCHs���!�	�E��!L2�F%���J�*�%�	�~����R	���'T��^؟��-�H�>	�k4�.P�F����y2��'$�a��Ip�a�jot�L���y�t�ǆD	���҇}�1b	�d.�e���Ql�~��D
e@_�O�������^I��_�D9�~�OF�*a��$�dW���?k�U���I���9d2�u�$8d�}s|�	��$��	N��ooԀKp���ܐ����v{�Y�e&ĸP=�Iht��L=���8�2!ݝ-�0Kj�٦�uC���L��뽄h�n��_�L|	Y��N�j�=&��x�p3}�Kl���D	6�� ~�>��!�s&��[����/'�I��Pk*�N��q�����c=K"���^6��M0$���b;E��ɧ�6��a�BW�(������`\(�OF�����������+xE�X�����4��Do^��D�»��8@��{�����	Za��c���p�!M�|�ֿ�S'A%Lu
=������Y=x�`�]��P���n���Z&���ٶ�A�D��P!��Bd�Y0l)�#>C�0p���r�dhY�1��	m�P�G��:d�{�e�"���`ץ�#>Cq@��ř�6(�g�;>(2�w    $����gl����w�@}[�"[~�}[��f�����H~`wB3v|�� ՁC�ңz�u�M��Ev�=�;=����'�	�Pۊ��������AzF��Y��&�ˢ��盈��Nַ|1��,B]��	���)����Iܼ�S6��a�潪eW�?�>r.��;�Du�К����/߈�1Cɮ���d�L�&_ƷY�u�g��BG���o�2iz�{�3�7+�+y��
���͝�:�A�ޒ]�%Co�jH
KV�An�����e�n�w��AG��PWr� 蹋3����|gb/�U�<�+���O3��B�����>������[�����[�5���
e�޷��*�P�>�u�0!�;*�8�H�:���(�u����P��PR����t�dS��5�Ů0m���1=۹�S�� Ov���T�/�)-VH�O�L� ���g�yD�,D�6
Bm�G|e�6e��a�ӂ���L��^;��X��r �k
 ʵN��	�O�0�<�@A,-�e|3�����Z̵]� N���a�y����NV�Q ��(�J��^��[6��O�����糨� ��e_��]���n��u�8���{�=���گ����6ُ�l�Iwd�l��e�J���B��z���#��0��.�B4!{+�4!��o�����׮	���r�L?���Q�>�\��4>3�O��_\mI�XY0q~(��ŎSK�@�/���������,��ݵq��3j��� ������c��������y&D�	Q,8f-�l�D/�*`�!�f+�v^�!Q4d���F�NEH)^�?.�"�)���d�5$
	!>���+�h6��&�&]�(�ӡL��맱-L<	�I��j��h��>���fj���a�|8S��2ʽ���������)�iS`���@<��B����r`��|����M/���hG�n7${@��R����&V*0`
2v:)-�M�\�VV���U_+�ת�-��Bo��%����PZ'��ȫPc�����^�I%s�R��Q=���S��U��°;�
j�_���5�=Y�+����{�^U'޸x+{��w��B�K�!qz��������t��3�V��3�߁Mˊ-��[vŖ-Ľ��l�����O�|�b�6�eG׊���&�~��+�h}��9|[�b���(���+v��o���gov�F���.!��HJ����j)�d_?,7�
��
B��P���Th�.���e�]D��|��%/��f@�OTh�����貨�S��]�6T���)u�&�ߢwy��Dt�x\V�����
�\�"��Z��&-X����㞶S����M�Ć��z��2m��{=��UӸe1�:��bz�X� ����_��F5�nK|LzF��]�\�B��c�]T�H����w{�r��&��m_�tfd�쎾�!,��Q��Z���ݲ�4������"��u���MA�y��zS�ie�j�|bAϩ��҂�+v$�ed�(�;u��7��Mr���+�) Da��m���4��Eta�[ܴ+����M���lE�d^!�E����M��+)�`1���ڳ�ոB�UM{b�ԛ
�[��q�P�W��zYQr&-�?�ǅ��7+!`X�;"��B|�E\ �q{��Ö�?@'��y������2��^5@\-x�,�G�;HG�垯� �� �wh���n5@�U�?���d��Û�l�_m�D揫3����k�B�?��:@�\Ez�"���Z�d����t�~#�� ]Z;��c�EpS��#�G�]�v9@�T�(	���6@��>�N����� �rh����8@��zs�~�б1(F��'��VpW�dj�J{�܇x<��'�����fB<HH�����s�o��+�2�$�ї�� �l�0�����t�z6���rg� �����m4�=%�(����g�Y�� G���^����a^*�\�v��q��]�G��&ح-���4�-�2���x�a+BF�{�� mu�KTE`�� �uPe�Ic>@i�'	G!����pz('��kP]�[�k�I��͑�l�$s1hRG*%�/�/�oot0*׽��:�X�#����3���+�Z�� h�2����p ��`���L}�.���`��u���j����\��FkYB��'����T��4սC2�ӂ�s��;����I�O۟K5@2�b�9���qR=��(5��5�.1�{�gO�(՞�y��5]O��5��`�ꧦi�j�N�!G�P"�0o8W�� �����O���7szLDu��"^��s%Q�|;+Ё͒�
�G�~%	����vGkQ"4�ߍػ�r�T��C���������K�⣾����4DX�X� h �b�az�z��,�l�����(q��a� 885^���_P�������^
���HV�s�H�IM+���ʟ)@�sJt���fMH���`v(7����x74ma�L�22���e�/�U@�����cR-���ֈ B�\zT�9;�M���F�u��A�0�C|�Ȇ��yj�v-q~b�q���5�fYiP�b�k��%��#� 퀶Χ�1C�	�7b�'����r�5,����婏a�}�
2��!��T J1h%?Ȗ��F'�m��k��X״4�?{�&|�dl�v���H �#����bC-B���E"k)T&�BEHw2y�OˠQ��<�j�]�_C��!;8[2��=�f=�Ml�n��O��m�5�d��TF�Yß��`-�A�7F#���U	#+q?�!=�)a]NƔ����X���I`n���5q*���!� �IY�f����kD �w��6>CV��?���օR<�E`�@��G|�Ȑ����@�����3��v�r_�ԆH�䑟�9�'�Q���=�}CA��#��ҠЊ�����S/���5q~���qfUA'5���V���"|O�N��ҭ6 �|�lF�ps���fV����h16�+���@x	q��@���d�2�o��W�����+\$m�����/?�g���t�t�\q��ǊZ)_��C�*0\����������,%��Dz��Z/�?����y��.O�\E� b�|�V�;�����5�˨�����t�m��G�˂�x�[�ָ�`Xi<���Kh�y�JS�k�+K�IW��Jׂ��I
���#�/;�Ru�W:͓���R�,&l�������l\n����)`.t��Bo�p�4��������$���%�GyFQ���3/Y�X�ztL�I�,{�rE�`	�'�rtO��ԛ3 ��]�K:XAHB��*��9ϩ h���'H�3�:�@VP��[��9J� VkR אč�5,�'Y� �0���_D!�x��Z���]����8\"��d�,��ϡ�~uXF$�LF�x�Cӡ3%� ����R1�`<�)�x��=	]���qC�2����;��VMT�/j�w�����$%��7E��ct����8���_��t�n�4.�)��ړh%Kcz0���T��U*u�F�=-�����%��B�d�k�vty�fd�ʦ-�6�.��^ײ�S�����7���?��S1���R$Hn��y�#�۵ŭ��Fv e#�U^�,�$�$!�Q	�
�4�����F8@����1��g������P��s��u��gD;���:��3�sZY�?c0��Y:�ģd�y���l�t/sw�h�ףSY�C1@��A���ļ�SF�F�f�~��?���%���u��KT����ާѴ}`]eE�L��×��̍ް��;S����+Qd�Z5"�B�k���iQ����w�ڲ���O���7޴��t��<
��y�&i*��맵�1���=U���-�,�0��Ψ��K��3��T<�"��u~�mT�j��Pߠ��m��}������Z=�m����۽����6Ϛ!W��FF8^��~w�E&�����N��K`���+�Pb�JCFzhq�lL�$�~�c5��L�-��B��:FVpP�֝    �-�QF�rs)-�*����::zx��=�$�1���0Ɣ�z<�C��]�����g�&�Pn�(Q9@�TJ��HUQ����p�n�nd���,sd\��o[v�Ĩrzڎ��=<��&�3�W�{8u�Y�w�7�OuW�A��C���ʩ<1.z��=�W��fUtT�ʯ�ˀB�"�����Gc0�W���O_vRϝ�C50�絓��#9)��q����C��-��{��}S�/�� q�t`�Hջ��6BF���P�{��Ay��Ƞ/����C_�M!}���߮6�1ev g%H��׆�@?K��?���������J��j�W%ˈ �v�k�̍��3�:)C���1"��x��!���k3�;v��g�� ���,�V�
ﴈ4��YU+pVӌF�+nf_A��k���e��V�Lb4��u�7B� �fF���+n�<>�}n��������Qy�z���i�W�a��kE����G�4Cs������K7&��mw2.G%��Eh��^���^�7�َ����=�>B��*N˫Et ���v��[mXQ���Q:�����I`�j铍�]yި$d-B���RZՏ�>�P~䝕�2
����Te�{ɰ����!���E�\.���Wʈ b|���aM�	���ѷQ2�?=/K���{t�^�o��:����}�P��#'����N4��`-R���=����l�����zLF�$C_��g�����x�ZB���xۮ_%��o�	}��8�2��A��qO�="��Zy"�Y��M̭l���6L>v�R�p3�K;�2M��mb嗦��^1��l�I��]n=P ���n�yĸ���ۿR0c\y&m�I���F}���l�=�xR#�Z+�ĺ8cPeOI�L�_�4$����w�{G�F)q������Q�W�m=�&aY-Y��0M|�䏎��xl�j !���R���M="��$�&���V�;a�{ť� ��|��-RW݁�͇�?�����v�[�U�V�+��v[0���#� �E�����W ��*S0�J�`#R^�u1t��qȱ+��s����g�t�*��H39HFh[g��r u���ok`�p�<���dф������R�b7~.푊�R;�C�YI�6�*�L����v���[#���{�JV�;l��qq�8{����8U�_�8b:T�2���a��N�}�yC"�!VIlg���a�|U�û O��g�ׄx��Wk@��c��g�y@g�8���R+��^C��~qQc5�c��KF2�6(�����f�8`��m��A^���%�~���L�����'@+G^�S'_��D��G]�����*Iv�s4�u�X����.I��r�.GN��d.j������E@��0��D�����]���%龌�礜6�0���;X�&���	��B�D�N{|�ĉ����㫵��8��	J"|Z�i��%x�� �b�ԄO��d!4���� ʜ�j�@���`����r�En2X�y�������:�#��=���m��[C� 0ςM�`<9�g�4AZI쑟��a�H��P�v��̠h����l	r��1׬��A���z����e>a#H�;��uj���ۺ	��Woʈ ���Yj	�[��圔$Xn�d�܋���Pl8-!e��Q9��K�m¢,T�]�`Wh%��/����<)��R��KW���ٽ���}Y�e��>�K���2b.��=>�{|��5�X��zF����iT�+WgT��\����d	��g�b�PƖn-w�G����=r9h2��7��3�2�r�>��$t��J���%�g��J*��9G
�I^���#ih"��ZE��Ɣ��d� ��0��]�}o� _��n������f�Vl��I�Ø2���à����|�8�(�Qu-Ӹ44Y��Z�I�C�6��	����A�':f�h�t/���P���VF�(?C��8e7�E��zPw���/�B��$b�(��\Ja�q&c���GmG3��z#�_i�8���v�'�q03Q����ye�� Z�͇_�h8C������c:J��.x~2�<]���:��0.����'�Xy��d(���Wt���-?�D���K�O�L��&�"�YJi0���:�+�gT�Ӆ��ڪW'̈ ´�E��:@�&���4��\�t�H��t�ق��9dK�l8kcB�6�/�	}�('�=Co5�ΰ�z���)3ⳬ�DO�:eƈ�|	V���L4a�q�q�T�'V�������!���p4��jQ��j�!����U3fK�W�2!�<��г��hF�P�˟�-P>�
����ˆ�w�ggh�Z،�[����U�H��ǽ�e���f���tٚ�
�z>�w�K);^�¸�GI��He8��{?:é�ۍfO��Tl\%��3�v�r���p�n6e������p�� �z��G��F���p�Ǳ�[���=H�z�� ������ �w,�#�<�J������{���:d������c�/un��KSy��2G�f����Dk�нx�}#%���C��HR�G/�����@hN���+0���[e,gZ"�O/$OD��/�sZCQ`;�zt˺�����M9\�R��l�wx��?R��~� gi\
�F��ć����~�s��8+0Ki�}�<���TWmTk��[`;N���b�
��Ң�F�;/��p�Q
�Hk�/��b^�1#3���R`�	v/>q�e=��yON
����#��P`�\v�Ev��Ke�� 1�	�+"���I�|I�GJt ��^�R�-0���?YXvol)0�ԛ���#$�6ir���d���R�A�8L�b�o�Y�
lan��~+0O��cF�d�{�Z`��YF�?���3��-c�~TF^خQ`�h��Kv^��"����hv��m��r;��`)�����Qw)WO�\��xe�� ���55*6�n�,��\�D��u�$��� q���l��2ٮ]��X�%Fq9 +v����ƲԣQ��+Sc+ܲS�-zQ��)[uW�|����ا��YF_�Y��:�Mø�:t�TŦb���c��W�ʈ 3�d2Vl�E���b�Pf�Bo�V���Ѩ N͊]�Z��튈������*.�I�]|���#�-��oV�g��A�*��V��	 ��11N SA�Mj��a��vu�L�%�b��-i�d����mwd�X���8
H,KŚ\g��TO�d9%H��wŪ,�z�hdE��ǫ�dD !q�Ѿb�Ȑ�����o�A��;��p�x���H��?�y�[�ۻ�p�
�W�Ȉ �w�±"X˚˂`+�*�}�@��2i�q�=w`����ڢ���¹"�}f V�W�I�XX�KkE\d�\?^�F�W�+[dD ��Z����A�ި8�#Jk�O�Zr8�>�c�ibTjM��K��'�,��^/�p�TיR�L�v�n��p)V�Rgr��3o�;ez u�U8R�j��R�G�-{ȧ_ԷWq���!+.C��Gf�W܅�s��,�w!��~��$(w0!{�`N�L�2 h���� ث]eD �1$�B��t�)��9@J3�IH�y��g�l�Ѐ��/�5,(���(�����.=@�mU�x<� X_��^�.�'k�H��lh��ɱ��� �v��~z%GF�[�,�!�5�hY�e�g�� ��B�� ��~]�u�gW����rr8�^��a����:�WOˈ�u�e�j�{�ob[*�q���M�ō��~��������2�����u�©��t��T��uw����|���(��^g�G�$"�=[�*�q�kMr�5�T|��{v�;�34��sx�g�N��5�
�Q2��<e����V�k�� Z�vj��S�����x��)V���"`��,�:^(�!wq��	��X�O<"`��Ȟv���It8}�p�P���9�J�`뛌��V��r��ˆsF�)8�f&��6�� �J�/�G� b�Y5=���#ߓ2�O/�}!~��x�F��p�    ��`��n���~�qW ��f�9�`��q{�H���qi��q,H���]������/�� �l8����T ���Y�� TY��*k��u(����{����̚�Ǵ�Y�Q�d9�Q��s�u@�I�P(�e"3�ȍ^�zpS����\��:wۥ�T�Sĳ�2\�[��C.#t���c�o��*���z ӑ��{X���(]���ƺ�M���w���>^���{�uun���@,:겟g�>����!T�2z��zw�??��!�h�Oh��우���r�@��	W5:UM��_r�q�PW���P�ˈ�/;��2Яx�
]���؛�	�J0,�.��� ��Z���� 3;b	�*3h�D'���cN܎���iz5a��ϡu�8�My`7��l]�S�qu"Ig��ޑ��=����w�%B#�ԗ�L�R�M��끵�K
E@6���7rmZ��׳6&�Y��e�
-���S�ژ�>��l@Y����(��oԿPN�[�o���������:D�]ԆS�{�j�)�g j�ٷ�"��
���[@�7#X3:|�Dۿ8*�g�қ��P���r�v�a�h,�Z�R�_�* �h,\�a�J�m$��[p+�US~u����q�X���_�@5��7R����T(3��%�K�Ch�5���i7k"�9�n+ׁ���aO�g(�Om�9���a!vO�@Q8%.���gRfi�T�;=k���<(�`��x��l�G���>���p
b��趀�p�&Ґ܀�p�{Wr��~��)�(7=����+��쀢p
�a�?�Cwz��#
�	w�.ާ	��S�P�M	/X@A7{����s)$��N�C�	�tV����*�T}+��ń����?j���ǟ�m��v�*��r�\�(S�2Ee���z9�����D
���C(:q�`���D��v����D�to��4�Bz��l�����7;�B��Jt���g��a����7��v�6;�IP � z.���Q-�-ә;l���2�e��2z谵v�r0N�S*t�4;w��`3wz�N�sׂr����h�`�jN��΋�vq!h C�[�q��pܧ��+q��{�0�w��J\9��U��N��-�o6�"���M;증���=��(�q�5*۫IG�E��K�����Y��=��:�]��Ј芦 P{��f�i����ړ�	�����S�e�Y�;lP]���i��GӘ� ���a��l�\��՞uXKl���?l�gH�3u;���)�+��\nV7�N��J�!���-t0�۟8S!CB�4o��[�`w�E2n����8�mM�0c�fTu�����2��6�,~^l}zhP�$��LJ�(�LP�DvW1�/Q�
v�4��j	��z%L��;��Y�s:�Li�e�'N��"�B~:��G��5J����_���;�&D���|oG����h	(Ѣ�Jw���(΢M�P�E�ϣ��"Y�J�(�2��������ر��,�y��,�oaZ;n���ʢ`K6�ݑ�N%�X�V�3�P�%��[ʷ(���P�E��(�mQF�>�ݏ�-���lQh�\{v��(�ʚdeE�{��Y|�9��,�-�P�E�{�I�����:����Ui��(&���DkG1�4=/]"�5>i�I=���]�����~�X�8}'�k'�9�VLpk�ԊQ�vM(ԊQFO@oق� ��d�#����,���=���zbAJ�F�8\�)A�IR�9}� ��~����Mp��Qb�~�Q}f�!RI�|h���z7
Z��Ӭ8����o���g�5��9.C�r2�~VS:��Dp�O�P�%�V�������=�VTP��j�fyw2��E@$���-�\��\n�b��˹N|H��+��e�Y�89�$�*A�D@%�`�4&�ʸ��:�q+�C�
J��}�jC1�� Y�G  MOg���k׾�R T�Ʀ���zH���Q�A	S���{��^)-��u�c��M��r�Cie�>�(��C@5�LZ=:i�0j9��Ch%�f�����PA������Ŏ�P&AA�y"J3�%9����LP�<����	a�� +]�"[����7��k@��"�~�9��L�"�Rx�~���q6�B1%[�͸Yz-H�JOm@Q%${aB&�@ǉ���ݦD@�lL��2��`�S�F���w����B��*(vg!�5���������R�{�Y�L�F�[��u�n�o�
�1}{�AS%-S���/~9��I`ȩ��}��zY�N
�r�%@����>�<?3��S���5��ev�``8�p������'�} B�k� �t`D������'�<_N�"�[M�B�	�%`�%ˬ�h�y|]7"���������5�~�	����U�����,�C�����	 _!��'�5/dd`(aa?5�a���
��˨��;Ė����K������үhT�S_�����	��(�#�IdD q��mqoD�1K�i�uãXv�&�1��� ��/˺zFeP<�ИҞ�S�hn����
��ì� ��ǘ�ܴ�__ �����h��"�Q	���9Z �b�%��!�|��M�ً;6��+�����&�
9�;�F���+Q����W޿�Cr�z`��Q����nS!��a�LV����bd9�.�<W���M�q�\�<���>:��?�B0@�����m8^[�:P�Mķ@՝=0\YԳBS0��_�m!#�O�N���b� #Kk�ڲ�����,��%��+���'T��7�¥q;����]O�)՟QlCՠh�Ԕ㪃F����c���HCA�JRy��2�FJ��oN[\3mu���=q���-l���2y� P郫���!�[A����q��R�ZZ�*��4.�{�W����"�0F�������QH�Ҟ�83��~a.\���A˜��K�95y�2n5�9j�G�k��#�kU|�'ֆu�4Ќ�l�`aH��lT��j}zx?���hH�n/�COu��"r�'�*#/�̈ �~} *���a�����c�eY\��$�"sׂ��{;4u�q	�����Ϡԝ�/0� R�o������֯\��姧��a��v76�Mb�4O7S�,�s���mq�b�$X�u��������"��(��Jg���	ġ;4o2vpt�0�p/���{Y���=0�ⱃM�bk���F��2ZѠ<}�ܶ����gg,S�qC�D[S1/��J�0'?k��g��&:��mL�~�8��徹	�~-��W���ո&��V
�r=Ɖ�����������t�.���4����ZcL�^u���������ܽ����LRQ�߷���3� � �������@L>il��݂%I��*�s=��r3���y�~�����g�3�7'��sΕ`���e�d�h�=�N�N�N�f��ٝ ?�%�������P���w��oG��v���8��w�� ��Y�tF���4�x�&쎉;+:����C#�i��;;Fv %Dn�FZ��D;��GfH:#h{yCƨ4�u�yb�!C�y���L�����`�.4��oZh�l��Ma�jM���������Ed�-?�9���O�.�I*Q����!��t�!-��N��;�7��D)iQ�+���s�����y����*��'|]&�6�o��*��7��rԉ�ܞ�l������Y��J���`Ϫ�#DC����ޕQ(46W�G���sJ�A����[���\��v�'��'٩�O���]_��
��`Z�b>�+:�^\�*:���Ե��3٩��weE�W	S�ñ������1R��'��#5ܜQ=��Tc�w���n���X�<c:0f�l�F� �(�yF���Vuhը��ߖ7���j^n�9���6kD �q�Z��o�=�3��=4v��u�*'l�����Cm�BZ� �v�_�'D|(���?��d�_Z&=�e�}܌*뚘^=e� ]�-����;��셗@��&��e\n�    H�g#�s�+�P�{���>6Ai����\�{(�^ܧ��6�s�-����A�mdi{+�f\G����N(%��yۼIoj���[��jA�O�{S�Sh�����媇�7u�j3=Q���*4ћ_�8@{(��*I��>�`�x�^mO	48���"�WpF?�`�H���s6�C�J�hy�R{!͡bLnO�Nט�!R.݄�BF�j�C5bܠ�T��Ш�<m��F�;��������I`����q%��ZT���HgO�h�{JnX�w�o�TM�� �y�=\����V4@����h� �9fS���^Oy�/��ԞF�� �m,��������yy9ް
�_�0f8=����C�iy~q�w ��27�����2���������q��8;��|��aad��7�.��5��/�82@D�f΋�=G�oHn�N��߲�ƽ�&7�����ݒ�82~'�e�XB��j�cy�S� ��	fD���Wr�N˘�1���l���F��ƥ�G�{�O�?����}�n��<=R�<>��Մ��y!.΄3�ŗߒ}1�XJ���`,�vl!����sv�ml�X�rH0���Gb����~ǑRC��%�}WY��gU�z_5����Q�GGy����`'�	��������`Z�~lY�e�]�nZ��n\7��n_��{tL�_���G����Q�-N|�I5�w4��d� ��0}�?;_Z����4�s8��p�9��I���Dt�	�MDߝ8v:�`���0���n�R0Й~���������9dws���h
�,�˅6ccPR-B6O2v��'J�N�O7�i([�����,`H��f�e,��B����{@�qr�2 aw���p3}���a�	^O#��������j�UY��M�&�/�����M��--�[ZƖ&��t��ʄ��Eb������LH��ŘFn�J�(���gw��X��i���ٌu^���@yק������S*;j�d,�y������0W����b5�?.c�?g�'-c��:���f�k.������	ckh���I���I�2�Ć1~/�2܁^mx#���i������x%�xN.��g�D~\�45*�{�a���܌SnݤV����hPD�[b�BF�Þ��P,�0�����9/3��Y����uS��ú%�ꌮ�l@�,��2�X��H�g�Z��bf˚��~L��ٞ�s���ڑ���@\�l2�xs���y���M���W�y�˚M�K���M�{�f�E��9˗�
�{��o�����{�G���]<*$^�d_��0��%��
��Y>9|����p�	q/�*I��:P�����>�<�31�|�oz���asd�g� ����{�������k�����}Џ�qli\O�cOA���z�?��ca�%\KB�quf8�@>��w^v�y6�!�Y��@��������)��ݖ�N3�{�ږy	�I`N5bMg���0'�;�͗���z��h̸��ݫW1�ty���g��Jm���'U!pC8' ?��"��'�F֫
/N{rk��R�%Ǩ2=�7�aϰ�s�Aܐ����B�N�%z��y5l��m��_�/��X#�ބ0�L0G�k��##��u�ڈ�ݑ%�99�	�'�?%ņ)^Bp-� !D����*��Q|xdk{���:�2C�q"�BH��� ��
U�BĀ�,����w��Q��u&��j8�~T9"��_Ӂ��(�0o+lX���P~�!\C*��
S�-��0�©`��0Ê
H��:,K>�}��3�Z��f�~ ��(H���a�F�iV�9w��'I�3�-���W��+��!��������ę�_��[��(p��)�9�f��8N����f8��_0����������V�2!VX¾X.�_;�+�޵�����������䶉�q�>v���������=��������C�����c���r�P�K�n����l\w��s�G��|<��^�DD��_�@R�X�_xy^�ޛ˂�C�G��W���������p� ��#��Sw
�B ʈ��.�H�
���i�f��bzJ�O�����,]G���Q2\v��x,
���,ݨ":��G�W�ܱ�u��c�%x�;�����ґ�\��za�Fy�J >o��ɖ^�-vJ��n*p��A�T�'-����OZ,�Qs�_�R{�y�!�lC���
����Hy�]\�3T��DG,𗖛��3� �B���r��t�Џ�r���4�ԝb=�C�vX���e�5�;DzN����ڕ�e�[;�H�G��rS�u����妠C��n���Pk�����fp�)��:Y��{H��>����=��GJ�"�sa��pC�;��Ф~wԥ�K
��>�Ug+�*p�]\�.�������T��9ΧlE���|;����k1���h)�������_�V�Gl/��:�` ��D3�=�w��[;j�
6tޜ���~p"!�!�qFt������� v�j-�����д�O���8��⺃��E���N��W��r�x��f�a���h����4���e`�5�v���-p���$Kr������?���^�ӥ �_���vo�8��`����Y�3� ���?�����\F.ȥ�u�#t�C�A=|�jN�h�3x��驰�M����d�i/4$-a����:�*BB�p_�蘮��g�$����͚��
G��[��p��>;3�v�8��+@K�j����r*\9upJ�x�g��]ḙslNW�k�qlc�pӼ{1��Txg�Aꔩpʜ��S�9g�:X�Y�Χ��3��0W��9�����0W��9C��
���0W��V���o��z�M��T�v�7SmYꉯp;�)��fC��7�S��b��4UM��	a��"+at���*��7'�m�Y<zJc�5��p���[�+L��}�o�7�I	���t X>����*|LU��Z�GbxV���ÅQ"�׭wE���tF;YW*�MB�F�%:-�-ɠ1*�.�=+<O��?#�V�2���G����Dtnl����'�x�M���nH�Q��U��Z���Wx��������;ޮw�7������ 48MM�m��5 OO�-���-`m$_D+P����m�@XO��y�*<lUS�HFe~t_�\�p�Q��?"�X�ᯔ�<�'��*�3vޖ���}�ҕ)�.丮�U$�bCk�7+�f��Z��;�rh��&*.L�#�����9�@oNV��럫��U���L��k��`L0)���pב?pְ�Q�.i_xpz����>��+\{�8w����0V�B�
�{�2!�ќ+^�Es��s�͹B���4�
��Ӝ+\�7�s����Bs�w�_h�3��o4�n�`�9�p�I��\�y?��s�]�5gT��
�=*���O��.�\��O�3�H�x)�����"i|ʉ.�?7�ϕ������[(+ڟʊ�+I(,j�WT��� J�n��+:=��Y��»��bG����4���J��I���Zi�V+�Q��G�җq����=�a��r���Z�ti�J��IJ:T.�1,�UK��{��MQ�����B}����C��a�(]ڣ����I'wX�$�߱x,AB�9�c�SGH�N��\��#T��Zf�Q����Uz
�4�_�*�R�.p���œ��V(��'�
��4�z�[ǘW"��Cw,��iB*�c��'>br�1`[�U�$ ���W�6K]���/)�,��qz��(����@\�J.5�`+�(��ϣ�eQ0�n�����S+��FC7m�0~�Wb.(Ӻ�D�HjE��$�Qy�BrT)���Ղ��{��g8�wn�q�̧�����e��C�q��3S�����.y�H���TfJ|0�ky�(�"�?�6I@
3{���Z��}T���1����%Xa^H�f[H��Dh���TC�]���>H,D@����f,�U@ڳư:���iy����U�ZB�ʺƈfA����k�E��霰:$Yh���޸���O��P    ��\��#=�K�$��B +�K���NiF2)>hX���g�����AF�d\ϦHnoe%
��z3��_WP����{��gל�
*������f͍je�ev��	�V���{�7�֮Y)nc
��~�4XdC{��!�A�Qr�̀p3L!!+zʱ� ��wY�ܰ�=�xa���z�Z���m3s�E���P�1��3��+z�}���"����"�b�����(�l���&��jh�o�q�S�[�|ǭ��Soi4[�kh���NhI>E�ZGhMf7�KѼ@��Gɲ �A]C]�\{�a8�.G�0#��x����-��̈��^sN0���*�l�0!/yb@R��&eHʦ�DiЄ�	ق�[�1�)�»�e_��b�;�QͯF�tB7c�I��s��oL��K�J�	D��dl3��"�em���	R"����a�5�K%7,%X��*����Y~f�d�\hV&�q�
*����n)�!A���}��@~M��/\ڡI��G0�[��+U"��?����I�0����*�[$�f�s��D����'��R�L>!�=ۨ�E�_�E��9ɪ�Y�L̮s#���zt�с�ł�Q�,��f�(�6�hl�"�e ^��;�ѱ<�&�;�J��V��wN�R��h������u�~�2�9��.�*@<X�6�:X�r�t;.j[�	0��q�b�"�=���T$���vd��K�\���p�C\���G���WVx 0U`�r���m��w#W� B��Xt�R(���$��G��1��Z*�~��=���ֵ���\n_��Ӥ��~��{!��wMb�m��f��'r�^�0I�U�Q"�?�SuRh]����5�&}��LK!λ|�~�2w�ȥ���t�Gh��ഽ����I\+�7��>B��p�^~��"�+���4��a�H4��i�z�L�����.[���R�9��#*�{PqP-e���ڹ
w3�����xJ_H�F,?VEr��S�"΄@=:"΄sN"Nˢ���Yy#Nˢ 휺S���U��-!�p%��+�+B�Iq�"��lˊ�@�eD&Aā�>�%�W"��8=�1���>��0ފͶ�y��}d����)�}Pl���Qvo4���"\��)Ϧ@@�>~�1�
�� S4E�.���]1U p���uԚ{O����/��G��#G�#��r	�p#Gk3�����2�uN{2ːY��@^l��O4-|�����F�%�r�7q$E8}������2��R=(���Ȝq~^�4T�ujE�=�g��3Z%����|�b��1�P#�����L�T��p���?ɇhyVx�V����S1�q5�3�4��[��%�o�q�����"�n��ƣUi뀵��������o@飼���E���ǭ�$�=�2 =}`�۔*��e�g�n��7 %Z�:c�z!G~7sȱ��娛q���L��\?|#~��et]�.K!V?�k��f���8UvX��T(����1�J�Q����<�x���ᵜ���V�=Å��m
�����/���Ǉ@Y�����A$p�=ǝ%L<1_~���x#|����F�p��@�C�ؼ�^�D�7����Y��=���Tx3��͌�f
Arp��~����e��ߑ ���0����"��� �B@�w��NE!���}24�y�|��8l#���9cZ�끋Z|��=�O�q(�#������b=����P�C�Ԇ�2�--PZF	�us��#G;�����y�_�X�
13�,}QJo{SOJ���e���/��jړgu��L��Cv��E�%d{���	V@�w$U@���Gґ��#��a����'��#!MAs��G���.j�Xˤ�ԃr#�A�>�J��Ø�FL�G�E}���	�/bđ�r	�,�H�v�~y���3q�hH� �Q�r&�vƎ�Q\Dі۔I"�g�����Z&�ó���d���2�`��>	r~�`�#� ��`��U4(?�TO�-$�`j'��N0���es�G/$X��Q>�2�tN��;���ݞ������Y�d�;r/}���ʉ���]k��<c;��1�\�H��c
���1�;n50t��� ��!��i�v�d��4��Npe$ו�����j1�H�/�DQ+>��!�G�1A�fJ��ەf��H�F�ؘn��*���S0H�lC����g*/�6/�%�A�\M��&���,.!�KӸ��t������!�����zN��D:�H�r����s���������z�J���A�η)3�);0�k�'��U�O�z?�
��il�F�F}��z����K �o�p��`�'s8������+�P�}F���B�2��jG�nf�����)	����o�`{�Ĳ�Vi����V��iz���?֯�5Je���j��*X9�
����_k�ݏGt��R!�\	����c�H�#�r�xc�{?�6v�ٌ�ּ�����5pF6-Y:�;Ly�����~|ݲ+	����-3	��Hrń�a�wWw2�X�w����A%iU��`.D�&�N	��_� ���H�Y$�"	�
�>OEBb-���3%�<	`E�IkBē@27<m����� �_�g$�3�Z�{d��`�n'�DP5c\숣1�-�Z������r;�g-7"�hWIYȜ��D����EJ
ۃ�;�r�y���Ep����<j1,�W?U�� ���� ���� b4�vR\�p>��M�a�+:�D�&���ϋ�A#'�.>� $�p�cӁ���N�z4�7k��ۅ�dXF�* �a&鴗�;4�ǧ�)�m@���偂}{�fy�׈�ӷ�Y��"�L���~�����$9���Uڃ����w�݈������f��C���܅bD Ѭ��e;�-�����ͺ�NIm{�3�oR�B�n����YbD 1��[vШbn�i?e|@����^hD1)��۔�oc��\�qܰ7"�P�9�5�k�(�K�ޠ���D�-�&Ǘ��������Ͽ�ySp$%�q�aej��qq�"?UH���Fv�l�$�Z�w��fd�\i3 �@�kdh`j���=�*$V��� n�@��ƚ�p ��Ql����g.�f%�9�@����X�m^�2 M!�Zj�F����xyø
�x�d1A:>#�;�0=�O逴��$����,OןگA���-L"�Rk7��L-���z�s�lD 1��G�� ���"�6@]ԋ<;�Θ����ЈPmz窼ݍ5��%\]mIp��P�#&�S�z`��\U��2 �����禙q鬝�k9�_n`_��ca���<��,���d�`��@���iq�jP?�h�q�:�E�2� ��i��3,�_��}���tݘ=�Y����=-�i� ��!l�u��f���l�F%��<���E Ĕ+�\B;X�I%n�uO���;X�<����2'��K�����A��N�f�O�`f;�8�����E�_�}���)��:���U�;���.z����K���)�]�����􊝱�h\�w�C�(-�G��릗�̈ ²R�)�c�<Qb>3��X5�t������:� ;�a�=���.$=3�LĬZN*Kf�0���Xg��_F���;Q�M�_7��~Z_�N��fJ��V�]��O@f��~C�Y�}�e�n�=�5/����o�x��_^$���Ƿ���cI���l;#��z,l����l쥃V�L��޲�cY�>�unLwb��2��'�ԈF�<�7&�޴<0&�g�!�q�=��2����|�Xu���D�:�f��.M��E'6�%z�Q�1��*6"&�w'Ɉ �#Y�#f�^"�V\����H�=��"�n��x˻��$ �z�z������9g���ld7���W����oR��Q"��Pp�K�e���^-K�o�����_̓1���LF�קb�� [L�
#�p�f�ڕ�.O��C��r_��=.\2�o���ѳ\�#�Ḓ�rē�q�-%#g���!l�<_��/Z�γ\a��_�4Tz/��8^#\~�^h'g    #Oez�r�B?6C,Y4��LӍ�Wʀ�NH�sF8�h��2�ف�ǒ�S��</[����Yv���$�32���eޓ�2����:�"�k��Ĝ+�3�.����t��(e��eh�g��9F�����n��ߐtz�)e�00��١ݎvD������M��ˌ���6"�h���Ǒ��m���A�vQ����߈�����~��Q��0�N<��J�4���РTi␃��H0�Ac�$��RCk�sGVM��M��o�';����E�Gw�M�����$�4BL�d�Z���&��"'7���&h9I9�}\�-�1�6A��~7Z��ű<5mk�wːJ#H�[�uΛ�A�u�<t	^�w��ϲ��B둇eܹ�C,ڛvDh�� �ʛ4E1(�j���ԧ{lq�?w��6A���@\J�jdRqE�bn��R@]>���B���	?O�WT�MP&���aT2>�r�Fy��$ʩ*��z����d�1���p�P���vm�X)���Vc[�O7��H�$Ml�G�,�e�x	1~<<AO�n\D�����˛���_����])b<Y��������{64��h��1��7x���ˈ�m��sdB%H�3L%�����$Xg�X��{�(as`'�	�D���j��{&�z����%Df@9����n�������$in���b����s~�H�0s�$X&oC�͹�Pij�\�}�Q�t��ٳK�мZ�T �h\G�e��i0"�X��?0Q�r�}�߈͓�,	�r�!�=��P4$q�#�4�9�rc������!�4�ɮ)�1$W�@��BĞ5�`�%MS�Ӌ�ԂO0�R`��A���`�s.���l�"�V�
��,��
��s�S+i�C�I{�m6!+D_/̎��O��}�4���R�b�35t��\�u@�{�n���4"�_��� �w��6�Ӈ��|�T�ɛZ�ho����q��U�[�P���6������h��M���7]h��dne(��B��Is���6����A �L����B:�m�o�s1�ݪ1"���M�6#��N=��3��U$�����!hF�9�N��I���T���zd������u�,f�<�,�������1n���N�@����А�nM��2�Y]X�Ī!;L�c!����B6��wB�A�")�L��=g�b�H�,�b{�~��#i2�	努��Zݞ/ˤ��`j�������ino���R��`5�g�Dh�I��H&{vM��=[��2u�!]CN�l�gX�Y�S+����k]8��a��~6E�P��Y}�\�1� �[@l���D�u�� �N�>4���I���a�g���D���9��s��,�t��p�u�,�7)�'A�9,�#�sZ�a��P��28��,�eTib�RL;�hD�$(MZN�a������P&4���E	fZVT3p�S%7ʵn�8��к���$�����ӧ�6�T���̴>�$����2��u?d���c<k��@]Z���~ Lr#q��1~��~��Nc��4��-��&`T��`���p?跺�6nP8��.��dx��y��<�霓�f4��M���F^����	~��ħI�H�Յ��f�� ���*�f�i޸
p��}�/.�����?�y�v�����2�q��uvf���vBJ���Hƥ�<��ϐD��+z%$�%���.��|bm�pO�"j�4��������K�$��׺�a	M�����.��!��l��ы�T���qˊ��'\E�ױ���4���j�B�1�v%p� ��OX���I0U�W�g/ *σ��A�-��^��X7�>ӽr��4I%I oL3ϊ���fxޱ��)ß�����yw�M��IƤ�Z��<�!�6Ζ5��~K�q�g��ee$�9�F���Pt���p�$[� q�gA����^/ɸ^"�%֥�wK�ܓ�kz�4�I�;&ot���l�Z�Z[�1.�q4\0��HOas�U-_+J9qD�`Ay~�FA�`��%{$ɔ����`�q�r�X{�8J��v�9�D�� π���� �
�k�9�; )�QC����y���2����Ǖ��*����û�@�J�#�3��]i��Q��J�� �����^����԰n�$�����H�Ļ����葚:�%V�B����wۍ#Gڵ��.t֧�$��G���[�=��e��m�KЦY���ψx��U�Fy0@wc�QnH&���©[aD�ě���q��"�2��u!�"������ךL�ɔ
�a�8\�������U�{,N���#�l��{�|��b9|�:���)�aD ���F���U$�!�2�XF�>̍~xsf#G��}��K��%L	�(�`�Q�p���t������FZ+j0��sq��F袦`q4��
],�=S��Y���_LO-0<�e6iWe�%5�QS`��6l�%T`�.j 4WK�)���Ay۫a�J�����x������\�e����˶4���]��^���j~�}�X ���T�'�D����L���t;��)0u#6JO�)�u㝾m�e������s���&.�7���-�5���?�lU`i.(�Vz�0���V�**U`i.�>�U�K���8?���T`p.ˠ4���7���Oj��N��|�z�Č�Eަ�Sl�S*�%�eQX`�.����P-ĭ��ڨ��� ȸNv��Z��=}�B�՗hSQ����S`�><�kX���r�O_�9V`��w���KQc�枰
�\y�����,���*]�ŒB8�.��Q`�.�������f���A�Ŀ����v\\�q������$hRX���������qѼ�,�sj�J�a�W`>��;��#o]HڰL�V8�ʈEb�o7wߦ���� JP������B�iYb���X���xS`cF.��ƥӻ:rG���^����6.����ĳP`h���uv��Y���ܒ�:�6���C�	)���^CM�?aS��<'T^/�`��p������>�M�B���eS�P
ڕy�A�2Y����`��9���5?��c�`��Ûa���$7��
�Җ�&�̈́��E�8Bi4ȇ�="5�ы�bҍ��+6r��o�	ҕz+&ٳ�Xȅy��]��?>��%�cX`!P�����[1��ֻc-��+�N ��R`%/fx�IVr������
�'bUL�4xl8F�3���h��(�Fw���hI���^]˹��0��o�n����K�+����O����b΀�Gf��P���&W�ɵ��ֶ��*���p���B_��9mFd=T��3�s�*f��E�8T�y�� Uhɵ��\�<���K�BE���8zϰ!ë�G��B���N]�S������'0c�'�U�R-�Ip7�l�W�ӵ���q���P��f6�RU�B��w�m���
�Z�(��k�T>V�5��Z:&܍�a�_�A}2ԇþ�A;����#����+t�j�EZ؇�{*T��3����Bᯪ��`�
m���*�}!L8v'�-���P��H�a>
�?�!���hz�s��\M��az�nZT�P��`�Ĵ]�B׮�;�c*�����}��D�U��U�����\�Л�H��
����-��Y�.�9��u�������"踠S��VWy�P^�渗�W��GL���_��1?�h�5t��h1�kE1("�V(��4���jìP\����(W(�uV���6c�<��B�s@��K
��7k��\;r��)$�j�ʾ���C��-+�P�r֥r��Mi���Cj	��P�N^穣�V(e�U�*���J�5���ye*T3�����.ˁ@ϴO�*�E*��P�jo��٬,�2IJƠQ���OţY+0��R�Wuc�*����5Iw��q e�&%��)guS1��h��P1���+~����=�bj�H7O����_�Y��B�TLn��)�=�o�ax<��B{�Z)�qLV�N����*ԧx�KV(PB��M��?���9�P�����U�:��1    ���`�`D �3өnd�d���]w�04��jaXv�O��#P�(�V��a��v#HSZ^��y���$�u�$�j�b4�J}2��u����/.v[ǳg5��z���x4^T�10��':��������_�)����n�b`�AkHH��sȳ��i�١�Ұ9]��;g��>��/���ʕeL�.i�@��Z�_�$@X�m~�9���e���^�r��0?��5�B�"=��M���:;XY��6��w��qagT���oa��S��~�X��Z�3��b#�Ïa�����1�'��؀F�b4%����$#�)����(�S/�뎘�e��zW(�����"a�z�up��}B�C-���	�ڷVp�xzs�s68���t��1�Y2W,�P����9�� �\	,WӸܼ�oW^v��BV�J�m�\���v��k���Bň�͸�f���OР�4aQ���9�VhB��5�Ǆř�� �FL
�@X���G����^�шx��/�.\I�F&��?&t"kи�ܧ��<b2&���?W�O.����m~#F|\��D�6�-�����as���v��wt�B���ⵖ�Yג3|��w��Q}.�j3�02��@@�c���@G��XܗlD��g,��� �.f�40����U��Q�?��ܻ�-�����+f,��+�ݯ�&�s؜^�j��dd��9���N�\Έ����g�"*Y�U��`�p+�Ĳ���墙e��~�)�$z��xz]��/XD��1f��/_;k� �((X<��FUPr�=�[�*:+f�z_L	��͝㯄լ���'U��&����JX���:Rǘtz�ۗ�ú`��}V��"�SK�G�8�I+�qG�rC�����
�%���0ޭ"W��<��̈ B��
��6:��~�W�4�q۴�	��$�l�g�F@~b�q�D�ii(>$��S=ԫ����ט��Iv0����>pn��fu���u�S������>E�(<	�����θ4O��>Sža�qӣ�����[W�:k����Է��9˭G{잽gH䲮M�aɵ?��䣷7������.[��j[m��߬�Y�|������G�"����6�B�ou��"N�io�S��h��sgJ����������>�?�꒓�oMi���6S�L�n�ռ����=OF�P��l�����ɮ�aR�&�����uL͈>j���:9U��Y�%IS0����Pp�z�"as�����q��ϰ�rC��	�.^#�<G$�֐4?���u�+&�y��ޛ�3�D�}���ZI�{�n�=�Q��jK\� �hU7���{{�:G�;c	{&� F�ڽ�rM�;#�s�c�+Cs{�ER�)UO��vϢSn���b�
���	o�"�=��)?�E�q�>3�Yc��\J�&ː1�O�5�r�(B��	3���lD ��:O0��b�X���'מs��{��緧�t��	^Z�K�(3*��.�H���0t��;���+��,4���~N0�n|0���62��7�!z^��9˞4���8��yYW�5��3)\c@b�����{'��yE0���D@�ni�B��I(�b�n�3��4���LL��F� ��I
3�^�B����Ԃ�Y��~V;��B�~}Z���SzK���{�G�o!X~!���
k#a`<���g��n���p2�� ԝt�]7�6l v��޹Pa��o�_�?����@P#��p	x>0�x�? $YbH9�$��U@���_�k�gX��s��6���zfB�˗;*|��G��vC
}�5�W�ν���VJz+ȏpY�e1��u�IX
 ���M�52�d�ɌH���3��.����7�<_��Ԁ�|#��c�����Ć����Yk|l�Z�X�c#��-E R}���5;�UVo������T��~�M�:�� �4.�s���Ƅ�A�W��x��֐�|C������}p��L��N�p�4�y�U>~d�1qv�Dkqhؘ(�=�E��jڐÓV�V�>��u9��A����U1xz� E�H����@?���P�'W��4��z@��p��n�bh�/��F[zc���;@����;�n� R{H�Դ�ٻF�S�o>�����ҿИ�ǷI�[5b5,�KM'�o�j`�kv`X�ۈ����£�D��(�DZ�!�X^��s@�ǰ�pvǄ��D��CO��n��������9Mr@��`c���N�ƍஷw��f��.���t��E���Ϗ(Ϲ}��
�&��\�X�ƒsx@���}խ����O�W�`�^_p#���7�X#�m���t�1k���`]�и�B$�,1 6c�{�P������7��@�S�cG��i@��`A���;1Y�9�̀،~%nU�a]�I�g�@���5;7"��&�I�ڒO��G��FK��Y~?ˡ745!�TO7l���:��R�E��+b̲N�y�)���E�Am�B�~�
h��ŋR�>B��=��f�zO>���y:�~�� B�RZ>'j�������Ff_u�bS<�j��򊳭��	��F\��0j�^V�'��,�a�_�a�BT�Ҿs�j�D�Mq��"�&�ӯ�UUC�سDl#��$�O��y��ƌ}q�KH��ֆ����YF��A��z�[3�_��ۏ�C{�o^��l3%�69���r x\�`}�S&���_�h�h� T��C<����}�(;���TI���u�4��/ܓ�#�����/�\�\��gAu?)��%9�%=�k��}��V=��c���E�f��i;n�!���rD��]�_�ɵ�v�,m����KY�"��b�㯦V�[�!]��c2rX�+�`�<g���և[ӌz��(Ӟ����[��	F�)N�U%��r�x�m}F���NȰ9}B��f����-p�3ˏd�r�Lw�g�iD��6��6�sR���y�N��&:(��,��\y�O*��LK�:��#t#}T�G<i������+�>�F�NB,g�1�;M�@�$�C��O�O��'D#�?�:�6��M
aH�rc��8�j
}��p���+��W��%ć�����+B	��ic�+�^�P���0�{���r�5ο��~�R�����P����kG,�e�X�-� :AZZ�<�~4�>���[�S�u4�O�9C�p}��*+�o�8c�H<�}6��y�>W�,@��I.x��/Җ#z�{�S9l��.a�<��q�p���xIo����q��.�������C�|4�~��e	~��ba�v�%LD$LD-�wh��+�F��;"'bϧa]�q�A ���d3�M"`e�ʀ�MC�#'bO��:s� ��7��ZvV#H
��5�A}��k
���MB\D/��ϡ<$h'�:j���@�f'F�Q��p!��\^^��Z9���ĒU�e���[)�����V��q�O��3�`��� �<��+�Z�����}����wO��P!���nW���ǂ���w��w������C?Ԙ�>��l���0"�0������"�-vՊ�.^�/���X>���w���n��!E���}�5$Q�k�~W&""�%���N4qD��|MV6İ>%���L�y.�.��r�F�9���Hs��g��r�h�����l��\�˺��auƤ������wG��-�W�xI/I/B�I>�Hz��)q����q�/�$�Hu�sv���?tj+�p�Y�qhsoO=��.깔݈l��Sb<�e�W1'����e}���5�����PC� K��@����,��,!P5���Dd��e:uqF$�Ğ��Ov�5�}�	 �&Q�&�p5���V�(1_�5Lw;S*!"�$��l��G�z���#)��z'�L~�����(���'����m{-�a���ш^�̾�����~�?�ѝ��z
�0�aDjItSK"RK�eC<9y;	&q�4�,T��q7��3A�I�}FD�IԖ�����%�ϻa�+�"�$.RW�� 'Q��Y��3���or �̵�l���0�X���;�l{sw&    %#�$�Vx�)!یLK�۪�r�o�1I�$����r�����x�}�dw4�g6�	��t�U�N������<�~@#��U��r"_���/VѸ�+Q+�{�>1�u�w�{"�{�xsEd��E�;V=��x���|$b�z�f
=���$�h��]�pև󭔌, oܗ���� �yp3��[z��'��\OB.O�<�����@.�>3"��?�gF�`4�?"��x@iʒ��0�w�a�Q}�Ey�����K�n�PD�PmFd�0(��纪���S�,"mH���]���� ���� M� տ�0�?$�	N���������`9�iD�҈��!
yD:*rܺk��t;F��e����f�Dd��}��ʉ�K���H#��>���H���سgX���%�iH�Yp���%�JY9�(݆�qG��8��"2t��"h��_�Ж6�����;�7�s�^�=���is?K��9tǼa�'�<�_�����7v������9���4�;]�C�Y�Նp����Y����	!��LL�.�V8R,߸���;��� ��`��i uB`���B���?��ք���Dq��(������D�'� ����Ub�c�c�,΋�%��%�rRb�R�F��hBX�>�$I�XEÄ�:�ԝ�8�������~4�&!�N���i��@�Sg�g����N����!��9�1�އK��
A��(3q
���d���66}���� ���-8Jt�G��6�Y���<؎�'�w��~�P#(	�vF$�wu�t�J���I�:���5�wl��c� 	�?�B�>�����}��֗��}t��^��\�x�{s�0�/!"(�A	AI�J$�NLN�);�vl^7!�G���J"DLN��Is�z�%����s.�*!��.z����b�=�:	�?���I�F�թ���0���	1?���բ��� MM8��O�*k4M�yf;)��K̋%J�%J�"$�:F,����2Gb��FI�i��J����~��%�R�����#�W��c=&�}�#��蘄���'a�-�kl�ཱུrg`�c�/���k�������_HfvB���CKJQ�5!n����t�C��s{xBؐMʓه��7���m:��ޭ�=CFͮ��!��Y�ޑU0�
ȐO�&��ːL3�\1:h8 9S3���JwҝVlA�	W��!�	�Wd�|��fU�$ (M�Ø2���B��-s��3f&�e߈�+C��ʸZ_}K�،�l����I:��+
f����e�s�!
f�Uh�s� (�ٺ@����H��5.��R?�I���
��<�7Ӏ[�lҼ��)|�U��I�+�d�$���y�>R) C69�߽r{r�����[3���RD:�V�78	�=��v�L�X��n�a%�'�7V��aɎ�q�g�D�8хx�i��4暓�nU�֐�s=o~W�!�p�sd)3.f���Z<3��|&�2�XϿ���8ݳ{�g��.��{f�ˈ��n�eF�e�@7�83F?�<1�>#�2/#�ޑ��X�<����a�YU��������8�}Ĥ�t	���eD\�FӦ2�.�7}aFތ��l���AF�e֠��3۷`�bYɰ��ˣ�8�OL�|�>N�����luř�9#�2j�S���%�:���\�8Xh�̈��/��si�@˞d[f��4-βߑ�'���ʈ���Q���aB/�+��&# 3���y���޲`?(�(N̾Q��z�I�>*�l��46#�IR6?�@���Z��~MF �"�t��{��2�[�|
v�����}-# S�3.Ռ���5<٢�>	����3B03�)�g O���<̃Z�؎WB>~4�+�@b`ψ��㆛�2�.K��K�_�ͼ,��W�&qOB�	��sk}2���/:��]S_���5�po�޺g������{?�>#�3k,�v�s-���ݛ�����Ew2B>�Esj%G���ktb��3�&�5�5�-p�=wÈIn�*��km�%��w���\6X;��/��n|vF���^~�+�a��g��g�N�{8�1��������0+�CɈ�;`�e��'�qX�ތ�=�n�m���2
'��〹_����2j_;�㌸=��?�m~����o�Cz�9��v�a�|��ૌ�+!�kOAB��/��l����Z���uqc|FV��4m��/w~�B��r"��-�Wx*y# +����	4�ʋ�*�������xY$iFV�#�2�r�K�ea	#��6��%���t��8�݇�j>��vd�`�H���"�2���i��n�MF�^���0�jTF(��,�>#��_�դ��Fmr4 /#F�I[���dD�w��}<4# F��1��7����Gk:Z�����+޽<]\c�3bL�E�����HFI�얤�(I+�L��am3Df�O<m!͙A\�E9Z���ՌQ�6�䔿�(F����?��VF=Z��X�:0�IY�Կ�����aU�ڵDm,pC�Q��B+FxE�
Ұ�G� ���oDѨ6�2BHwϤ3�q����� �t��WEA�́�RKA�L鍆��|A�,�o̙XP%��n��Y:PD3)(�U4�g�}��~�����)��u�a�ޫ����������΋��q{q�'���/ l{,վ��U\V���5����W؀5�R��X5$b�+pb�e��w����;^#��ut=.8���ߺ�:`��ʮ�0���OߝA}z�=��
�	yi���GV���.��[�B�����?��&X�`1'���$�PWl�F�1OD)��	q�����Xc�x��t"�Y\�d�\�>yV��[�Xu�_�]��ŧ��Jg��U�/.Y[�'�pM��k�R6+�����p�@$�Y�V��
bϊV��$^w� �� ;�MG�>���a���b1'���:"��
�2sB����-*T�v,�c-}����R]��',�^-G�����du�
|����=c�(p7
�NV<��A�sd�6����w��H�W0��K�~{��3B��y*\A����1�¸�\gm�Xl�O���ZzЏ��#��8__�'>b�-<��!
�ev����W��� >ݬF�:��c�.p�*����=�Xx��B\
\�@x�IA����W��'`R�~�4��d��m���V��Dp�q��y��W:��O��~HAU�X:��/�5YA���c�#�����Y�C
�/�[>�8c�{�l!�.��B �y�zG�`g���$�AY����yw{OO�����J�&c�/�7���S�i�V�׶�Y��!�>%X�ĖX��.��^��'�6�6Y��.Z�Il*�GZh���}�*���a<!)�El�n]e�r�����HKM8���x�ʜ^o]�'o��۞���խW�7���Ո���wA���w[
��Oaf�+p�/[^e��nc��9=6�.D ����\k褄Vi�4��0��%'��l
6_4�-Ԃ���f[.�?��GcV��"���������{�Ѐ����)6��K��K;�N	����.aX��'M��'K��<�h�m��Ч�f�}ǖz	�|���+p�=���yӹ
}�.�������[�	��(����.�E�E��+�"��- PXZa�#Z0u�y�����:��*��BO� [T�����q\��.V��E�T�Q�*ujT��rz�,k�3�gLK�}v5���0SǙ]���������Btٖ�ߛ%��j<��'.�א����Ʉ�s�����r�s����rW
�	�NPNP�/��4B
�l�����7,}im}�LRD����E%
"
��4/P��
���k�Q6���อg*hX��G�k�[����ۂ�L ���ߵN/��f*։|zʿ����&�`bn�*�8�/��4�--^P�I5��cy^s�3�$�6���_s�������RG��~����J~B}    7�'��'�=)=�=�RsRz�	%b'� 텈���r�oě�c�]H#�d0�+x�9'����T79<��9b2=�N�kyF�I�U��}e�ʲ�;Vr��LT9�k�F&�	�l���m(ux^���V��:�&�E)�)NT1B��yh�=e�f�q�H���is���L�|�s�u��œ�3Tܘ�����(��� DO����f8��o���*�������	*�u�"<��<��UA��^H�T�jm��$?:�4�٥d���o���_|����	�)ҫIi"N��� ��Q!Tz�(1�2�Bv����Q!�K��aOR�
j0�SA���}�	���dYP��h9�sj �0�e�#Zܠ�
��g"@j0.H�Ψ�T���oH"TA�#����P�I�s�4a*Z�Jwe�	C�
����	EA9&!�o�]���}87�d6��31-�g��e�͹s>~YG�B��y�(�'�#�h�!���`��0}軌�?�a3wwomy�vō�+��+����K-�������*]	#!B����ޱ2 �y���j��%&�3�r��F����T�W;�~B��}娭�cGx_	gk�D�	��>a�����2�����m�����y�0��_��G�<��+��Ч�޽�wjV����ߘe�Z)(uu��$ςX�#��b�t��TAūy/�����`Ѽ���G#��GG8��+F҈�`EW��X�� ��p������I!d����c�S��c.����~c�	���j�s4�be{:�%��т�Q!̅=mL�E�r"-h�fA��8
Y�cA�]O*����!j:<���wY)�$��V�(S��ԳX!�t��otc����O���iG����Cxr��}2Pˀ��֧�Z���i��X��H��F:D:���e�0	��"�Iͼ3Aa��;4����ߥ��+��O����+�z �Z1=�������[M%�΄����^h�%���m"������}�%6�U����;=����)�B�y�xqa�S���9�.�0}zkOO��y&�)�{��-�p:�^=$�W�q�{%�qEzu��+�Ы�C˔�_�"]!'Ȫ"]Kؤ|Ez]���BE8zE�9=]+b����uޮIסxS�3`���x�xED�p<��"�ƃ��+"�`E�*�ЫE�;��Q.�a�F���bm�޳�"}MJ�+��K�2��;(�B=�BE�x�� @%���q��Z������X��; V�p����?`ev;���P��W<�T..��P[\�;k�S,^�0�V��x�_E�l�Ѥ�W�"dV8�\W���^��,��
}�R:	%lϭ��G=G�W�"b��y����-V��
hQ3�kq�"p��D�޽�O$�>P�y\E�l�C�/�w	��_������A�=e9T��x�x�Z�n���'�]+�]�Q評ܧp�r�g�ѯ+���*B`���*_+�.)P�5���"ֵj����dK�-Q�u3��TL�|��(S�ݧ"N��q�q��7$��+/c���BG�Ѭ�@1�eE�f�p����yX���(��/�$8�"L����^�ME��ʛ!]7#��U�U�3��ݜ@}�k]9�TD�	u{�}:�Y�tE\�b(�>}��l��+�2���E��[����dE`�@����+���e�qk
6��s���^�`���mI�>,:D~N�r(w��I�>�]7�Ëڪ���Q�=��v-��M�ꨶ�\�#�E��R�A�T,��ď��uQ��`���UQr�r��b]�y{{��+���}V�3�f;z��Wb+��Rl�1_5�)��O*��v�0x����,� -e]��sDb���\u�A]k�_
[�^j�^��ێ�6E.�T�oP��������M�/��;)JL�AmPjZ�4�^�J�rZ�����6{D	ۚ����D�lPܚ��N�y�64�nm����:���Tt`�k���\�A�i=��f���hPtf֓��wĖԠ�!]�^~��Ӗi�Zr����;r4h;v������7�:����e5(:�85��}v�7���O;/�Ր	+�ͤbOK��ܐ�ǲ���Rb���Y@a=���#h��=a��p����}&4X^�d��/n����as:�,\�>/7���|M�<��o��Ч��э�������2��է���������Лl|�Y����hn�hn����OQĞ�4р�C�x�?[+�����\0K*mHg���7�3q��^CR��]i�Ԇ��#��ߢ!�/�Ui#KCzs�r��r���;n�i�o�g��@�VԐ���6��r�Y���V��%;'�.b���廆~��@�;Qs�Dv�f�Ģ�N����q���1�6���eߊ/��Ʉ՛���v�֓�Et�ƹ�9Ձ�%��@Ԗ&τ�`$X���+a�&�@��w�u�Y�	��N�5�C�7�p| ֭֡z׻oL�m�	'>&.������tW:�a\,�N!��u�������E@�z��]I#��g�j0k5KFv*m6ص�%k�(�&G����2Ƚ�-����`�:� �	�`�jֵ�/���7e�[G���V��7�>��zb�m�i3�zp�!,^�nYc�s�~:�?8���Lݙ��.�1�����R�TI��m��>]�4@CJwY�1�a1�	�_����n�eC���Р�A(@@ i
 u@n���Aٸb���hjV�[	X�%�N��dZ+�r���;)Z��YuJUP�M_��w*���wj�]�	6��|f������P�r��5I���}~��;��r�q����t8�{��IJ	V��T+@�uo�@�1�D 7ۗ����N�R0������D�Y�T����6=?���Pԭ������?���>EP�X]w�9l�^�)�g��T`�G�VOP&.�H�>���hv��Vf����V��<�"!�JX}�ڦD !�&��I����]�
�o��,(A����@˰�r��_;�����@�u�����L�r����F/a��A� ��$�I���'a�T��߾�,K%#H���o_�Vr�0��S`����_k[��oŢ��(��D��$N�*(+8s�u�)���{��K����r�nHH�R}������>�J�\<}8�PT�>�,�O�>��u�y~9���	��~E�r)j�
:Y�-�e]ʯ��t0H�)�
�v�܆>��|�@}>����k�LM�	�;:����N{����J�@}�N��	��F��>#>�ѫ��LcUc�Ӟǟ�����]F#�e��)���͟�8Cy�cU��B��VO����<���J&A�EgoC�T��
s�K�XAN����V����T�"�]\� .5.��2�:�Pb�wZ�qlag���@�T� ��f��)X�e����Ǔ���7:a��1͜Q,�u(7�ޛ�FU4]�7�R0����@�X��b���==
֜��D �ȕ@Anb�J�"�wV��=])���))W�
V��j�y��M�EW���C��+Kk���*�d=��V޲r���3h*�'�]�	1%�9�;)�0O�/!�>>5w+�'B��[��b�9�Jx�g��T,��z����*�
����kǪr	�sU��z6<_���Y�d�FEKYx}��n��Up0��ʱ
��{��MaB�Ϻ�P�7B��dl�r�Bq���kH��O�+x�=z��UYC�����X�`��,|�����؆z�l��s51�ܩϣD qm�IJRl ���bx�C�e�L�����oX�폿��f|V�T~!�)J4�X��_
eowl3kX�ML=/��E��6���%C���NC
������׈�7�y�{J}�]�����bN����Qe~��g�v�B�m�E��J���(@L;�WM�fgk��R��)z��
H
F�&�?2�?llMk"Ia$S6������H=L�28쯬��rJ!�Z6��ÐȔz/ڀ��K"�Y��az"Z������H���)+ɑԺ`Eo/M�(�    ��g�1Zś�;;mz���kJ;������e�a�o�ȴ��ʤ��ЧUo=�٪7"���7�[�d�pB�C{����I=��5oH�����܊22�7|SEx-V����uv�v�ǀq����i� �:fɓ�V���_bڿ%��%`﷏r��a0`��q$��	��rx�Y�[텆��m�w|��᰸���U6��>�B�胯-�>�E�:��N߁X�����Nc���;��ݿЊ���x�W;��ܯ���Xp��`D �c������=�-Q�����Z�3,C9}��8V�¸Ι��u'��{rS�Ex�A���ۅ�����6������+�~c� qK�t"cc���嗄��^#���a����0�3�d3#���W�K�wd�]���F���F�2�͹9و �Ă�	ި��_�T*�"�[�>����I�RuШ�S�q}�GՈe�Y[w&:36b�k4)VaLâ-�h�g_ǭ�Oa3?��ym��
f��ˌ ,��t{
 ��:�pfEK0K;?Dc\g��t�&ƊC_\��:�a����>��)���N�z��NiDA[��O��U��F�c�e�jo\uu�k�X>Z!��}��u8�b�p��ZRL�� ��~^�vf��պ��q�s+���>.��H0*���.���lP$�n�pV,���|�L�����L�L����]�K2 !�7"��|�*Jиt�Q���#H� ��@��	;9U5يSMW:�7�-/y�}�hʯЍ�ҜF���F:Q8�,���j��:x¸��C���d �o@p�(�7ط��8�ֺ�D���8F�{�#��I`��6|�8_=8VV��٩щ��$%�G���ZÃf�X �@.�h`�O�Ϛ��&�/jU�ep!)d͉��l;�چ��k���׀ԯ2[_��4eG��\!e@�u�����F���h򃆦��1�`��+KgT����5.��"X�0���:�A~�xAOs�9���v�iĨ�f��x�r[� Ri;�Ec��������
=�H��~'.cq����z���Q��as��F�����wO���>N��	��X ��H���Dba6,�-��#e�(3<�t S�i� �z��2�b=���D����KO��Ӌ�҈C��߈��ň��t�����E�x`�5b�gjR�)����5�A�[���Se<U�נ�&�/����N�O�<����|������h�2��q~��s�����t��׀h����p��Ko�H-X�D�HCJF �V6@5�"wh𑁥��U�U��U�9�>���^��Bd�kD�o�<m2�N���������'~��b����X$�R8@)��L'�b�h�R�ؘ�gÊő_-�\;Q�����b�l�*�J��L���X+��k+K�e��W,��<��}��b�@���{N�A#0�oR_��09�)0���۟V~nXN<��� ����ڰ��I:����Yòj\�4 bU?��NP22�$�d( Υ�YA��-VV��)�砱'w�~�?���}4���?L�4�+���^K�HN��Z���ڌH8y\l�<j!��;l+�x��ٱ"�'w����ɰI��'%=N�.sX�ג4��$�D�9&��$���0��o\�7�:/���0Y�	��k�`��e]Aܠ�O��`������P\'���3� ����Ȫ�-fX؇,����?�OM�"��Փq`�!�]@� �C���֐��)K
�A��������@� �r�-��O�I7��xʼ��9����	�,K���ٔ�K����������|�^�x]�]��Q�,���P{l��`	~޿�R�H����G����]��n�-$B]��~Z��ύ���Ў35B�����	��_t��O��D��?��OI+�G�~����{�*�_����D�\��!�D�� zDǿ��4<�'�E�pѤ���]7�����V�ΰ�Z�m�Iъ,N{*���8%�F�=�s����&U�@�l6Ey"K�1͇��A���G�K'����d����>Ǚ�vR~i7K���� �/n}�7ɥ$��l�||f"k�x@#<I*j�<�\X���g�؈N�䞘	'�\rJ8'���Uٌ��xa�G�ј��.�l�8_��	f�~��N�8�m,�T�1�.9}*�?�N8�,�?�v�p>'���k�-Ą� :�0�N=t�#��\���*�]����1�1�p̦�bN�lSH8h���"�_�-^w#F )��%+������1r���Ȋ	q\��O�V�ރ¸���#.��!�rC�ܐ4��Ew�$�b�N�u�w�b�盆�8K�X�##��d��@��	f~��r�(U@-tq�M��'u|�#�2m9��`��W�q}�JT�[�r�op�lzv�;~:��C�ƈ��+tδc�`�P��ړ����YWw2`����+�y��0��v�����X�o6�s#������}�c؜�Ԋ�4��0���S�s�눥���@��s����4 �������7���<K�<����f�@T��Ք@��>;1�I�)-fQb��B�X�����.���	jB��[:����'8���>O�Ŋ�6s��oPr�A	ޠd�~Ϗ�~V�`>��q+A�Ch�m�;(���;qo'8���/w��N�r���^���A$�.��3�R�)R�w?�ܐ�[��u�0)�!�o��#D�QKHI�&�!X8ڋ������{��ѥ��9B����)S�����6���;j�����J�7�g㖥_����	�Z�k��ϤQ�c���k`�-�����3���#F������#���J#�k͢zFH�z-U@o�W%���,5g�}��Gϧ5�6���BϬT�QyIM�(���r��z+�R���Z�W�x�"&�q3`-_�5;"�e9�WD'��2���)�Ģ�g��3ƅ���m��1Zr�|6&�u�pC	(y"��]C�L-X�q��|)��3;@��xV�L���#�)K�c��|!+�D'<�>�G53�������N������X=ײ쨕�{�zqöτ��^#T���D9���k<D��ºJ���VW�����}�лF���LXS�Z�Ґ�*��зF��|1ޞr4B9UH�1Ul�F�w��̷#��j7���2b�y##F7�vq��zaL>yv�f�c��c>�w�ڈ	@G�����O��H#��m=G���^ى���\9����T��E�>	&���n�!�fW6͐M��uޠfH�y��N���4/�no��#��	�s�dȥ�KYjqbT3DT����g6v���E�W݁���z�{n��Ns�`��bllwɐQm�e���t�x�o��%F~����w�]ޠϽ�Е!����˨_�����w(gH}��j�h���!��L7ː��+e�CBX\�77���+?�2d�����-�	�ː�r���d�k���<U��۫��!e<�;:C�n�h�+aF�2��#1�d���� n��������7=�3� ��&�s<3���9n&�ȿ��qM|�%���k�7)e{�ۄv��zg�ٟͪ�`�?nH�gc���ğo�8K-�gd�q�g���ƌ�2Ri�؈ѵc�Y|�|�G��8���1���n�bH"�q���>�׻�u�XC��s�'ø�]�^�qOs�9)�6>Y}g#b'�Lߴ���Ϙ�<M�O��d��uJ|$r��h���ϪZ��_cڋV�Y�@n_�wk�Y��@,�s�����!.vF �Z�p'���q}��~A�:�2�K�M�`	x��K��vT�)�}�YS"��d�#h��u���a#0�eY83��o�E�YdV�ATo�Q�ߎ�����)��u���Cl�aƐ>ڳ���^%�QO{!��i�:2�n�v�v��N��`���v�-���3Տ2�޳F���.4�j���N,�1#�=[���+7���$�{64L󏫆�Q�ed�m3�����    �@t���^�ep��$#t;[���sjY�'"�ܶČ^��Wq+Pd��A�	$zL�D�#��%i����D��O�ެ<��*P`p�˗��]�V��_��T`g/��*^�4O*ЇJ���� ��Ζ*Ѓ��o��j-�}��-ߑ�,*MqU���t�B��Rj 5M���|
"?�	<þ@�)Gq�ğ\����	�t��C�V��ڱ�':�4����k����ۮ W/s�UWo�'�^��ei���6�b���L�@�9?�v�m�蒤ߒ�}���8*]qU���������lg-�센���	
E@P�_m������+	�(��
��w��L�����U��%T��-��V�XR���I��#��=J��$��f�h����
b��X��GL�j����Y���Xz�(���b���F����G��2#�Fl��?��̾:bvT��|z��M��XT���G�@W<zo/I�@i,ߣ��-�TG}1��U߽��4����zd����_�
�F�h���X�y�rD�NS\��@�)=�NC��L�����+�[(��*sMko�
V��^\6KN�P}ڭ+���c��*Q��(Xo����_$6]�
�c��?�z��Jf^*�p��sy����i��M饜^���׊��������Y%��=l���@�)�y��(2eN���7��i���b���;��K�<�Ֆ��
{JN��Tj��iAZ���q�0���-)�X���/��r
+��
���?mw"2T��f���UD2�T3A>�?ݳϲa��cG+�˔�jj.�6����U���-QI�T�nbd�I-G�{^w7�t��jK�Y�XAJm��y0wA6m9��ev΂�Z��tȼ{�~��������%�T���g��>S�>S��2-C�1"�F�i��w��r�;jc.H�)� �u�ȸ"c�h��㴉��Bˮ��]�����l��"R��k��Hv�
ߨ04���!� ��S_���v��UxD�rۮX��w�
s���zw��#��lFG4l#��2�e�< /^�]�!��i��oU�*Rl�D��ӧ3��[�W�D:�e+�3ET�"�I��������>`u�Q���h���� �s�-B9Ѣ�w��Wx`��b2�H&jE�=��V��)"{����XX�U^K^�w��Lu����8 *�+�5�T�W����g���艦f�zƧ-b:�/_aQQ��B���j�G7b��@��
s�>7-|VaOч��؉+�)::���R	*L�5ET�"�[���Q�f��4a�{�@@�+���JW��Pq���PͭL�o���z}=Re)6 �~����Q��Ă�*�%(�7(8Ώw��VP����˪'�1��Xb�3�ӓ+��jN=��Y�&W�\J�OD�P���#|W�]koe&5{)5���c{�~����
>s�����H�k>��tG�u���/[��mX��
�lդ�{nO���b��c�`f=�C��A������'�?*�	
It�{�bs��7��^(W�P�r\7U�""uS����3���Y�]%�n*�Zu��uS�R1YZ+~$&ٺ�XaZĘ���J�9�[͉;���EUoI�P=��zV��U;+���b2+�Ϫ��l��z�Z{u �̮PE��!�zh�厼(�
]�.�CQ�j�*�_�t�1����4h�;j�f�sB��'�+��h���Pm��?�\��=�)���˅>��*����V���=+tO!��hd�|VU�K�B����C�$ W,��B笪sJ''۶�P�t�e�����&�3��*3T��EEA��d�(�$���Ӷ���d�Z��TP�������(�T{�����Ci&{���j4p��@���ՙ�KL9Q�I_�����\�V<b*@��\]1@Wâ#���'J(��?�ĉ �q��D_ҙ��L��B���ju`1�BeP�̢�:�aa�e;����_�41�)����w�l�
� '��T�������~c݈R���Or�kD��3�n$$K�>�ԫ+@k+)GC�ˇך*$'X���'�h��բ�艸ݿ��"�o@�o&�(���ڂ # 	.���9��ʠP�i,���4����*���u��v zbΨw!�>�ԼQ}�Y�r���+\��P_NK�������!�>��O���hK�v�C7e�k�m0�63�ѥ�`�m\ĺ�99�6YA�=�h0�6�Q�&M���հ�D4�c��Z�>��͵26X��mBL�M�j^�d�qQ�Y��ɭ�Fe���`]�[�����,�D�d^�rj0/*(7�v@4����"R��S��"&ƣ�x�~���^|l-���о�m������1��D�okn0p��%�!	�mc[��<7�:2v�;u����5��Ph�q*"�N�r���V�"�`���1D���f=bu�A�|q��E6>O��0	���8L���P���0ɍ$n�u
C#Al���N}d��Ϧ&S>�	�/V�{R�!�J	q�]|ٳ1Os�K]�o-a̵���h?U͵7-jn�nC_b9���6ۖR裌m��g
�G��r&�	�G[n4�H�|��w2w|}������{qUET�p޲��hp1x�y��O����	w}���a8\�J#>&�r�`9os�1�M7΅�,�h��M���ɟ��A]��Q<X���`Do=����_�蝋#>.)����娦��G5݆�8}���[��o��>�
g��>D�6D�)�}��ʘGϠ�`�p�Gw>���������6��&l��w��M���j[���Y���,�`�o�W��ueL��}x��#���3��i0��p�6�G�d�G*-���J���6�]�ż��)`n]AҼn&q���{ypӀ|��=4����:[���4(	�w�X�+h���C�0���v�GF���-��%��_�,�2�˻�C[1b�c��1�4��~Z����@-j���CV�UV�Y=d�3\�s�Y�ܣ�w��i�M�B*���b���.*&�4����@���x��G3~X�;��el<e��ll{�˴7n���Ԁ�����!m� ���U�� ��/�Pjl",�%a�I��?�ؼ���(@��p�̈ B�UN%y#�NP{�1�����9t�%`��<���@0n�:�J�1&�A2��40��zg!1/��b�z�W-�&�&W�� �����-vRI����ѸN�J��ٰ���b�� [�Nf��._�h:����_5ˌԚ3��w��_ܶnd;���b��X��9e?�lN�y����Ǉ��$���].�@ж؆@>hc,�����E�AEO����Я�r���0��>��Wg��+�S�o� c���mD a���1n '�6�C�}ӕa	ش�Ȳ�{W��s�̈ �'�l��J�5r ��e�YȈbQS�y��l���=
f���@���w��ۭ{Gj�.F��]F���pÆ�ɹw�QԲ�{����]�v�`�����b$����m�%�)X�o�me�2�vLGV2y�U�iu)L��>�A�{}F:�Ń\� &��B�R�E���uUc�|�߉)��f��5vjϋ��A!�m��b5��3��I2�=������ha_~pi�Hq��4Y7�r���n!8b��wS �W�< �:	�A�]�
��(T���<�QO�����J%� 5ŉ�(�n��D'�����@-���]�jbA��\*.E7� }D[����������(��N��m��@Yom#d+�� �}5��a=��I��X�m�����g���r^٦mͶ��,nX��#{��{&�����
UO[�-
q%�9�T7�S�Ѡ��`~Hz�;�^Ft�I�B9w;��rV�t�2 s>�r���Z.u�Y7��A$�����R�e�:ղ}O���Є�����:��h��\f׉54�.S�0r�q��E�$P»z�� MqX�.�ϯ�4��o/�����D�t-ᢠ����r4h<��C�ZK�\��U^{m#���1�u6b�~��VM��    ct�_�,��	�v�����شa'I/�cƛz*� h0��ͬL��hF ���s��YI@|�j����6"�0yx���9���}w�h(xpK��g���T��
4@�ڝ�8��^7*��e=%g��3,d�o�"#��>���##Hh
�"l\���&����������?@�,*��/���G��c� �뵨h��/�Fޮ+5�Z�>����iD��BS�����ڽ~��l���o�_�Pl�����?k?jA3[����] �Nh�@���D��F��mt[��ֈ�>�����]V�l�o�'EB�>����qI�iA��rhD�����lD q����P�`l.x6[���E�i-.�t��~�b��������i��#�!�/'�ֈ �v��� |!�Vd�Dcd/D�>\�zZƥ�;H^!�q	!b0�b������
:7+�#������J�R`@7� Co��yϜ�FF�Ӊ����oF�~o�'��]%E7vn�&�J춐�+�Hya��F2td���B��BՌ �N)����\{eI��"tp����w�F�౫�&�|"1|���m9I��]��f�A������ϐ�!B/�Z_@�W��}���e�%F(�Z�vG7�P{c�w(϶.�j��w�|���~�u��i<l�_�����<�P�׸�{^K"Q���"��F�S�������@yMߌ�2����w��K�E���!B9��L��#4�h
7�~#Tr%��@͙�Uq�ʐxZoc�P��i��Lx�tN��Ь�RS�'T�n����Z�����p<�ܞ�>����d�A/ܪ�@DcS�2ߪ#bAT���~���)�
qT�X�.0|�2Mѵg�dJ��f�e�a��_@o�9�ް�:�Y���=�9Bq�k|
sDQ�=q�D(�Q�[쁢����F���_9�UZ���'���؂���Z'��)��v��Di\�f�b���b�M����H��9�.I
�j�W����G��ڂ^�&B��B?9�U|nAO���J��B
���7hRbШܯ7����A���>�O��
?��NGS��Y�K�6�	��P��9��$S��ӽa���mxP���TG(�BL�����Q�w��-�b�T�{�g�LX�>�'��Eh��Վ#��Y��?����C���8B)�KM�7�28v�T���U[#�V!f���$: =$_��(�{�RYl���c�P��F��B�����`1]S�1BH�k����������d!9����*�ʠ�{�&%w�?��o�����o�ؿ�\�糇�����m��.Bc<�-9�->KX�.sE���aEZ��r6��3��g��LS��c�b�:�I7A�T~�D�	�g�Rz/w��&A�LZ@��yO��}3��f���T�b�1��f��Q���������pNHPC#Jt��LO��Kf�MP=�&���Ì�����7U&hm�����d��M�o���~m�JP�Ti�?�#'AyF��b���}�^�`�D�r۾��ġ���%W�K��R�H�`�§���T�N��R�3�`�3��G�P�e��G���e&h�	�� �O�3..9�������H�	z`Z�e��J*�Ք&u,��>F�S�Fkh������j	Jc�Tw^&���_�L�#Hm��}���i�J���u�7"��]FE�),�eL���J@�D�ţ��<�7AG�X�߈���OoD ��NR�Èc��K��f�R.�;n���g��3x�ۈc�E�%M��	^�;�Fm�z{��+s6 ��dK��ܸ�~|��a���U���#��ڶ�:JF����9�a�6��O�5q6�_�1g�0Ў=$��9#�3�5����	�tĩ�5M7"�8c�q&Ϙ��p��#��?d~);�ݳWL��0͘Ԗxi�q@��r֐?⤶�ٻ��W�5�z��$�m��R:�,�ze@tW༸ݯi�+��q��P�̈�z\�vY9퇂w�N����3�mMo"u;��!�V2]!	��+<���m�ָ�-xz��qp��3��1r ��G�z��3GC�Cyv�v��7�?#�c�1�=W�si���D����\1��O�ݸ⓯�f�G�Ȩ��T��P1.�����<��}8�x�Q��9�@�$yF�F�qi���#L��i�����o�"8���O��9ye#촂H]z�aJ���ut��#���QV�y&`�^��I#̯B`?g�L �H73�=���5�7"�������23�E?l�Iq�����wj��f��ʐ!�y]э �p�Sp �,��*?��!�e�v��j�&<�'�d�+J����}���܅��>}��G�[���n��^I�K�$S��G����#����Fb3d��v�ZG>������M� �?п`'g���]87�gH*^go#�E�Z���>��qm�J���f'3g��E�xb���B&eC��6�l�!�d���&�fjȐP��1�I?�@��n��t�e<~>��g�g���;��3^�팬c-���Ng�/�����(��c+C2�s��S�!C@��-���
��T<�'$eIYE������!%e��g/[���"��SY-c@�{˘�!���2�!A���pdX�_֒p�m6Ol�[��;z�2$��b�"س/�a�Z?�X3y�I�����u	Us��3��L���u����63|�ټ��t��gGܛ��7�I�#�"��;�wGI�cS(�R�ذX�C/�Y)#·���?;>7��(�K҈��jv��~U!z��s�exUsw��<�k��9	z�TA �8i�����R3|�B�T��W��pԇ���eޗ�@�K�(Un2��Bl �j��y���$'q�h��5���g��s��_b�w���53\�¾��Rt��ğ� �,�9���p���~f�lXb�[��{y��?���X�@	�ԁ����.�ع��Ж�)շ,�zP���ŔF��E�XRӰ��{hE�����v��P\�@�/�C�'k�BT�-�̉�t�*�������X(�Q�֖ ���(^�j#�E<�xWw��O�vQ�=�8'��5hg��1��U
�!�Y�
t���c,|�����}����]�@'N�V?߿���iv�/�V��'_ȗBH��O�{"���VZ�l_�'G�t���_l�y ������W �.t�[.��}�(�Vn
D>a?�'��UQ(���+eHY�O��'2����������kb�|A�")���"�/���}��N��S,��A,���\R �C�����rHWz�{����,H�G�:q�Y W (J8����2h�� 1
D!>>�kb+9g]%����P\�@xbz������b-���:��ٖ$S�
$��E���M�����?�B�`x���q�o��P06��y�O(�b�)9W���x��wk���¹�˔< >H=D0�^�e{wp�;�����^:{vh�Ń%�&�2�����$6"�����>˹���wm�+⩚/���c������״ֈ �G�H<��u^2�N�Pa����b$*�^�GΧQ!]z�H� n�-)m���;�{�9�^�ͺ��ڄ���ut���^|ؓ��
1�kCjD ���%�*��j��fQ!
3K�4T��}CYѫ���kcD ����������������+fu3�C<���4|3�U��Q��_�����X��;+�L��u��a����R���!z�B� ��=�u>�v���(�*炼}��p��i�E�[�+�_���-l_doaD qh�%�{�u1|����ot��:C��Z>Rm�w�9�5�=D^������~4*�'i�O3`��dD 9��������Nl6��3�'۟��?{>�1��%���X]�A��%A��͊�ڵ&@����׈ �����T�5b !j��GhDai�l�1.����ƌ`lX�q�u�Y�F��    �oN���0L��7"����z� ڪ��c��R,�l37*���z{q�V���{�n��d <SO~1\0"��Q��`����gT������cH"���iu4�z��o� ��ZLj10�D��1������g��Z�u�������R��r�$�{��d�FO�v�V�hd.R�l�e��� �D���ӓ(�%l�ǖ�fR\���#�E���-b�0C��Bv���ٸ>���P�Z�>oD a}�U0j���.�bTeEk�ԨJ5�錺����
K�����`�����G6�˥�}D����F#&�1t�L=j#c'5PS��ѡ����;w��$ ��C�r���|�a}B�':�o(m��G��b��}�o�vmT3*��Z�3�̏�t�wϸ
N�2�0�-1.a�:��؈ ��n�j� ��������tbPd.�뷵KĸttO�n���^y��ʎ�؈ �7D��p2��u_������G�����0�e[��p�:`#\�/9t��᫨���z&����p�*ȏ��ޱ�@�Dk#�ak��S �'z�^.�X�r����i)C
�[��Y~���x� �w�/dؽC�KTi!Ƶ7��X�V>�غ�{`lۡ�+�b`��MC���
 �=��!�L��F��ƥ?�>��c�J�a��j�/���EV� �zp5���ph�K6���0�b�L�-N�ʧ�i��a{{z��XJ� ?[�ު:�Q�@�������:`zK�is"���u�.E�YYՌ�`���lP���I��7��,CidX>����hK{yn����pp����P�E'8 <dehz(j��v�	��{�Y�W��Z�[��nu��A�P����`���m��U+�Q	����3f�&7���+�@3(R��}�O^�������ͪ_�����mܧN$v�������*h׈�}��54,c,w��p�@����@�^�� ç� �� �LЧ�@�l�aX���2��9tk&s6�ǻ(�W�e��YWI��q�4�FRmM ����A7��0���|{�] �����ػ�Ƒ�l���z�8�ih�?�?��%X��a�-ti�P���}�;yx�2+_��A�e@O偌� ������N���*{�����i�G~��?(�{���=e�u�VƦK�6����(��=��-f+c��������R]���Z ��kvyI*��]>f�����m]>�c�=ԙ��%���iي�V��v�d�x�˭�]�s��=��'{�sz�k��TߺP�I3ٙ��b�����>��8��L���6_��rz�{�I_[�ك�އ�pTO��>Z�Ka�,�;Wyd�e�Wj�������ڎ����������G,�Ʉ����=b��Y�1�5���qݹ�g��n}cJ�.����̚A*s躱�Q٩+*B�ֻ��.|��z����~a�M�r�.'���Mn~�{oI`��h�y�F��GУ#�OC�/J�Rr;L����#}��f�4"���!Xޕ���bS�����}�v�7f�$�f���xX�5'���(�7�L�=���yq�5*PnDr������z�h����ZN! �Z����9�|�C)n�jQo�ؓ�%q.n��A�.naF���HN��|����þGNƍ,N�d��U�����T�L���<7����%��U�2R��G�M"A��V�`�
U���輄u��Wq��}��R��e�����͢��_�>a�W���껽W��Qs	�Y	^C1��A�� %'�z��{~���2^���5T�����q��_{S��|0�d��dȦ�hN)?�� В��?�0/A��1Z-���Z�ws_���)��~�:\\�ɵ�@#A%W�0��z��J��3<x_��)�W7�Ȱ��c+�U76�j��\3�ol�]\2�����0]I�,��H��oDF5�{��l��5����1�8T�%��<�|�Zǁ���UܥǨ֩�$Re����Vrﵒ{�ll�E�K��!�k����`�M����`�M���Y_q֬P0��>[gʴ�`��y'�w:K��Y|���_/;��Y�p+�{��e��7��q
�,�uA��i]~GZcN�޹"'�����������"o�Q�<��[��p��.�m�Y�53}S���oL3�?Q���{9*v{<�=�kS�:�å�wU���n��ҽS�C¹��uw��\�+o�����W<�ÊǽW<6bv�ꮺ�{��Q���'�Wj/�=���:?����ժ���4|�vy�?�lW=���er⇠���)�iܰ�q��U�
*���V�S�?���`{�UW��۰�hu/#��{eh#T�VH�����F�|�_��a+��Vg%��:�^-z��l)��]�=�;�=a���u֡��ҷ��k�u�r4���beI�
z�G�`��a����Xu��sa���(�Q��aK!�/�8����zԲZ�%KX����C�Ղ��Y�������v��tε�m��A���Ʒ��g����������)0���-_����x5���)���%�����R��7��
*�̋O��#+�hd��3�f(D�c0�������蚱,��Aથ�~�����bo3��
)W������g��2�>goI�_��}�/Ȝ�z��@��_�w~��}Q�$��z�����z�E4�#)`l^���t�?�:�޷��2_����p�����_X�+�|������^���gR�����U����<l�\��O��\=���1	�UfO����x^IT�ވ��֗�xv�r.�u� �s�@OV��y��7R�UO��;D�ƣ�Zu��ݳ���Y�Q�s�i��P��_<�~�?]O��3Fv�v���#�q��Q������`��ٸ�)�.�_6����38�sq�;�����[|��bj��J������т$�]��NN;d�k���q|;�qï�s���n<��57"9����ƣ��)4E�G�gX�
��B�e!��ظM�77"9q��)���%��ոI����si�ˋ��^�|PG>Q��흡�[h�ӊ���^�����oD��}��辍�7�Z��ҷ_dG�߷����辭�7í�a!�Ǿ�����l�x�O��F�j��j�0�nh{���N���Ն�Z��k����/$���=�&g;��j}Ok�^��l�;G��O��ۍ����B���X���B3����n�XYM�!Ѻ�����疝�n}�%*��{�U#�$�Lv��\q��D$����AT������}�Q����n�O�"+&�$��S����J���½W�40t�[?:e%:U7Lٝ��Q�F#���+�|�������X���t��<(j�L�y8T6�u�K�d��<u�4��Kt��D%{/�h��2�g����lW�g�&� ��^��H���Te��v�#�:�Ȕ�ܔ�.��QwnIt��@���������q���;_^�"��q4�������ҙ���أ���V����꽊�_m��ɡ���FE{/�h�""��B���^�1��t������*���Q��i�y��6�n��9c�t�L���=�V��ls��]h
tn
tS�E����ҷ�Z��������y��`74��yvK73T�e��AEtO�O�-zA���i҅�I禉��V��@�<~/�JŹ١�qe&V�vI7��e;7M}�EY�c�0�{8F�+�:�c��`�P�]����#1�V��r�g�����(�p�|����1+���>�%ڃG6Ci1���]�IZ�/-�7��[��A��ݳ�?d(�iQ��,��t�·��u�Wc�9���/-�t߼��ZHh��y�U�׃�x�q�����^�{�����Ah�-{�M�2
B+Q�Y���(�/��.��J@�N�eږ�ۖ��g��\9���ojl9g��6�l�f��+�nh�f"N���������Ȏ��t�cP�����>��{�y_����z�wMP�4&���#����/�y{�y{*�H����m�f��6�X��(��wx��     }�ws���;,�^�ҩ_L���X���9x�M���ɣ��|�f�AGo�����q�f����G���'�\��u߻u�/!�?�Tܹ*��������bZ��wcq�`��\�8������ \�����|#�a?�F���s����i�n�����2��WN�ͭlX>�N������:EU���#r��M�M�]�^����;ܽ��i��i뭦�c���G����k9I��d�q�gs(VO��sl�C�����y�^;�9ukB2�42��zr���z��9h�)��݈F�/�O� ���i���������8������v���{F ���w~��E�j��[�&n4ӛ�J��t����3tI���$1�T�N�n����@�!��V=�"�
��S�,�7��=�_.
�Ӄ�� llZ���/L�/��  k�jhT�
�x���]��9z��Q����e��.W�|a���nV�����t���R9����7�/�J����CZ����uIW6�	��r|�vO'�!A�8�ڇ4L�|��=?H�hD24q\+C��<=d(��^�?d("~�5H������z{Cn'ΒI��ՇHM�!���m	p�ނ�Q�=2ԇ���#C}J�����zO���dS�Ǉ<YS��[�ؐ��{�fϨ��z����5��Rn�ߺ#����f����~��1	9N^{��f��g1�t$Us��xR�c���gq�d�h,a��I�gz\��A�׍r���������x��g���/Ǎ"��gs�J������[{?g% �x��U�67�z?k%�6B�Ju�m�(s�h~�F?r%$,&^���͑� ���щ�{]Fߨa����������Y��XA8� �[9��_0A�a�3�T�8N+�l�[�:'���25�.틸�C����%�f�������.���N*{f6N*�r��ҕ�RPõ�ݍr�c$��7��-s���ec�#W��~��B\?�={y�o�H�S%+h��CS��b��c���k�w�OI?���;\��]2 �E�<0��W�V��V����D��Q����SMP�G�.t���Ђ�V]�+:�k�6��,�MȵN"�y���Q�/�S7�F�ᔠ�O��d�5\�j��ũ&h�:4����wwF8�as�9�Y��ΰ�K���+-ųu�В����q�����	e�.�1#X��A<���������zJ�&sք���y0�I�ޏ�
z�"�t� f�ȇ��{?�+���=�C4����Ώ�w�SW!ȼ��Э�����7Ը9����Jy��'5�Y+�Hm�fS��fo�+���F�U����_X|=�	���6�����{�5�M������M�|�H�9�-ܰx���l3�������F.O�>"��P��%o�$�MO�gD�zof����	��SS�N��8�@I�e�8�7t+�fT�p0�0�mP�Z9D��aeJ�6�w��O4|�����0^���s�[��q�� �t�k������o��7x:�>r\�t�\���}]�`s��>��n?�5��	���1�A���M�Pfqy�aD�=^KY��^kq����1x%,o'�3���x뀊Y��m�z)ِ['
2�?Wtv~�Dﵲ�<hm���޼�8;�?D"t�QmL�z�-),̤�b��@�X|�E���{�c������)N���/�!����(�5K��A�F��f�+���o��A9�A�'*F�{�'x�Xv%[����ca:�����,X!o~��Ԣ����{*9�6���wjN�����^,oL[�~�f�~�f�^��6��ө�?�T�����]KyE�c~�윥�������ۂZ%���GS�6Wti| 5[���2��ȑH��uGG4�BD������Y�Ȓ��M'��u�Z؛�)�S�4GG[�
m�}`���J4I�n����j]�b{4-R|.���U�z��W��ܯ����:^��n��cՅ���C����3����2���6��z��+���p	�zp�e����8n�?ک�|�9��A�-�g%�����=H"�0��\� �yD�IOkEB���hԜBH��jt�$�?Z;��t����Ը���οD�;�]�O,�b�,��t�.<[����,c>�x<W_8�D��<k�9x��0;��"��o����۟���G=��_+;��i|v�~��O�n��%N��c���3���|Ta��xޱd���>߽��L�M�:`�0�3���=�[�}�s�.�<��瀍O:{�!,�8�ޜ�xt#T��ęs;�}��K��پ;>�0�o�)�Mۮ����w����e������7�߬R�U�r��A������u������D���a'ȕ��'�ߴN
	K~��䭩lR9�(�=��Ҡ���ǐm��p�}��E������&��M����TEz��K�F+%�iϮ�w̆p�l��Ac�;5z9�����r�_�;�Z������_�:=N��,Db����p&��rJ��.�{&�l!����hq���r9W�bN��M'�CSl��e���vz�H¿�o��ñ������v����.���_WW�~%�[�~�J��W�b)U]�������.�̡�Z-�V�S�s��u�r�s^	r��ٴ����V�^�=�i����	�k+XڔHN�	�)������?��%�Xq&顠\u��i��u��b��rl�\��9w��$+�(]�ܥDr�T)q|��`��"�`���?8Ղ�\unV�1~�f��O����O:���8"���#&�G:*����P�Wu]�%�����Ρ�}����CP�:���4�0O����K�Α�}��N=��9VJxw�SS$A��Ԙ���R��'=����c�e Z�V�f���ս�z@ă�I�r\��3�R���v^���7�I��j�A�J��ħ��=�*���0*T��,T�. �׫T��	-˙p� "�Dr����XB����S����V�8i�a�ս���h}��]���4��m)_�s^�S��2�����fm� j�Sɍ�_r�.Ϯ�#���LK���W�w�\I�1�%���q��~��l�Օ��Hz���j�s��3Y��udd�>���eJ$'��ȅ=*��S��q�>�'�eB+XW �z��T��/��އ�l����9k�1��+�){��/�� ƸF��=]�S�()7D���tE��HNl6gW2;��*U�׻� ~�� �'���`Pz�u:�+�A�?��؊^�w�m��K��%�J7�t���%c�*q)�]FѲ��h�2��ڟ����JJ6N�hf��/��Fd�ܞ��y钑�:�&˗��?��Iپ��2<-x���-Q�E��Ģ>��;,������]����6	�/jۇt���O���+�4P�[�{���{��������Ѿ|��݋�ʵ)������3���܃QwaR�˗tGf")�./v��TT�[bW�$�����K��H�=٘Qb ��;�k���v�(�DrbۀInp/Z����4E�
��M�nz����1�?r7�G�o�����U�z!�+�R嵮�������9F��
���	�1�=��
KNLa81y81y��Q&;3����i�P��������-#3Y����Eϟ���oV'��ϵ����)5>�w���d�s'0�yQ��K^|z��(ܜ?�d�0)�(��<�(�ǃ��>���Ɩ��!�d1@�(��B�p��^I�l[)��x��D�v}cJV�H�<'+
!#j��[�^*���Q��!���V���0x��[5UU�=�V�T��ܱ_0�v�^��,�nJ�e�ҸN��=yx2Yv��ş��i\�'���k���j��>z�L��+vq1*��u�|� m��L��e-��C[i��c�~��ԺXZ����Y
�C\�j����[������X���0y��<]�����\,QL,yL,i�(�<6Q,�<6A,�<v�X�/y�t?    �K�Z<����G�]QX%yX%!@7>��T�Ta'�s�b^� �GH�B�7R%���"(��Drb�k�������޿%�W�l^CN�*��ճs�$y�$�Q��Q�����-N I��{6�<D2��ˣ$iN�N��GI�3AF����U��1$�٭�/�M�C�4�M��{����Vi�D���g��n���gx���<1�؈�w��|x�v�Ax&�>w��é��}�{�"������t�on稬��@��OP���:�n��˩���\vn�|���8��"Sjv�\=qv!g�~���]�˻ʧ�(ݒ�F�K�3.��_�H�2�ɟC�?�ɟO;���y�Gv��~"'6�+K���T�:��̻������z�b#�����W�����L���[-��l���C��5?b�;�}�t�|<�NA�4�/�=|���4�$k+e������rx�m!��W�W�>�"�*�k�ggE�)�������OPՇ�)��#�x�{Y�
k����h)ڜ�]<���]���Z�w\=Շ��%�J�N�����c��Yw�D�Qv�H[#e�`�|��#%GȰ�_��E���> +�ѻx�D�54��=2�U߅UcS�s�̈ꝲ�<XW.F�C�_��B;ʥ%wK%�Y[B㧸�St��A�����5ѥ]m��\9�xl��T.�]l��Q|�/��_|�bè)��+�z�W}�X�_��e޲����z9�RX|E.�\|E.���n5��[|a&�,��Kt���ɡ�cT�DQ�_0���M�|�����Z��O>�m��<Ϫ�:T�u��:T����u�E��"T�s��zz*��HZ#E�zv�=u��O�%���O�e�a��;�'��NF(Wfܣ53`~\��R	�K��KEs��D��C���+�]�x�-9�OEu�Gu����v�0N��w���Se���N0[t��u
[�S6r(�<
���T�***�����F���n٪]<�RJ����X��E�E���	g��#����B&?���3ԀC�Lw�)aD�xD��#���+�)��$��|!�N�)��Q�#�$_œ����#�eEIؽ�HNlT�60;���'_��T�Y�3�ή2J���3�9]�=�S댝�Z�|7�;A�ao�]@�1"9�K�������gn?v//҂�AJa1�e��tx�o�2v�I����qcĈ�Xx_/��eǦ����ZadqRR��U@��`��j��z6��|a7"9�Ʈ� ��y>�&������W��m�<�8ŏjk�}�(�iDrB���o�Uʰ�N�׫��A�{�����Ǌ>���F��/6��M��B_��E��Xd	�Z�Ɵ)�هr��Q�����p�'�����Y=2q�n��5Q��"�̈��9���d	"�ZU��i��v�j�����3p��W��Q(z\@ŕ9?F$'�J4e\v΃��R�(��0�$�OB��qir�>^k\vη]d6��j�ybf��ӆVGg�l�E����CH�M�VCs�����0�ֆ�q�9����=[���B��b�{IY"-c�/���c��j,W��c��X�s�����[��j}�h�W�U3`$�ˋ������?��9z�&,�!d��2��/g,�^�C�el|�4�Q3:d2V���N�A�CYv�j����)Y��۹ѯ%�\~Ѹk|�5P ��s�ˬ�͢�� if��Պ߬�w�ڄ0��ѽ����v���P�Ӛ>�m8�ZpJi��A�!2�9W��{��TGn�Q�&��Ǖ0zD��ɟ4�sN{���.�hԴ>j���3���T�q�9��A��2��=ͭOUB�_�mT�o�lL�L\lK+3�$�!���n/�1%�D<�9W�g�]��(V�T���i��mh.�n.��*Dm%��g���
��OJ�vz�~S�7SbԺ�����ݯ��:aU�#�՝+ow��ZD���ÕF$'������Z�6�h}A���e�� 2�N��nauЙA���eY���Ծ{[�]5�Ío���v�P��X$��֞�
3q�RJAR�
����U���P���j�oFh���b��9�w�u�TX]��t��a�zH!òcь��B�͓wX�a-������������U�37��?��'~A�l-��Cw�ݫXb���|�����iXZ���ڠ�]��z�^�v�h��|�.�ֵ"=�t>
o&
�<��7~�hV�|V�twt����������;��:=�.,�����I��v������֟:�:�:M�]mJ����t��`���3	̨��ՠr(� ˯����/�_ۥNW�Ӫ��:��hsB�F�C�	�R2зϐ�ȝI`ܱy�?�f�'�<��DA�;T=kN�n�.�T;���2����2�b��p���]��Ӱ�i҃������I;r�V�V�R>:���i�΃@�ә�7糡���k�����u�A���S�3	�i�L������=����}'暳�������7�~c�lcI5y&5ǝm�ז.&?�ѷj �8���z�x��hrj -��pl >-�"����&�Kv6�J���E����-�Wg��<�(����B�tx��U���H�|�f���w��p&����߈�di���'�����9X��`�����o�͟�����g�Հ�|�����坘����z�Up�����k����jw���ؙ�����]U�9T�=��ޖ���C~"FG�@��@�h�D9l�epav����MC}g�[�q�Z�8�YF���p\��Pd�My�3	�G/�sX�1�� ����*A�����҈��謀����`��A��.�u��g�:���'앙u�vG�]�\(?��t��3/x�v�wNu����8�W7�My�� �ѓ��� q��D
ܤh7י��ɣxJs�� �s�Ľ~Z�ct����͒�`��xIB�9m���p�5�ѻ�і�Ъ^���2��T>U9��
�΀�S N�I������w� )p����:��LF�F̐�F?{��iq/��&15zX�H��Ӥ9��#�U^�^�G��=_�����j�~�����>Y�(�Ls:vo�J�#��ܳ��԰/��,5�{�/�`����+��x��C+��ʩ@([���2�N�e��X�g������qo�f�0m�t�o^�?�O�<�����H�@8Հ���M�h�F���,Z�I�$~���"|�a����>re�Ia<���cqn������F�Ǣ�C��L�R>��v�R��b0�>f������71�V��
����, u/�/��l�X��Lu��EB���j�
�L�ť�ˌ�*��Do�:Y�HI6>�����N� owAo��ÿ��̳�w��#���SYYx#Ҥ��њ]�^;5������v���=�:J�R1Gi�i��K���%�C罚�{h>)��x��yr�ݪ��-@]��^U�X�.�r���L#�Y(��R���?ki�l9����+��S��h�� �ߗ(2]a�F)k�$0X�0����N��, gM���@J�5[��y���\��Zm��u}�թ����ØO�^N������ѿT�/4�*L"a�4������
jۆ������(��D���U�����j2�W>`*LŚ�����5�bM��S�}�O�bE�Zd�3��+�����}a�'T�t�O\8ׂ���-��t3�m_;�O��
���X1W�x�����	b�s�1l�����`�<u��H/�<LT�0�0	�g9[�
��<��\�����v��Gׂ~���EJ�տt�I�f�����#�"��*J�ܲ _�E#�_u&���:��D�+g�Pĺ�;S�������f~;ڜ�ol�mOi4��{$B)Ji����:c��~A�\����o/���ٺ�Z.�!@.eAW�z�dh,\�,{�qt:��N�5I����l^ϟ�G�Ѽ�u.������c}�ĩfu]Rz��vb�N�Ԋi�`ڛ�1��2���O͐��#C�yR���@�
c*b*�h�>�    Mt h�x�ʗu�&����T0qs>'�zG��d�n�޸[^��e:�OO([	�; � ��?��#WE�<Ʌ�rjR�K��)Q���jj`55���J�u$Q�޽�pNsI�϶�G�ƒ��1�pw�|T��ў��Y*�Z��U����)Fa ��TW�R�Ls�{�įS�?ԅh���s�4�u��LL�`�Bಆ�޶�u�^
I�B�#�����i%l�(a�(as��f�d0|_�AXPޡة:�LU23�AHP�%
�>_�x�_�Yr"����X�����/������#�c�&�9�@i��&M��������h@|&�&�{�#�Î��a#Q�A䯉#"�v�=���ܸj�/dQ�����V��y-�O�Q��vE��C��H�O�y��?#���k}]��ЦR�q���_�^���b���iI�/�<L�~��ԋx��I͉B��_��ri���n/��૷�h_�8q�?:F�L#��O�A�!��
�!�����bB�g��c�z�+-��Z�Z83P*i�ԭѻ��i���%��L�-\;,E��~t�ə��>XEW3��� ja����0����"���t�f�r�T	�?ݿq���C�����^��t���Qc�U��f�nZ���[-����*l���l���b-��o�l�ka)�M�_�����G�h�f�na*���*�0�UG�/&b�7:��L���Ӻ��Cy�^��X������q?Ȓ�����Y/�4庅���z��ˢBS��������,B���E�ǯxE���rw�+6��n�f�NՉ�^*�C$�5�$$�vzZX�a)g��7iaD(g׵��)��C�5���t�f�s��n��p�[��i�qݾ̹�z��`��PN��-�-�T^����Kw�Zċq���֊����+�:LF�o!�C�a�E踵��G9x�Ob�� �M�ow���C��o�x�#���P3����R29_��w�b��Enj�l����	�-6�95	�:@*�o~
�^���w9@4�[m���mF&�������ɺJU�<n�P����{׀���!z�LX��`����.�01o4���3S`��G��#�$}1�)�O���;G6_t�����$0j����w�:�FpÞ��G������e��C읔|u�Yp����ڎN�:��x+��.B�Z�'�����<��MM�n@�.S�[O��3 3SC;:��L����q,ϰ�5�F�{�l���?�΃+P�t�u����f���b����R�ۻ:T yhj]��
����L���B���=on]�m��K�2:E�L����Y	���,u6�
(+J@3�;ؗ�EĢ��@S���,>I�!X�����r0&��9�x�QyF�Ij�:V��wα��
�c���{X�Æ���ڨ0�̯�_O*F�u�N�1�tGvXTx�`�0&��~>��Jc2�R�Ÿ���%�y���}9�������6�
3�|tS!�`N2&M̑���3FޑS��X�Zv�Y��~���Z`r�<�k�8*R@޹:u?������"�� ��4n������8dLu�$0>����6�q��5�B��Suz$M��Հ�,G>(3&����3	�8_>�=V�2��� �q�bhX��T)b�����4ҫs�%��2&��0�^��<V7�Lи���,c��*R:��|9�$�̘��|��߽@T���m��'4�9���ڬ�I��*������n��Ǝq�F�=�+�<k�}�ְ�9�����u���l�7��y����5,����bQ�$0�/h\g���_�;FF�3� 'z���`տ�ݯcE�5��RN���Ό��i��uI����|9|�^{�~��/��
���|�1	��1�Ì�3�St�2���3�STx�͘F�Ar֨
U�%A������E���|[`�9�D6ҹS�Ν��m��f�{q��V![�>���x&��ҹ�G{��
Ls�I'!E;�)�	)��|W�u"TB��A7~���R���B���*�O��'wU�:�BS��h��c�4.ϸ/;R}׹���|*V�0�;!��y�#�cœ)�];V�]%�Cu~Gf�VزU���q6�sS�/E��
C֡O��k�a�)��$0�
J�5q0��F�R��3�~
>�F?�qI�t�{%�h�9�qg'�����[2L�7��g���$���
��o0��
iQ8�e`��SbT�zԮ~�Pj����{�$0:�s�V<~���_H��Q�I�{eAr���%pW'�3b 3huT=#2�VE��r�Y@���A�j9�-��C��94,��B�r)�KN����<-e����R�K=-�����R��=-垨��`�ʘ&z�ް1��ac�zC<�l����F�m�UƄ�m�U3�=��V� �ܶY5���nS]�|��0&��_�Aژ惴1$�ic>H���|�0��� a>H�A�|�6惔!�`e6&��e�!˼!�Y�Yf�2o�2C�yC����̐ee���!���1��2����e,Ayc	�X������%(c	�KP��7���%(o,AKP�X�2����e,Ayk	�]�cv1;cb�e(/���ATyʋǸuw�CTyʋǸur�CTy����P^�P^��[9#&iL,�����l�@�eC�//x�x��ˆ�^6^ �%�t�&�ZJ:9�yZʜl��yAq���ԙ���`�&��R1\��p�.uc�T��1\*�K�.ån���R7�K�p�åb�ԍ�R1\��p��r)L:\�%r���ji��fC-��l���Z��4PK���ji6��@-͆Z���PK�4ji��R�\-�L�\�i)s�7i)t�7i)u�7i)v�v	��;s�|��ֶp�z���k1�ڍ��b�C���k7�^���n�C��z-�^�1�Z�vc�z���k��R�t��L�T�������렼nCy��m(����uP^�����6��Ay݆�:(��P^Y���$0�,{ȲߐeY���!�~C�=d�oȲ�,�Y��e�!���7e9, �!��r)L�!��L�T���2�Gy#x�<�����Q�e��F�ȫ�� ���6�7@yÆ�(o�P� ����R�Ly����s3*�����ˈ���XFl,o��2bcy#6��qgS��p� ���AL-��=��Z,�{.L��t&r.�9�kFj)tj׌�R�Ԯ��ة]3RK�S�f���O\�i)��E���O\�y)��e����\��l�s���3�}^�>S�#�Gz3"�y#қ���ތHoވ�fDz�F�7#қ7"��޼�͈��HoF�7oDz.����[A44�|��|1&RKA4�lDC��e#Z-�Ђhhو�DC�F4�slr�c��ccL,�	�!EO��AT�C�^<zQ	dH )z��D����Ad`z��DfAH1,�lL�@�qH� �X6B�!ŲR,)���bAH�l��dagc�X��dQ��%+����(YA��lD�
�de#JV%+Q��(Yو���ª��$0�,�2m���Fh� �U6B[����*m���VAh�l��
B[e#�U�*����NX�٘&x�����N��t�F@� �S6:���)蔍�NA@�lt
:e#�S�)[��PMXgژ&VK�ġ��PM���j�F�� TS6B5����)Ք�PMA��l�j����j���R�\-�L�\�i)s�
D����$0��{�8� D��F� �T6"H��A*� ��R���g�I��Z��j��Z7��
k�nX��jݰV+�պa�V��O�{�Dy����A^�w&�&t���mL����&t�	]7L�
�n��&t�0�+L�aBW��uÄ�0��	]aB��ZÕ�0�Zҙȩ�����x�0�+��a�W��u��0��9^a��s����x�,P^��_/���4, ���.�¤ʫPK�#T�u�G��ꆏP�#���G�>B��P7|�
�n�>B��*|���    #T�OUKM�Kar��3�s�����z^���ROK���f��s��=-��B�.U�]�
��n�T.U�p�*\���RU�Tuå�p��KU�R���¥�.U�KU7\�
��n�T�'aҡפ3�s������k�R�|���W���W��ի�^��W7\�
W�n�z�^�p�*\����U�zu�իp�ꆫW���W��ի[�^�����2OK��Ц���@�0B�¹��e�sY7��
�n8��e�p.+�˺�\V8�uù�p.�sY�\��¹��e�sY���
�n9��e�r.�Z
=i)u��.��Z��G��Q��j��Z7�
G�n8��j�pT+պ��.q�CE�����c�ĩ�'a��ҧ3�s�����p��R�|��i)�`���ع�ҧ�ܹ�ҧ��ٶ�PKɳmY���g۲��R�l[V���ٶ�Pg��>/e϶e+RVj��R��R7RV*RV�F�JE�J�HY�HY�)+)+u#e�"e�n��T��ԍ��������R��R7RV*RV�VʊPg"�2OK��pHK��pHK��pHK��pHK�ӏi9a���NEƄCi9Ĥ���	bB@Z�1 -g����3A��Ć�r&�=��LzH�9	�=��(.�9zH�9Q\�i)u:���s����R���KK����A9<:�qt�Z3�Լ1W���)}C
��	�Qu������ ����bD�z�.��i�x�Дo`�3UǺ[b44�P�����F�����UpR�����Պ0�iu�Y� [��@j'm�^���X�M���s�7ԺJ����a&&m/��r�O�+y��֍^��T����ƚ~���Tڸzó�5=�G9���d�*����R+��uŲ���6{ؽ^\��AƵ�wϴ¨a�/���,Z��4�h5���4g���3TP�V����ű���X_���ƕqy���~�$,����#�\�X�/,���}x_��2���	Y�:#;�ׇ��EPv�������|�{��Ll�r�OJ���_Ҥ�ϯҸ�u30���m􌟴���ʾ��2FI��&LcU��/(e�2��{�Z���,�Y��#K,8"ϯ|�M��d�������oRe�[��1�L���]H��։�:g|0V�ﺱ����-ԣ�dU���nz���[0�-���x��tQM���*�n���Ȏqܩ=�jlsƎC��3�|5N������S-$Ƨ�I`���k]�аL˓˸�}��vx�#�����b��T�,ŖY�e��&�ҩ�xO�	��K�kR���ro�	&�Om^�}\�+2�|�{��FZ�~1���I�ݓ`�$m��z�5���k'�ޞ�nOz>Y���:N�O�]�I`�@�e`���Ǩ��x����4 ��*0-i%kU 6(�P�+�yX}�?�Kv�h	c��J6iף��0�rlFe�Q��G/cgh����1�%3,'�����y9&�H�}����_3-����6�m2��h�/nu�ب������f��5Yկ�vk8����v����ѓt�t�3r_Y�ɨ�\w��@�;�(���c�&e�3Z휳Wl��p��O��$]��H�}���PH8��x�	��f��9��7롐9Lc-<�6��сǙ7Wi���x�n�z�!i���o�v��3h5�BW�{���]�gd��Ļ�I\��N¬���3�E�[�&�{�D
�ׯ8�n	;et"�Sk��m	��q|�p(#`��/�7�4`� ��|�!pN��o���m|p���Aa�z�R$�)'�0¯#J,Ab�?�rK��9�F��i6�q�P����.��7���|�D�^�����.)�5��I��M�#���X�����aUp�ȼ"�_C�f��%�7cd,i*݌q���o�edKȍG�>r����g�a]=^�t�p:&rJ�%C�CFs�*�9�1�vA#ʌ�PK�CF� �*�0'�{B�'TFO(c�k��8��-+���w�e�e�5}�͡�
�/t$:8�|~x�=Ҿ�Ff���!��!���h|���|A�M�k�(V�.^1:���Q�+������0A�s�(L�$;Le]<�u��:��d�M����,�s؂��A�	l��r������K���$��Zפ�����l�H�Gg�L�Q?6�S�KH�m�k{;�6@��F9�O'�!���Q�C(��C�B���x��k�u#n�wi�D��X ���i�g\wu�p2��`dR���������y���EV{l���|�wan����걡�����uwc��b�����em��8z%xd@�(cz���ңH�����e���������pU��N���ѯ)޻�q�I����/n��z|̃�2�\|��.��G~d_�݈>m�J�8��7{���m�.T"����g����t�cӡ�� ���y�����T�;^�v���o��� ���hH�Ǚ(����|H�-�m�����t��m|q�,=K�x�d�86�©�� ��no��T��/�m2�(��~���^9��7��k��UO/�^l�l����=�l�8K%�L�X[�J�Uy�`v��<�C�
�3�?i�K�	>�C���I;"+U�P�t���v[����~x�����z�?�-��-*s�������@�!�E65�{���o����	�����,'J����VJ���_�������z�����ˮ��d&$_��0�fdN�/p���J��Vv��m�hC$�C���^
G{��iE�&��8����Hz���;C���l��Ʒ�L��%{t�!B`7��qz�����x���WC��f8�.���sd�D���L���O�h7|��Z6�4JY��w`.@�?�·�;��޴O�~�-t�O:���.��3�y{`6� /]/{�8��Ѵ%>�M����3`s��I����u3�1��p\O��_���HgO��%�t\����=�'����_�n7u�N��O���z� ������A}��6&fm��@�g�Y`�E%'������6
>�~t���=�O~��ʞh����)$W��o+�r����5ĉY���\���]��YK��Y��I�J��\�!hp����#�?��@�o�~Е!5�zc���Y V�a޾�����rJPw݊��I9�~z��<�%���!MM���o,�#褡��� �B�I=f��b{�l����K���"�������}�U'%:���yt�脱��]t����âP������<����mW�������_�.x�.���<�]?��;�d��z�B�di;>�/����=�%c�3��N�I-ܤRq8/$�C����Ȥ�х�xO����C�
9 R�M�(��� C&��0�,�.�pI��x��a\�@*��rtWw�o����h�Kc��\=H���iz�46��/z($t��\
3W}�
����ρ,� \�a�Ȣ��4`f�9�2��}o����Ll%)���5*h�
+TYKWv�J�����K�J��2
1+����r��u}z�_�B���F![���������"��*���2ξv�kC]鼦颮p9�y�UѺ��-���m�n����#_A�Ʒ��Q*3@j�)R��ݍ�'-~?��6�p_/�;
5x���V&�9���O�fT8��6NV�d��(W���%�T���m�[�&��U�㑎't�UF��|��@�&��5�MOc��4�խ��MD�V��*$���8^4�5fa4�+X��2X��,9_X����=͠L����qn�7`�;M+W���>u���A�qK�<���8a���Ae2�)��@�3:�ѱ�+�(�����S�W�f�K����0�=M	s��aSq�*8��_/E��4�b]V����(����*�O��e+4 �qj�S��r����g�jx�I��&�+7)E"+\z����{�JM����J�5�PT�=]�__�۟4�:^���F�I[I!� �O \�5ad+�������9��Ň����6������#�Y)y�=�    �;��4������4��x|�S��b��j'�ۃ6�i\�����<��U~7��ؤ���K��&-��BO��b�[�r�h8�o�/=Ӯ�I?,���I-�@�s�l�2�l.�4)e����~�eۼ�3�.j�V4�5�r=���M��
�}$iʞ��%�j.3����_o^�G� �ǔН:�ݩ�S+c��2 �>����b���6�3:�32��[}V�0�/�����so�XPDɺ�-9�d��q���֜-�Kh�e�f�h���ƙP[9�)�0G9F��|�V��:��u��A��9{���˞<��G��|��^�-�K/�mr8�����ʰ��D��|TO��*�Tg��~����'C#��;T�7�|��pH7Vhd���.9��2H=�~���|A�=0^�d (XN�t�mb3u�Q��2��e��į���[>�8�A�҃�k����+X��i2�.��Z�r�c<W��o__�`3��H����g���g���wPS�Oh��#��AO�o�=���޸K���T��k������ޥ�0	Ңm��I��v�Y#�g,��G���=OM��^�{�Sワ��{[�	�+ɘJٳԔ���%W)Z����!��#Dl����n���v	���Fw���vi��]Bw����.��]��n���.mt�K�n�6��)�-�u9<���.D�а�օ�饸�^B3���L/��^�h���L/m4�Kh��6��%4�K���饍fz	���F3��fzi��^B3���L/��^���%4�K���饍fz	���F3��fzi��^B3���L/��^�h��P����v�PhX@T��X��K��z����}	���Fﾄ�}i�w_Bﾴѻ/��^���%4�K���饍fz	���F3��fzi��^B3���L/�q]��%4�K��ץ��u	���F㺄�ui�q]B㺴Ѹ.�q]�h\�и.m4�Kh$��Fr	���F#��Fri��\B#���H.��\�h$��H.m4�Kh$�6�%4�K��ɥ�Fr	���F#��Fri��\B#���H.�AZ��%4HKu��D9r~"�O���^���ڤ3E�h��Ҕݼk3]ѽ�O�!@�4<�͞���4��X3�8��.F���6��l�;R	*�s.�;��T:����v|%���Mz�Xd���R�d�l	SOc��L*��=� �P��e���~����l	:�@�X�b��'U���Q�g����D�9e4m�#�W�H�m�5�)z��9_|� ]蔔r`��_��Bэ����-ۧz�=>�S�	�w�6xјn��A����e��HhR��~u��;�����{�4�Q���+ȩ��H"��p^B��w�K�~��m�J�0�ZyD|��b����膧�&�J舷����G~�"*L���h�������`$��z��=>�d4˛_5��3����	k{)�f�&U?Y����N�l��Q�,�]���SdR�t��FR����W��Љ@s?e�����2PK��P0����.�����?t�U�7��ғS/T<CM��|*�d����~B$�'8P�����{5Mj���j"	�f7�ISh�gWSM�$��������OA?��1��Ԝ��:SӤ�`xrfE�����~�VR������K�TƊx��":*&v��b�,�L��&:zڭ�$�}��Jc��4h���\y����݇#��w�6�,�>��PiŒ�������B�+��~��=��5u�s��x� �G%�����04��G�n�P
*Y���e[����;γb	}�ׅ��I��ص���Kp�&�I݇�J�2�M�y�M��~y�5�G����Ë� ���ˏ���L�&�yY����Ű��M�V��n�	�
���w�@��~�.�7�aF�BE蹗�~���m%/�i�����;`'YJ�np�@l��
Ę��w"	c2���6���&5�t;�8n�$0w���<!l/ʘ&:j�{7x��0&�����T�L�jq�a�����"<V`*������� ޲q����*���jir�N7�'R�˨f�FGLN��쿭3D�m���e��6�J`J����X}��d0j�j�pZ��Q[T�]Jݕó��1	��׽y��kp|s�?�����։���f�f��������+5g��g$��-@��F���xᤐ1)h����l�7:�����X"�A�Gu�GC��r�˄�I�|��o�����c	Ǻˉ��E�D�59~�f�W�Κ��6FFP�����ԍU<W��f|��|��jrϰ�n0���C3w�k�C�q�L�'��f����o�8���9~��yz������p�n�Fm?��A��9Lb7F��e��atK���3wIl ޲L�Ǎ�2U�I`�x�0����ݘLz�x?{�gb!x������y!/_0��i%�$0��!5����A�i�sG��Y��ܳGfˑ2����Occ�`���;���^��'z4��􇗋���M?�P�ɿ`�/(�7��6��� G+��⎎��9��q(��g��dl��~J7���A�tO1��9~���TԒ�^�@�T"~�ߩ�j�,BE��COjjRȴxD`�C-X��	c��8��p7�`*zj���L�X��Ӑ��tfh�5����Oo�8�e�� ��+����M��Å�`��촱1��Q�/��
O�ȮA�4e���=��� �	����q��ih�D��B$�]�n5��[2#�`�.V��b��~���B�p���8���L��/����c엟o���8�IYj����Ʊy��M4�
��;E鶨%��ei�6��dx���(3=��:Ⱦ;�=p�O�����ӳ�D.��I���h�k�R8���:�^�e�{K���n4"� �:QD�� ��T*0��6.�J���ɻ܍C�O�=$ڟD壉�u~��³��1���U���mį�}t�0���.�$0��'-}�VX5�+3�*l�0���w��u���{�?��qG���:�[�+y�Jn;�vL�-C+�����&Y�p|Kˠ
�#�r|cV=>3W�ި1	�u`Hr��0�������b���I`�ޗ1���d��X����x{�w���Aߘ�Y�P�<�$0�#�ܚ�+��9K-ޣ�|��*��ot��Mc��F���E!߿q�e4sw���5�[������r��p�!�s�vw׳������ Jf]�m�$x�
NK�|�]OPA�}S�3�ߖ>U�8�I����Xn΋��d���Ѡ>�2mT5m9ѣ��钧j����x�p&m0�6:�>r+��4����W6�5�C�S�OW7����d��E�L��&��Y�a-���5��!�p�m0�6Z�A��GR��J�>�h�h0	7:M�G�3x�
J����n0[7�l�`��f|�?ټ�`�n�<��L�B�~����y�i��4ܨ��!��FeP�7�t`q�o��%������h������N�Ly%�Q0�5?���b�^i�q��h�����&u��9UT�#)�F扤�i�Z�+�Щ"<VPnݘF>��Fc�֍��5��n�5����9����iF��Q��^�,˅׃���l�'m�M����zI��J����uU������`2��Azw/6�[SE�4�K������n��7 Q+c�e�&�D�x�������e�����|�	FHJ>ܣ��7�U�����S�[���&�D�:g����d�`�$���PK�I0O��'�0a�h�������M�����jmً��i��4m����537,��e�*��i�T ��o��D�{�:/t�hao������l5�J)H G3�`�jan
sK+T�}c�E�_���n-��/��v�8#$Z�-,��R��h���*�Ui$�W4Z�;�`����+��0���Ƃ(-L>Eh�H{��<+�N��q�|��t��lh%��[/�c�h���i���EE+�o��^?�#��q	�ilζL�ܣ�0l�Y�H��E��aj���o��q��wI��iEHW�#6�Y�O��U�a�v�X�aqG��a����    �!i�d`���Nh�O�C�S�{��t{���i�a�uHsC��f�=�K���Y���S�{r�[��Ϙ&6x{,lڂ�=ֵ{�W�豼��s��I=8!?�.���rz[z]OY�!���=�v{�Po`?�E07�v`2,��Ao�]zz���:ԍ�,\�{���|։��"=�����ݐj�F�[W�^~��Z������R�U[{&���+[����SA�[�z`��rC8R<����v�M�$�r� Td�8�"�m1G>���`�o�uf*���E	��V�1���B��6�5^i�!ӂ�U��d��+��5�d���9���B�c\E���-��lTZ��j2h������.���<#'-ܾX��rW��]�D�Dnc>$q�$xUds'k���]�T+R��������1��7f5jl eߌjA�(?����SFv �^<�
d�Y�$0�qu��!jPڪ��t��GǍ���\ѷ#1ݍl@ޑ|fC�		ϲ�M�K0
>ʲ1�>I;lK�%�c�<=���v����tB0j҅E��v���I�0é��zRZ0�+�T`��X�!�,dh�P=�2+��$%���n^'RN��Q���fF���g��qe�>�n��f?��O������O4K*��+�^��Y;���4�I��<[�ȴ"�ukh>�����\<!���1&��B�Ԉ70�6�|l6$��e+���eZ��t���`������_r������oӁ�r��E�n�	�幦�淿����ƶ��4)����oe�I+�9;B��&���j>�9�"@���~�$0Znt��'j�H�I�m��ۇu�ڐ:]/�- \M�m`;��~􇞂�u�W`�F��c1[�@>4I`L��&ض_>�4�@Nq=�#�Myqc&�C�I~�Uޚ+,��!_�_�%�q�z��a����$0t�Ϙ�6�5�L��E����x�e�kI���A��t��=��n��kT�e��O�4.��e�0��Gq+�_�t�x��*T5{��$0^.@V�f�Z�����`Y�������D���6�r�Gp�P˟H%��5&�a5��@�;�5�+���&��h�'C��J��`���9�odR����0����W>`�L0�˙�������V(��<i�nO�3i��{����_C�tp���-MJ`;*��t -��G�`��:�İI�y��������(i�QRc�V��?�@*Δ��\�o��-~��rj�L�]A9��c0��(c��:_z�I'Ț��Z��Ly�~�H�������`�R��a�Q#;E����"R���5�g��V|�NfĠ���(���Ѣ��p���F�n���[B�a�"v��s>4Z��z�+���5�{o�-_�ƹꐔ�7�w�z��W��ע�Yv������t��Y��9O�������`ex�ܘ�N����2^�O��Y�qp��Ll��T�n\A���>�nT
UӨ3&��2�1�l$ǖx��v,�jЉ�K}�}�-Jzxܯk>(�&���G>"
��G3�Y�r�%(�cl^����6CI�C+PM�SC��4�������0����id�g�H�'������|�!�E(�4))��2l�����f�G��&m���?�q�N��/������)��I��!*̤�`cبI�:1n��%�����I��'��VT|\a�8#R�� Ul�G�&����qe�����T0v+�W*>��!�����]RC��hB&�>�W�y��lm�YZ#{��]�Z����Q����2���6*2B�'QoD�3B�ac�ٞ����@��_g�{m����>x�:�|�'#�+��b��W����_w��>i��3��nG�� ��8�6�i����'��2B��}�h2������l�q5�I"j1F��oF�7[�3:bd�H)���9Z�Z��4�6����`�k1&ک��Gnv�����9�Űh�頻�Hz=8�H;<�����X�DҌ|�{�\���QN�G�Ns������oS^��WN^�&-m�N4v�;G`Ȥ�O�b�!s}��a�&����_��#<�0gD��L���Mb��Π��.3?rfh:�ёn_A�F�+]":����y��HkF��n-۱�|�t�~M1=#r8�'x�4������.MJa���4�)�/�l7Q�����w[\�*����K�Z�/���e�� �nR��yܰ�Ҥ�6�)d�ΓF����=MZɈ��՝�I`��t8���� Ɩm�oiB��_U?����z��i��'�ah��ys��tL�nu�P�����k������%�8�I�+8��4)�|e�S�]�)JpҖdz�DK�x
�j�����d0�P�!e����¾���߹����2�X=q�P��KA�د�!�cʚm_P˴ b\.�o���5���C(�{�g2�?H.C
��]0yI-�$��x5-`���=x�vǩ�!
�{�6#���]� 	�_�� ��W�MP�RiH?�O4�� ���2&�A7��ˑ�'"]�bR�>�Q��qe'Ռ� oF��~ͻ�.++v8r����
??#�@]�VX6�?�p�g2t�_���BZ��Ǘ�lZFL�NĠ��6���P�	�����F��H1��.�#H�� ?���P���1��u�S�t�h��w��6L���wl �0JR%)�r�]��� �vOr�"�
0K��P$3x�dA<�,��1�� $R�+�;F&�z��UTQф_{U4�/N�
�a�7c�k=��M�(F��n|��P�_0��Z�����Y�q����)B�' �����=k�/���O��
�˳�]�rmM�47�3i�A� ���H���C��C�ov>�:�.u)���.����S:�}j�����E��'?HE�H�0z���c����4����[~�}��}��0���}��lp����/��k��Cǡ�X�4
�݌����{9��|�� �rp����]��gRi��
R������W�,
{-[�:oP]�����tO�Y����I��F�ԃ��΢P�c�� uڿ�O�z�\�~^}�T$����:�z+�z+��DC�mX<����v��K��S��fw|;���Է�eZ��g�� ҽゴ7}�(�W��V4���b��أ�'�$0���� C�j�LW���|+|bTd��L3c��Ə@- ���������0l8a�
�W"~m1&�A��X�zI�b��	��U�0�N��n@B�bD>Hk?>�'�-���y6!����@τ���A��ȟ�����ȱ��'�.P�%�_dfM�_$�0F��"7�Y\.H��]�|E�����hh+!~���E"UI�=�8��{H���IS���힄�C�0��}��ߣt�A��PN4���� ��
�i��f���56�(>[���g�	[UVԝ5R2W�)+���o�"NY5_R��`-��U����������h�r���LUE ��Ȋ d���ԫ�&mEr�~>>h�y�"&Yl����d����f�F�Ԟ���{�_�nREp�ZAq��lŬQV��J���C(���اY�����
t����7�C+��_.�T�I`tӁ�c��ிP0���mk��[�*[/�G)�e������@������g�]v�8�n���3O�������h��L�|��ÖE�	Z�Ho�����\�ݬ�À >]Uy�\Ѳ�_9�#����_�dL�.��!�
�gф�F�&X��ӭ����v'	�x�w���w�:�^	.w�����w��p����4tt��*A�u�R�ؕfIQ����:s�|�.�	2m:�i��8�?'�ݧ�Z�d�w�;��%ȵ�Yּ�$�(�D[�-��"�<�M�<V�X��%�r�W+�q���;��yo5���V��.�)L�ϔ�|}"�C�|��	7&��;�gnďYP��se-ADN�¯c�$��G���ٌ�B~�T	*���r��q2U�ʜ�g�oۗ�w�� 4'\wF�� ���[�[�1��Y    �أ�0���=�e��Q��/ؾ�D.un�e��3s�������I��U���4�ԋ3A�?b�����'�?��bt|�<��i��=��K%a��*����x��	r��'��#ǯ;����jȥ���0��c,��n1���v��.�<�C�cao,�vW+�㢳����bsO�ꢅ��;$�;$��C	���%<��b	�G(wDK8w�+	x�f�Gt�3*�f5;�O������p���B�=�S���r��0�)=����T���vO N �q�׌��{�4q��kFS�ݭStgZ�3zy&�Yg��J�ΉL�Y�bn"�x��\����h��Ԃ�����3�	`�P[
���3���(�����8Io[f(#Yo[.,�q�H�a�v�˒�<��z7<3T�||�ͭn\x5wIɸ��!���X24���������e(,� в3�fH,�I;�}w��r���{�g�,G߰�q^���t�	-3!�b��.1�]&/�F����9q�?C\�5�$琋��DV���^��>�B��q.�dKi�	)R�t�,���t�)�&�� ��'���փ�i���^�#��4µ��Ŧ�e�McL ��^1RLٹ�g�ʔ���	����t�f���xliH�i
_戳�T6:�Fd(S��qC�~3���>Ie�]�jU"�����H�*�1��t2��P[5C��O.)ehT��\���Jпzb*�e�T��<�Pj��aC��B>��h=��n�O���Z:,�&`��S�=��+oQ����h��Ƭ�S�G�*��	C$�V�y��H��D��;�x��F�Fw�f�[�r˜r��m����,
)�ͼ���Jg'Ʋ�I��s�paҾ�'x����,+"���ּ3�R�Ï���޵��⎶4�d�u�C#��<�f��đG��2�+3�W�|�ծǩ	߮�W�8�-�y���e�|�1"O�{#NnR96M�X�&�a�p��#���;dAͺ�U�b�!��{�λYA��H:C�ҧ9ݵ�v�?�F(����u[�?ʑ�2D(%	�n�|�e��_0�A^�b?e(Q�H���jR�G60��}z�����M2 7�1L'+�	#����ץ3� K}v� �������>5U���方gA{�Y�+�D��4vE��N��H�q�g۟��d���Ϗo��"�G����_3.�f�]��h�q�4�h�;�ɸA��>�C=��ug��a�կ6g57�/� �a4����� ����`�!���x,�B�`����,;b�����`13d�1j�:�Ō�pp����3���P7<>U�f�u'�#A�|��m�IӧQa0�/W��-��a�h��A��M}'��(���4c	iƌ9�] �YB2�*v�R(y�j01�씁���[�zVHcnj���bƈ���Y�CW�u��H�\L
�0}���Ɏ��0}b����7�XB1cNhC�&�h�܄+�7�~�4���	��w:9�S��d	�Ɍ9�@�T�`�Qi�%��	δ\�C-j�/��T����K�9f̉���]8�@�|<����J�_Fl��2:`� TPXז.���E��uW�c��"�w�A�O���{|�9�.(6�kz'���.j��y����.6vѻZ���vEm��k��j�S����-
lղ�.e�;��\ˡ�r(z ��	��C��0��P`:���'�W�Ք�_M)��"��-=i(��RND4.���!:��jJ�Ժ~�fC3PM��fJ�,����)!��i��+�(ϟ��RpCE�n��S����̥G�vr�g.�A���\|)�ŗ��/¨$�c��{1΋eXp�E0I��3_UXSշ�*��z�x���
����zK �K:O:�+�D���m/	�Ϯ����&V�M�
�v��͋�EUag�����:`O�
k��>W�I���: c��ܱj(X��dTD��FY�Q&�:
^�wF�O�_��g���!K*�2�֩j�*�5Q?{T��Ќv	i;���3!m�1�Ta�U�s�;���K(6H�Xff_�1W{lQ�����2by�(�k�U�}��S���Ta�	�\��0�4i��V]F)�8�w� T�{���܌l�Xa�C��ai:;��xK��WՄ���$VXzǠU����G�}�Бv�<TQ�=Va�UU^^���
�lp����*�eZ� �1z�B?ܿ�F3����G�$3j�5+��:���7�~���%����G����Ϩ��z7�b��T{�� <sC����t�����7!�m:��z��>�3L�y���O��3,��r<>ݑyv��0�����2>rw���>S�l,��[�g�L�QO��6�Ev|ifdI�X-'�ߌ,	�O/��-5yvI��I���l�aC��ur�å���c�ӂLh��[Sf6�*k�?��J��<�b����q��p>.�z��m�8�n3�AQ�d���/�qʔ���#����T������3�݇�����r���&���V5�7��~&F��*t���o;���N��3�yob�G��������m��:[�v螼�Dt���3W�$��lq���lw���W�,�3,�ٷ�fXz¸Z�;o��e�,E��i\՞a�yG5�a�zjo���L"���J���?��;�qr/�_tS1Â�}j�5��4t�5�d�礊�'��3�'��wύk=Ä���^i�U�N��#��X�Ǜ������w���>i���8{�������8g=�t�϶qk$Lk���q�z�/����2�l�u��<v�.�L0����J�|>�Ϻ��|>�'�Fm�R��>"h���+m�����,�W�Yq����q�qFϔcN	-="�������7��vg��I���6ACc5��g�fkO�'�3V{̽�	:Ca�c=5�Jb5<9q8?"{l�_���)aT��A�c����!�z���1�q���m�0~�>p4�R��㏃=�R�)Z�Ŭp�_�P�g��;q�<C��ϥ��n�8L���������ͼe�i�XL˾�[�:@�>#���Q�DI[����J��C��q�4fDP�$:�h��f�Q�iY���6#����s{�DI_�G��K[�N'Tb4h���*�F�潱A��RtaR_JD�S	'|���BP>!5(�jޝ]��q� E��^ըeW�����$�.k�-�A���Ӏ���Ŷ9J�V�1J����� Gۏ��ѠC��#F��ZΏ23����*y���!%#��#��i<RuCF�zvŁ;-6�(�Q��F���QG�����T�m�`�<Uh�fQ�~����RB9.\�M�z����fB���@�%8�>���������u��!�n��&7H;�#	��tF��h#�G��`����#�^(m�r��>y��D2M7�8� _w?�4"�a��OKQn��� ��,�����N7^yG��^�n���@�����ȜDO�T��@*P;%�4@�"��?=b�D��{���kĨA$�4\q��#��{�A1t�o�%�'�i�1�,oЈ�m��f�$���{�F��t�y����_�U�^�i"������6��
s�MF*{�p&ۼ�vg�J<o�t��Awt����РIlA���S��e%�ө�&�������ޢ.�8Em���^��\Z��~
�\'��{]J��qI]&�t5��:���wU�ղu7B�L@��x��h������u������4���ޠI��%�8�ی.������a���0?-i;�N\�j�6����c �Q�r$@}���>�p>��ꏥ��M'g'��`/h��3�t����q]���yy5���'��a������}�K����1������F~������X�A��:)G��D���"x�/?�hP��m�zFR���ͪ�5[�\�݉U�.���sE3U'�f���p����s� �7ȵ�^��RE3�;Z��ntť��������� 7_(&���������hY���M:c�F֌V�    �Ao����+����V��;w���<�R=��-8>_�0�µ��0�b����Z���gؐ�!��l���ղ�	`���>���=(|��sN(?����(6��>�>Л������9v˼A>m�|� �62�]����fٺ҆�~�����Ԧ���g��|*��)�I��W��I�����!�}���\{hh�ʠ�^8�o���U��L�2�y"�q_Rj�-Ȩ|�4/=o�0��^�d4�7��H7_�nP��9�a�(�����y�A{�˙t�N+���#4(�m���4�b�<-���P�M�������e��=l���K�� ��-����h8��^uN�f�	�LMt �J��τ}�l候:���ɇ5�Qk7jC��zL��D5��q�����eR�ޮ�+���0�7�b��s_%�c��*���zZ�2��4���'
�IL���;�++� �9z��_�
'3�wvq`�d�A�=IM� ���~��i�#��Ҋ�#��ъ�c��+�������++��+[W�w�4�
��K�PמܥL �'�ϻG��%��!ɻXB�'	�ȋ�P�I� 9Ls-w�ixq�
�n'���
�������{�����'+��p�g��$豟�M����ָ��x�W¯�"�\��(���r禀�)�o	��Ld�e���j{�c&`�	v��5N�4�{�+W�����P�:H��(3����n��^t�O}����u�5�N�c8�8uv@�O�; �A��o�N�����Uq��W[DDl&���s��_T��	'� *͝�f� �[==k�sq�<����h=�#p=I��/�b���+�lS*��y�*�ح(��p*3��r�"��\�}=��`��z�n�LseX�,�_�-�E����3li��ىy���=�R� f\�&���v��?��
�7�s�Q�V��;sEc�#eZ~aF�%n�	K���I�	�e>�P���x�/��-1�3@���g2aNX�&����M#�+9�Wl���C|�[/KW!��%p����P�i� >�ͥ�e_
RE�
�O�GA%�;@ַ�_�&�o�]S���ݣ�#��N�-�z58���<��r����v��	k�k��i$�����ҀL�V��dV�����D\��X&S �'�Z�������ף	kׄ���go�&TI'�;��V�r����-?V����?�hW� �+�nsd�cּ�<<�r�;����ԏy���O$-"���S?�T��Z*3��a̕�`4����/] ��by<ˢ�ɧ��C9�m
&�����NXw�õT^8���'��w�W�U� W��@�����`���A�#�d�DEx'i�0=i��25����H��O8��!�V�~�v�wTk���۩�Qk{��D��j�d<'���yX��C:�ZC�f��#�x-r�0��?����!e��JM��l�H|i����H:z�P,�;9j�N�\HA��ͮ+/��L(�t��;̬���~�4^��(�� ^�K�������V?X��+��Ss��E���?�~������a�G��Uf5.�GX�����G��n�s"��i���/.o�/�`%���D���NҨ��6�r�ɲ|x�s���+�Nʱ�ǯh:��%�FPA�r�e���&t'w���c�r}{G�#��@v���O�T���T����o���E�R2��\���.b/eϓ����C�zXl2�D짢��HRJ����T�fJ����K��(:���������Ko�����*>H��AD5K�Χ�'U�
tL���^���@��$1^ǻ�]��r%���S��*��n��(��0��F�b��q �|�J7_�cO��9KD��4}��B'�Zw��ǍQ�.�Yѝ���ޝ�z��P�T�B�u��Mp��\̇W��b���@ߨ������}ѣ��������A���q_����X���i�b-��(���j[�n_9vOm�t	q�):Zɚ��XǞ��?�ym>*����h�~K�ʱ�,���>�)��D�ŉq"Z�1�r�"���G�cdty�T�r0)� �m��>uetvuD�Og����^7e*�����Ƚ����
"�H<������;�V��i���0�#S�#��x�W��q6����EP��e��t��*-��w杩輮掤l{�X��a��h�N.G��J��/��w�k��z	��+?K䭳ώ*a�\�n�B����R}F��D:Y�}�`ǭ�'�?����7�S��}�8�6�6��-�24��i���!�	s����ݟ�+��`�6����W�1�\$�o�����Z��G��˖O�3�3�����=݌��>�LǴ���1��<�-����T�|���τv��3��{��y��h���Wr!Q��x�q=��`r_�_n�7�)W��(#4�S*e�Ji��A��zVC�jG�:�]ꀥ�ߕ�G_�qP� uo�(V��x��u�O;1G7�7:��-���Or-����-L�"�\wJ��B�Ұ3�����ݏ"t����:�0=��ˉ��������LHñG?��/��&B!ޓ�X>B"��0)4������e$�<�6!"G_D����R�����,�#����� �_WP0��� E3���-@��'�Up���/Bd�j�S\��`�i��5a7"��G��	��a�Ѳex�v �f�qOn��Z�F��>W�{��km�Ω|ԁ8S�%���Lwt���	����2h�q�󖇜�yc��ʛ��	�7��-u�xv�v�0,{�I��p=��Q]-����g��9'�Q�U`H�S�n�@Ռ�?r?��Q�v�j��W������N4���^=�
ā���	����	`����	`1��Q�� �����r�54e�LC2=���,E����GE�zĄN3��H�F��'��D�0�D�����=��4��rpl�h;Y��F���ѧ�:����9r0&����XdF��$����+�7Ľ������y���D5�V:���[��bpGt����V��Y,T۾vZ����|_��O�ѡ����dG���?'4����H�sߨi<�U�Mi�Ihp����Z��F%P����!���Sח*�x�M����n��)���M"�2�Ũ6�\��ވW ��_��6`Իdm��{�u�"���aᡍ5:R�wc��ȱ_�
��}��C��F�sc10��9�1�~�_L�5p(�����3�t���u{���H26�¼����}0����YAj�O���q�Z6��;��׉F�_�i."o9�^'XM0�)�������k�}=��t|��ǈ���-� ˷e`>�(�����'��6zԾ{;P;h��|<���\q	�<Ø ��2�b��3��(��Q��i�VB�y��0�"7��W�>9�3���>�,CF���\�����m@1
�U�hQ!xm�� X���J	�a.�s�1�EܾY�O�ݘ ��IϞɍ'������#@�K9��N��N4y�20�ab"���NHK�8����Һ��^�a갵~83\E��a4�QI�n����Ɔ}U�"��x^�od��F-��� 5�vY��ץ�7�a��1x���c�h�w�$K�1�m�9U�a��{Q�qm�{􆻓�@�i4���ђVь�����T���1c��T��#A�<�~�-�~��~sM'�C��;M0c��zS�v�m������}��'��w��Go=��<޾¤q��ۄ&��t2:�L7�b���9A^�^H�Y���)�B2�ae:x�>;��:�������;cˌ��NZ�F�^F�w�dl{p��{�ml!u��e�q�?��s@:s���h���"��&�SY���t�j�θ}���_���6Y���BONhM�F-��F����ܷ�7�z+s���}9�TD�Q3������~�S���~�Ә~�-F��g���g�M��O#UٳKI���q:o���F\���h:^V]6O��D������V
��ƫ0~��    �?��,`�0.��I��	�1̎F�O>eMС������<����_H��Q�t�t=�J6�,�:�C�5�����nz��R'H��Tc�qY����n*�e�f�l�Ep�z;b���h�!�+���-̱2^��%A/��ȍ#f=��29�u|��y��|��9����ѣ}����"�p��<��4*FWl�8!�O|\~�yp��>�x�8��Z�C	ޕ}'Ⱦv5X�2>�:�HI�L�	��
/:�`�Ҟ���z3����6O� O��5W&��|���7A�ԙx�f�M���߳�W��a4ˍ�{��L�w=4�3�Rs�y\�!3���A7[�	3����NPy��b��|���[��ǡH��EڨJ�9�ƛ ��fؖ����&hw��ɟ�;�=ȹB�G���:/(�D���>�ep��͐�Գ����2,���*B��y:���P�����.���jT�h�؟ �M��z���'�w���MP��j�̿a2�b���o�1��F��l�F����M���d��	��{�ޘ ��{E�]����qG6���	*�;�Ut�:2�8��l�\��e{�2�(]y�`o�Sџ���%�Ye���1����V��p~�y�eXC�܎��%"#G똓�����<oT�����jf4�� �+ OPͦ}�ig34��h�gz;A
�o��g�}��Xi\wpIb}O��z�L�K����c���53���?�� Ȝu�4��|��Խ�%�,/nhbǅ٘ F�����p���AzQC�6���� �F��y�/�6�'��+@�]�)��m����3�JTI�L<&�n(c�>�>R�b����3�گ�k��9�K>cA��w~�k!�@��Y�,V��85�̀����S#LܱS�	����g�k�'��usB��2�Ghn\cIS����Mo�oe댣-�EM��,��B���+5Q	uK��Ʉ��,�́��*�'����kwO?4?�S�v�H��?���ʄ���	2B��Y��ذ��}�����~����O���.����_��	}`O����&���1�#bh_:�p9�E0x1xX���x�,#��d�V�F<0&�q��.v�l�L��N��U_��DEuv�~'�	x�̥7��s��.B��L�"��V�R�֋W�O�E��v���X���|_Ყ��;��"T:7v���Y"�%�� Н
Jho_	����-&�&��	䰓�!Q!0��!R���	M-%��=l�߄�J�'co)ɖ2�-�Q�B�m"�LX�l㦣rp)4B�R	�o_��f�W}�P��޺D�N�"�C��#T�C�\V42�H^�мz=	2/DA�]5*B��a鉴�Jm:����"(��t-(p���9�����Z����P���p"ԨCvk�-	b?���'�	���
w���D/ ��AEuW�tÙƵ�*��W��s
�W���[�x/x:\�Odh3��[��Q����~2tԷ����.ݛ������2�)�&��<B�跙��
F�="����ɹ�<,�m.*�DH� .�+H��F՝������ВNr��*�^�]�e;��	�U3�+ch��E	 ����i�~*!-�e��ݿԷ9BXP�s銐�����0*V*�]�[���|YeX�C}p/ �h�^����5wi�!�*?6�\�CDlɽ�%b\&^f?��!EDs��t�S������qO��!���ƙ�	�{|���Ͻ�H���X�	{�o�~Me~�Τ�񗋮�Mo(����L��__��<�}���h��?�})�}����^|�l��	�$`������"qc��p�6t��k}�X�L�ꗉ�x�_%��t���6%_mJP���a�������z�q��%U�$'��΃����z���t���>%�O�4��?�B9fB�����/�HP����t2� �[ιb��|5(A��	:�0W�����H��r�����]��{��̆	ꏾ��~'h>�Fu�;��'�m`��)�/�}��'4�e!`g)	�A�E�� �o	�����ˌ�Կ-A-H=x�ck$hI_���{EB�&s��z�`�~�|EOd EŘ�bkf����5��%�L����Ќpw�	;��Rζ#a�=@��L����	���3�;vZ�N:�;鄝t�[T'����I}&4=.9�M�L�ܾ<k<>{��،t��N/=%lQ��EMآ�}�y��$lSH*�$�U@��$lX�e�����m����S�3�~�y� uźE�^�\>H��
�M��]l��0����lR
�ר��az��M��<��|O��!�C�� �%	nc�4��8�f��b�&�J������aeΡ��^�i�V��>�e��6�E��?�2�0�~��G6`sO6�	`��}�An99�甠���<�E�o���>G.�I,PG�x����6��k�3��cM�X��\߭ӄ:���ʯ��&wP����3-/7I2���[ֆ0W��|ޞ�f3L��8��2L�ힻ_d� �$~�a|U)6͔Gp�ߕ���wu��bg��2V�P~VOۨ���0d��B{y?���Y��Vg�^d�¾/��7O�󋷕�Ќ��O�S�[����-���p'c9e�NY���96���ݚ�?e�\d5�4��{2�#�7� ���`WP%�[��y<��\�x�+�n���0�r?�9���fXz�Z���)�a�	x"���#.�{�ax�)���)�p��`G!Ny�x�]op|2�L��PW�/^}�b����x�C	�oI�8Ûw_I��;�kf�����<�A�W�v��3�ڰ�Z�I�rF�;Z���T��oo9��ՋK��Y�]?��ƻ�a�g;8�`�������[='��>��G�a�g3���F)ݓ����l��W�u��=��N6��oxG'�8����z��������Aftf��)��b]�f���e0c�J��e[��r�� ����f�������NX���k�/{�����+��{���i
�4Ŷ"��ۚr�`WST�܊K;�S��ѧ��u�39;��NX��'�<K�Wv�`�v�@8,�E���b��t�-ۖҝ�xF|]������`�Rtg FRZ��Tv1��h~i�Y��z�$i
u�Fm�;��A9�z�̳���Wow���C#P�����`G�O}�<n�,R�!(�_�X�l�P`��l-0[�yw�X<���;'�~_�(h�����T�TP���b*�r$�>>��b6�#h�'�U�	{��dS�pU�	�X�v��~x�j��x#3������J��َ����PB��}�L�
���?���
�[�I�Pɝ'����y�S�p4��YX�&DVq}|���Yq�E�[�I_��.�7��<6��o^&#2J��e��>&u,�F�\�� �E���ď�!�t��IB��͉��o�[U_��0.�p���+�j����+��*�j$h��&���圩�����Q9i4:�̢��bVf>V���W��*��Q�'��	�������"��=R�[k*�Z5�����W�:�F����`q�Y��Z�S�Mz�p���|�<��2���,��DaL�3g�%4(�$֔��f�N2&���d��h���z4A|zu��\���9S�X>kՃ94��i�W����FM�ͥn�O��-�#z={�OhU��3&���x��4�?O��ƈ�BT�:JhW�h�Oh�dq.Y�&�07�1��'3I۸�#Z�a�#����c���V%pVc�}����ahZ�>I�m��&���f�1̻��w����dq��W^C��r��ʄye�#��mC& �͍3��-X�}^`P���
��	�J�V��8{GoS8���;;_��� �JS����G��-+���F?�N1����0��edZ�q8Q�9��*�扈qf�Cd�;D� �ie�1R��q�0R��k{ܨ鐺�S    C�X��f4��A	��w3$�ڜ�s>�0��������:\ļ�3�� ]���V��	ýAgL s��왈	C�a1[D]>ז�!	����RE�r<��D��}1c�KI�u�2�t�oڄ*���	eLx���owc���-o���a��`E@r0G��~Mɘ�2G��I�f��̟�k��������!�1��g��%#.��OFD�̮����ˈtل��u�5&��.Z�y��i���=a���z�`F�z���V	s����0��Zo	�O�'���'ٖ��Dg7d�L��P���8�uBf#��ۿ9�^F�Y�,�:���Ѕ3a�d1���a�x̲3�e##a��^��^~��f��6�6�9�c2�=��1��O����ϧ����h�Vr����������Ɯ,iAI�ɒ���(i�������94�N�$��q�K߸�{1�Tg<9�cV}�5�=A٘�������h2f���^�WVS�'۲e�\Yu41��j�1su쳊�lM̘�\=cn�|}nf��2����3�[��W�.Y��kB	��)cvʦ3�oL���w��ot'���E���E7cF1�W6�gL'�Es��@��u�v+����dL �v��W�����/�E/�m��a��c��q���y����L�n@Fh���NwbX=~!=+.8o/�y{�y{�䛳�z�`�䳢��]�ѻ������=:���f��dG߹vM)8�/�	}�	�1��<U0O��-V�S����I@T�e������Q�uշ-�3:�]�SS
v����0��W���s�Q�	Ǵ.�a;��pӫ��{JaW�����Z0��06<�D���!H͊�o�Q��`
v����;�J�r��u#�V-�?�_�g���Q�����o-�.S\
��=y��e�^=������Y��kӰ��7j��;:�j�]>
�����f�%.�FM�DV��e�ht���[:WT��  M�R�َ?�1����{*z��ap��`�7vnH3�y�����R�R����e��!L�b1�c����}��G�w�Ųݿb��<>�P��B�P�em� l��X������vc.Ɇ�b���i�)�X��T�9���_��+ւ�kA�	ޓX*ց��I�b- w��/���,��/���Šb1�y3���9AC���Y|��PƳ�"sD�JQ���b��ʳ�+V
��dU�X�s�Am�DZ���b"�j��E,z���NU�U��3jŤ�$��+���ϗ�07�O�A�=jvE5�	O�^��2*�����3"��f���r���s�lF2����!�֙1�6Ž����P�+gFv3��Y�����͐�;="�w6�7þh��?I P����ë��A:���1��ټ�F��6��	��N�3&taās)��͛�}�v��f�Ь�%�ʩ�	M��0�l[K������'�Of�E���~�Mh߾�����{%;%�q�F*�k�)������ݱ6���k����S��p`�M�a5m�jڰ�
�Q´�Y�a1�O1�?�FmXK�:,vS>V�比+e��$ׁ��Ѱ`��bѰj
�'��VMex9��7w�4��a���.�[[�����a�m}�e!���I$�w��7���aNS|��7���X�ְ 7U��3[��_}ܖ���o�߆�W�KQ��!Ұ�
�u���c>у����ٽ(����\e2&������Df|�>���C�ou"������6��Z�0ko٫��9�#`)4q�3�����;[��E]3Rǝ7�-d���-��,3F�k�Q,d�a�Ջ��~��*3���ݼ�C�fAʌq��f�Ɍ��V���>��]��l��e+�e��9�+f�9)*f�y����*�e�۟��r5���G���r�Y �|�`\���`�3���� ͢Y����Sʄ����A�1�軖B����od���Q�9wT�q6�����>�n��a�'�d�4��A�n� 1��}���i���}�>{P�cű��	`�g8���0"�ЏwGԄ�<j�㌦7.�i�	E4��I(j�* �W���Qv����R]��X��07rk�aa�J��<*H��B ���t������#��`gh�����eٰ߯�V��4Q�������m��v�۝�ma4�����['�20��F�4p4��􎻑���<~}�ܮ�H�F�h'|���ˤ�Y�u�G��HRyک��(���籄N��_�	`h|"c�=�Y8E�-��X�BL�������:!�q�nȨ
ʢ_кȨ/g�cL �e��L��lo��Ռ�_H�vʨ�/!��QaY�<�:��Q_��1����,�}������ag��7�����h7x)h-g�gL ����@���V�̯삶�Q�ܡS�|�O�O�"Z�|�����+sJ�74��u|�_����؉��m����7�����
�
�1�I4��	2,�h^gmL �s�Z�͊֬��h7�$ h�ՎǸ<�͙[	�XO�����z	^��<0E��y<�;��@I��O�S�0�~�Ux-����T5U�;�j��s�*�W����
�1��xDį�f��J���+`�x{�~��s��N�
���a��q����I�E��z-7���Y�?H'�`�O*?����2)��7*��2-V��F�u�޺�?�������֛ '� ���;�z��߽�VqM�kssb���x��}@/�� U���ؾ7���k�@�۝a;��to�U�t3F�6r�⚛Q}\���P�	���I�	���lHK����$Y@J�-ɔ�k���އ��g]���W��X1�q̕��D����I�n�=��<XK��8C{�P����\�o�Uܐ3FK��s�%1	+.�ux'���'Ԋ<�UN���1W����ny5O��e�tt�����:w�k�yh|���ą����{����1�U?��1�X�3��'�i����؇�aՈ'��]�$�Lj�r���zV�OK�w����ьlv�����Ŵ���2b�����6ސh�A�ₜ1r�_��e���BOV+�ȍ�}���^YLvNd,�z���"nbG��E��U���e��>^PU�-bۦ�,eM�Uq����e�@ĞMH�⊝!����E���>��í��
�oy����А:��q���s���^�g�XXq�ϐ����g�T����i��	�J2�����-�>�r̹�l��)4�>�ZB�86�a���Q�b�H`�3}�U�]^�8�̫���hr�U��X�U�*�Dq���h@O�J8lIfc�c%���3��]��:����]�&^�H�c+n�V�fh��PcF������	Ƅ&q��S"��pg�d�M�%�")��lLo��uN1ʛbp��꽓F�5t~�:y�n��YL2����L�LcɈ��c}%��kl�D�d����,�:�&kT�M�	�{�ט �p$�Rz���!1$���<�'��Zehޣ=�(Ighh*�������
r�:����)�RG�q�֜�Q+�8'ّ�%4�|\,N8�Y�T-N8��Oݽ�TM��=��>�f@_m�zi��8�V�Aȥ��'����W$�Q�l�xbN迮�`�ZfL �&��Mc|�%}�L �A'a筯�r[_)	U��4��&/�Q�x�$ {>[�
2�����Q2��I�y2��5�����3�2Z(#�ޗ�u###ȫ�o�����$�AP_-�\��0��f����	� -ꁉF;\F�Y�O�K8:J�ӹ�+Q��J֭�f�x�p�b~�-ܾM�,��8��Q��ho=�a4��g��@����y�Cl�o�	+!��<�C�?�����h���)��ۻ[��-����.�{����	���t���W�����Nۜ����<��'l�'x�W��K�IC�9�|�[g-�����]T�hYy�O�*��-!g��g]��RF�&�f��^��%��[�J��!��ޠ604	��4h#T���0�0O_��N�z:��l	�y�8    ������=����1݃\�rj��9��5����?�H8�P�oOo�k���?�ڰ�2��4��8���0�Y�6ی�2w�Ҝ�a�ؘ3z��/�3zˬ��e)Yv�^�Wר��0j���"�ņ|ﾯ�'9�yɒ"��I\DIk�UYoQ���tPRϑR����wn24��Qܘ �G��\ō��Q���x����;$#����ل4t��dɄ�)`N��%��m܇�W_h�*M,����u���4�4o�i���F^n�`h�����̹ݘ!�]l$��O���n�xϽ!�y�����/�ed�8�&�u7�O�g�t!6�w#�B .n����+��g���x �3�S�:�e�6&��#���P���Y��H��d`K2���R� ���2vxM@���L�g��p�E7l�!���y��V� ��2���_�P�?B��z�^�ᒠ9��6@�|��)7@��$�Q	�U��W?2���X ^,ݝ�4��l���x�/� -3���@�L�v/��C�\~�B�}{�-������g�OC�4̓�,`�P��p�qdL #��5H�&pz'd�\2���dH@:+�q��R'AnzA�)E�g�eE�e
΁��.}Zf<�G@=��Ӄ��R����I䈆�G�?Z3���3��X�ņg���#���0�a:�;���]S�9sP���t*8K��L?h�/8G�/ur��ǳ��<���P֒Κ��^1�m�ǍWW3P�Kx#��Y�V�ʀ�wO
N���"��Y��̡�щ�Q��$�W���r]����+;&.8��	���PW�/f�3h#*="!�%�0*ѕ�{�*c����z�*C{�vv�����-;��Y����{b��ɌM3��<�U���rs��	��ɇs8��rX 8�.Fr��@s.�?J���SgIWy�N�dg���7�����3�W�7�I�Qy��Q �᳌	`��(�)�?��
�##@$�q��h��"#�%��_X̘rT�Z j1�>W |�W=�P����eL �s"?*�ԹYE�v��7~E�vlY���{�|8PgY�!
���0�4�����2�*��y��C���3�j��,�3Z³��H�/{��4��R5�Vw���A���!]]�@�ƹ�X�K��.�vQ J��-F�$ٟvE�_
DI{�sR J
e�yfKC��k�=�eFG��v#nkO��N���~��0������F5��O�~����
$?�܍l��W|��@�FCA�c�U�{●�>-��R��"zSz�ޯ�E�Q�'�#�������0�=�/��/-H��\�{Z� ݾw�(�Bj(Τ�8�!���o��XdQ���WM�J�3Ȉ�PFt�=� �EB�p�������D���
a�v�J�L��X���o�߬B��#XMRX��F�210>^*t��ot=�WH*���H~3�B�8x5�D��%���
Q��1dVh�15���T!Lh�%*%��*PkWX�=�������Я\��B먐�z�й�w�EJ�"VH=�'��jPԵvu�B��h�Ζ�B��7���\ة�5,��8��>Q�j�k�m+|D��Է��GyM��yQ�':���)�fЌ���G��m����J1
K=TX<��Ba�v��g�W(,���T�7~D�Ǔ��&���<�P'��R��T���e@�J��"�ۥ��PgI}p�r9���ل�l�+d��:U�Pu'o%��4J������6�"��֘ F4:gԱ4ˮ�Ζu�O@��g���=:}<�~��g�k�ފ�MUH3U�=�Q�ˌ8g%ڌ�;ě�rгx�[����,n���'bTH՗.le댳%�ɭ3:�ݰ 6�;vm��v&qMoc[�ū����f�z��5��r�Lw�W�	����7�ltt��	�9���-�>���}�Ԛ�*��s|4�\9`Ȍ�wu�
��چ�;�V(B}z��.��«�
�i^Ȱ
�@(�5��kF��'��M>�,q�љr��ݶWlۅq&膪h*
�9	���o+6��\��\#;B�7?i7�fP�n�S�����8:���G�u�16����7T�朜U��`�G�`�q��M��,��5�"��m��"��RÈ�HR�8��}y���|&+�\�i��4��!���<�P� �.���ZM���B��R��ҟ���;���p����
aL;x�7������<�]��r�N�E��Ř�p���;M�;�0�y��MF��FV]�뱿�zX�=S�/c�T�����
/��%���l�Ŀ�-M�&ʸyŢr����O�|&���@sT~X�H3ZE,0���tDz�<j���-�zՀ�a�w�!�W�Cz���Cܻ.�K��qA��1an��1�Q+�g-3���خ��]	y��,�����k�-��h�X��(�S/6,m�o��]��@r����==���a��
3��1����1�-��<���p������
Z�=~&���� ��
����p�M!#HO���s���T
MV�����b�\-?+i���O�~��4h|B��=�[��@����6�{�\;�=Ľv~zbk�Z���+f���H�H�`�]Aҫ�diо�%wUj���=G|�����]J����0��#�E�0����cu<˫�~�Y�/�4�cn���\�زFO��1ͺ����	��4y�Rg44x���&_�H�`�lf�V�AYj����jh���u�}���nx������o��߽~_'a2� :�9�� 8�~Q�n���v"�i����S�"��1�.68���ۋ7�i��O�,��3���.�]��ޣ��㰠zKw.W��������l�.L��~�q_i���F��,������\��Alk��,��� ���B���[�4��{X��xd�a������ŉ;1W4X=��e��qը5J�Or}��5�Q��%�(����}�K0�Χ��u4��:z6�RB�f��@mp`Y�ޛ��HĔz��m���eg~��a��A6g�K�������HC�4����l�dD���WC�4GXm��|7���F�(�,ޠݹ	P*�s"�n�vgyK,��*��s& (w��d�fr?�k�
�r�@m^�v��E���ͣN��42	� d;}���� ����E����&�V�M�L sma��GM�l�|�=}_w<%#Hݫ,�(�J&�6��O�<��'^*	+Z��pcI�
��N�t���ij�/��7�O�����v@�0v�J%'�j����C�8���.?�pJ=����@�q0��ܝ�'z�Bז��Go��y���tBEO=����۬)�F��_���)��[jY}��N�� ׸�&��&p,��&���Э$0e�C��v��0{��X��N@���HO���/���ܛ�lv�_$�B���pd�W2r�/�V�P9|�ТX=z�Y��Y2�ev�sLBM{{Je��o�M�������nq0�C�񙹠(��.wT� �jN;$Tp:�FF�y;^e�0����y�CN��)�| ��Utu�u��*�WNdY�2�w�2�ͨU�ЫT�6QŰ@My�Ue=Y_۰
M��ӄ2rԸ��@��N;XAmw�(��"��E��8qĶBMy{FeM�~�D�Stz�23W���t샊Z; �鲢y�z�Ъ��c��-Xe�w^���m5�	`+�lY���x8JEP^��Q��#E(����;LC�<'e	d�7'��J��1I�ͮ(�=�J�.6���Pl(l���$����YZׅ����,�<��3��g��K3@Z=��@e��"�iW�~��L��k�)R.��)���BA��p����"���N�:J������9p�Ǖ	`$D+5m�a��R�D )���n�e26��w����m{^�y�x�4�`�-#{��C�̨yo-0�Q�Ε����Z+������]0؃�D�țA�t;�f�R
e@��qK΅�-`�͒E�T��߫q`�=�N���    �r��y�n-�p��V'He�T��l�e\ݱI�l�>s(�Hg�`O�ž9m�;8� �
����#���$z݈LpB�Hmk�y��'�m�a�$ �-����=��!���jם����0%�q{@��0��~`)����)o�y���Y�YБ�vߛ�r�ķ��5�c�Lw��<��7N�����'_7�^�NL��\�a$���4ф%��$��Ri�k#P/�j@�[�z��>�8�GI^5-��Մ��T�B\#��:sH���'��P���Ǚ�0�|"����ytzr~*�n����pb=�0#"���`"��2��c��>"��*c��]0���a$~E�_���nE�È&�؟�^S����W�zi�1��
XA�9C`E��H��,"h@"`{�t4���p؊N�a:�V.'"��}���&�,W�CV����JW�jcA���*m�-�]/ �n��n��{v֚�n�|�"���MN	]'����B�Ed���}G����VM��ͭ���,�)��T���;4���9���"[�u�芋H����C�#���}s�����U����F��|��h�l��/GtFK���12ڳ�M��~Fs�2�Ѥ^h��\��y3G��f��G�&��Ӿ��o�^�T��O5�jX�h��*�$�/pA�(�I�s::Ew��B{����	�)��_�1`G=�'l�塇��?oo@�^e��m@�^e�%�������W�_�߫�H��+�����*�	H���bGw[3���W��0B�����M�N�hP6���I�q'�o����|�7�������+WG�ű��NnF5����R���q-��a�J�W�p�CX��F�Qx�@ަ~G�[�=ȕ�dla�u�h�G�WSlC/j�I�"�*t47���yU+����+��k}�����'�x��3Q�� ;���'�<ʆ�mU��
�;��w������?tf��-���l�� �����I)��ɓμ���f�bC~���>p����P���9*�ἷɨ~��yo�����	Ń�P< �x���rts��BRq屑���$H.���^�A�q����'V�H3����3�AO�w����-Y�&�x�&�y����NQ<�C@����/�_�Lψ"Nl���� 1�-ԉ�������	͕tr�3'��3W�B,���l�@.s�̇�9��'~z����X�8Q�2�+�Z&HH�wn�H��3���\�e!���'h��oc���ʃ��< _�2�,D�/�ZBu���	5g��|�Pu����\)�+�i(�������,ԅ��0a;8�۝��z8�3����Љ4�P�Cr�#ə ��n�&lĦ}z%��M�	�	-cL8߁Z����r2�(���6Յ��L؟M��J����ٱ`���Ec�(�y�> Ͻ2�/����s��//C��7\N�.��́�����˝,����R|�eY����篎G�2q��e�]#ֿ��_쎹���0b�t�r��F,z���~�����E��!|:�X����}�۩�	U7�ᙻ� �}����=���-����^)M3wA������mU�\�	(�~^2Y�Dv^*B �}�3�d�WF� ~<��{�9EE{ǀs\"V#�e��wˑ�|{�u�������1B*Vc�f�B�P�F$B&�&;˭��v�8��d��h6wi�XZ��;�9��@}��`^�6e#Xǫ5ba�GW#٭Be��a.�oY뀌���H��^�q�ݤ	�L���������g���?�+M���>XNsS! �B|�����K��<$�|d �r�=�a������t-d�~�����b�yG����s�����&)]+baY�a�\�߸���l�C�k%��%T�;�"Yrp�%$KV�u�@�d����3?�%���i�C:�%@��`����̨
w�Bbbe>�� i���B��$V���3	���8�d�jEs0���|�������0����<�MG���0�-��e�TaL s��&|�t��&|�t��"�̙*�	`N~Yėœ_�e��%|�3r�	`N~Y��_��e�_��1�r���J���++�9�����+H��{�k��Xst
�v�`ho~��CF%P{���O�Ƅ�&���-5a@��1�����tRW,�s26���q^�	şNś7�����H�Q=0���Ac�|!\���^��y�D��2�%y׎�Y��>���t�~r�y��Z����쭓���p��Y�*���i}�)DFq�e՘ �lфSFN�i�<�a��HRI|�gtZ�d'il>bi�k�{A��͘ Fy����X��;:`< ����c�z�54.p�?m7g�B!HE�/c)����٧���7t���}�7EV���u�Ɗ��t!�̱+��^�>�䎳�1a0�S&�D3��g;:�O�a�j7�Ԗ?7|�s�mL #y<<���	���4p��dw��`��f������X\��VŰ	�F���d�hp\��b��,�A�ط���9���̇O(X4^Wc���0dҫ��74�[�u6o��j,�)�[.�U�]�2&��w>����ސ7;ގ0J����ep��3�!`Fx��	`4,�Hq��{��	��l�>��=$�Ż��j�q����a��	�F�;P_\C'���L=[��G�3�X^(NcY��`X�y-1}�=�'�Q	S��@��#���[�Hɘ ��F/b?On�#����1��WNx��x��!�܏G���[FX��i�1��D��Ծ=���'�����sJ�Pw�El�j_����M[ =�{��\GL1*S��)�yBwt�kclO.Y�-c'�}��BRA.K�[Y���$���ʳ1���|���}�]Z>�Y��o������{�/w�mB�M�=N����/��">>"���;o�oP�YG���t;gB�Ta����_j�'��4�<|ܱ93�{�ʌ�l-f 9��_$�Bg�]�+�};�o�ߏ����	 ��d����׌����{��bv�_^�-�Uf}�ՠ
7_nP���K�듨Mب��']�AƳ^v��%@׷?��A4n�h� ��ڿH���� i�*�`_���q�����5��T��9�Aan��ܠ0�.	?����ec��ߓ1� 7_6n���y��-&/]�%"����,��q��:�e�k����"�������=���gL �N�lu7n:���.-x�#���6�{v_[���yuū]Ř F��0�,'��%k([��@��.;!���!`/4a�qe�Y����m����	�,x-���ٷA�6��I��t������1ˮ���Qk��;F���ؐ���$2�A	����`�%|�;�'�����x�����7�����+C��R[A&J�
M���j�ݨAOn��ܠ'7���:0z���k�Z�1�r���o�j�K�5S$51�Ҡ�6_QmPT����ǇiPT5���Ni�s6�ٰ�4�b{��5�98*�^ٖ�n}�n`�?q��i��}l����Xc�]�bް�5�B=d?o��a�O�x&r(��nׇ��d0jO��q��HW���ޱ9m�BTɸs��Ћ���u���������a�h�{�%��c?�卨bq��?{!��a���g�7?��,+��ȄJr'܈	���=X����ΜPI���sr86_[�4lh�i:e�r.��˝4z�i`�v�����N��0����53E#�8᮶	'�2��ܳn�0���F��a̕:$��U7a�K�G�4IM��a��T%�}*�h��``��V��^�ɍTc�(��׻Ypb�%5��ԍt����+�L�+��m���������r8'4�uW��U��72Qm���1a��	��N�x6H=͗z�c�kP;�q"��ۀ�nyߎ�4�z���	_��^	�W:w�7�;�|4_����5�<���{�WL��LK�^t�a�Igl���3����w���WV��y�Պ�"c�i[�Ld��oWSF��ːDOMh�˘    ��!�OeW�jФ�q..4RF1�����c�#-�1h�?h2M�NΖ��#�ihL�?F�Cf?d���x����22�I;Y��f�ژ��1cm�����0tJbYA\�ދ�OFQ��7�J)�~wC���ʶQ��ݔ@�'��N�~J8|ݎd�|1R�ds�g&\6���_��R��uIL��	����Vo(D���Ib<ݐ+&��5ʭ���@6�	��[s�0洵�́�����#��s���.��l%���Ͳ`�G�+|,��0̔������[:L��O�&��ɂ���}�t_��Eb67�g�:�`���f��3�d�!�1��G������`�7gЩ�`m(��P�6�!�=1� #�cҙ
ևA^�.Z��.���6��y@��jR��CW��Ť�@����� U¶���o遟��o���D��'�O���|W'�}vE�E� �&����s�t��:���;��|��@���� �w`���nT����[�K�4���Uܙ �D��N+��@�plI���:�V�pwKl��g��%Z����+?���\�1b�;X����0=�e�տgT?��:��A�:eT�&`n�F�7�e%y;�w(Z���D�晏���4���fT �3�L #C�.���C(vr9��j!�h���W���&���85w0�ٜ������L c���9���h"?b3x�#ps@�������T5�:c�h�}�s�����uQ�X?�g��t�������\g$-= ��P=�$a����gKIħt��Q\�aם�`�Z��P^n�t&��º��vb���[���|\��2Pg���ď�@,����s�N{�V��9�R�x�
lAch�DTJ���j8ω�r�ՄuW�<�7Ν�ヴ6�;����s�rGߎ��f"_ufs��YБvP�~kFҾ�u`�輇�G.�v.����>vxZ�,�P���/ �I::�g��h�K�U�]4�.�W���c�tjea[�]�:6JG��y�I�]z���W�|�0���[�
:ٯL�	����4���+�J~gj��2j�5�&�A=&M�ҹ	���YGN�T�y�;�����.��^����˨�q��H�/(,W�:�������Kg :��� �;���%����4�{Ey��~g������h�}zڭ6p��Y�Ǉ����/��gI�=��u�z���P9,�ԹzT��:���;9�!���}F��f��Y/_�ƾ\�����o1���13j_�s�$G��׆tm�	6n�/�������	�	�;n��߮�ʬ3�4􊦗��0����|����w�J�fC�h����w҈� �e��R��r���zÊ�~S�FrLb�U��%&���%-��ۀ�����)�=86�G��
��C����UY�u`GC ��;�O��s@�b��'ԄouXݚ�i%gO:>���A�ͬ���o� �[�di�a��`w+IG�f����%���X���(�WU�֙l:�J�6�F[����B	��u���:�Hd�O�'.9E�IG��>�~�ɑt�8�bF��]�p�, �f�Pv��&���O*�	�|�y��	���Te�)I������\P�4b�w�W�hݝ-Go���\Ѐ�p�����'�FT������FӓiI#j8v�ij�Dlh#�NT����+��k-_�5+bk�xa���UG�N���<~U��{2���3��Q��o�#�*8[2�>�-+[/#�e�K�hL{�8�����06bSv��oh"�eo`�'��oy�j�	`��7�c�����{eFe8�x��+� M�-��TQ�h�d�d��%���3j1[Z8bGlࢿ����	���Ί���A�;�Y �����]
|ZG �h�I�YI���p:C��QPu���b�b����
>����v�B�Z��U@ ��hoe�h:w��W��N�R��ӏxC����nYd�>�[��뛆�@RJ�=c�v�fW�:\�&�/�S��H�E7�dVі��)֌Vrw��ۈ-����S����|���8sO�K��3c����y�'���YN����2#$�c��h}�g⣠m�cw��A��gÎ��i�=j�9e���ɍ���� bs�(������+G��0_t,�kXC�SzNĮ<�'�BC�o���s�蟳E��EK��gC���`��_�]uĉ[쩲9�����M��-	q��lݿ��^�f�sp�L �d��4��|�$l��p���M�Gy� y͒м.k���'�u;v���w�n�}���y�w�W����+Y?H�Ozn�	`�-����'�*���������	-xx���ME	[ˤ{���@¶���h��u��@�&��?�2���f�L���e�>�Oa��͝�OL	7���ߐO�	{Ws�|�aDSF!�#	���#�:����4�o��x�/�&��ޥ��0{[��D��X5d��q�X�iw�4w�8u,���(�	X�X*�%l[N%�=yH8N���	� ��!�~i[�0�G���ͽp�&�4gW�w�V��U���7�.�u#K�n���P��n�%��i//� Y^��]@�3]<]�!K>��?��IRA-T�蛼d$3#�C�W��2��ý���SJ�\X�ri'�#ߛ�ƪ��}��9�"���/='\�a=�?zq���9�"N�{p�=����~EcN�@�p�$L��#,�B���Q�p���P1�p���˱q�ĂnE'��y�������O���/���m���<����BY�,mo^�&�.،o�5�D�b�ʗ�T#�2+\J�l�T�=iD��{��-��o
[��F��(U���9Қ��&=:�2��5���7�:���r�m��9t��d�ܷ_��,�FK���6�H���)�j}�Q��(Z���3�&Wql���4�\3#v��(VۓF�9+`��*����zv"}Ƨm��ʔ�C:��+Q�>�;Ӱ`v��w��秔%��K���}W%t�!wN%lţ	\�*���mUZ�Y:��B
���V(W,���M*Z�ֽ�8��y�Μ��7�7��]�Z[��@�Y6�g��怯ԵFX��FQ�պ*ׁ3e��y�h�.�/�[H|��Wҷbi��qC�"̇��}8ǆ߫������ZTrX��?�|�zk�A�L]l�[�G�5GF�#�mޖ��PȞ�F�GX"�����[#$���]߱(�s��������"}��h�햾,�|q�8�0�#��'��þw����h]v/�iV=��|�Jl���j�_���j���;A�Qj�k�� �� *��P�P�\��I)sNu�vN��lg}FHTD�4Y/{#	[���H��V� kcPK"׻̍ĥ����N������;��ø�K�sE?�+"�K�ww2��map�;ٖ9�\N,�M���������:i��d�Ѕq]�r�hD\���c,FDWD�{�CHW#=;+����U�����u�P]hq�����R-���,�d!y��.���R�g��м����6s\���&ݒ�z1AM0�ǵ��;_\�Tu�?���ԋ�L ���<�+�~C��'I)�����a��L�zs���B	�Ս���ߠ�3__��z|Euz�q��r���Mf\�De���&��0}E�M�B�l`�v��W&�A4�s���ՇZR��!���/�T�Q���;`��8��DVVrϫ`��C�����*D�Eت��w�� ku��U�|o���zM;�<��x�=�#�YP<�7ض�&�	`�X:� �(!�b�����!��ҋu����׀'z� �u��B�ӂ���rz|ޖ�hi�;�ܟ�Y��@/-{�f�8�k���� �#��ߨO!���nڽ�ML҇��������gq5]�Ow�`��7�P{���y�IytN�f찲�{�� [����Nע���*tꖂ����*�X:���B`!��\0�O�R�r��x+���']�aT\sbdV� �xP��d�!��5��o�f#�1,�H����$�ж0����ّa���)���.A0���[���z#� !j    �+�V� fZ#���{B�LZ��8G��t��I����$�ͬ����f�D��ϗԌ�1���.��bf��Th��g'D�Ԗ	�~������8���	���5�+����|t��y8!'im�ii����T��q5�L��^�a�B �2'���}�	�7I�Ӄ\B��Wh�2���&��(s8�D�ؔ�X�㽂�t�>�ro	1*iQ0`����yuo'�&�����S�T�IE����a�oo~�:��X��#L?_�����7B�v�������ͷ>>~�jF:���Q�'���[_�N��8��aeRb�"����x����
��jb9�EE���$Do$�c�MGMo'H��8a��Z����kc
����&xi�5��Z��6�'��@� �+n��6U��4���0u����:%@���П��-�#��<�6��ݫ�}[Z������VBX�׍�N��
����$�G�����Kp�	��!���K�~y3@�����quM�I�����x��	�T+W1;��'���0���e��W�N���$��wM�l���*�V&���vz�AW����痓�<��t�<G'>��v2\�I3&4���!��d��;�Q��}����V=B�c[��Y�,�#;���YG����t586����	`�`��f���ӶB�zp�j}ϋ�%86���7,��)�#�ǩ�<��7	.N���>�U�$���~��|��#�,��������<f+!�n9�[�sٿ~�-������V&��8cSu0r��x���0�X��5�o��t��mM���Gk��Oظ�~��^c����|�}�ł�i��N��&����M�Q�y���i�ݗ�}�]�1±l�����oM��dѼ	��ǧ�ut�o����+��au���{��� ��uy%�\U/g�|���𻦕��[�q����	��4{�8Ձ�#N���A�	@��� ��&8��ۦ"�@���j����
����_���Gg\����2OC�//���_^R�Á����%sT��'�P�j:��N��f�,\8��7�h^]S[p� l-֩>�S���J�`%�|��XI}3޼���:v,(p[�P�N�l��J@7h:�s��w�0�V�uU!���P�|�n誖0��{p7X��
��H�j�WM�����Mp�$�m��6��t<�&0����i��@�x	NA�ڂk��E�ϧ��^����F���,'"g��a��K'8U��y�������0]�t��b�|��J��s͓^|*z�I�c��-��D���#Ρ_I�/��Ԭ�&�imv>��T4��W0jߨ`�
�Vvn���]?j)bÓqk"w���P�l[����n��bӖ 7��ô�o�V����Z_T&�q��V�����*������y1��=3�ex��zn����W�|l� �q�~�T����,����1�2���^F��(k����(��2��B]?��Ѕ�Q�knMZ��&	dK���r��=^�Uq3�H�a��K��K��Kz2-�<2|0���d�`2R��Z?�o(���[��׻2�/BV�l�p�d�	�����&��d�Ľ�����!{\��C/szfI��#�w��/�J��!�Ց��_�2]�8G�|^&��wH���X_H�_d2$�j8���j:9R3R&+��m���Y��N/<!#[R�us��^)Ō��%K4fdNf�G|�9��ѯ;CT1\|n���+g����x��hF
K>��ަ|����lm���*�۔�_cvb�О�u��9H���{:�
�N<]?���y��I�wwg���`s)��R���$��<��R��Ҥ�H��s��gK*�T����]{Ji�+%qn�譲��Y��PEA-���g�� E� �W=ҏ�`+�.V���s��>�<�Ѧ;�+�F��G�p
b#�c��B�B�
�Q���-��p��r9�1�f�����Λ�`�E��
6��o�|���_��"D�5�d�ų`G.��\�#�nw�/6f#w�� |ٝ,_���c�>]�(�X�Yx'��4����vi�|Fg���?��6>��F_#cp���`�\�^i߂��`��L���꺼|l�v�b��2�E�^X���`/,-����M�*��L8'���Լj']�`S,�젧��eN�[���瞷�`g����_>;�Yw�����7��l�HH#<?��G�Zt�#=�fs&Ό�X]Q��PJ�,
�"��n�BA`DA4�g�-�r�8PA��>'���w��\�P�����a�B�w��pK�6�e���W�PZV���&�j��ǂ(���d��x��ǂ�̪����t���I#.�⻈\����>b����x�t��
<�����?���bٌ��Xo��j8`�|k� kװ**�Ԏ`�R��+0x�'����ɋ�wjv��]��c���v����?D8D3���OLyp����p�T��u�̏��3��"=nȸpo� }~�����p^{uO*�����懦zK�2K�򃪶Zk�ih��̚v���?�P��Gt��:��:��W	�8���;� �^@�O=�5�rȯhˀ�h�����6����0R�倖h���&Aߟ��3�����f��_��2��2h�{�0��"��]$��=�8�z̘��	�ptP��ō�px���w!pr�nTN	�=���8�,�q:���hY��-;4��8hP�O�ʹ������#nL �B8_�bl�Z?[i0�u�4��]�)�F����^����G���i�%I_	��l8�0v�܉�3�#<&1��^<$[ۯQ�t#ߴA	P�E�]�XRc3Xz�5�����jC�vKq�G����	`�!�H��=����-���t�\�<�ί�F�b��p�C�"βiL C�"c:0�xryF<��j�oޞL/���t��3~Y�20�+����O��,��0zPr��&b�3�imߟ^H����*��fQ��/���	`��tw��E�(�'x�K��7�:�#�/V˄�q&�����u��%��6���1������A����It�z@~f����r�Hu�����vFd�I�nk�3� ��8ݝ�ʁ�C���-����!�X:�
V�Ф���f�qMz�=�}����6#8����떇��n�6Ra�NO�"ف��cJ�]����#Y�FEP<. ��v�屧���.�W�g�2�2�a���(���-�/�c�ܭ���h��ŋ���d�1v}���~�LN;��`��Щ�c���zy>2M�6�6�y��@\��9/�ؠ��)TT�n���N{�9�t�ͺR�5���ӏ��_24/��=_#�u�z{�16���NWv�1����p7�|y���%Y̧j�qw��������0��-��=h��p)��@*a���/^2��	l��h�@C3�ϧ�0�ӓ~cj_g�<C�u�zx��[0S��)4�He�'jh�Z.���Jgd���C�)�Uc�ߌI�*Z�Usm�vP�:-�-}�U!�i�����ϒ*���������w���"�����q��L�)�K�A�b���bk��?��7)��v�qM*�[�!�Fp,Z��&
�����8���`�6w�i�7y�i���94���F�ȡ�ŏ^7�����fҍ�����t���qbVr��&���YJj���}]�{)O�-�ߴ�a6&��ۀ
���D���U�3�]���қ��_q��/N-C��|;�ʌ-�1����\����r��N���������|�l�.���|���=`?�����nv�Sýmm���]�<��a�s����M��b��J˽�f��q�,K��ɛ��T�&g����ULr�dq|��0_�Z��#���t�b�FL��3�FL���3�p�������cTi7�#�j6#&�����C�e�������"K�7��4��!_?��z�'{6(    �^o�-mTnoqz���]K��N�NC��*��$7f��R�+��C����W�X8f�^JGR�P���V0&����A� �P�-g�
�~-�z�"l`;i�%`�KqI�	,�U)��2���>.H�#�vs5�z'� ����nL ��0�g?ܭ(��d�o7g_��`h
�W*���~�'����;��
�/?��sS蚰y]|����~<:s�ç�IA�]u��E�jϬ`��͍	`h�ic:0�_�憦 �V�}�s�U+���Z�q���\�!�Qu�YL�q8?�Q�ۖ�%nL ��'�T��+D4`L��f�77���N�]-���z7nli��"�p`ے[�^�>��M����<
V��Dv�V��ջ8*�y6��ZL�n�14�h��/�\b�������ai���1���R�)LG�I��;Ce��5���0'z	��0{� ���R���VG�;��l�O��|��5�z���%�P�A�����8�@�*�-�i��P�w�Lh��ԩ3������E�#_a ���Ɨ	��Z��B�XK=ז�6�lG�֚B^���k��_��_S��Fp奇sSH����
P�����4��q�����'R�����w	���}"=����1d����ޢ{�6��a ]�M� �N?�glVl��AT���]�����WnȰ��ͭ���;�b�	�� ���0��xȟ��`]ݩ���7��5^�����0��Y>�J�y���9�K%Ɇ'���֤ğ���$��$������ΤаA��Y���w�yQǔ3����!_�3_��$b������kb1�2u�ph��C��CS���'K����w�f��=[n\���kS�o'���õ�kD���<�7�o�������k5���S�_M��Ac��m���p/
uu2]��&�>j�	���p+�����ņ�q��kk\�Ik�h/C���&ʿHI,C���2b���
SK	\2}2b�ZH�QY�|�FKA�{r�JDl���������������	�K��)b�W�6ɏ'Y��
�[��{����M&�wz��)�[n��܈-7�2��_L��n#r�������E�9���Ḁe��-�Ĵ׈=7��lgd:H���1G���3N�����qb|5,Z(�^��8��;b�u��Ǣ�,j`[�"v�ؒ�=Wf�����r	��{<�ض�nwV��=�G�c���"��h��I�A]���1Ѿk��k��ީ��7=kGlW�
��e�2�?����:�ñ�Z)�X��"f&�{94.F���?�&]u���X���V;E�Ee��u�Z)l�$�H��ӆ��F{}�����>.���C}Ć�z���p'L�%�;#�0e���J�-�&�!yFdQ��f3����Y5i�U � �Ԏ3�o��@��)c��2��c\�9�	�nw��A3ڡ~g�J�`	�u�F�ΐ�p7jD �=�����U�rV��jl�bD<M��?x&@D4M�Pzӂ��iDih��#=FDDhDk`�'�D�hX?{n�Ҩ��QE��᜔56&�i=��$",��s�	ǠY�F�󅨳 "^��ynL �Rf%R����W���}�/V��?���f"E�gD�����/ %	�72`��󑞑#b4�����g�i�����U�!7""""B���!I��{OMX����'�V���j�i|����p���_lGHd\�޹1B(�Z�.���*FeqQ^���qC_�Nt>L�	� �.�|����ᑙP"�2�f��0��2�2j+r'1"",cձ��DDf*�4֯�~�X]��X��������']}��y�'�Ehh�{':"B�m�nL c�y;W�@J��h<�1"PbF��v�"8O}Cx�u3�+:�#�:�5>�s�=)�g� �TO���m�8c�5��H��X&���$<M{��0K�=�����0�cF���p[���C�3aEDpD�����n�"ŋ�� >8�~���b��
%�7����5&���EDp�N��yy#-4"��������iҘ f7�+����:�`�Kf��1]͉/J0�����d�K��)6MP2��~�rI�u�J����/�;l~���^�؞�`�K��Ȧh��Ϻy�����%$��5pM"�ox2jB~ߖf.2���pOO��mOiL #U\^Ț�`}Lj�;=>O���zK0A�}Ca��1i��UJ��QsF��1���N���/q�ulX�0�����J�4�q&��B�մ0��ͤ�]�N�I�� �X����Z*�w�&��Qy9�H�z��JP��!�V�65&�������m�k`Ж�������=f1���$s��V�����wtn��ٽo�Hp�&+���xO���YJk;#:����ICa�V�㵽�-]o�uޏvF84	�=�E
�҅��<�7��0�^��&<�4�C���^���6{����j�t�6���հ��/b֚m�xKז�IZ)�F�I������>����(�l��n5&����ȴ?F��/�i�0H�"�b�F��7Z`ٰ���oT��z%���8�����������~8�`����[���:����e��5v'�����j�`������ii4��l��iaו!�yf�3wr�$,ۂ�^ ״�V#�s�d��	z���۳V�8����kPȂ�%N��34wE�	2CmoM<�H�;�287'Cu{^�4��%�jpx7:)C%�*�X���g���=�t2TS}֛o�4 3C3�N�7�ji6剕��24AW'�Љ�z��^��	�Fr�J�b�-x�O�cf��	������1n������dSh�5.C���b�~<�؉�'��024��-�q��]>c�Ϩ;�2��tL[}�2U7|����zv��!E�����;f������|���A����DȠ5�c�V>�D�kSӶRZB	�p5�Cەx�2��ڍDC+^�L��9�d2T�����#r�Sk�s\��$^�����Nd�F�E/>�Ù�-C��� �z@���6G1&�a�3�X�
f|����if���D�s�p��5=bf���ZS�r�1�Y���ۻ7t����'����u&g8��%J��1qNem�rx�&�WԔ��X�⛣�kb~p�ȩ�갆�v5��I��2<ʹ�zgȀs��~`a�	����5����Y�� ߖ����N���p��0`����}%~a���l�N��핤����ԕ��VH>��|��C����28��!g����`ΚI���d���t�z'�_s�՚�S�p��y3�p��yCKn��9[��i���!�z�+j��p;g�������p��І�
�YH�R�g�o��7��旆ۮf��v6x���>�D��DΚf?Ɏe�f���z��|�p���Dng8��/�npg�=��Ρzz�k�w��~��!�q��Z�|�)#�ݝ��t�:���Y���^��8����.
p/����d����d��5�_|�.֧{��
/�і��;�7�����LF
��qC|��]?n��8�8�f���ô�?����o^�\���3R᳟
��
/�<���Ʊz�-w,�i��"t���^?J�I�Ёy!w�#f$�Ϥ@M+$]�p��_�%#e^�)��7.9�������|��1��R�n�ҥ���u�u�=��lxŷ����zo��ۮF_`����[�
�zE=��*Q`�+�g�.��G^a���W4��Lf����g��B�K���U�
��B�gY���!K�v""/0*���	`�>�Fu��-Y��oat(��H��0:��=�Q�%����
�EK�^�[��ȼ��*Z�m4w�����t�{q�~n{�o:��!7w�-0e�eN�����R�OP`�\_�6^7:6��3�=d�W%�%2�3����!��, ]n�E�hޫ�(]`մ.�wl�.��V���w���c�+�����	`Ԙ)�VQ.��?�q�-���X]��F���X5�o^E8��_7�    ��\Ż�8�L���xc�Ѵ�,��\`2-VX�	�޽����J+]��j�==��M��
2����'%A+�0'rA�Q1����q�n����� a�撮�&�ZL�,���rch4]mij�8<�.}��V��䚸L��H�0����[�q��� M�_�[����*t�_`�^��K�/0x�j��aGv�zM)��� �������(�r�+3CF��\/��<
�7�����$����d�j���B�����J��Xoe�jCo���M�t��~
���xWQ�2&��I(�$�Qʐ9�9c��+-�V�un'���� ��`�H���=��
Js�I�����#����E9x��Y�C{���yj[��/�	��b�)�S�t-����j�WW�F�@XŊr�{�ʜI����uc�V��4ֿ���w֞�Ƹ�
k��:*;ū����ͨ8��E�_����OO�3�nC��x	M<r$���j��I�&�e3>=B�>2��ۆ��WB��'Ы����ҝ�����������1=�PA��`�����e��T,pw�-��	`��S�]�%������^�f����{�q�x�����7�#3�C,���q?k����w
8��>Y4?Zg����5�������*pS�\���뷢o�U�7��i����x�_U�+�eF�k�.�.����!�~zT��J��p��y����ABm��&����x���4c�6�	��`^"O!�����xъ�E+�	s���O N�5�}a�x��j����e��i�JP?[6^���&�Y��O8[6��)H�,�����ޟ��
e�w���֑��4���Q݊Ը`�uN�YB^�ס�(<�Q�1����6��;?<��ν�ˮ�i�]��[�]�!�BmS��j�x/��I�3��)��:W|�z�'u9ӹkx�KQ:z.܄���:LX�����y@��P{��%���-h����ۂx?��&mNEP��{:����~lv��p��!�W���i��}���� Y�xAV]��.�̬a��&�.�:���cj���z< )��ے2�<y�ג����1/�;��#�EƋ��y�8x�A��� �Πn����3���O���:��S�ճ4���ِ<*g�kG����]>��c#2._Xh� �N�n�x�����Iڅ&����!r�74�7d��y��.���=t�z�w�W����@�~ ��nQ\�=��V���n*������i����������M���V������Qk@�^��ث��*n�Gs�ػF��w	s�t�s>��Ո�v�$׈]���Ί6b�j�6U FlW�����^�m�[L�3�Èl�s^=�: }˞7bӡ��;��)%#6/��4�X\ۈ�k����%kľ�^߭W3b�Z�ʴ��t\��j�{�"�M��A,\J����9Mɏ�<A����\'h��F�I�.�0n�۵�OTw��+j5.��sO�%Bw��8I�M��)���0BS5�CK�P��}a���$0BU��j_3B_h�{ixGW�_{�	�C�F(��+�X��eӬ�������2B��C���<k#Ԉ�uv�������=B�Pqj}i5!}���,�yD9�yb<�:#j!4�x}G�C���?�)�j:#4a.^~ziz#��Q5"����gl��םh�ޣ��H�IfLg���΋�����ku��3֪�{�U��ڷm��w�����ˎ>g�J�ІF�ı����hl�4�e���H�O��3�YZ��s�&�/R_דBH�k:9��,��9���E�?����O<{��d�>�>4Q��wLn�y�����stMzjZzǼ-���x.M:s��.nu/�S~�D��k0�~1��ޒOWv~�#�n𾝽��*��T��W/��w|��Xd�p��h��C���#�r�݈�5����9"�l\Ea1K�4E��������^���i}D�ٸ���^�Ah�.X��(��̔	��������я�p���I�q�߼��\|Dԙ���i%�Y"zf=�VRά�!o��.�1����1,���{�3[^�]{b�$#�y�H��v�:��u�[�9��6�$s!�T�on���&]���qKX܀�u��R�@��$$1�<sm&aMH��y��",;�ь��tz�b*=�OV��=�D�b��_�� aH��"���@߲$�0��ez��<[dDH�h����)C�n�؈h�qY\����&C�58�±���rRF��qD����n�߈�׸�gH=W�����L����f��}
����2�k��Θ�&�k'dDI�Q�lZ[�r~��v���G��~�ڈ�Q�����K<lcD�ڸ���kc�TYF1��ͦ`�,X/�rD ۊ�U�S�
�"޾�x#�ٔ���)>"��]��ឦE�k����t�=��pGD-�~�҈��qY`�Vx�4jq�Z��s��n���K#�?�H�:J$5htڟ|� E���j#�*���g� �������#���o}�w14�L����r������R�����Ф�c�B?���Z���\�w�lsc��	`���sM}~�n���D�'؈	6❩�r<1��75�sl��b�o�1�Z)|ͱ������R���k�����������Vct�L�н˝����я�15.��\wB�F��t������>0ܡ�&B���c��;]!L��s�oaR���R�I�pr��݉�!���꼆8��j(�ǂR��րT7E���������T.�%� �p)<(�w'*��[2&0-.'Cĩ&7TaD����h�������T�5�k*Р�aZ�U�����F�i�/5mLwT p��U��GG�A�VũR�H��*���Zz9�P"TK-8K���{Z�&����}�Jx7�g�xs�P�:zW���M�[S(������r�0����:!���<;=� �%-F��ň��\Ұ�-�e�ϔ��c������/t�:
\��]�������fd�/hYP��Џ���ph$k��u����~���M��?��j����#��D�nP�=��g�ǻ�	�D!��4���+9n�圱�K�.�����d�����>M~2:?q�Bם�f1�.,&�/�NT7SojS]ׯD��'�~}��Y��K�h>�9�h@h�x҈�,�2��Cq�'�����;ጨ˲b+��{!�).=xH�(��V��͝���Y֯�r�8��f���s�*4I��H+�	7�I�'{�-�?����&�J�Œ�c/����σH�A!�����p�5M�*�o�k\A ջJ�_P��m�� ʌ�4C���wZ<?�L���|�t�_��"��M����7����2�v��[������
���
a�_>��`�{��+�&-W������ΰ�/�`�P{�����$,��k{K1��K�gH	�me�]g!���x�19���c=�T�0���W��ԻR��֒�t��|�N��6��!���$J��ڿ�������%�b(6 ���7#F���+�\�`eQ����-D����R6nX��lw���Qg��r��[d�+�Ӗ�	`xE e:0b^���c�4��nz��{�U(Aj��J�b�b����W����Yh�B�'�3t�$_�yP�b#0�&��Ci�ez��yډ2�ӕQ����5Bn��3��b�a�;�E*� i�>�_W.�G�:ߜ�(���Xu%��>1�b#0��::����&}�}�֜��	R��e���)(݁��]
��/(A�I�"ܑ �"����*��O���Wu�:��AV�VP�lF�#�'�찾�5�FWrl�zz<Jn��I�p>����U�&3�P�T���_7�}Y��%^��2�1/������0��@�:}큚e������ң�������̢���xD�l{}#	��qG�a1L�>��X0��_� �'2y��u@�����)�T3�'ZKK���I��d�������?yoQ�M�Ť�    �Z�W�St�<D\Rc�`�I�����	�k�Kf	�p,%��)گG����l�<�;���l��0ľ�P�!4=r���M^���0`�{1�0o7�6�΂0`֯���1`��J�?8>e2�Z��wb�P� ����+��y���#?X���8���j?��B�$���������	`�B�� ��v#�<��h���L�L���B�h	i7E��/���&�FFy�*��vQ?�L�fq�8W�Ufn`�2b*���˦l�b�DW��	�Ux0�?�p^�V}Ѵ�b	X�|�f%󂤡�J����Ϋ�,���{�дG5朙W���-ou7gG�E���S�[�#=%ȼ0Ʒ.X���?�ZlK!���ؘ�Dv���~G��I�{;
|�e���*�����>��z`Z=���:K����Wj�0��>�:ⷼ�F�O��`�_-q�+1�P-���ȍ�Z�B�B���|5v� P=�v[�T��Z�g��]��P?q��zj�Hӡi��-�:k��/��GZ>]�s0�|�X�mlՓ��#(���� #Y�y�7E"�[I�U�����r��l��6�
`����T�����/���c���IJ6�X�-oY�C��Q�_`��~�*@���
��/��d��i�����/f��9YE��n��� U&��bz�0I�;��2}���*�Da]���S�����߹��b�L�:�JPuqt�4X��77ab4w'��`]o��u��L����ʘ F�F�9���]̜~ǿ��X`lvҥ�IĬQ�_�æ)�[	��[U3ré� ����e�;1G�k���}�n?Ǝ�ûjh{w7�~��8ׄ�Y�T;�_]I����F`��%����	Nt�YN�i1}�v�A�WfQG�����flL ��mt C���>l���/b�y������j�9���]%1�'a�W$��+�����+|eиx���ӥ��|�dg�<�lOF���L�	`,e�Z���V$+re\����a��n��/#@�6lLS{��͏������we\ �s!B~��=>����@9��[F�1���F.䢥?�e5��Xn�<�g1��8>�	��q��,TMZ���]�b�������$ˉ
.a��&R!f��_�4]�вB��H[����!c�o�1�Ǘ�jTJ
�ҷ�Z�KIX�Χ�1�K��2Fz;5c�����P�`g��6]�p��O��~�����`��y9�<ˡ����$�~��������~'0&���mO����c\���N7%r����_��xtP;U�$�2ČL3�as;��@Y�C
�A2f ���kĸ�m���-����l[����%�������������^g5Y��[����G����:h���iɸ&�����o�\�����k� �^��U�D��_���uV��N\�Op�Z^��cv�j�hL�ج��6pð�����K��5O�Dr}r��z�;1��6q��e�TK��*�����x������|>L�x:���|����G�����J:6gc��Tw��Ud�|��}�M�rgP�Ų�D���������k�W�$�x, �Ljs��Sg� ��z�M�HkO1�6`XlsyzX���WA?�.��H�~cdl��h�4�;��Wg����Ӆ�x黟R��g�n�\�,G��6��В3㫉�
�k��,�/7tQ�&����㪰MBW/O���m"�<�OG�gG�t�Ѥ9��/���v-	,	�T;�l`�Eҷk9r��E�f�cL ��:-c�c���0���=3u���� vz�`C�Z�5ϲ��� �Ui_�$ޟ~:
ugu��49\^��p8�S�cp�tq�����-u��'/��Ļ�z���47��յ"f��g��q��2�vy"�&��z�z�̙�m#F;>%��<tⰻq��� �l���`P�~ή�M 0S}9���>G��i=~m{C�F����uT�D��;+��'|�r|�a�o�0��;�R�e�({�({���z���z�)���}ŗ�gʾi�ι��Ѳ�$�O$�¨�����y~Kb�-��-��Ҷ���`]�����k���e�z���j3iid��P8�#�H5�GF
_az���`��NǷðu�ϙ�&I8�I�R�w�i�q�7���	j�?����u<"=���Wz(}���0�J�C+衄\��.�ZA��1������,��e}Si_�֦�AC�����$�=�K}Š]T$"} ߓ��ë�`
B�m�����x�&��r6��xo�6+�bT�f�Ӵix�@�_�76�U͊�W���G�6.;EBU�A��f�D5�=�� k
ld�B�.�:�ą�h�\?�U��k��gghJ�G�������?�	����Y\�lvG��v���x�e�=�g��r)}5w�m�I�7���DѪ��n#��9Q�F��,:�Y�#��hGd�BkX����m�YĞ��o̎�P���J"�;��Q���T>py����eDlQ��g��Fl�\֗l+�8lF������DM�������%.��{t����RYG͹W����ԓv���?bQ��Ib/�y�5�H%��Z��M.W�ߝ�q�b�$�:���b
� Ual�q�tZ������ݣ�7������rY'U��Lm��q�"�g)�����'Z)������m��<gp����kG���Ftg]�&�i����`����=�x���x>���D��o?�r�_����/U}���}'�.�ᏙR������/��|~>=ъ��7��G3]_�����S���0B��>�F$_PE.B%�k�N���yR����F4q>���8���_|/�X��d��@^\�a���h�ب:��r�.��W(i`h`X��.�a�
s��&�:ƿO�"�,c��a]�٠bH�{?:-ߌl"����H�5ÚPޟ$�������+K1�Izs��k"�j�VV#L�O�Ƽ�5Q�o���������O10���$�H����/�U�>��=�S����6\#�.�_�W-"��^N+���ږp&J��(�L$���i\N���p*J��C��	ǡk����ښpl�Z$-��͍]�G�o�ad܃J�A%Y�S�O8�$;V��x�P=(��iL�.�	'�hAc�|�oR ̉KK8{�����c���Q��<0�a���WL�Lp�
u�h'�隻���WS�.������}�q��rO8$%���pHJ���p^J��}dE���O��H8/	u%�n�J8�$;���"�
 �Q\jh�:�����Y]��؂���$_�IPV�ʖ��e$A�qv��$���p�%�d�������k	�IYO��w�Fٯ���կ�'{�&	�g�7τ�K���Sc��4�S���a��w���&��F�x���k��s�NV�H���>Ɂ��c㆒&��&P<�͑c]���,�Ƹ������	��I�85,�ِ2d�߈�I�"Mh��ˇY9�ހg�&�g�$���(�:{��p>�����<�6!xTSVunn)Z#۰~u��7
W��ơ���M�6�i9����#�.G���{�Ҙ Frd��5�T�ol#{��eŤb\l��RK���/�l�ƄƼ�G��B�WX��۶n7�o�V5�H�� %a3W�I`p> QeF�5IF���_��@�����Pgc��;ۜ��/���]qGG�5&��5�4��w�O߁G潓$it��\=z?��G�Se^��7�;�G|��� #>Hc��[g��*��4��j�OH��w�b�w?��4R��Z9���}�l{�g��)oH�v�5nh�t�=hqV��G���n�(��ֿ����ڵ��B�@�lB����LN��k�r#�d��h;�b
9_�1�!fP� +�G����u���M�6.�j��#%�zC�7��u�ۉ�yq�i�޶�3��[�v���5,.v�L��6�m$?z�?)�0�,{�~k͊�Ȣ��Eld����H
}F�dq��\~7n�    �,bs�n�������g���z��_�R4�)bok��{�a5Tײ8wW�ۇ�g~��DD7c�����7�<�.v��9��F�/����#)Rb\N�(�M*����f�_��m�5�Ғ�"��t�#dl�/�X�ٝu1BЯ��wvOW���U�1����Q�Q�?�ސ�9���05ѐ�~$�w7�SՙE�7�S��;�`9w�S:������:l-��fL�:׍K�k�W8:,�o��t�M�4rh��g���}ڐ8=�~/����w�!F��i]���&�-R�#�NM^��v�Z5�T
34n/L��1�V�ډ�ķ��@if�AMD;�#��r�A����h��A����jh��V������G���X�>u��~銱�b�{�k�"(9��)=�V=Rxka�E���uADF���Z���tK�n��g��A|><�d�K4�uh����·݇��ϧ߷{ÚH�����Wa*k�nh��H�mB�~BQf�4������Kmm�gY�ۧ��;�T�|�Α��~l�^8�Ejuj��5�p���H�B���c;�{���|Qj�32���^��ڠ���μ�9�`�g�|�7�{��J���ս��G|&Us�y���3#P��
4�.�|�@�]�V�:o�] �d<���GK�4j��wG�I�	�b�r�`0X&��G~�H0�P�0&�V,��O�ԧݭ�`h��x���L���1C��}k��$��p7t�+K͍��F�`%0V��q��tr��1���:@�����%	��,��)+�JP�y���T��P��(�֭�`%��g)�	6���c��l�	v�z�:uE��,Z	����5AԲ��C~��`-0�Z�/�4�,�b`,b��k���T�H:�^���}ҹ�C�o;���bg���j=�k�>I{���\���`*bޠ��~���	g}ch��C�1ܽ�p�7�13'���d����!-����$���1��4����J��	4������Ϡ/���ɋ�7*���C� a����}|�Ί�]@;�k�U��|�L�uIk)�Z��=�����ƨB�B�Z.&u���Ds}�����ۤ�Y���	�50n�M\��i�l"�9$����M<h+��������z��8ң��|�Ip��6���&��n����9dE��,�t�<�<��������!R�����p0&�y�#~����0�ns�/iKA�[�2�	���c��e,�p�08��mzĭ¸�z�_3ph�#F��`�J�m%x�3'�&�ꚧ���������4卣�TP���`N8�a�	`�l&��F���ik�2�xyÜ�E@R��.a3��xHc2M�unV IV�w�5vh��U�=rx������z�G5�'߄nL �(G�̞�M����.��N/�U�Ϥxy��������t�T����fY��ݘ�/���?o��'�
8kt�I�Z��m��%��	v���э	`��|��)��Z_����^��5��ʒE#p2�t:�%R�oHM0��j�H��l��H0��Qj�p
Y�$d&����tD�c�,nOl6	��-��X�8���_Mfb1��g�c��u+�-��`^[��4��v%X���^�I!^�U�;��ݹ�@װ�5�r�0T�Nx9��lZl�a���yj��_���E���ڿG�~�7z����h#�U�*a����,c�+�|d㝱�� Sc#X�8hL����ȇ��U]m��� �{��לvn��u��mT��'j��/��*��>�ه7W��0��"x��q��o��$6��"���jE1NN7-c���i�8�o�ӈq���4�9N#�i|s�F���_�Sa8q�H&�yU�ߕ1��j���(Ukv�&��Z˫W$Uk{���|T���uF5@���C�H���h���U?@��vN7��q��[ɝq��� �q���$�q�����3��v��;�W�����2&��e�?L3�t���ݑ��W�c����+NMtĲڅ�]Iھ����$��7� ��U?Y��|-��o;����:��څ�tH����3�M�E��F��Wwu<��N�=N�nA4c=�ja2'�����o���S���%�ǑS/J�1I@�(�%s��8m�k����k0�w�I�6b\��㶽��-4H��ȔL�N���?�l���P��je��	�����8�
��;��6��ќ�|��q�I���8�j���U�~��"�5{���֪n�3ef���s3��j57C�N?�&�������{��q���bO��渲{���=��9�\HQ c-�(�lHL���=����;F��wGjH��OTH�~pf\=�f@�5��`�՜��j�����Ir.Մ���҆6��� �9n2�|�Z�)�	Mb��r��>�����w��2���[@T�&O7� �Q\�ǌY�lz�lj�������T���v���Y͘'~.��F��h��_���9�ĝ&+��YF���1���:Өq��|����p�&��W����ML����_�ch2�*ʇ��ls5����{^MR�mH=:=k�oX�aX��bV�t|z$�9#=�)a���P��uw�{"sÚ�ئ1iyk�n�\n�9�d�lKR���NrD87,o�K$a�-���bh2��=�罹������XZ��=�_>���¢�I�cּ g"�����F��/t��$R����)[��o{��{цz�{uMD�O��ξH�+p���.��q����5��0�
�h�ߥ9�� ��5ˑ�6_c�*K:����.�4�����n�?2�N�Yp�ܼ�û�b�g|��8zX�{�j��j,L�h_9�X ����2>�*l\�����j�l�o�G���$�_�
DS�7�Ύ�|��hm�����-��̓s^0��o���;���/2`���S�����.��PSJ㶠�0`���I�����7�($�8����Â���ta�0I-�Æ.���OMg�X�-ih�Q�f��!���zZ��|�ɨ#��P����'�A\�o�lF���;��	M����#���MH���:�F���]�i�B�<PF��U�C|-[w'CZ?�'*x%z�+��+!�ӛ��TMؙ����#!�䗑���a���R����c<]=��$A
��]�^!����o�3Q��\��J��]�`.�����uK�{p�W�|s�z�����a>�-N�>��"��'FpGQ�F��E78`�ΓO��osB�Tn��!�/B���� =��Cpg�� e_�	�����瓔�u�W�n9'
S��_�+��������H�c�Á�0�hR��ޜ#���!�������$������ȵ�=ۙ�Gҋ�<Z�p�w|�����O�g|�u���-2o\�Էp���;\���
���ۯ�ס��JOt�0^�y���`�����x���� vX�����wg;�١��2��&���yص�#�s��{�뀕{1"�u)`�A�*L�ק�7NcG�W � `��� �g���4�M�&&����5���n�OY0~/଴}h��O����i����6� ��|8H�*��@�Wm����C�����oa��'�֯{5]�a,���f\r� �T:�����"Ƙ ��˃�Ez��p�ou$����xԊ%wG'�#�7�8�(q�m��<�p֗��O�UD�ʵ�*[
����������p�vy��|����#\��c��>���� .l-����:R_꒦�D�����\��������h=�ד�RLk�֙�Hs�I��U�5�^��}o�:S��!�2�75�?��_�K�֔�(��В���I�Z���h��W�η�u���=mDkP����R�G��!x�XD E�("(��e�@��
����:,��lOa����5]CDE�j5��5"z����E2�Y�c����� NBWDE}a����QS�-z]V�'vʎ�]�Ym[��L.��'^[��&����iЯ�q#<�#��&kG�s    ��?_��$!��#����k�'c����Y��c�����Nm��uֱ�z�� ��	�࿬������ە��3���iAg�0S^�Em e���P��V ��v_{@�3���M2f��Iy����]�M"�Ț�8�������h3���	�M�0"��{wpC��$����fA�/vfCפ�k���">.W���{���`��{F|Zҽ��j�;�bė�`i�mTeZ&�L#�&	�0O�󺹽��7,�=�^�K��c���7���y�q~c�ڤ��Ո�/��NqD؊v0��Q44,"j%j�-sdT��ҫl��6��~F�Llڵ��r�H{[�xvt��y2z��|���2��b�\�~�Ӟ`�@�!A��+�e�Z�#}�C�0�AqI:B���.���"8t�K�*�o���Z�К��z}§���Q1�M-�[;����$���(��<����׷���x.o4��?a��?LS��#2�_���E��EE"�}�)�|9ΘGRnaZ���3�P�m��g#�R�s��1)��}`�L+p'�!"������8��86��铫G����߈��vm�FQv��������	j�.�����Lu�&�Z����Hc��u��O ���H�&�O��ξ����c��������}[�&8]g��*�q���n���&�M@w�"/L��ñ|�.la?5O~Э~p}��y���s�(��`��`&a�{���"b�xu�5���Ki��]P)��̒"���jR�����Fj퉗\�c�V¢Vd�9"�����/�X֎��W	�[�g�W�K�'�NVB�Z�-�-C�m���E8�yʚ�n�%�Wbx�q� 4�U�'Od�	L]�_�W^?��G�0�f2?i���K?5��9}k;�����������:�L������:H0�'��`�O������	�~^����g�h,_�I����O��n��_����+�ȟ`�,	&��ʞ�5�ʯ�t 	F~��H�s�Ф1�"���t����|F	V����`���=�:<jA�AJ����n^���s��l��_�m2����	�~HG2Ú�$!䤕6�g^��S���bL�l��?�������F�W�v����Z���I|:�`��=i�����G�'�ٓf�����z��G��L��������%,�JK��_�(:|��%�����g器:|����,�c�M���1v�T���w�ks��D-~�u%��.$*Iky�6�xn�3�#OM0��Ǉal�v��σ�g|&�r�����qΌ���O~e�de��ș��YR��tM(�ʇ&t	�$�A}Q߼u��'�����T*ϰ��^H�:�S�5�� ���{9{OW��rO����T#�;�U3��'�"�� �NV�'��WZZ��]�Ǘ��lf΄gB������F���ԑ��HH�
�<�#�������:$97��C�
�Rh�ӽkRMp/�t�cv��B{�+�VKp.,^��}hR�zŅ#���F�͏��]��f�h���o�������	��Iǭ�+T��7�`��K��E�����#��E"L 3{��T��F������k�L��Z�B��Y�E��������"�<�6b�X��[K�ߏ�{;W�Ɫ= ��yN��{���t��N�J��mN�$���@Z/���@Is�n����@���/���"��-�����0�ӫ迎�����w��޻rz�畄�=���N���q���?�Ǽs�q�Ǿ���p�[���+�h�OΧ�B��u��?����%�'�z%8T��Ξ�M,�G�Tڐ<_�O����)y��{�& ��E-�	��I�ewG�I]XS=Q�H#<������机6��
ڻ����	�������{�&����}�k���i�XD�sr��YO�N���_?f��w!Ê�>��h�
����D/t?�/���XZ���w��?�ض�2�c.*w-�XR�g�Op�����ԏ���R|�N���sq=ɿ��E�Z�sd R����b�*�ލ��jŐϸ����J��|:aV	�;4�ugd�.��#��������]
�Z�2����q�����×�ɖef��O��S 悀��7n,sѵ�52׿�&�]�a�˥>��GZ%�Ӳ�Z���@$�~�2̢�����ͥOȥO�8���R酱�#-��ր�9X���{*�Sq�Pb��g*�sPR����\z���G��0��6;��TLH�O(>����������d2�,���d�Yr5<_��<�͒��������<;����o���c��Jcu� ��i�P#�G�AexZ�K:*l��%7����fx[��k��c��ņ����Dkye�Y삧Z��+�.�?�d�V��2�4Mao����%�`�N�K�i�g���s��9dD��!�0/;�/�F��q�映H��!�҄N]��!�9��vΆ|^���;�אk��V��֑�Ò�։���4x(�ې��;fg8�bG�
l�eW��sy��f�V?�/����5Oc����
@�/���5��kd�Y�k��<�H�B)��t6��r3�Б�%kf1���
VM��w���9>��\�j*�$u���/X4K+�J�S�`�X���`�������[�H��x����B6N{�Y�K�t,��5yZn��X�8>�łD�kp���-�o��B\��ںM<1�B�3��` �&�CL�/ZH�����m�hn�;��kb�tsx��G�����9
v����^Ib_,��r�>�R�lǜ[���_Pj��"?�B:״�S��" �"�l0����^;{c�z@�t_�:|���>��(b`�����P�P�^���3G{���Y��,����wg�Ĕ�2Ϣ`�UPj�J^��[�����;��B�^U�?(ލ#e~��Z8�7�*p����CxA�r6P{���������>����59U���nd�%�����[�k��s@�t&���`����pwG��>6�;�(�8�Z�O�Ό����~��s���">%�;X�,�5����AAu��P��`Ѽ�ۧӋ�_{oķ��	5gx	�pv���i���D|Xou�*����f�^X_�����Ŏ�� 1��%L �ײ���H��ea�����?ƿ�1�I���;������i��^�W9OO��r��'�$A6+�1��٤=E/A&	y��"�B��]_xg�_W1=8� �~Mz�D�y�}ƜpM�&�b��{�ZƤ�Q�˘�����{�La�u�
�����-�(��;m�_�0�������/b0(0㗖��_`�_������
wC*Re�"���k$�,Q�0*H�ih�-��l�����5>�<��������M
�r��Y�vT0���=us����p=�9ίr^0�w���y��U˿3sfnyc�/��x������-��&�о�I-��)��ŵ�8%�c	M?--�SM���̈��)!n~��M{(�Ր����q��YV�g _�>K��X°��[��g������Qn˸ۈ�)�����i�rbp�3����f��~��'|2�H�8J瀯mXX�ߘ)>���i�O��{�W8Ԩk�jAd��$��#���A.��\�u���6g;�;�&u��s��@�3�aTP�X�]�FgԾ?�] J��=)�������(({�F��rA�c ��9�0�ZUHM�g�0e��_F����0��'��2��K]PF��ڿx�?yQ`U�K+R��kWMDyavo�B����p�zT�>��� ���*�윂���M
qN[aP��F]���1列���
*��pA��.�
��[͟�;�5!��u2���x�=B��V3��G+������>�mѾ����왝i	wE�s�%ņ˲��őՄ/(:�#����kj�³��x<�<҂��6��ɚ�jPwx����!���U�_>4�Iv�]��pR3��#��������N{]�>=.��I���<�Η��լ �r��-sx&�����K��|�x�� �  7(��Y`DA��
!��.���������}:�+�������՚�����z d�N"lg�G���9�<˱�@�#(�l|�62k^�-��]hB��G�]h"Ѵ#�4����x|\B޼�s�����8
]��6�	��#�,u��n�u[ɸA�u��_׺���0V$�������7��G����g9����T�.�
�˃*(o]�����u��˷7?�_|ذ�K�3��P�Z�>1�ۑ�Ј�ӝrB%�F/}��k�p�{�����+�m���^�/�p����.(-̻�{���"�^���z��:��

B�k�Ug��$�A-5(	]!��^��ܣsޒv��Og턧D�iKp�6��V��7�����D�	}øs�nK�WnR�KJ��
{���%97��p�_�����?��?�?d�N      �   v   x�M�1�0Cg�\ ��ɧ!SƊ�Њ�RQ���ITl/O�|�,�j�PɃF�Q�m�T�'�߄m���y|���=���
�P27VBŐ�$�k�'%���KNŘJ�WU����1;�L     