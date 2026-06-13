CREATE OR REPLACE TRIGGER "TRG_AI_RAG_APPOINTMENT"  
    AFTER INSERT OR UPDATE OR DELETE ON booking_sec_t_appointment 
    FOR EACH ROW 
BEGIN 
    INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id) 
    VALUES ('APPOINTMENT', COALESCE(:NEW.appointmentid, :OLD.appointmentid), COALESCE(:NEW.invoiceid, :OLD.invoiceid)); 
END;
/

CREATE OR REPLACE TRIGGER "TRG_AI_RAG_MEDICAL_REPORT"  
    AFTER INSERT OR UPDATE OR DELETE ON basic_sec_t_medicalreport 
    FOR EACH ROW 
BEGIN 
    INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id) 
    VALUES ('REPORT', COALESCE(:NEW.reportid, :OLD.reportid), COALESCE(:NEW.invoiceid, :OLD.invoiceid)); 
END;
/

CREATE OR REPLACE TRIGGER "TRG_AI_RAG_TREATMENT"  
    AFTER INSERT OR UPDATE OR DELETE ON basic_sec_t_treatment 
    FOR EACH ROW 
BEGIN 
    INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id) 
    VALUES ('TREATMENT', COALESCE(:NEW.treatmentid, :OLD.treatmentid), NULL); 
END;
/

CREATE OR REPLACE TRIGGER "TRG_AI_RAG_DIAGNOSIS"  
    AFTER INSERT OR UPDATE OR DELETE ON basic_sec_t_diagnosis  
    FOR EACH ROW  
BEGIN  
    INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id)  
    VALUES ('DIAGNOSIS', COALESCE(:NEW.diagnosisid, :OLD.diagnosisid), COALESCE(:NEW.invoiceid, :OLD.invoiceid));  
END;
/

CREATE OR REPLACE TRIGGER "TRG_AI_RAG_LAB_RESULT"  
    AFTER INSERT OR UPDATE OR DELETE ON lab_sec_t_results 
    FOR EACH ROW 
BEGIN 
    INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id) 
    VALUES ('LAB_RESULT', COALESCE(:NEW.resultid, :OLD.resultid), COALESCE(:NEW.invoiceid, :OLD.invoiceid)); 
END;
/

CREATE OR REPLACE TRIGGER "TRG_AI_RAG_RADIOLOGY_RESULT"  
    AFTER INSERT OR UPDATE OR DELETE ON radiology_sec_t_radiologyresults 
    FOR EACH ROW 
BEGIN 
    INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id) 
    VALUES ('RADIOLOGY_RESULT', COALESCE(:NEW.resultid, :OLD.resultid), COALESCE(:NEW.invoiceid, :OLD.invoiceid)); 
END;
/
