all: help

doc: ## Update package documentation with `roxygen2`
	Rscript -e "roxygen2::roxygenise()"; \

check: ## Run `rcmdcheck`
	Rscript -e 'rcmdcheck::rcmdcheck()'

test: ## Run test suite
	Rscript -e 'devtools::load_all(); testthat::test_local()'

pkgcheck: ## Run `pkgcheck` and print results to screen.
	Rscript -e 'library(pkgcheck); checks <- pkgcheck(); print(checks); summary (checks)'

clean: ## Clean all temp and cached files
	rm -rf *.html *.png README_cache 

help: ## Show this help
	@printf "Usage:\033[36m make [target]\033[0m\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Phony targets:
.PHONY: doc
.PHONY: check
.PHONY: help
