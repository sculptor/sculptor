File log = new File(basedir, 'build.log')
assert log.exists()
assert log.getText().contains("[INFO] Generated ")
assert log.getText().contains("[INFO] BUILD SUCCESS")

assert 0 == log.getText().count("src/generated/java/com/acme/toimport/domain/ToImport.java")
