# frozen_string_literal: true

require "pg"

conn = CaseflowRecord.connection
conn.execute("CREATE TABLE CASEFLOW_AUDIT.PRIORITY_END_PRODUCT_SYNC_QUEUE_AUDIT (
              ID BIGSERIAL PRIMARY KEY UNIQUE NOT NULL,
              TYPE_OF_CHANGE CHAR(1) NOT NULL,
              PRIORITY_END_PRODUCT_SYNC_QUEUE_ID BIGINT NOT NULL,
              END_PRODUCT_ESTABLISHMENT_ID BIGINT NOT NULL REFERENCES END_PRODUCT_ESTABLISHMENTS(ID),
              BATCH_ID UUID REFERENCES BATCH_PROCESSES(BATCH_ID),
              STATUS VARCHAR(50) NOT NULL,
              CREATED_AT TIMESTAMP WITHOUT TIME ZONE,
              LAST_BATCHED_AT TIMESTAMP WITHOUT TIME ZONE,
              AUDIT_CREATED_AT TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
              ERROR_MESSAGES TEXT[]
            );")
conn.close
