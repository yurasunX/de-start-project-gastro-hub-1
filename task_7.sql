BEGIN;

-- Блокируем таблицу cafe.managers в режиме SHARE.
-- Этот режим позволяет другим пользователям читать таблицу,
-- но не позволяет изменять её до завершения нашей транзакции.
-- Это соответствует условию: managers доступна для чтения,
-- но недоступна для изменений.

LOCK TABLE cafe.managers IN SHARE MODE;

-- Добавляем новое поле для массива телефонов.
-- Первый элемент массива — новый номер,
-- второй элемент массива — старый номер.

ALTER TABLE cafe.managers
ADD COLUMN manager_phones varchar[];

-- Нумеруем менеджеров по алфавиту.
-- ROW_NUMBER() начинает нумерацию с 1,
-- поэтому добавляем 99, чтобы первый номер был 100.
-- CONCAT формирует номер вида 8-800-2500-100.

WITH numbered_managers AS (
    SELECT
        manager_uuid,
        manager_phone AS old_phone,
        CONCAT(
            '8-800-2500-',
            ROW_NUMBER() OVER (
                ORDER BY manager_name
            ) + 99
        ) AS new_phone
    FROM cafe.managers
)
UPDATE cafe.managers m
SET manager_phones = ARRAY[
    nm.new_phone,
    nm.old_phone
]
FROM numbered_managers nm
WHERE m.manager_uuid = nm.manager_uuid;

-- Удаляем старое поле manager_phone,
-- потому что старый и новый номера теперь хранятся в массиве.

ALTER TABLE cafe.managers
DROP COLUMN manager_phone;

COMMIT;
