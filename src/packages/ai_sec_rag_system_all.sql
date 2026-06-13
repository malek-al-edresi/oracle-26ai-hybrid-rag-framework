create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL.   
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
       2026-05-01       ENG. Malek Al-Edresi       Added procedure refresh_missing_embeddings  
                                                    to handle missing embeddings in the RAG system.   
       ================================================================== */   
    /************************************************************************   
     * Procedure : sync_ai_document   
     ************************************************************************/   
    PROCEDURE sync_ai_document (   
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
     * Procedure : add_ai_document   
     ************************************************************************/   
    PROCEDURE add_ai_document (   
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
     * Function  : search_documents   
     ************************************************************************/   
    FUNCTION search_documents (   
        p_patient_id IN NUMBER,   
        p_question   IN VARCHAR2,   
        p_top_k      IN NUMBER DEFAULT 5   
    ) RETURN CLOB;   
 
    /************************************************************************   
     * Procedure : validate_ai_integration   
     ************************************************************************/   
    PROCEDURE validate_ai_integration (   
        p_patient_id IN  NUMBER,   
        o_status   OUT VARCHAR2,   
        o_message  OUT VARCHAR2   
    );   
 
    /************************************************************************   
     * Procedure : refresh_missing_embeddings   
     ************************************************************************/ 
    PROCEDURE refresh_missing_embeddings; 
 
    /************************************************************************   
     * Procedure : process_document_chunks   
     ************************************************************************/ 
    PROCEDURE process_document_chunks (p_doc_id IN NUMBER); 
 
END AI_SEC_RAG_SYSTEM_ALL;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL   
       GENERATED ON  :  2026-04-06   
       ================================================================== */   
    PROCEDURE sync_ai_document (   
        p_patient_id  IN NUMBER,   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_doc_text    IN CLOB,   
        p_doc_date    IN DATE,   
        p_file        IN BLOB DEFAULT NULL,   
        p_mimetype    IN VARCHAR2 DEFAULT NULL,   
        p_filename    IN VARCHAR2 DEFAULT NULL   
    ) IS   
    BEGIN   
        IF p_patient_id IS NULL OR p_source_type IS NULL OR p_source_id IS NULL THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'sync_ai_document',   
                p_custom_message   => 'Patient ID, Source Type, and Source ID cannot be empty'   
            );   
        END IF;   
 
        AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.merge_document(   
            p_patient_id => p_patient_id,   
            p_source_type => p_source_type,   
            p_source_id => p_source_id,   
            p_doc_text => p_doc_text,   
            p_doc_date => p_doc_date, 
            p_file => p_file, 
            p_mimetype => p_mimetype, 
            p_filename => p_filename 
        );   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'sync_ai_document',   
                p_custom_message   => 'Error in syncing ai document'   
            );   
    END sync_ai_document;   
 
    PROCEDURE add_ai_document (   
        p_patient_id  IN NUMBER,   
        p_source_type IN VARCHAR2,   
        p_source_id   IN NUMBER,   
        p_doc_text    IN CLOB,   
        p_doc_date    IN DATE,   
        p_file        IN BLOB DEFAULT NULL,   
        p_mimetype    IN VARCHAR2 DEFAULT NULL,   
        p_filename    IN VARCHAR2 DEFAULT NULL   
    ) IS   
    BEGIN   
        IF p_patient_id IS NULL OR p_source_type IS NULL OR p_source_id IS NULL THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'add_ai_document',   
                p_custom_message   => 'Patient ID, Source Type, and Source ID cannot be empty'   
            );   
        END IF;   
 
        AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.insert_document(   
            p_patient_id => p_patient_id,   
            p_source_type => p_source_type,   
            p_source_id => p_source_id,   
            p_doc_text => p_doc_text,   
            p_doc_date => p_doc_date, 
            p_file => p_file, 
            p_mimetype => p_mimetype, 
            p_filename => p_filename 
        );   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise (   
                p_source_procedure => 'add_ai_document',   
                p_custom_message   => 'Error in adding ai document'   
            );   
    END add_ai_document;   
 
    FUNCTION search_documents (   
        p_patient_id IN NUMBER,   
        p_question   IN VARCHAR2,   
        p_top_k      IN NUMBER DEFAULT 5   
    ) RETURN CLOB IS   
    BEGIN   
        RETURN AI_SEC_RAG_SYSTEM_ALL_SUB_SEARCH_PKG.search_documents(p_patient_id, p_question, p_top_k);   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'search_documents',   
                p_custom_message   => 'Error in searching documents'   
            );   
    END search_documents;   
 
    PROCEDURE validate_ai_integration (   
        p_patient_id IN  NUMBER,   
        o_status   OUT VARCHAR2,   
        o_message  OUT VARCHAR2   
    ) IS   
    BEGIN   
        AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.validate_ai_integration(p_patient_id, o_status, o_message);   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'validate_ai_integration',   
                p_custom_message   => 'Error in validating ai integration'   
            );   
    END validate_ai_integration; 
 
    PROCEDURE refresh_missing_embeddings IS 
    BEGIN 
        AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG.refresh_missing_embeddings; 
    END refresh_missing_embeddings; 
 
    PROCEDURE process_document_chunks (p_doc_id IN NUMBER) IS 
    BEGIN 
        AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.process_document_chunks(p_doc_id); 
    END process_document_chunks; 
 
END AI_SEC_RAG_SYSTEM_ALL;
/
