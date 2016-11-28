class DawnscannerJob < Job
  def initialize(options={:path=>"", :save_output=>false})
    super(options)
    self.output = "dawnscanner.json"
    self.command = "dawn #{options[:path]} -j -F #{File.join(@spool_name, "dawnscanner.json")}"
  end

  # output will be consumed this way:
  # raw = self.output
  # raw_h = eval(raw)
  #
  # raw_h is a string separated by \n containing raw dawn results
end
