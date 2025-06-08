CREATE TABLE tb_province (
    province_id INTEGER PRIMARY KEY,
    province_name TEXT,
    created_date TIMESTAMP,
    created_by TEXT,
    last_update TIMESTAMP,
    updated_by TEXT
);

CREATE TABLE tb_district (
    district_id INTEGER PRIMARY KEY,
    province_id INTEGER,
    district_name TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by TEXT,
    last_update TIMESTAMP,
    updated_by TEXT,
    CONSTRAINT fk_tb_district_province_id FOREIGN KEY (province_id)
        REFERENCES tb_province(province_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_commune (
    commune_id INTEGER PRIMARY KEY,
    district_id INTEGER,
    commune_name TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by TEXT,
    last_update TIMESTAMP,
    updated_by TEXT,
    CONSTRAINT fk_tb_commune_district_id FOREIGN KEY (district_id)
        REFERENCES tb_district(district_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_village (
    village_id INTEGER PRIMARY KEY,
    commune_id INTEGER,
    village_name TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by TEXT,
    last_update TIMESTAMP,
    updated_by TEXT,
    CONSTRAINT fk_tb_village_commune_id FOREIGN KEY (commune_id)
        REFERENCES tb_commune(commune_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_gender (
    gender_id INTEGER PRIMARY KEY,
    gender_name TEXT,
    gender_description TEXT,
    is_active BOOLEAN,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE tb_property_type (
    property_type_id INTEGER PRIMARY KEY,
    property_type_name TEXT,
    property_type_description TEXT,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE tb_status (
    status_id INTEGER PRIMARY KEY,
    status TEXT,
    status_description TEXT,
    is_active BOOLEAN,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE tb_customer_type (
    cus_type_id INTEGER PRIMARY KEY,
    cus_type_name TEXT,
    cus_type_description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);


CREATE TABLE tb_occupation (
    occupation_id INTEGER PRIMARY KEY,
    occupation_name TEXT,
    occupation_description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_business (
    business_id INTEGER PRIMARY KEY,
    business_name TEXT,
    business_description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_lead_source (
    lead_source_id INTEGER PRIMARY KEY,
    lead_source_name TEXT,
    lead_source_description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_developer (
    developer_id INTEGER PRIMARY KEY,
    developer_name TEXT,
    developer_description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_project (
    project_id INTEGER PRIMARY KEY,
    developer_id INTEGER,
    village_id INTEGER,
    project_name TEXT,
    project_description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    CONSTRAINT fk_tb_project_developer_id FOREIGN KEY (developer_id)
        REFERENCES tb_developer(developer_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_project_village_id FOREIGN KEY (village_id)
        REFERENCES tb_village(village_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_owner (
    onwer_id INTEGER PRIMARY KEY,
    gender_id INTEGER,
    village_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    remark TEXT,
    status TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    CONSTRAINT fk_tb_owner_gender_id FOREIGN KEY (gender_id)
        REFERENCES tb_gender(gender_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_owner_village_id FOREIGN KEY (village_id)
        REFERENCES tb_village(village_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_property_profile (
    property_id INTEGER PRIMARY KEY,
    property_type_id INTEGER,
    project_id INTEGER,
    owner_id INTEGER,
    property_name TEXT,
    home_number TEXT,
    room_number TEXT,
    address TEXT,
    is_active BOOLEAN,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP,
    CONSTRAINT fk_tb_property_profile_property_type_id FOREIGN KEY (property_type_id)
        REFERENCES tb_property_type(property_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_property_profile_project_id FOREIGN KEY (project_id)
        REFERENCES tb_project(project_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_property_profile_owner_id FOREIGN KEY (owner_id)
        REFERENCES tb_owner(onwer_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_staff (
    staff_id INTEGER PRIMARY KEY,
    gender_id INTEGER,
    village_id INTEGER,
    manager_id INTEGER,
    occupation_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    "position" TEXT,
    department TEXT,
    employment_type TEXT,
    employment_start_date DATE,
    employment_end_date DATE,
    employment_level TEXT,
    current_address TEXT,
    photo_url TEXT[],
    is_active BOOLEAN,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP,
    CONSTRAINT fk_tb_staff_gender_id FOREIGN KEY (gender_id)
        REFERENCES tb_gender(gender_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_staff_village_id FOREIGN KEY (village_id)
        REFERENCES tb_village(village_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_lead (
    lead_id INTEGER PRIMARY KEY,
    gender_id INTEGER,
    customer_type_id INTEGER,
    lead_source_id INTEGER,
    village_id INTEGER,
    business_id INTEGER,
    initial_staff_id INTEGER,
    current_staff_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    email TEXT,
    home_address TEXT,
    street_address TEXT,
    biz_description TEXT,
    relationship_date DATE,
    remark TEXT,
    status BOOLEAN,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP,
    CONSTRAINT fk_tb_lead_gender_id FOREIGN KEY (gender_id)
        REFERENCES tb_gender(gender_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_customer_type_id FOREIGN KEY (customer_type_id)
        REFERENCES tb_customer_type(cus_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_lead_source_id FOREIGN KEY (lead_source_id)
        REFERENCES tb_lead_source(lead_source_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_village_id FOREIGN KEY (village_id)
        REFERENCES tb_village(village_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_business_id FOREIGN KEY (business_id)
        REFERENCES tb_business(business_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_initial_staff_id FOREIGN KEY (initial_staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_current_staff_id FOREIGN KEY (current_staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_lead_history (
    history_date TIMESTAMP,
    lead_id INTEGER,
    gender_id INTEGER,
    customer_type_id INTEGER,
    lead_source_id INTEGER,
    village_id INTEGER,
    business_id INTEGER,
    initial_staff_id INTEGER,
    current_staff_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    email TEXT,
    home_address TEXT,
    street_address TEXT,
    biz_description TEXT,
    relationship_date DATE,
    remark TEXT,
    status BOOLEAN,
    created_by INTEGER,
    created_date TIMESTAMP,
    updated_by INTEGER,
    last_update TIMESTAMP,
    PRIMARY KEY (history_date, lead_id),
    CONSTRAINT fk_tb_lead_history_gender_id FOREIGN KEY (gender_id)
        REFERENCES tb_gender(gender_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_history_customer_type_id FOREIGN KEY (customer_type_id)
        REFERENCES tb_customer_type(cus_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_history_lead_source_id FOREIGN KEY (lead_source_id)
        REFERENCES tb_lead_source(lead_source_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_history_village_id FOREIGN KEY (village_id)
        REFERENCES tb_village(village_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_history_business_id FOREIGN KEY (business_id)
        REFERENCES tb_business(business_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_history_initial_staff_id FOREIGN KEY (initial_staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_lead_history_current_staff_id FOREIGN KEY (current_staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_call (
    call_id INTEGER PRIMARY KEY,
    lead_id INTEGER,
    property_profile_id INTEGER,
    status_id INTEGER,
    staff_id INTEGER,
    purpose TEXT,
    fail_reason TEXT,
    created_date TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    last_update TIMESTAMP,
    CONSTRAINT fk_tb_call_lead_id FOREIGN KEY (lead_id)
        REFERENCES tb_lead(lead_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_property_profile_id FOREIGN KEY (property_profile_id)
        REFERENCES tb_property_profile(property_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_status_id FOREIGN KEY (status_id)
        REFERENCES tb_status(status_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_staff_id FOREIGN KEY (staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_contact_result (
    contact_result_id INTEGER PRIMARY KEY,
    module_name TEXT,
    contact_result_name TEXT,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_call_detail (
    call_detail_id INTEGER PRIMARY KEY,
    call_id INTEGER,
    contact_result_id INTEGER,
    call_start_datetime TIMESTAMP,
    call_end_datetime TIMESTAMP,
    remark INTEGER,
    created_date TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    last_update TIMESTAMP,
    CONSTRAINT fk_tb_call_detail_call_id FOREIGN KEY (call_id)
        REFERENCES tb_call(call_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_detail_contact_result_id FOREIGN KEY (contact_result_id)
        REFERENCES tb_contact_result(contact_result_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_call_history (
    history_date TIMESTAMP,
    call_id INTEGER,
    lead_id INTEGER,
    property_profile_id INTEGER,
    status_id INTEGER,
    staff_id INTEGER,
    purpose TEXT,
    fail_reason TEXT,
    created_date TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    last_update TIMESTAMP,
    PRIMARY KEY (history_date, call_id),
    CONSTRAINT fk_tb_call_history_lead_id FOREIGN KEY (lead_id)
        REFERENCES tb_lead(lead_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_history_property_profile_id FOREIGN KEY (property_profile_id)
        REFERENCES tb_property_profile(property_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_history_status_id FOREIGN KEY (status_id)
        REFERENCES tb_status(status_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_history_staff_id FOREIGN KEY (staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_call_detail_history (
    history_date TIMESTAMP,
    call_detail_id INTEGER,
    call_id INTEGER,
    contact_result_id INTEGER,
    call_start_datetime TIMESTAMP,
    call_end_datetime TIMESTAMP,
    remark INTEGER,
    created_date TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    last_update TIMESTAMP,
    PRIMARY KEY (history_date, call_detail_id),
    CONSTRAINT fk_tb_call_detail_history_call_id FOREIGN KEY (call_id)
        REFERENCES tb_call(call_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_call_detail_history_contact_result_id FOREIGN KEY (contact_result_id)
        REFERENCES tb_contact_result(contact_result_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_site_visit (
    site_visit_id INTEGER PRIMARY KEY,
    call_id INTEGER,
    property_id INTEGER,
    staff_id INTEGER,
    lead_id INTEGER,
    contact_result_id INTEGER,
    purpose TEXT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    photo_url TEXT[],
    remark TEXT,
    created_date TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    last_update TIMESTAMP,
    CONSTRAINT fk_tb_site_visit_call_id FOREIGN KEY (call_id)
        REFERENCES tb_call(call_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_property_id FOREIGN KEY (property_id)
        REFERENCES tb_property_profile(property_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_staff_id FOREIGN KEY (staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_lead_id FOREIGN KEY (lead_id)
        REFERENCES tb_lead(lead_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_contact_result_id FOREIGN KEY (contact_result_id)
        REFERENCES tb_contact_result(contact_result_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_site_visit_history (
    history_date TIMESTAMP,
    site_visit_id INTEGER,
    call_id INTEGER,
    property_id INTEGER,
    staff_id INTEGER,
    lead_id INTEGER,
    contact_result_id INTEGER,
    purpose TEXT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    photo_url TEXT[],
    remark TEXT,
    created_date TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    last_update TIMESTAMP,
    PRIMARY KEY (history_date, site_visit_id),
    CONSTRAINT fk_tb_site_visit_history_call_id FOREIGN KEY (call_id)
        REFERENCES tb_call(call_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_history_property_id FOREIGN KEY (property_id)
        REFERENCES tb_property_profile(property_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_history_staff_id FOREIGN KEY (staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_history_lead_id FOREIGN KEY (lead_id)
        REFERENCES tb_lead(lead_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_site_visit_history_contact_result_id FOREIGN KEY (contact_result_id)
        REFERENCES tb_contact_result(contact_result_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_payment (
    payment_id INTEGER PRIMARY KEY,
    call_id INTEGER,
    amount_in_usd NUMERIC,
    start_payment_date DATE,
    tenor INTEGER,
    interest_rate NUMERIC,
    remark TEXT,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    CONSTRAINT fk_tb_payment_call_id FOREIGN KEY (call_id)
        REFERENCES tb_call(call_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_role (
    role_id INTEGER PRIMARY KEY,
    role_name TEXT,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_menu (
    menu_id INTEGER PRIMARY KEY,
    menu_name TEXT,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_permission (
    permission_id INTEGER PRIMARY KEY,
    permission_name TEXT,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_role_permission (
    role_id INTEGER,
    permission_id INTEGER,
    menu_id INTEGER,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    PRIMARY KEY (role_id, permission_id, menu_id),
    CONSTRAINT fk_tb_role_permission_role_id FOREIGN KEY (role_id)
        REFERENCES tb_role(role_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_role_permission_permission_id FOREIGN KEY (permission_id)
        REFERENCES tb_permission(permission_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_role_permission_menu_id FOREIGN KEY (menu_id)
        REFERENCES tb_menu(menu_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_user_role (
    role_id INTEGER,
    staff_id INTEGER,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    PRIMARY KEY (role_id, staff_id),
    CONSTRAINT fk_tb_user_role_role_id FOREIGN KEY (role_id)
        REFERENCES tb_role(role_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_tb_user_role_staff_id FOREIGN KEY (staff_id)
        REFERENCES tb_staff(staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_channel_type (
    channel_type_id INTEGER PRIMARY KEY,
    channel_name TEXT,
    description TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER
);

CREATE TABLE tb_contact_channel (
    contact_channel_id INTEGER PRIMARY KEY,
    channel_type_id INTEGER,
    contact_number TEXT[],
    remark TEXT,
    is_primary BOOLEAN,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    CONSTRAINT fk_tb_contact_channel_channel_type_id FOREIGN KEY (channel_type_id)
        REFERENCES tb_channel_type(channel_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tb_module_contact_channel (
    module_trx_id INTEGER PRIMARY KEY,
    contact_channel_id INTEGER,
    module_name TEXT,
    remark TEXT,
    is_active BOOLEAN,
    created_date TIMESTAMP,
    created_by INTEGER,
    last_update TIMESTAMP,
    updated_by INTEGER,
    CONSTRAINT fk_tb_module_contact_channel_contact_channel_id FOREIGN KEY (contact_channel_id)
        REFERENCES tb_contact_channel(contact_channel_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);