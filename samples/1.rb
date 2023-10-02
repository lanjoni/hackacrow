print "Enter a number: "
num = gets

if num
  puts "\n#{num.to_i * num.to_i * num.to_i}"
else
  puts "\nEnter a valid number!"
end