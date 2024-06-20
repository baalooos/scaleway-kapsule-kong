terraform {
    required_providers {
        scaleway = {
            source = "scaleway/scaleway"
            //version = "2.2.1-rc.3"
        }
    }
    required_version = ">= 0.13"

    backend "s3" {
        bucket                      = "ceg-test-env"
        key                         = "scaleway-kapsule-kong/terraform.tfstate"
        region                      = "fr-par"
        endpoint                    = "https://s3.fr-par.scw.cloud"
        profile                     = "scaleway"
        skip_credentials_validation = true
        skip_region_validation      = true
    }
}

provider "scaleway" {
    profile = "test"
}
