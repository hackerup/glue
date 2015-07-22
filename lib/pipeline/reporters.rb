class Pipeline::Reporters
  @reporters = []

  #Add a task. This will call +_klass_.new+ when running tests
  def self.add klass
    @reporters << klass unless @reporters.include? klass
  end

  def self.reporters
    @reporters
  end

  def self.initialize_reporters reporters_directory = ""
    #Load all files in task_directory
    Dir.glob(File.join(reporters_directory, "*.rb")).sort.each do |f|
      require f
    end
  end

  #No need to use this directly.
  def initialize options = { }
  end

  #Run all the tasks on the given Tracker.
  #Returns a new instance of tasks with the results.
  def self.run_report(tracker)
    @reporters.each do |c|
      reporter = c.new()
      Pipeline.debug "Reporting for #{tracker.options[:output_format]}"
      if tracker.options[:output_format] == reporter.format
        begin
          output = reporter.run_report(tracker)
          if tracker.options[:output_file]
            file = File.open(tracker.options[:output_file], 'w'){ |f| f.write(output)}
          else
            puts output
          end
        rescue => e
          Pipeline.notify e.message
          tracker.error e
        end
      end
    end
  end

end

#Load all files in reporters/ directory
Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/reporters/*.rb").sort.each do |f|
  require f.match(/(pipeline\/reporters\/.*)\.rb$/)[0]
end
