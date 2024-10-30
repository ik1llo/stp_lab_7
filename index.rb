require_relative "./TodoList"

task_manager = TodoList.new

loop do
  puts "1. add task"
  puts "2. delete task"
  puts "3. edit task"
  puts "4. filter tasks"
  puts "5. print tasks"
  puts "6. exit"
  print "\n[option]: "
  choice = gets.to_i

  case choice
  when 1 then task_manager.add
  when 2 then task_manager.delete
  when 3 then task_manager.edit
  when 4 then task_manager.filter
  when 5 then task_manager.print_tasks
  when 6 then break
  else
    puts "wrong input...\n"
  end
end