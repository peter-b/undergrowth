# Tools etc.
LC_SRC_DIR ?= ../livecode
LC_BUILD_DIR ?= $(LC_SRC_DIR)/build-linux-x86_64/livecode/out/Debug
LC_LCI_DIR = $(LC_BUILD_DIR)/modules/lci
LC_COMPILE ?= $(LC_BUILD_DIR)/lc-compile
LC_RUN ?= $(LC_BUILD_DIR)/lc-run
LC_TESTRUNNER_SRC ?= $(LC_SRC_DIR)/tests/lcb/_testrunner.lcb
LC_TESTLIB_SRC ?= $(LC_SRC_DIR)/tests/lcb/_testlib.lcb

BUILDDIR = _build
TESTDIR = _test

LC_COMPILE_FLAGS += --modulepath $(BUILDDIR) --modulepath $(LC_LCI_DIR)


# Source code
SOURCES = \
	mainloop.lcb \
	mainloop.test.lcb \
	callback.lcb \
	callback.test.lcb \
	log.lcb \
	_bits.lcb \
	_bits.test.lcb \
	_poll.lcb \
	_poll.test.lcb \
	_util.lcb \
	_testrunner.lcb \
	_testlib.lcb


LIB_SOURCES = $(filter-out %.test.lcb,$(SOURCES))
LIB_MODULES = $(patsubst %.lcb,$(BUILDDIR)/%.lcm,$(LIB_SOURCES))

TEST_SOURCES = $(filter %.test.lcb,$(SOURCES))
TEST_MODULES = $(patsubst %.lcb,$(BUILDDIR)/%.lcm,$(TEST_SOURCES))
TEST_LOGS = $(patsubst %.test.lcb,$(TESTDIR)/%.log,$(TEST_SOURCES))

################################################################
# Top-level targets
all: compile

compile: $(LIB_MODULES)
check-compile: $(TEST_MODULES)

check: check-compile compile
	-rm -rf $(TESTDIR)
	$(MAKE) test-suite.log

clean:
	-rm -rf $(BUILDDIR) $(TESTDIR) test-suite.log

.PHONY: all compile check-compile check clean

################################################################
# Build dependencies rules
include $(BUILDDIR)/deps.mk

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# We need to rewrite some of the rules to make sure that lcm files
# inherit the correct dependencies.  Specifically, we need to make
# sure that .lcm files depend on all the same things that their
# corresponding .lci file depends on.
$(BUILDDIR)/deps.mk: $(SOURCES) Makefile | $(BUILDDIR)
	@set -e; rm -f $@; \
	for lcb in $(SOURCES); do \
	  lcm=`echo $$lcb | sed 's/lcb/lcm/'` ; \
	  $(LC_COMPILE) $(LC_COMPILE_FLAGS) --deps make \
	    --output $(BUILDDIR)/$$lcm -- $$lcb >> $@; \
	done; \
	$(LC_COMPILE) $(LC_COMPILE_FLAGS) --deps make -- $(SOURCES) >> $@ ; \
	sed -i 's,\(.* \([^ ]*\)\.lcb\)$$,$(BUILDDIR)/\2.lcm \1,g' $@

################################################################
# Build rules
$(BUILDDIR)/%.lcm: %.lcb | $(BUILDDIR)
	$(LC_COMPILE) $(LC_COMPILE_FLAGS) --output $@ -- $<

################################################################
# Test infrastructure
#
# Add symlinks to the LCB testing modules
_testrunner.lcb:
	ln -s $(LC_TESTRUNNER_SRC) _testrunner.lcb
_testlib.lcb:
	ln -s $(LC_TESTLIB_SRC) _testlib.lcb

$(TESTDIR):
	mkdir -p $(TESTDIR)

# Run a test
TEST_RUNNER = $(BUILDDIR)/_testrunner.lcm
LC_RUN_CHECKFLAGS = $(addprefix -l ,$(filter-out $(TEST_RUNNER),$(LIB_MODULES)))

$(TESTDIR)/%.log: $(BUILDDIR)/%.test.lcm | $(TESTDIR)
	@$(LC_RUN) $(LC_RUN_CHECKFLAGS) -H RunModuleTests -- \
	    $(TEST_RUNNER) --lc-run "$(LC_RUN) $(LC_RUN_CHECKFLAGS)" \
	    $< > $@

test-suite.log: $(TEST_LOGS)
	@$(LC_RUN) $(LC_RUN_CHECKFLAGS) -H SummarizeTests -- \
	    $(TEST_RUNNER) --summary-log $@ $^
