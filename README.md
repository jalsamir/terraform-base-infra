# terraform-base-infra

### It creates mgmt vpc for management/operation specific application ie Domain, Anti Virus, Deployment/CI-CD Applications.

### It creates pres vpc for presentation/bussiness application ie Database, Web Servers etc.
# Create tfvars file before running this
	access_key = "access key"
	secret_key = "secret key"
	key_name = "key pair"
	ip_range = "you public ip for whitelist rdp access"
	mgmt = "Mgmt"
	pres = "Pres"
	preprodacc = "your aws account id"
	prodacc = "your aws account id"
