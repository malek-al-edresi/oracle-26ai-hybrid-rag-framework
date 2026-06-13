create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.   
                        Structural refactoring only - all business logic   
                        preserved exactly as in the original source.   
 
       CHANGE HISTORY :   
       DATE              AUTHOR                     DESCRIPTION   
       ----------       ----------------------     ---------------------------   
       2026-06-11       ENG. Malek Al-Edresi       Implemented Hybrid RAG Architecture, 
                                                    Document Chunking, and True 
                                                    Hybrid Vector Retrieval. 
       2026-04-06       ENG. Malek Al-Edresi       Structural refactoring:   
                                                    standardized headers,   
                                                    English documentation, and   
                                                    professional formatting   
       ================================================================== */   
    /************************************************************************   
     * Procedure : merge_document   
     * Purpose   : Merge Document   
     ************************************************************************/   
    PROCEDURE merge_document (   
        p_patient_id  IN NUMBER,   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_doc_text    IN CLOB,   
        p_doc_date    IN DATE,   
        p_file        IN BLOB DEFAULT NULL,   
        p_mimetype    IN VARCHAR2 DEFAULT NULL,   
        p_filename    IN VARCHAR2 DEFAULT NULL   
    );   
 
    /************************************************************************   
     * Procedure : insert_document   
     * Purpose   : Insert Document   
     ************************************************************************/   
    PROCEDURE insert_document (   
        p_patient_id  IN NUMBER,   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_doc_text    IN CLOB,   
        p_doc_date    IN DATE,   
        p_file        IN BLOB DEFAULT NULL,   
        p_mimetype    IN VARCHAR2 DEFAULT NULL,   
        p_filename    IN VARCHAR2 DEFAULT NULL   
    );   
 
    /************************************************************************   
     * Function  : get_document_count   
     * Purpose   : Get Document Count   
     ************************************************************************/   
    FUNCTION get_document_count RETURN NUMBER;   
 
    /************************************************************************   
     * Procedure : populate_ai_from_lookup_for_patient   
     * Purpose   : Populate Ai From Lookup For Patient   
     ************************************************************************/   
    PROCEDURE populate_ai_from_lookup_for_patient (   
        p_patient_id IN NUMBER   
    );   
 
    /************************************************************************   
     * Function  : get_document_statistics   
     * Purpose   : Get Document Statistics   
     ************************************************************************/   
    FUNCTION get_document_statistics RETURN CLOB;   
 
    /************************************************************************   
     * Procedure : validate_ai_integration   
     * Purpose   : Validate Ai Integration   
     ************************************************************************/   
    PROCEDURE validate_ai_integration (   
        p_patient_id IN  NUMBER,   
        o_status   OUT VARCHAR2,   
        o_message  OUT VARCHAR2   
    );   
 
    /************************************************************************   
     * Procedure : process_document_chunks   
     * Purpose   : Process Document Chunks   
     ************************************************************************/ 
    PROCEDURE process_document_chunks (p_doc_id IN NUMBER); 
END AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package body for AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.   
                        Structural refactoring only - all business logic   
                        preserved exactly as in the original source.   
 
       CHANGE HISTORY :   
       DATE              AUTHOR                     DESCRIPTION   
       ----------       ----------------------     ---------------------------   
       2026-06-11       ENG. Malek Al-Edresi       Implemented Hybrid RAG Architecture, 
                                                    Document Chunking, and True 
                                                    Hybrid Vector Retrieval. 
       2026-04-06       ENG. Malek Al-Edresi       Structural refactoring   
       ================================================================== */   
    PROCEDURE merge_document (   
        p_patient_id  IN NUMBER,   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_doc_text    IN CLOB,   
        p_doc_date    IN DATE,   
        p_file        IN BLOB DEFAULT NULL,   
        p_mimetype    IN VARCHAR2 DEFAULT NULL,   
        p_filename    IN VARCHAR2 DEFAULT NULL   
    ) IS   
        l_embedding  VECTOR;   
        l_user_name  VARCHAR2(100) := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);   
    BEGIN   
        IF p_doc_text IS NOT NULL THEN   
            l_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding_from_clob(p_doc_text);   
        END IF;   
         
        MERGE INTO AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS d   
        USING (SELECT p_source_type AS st, p_source_id AS sid FROM dual) s   
        ON (d.source_type = s.st AND d.source_id = s.sid)   
        WHEN MATCHED THEN   
            UPDATE SET   
                d.patient_id = p_patient_id,   
                d.doc_text = p_doc_text,   
                d.doc_date = p_doc_date,   
                d.doc_file = p_file,   
                d.mimetype = p_mimetype,   
                d.file_name = p_filename,   
                d.updated_at = SYSTIMESTAMP,   
                d.CREATED_BY_USER = l_user_name,   
                d.embedding = NVL(l_embedding, d.embedding)   
        WHEN NOT MATCHED THEN   
            INSERT (   
                patient_id, source_type, source_id, doc_text, doc_date, doc_file, mimetype, file_name, CREATED_AT, CREATED_BY_USER, embedding   
            )   
            VALUES (   
                p_patient_id, p_source_type, p_source_id, p_doc_text, p_doc_date, p_file, p_mimetype, p_filename, SYSTIMESTAMP, l_user_name, l_embedding   
            );   
             
        DECLARE 
            l_doc_id NUMBER; 
        BEGIN 
            SELECT doc_id INTO l_doc_id  
            FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS  
            WHERE source_type = p_source_type AND source_id = p_source_id; 
             
            process_document_chunks(l_doc_id); 
        END; 
 
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'merge_document',   
                p_custom_message   => 'Error in merging document'   
            );   
    END merge_document;   
 
    PROCEDURE insert_document (   
        p_patient_id  IN NUMBER,   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_doc_text    IN CLOB,   
        p_doc_date    IN DATE,   
        p_file        IN BLOB DEFAULT NULL,   
        p_mimetype    IN VARCHAR2 DEFAULT NULL,   
        p_filename    IN VARCHAR2 DEFAULT NULL   
    ) IS   
        l_embedding  VECTOR;   
        l_user_name  VARCHAR2(100) := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);   
        l_doc_id     NUMBER; 
    BEGIN   
        IF p_doc_text IS NOT NULL THEN   
            l_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding_from_clob(p_doc_text);   
        END IF;   
 
        INSERT INTO AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS (   
            patient_id, source_type, source_id, doc_text, doc_date, doc_file, mimetype, file_name, CREATED_AT, CREATED_BY_USER, embedding   
        )   
        VALUES (   
            p_patient_id, p_source_type, p_source_id, p_doc_text, p_doc_date, p_file, p_mimetype, p_filename, SYSTIMESTAMP, l_user_name, l_embedding   
        ) RETURNING doc_id INTO l_doc_id;   
         
        process_document_chunks(l_doc_id); 
         
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'insert_document',   
                p_custom_message   => 'Error in inserting document'   
            );   
    END insert_document;   
 
    FUNCTION get_document_count RETURN NUMBER IS   
        l_count NUMBER;   
    BEGIN   
        SELECT COUNT(*) INTO l_count FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS;   
        RETURN l_count;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'get_document_count',   
                p_custom_message   => 'Error in getting document count'   
            );   
    END get_document_count;   
 
    PROCEDURE populate_ai_from_lookup_for_patient (   
        p_patient_id IN NUMBER   
    ) IS   
        l_count NUMBER := 0;   
    BEGIN   
        FOR r IN (   
            SELECT patient_id, source_type, source_id, doc_text, doc_date   
            FROM ai_sec_sys_view_patient_full_history_lookup   
            WHERE patient_id = p_patient_id   
              AND doc_text IS NOT NULL   
            ORDER BY doc_date NULLS LAST   
        ) LOOP   
            merge_document(   
                p_patient_id => r.patient_id,   
                p_source_type => r.source_type,   
                p_source_id => r.source_id,   
                p_doc_text => r.doc_text,   
                p_doc_date => r.doc_date   
            );   
            l_count := l_count + 1;   
            IF MOD(l_count, 100) = 0 THEN COMMIT; END IF;   
        END LOOP;   
        COMMIT;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'populate_ai_from_lookup_for_patient',   
                p_custom_message   => 'Error in populate ai from lookup for patient'   
            );   
    END populate_ai_from_lookup_for_patient;   
 
    FUNCTION get_document_statistics RETURN CLOB IS   
        l_result       CLOB;   
        l_total_docs   NUMBER;   
        l_by_type      VARCHAR2(4000);   
        l_by_patient   VARCHAR2(4000);   
        l_oldest_date  DATE;   
        l_newest_date  DATE;   
    BEGIN   
        SELECT   
            COUNT(*),   
            MIN(doc_date),   
            MAX(doc_date)   
        INTO   
            l_total_docs,   
            l_oldest_date,   
            l_newest_date   
        FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS;   
 
        SELECT LISTAGG(source_type || ': ' || cnt, ', ')   
        INTO l_by_type   
        FROM (   
            SELECT source_type, COUNT(*) cnt   
            FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS   
            GROUP BY source_type   
            ORDER BY cnt DESC   
        );   
 
        SELECT LISTAGG(patient_id || ': ' || cnt, ', ')   
        INTO l_by_patient   
        FROM (   
            SELECT patient_id, COUNT(*) cnt   
            FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS   
            GROUP BY patient_id   
            ORDER BY cnt DESC   
            FETCH FIRST 5 ROWS ONLY   
        );   
 
        l_result := 'AI Documents Statistics:' || CHR(10) ||   
                   '==========================' || CHR(10) ||   
                   'Total Documents: ' || l_total_docs || CHR(10) ||   
                   'Distribution by Type: ' || NVL(l_by_type, 'No Data') || CHR(10) ||   
                   'Top 5 Patients: ' || NVL(l_by_patient, 'No Data') || CHR(10) ||   
                   'Oldest Document: ' || NVL(TO_CHAR(l_oldest_date, 'YYYY-MM-DD'), 'N/A') || CHR(10) ||   
                   'Newest Document: ' || NVL(TO_CHAR(l_newest_date, 'YYYY-MM-DD'), 'N/A');   
 
        RETURN l_result;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'get_document_statistics',   
                p_custom_message   => 'Error in getting document statistics'   
            );   
    END get_document_statistics;   
 
    PROCEDURE validate_ai_integration (   
        p_patient_id IN  NUMBER,   
        o_status   OUT VARCHAR2,   
        o_message  OUT VARCHAR2   
    ) IS   
        l_doc_count    NUMBER;   
        l_test_query1  CLOB;   
        l_test_query2  CLOB;   
    BEGIN   
        SELECT COUNT(*) INTO l_doc_count FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS WHERE patient_id = p_patient_id;   
 
        IF l_doc_count = 0 THEN   
            o_status := 'WARNING';   
            o_message := 'No documents found for patient ID: ' || p_patient_id || '. Run population first.';   
            RETURN;   
        END IF;   
 
        l_test_query1 := AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG.search_documents(   
            p_patient_id, 'What chronic diseases does the patient have?', 3);   
        l_test_query2 := AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG.search_documents(   
            p_patient_id, 'What treatments has the patient received?', 3);   
 
        IF l_test_query1 LIKE 'No relevant%' AND l_test_query2 LIKE 'No relevant%' THEN   
            o_status := 'WARNING';   
            o_message := 'Queries returned no results. Documents might be insufficient or inappropriate.';   
        ELSIF DBMS_LOB.GETLENGTH(NVL(l_test_query1, EMPTY_CLOB())) < 50   
           AND DBMS_LOB.GETLENGTH(NVL(l_test_query2, EMPTY_CLOB())) < 50 THEN   
            o_status := 'WARNING';   
            o_message := 'Results too short. Documents may need more detail.';   
        ELSE   
            o_status := 'SUCCESS';   
            o_message := 'Integration working correctly. ' || l_doc_count || ' documents available for search.';   
        END IF;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'validate_ai_integration',   
                p_custom_message   => 'Error in validating ai integration'   
            );   
    END validate_ai_integration;   
 
    PROCEDURE process_document_chunks (p_doc_id IN NUMBER) IS 
        v_doc_rec        AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS%ROWTYPE; 
        v_extracted_text CLOB; 
        v_embedding      VECTOR; 
        v_threshold      NUMBER := 1500; 
        v_chunk_no       NUMBER := 1; 
        v_content_type   VARCHAR2(100); 
        v_should_chunk   BOOLEAN := FALSE; 
        v_json_params    JSON; 
    BEGIN 
        SELECT * INTO v_doc_rec FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS WHERE doc_id = p_doc_id; 
 
        v_content_type := v_doc_rec.source_type;
 
        DELETE FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS WHERE doc_id = p_doc_id; 
 
        v_json_params := JSON('{"by":"words","max":"500","overlap":"50"}'); 
 
        IF v_doc_rec.doc_file IS NOT NULL THEN 
            v_should_chunk := TRUE; 
            BEGIN 
                v_extracted_text := DBMS_VECTOR_CHAIN.UTL_TO_TEXT(v_doc_rec.doc_file); 
            EXCEPTION 
                WHEN OTHERS THEN 
                    v_extracted_text := v_doc_rec.doc_text; 
            END; 
        ELSIF v_doc_rec.doc_text IS NOT NULL AND LENGTH(v_doc_rec.doc_text) > v_threshold THEN 
            v_should_chunk := TRUE; 
            v_extracted_text := v_doc_rec.doc_text; 
        ELSE 
            v_should_chunk := FALSE; 
        END IF; 
 
        IF v_should_chunk AND v_extracted_text IS NOT NULL AND DBMS_LOB.GETLENGTH(v_extracted_text) > 0 THEN 
            FOR chunk_rec IN ( 
                SELECT JSON_VALUE(column_value, '$.chunk_data') AS chunk_text  
                FROM TABLE(DBMS_VECTOR_CHAIN.UTL_TO_CHUNKS(v_extracted_text, v_json_params)) 
            ) LOOP 
                v_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding_from_clob(chunk_rec.chunk_text); 
                 
                INSERT INTO AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS ( 
                    doc_id, chunk_no, content_type, chunk_text, embedding, updated_at 
                ) VALUES ( 
                    p_doc_id, v_chunk_no, v_content_type, chunk_rec.chunk_text, v_embedding, SYSTIMESTAMP 
                ); 
                v_chunk_no := v_chunk_no + 1; 
            END LOOP; 
             
            UPDATE AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS  
            SET is_chunked = 1, chunked_at = SYSTIMESTAMP  
            WHERE doc_id = p_doc_id; 
             
        ELSIF v_doc_rec.doc_text IS NOT NULL THEN 
            v_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding_from_clob(v_doc_rec.doc_text); 
            UPDATE AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS  
            SET embedding = v_embedding, is_chunked = 0, chunked_at = NULL  
            WHERE doc_id = p_doc_id; 
        END IF; 
 
    EXCEPTION 
        WHEN OTHERS THEN 
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'process_document_chunks',   
                p_custom_message   => 'Error in chunk processing'   
            ); 
    END process_document_chunks; 
 
END AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG;
/
