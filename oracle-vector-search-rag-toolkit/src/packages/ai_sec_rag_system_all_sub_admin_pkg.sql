create or replace PACKAGE "AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG" IS   
    /* ==================================================================   
       PACKAGE    :  AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG   
       GENERATED ON  :  2026-04-06   
       DESCRIPTION   :  Refactored package for AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG.   
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
     * Procedure : populate_from_all_lookups;   
     * Purpose   : Populate From All Lookups;   
     ************************************************************************/   
    PROCEDURE populate_from_all_lookups;   
 
    /************************************************************************   
     * Procedure : refresh_missing_embeddings;   
     * Purpose   : Refresh Missing Embeddings;   
     ************************************************************************/   
    PROCEDURE refresh_missing_embeddings;   
 
    /************************************************************************   
     * Function  : check_system_health   
     * Purpose   : Check System Health   
     ************************************************************************/   
    FUNCTION check_system_health RETURN CLOB;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG;
/

create or replace PACKAGE BODY "AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG" IS   
    /* ==================================================================   
       PACKAGE BODY    :  AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG   
       GENERATED ON  :  2026-04-06   
       ================================================================== */   
    PROCEDURE populate_from_all_lookups IS   
        l_count NUMBER := 0;   
    BEGIN   
        FOR r IN (SELECT DISTINCT patient_id FROM ai_sec_sys_view_patient_full_history_lookup ORDER BY patient_id) LOOP   
            AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.populate_ai_from_lookup_for_patient(r.patient_id);   
            l_count := l_count + 1;   
            IF MOD(l_count, 10) = 0 THEN   
                DBMS_OUTPUT.PUT_LINE('Processed ' || l_count || ' patients...');   
                COMMIT;   
            END IF;   
        END LOOP;   
 
        COMMIT;   
        DBMS_OUTPUT.PUT_LINE('Population complete. Processed ' || l_count || ' patients.');   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'populate_from_all_lookups',   
                p_custom_message   => 'Error in populate from all lookups'   
            );   
    END populate_from_all_lookups;   
 
    PROCEDURE refresh_missing_embeddings IS   
        l_count NUMBER := 0;   
    BEGIN   
        -- Refresh Document Embeddings
        FOR r IN (   
            SELECT DOC_ID, doc_text   
            FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS   
            WHERE embedding IS NULL   
              AND doc_text IS NOT NULL   
              AND is_chunked = 0 
        ) LOOP   
            BEGIN   
                UPDATE AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS   
                SET embedding = AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding_from_clob(r.doc_text)   
                WHERE DOC_ID = r.DOC_ID;   
 
                l_count := l_count + 1; 
                CASE MOD(l_count, 100)  WHEN 0 THEN COMMIT;  END CASE; 
            EXCEPTION   
                WHEN OTHERS THEN   
                    AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                        p_source_procedure => 'refresh_missing_embeddings',   
                        p_custom_message   => 'Error in refreshing missing document embeddings'   
                    );   
            END;   
        END LOOP;   
 
        -- Refresh Chunk Embeddings 
        FOR r IN (   
            SELECT CHUNK_ID, chunk_text   
            FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS   
            WHERE embedding IS NULL   
              AND chunk_text IS NOT NULL   
        ) LOOP   
            BEGIN   
                UPDATE AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENT_CHUNKS   
                SET embedding = AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding_from_clob(r.chunk_text)   
                WHERE CHUNK_ID = r.CHUNK_ID;   
 
                l_count := l_count + 1; 
                CASE MOD(l_count, 100)  WHEN 0 THEN COMMIT;  END CASE; 
            EXCEPTION   
                WHEN OTHERS THEN   
                    AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                        p_source_procedure => 'refresh_missing_embeddings',   
                        p_custom_message   => 'Error in refreshing missing chunk embeddings'   
                    );   
            END;   
        END LOOP;   
 
        COMMIT;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'refresh_missing_embeddings',   
                p_custom_message   => 'Error in refreshing missing embeddings'   
            );   
    END refresh_missing_embeddings;   
 
    FUNCTION check_system_health RETURN CLOB IS   
        l_report                    CLOB;   
        l_total_docs                NUMBER;   
        l_total_patients            NUMBER;   
        l_avg_doc_size              NUMBER;   
        l_index_exists              NUMBER;   
        l_embedding_test_result     NUMBER;   
        l_bad_dim                   NUMBER := 0;   
        l_dimension_count           NUMBER;   
        l_dimension_format          VARCHAR2(100);   
    BEGIN   
        l_total_docs := AI_SEC_RAG_SYSTEM_ALL_SUB_DAO_PKG.get_document_count();   
 
        SELECT COUNT(DISTINCT patient_id) INTO l_total_patients FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS;   
 
        SELECT AVG(DBMS_LOB.GETLENGTH(doc_text)) INTO l_avg_doc_size   
        FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS   
        WHERE doc_text IS NOT NULL;   
 
        SELECT COUNT(*) INTO l_index_exists FROM user_indexes WHERE index_name = 'IDX_AI_EMBEDDING';   
 
        DECLARE   
            l_test_embedding VECTOR;   
        BEGIN   
            l_test_embedding := AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding('test');   
            l_embedding_test_result := CASE WHEN l_test_embedding IS NOT NULL THEN 1 ELSE 0 END;   
        END;   
 
        BEGIN   
            SELECT COUNT(*) INTO l_bad_dim   
            FROM AI_SEC_RAG_SYSTEM_L_HELP_AI_DOCUMENTS   
            WHERE embedding IS NOT NULL   
              AND VECTOR_DIMS(embedding) != 384;   
        EXCEPTION   
            WHEN OTHERS THEN   
                AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                    p_source_procedure => 'check_system_health',   
                    p_custom_message   => 'Error in checking system health bad dims'   
                );   
        END;   
 
        BEGIN   
            select vector_dimension_count(embedding)   
            into l_dimension_count   
            from ai_sec_rag_system_l_help_ai_documents   
            where embedding is not null   
            and VECTOR_DIMENSION_COUNT(AI_SEC_RAG_SYSTEM_ALL_SUB_EMBED_PKG.generate_embedding('check for my'))   
            and rownum = 1;   
        EXCEPTION   
            WHEN OTHERS THEN   
                l_dimension_count := 0; 
        END;   
 
        BEGIN   
            select vector_dimension_format(embedding)   
            into l_dimension_format   
            from ai_sec_rag_system_l_help_ai_documents   
            where embedding is not null   
            and rownum = 1;   
        EXCEPTION   
            WHEN OTHERS THEN   
                l_dimension_format := 'N/A'; 
        END;   
 
        l_report := 'Medical RAG System Health Report' || CHR(10) ||   
                   '=================================' || CHR(10) ||   
                   'Timestamp: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || CHR(10) ||   
                   'Total Documents: ' || NVL(TO_CHAR(l_total_docs), '0') || CHR(10) ||   
                   'Total Patients: ' || NVL(TO_CHAR(l_total_patients), '0') || CHR(10) ||   
                   'Average Document Size: ' || NVL(TO_CHAR(l_avg_doc_size), '0') || ' chars' || CHR(10) ||   
                   'Vector Index Exists: ' || CASE WHEN l_index_exists = 1 THEN 'YES' ELSE 'NO' END || CHR(10) ||   
                   'Embedding Generation: ' || CASE WHEN l_embedding_test_result = 1 THEN 'WORKING' ELSE 'FAILED' END || CHR(10) ||   
                   'Incorrect Dimensions: ' || CASE WHEN l_bad_dim > 0 THEN TO_CHAR(l_bad_dim) || ' (WARNING)' ELSE '0 (OK)' END || CHR(10) ||   
                   'Dimension Format Vector: ' || NVL(TO_CHAR(l_dimension_format), '') || CHR(10) ||   
                   'Dimension Vector: ' || NVL(TO_CHAR(l_dimension_count), '0') || CHR(10) ||   
                   'Overall Status: ' || CASE WHEN l_total_docs > 0 AND l_index_exists = 1 AND l_embedding_test_result = 1 AND l_bad_dim = 0 THEN 'HEALTHY' ELSE 'NEEDS ATTENTION' END;   
 
        RETURN l_report;   
    EXCEPTION   
        WHEN OTHERS THEN   
            AI_SEC_RAG_SYSTEM_ALL_SUB_ERR_HANDLER_PKG.log_error_and_raise(   
                p_source_procedure => 'check_system_health',   
                p_custom_message   => 'Error in checking system health'   
            );   
    END check_system_health;   
END AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG;
/
