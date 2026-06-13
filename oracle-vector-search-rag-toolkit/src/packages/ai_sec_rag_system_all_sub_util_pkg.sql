create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG.   
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
     * Procedure : log_error_and_raise   
     * Purpose   : Log Error And Raise   
     *   
     * Parameters :   
     *   p_custom_message IN VARCHAR2   
     *   p_source_procedure IN VARCHAR2   
     ************************************************************************/   
    PROCEDURE log_error_and_raise (   
        p_custom_message    IN VARCHAR2 DEFAULT NULL,   
        p_source_procedure  IN VARCHAR2   
    );   
 
    /************************************************************************   
     * Function  : get_current_user   
     * Purpose   : Get Current User   
     *   
     * Returns :   
     *   VARCHAR2   
     ************************************************************************/   
    FUNCTION get_current_user RETURN VARCHAR2;   
 
    /************************************************************************   
     * Function  : truncate_clob   
     * Purpose   : Truncate Clob   
     *   
     * Parameters :   
     *   p_clob IN CLOB   
     *   p_length IN NUMBER   
     *   
     * Returns :   
     *   CLOB   
     ************************************************************************/   
    FUNCTION truncate_clob (   
        p_clob   IN CLOB,   
        p_length IN NUMBER   
    ) RETURN CLOB;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package body for AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG.   
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
    PROCEDURE log_error_and_raise (   
        p_custom_message    IN VARCHAR2 DEFAULT NULL,   
        p_source_procedure  IN VARCHAR2   
    ) IS   
    BEGIN   
        AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
            p_custom_message   => p_custom_message,   
            p_source_procedure => p_source_procedure   
        );   
    END log_error_and_raise;   
 
    FUNCTION get_current_user RETURN VARCHAR2 IS   
    BEGIN   
        RETURN NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);   
    END get_current_user;   
 
    FUNCTION truncate_clob (   
        p_clob   IN CLOB,   
        p_length IN NUMBER   
    ) RETURN CLOB IS   
    BEGIN   
        IF p_clob IS NULL THEN RETURN NULL; END IF; 
        IF DBMS_LOB.GETLENGTH(p_clob) <= p_length THEN RETURN p_clob; END IF; 
        RETURN DBMS_LOB.SUBSTR(p_clob, p_length, 1); 
    END truncate_clob;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_UTIL_PKG;
/
