-- call in store procedure

CALL public.staff_insert(
    10012,                               -- p_staff_id
    'STF001',                           -- p_staff_code
    1,                                  -- p_gender_id
    1020100,                            -- p_village_id
    NULL,                               -- p_manager_id
    'John',                             -- p_first_name
    'Doe',                              -- p_last_name
    '1990-01-01',                       -- p_date_of_birth
    'Manager',                          -- p_position
    'Finance',                          -- p_department
    'Full-time',                        -- p_employment_type
    '2020-01-01',                       -- p_employment_start_date
    NULL,                               -- p_employment_end_date
    'Level 2',                          -- p_employment_level
    '123 Main Street, Phnom Penh',     -- p_current_address
    ARRAY['/photos/john_doe.jpg'],     -- p_photo_url (text[])
    'MU_05',
    '[
        {
            "channel_type_id": 2,
            "contact_values": [
                {
                    "user_name": "john.doe",
                    "contact_number": "012345678",
                    "remark": "Mobile",
                    "is_primary": true
                },
                {
                    "user_name": "john.doe",
                    "contact_number": "john@example.com",
                    "remark": "Work Email",
                    "is_primary": false
                }
            ]
        },
        {
            "channel_type_id": 2,
            "contact_values": [
                {
                    "user_name": "john.doe",
                    "contact_number": "TelegramID123",
                    "remark": "Telegram",
                    "is_primary": true
                }
            ]
        }
    ]'::jsonb,                         -- p_contact_data
    9001                               -- p_created_by
);


CALL public.staff_update(
    4,                               -- p_staff_id
    'STF001',                           -- p_staff_code
    1,                                  -- p_gender_id
    1020100,                            -- p_village_id
    NULL,                               -- p_manager_id
    'John',                             -- p_first_name
    'Doe',                              -- p_last_name
    '1990-01-01',                       -- p_date_of_birth
    'Manager',                          -- p_position
    'Finance',                          -- p_department
    'Full-time',                        -- p_employment_type
    '2020-01-01',                       -- p_employment_start_date
    NULL,                               -- p_employment_end_date
    'Level 2',                          -- p_employment_level
    '123 Main Street, Phnom Penh',     -- p_current_address
    ARRAY['/photos/john_doe.jpg'],     -- p_photo_url (text[])
    TRUE,
    'MU_05',
    '[
        {
            "channel_type_id": 2,
            "contact_values": [
                {
                    "user_name": "john.doe",
                    "contact_number": "012345678",
                    "remark": "Mobile",
                    "is_primary": true
                }
            ]
        }
    ]'::jsonb,                         -- p_contact_data
    9001                               -- p_created_by
);
