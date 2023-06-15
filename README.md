# k8s

#provisionning kuberneters cluster on aws sandbox

ENV: Windows

Make sure to already generate ssh key named "id_rsa" on your local machine 

On your cmd or terminal

- clone repository

- go to directory

- terraform init && terraform plan &&  terraform apply

connect to controler node and one or two worker node depend on how you setup your cluster
ec2 environnement: Red Hat
ssh cec2-user@<public_ip>

check whenever kube config tools are setup
