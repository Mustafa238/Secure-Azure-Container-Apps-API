output "action_group_id" {
  description = "ID of the email action group"
  value       = azurerm_monitor_action_group.email_action_group.id
}

output "action_group_name" {
  description = "Name of the email action group"
  value       = azurerm_monitor_action_group.email_action_group.name
} 