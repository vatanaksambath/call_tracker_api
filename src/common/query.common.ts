export const SQL = {

/*  ==============================> Common <================================ */

    getProvince             : 'SELECT * FROM get_province()',
    getDistrictByProviceID  : 'SELECT * FROM get_district_by_province_id($1)',
    getCommuneByDistrictID  : 'SELECT * FROM get_commune_by_district_id($1)',
    getVillageByCommuneID   : 'SELECT * FROM get_village_by_commune_id($1)',

/*  ==============================> Role Base Access Control <================================ */
    getRole: 'SELECT * FROM get_role()',
    roleInsert: 'CALL role_insert($1, $2)',
    roleUpdate: 'CALL role_update($1, $2, $3, $4, $5)',
    roleDelete: 'CALL role_delete($1, $2)',

    getUserRole: 'SELECT * FROM get_user_role()',
    userRoleInsert: 'CALL user_role_insert($1, $2, $3, $4, $5)',
    userRoleUpdate: 'CALL user_role_update($1, $2, $3, $4, $5)',
    userRoleDelete: 'CALL user_role_delete($1, $2)',

/*  ==============================> NPL Compulsary <================================ */
    
    compulsoryInsert        : 'CALL npl_compulsory_execution_insert(  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26 )',
    compulsoryUpdate        : 'CALL npl_compulsory_execution_update(  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27 )',
    compulsoryCloseCase     : 'CALL npl_compulsory_execution_close_case(  $1, $2, $3, $4 )',
    compulsoryDeleteByID    : 'CALL npl_compulsory_execution_delete ( $1, $2 )',
    compulsoryByID          : 'SELECT * FROM npl_compulsory_by_id ( $1 )',
    compulsoryPagination    : 'SELECT * FROM npl_compulsory_pagination ( $1, $2 , $3, $4, $5, $6, $7, $8, $9, $10)',
    compulsoryExport        : 'SELECT * FROM npl_compulsory_export ( $1, $2 , $3, $4, $5, $6, $7, $8 )',

/*  ==============================> Staff Information <================================ */

    staffInformation : 'SELECT * FROM get_staff_info($1)',

/*  ==============================> Audit log <================================ */

    auditLogInsert  : 'CALL audit_logs_insert( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 )'
    

}