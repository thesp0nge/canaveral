require 'owasp_zap'

class OwaspzapJob < Job
  include OwaspZap

  attr_reader :target
  attr_reader :zap

  def initialize(options={:target=>"", :save_output=>false})
    super(options)
    @target = options[:target]
    self.output = "owasp_zap.txt"
    self.command = ""
  end

  def save_and_run
    @thr = Thread.new do
      self.status = :running
      self.save

      @zap = OwaspZap::Zap.new# ({:output=>File.join(@spool_name, "#{self.output}")})

      @zap.target=@target
      @zap.spider.start

      while @zap.spider.running? do
        sleep 5
      end


      @zap.ascan.start


      while @zap.ascan.running? do
        sleep 5
      end

      File.open(File.join(@spool_name, "owasp_zap.txt"), 'w') do |f|
        f.write(@zap.alerts.view.body)
      end

      self.status = :completed
      self.save
    end
  end

end
