all:
tag:
	git tag -s $(shell date +%Y%m%dT%H%M%SZ -u)

# This is a helper for infra
update-puppet-to-tag:
	OLD_COMMIT=$$(grep -o '20.*[0-9]Z' ../puppet/dist/www/manifests/infra_status.pp); \
	NEW_COMMIT=$$(git describe --tags); \
	sed -i -e "/.vcs_tag = /s/$${OLD_COMMIT}/$${NEW_COMMIT}/"  ../puppet/dist/www/manifests/infra_status.pp; \
	{ printf "www: infra_status: update\n\n" ; git shortlog $${OLD_COMMIT}..$${NEW_COMMIT} ; } | git -C ../puppet commit --signoff dist/www/manifests/infra_status.pp -F -;
