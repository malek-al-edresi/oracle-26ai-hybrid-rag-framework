create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.   
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
    -- Global embedding parameters constant   
    g_embedding_params CONSTANT CLOB := '{"model":"E5_SMALL"}';   
 
    /************************************************************************   
     * Function  : get_embedding_params   
     * Purpose   : Get Embedding Params   
     *   
     * Returns :   
     *   CLOB   
     ************************************************************************/   
    FUNCTION get_embedding_params RETURN CLOB;   
 
    /************************************************************************   
     * Function  : generate_embedding   
     * Purpose   : Generate Embedding   
     *   
     * Parameters :   
     *   p_text IN VARCHAR2   
     *   
     * Returns :   
     *   VECTOR   
     ************************************************************************/   
    FUNCTION generate_embedding (   
        p_text IN VARCHAR2   
    ) RETURN VECTOR;   
 
    /************************************************************************   
     * Function  : generate_embedding_from_clob   
     * Purpose   : Generate Embedding From Clob   
     *   
     * Parameters :   
     *   p_clob IN CLOB   
     *   
     * Returns :   
     *   VECTOR   
     ************************************************************************/   
    FUNCTION generate_embedding_from_clob (   
        p_clob IN CLOB   
    ) RETURN VECTOR;   
 
    /************************************************************************   
     * Function  : calculate_similarity   
     * Purpose   : Calculate Similarity   
     *   
     * Parameters :   
     *   p_embedding1 IN VECTOR   
     *   p_embedding2 IN VECTOR   
     *   
     * Returns :   
     *   NUMBER   
     ************************************************************************/   
    FUNCTION calculate_similarity (   
        p_embedding1 IN VECTOR,   
        p_embedding2 IN VECTOR   
    ) RETURN NUMBER;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package body for AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.   
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
     * Function  : get_embedding_params   
     * Purpose   : Get Embedding Params   
     *   
     * Returns :   
     *   CLOB   
     *   
     * Exceptions :   
     *   WHEN OTHERS - Catches and propagates errors without altering responses.   
     ************************************************************************/   
    FUNCTION get_embedding_params RETURN CLOB IS   
    BEGIN   
        RETURN g_embedding_params;   
    END get_embedding_params;   
 
    /************************************************************************   
     * Function  : generate_embedding   
     * Purpose   : Generate Embedding   
     *   
     * Parameters :   
     *   p_text IN VARCHAR2   
     *   
     * Returns :   
     *   VECTOR   
     *   
     * Exceptions :   
     *   WHEN OTHERS - Catches and propagates errors without altering responses.   
     ************************************************************************/   
    FUNCTION generate_embedding (   
        p_text IN VARCHAR2   
    ) RETURN VECTOR IS   
        l_embedding VECTOR;   
    BEGIN   
        IF p_text IS NULL THEN   
            RETURN NULL;   
        END IF;   
 
        l_embedding := DBMS_VECTOR.UTL_TO_EMBEDDING(p_text, JSON(g_embedding_params));   
 
        RETURN l_embedding;   
    EXCEPTION   
 
        WHEN NO_DATA_FOUND THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'GENERATE_EMBEDDING',   
                p_custom_message   => 'Record not found'   
            );   
 
        WHEN TOO_MANY_ROWS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'GENERATE_EMBEDDING',   
                p_custom_message   => 'Too many rows returned'   
            );   
 
        WHEN VALUE_ERROR THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'GENERATE_EMBEDDING',   
                p_custom_message   => 'Value conversion error'   
            );   
 
 
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'generate_embedding',   
                p_custom_message   => 'Error in generating embedding'   
            );   
    END generate_embedding;   
 
    /************************************************************************   
     * Function  : generate_embedding_from_clob   
     * Purpose   : Generate Embedding From Clob   
     *   
     * Parameters :   
     *   p_clob IN CLOB   
     *   
     * Returns :   
     *   VECTOR   
     *   
     * Exceptions :   
     *   WHEN OTHERS - Catches and propagates errors without altering responses.   
     ************************************************************************/   
    FUNCTION generate_embedding_from_clob (   
        p_clob IN CLOB   
    ) RETURN VECTOR IS   
        l_text       VARCHAR2(32767);   
        l_embedding  VECTOR;   
    BEGIN   
        IF p_clob IS NULL THEN   
            RETURN NULL;   
        END IF;   
 
        l_text := DBMS_LOB.SUBSTR(p_clob, 32767, 1);   
        l_embedding := generate_embedding(l_text);   
        RETURN l_embedding;   
    EXCEPTION   
 
        WHEN NO_DATA_FOUND THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'GENERATE_EMBEDDING_FROM_CLOB',   
                p_custom_message   => 'Record not found'   
            );   
 
        WHEN TOO_MANY_ROWS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'GENERATE_EMBEDDING_FROM_CLOB',   
                p_custom_message   => 'Too many rows returned'   
            );   
 
        WHEN VALUE_ERROR THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'GENERATE_EMBEDDING_FROM_CLOB',   
                p_custom_message   => 'Value conversion error'   
            );   
 
 
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'generate_embedding_from_clob',   
                p_custom_message   => 'Error in generating embedding from clob'   
            );   
    END generate_embedding_from_clob;   
 
    /************************************************************************   
     * Function  : calculate_similarity   
     * Purpose   : Calculate Similarity   
     *   
     * Parameters :   
     *   p_embedding1 IN VECTOR   
     *   p_embedding2 IN VECTOR   
     *   
     * Returns :   
     *   NUMBER   
     *   
     * Exceptions :   
     *   WHEN OTHERS - Catches and propagates errors without altering responses.   
     ************************************************************************/   
    FUNCTION calculate_similarity (   
        p_embedding1 IN VECTOR,   
        p_embedding2 IN VECTOR   
    ) RETURN NUMBER IS   
        l_distance NUMBER;   
    BEGIN   
        IF p_embedding1 IS NULL OR p_embedding2 IS NULL THEN   
            RETURN 0;   
        END IF;   
 
        l_distance := VECTOR_DISTANCE(p_embedding1, p_embedding2, COSINE);   
        RETURN GREATEST(0, LEAST(1, 1 - l_distance));   
    EXCEPTION   
 
        WHEN NO_DATA_FOUND THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'CALCULATE_SIMILARITY',   
                p_custom_message   => 'Record not found'   
            );   
 
        WHEN TOO_MANY_ROWS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'CALCULATE_SIMILARITY',   
                p_custom_message   => 'Too many rows returned'   
            );   
 
        WHEN VALUE_ERROR THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'CALCULATE_SIMILARITY',   
                p_custom_message   => 'Value conversion error'   
            );   
 
 
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'calculate_similarity',   
                p_custom_message   => 'Error in calculating similarity'   
            );   
    END calculate_similarity;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG;
/
