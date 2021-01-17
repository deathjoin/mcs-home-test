provider "mcs" {
    # Your user account.
    username = var.mcs_login

    # The password of the account
    password = var.mcs_password

    # The tenant token can be taken from the project Settings tab - > API keys.
    # Project ID will be our token.
    project_id = var.mcs_project_id
}
