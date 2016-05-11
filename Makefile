VERSION := $(shell cat package.json | jq -r '.version')

deps: README.html
	npm install

release:
	zip -r opszero-aws-ec2-cleanup-$(VERSION).zip AwsEC2CleanupPolicy.json Makefile config.json index.js node_modules
	cp opszero-aws-ec2-cleanup-$(VERSION).zip output.zip
	curl -T opszero-aws-ec2-cleanup-$(VERSION).zip ftp://ftp.sendowl.com --user $(SENDOWL_FTP_USER):$(SENDOWL_FTP_PASSWORD)

README.html:
	emacs README.org --batch --eval '(org-html-export-to-html nil nil nil t)'  --kill
	echo "---" > docs.html.erb
	echo "title: AWS EC2 Cleanup with Lambda" >> docs.html.erb
	echo "layout: docs" >> docs.html.erb
	echo "---" >> docs.html.erb
	cat README.html >> docs.html.erb
	rm README.html
	mv docs.html.erb ../../acksin/acksin.com/source/solutions/aws-ec2-cleanup.html.erb
