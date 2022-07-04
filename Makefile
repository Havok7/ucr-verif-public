# melvin.alvarado


INSTALL ?= 0
VERSION ?= v0.0.2
#VERSION ?= v0.0.1
PLANET ?= naboo
#PLANET ?= tatooine

IMG = mjalvar/vivado-$(PLANET):$(VERSION)
RST = $(shell find ./* -iname "*.rst" -o -iname "*.py" -o -iname "*.css" -o -iname "*.png" -o -iname "*.jpg")

DUT_LIST = $(shell find sources/*/rtl/ -iname "*.v" |grep -v mem-control)
targets = $(addsuffix .o, $(basename $(DUT_LIST)))

MOUNT = -v $(shell pwd)/sources:/home/developer/code/:rw  \
	-v $(shell pwd)/test-sim:/home/developer/test-sim/:rw
ifeq ($(INSTALL),1)
	MOUNT += -v $(PWD)/docker/install:/tmp/install/:rw
endif


run:
	@echo Launching docker $(PLANET)
	@docker run -ti --rm --network=host -e DISPLAY=$$DISPLAY -h $(PLANET) \
		-w /home/developer $(MOUNT) \
		-u root $(IMG) bash

pull:
	docker pull $(IMG)

draw: $(targets)
$(targets):
	@echo $* $(*F)
	symbolator -i $*.v -f png --title $(*F) -o sphinx/media

.PHONY: doc
doc: .doc.timestamp

.doc.timestamp: $(RST)
	@ rm -rf doc
	@echo $(RST)
	@mkdir -p doc
	make -C sphinx html
	make -C sphinx/ppt revealjs
	mv sphinx/_build/html doc/html
	mv sphinx/ppt/_build/revealjs doc/revealjs
	cp -r sphinx/_main/* doc/
	touch .doc.timestamp
