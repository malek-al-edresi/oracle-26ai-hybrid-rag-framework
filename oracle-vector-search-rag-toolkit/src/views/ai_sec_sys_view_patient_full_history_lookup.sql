CREATE OR REPLACE FORCE EDITIONABLE VIEW "AI_SEC_SYS_VIEW_PATIENT_FULL_HISTORY_LOOKUP" ("SOURCE_ID", "SOURCE_TYPE", "PATIENT_ID", "DOC_TEXT", "DOC_DATE") AS 
  SELECT 
        d.DIAGNOSISID                         AS source_id, 
        'DIAGNOSIS'                           AS source_type, 
        b.PATIENTID                           AS patient_id, 
        TO_CLOB(d.DIAGNOSISDESCRIPTION)       AS doc_text, 
        d.DIAGNOSISDATE                       AS doc_date 
    FROM BASIC_SEC_T_DIAGNOSIS d 
    JOIN BASIC_SEC_T_BILLING b 
        ON d.INVOICEID = b.INVOICEID 
 
    UNION ALL 
 
    SELECT 
        r.REPORTID                            AS source_id, 
        'REPORT'                              AS source_type, 
        b.PATIENTID                           AS patient_id, 
        TO_CLOB(NVL(r.DETAILS, '') || ' ' || NVL(r.DOCTORNOTES, '')) AS doc_text, 
        r.REPORTDATE                          AS doc_date 
    FROM BASIC_SEC_T_MEDICALREPORT r 
    JOIN BASIC_SEC_T_BILLING b 
        ON r.INVOICEID = b.INVOICEID 
 
    UNION ALL 
 
    SELECT 
        res.RESULTID                          AS source_id, 
        'LAB_RESULT'                          AS source_type, 
        b.PATIENTID                           AS patient_id, 
        TO_CLOB(res.RESULTSUMMARY)            AS doc_text, 
        res.RESULTDATE                        AS doc_date 
    FROM LAB_SEC_T_RESULTS res 
    JOIN BASIC_SEC_T_BILLING b 
        ON res.INVOICEID = b.INVOICEID 
 
    UNION ALL 
 
    SELECT 
        rad.RESULTID                          AS source_id, 
        'RADIOLOGY_RESULT'                    AS source_type, 
        b.PATIENTID                           AS patient_id, 
        TO_CLOB(rad.DESCRIPTION)              AS doc_text, 
        rad.RESULTDATE                        AS doc_date 
    FROM RADIOLOGY_SEC_T_RADIOLOGYRESULTS rad 
    JOIN BASIC_SEC_T_BILLING b 
        ON rad.INVOICEID = b.INVOICEID 
 
    UNION ALL 
 
    SELECT 
        a.APPOINTMENTID                       AS source_id, 
        'APPOINTMENT'                         AS source_type, 
        b.PATIENTID                           AS patient_id, 
        TO_CLOB(NVL(a.NOTES, ''))             AS doc_text, 
        a.APPOINTMENTDATESTART                AS doc_date 
    FROM BOOKING_SEC_T_APPOINTMENT a 
    JOIN BASIC_SEC_T_BILLING b 
        ON a.INVOICEID = b.INVOICEID 
 
    UNION ALL 
 
    SELECT 
        t.TREATMENTID                         AS source_id, 
        'TREATMENT'                           AS source_type, 
        b.PATIENTID                           AS patient_id, 
        TO_CLOB(NVL(t.TREATMENTNOTES, ''))    AS doc_text, 
        t.TREATMENTDATE                       AS doc_date 
    FROM BASIC_SEC_T_TREATMENT t 
    JOIN BASIC_SEC_T_DIAGNOSIS d 
        ON t.DIAGNOSISID = d.DIAGNOSISID 
    JOIN BASIC_SEC_T_BILLING b 
        ON d.INVOICEID = b.INVOICEID;
/
