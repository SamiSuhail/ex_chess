ExUnit.start()

for file <- Path.wildcard("#{__DIR__}/support/**/*.ex") do
  Code.require_file(file)
end
