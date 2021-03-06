# Calculates the most frequent items in a data stream.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Filter Parameters::    Check heka::filter::sandboxfilter for the description
#
### Buffering::                   Check heka::filter::sandboxfilter for the description
#
### Common Sandbox Parameters::   Check heka::filter::sandboxfilter for the description
#
### Frequent Items Parameters
#
# $message_variable::             The message variable name containing the items to be counted.
#                                 Type: string
#
# $max_items::                    The maximum size of the sample set (higher will produce a more accurate list).
#                                 Default 1000
#                                 Type: uint
#
# $min_output_weight::            Used to reduce the long tail output by only outputting the higher frequency items.
#                                 Default 100
#                                 Type: uint
#
# $reset_days::                   Resets the list after the specified number of days (on the UTC day boundary).
#                                 A value of 0 will never reset the list.
#                                 Default 1
#                                 Type: uint
#
define heka::filter::frequentitems (
  $ensure              = 'present',
  # Common Filter Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = undef,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
  # Common Sandbox Parameters
  $preserve_data       = undef,
  $memory_limit        = undef,
  $instruction_limit   = undef,
  $output_limit        = undef,
  $module_directory    = undef,
  # Frequent Items Parameters
  # lint:ignore:parameter_order
  $message_variable,
  # lint:endignore
  $max_items           = undef,
  $min_output_weight   = undef,
  $reset_days          = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Filter Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $can_exit { validate_bool($can_exit) }
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # Frequent Items Parameters
  validate_integer($max_items, $min_output_weight, $reset_days)

  $script_type = 'lua'
  $filename = 'lua_filters/frequent_items.lua'
  $config = {
    'message_variable'  => $message_variable,
    'max_items'         => $max_items,
    'min_output_weight' => $min_output_weight,
    'reset_days'        => $reset_days,
  }

  $full_name = "frequentitems_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}
