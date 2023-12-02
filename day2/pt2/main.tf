
locals {

  // Read data
  input_data = split("\n", chomp(file(var.input_file)))

  // Get the column containing "Game #"
  game_id_col = [ for g in local.input_data : split(":", g)[0] ]

  // Extract the game id number
  game_id_num = [ for g in local.game_id_col : split(" ", g)[1] ]

  // Get the game hands column "red 4; blue 4, green 2" .. basically everything after the ':'
  game_rounds_txt = [ for g in local.input_data : split(":", g)[1] ] 

  // Split the game hands column into a list of hands (as strings)
  // Each element is like "3 blue, 4 red"
  game_rounds_obj = [ for g in local.game_rounds_txt : split(";", g) ]

  // For each game, get the number of each color used in each draw from the bag
  game_round_red = [ for g in local.game_rounds_obj : [ for hand in g : flatten(regexall("(\\d+) red", hand)) ] ]
  game_round_green = [ for g in local.game_rounds_obj : [ for hand in g : flatten(regexall("(\\d+) green", hand)) ] ]
  game_round_blue = [ for g in local.game_rounds_obj : [ for hand in g : flatten(regexall("(\\d+) blue", hand)) ] ]

  // Get the highest number of any given color cubes per game
  game_round_max_red = [ for g in local.game_round_red : max(flatten(g)...) ]
  game_round_max_green = [ for g in local.game_round_green : max(flatten(g)...) ]
  game_round_max_blue = [ for g in local.game_round_blue : max(flatten(g)...)]

}

// To make it easy, save the games into a null_resource so we can refer to the values easier
resource "null_resource" "game_color_maxes" {
  count = length(local.input_data)
  triggers = {
    game_id = tostring(count.index + 1)
    max_red = tostring(element(local.game_round_max_red, count.index))
    max_green = tostring(element(local.game_round_max_green, count.index))
    max_blue = tostring(element(local.game_round_max_blue, count.index))
  }
}

locals {

  // We already have the max values for each color... the max values for each color
  //   just happens to be the minimum number of cubes we need ;)
  // So multiply them all together for the cube power number we need
  cube_power = [ for g in null_resource.game_color_maxes :
      ( tonumber(g.triggers.max_red)
        * tonumber(g.triggers.max_green)
	* tonumber(g.triggers.max_blue) ) ]

  // Add up the cube powers for all games to get the solution
  cube_power_sum = sum(local.cube_power)

}

output "solution" {
  value = local.cube_power_sum
}

