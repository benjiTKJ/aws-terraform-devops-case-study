#!/bin/bash

declare -a env_array=("prod" "staging")
env_array_length=${#env_array[@]}

selectEnvironment(){
    echo "Select environment to deploy"
    index=0
    for item in ${env_array[@]}
    do
        echo "$index) $item"
        index=$((index+1))
    done
    read environment
    if [ $environment -lt $env_array_length ] && [ -n "$environment" ]
    then
        environment=${env_array[$environment]}
    else
        echo "Invalid choice of environment $environment , Please re-run"
        exit 1
    fi
}

runTerraformCommands(){
    echo "You have choosen to deploy to $environment"
    echo "Enter y to confirm"
    read confirm
    if [ "$confirm" != "y" ]
    then
        echo "Please re-run"
        exit 1
    fi
    echo 
    cd template
    terraform init -upgrade -backend-config=../"$environment"/backend.hcl
    terraform plan -var-file=../"$environment"/terraform.tfvars
    terraform apply -var-file=../"$environment"/terraform.tfvars
}

set -e
selectEnvironment
selectCountry
runTerraformCommands