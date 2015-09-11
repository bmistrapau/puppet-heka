# The PayloadEncoder simply extracts the payload from the provided Heka message and converts it into a byte stream for delivery to
# an external resource.
#
# === Parameters:
#
# $append_newlines::              Specifies whether or not a newline character (i.e. n) will be appended to the captured message
#                                 payload before serialization.
#                                 Defaults to true.
#
# $prefix_ts::                    Specifies whether a timestamp will be prepended to the captured message payload before
#                                 serialization.
#                                 Defaults to false.
#
# $ts_from_message::              If true, the prepended timestamp will be extracted from the message that is being processed.
#                                 If false, the prepended timestamp will be generated by the system clock at the time of message
#                                 processing.
#                                 Defaults to true. This setting has no impact if prefix_ts is set to false.
#
# $ts_format::                    Specifies the format that should be used for prepended timestamps, using the standard strftime
# string format.
#                                 Defaults to [%Y/%b/%d:%H:%M:%S %z].
#                                 If the specified format string does not end with a space character, then a space will be inserted
#                                 between the formatted timestamp and the payload.
#

define heka::encoder::payloadencoder (
  $append_newlines = true,
  $prefix_ts       = true,
  $ts_from_message = true,
  $ts_format       = '%Y/%b/%d:%H:%M:%S %z'
) {
  validate_bool($append_newlines)
  validate_bool($prefix_ts)
  validate_bool($ts_from_message)
  validate_string($ts_format)

  heka::snippet { $name: content => template("${module_name}/encoder/payloadencoder.toml.erb"), }
}