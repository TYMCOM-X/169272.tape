SCHEMA tmp
BEGIN
  FIELD
    file.spec AS "10C"
  RELATION all.files IS KEY file.spec
  END
  