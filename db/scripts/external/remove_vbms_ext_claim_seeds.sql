DELETE FROM PRIORITY_END_PRODUCT_SYNC_QUEUE;

DELETE FROM BATCH_PROCESSES;

DELETE FROM VBMS_EXT_CLAIM;

DELETE FROM REQUEST_ISSUES
WHERE
  EXISTS(
    SELECT
      *
    FROM
      END_PRODUCT_ESTABLISHMENTS EPE
    WHERE
      END_PRODUCT_ESTABLISHMENT_ID = EPE.ID
      AND VETERAN_FILE_NUMBER LIKE '0003%'
  );

DELETE FROM HIGHER_LEVEL_REVIEWS
WHERE
  VETERAN_FILE_NUMBER LIKE '0003%';

DELETE FROM SUPPLEMENTAL_CLAIMS
WHERE
  VETERAN_FILE_NUMBER LIKE '0003%';

DELETE FROM END_PRODUCT_ESTABLISHMENTS
WHERE
  VETERAN_FILE_NUMBER LIKE '0003%';

DELETE FROM VETERANS
WHERE
  FILE_NUMBER LIKE '0003%';
