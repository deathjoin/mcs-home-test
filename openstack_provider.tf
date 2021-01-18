provider "openstack" {
    # Your user account.
    user_name = var.mcs_login

    # The password of the account
    password = var.mcs_password

    # The tenant token can be taken from the project Settings tab - > API keys.
    # Project ID will be our token.
    tenant_id = var.mcs_project_id

    # The indicator of the location of users.
    user_domain_name = "users"
    project_domain_id = "7aa9aefba7ab465cb122052125e77c8f"

    # API endpoint
    # Terraform will use this address to access the MCS api.
    auth_url = "https://infra.mail.ru:35357/v3/"

    # use octavia to manage load balancers
    use_octavia = true
}
