import { channel } from "diagnostics_channel";

export const SQL = {

/*  ==============================> Common <================================ */

    getProvince             : 'SELECT * FROM get_province()',
    getDistrictByProviceID  : 'SELECT * FROM get_district_by_province_id($1)',
    getCommuneByDistrictID  : 'SELECT * FROM get_commune_by_district_id($1)',
    getVillageByCommuneID   : 'SELECT * FROM get_village_by_commune_id($1)',
    getGender : 'SELECT * FROM get_gender()',
    getBusiness : 'SELECT * FROM get_business()',
    addressSummary: 'SELECT * FROM address_summary($1)',

/*  ==============================> Role Base Access Control <================================ */
    getRole: 'SELECT * FROM get_role()',
    roleInsert: 'CALL role_insert($1, $2, $3)',
    roleUpdate: 'CALL role_update($1, $2, $3, $4, $5)',
    roleDelete: 'CALL role_delete($1, $2)',

    getUserRole: 'SELECT * FROM get_user_role()',
    getUserPermission: 'SELECT * FROM get_user_role_permission_by_id($1)',
    userRoleInsert: 'CALL user_role_insert($1, $2, $3, $4, $5)',
    userRoleUpdate: 'CALL user_role_update($1, $2, $3, $4, $5)',
    userRoleDelete: 'CALL user_role_delete($1, $2)',

    getUserRoleByID: 'SELECT * FROM get_user_role_by_id($1)',
    getUserRolePermissionByID: 'SELECT * FROM get_user_role_permission_by_group_id($1)',

/*  ==============================> Developer <================================ */
    developerPagination: 'SELECT * FROM developer_pagination($1, $2, $3, $4, $5)',
    developerSummary: 'SELECT * FROM developer_summary($1)',
    developerInsert: 'CALL developer_insert($1, $2, $3)',
    developerUpdate: 'CALL developer_update($1, $2, $3, $4, $5)',
    developerDelete: 'CALL developer_delete($1)',
    developerExport: 'SELECT * FROM developer_export($1, $2, $3)',

/*  ==============================> Project Owner <================================ */
    projectOwnerPagination: 'SELECT * FROM project_owner_pagination($1, $2, $3, $4)',
    projectOwnerInsert: 'CALL project_owner_insert($1, $2, $3, $4, $5, $6, $7)',
    projectOwnerUpdate: 'CALL project_owner_update($1, $2, $3, $4, $5, $6, $7, $8, $9)',
    projectOwnerDelete: 'CALL project_owner_delete($1)',
    projectOwnerExport: 'SELECT * FROM project_owner_export($1, $2)',

/*  ==============================> Project <================================ */
    projectPagination: 'SELECT * FROM project_pagination($1, $2, $3, $4, $5)',
    projectSummary: 'SELECT * FROM project_summary($1)',
    projectInsert: 'CALL project_insert($1, $2, $3, $4, $5)',
    projectUpdate: 'CALL project_update($1, $2, $3, $4, $5, $6, $7)',
    projectDelete: 'CALL project_delete($1)',
    projectExport: 'SELECT * FROM project_export($1, $2, $3)',

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
    getleadSource : 'SELECT * FROM get_lead_source()',

/*  ==============================> Customer Type <================================ */
    customerTypePagination: 'SELECT * FROM  customer_type_pagination($1, $2, $3, $4)',
    customerTypeInsert: 'CALL customer_type_insert($1, $2, $3)',
    customerTypeUpdate: 'CALL customer_type_update($1, $2, $3, $4, $5)',
    customerTypeDelete: 'CALL customer_type_delete($1)',
    getCustomerType : 'SELECT * FROM get_customer_type()',

/*  ==============================> Property Type <================================ */
    propertyTypePagination: 'SELECT * FROM  property_type_pagination($1, $2, $3, $4)',
    propertyTypeInsert: 'CALL property_type_insert($1, $2, $3)',
    propertyTypeUpdate: 'CALL property_type_update($1, $2, $3, $4, $5)',
    propertyTypeDelete: 'CALL property_type_delete($1)',
    propertyTypeExport: 'SELECT * FROM property_type_export($1, $2)',

/*  ==============================> Property Profile <================================ */
    propertyProfilePagination: 'SELECT * FROM  property_profile_pagination($1, $2, $3, $4, $5)',
    propertyProfileSummary: 'SELECT * FROM property_profile_summary($1)',
    propertyProfileInsert: 'CALL property_profile_insert($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)',
    propertyProfileUpdate: 'CALL property_profile_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)',
    propertyProfileDelete: 'CALL property_profile_delete($1)',
    propertyProfileExport: 'SELECT * FROM property_profile_export($1, $2, $3)',

/*  ==============================> Staff <================================ */
    staffPagination: 'SELECT * FROM staff_pagination($1, $2, $3, $4, $5)',
    staffSummary: 'SELECT * FROM staff_summary($1)',
    staffInsert: 'CALL staff_insert($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)',
    staffUpdate: 'CALL staff_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)',
    staffDelete: 'CALL staff_delete($1)',
    staffExport: 'SELECT * FROM staff_export($1, $2, $3)',

/*  ==============================> Channel <================================ */
    channelTypePagination: 'SELECT * FROM channel_type_pagination($1, $2, $3, $4)',
    channelTypeSummary: 'SELECT * FROM channel_type_summary($1)',
    channelTypeInsert: 'CALL channel_type_insert($1, $2, $3)',
    channelTypeUpdate: 'CALL channel_type_update($1, $2, $3, $4, $5)',
    channelTypeDelete: 'CALL channel_type_delete($1)',
    getChannelType: 'SELECT * FROM get_channel_type()',

/*  ==============================> Lead <================================ */
    leadPagination: 'SELECT * FROM lead_pagination($1, $2, $3, $4, $5)',
    leadSummary: 'SELECT * FROM lead_summary($1)',
    leadInsert: 'CALL lead_insert($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)',
    leadUpdate: 'CALL lead_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)',
    leadDelete: 'CALL lead_delete($1)',
    leadNumber: 'SELECT * FROM generate_id($1)',
    leadExport: 'SELECT * FROM lead_export($1, $2, $3)',

/*  ==============================> Site Visit <================================ */
    siteVisitPagination: 'SELECT * FROM site_visit_pagination($1, $2, $3, $4, $5)',
    siteVisitInsert: 'CALL site_visit_insert($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)',
    siteVisitUpdate: 'CALL site_visit_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)',
    siteVisitDelete: 'CALL site_visit_delete($1)',
    siteVisitExport: 'SELECT * FROM site_visit_export($1, $2)',

/*  ==============================> CALL LOG <================================ */
    callLogPagination: 'SELECT * FROM call_log_pagination($1, $2, $3, $4, $5)',
    callLogSummary: 'SELECT * FROM call_log_summary($1)',
    callLogInsert: 'CALL call_log_insert($1, $2, $3, $4, $5, $6, $7, $8, $9)',
    callLogUpdate: 'CALL call_log_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)',
    callLogUpdateInfo: 'CALL call_log_update_info($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)',
    callLogDelete: 'CALL call_log_delete($1)',
    callLogExport: 'SELECT * FROM call_log_export($1, $2, $3)',

/*  ==============================> CALL LOG DETAIL <================================ */
    callLogDetailLogInsert: 'CALL call_log_detail_insert($1, $2, $3, $4, $5, $6, $7, $8)',
    callLogDetailPagination: 'SELECT * FROM call_log_detail_pagination($1, $2, $3, $4, $5)',
    callLogDetailLogUpdate: 'CALL call_log_detail_update($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)',
    callLogDetailExport: 'SELECT * FROM call_log_detail_export($1)',

/*  ==============================> CONTACT RESULT <================================ */
    contactResultPagination: 'SELECT * FROM contact_result_pagination($1, $2, $3, $4, $5)',
    contactResultInsert: 'CALL contact_result_insert($1, $2, $3, $4)',
    contactResultUpdate: 'CALL contact_result_update($1, $2, $3, $4, $5, $6)',
    contactResultDelete: 'CALL contact_result_delete($1)',

/*  ==============================> DASHBOARD <================================ */
    dashboardSummary: 'SELECT * FROM dashboard_summary($1)',

/*  ==============================> PAYMENT <================================ */
    generate_loan_schedule: 'SELECT * FROM generate_loan_schedule($1)',
    paymentInsert: 'CALL payment_insert($1, $2, $3, $4, $5, $6, $7, $8)',
    paymentUpdate: 'CALL payment_update($1, $2, $3, $4, $5, $6, $7, $8, $9)',
    paymentDelete: 'CALL payment_delete($1)',
    paymentSummary: 'SELECT * FROM payment_summary($1)',

/*  ==============================> PROPERTY STATUS <================================ */
    propertyStatusPagination: 'SELECT * FROM property_status_pagination($1, $2, $3, $4)',
    propertyStatusInsert: 'CALL property_status_insert($1, $2, $3)',
    propertyStatusUpdate: 'CALL property_status_update($1, $2, $3, $4, $5)',
    propertyStatusDelete: 'CALL property_status_delete($1)',

/*  ==============================> IMPORT DATA LEAD AND CALL LOG <================================ */
    importLeadsAndCreateCallLogs: 'SELECT * FROM import_leads_and_create_call_logs($1, $2, $3, $4)',

/*  ==============================> Audit log <================================ */
    auditLogInsert  : 'CALL audit_logs_insert( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 )'
}