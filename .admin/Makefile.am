CLOCAL_AMFLAGS = -I config/m4 -I aclocal
ACLOCAL_AMFLAGS = -I config/m4 -I aclocal
VENV = .venv
PYTHON = $(VENV)/bin/python3

.PHONY: clean docker python

bom:
	. $(PY39)/bin/activate && \
	pip install -r .admin/src/requirements.txt && \
	python .admin/src/generate_bom.py -d ../recipes -o ../BOM.md
	
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
	@$(PY39) -m venv .venv
	( \
		. $(VENV)/bin/activate; \
		$(VENV)/bin/python -m pip install --upgrade pip; \
		$(VENV)/bin/python -m pip install -r src/requirements.txt; \
	)
