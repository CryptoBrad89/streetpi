SWIFT ?= swift

.PHONY: test-core

test-core:
	$(SWIFT) test --package-path StreetPiCore
