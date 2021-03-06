# The Logstreamer plugin scans, sorts, and reads logstreams in a sequential user-defined order,
# differentiating multiple logstreams found in a search based on a user-defined differentiator.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters::     Check heka::inputs::tcpinput for the description
#
### Logstreamer Input Parameters
#
# $hostname::                     The hostname to use for the messages, by default this will be the machine's qualified hostname.
#                                 This can be set explicitly to ensure it's the correct name in the event the machine has multiple
#                                 interfaces/hostnames.
#                                 Type: string
#
# $oldest_duration::              A time duration string (e.x. "2s", "2m", "2h"). Logfiles with a last modified time older than
#                                 oldest_duration ago will not be included for parsing.
#                                 Defaults to "720h" (720 hours, i.e. 30 days).
#                                 Type: string
#
# $journal_directory::            The directory to store the journal files in for tracking the location that has been read to thus
#                                 far.
#                                 Default: heka's base directory.
#                                 Type: string
#
# $log_directory::                The root directory to scan files from. This scan is recursive so it should be suitably restricted
#                                 to the most specific directory this selection of logfiles will be matched under. The log_directory
#                                 path will be prepended to the file_match.
#                                 Type: string
#
# $rescan_interval::              During logfile rotation, or if the logfile is not originally present on the system, this interval
#                                 is how often the existence of the logfile will be checked for. This interval is in milliseconds.
#                                 Default of 5 seconds
#                                 Type: int
#
# $file_match::                   Regular expression used to match files located under the log_directory. This regular expression has $
#                                 added to the end automatically if not already present, and log_directory as the prefix.
#                                 WARNING: file_match should typically be delimited with single quotes, indicating use of a raw string, rather
#                                 than double quotes, which require all backslashes to be escaped. For example, 'access\.log' will
#                                 work as expected, but "access\.log" will not, you would need "access\\.log" to achieve the same result.
#                                 Type: string
#
# $priority::                     When using sequential logstreams, the priority is how to sort the logfiles in order from oldest to
#                                 newest.
#                                 Type: string
#
# $differentiator::               When using multiple logstreams, the differentiator is a set of strings that will be used in the
#                                 naming of the logger, and portions that match a captured group from the file_match will have their
#                                 matched value substituted in.
#                                 Type: [string]
#
# $translation::                  A set of translation mappings for matched groupings to the ints to use for sorting purposes.
#                                 Type: hash of hashes, or array of hash of hashes ($translation = {'Month' => {'hadukannas' => 1}})
#
define heka::inputs::logstreamerinput (
  $ensure               = 'present',
  # Common Input Parameters
  $decoder              = undef,
  $synchronous_decode   = false,
  $send_decode_failures = false,
  $can_exit             = undef,
  $splitter             = 'TokenSplitter',
  $log_decode_failures  = true,
  # LogstreamerInput specific Parameters
  $hostname             = undef,
  $oldest_duration      = undef,
  $journal_directory    = undef,
  # lint:ignore:parameter_order
  $log_directory,
  $file_match,
  # lint:endignore
  $rescan_interval      = undef,
  $priority             = undef,
  $differentiator       = undef,
  $translation          = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # LogstreamerInput specific Parameters
  if $hostname { validate_string($hostname) }
  if $oldest_duration { validate_string($oldest_duration) }
  if $journal_directory { validate_string($hostname) }
  if $log_directory { validate_string($log_directory) }
  if $rescan_interval { validate_integer($rescan_interval) }
  if $file_match { validate_string($file_match) }
  if $priority { validate_array($priority) }
  if $differentiator { validate_array($differentiator) }
  if $translation { validate_hash($translation) }

  $full_name = "logstreamerinput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/logstreamerinput.toml.erb"),
  }
}
