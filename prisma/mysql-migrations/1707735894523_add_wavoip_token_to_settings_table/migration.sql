-- Patch: adiciona coluna wavoipToken na tabela Instance (MySQL) quando ausente
-- Compatível com ambientes onde a tabela pode estar como `Instance` ou `instance`.

SET @db := DATABASE();

SET @tbl := (
  SELECT TABLE_NAME
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME IN ('Instance', 'instance')
  ORDER BY (TABLE_NAME = 'Instance') DESC
  LIMIT 1
);

SET @col_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = @tbl
    AND COLUMN_NAME = 'wavoipToken'
);

SET @sql := IF(
  @tbl IS NULL,
  'SELECT 1',
  IF(
    @col_exists = 0,
    CONCAT('ALTER TABLE `', @tbl, '` ADD COLUMN `wavoipToken` VARCHAR(100) NULL;'),
    'SELECT 1'
  )
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;