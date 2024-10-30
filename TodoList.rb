require "json"
require "date"

class TodoList
  FILE_PATH = "tasks.json"

  def initialize
    @tasks = load_tasks
  end

  def add
    print "[task]: "
    task = gets.chomp

    print "[deadline (DD-MM-YYYY)]: "
    deadline_input = gets.chomp
    deadline = Date.strptime(deadline_input, "%d-%m-%Y")

    @tasks << { id: generate_id, task: task, deadline: deadline, completed: false }

    save_tasks
    puts "\n"
  end

  def delete
    print "[task ID]: "
    id = gets.to_i

    task = @tasks.find { |task| task[:id] == id }
    return puts "task not found" unless task

    @tasks.reject! { |task| task[:id] == id }

    save_tasks
    puts "\n"
  end

  def edit
    print "[task ID]: "
    id = gets.to_i

    task = @tasks.find { |task| task[:id] == id }
    return puts "task not found" unless task

    print "[new task]: "
    new_task = gets.chomp
    task[:task] = new_task unless new_task.empty?

    print "[new deadline (DD-MM-YYYY)]: "
    deadline_input = gets.chomp
    task[:deadline] = Date.strptime(deadline_input, "%d-%m-%Y") unless deadline_input.empty?

    print "[completed (y/n)]: "
    task[:completed] = gets.chomp.downcase == "y"

    save_tasks
    puts "\n"
  end

  def filter
    puts
    puts "1. by status"
    puts "2. by deadline"
    puts
    print "[filter option]: "
    choice = gets.to_i

    case choice
    when 1
      uncompleted_tasks = @tasks.select { |task| !task[:completed] }
      completed_tasks = @tasks.select { |task| task[:completed] }
      filtered_tasks = uncompleted_tasks + completed_tasks
    when 2
      filtered_tasks = @tasks.sort_by { |task| task[:deadline] }
    else
      puts "wrong input...\n"
      return
    end

    print_tasks(filtered_tasks)
  end

  def generate_id
    @tasks.empty? ? 1 : @tasks.max_by { |task| task[:id] }[:id] + 1
  end

  def print_tasks(tasks = @tasks)
    puts
    tasks.each do |task|
      puts "ID: #{ task[:id] }, task: #{ task[:task] }, deadline: #{ task[:deadline] }, completed: #{ task[:completed] }\n"
    end
    puts
  end 

  private
  def load_tasks
    if File.exist?(FILE_PATH)
      JSON.parse(File.read(FILE_PATH), symbolize_names: true).map do |task|
        task[:deadline] = Date.parse(task[:deadline])
        task
      end
    else
      []
    end
  end

  def save_tasks
    File.write(FILE_PATH, JSON.pretty_generate(@tasks))
  end
end