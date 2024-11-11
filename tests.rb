require "rspec"
require_relative "./TodoList"

RSpec.describe TodoList do
  before(:each) do
    @file_path = TodoList::FILE_PATH
    @tasks = [
      { id: 1, task: "test task 1", deadline: Date.new(2024, 12, 1), completed: false },
      { id: 2, task: "test task 2", deadline: Date.new(2024, 11, 15), completed: true }
    ]

    File.write(@file_path, JSON.pretty_generate(@tasks))
    @todo_list = TodoList.new
  end

  after(:each) do
    File.delete(@file_path) if File.exist?(@file_path)
  end

  describe "#add" do
    it "adds a new task" do
      allow(@todo_list).to receive(:gets).and_return("new task", "01-01-2025")
      expect { @todo_list.add }.to change { @todo_list.instance_variable_get(:@tasks).size }.by(1)
    end
  end

  describe "#delete" do
    it "deletes a task by ID" do
      allow(@todo_list).to receive(:gets).and_return("1")
      expect { @todo_list.delete }.to change { @todo_list.instance_variable_get(:@tasks).size }.by(-1)
    end

    it "shows an error message if the task (its ID) does not exist" do
      allow(@todo_list).to receive(:gets).and_return("69")
      expect { @todo_list.delete }.to output(/task not found/).to_stdout
    end
  end

  describe "#edit" do
    it "updates the task's description" do
      allow(@todo_list).to receive(:gets).and_return("1", "updated task", "", "n")
      @todo_list.edit

      task = @todo_list.instance_variable_get(:@tasks).find { |t| t[:id] == 1 }
      expect(task[:task]).to eq("updated task")
    end

    it "updates the task's deadline" do
      allow(@todo_list).to receive(:gets).and_return("1", "", "15-12-2024", "n")
      @todo_list.edit

      task = @todo_list.instance_variable_get(:@tasks).find { |t| t[:id] == 1 }
      expect(task[:deadline]).to eq(Date.new(2024, 12, 15))
    end

    it "updates the task's completion status" do
      allow(@todo_list).to receive(:gets).and_return("1", "", "", "y")
      @todo_list.edit

      task = @todo_list.instance_variable_get(:@tasks).find { |t| t[:id] == 1 }
      expect(task[:completed]).to eq(true)
    end
  end

  describe "#filter" do
    it "filters tasks by completion status" do
      allow(@todo_list).to receive(:gets).and_return("1")
      expect { @todo_list.filter }.to output(/test task 1/).to_stdout
    end

    it "filters tasks by deadline" do
      allow(@todo_list).to receive(:gets).and_return("2")
      expect { @todo_list.filter }.to output(/test task 2.*test task 1/m).to_stdout
    end
  end

  describe "#print_tasks" do
    it "prints all tasks" do
      expect { @todo_list.print_tasks }.to output(/test task 1.*test task 2/m).to_stdout
    end
  end

  describe "#generate_id" do
    it "generates a unique ID" do
      expect(@todo_list.generate_id).to eq(3)
    end
  end

  describe "#load_tasks" do
    it "loads tasks from a file" do
      tasks = @todo_list.send(:load_tasks)
      expect(tasks.size).to eq(2)
    end
  end

  describe "#save_tasks" do
    it "saves tasks to a file" do
      @todo_list.send(:save_tasks)
      saved_tasks = JSON.parse(File.read(@file_path), symbolize_names: true)
      expect(saved_tasks.size).to eq(2)
    end
  end
end
