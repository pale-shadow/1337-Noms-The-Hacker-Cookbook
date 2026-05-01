CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal
VENV = /tmp/venv

.PHONY: bom clean python

bom:
	. $(VENV)/bin/activate && \
	$(PYTHON) -m pip install -r src/requirements.txt && \
	$(PYTHON) src/generate_bom.py -d ../recipes -o ../BOM.md
	
clean:
	rm -rf $(VENV)
        find . -type d -name "__pycache__" -exec rm -rf {} +
	@for trash in aclocal.m4 autom4te.cache config config.log config.status configure configure~ \
		libtool Makefile Makefile.in; do \
		if [ -f $$trash ] || [ -d $$trash ]; then \
			echo "Removing $$trash" ;\
			rm -rf $$trash ;\
		fi ; \
	done
	docker system prune -y

lint:
	$(VENV)/bin/isort src/*.py
	$(VENV)/bin/black src/*.py

python: 
	@$(PYTHON) -m venv $(VENV)
	( \
		. $(VENV)/bin/activate; \
		$(PYTHON) -m pip install -r src/requirements.txt; \
	)
