data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "aks" {
  name                = "bcloudaks"
  resource_group_name = var.RESOURCE_GROUP_NAME
}

resource "azurerm_key_vault" "key_vault" {
  name                = "keyvault-2bcloud"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Update",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Delete",
      "Create",
      "Import",
      "Update",
      "ManageContacts",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
      "ManageIssuers",
      "Recover",
      "Backup",
      "Restore",
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "5d47dcbc-89df-4abc-a1e0-2b7f168a9dc0"  # Replace with your actual object ID

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Update",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Delete",
      "Create",
      "Import",
      "Update",
      "ManageContacts",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
      "ManageIssuers",
      "Recover",
      "Backup",
      "Restore",
    ]
  }
  # Access policy for AKS managed identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_kubernetes_cluster.aks.identity[0].principal_id

    secret_permissions = [
      "Get",
      "List",
    ]
  }  
}  


# Create a VM
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-2bcloud"
  address_space       = ["10.0.0.0/16"]
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = var.RESOURCE_GROUP_NAME
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "bcloud-pip"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  allocation_method   = "Static"
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "bcloud-nsg"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME

  security_rule = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow SSH"
      source_port_ranges         = []
      source_address_prefixes    = []
      destination_port_ranges    = []
      destination_address_prefixes = []
      source_application_security_group_ids = []
      destination_application_security_group_ids = []
    },
    {
      name                       = "HTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP"
      source_port_ranges         = []
      source_address_prefixes    = []
      destination_port_ranges    = []
      destination_address_prefixes = []
      source_application_security_group_ids = []
      destination_application_security_group_ids = []
    },
    {
      name                       = "HTTPS"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTPS"
      source_port_ranges         = []
      source_address_prefixes    = []
      destination_port_ranges    = []
      destination_address_prefixes = []
      source_application_security_group_ids = []
      destination_application_security_group_ids = []
    }
  ]
}



resource "azurerm_network_interface" "nic" {
  name                = "nic-bcloud"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Network Interface Association
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "Jenkins_Server"
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  size                = "Standard_D2s_v3"

  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb        =  "64"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }


  computer_name = "jenkins-server"  # Explicitly set a valid computer name

  custom_data = file("metadata/jenkins-init-base64")
}

