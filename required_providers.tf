terraform {
    required_providers {
        openstack = {
            source = "terraform-provider-openstack/openstack"
            version = "1.33.0"
        }
	mcs = {
            source = "local/provider/mcs"
      	    version = ">=0.1.0"
        }
    }
}
