export const SQL = {

/*  ==============================> Common <================================ */

    getProvince             : 'SELECT * FROM get_province()',
    getDistrictByProviceID  : 'SELECT * FROM get_district_by_province_id($1)',
    getCommuneByDistrictID  : 'SELECT * FROM get_commune_by_district_id($1)',
    getVillageByCommuneID   : 'SELECT * FROM get_village_by_commune_id($1)',

/*  ==============================> Role Base Access Control <================================ */
    getRole: 'SELECT * FROM get_role()',
    roleInsert: 'CALL role_insert($1, $2, $3)',
    roleUpdate: 'CALL role_update($1, $2, $3, $4, $5)',
    roleDelete: 'CALL role_delete($1, $2)',

    getUserRole: 'SELECT * FROM get_user_role()',
    userRoleInsert: 'CALL user_role_insert($1, $2, $3, $4, $5)',
    userRoleUpdate: 'CALL user_role_update($1, $2, $3, $4, $5)',
    userRoleDelete: 'CALL user_role_delete($1, $2)',

    getUserRoleByID: 'SELECT * FROM get_user_role_by_id($1)',
    getUserRolePermissionByID: 'SELECT * FROM get_user_role_permission_by_id($1)',

/*  ==============================> Developer <================================ */
    developerPagination: 'SELECT * FROM developer_pagination($1, $2, $3, $4)',
    developerInsert: 'CALL developer_insert($1, $2, $3)',
    developerUpdate: 'CALL developer_update($1, $2, $3, $4, $5)',
    developerDelete: 'CALL developer_delete($1)',

/*  ==============================> Project Owner <================================ */
    projectOwnerPagination: 'SELECT * FROM project_owner_pagination($1, $2, $3, $4)',
    projectOwnerInsert: 'CALL project_owner_insert($1, $2, $3, $4, $5, $6, $7)',
    projectOwnerUpdate: 'CALL project_owner_update($1, $2, $3, $4, $5, $6, $7, $8, $9)',
    projectOwnerDelete: 'CALL project_owner_delete($1)',

/*  ==============================> Project <================================ */
    projectPagination: 'SELECT * FROM project_pagination($1, $2, $3, $4)',
    projectInsert: 'CALL project_insert($1, $2, $3, $4, $5)',
    projectUpdate: 'CALL project_update($1, $2, $3, $4, $5, $6, $7)',
    projectDelete: 'CALL project_delete($1)',

/*  ==============================> Business <================================ */
    businessPagination: 'SELECT * FROM business_pagination($1, $2, $3, $4)',
    businessInsert: 'CALL business_insert($1, $2, $3)',
    businessUpdate: 'CALL business_update($1, $2, $3, $4, $5)',
    businessDelete: 'CALL business_delete($1)',

/*  ==============================> Lead Source <================================ */
    leadSourcePagination: 'SELECT * FROM lead_source_pagination($1, $2, $3, $4)',
    leadSourceInsert: 'CALL lead_source_insert($1, $2, $3)',
    leadSourceUpdate: 'CALL lead_source_update($1, $2, $3, $4, $5)',
    leadSourceDelete: 'CALL lead_source_delete($1)',

/*  ==============================> Customer Type <================================ */
    customerTypePagination: 'SELECT * FROM  customer_type_pagination($1, $2, $3, $4)',
    customerTypeInsert: 'CALL customer_type_insert($1, $2, $3)',
    customerTypeUpdate: 'CALL customer_type_update($1, $2, $3, $4, $5)',
    customerTypeDelete: 'CALL customer_type_delete($1)',

/*  ==============================> Property Type <================================ */
    propertyTypePagination: 'SELECT * FROM  property_type_pagination($1, $2, $3, $4)',
    propertyTypeInsert: 'CALL property_type_insert($1, $2, $3)',
    propertyTypeUpdate: 'CALL property_type_update($1, $2, $3, $4, $5)',
    propertyTypeDelete: 'CALL property_type_delete($1)',

/*  ==============================> Property Profile <================================ */
    propertyProfilePagination: 'SELECT * FROM  property_profile_pagination($1, $2, $3, $4)',
    propertyProfileInsert: 'CALL property_profile_insert($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)',
    propertyProfileUpdate: 'CALL property_profile_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)',
    propertyProfileDelete: 'CALL property_profile_delete($1)',

/*  ==============================> Property Profile <================================ */
    staffPagination: 'SELECT * FROM staff_pagination($1, $2, $3, $4)',
    staffInsert: 'CALL staff_insert($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)',
    staffUpdate: 'CALL staff_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)',
    staffDelete: 'CALL staff_delete($1)',

/*  ==============================> Staff Information <================================ */

    staffInformation : 'SELECT * FROM get_staff_info($1)',

/*  ==============================> Audit log <================================ */

    auditLogInsert  : 'CALL audit_logs_insert( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 )'
    

}