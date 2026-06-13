create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG.   
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
     * Procedure : sync_partial_ai   
     * Purpose   : Sync Partial Ai   
     ************************************************************************/   
    PROCEDURE sync_partial_ai (   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_invoice_id  IN NUMBER   
    );   
 
    /************************************************************************   
     * Procedure : process_rag_events   
     * Purpose   : Process Rag Events   
     ************************************************************************/   
    PROCEDURE process_rag_events (   
        p_batch_size IN NUMBER DEFAULT 50   
    );   
END AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package body for AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG.   
       ================================================================== */   
    PROCEDURE sync_partial_ai (   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_invoice_id  IN NUMBER   
    ) IS   
    BEGIN   
        INSERT INTO ai_sec_rag_system_l_event (source_type, source_id, invoice_id, status)
        VALUES (p_source_type, p_source_id, p_invoice_id, 'NEW');
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'sync_partial_ai',   
                p_custom_message   => 'Error in sync_partial_ai'   
            );   
    END sync_partial_ai;   
 
    PROCEDURE process_rag_events (   
        p_batch_size IN NUMBER DEFAULT 50   
    ) IS   
    BEGIN   
        FOR rec IN (
            SELECT id, source_type, source_id
            FROM ai_sec_rag_system_l_event
            WHERE status = 'NEW'
            ORDER BY created_at
            FETCH FIRST p_batch_size ROWS ONLY
        ) LOOP
            BEGIN
                FOR doc_rec IN (
                    SELECT patient_id, doc_text, doc_date
                    FROM ai_sec_sys_view_patient_full_history_lookup
                    WHERE source_type = rec.source_type AND source_id = rec.source_id
                ) LOOP
                    AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.merge_document(
                        p_patient_id => doc_rec.patient_id,
                        p_source_type => rec.source_type,
                        p_source_id => rec.source_id,
                        p_doc_text => doc_rec.doc_text,
                        p_doc_date => doc_rec.doc_date
                    );
                END LOOP;
                
                UPDATE ai_sec_rag_system_l_event SET status = 'PROCESSED', updated_at = SYSTIMESTAMP WHERE id = rec.id;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE ai_sec_rag_system_l_event SET status = 'FAILED', error_message = SQLERRM, updated_at = SYSTIMESTAMP WHERE id = rec.id;
            END;
        END LOOP;
        COMMIT;
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'process_rag_events',   
                p_custom_message   => 'Error in process_rag_events'   
            );   
    END process_rag_events;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_SYNC_PKG;
/
