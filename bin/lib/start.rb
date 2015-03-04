def start_sweatshop(for_environment:)
  eye_config = "#{__dir__}/../../robot_sweatshop.#{for_environment}.eye"
  output = `eye load #{eye_config}`
  if $?.exitstatus != 0
    notify :failure, output
  else
    notify :success, 'Robot Sweatshop loaded'
    notify :info, `eye restart robot_sweatshop`
    puts 'Check \'eye --help\' for more info on managing the processes'
  end
end

# def load_custom_config(path)
#   path = File.expand_path path
#   if File.file? path
#     notify :success, 'Custom configuration loaded'
#     configatron.user_defined_config = path
#   else
#     notify :failure, 'Custom configuration could not be found'
#   end
# end
