# Just for fun, I made a version that has a really simple(crappy, albeit functional) interface.
# It will still take command line arguments as normal, but if you give no arguments then you
# will get an "interface" where you can type commands.  Type "exit" to leave the program.

require 'csv'

# MODEL

class Task
  attr_accessor :task, :status
  def initialize(data, status = "false")
    @task = data
    @status = status
  end
end

class List
  attr_accessor :tasks
  def initialize
    @tasks = []
  end
end


# VIEW

class UserInterface

  def self.run!
    @list_manager = ListManager.new
    if ARGV == []
      self.simple_interface
    else
      self.take_argument
    end
  end

  def self.simple_interface
    user_input = [""]
    until user_input == ["exit"]
      user_input = gets.chomp.split(" ")
      return if user_input == ["exit"]
      self.process_command(self.process_cli(user_input))
    end
  end

  def self.take_argument
    arguments = self.process_cli(ARGV)
    @list_manager.get_csv('todo.csv')
    self.process_command(arguments)
    @list_manager.write_csv('todo.csv')
  end

  def self.process_command(arguments)
    if arguments[:command] == "add"
      @list_manager.add(arguments[:data])
    elsif arguments[:command] == "delete"
      @list_manager.delete(arguments[:data].to_i)
    elsif arguments[:command] == "open"
      @list_manager.get_csv(arguments[:data])
    elsif arguments[:command] == "save"
      @list_manager.write_csv(arguments[:data])
    elsif arguments[:command] == "list"
      self.list
    elsif arguments[:command] == "checkbox"
      @list_manager.checkbox(arguments[:data].to_i)
    end
  end

  def self.process_cli(arguments)
    command_data = {}
    command_data[:command] = arguments[0]
    arguments.shift
    command_data[:data] = arguments.join(' ')
    return command_data
  end

  def self.list
    counter = 1
    new_manager = @list_manager.list.tasks.dup
    new_manager.shift
    new_manager.each do |task|
      checkbox = "[x]" if task.status == "true"
      checkbox = "[ ]" if task.status == "false"
      puts "#{counter.to_s}. #{checkbox} #{task.task}"
      counter += 1
    end
  end

end


# CONTROLLER

class ListManager
  attr_accessor :list

  def initialize
    @list = List.new
    @file = 'todo.csv'
    @header = []
  end

  def self.run!
    UserInterface.run!
  end

  def add(data)
    @list.tasks << Task.new(data)
  end

  def get_csv(file)
    tasks = []
    CSV.foreach(file) do |row|
      tasks << Task.new(row[0], row[1])
    end
    @list = List.new
    @list.tasks = tasks
  end

  def write_csv(file)
    quote = '"'
    CSV.open(file, "w") do |csv|
      @list.tasks.each do |task|
        csv << [task.task, task.status]
      end
    end
  end

  def delete(task_id)
    @list.tasks.delete_at(task_id)
  end

  def checkbox(task_id)
    if @list.tasks[task_id].status == "false"
      @list.tasks[task_id].status = "true"
    else
      @list.tasks[task_id].status = "false"
    end
  end
end


ListManager.run!