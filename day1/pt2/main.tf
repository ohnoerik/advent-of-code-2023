locals {

  // This normalizes both numeric and text numbers to their actual (stringified) digits
  lookup_table = {
    "1" = "1"
    "2" = "2"
    "3" = "3"
    "4" = "4"
    "5" = "5"
    "6" = "6"
    "7" = "7"
    "8" = "8"
    "9" = "9"
    one = "1"
    two = "2"
    three = "3"
    four = "4"
    five = "5"
    six = "6"
    seven = "7"
    eight = "8"
    nine = "9"
  }

  // Read input file, split into lines
  input_data = split("\n", chomp(file(var.input_file)))

  // Grab the first number we find in a line, whether it's a digit or string 
  lines_digits_start = [ for line in local.input_data : element(flatten(regexall("(three|seven|eight|four|five|nine|one|two|six|\\d)", line)), 0) ]

  // Convert first number to string for easier processing
  lines_digits_start_str = [ for n in local.lines_digits_start : tostring(n) ]

  // Normalize number so digits/text become the (string) digit
  lines_digits_start_mapped = [ for n in local.lines_digits_start_str : lookup(local.lookup_table, n)]

  // To find the last digit, we're going to reverse the string (lol)
  lines_digits_reversed = [ for line in local.input_data : strrev(line) ]

  // And find digits and text numbers, but backwards!
  lines_digits_last_rev = [ for line in local.lines_digits_reversed: element(flatten(regexall("(eno|owt|eerht|ruof|evif|xis|neves|thgie|enin|\\d)", line)), 0) ]

  // And now make sure it's all text
  lines_digits_last_rev_str = [ for n in local.lines_digits_last_rev : tostring(n) ]

  // Reverse the numbers/digits back to normal
  lines_digits_last_fixed = [ for line in local.lines_digits_last_rev_str : strrev(line) ]
 
  // Normalize the digits/numbers
  lines_digits_last_mapped = [ for n in local.lines_digits_last_fixed : lookup(local.lookup_table, n)]

}

// Time to abuse the null_resource! We need something that can count from 0..(number of lines in file).
// Combine the first and last digit together as a string
resource "null_resource" "combined_number" {
  count = length(local.input_data)
  triggers = {
    number = join("", [
    	element(local.lines_digits_start_mapped, count.index),
	element(local.lines_digits_last_mapped, count.index)]
	)
  }
}

locals {

  // Convert each stringified number into a number
  lines_results = [ for num in null_resource.combined_number : tonumber(num.triggers.number) ]

  // Sum up the numbers
  total_sum = sum(local.lines_results)

}

output "solution" {
  value = local.total_sum
}
