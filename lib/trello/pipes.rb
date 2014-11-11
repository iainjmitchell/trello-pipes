SUB_DIRECTORIES = [
	'adapters',
	'filters',
	'producers'
]

ABSOLUTE_PATH = File.dirname(__FILE__)

SUB_DIRECTORIES.each do | sub_directory |
	sub_directory_path =  File.expand_path("./#{sub_directory}/*.rb", ABSOLUTE_PATH)
	Dir.glob(sub_directory_path).each do |file|
  		require file
	end
end