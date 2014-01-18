File log = new File(basedir, 'build.log')
assert log.exists()
assert log.getText().contains("SculptorGeneratorException: Could not find an attribute 'libraryId' in domain object 'Media'. Add gap to repository operation 'findMediaByName' in repository 'MediaRepository'")
assert log.getText().contains("[INFO] BUILD FAILURE")
