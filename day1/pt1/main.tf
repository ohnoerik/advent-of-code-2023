locals {

  // Read input file, split into lines
  input_data = split("\n", chomp(file(var.input_file)))

  // Get all digits in each line
  lines_digits = [ for line in local.input_data : flatten(regexall("(\\d)", line)) ]

  // Get the first digit of each line
  lines_first_digits = [ for d in local.lines_digits : element(d, 0)]
  
  // Get the last digit of each line
  lines_last_digits = [ for d in local.lines_digits : element(d, length(d)-1)]

}

// Combine the first and last digit together as a string
resource "null_resource" "combined_number" {
  count = length(local.lines_digits)

  triggers = {
    number = join("", [
    	element(local.lines_first_digits, count.index),
	element(local.lines_last_digits, count.index)]
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
