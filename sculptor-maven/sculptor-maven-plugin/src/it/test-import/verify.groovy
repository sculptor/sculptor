File log = new File(basedir, 'build.log')
assert log.exists()
assert log.getText().contains("[INFO] Deleted status file: ")
assert log.getText().contains("[INFO] Created file : ")
assert log.getText().contains("[INFO] Generated ")
assert log.getText().contains("[INFO] Adding compile source directory ")
assert log.getText().contains("[INFO] BUILD SUCCESS")

assert 0 == log.getText().count("src/generated/java/com/acme/toimport/domain/ToImport.java")
