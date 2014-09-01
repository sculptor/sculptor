File log = new File(basedir, 'build.log')
assert log.exists()
assert log.getText().contains("Generated: src/generated/java/com/acme/library/domain/MediaBuilder.java")
assert log.getText().contains("[INFO] BUILD SUCCESS")
