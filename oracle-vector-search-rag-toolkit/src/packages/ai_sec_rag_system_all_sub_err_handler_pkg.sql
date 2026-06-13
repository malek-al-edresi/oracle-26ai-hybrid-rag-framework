create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Centralized error handler for the AI_SYS module.   
                        Delegates all error logging to APP_BASE_PKG.log_error_and_raise   
                        with the module identifier 'AI_SYS'.   
 
       CHANGE HISTORY :   
       DATE              AUTHOR                     DESCRIPTION   
       ----------       ----------------------     ---------------------------   
       2026-06-11       ENG. Malek Al-Edresi       Implemented Hybrid RAG Architecture, 
                                                    Document Chunking, and True 
                                                    Hybrid Vector Retrieval. 
       2026-04-06       ENG. Malek Al-Edresi       Initial creation as part of   
                                                    centralized error handling   
                                                    architecture refactoring   
       ================================================================== */   
    PROCEDURE log_error_and_raise ( 
        p_custom_message    IN VARCHAR2 DEFAULT NULL, 
        p_source_procedure  IN VARCHAR2, 
        p_stop_apex_engine  IN BOOLEAN  DEFAULT FALSE, 
        p_log_level         IN VARCHAR2 DEFAULT 'ERROR', 
        p_reference_id      IN VARCHAR2 DEFAULT NULL, 
        p_payload_json      IN CLOB     DEFAULT NULL, 
        p_response_json     IN CLOB     DEFAULT NULL 
    ); 
END AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Implementation of centralized error handler for   
                        the AI_SYS module. Routes all errors through   
                        APP_BASE_PKG.log_error_and_raise.   
 
       CHANGE HISTORY :   
       DATE              AUTHOR                     DESCRIPTION   
       ----------       ----------------------     ---------------------------   
       2026-06-11       ENG. Malek Al-Edresi       Implemented Hybrid RAG Architecture, 
                                                    Document Chunking, and True 
                                                    Hybrid Vector Retrieval. 
       2026-04-06       ENG. Malek Al-Edresi       Initial creation   
       ================================================================== */   
    PROCEDURE log_error_and_raise ( 
        p_custom_message    IN VARCHAR2 DEFAULT NULL, 
        p_source_procedure  IN VARCHAR2, 
        p_stop_apex_engine  IN BOOLEAN  DEFAULT FALSE, 
        p_log_level         IN VARCHAR2 DEFAULT 'ERROR', 
        p_reference_id      IN VARCHAR2 DEFAULT NULL, 
        p_payload_json      IN CLOB     DEFAULT NULL, 
        p_response_json     IN CLOB     DEFAULT NULL 
    ) IS 
    BEGIN 
        APP_BASE_PKG.log_error_and_raise( 
            p_module        => 'AI_SYS', 
            p_location      => p_source_procedure, 
            p_message       => NVL(p_custom_message,'') || ' - ' || SQLERRM, 
            p_stop          => p_stop_apex_engine, 
            p_log_level     => NVL(p_log_level,'ERROR'), 
            p_reference_id  => p_reference_id, 
            p_payload_json  => p_payload_json, 
            p_response_json => p_response_json 
        ); 
    END log_error_and_raise; 
END AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG;
/
