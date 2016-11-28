require 'securerandom'
require 'thread'
require 'fileutils'

class Job
  include DataMapper::Resource

  property :id,     Serial
  property :uuid,   String, :default => SecureRandom.uuid

  property :status, Enum[:running, :stopped, :failed, :completed, :starting], :default=>:starting
  property :command, String, :length=>255
  property :output,  String, :length=>255

  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  attr_reader :thr
  attr_reader :spool_name

  def initialize(options={:command=>"/bin/false", :save_output=>true})
    self.command  = options[:command]
    self.uuid = SecureRandom.uuid
    @save_output = options[:save_output]
    @spool_name = File.join(Dir.pwd, "tmp", self.uuid)
    self.output = File.join(@spool_name, "noname.txt")
    create_tmp_spool
  end

  def save_and_run
    @thr = Thread.new do
      self.status = :running
      self.save
      output = `#{self.command}`

      if @save_output
        File.open(self.output, 'w') do |f|
          f.write(output)
        end
      end

      self.status = :completed
      self.save
    end
  end

  def read
    spool_name = File.join(Dir.pwd, "tmp", self.uuid)
    return "Job is #{self.status}" unless self.status == :completed
    return "Missing output file" unless File.exist?(File.join(spool_name, self.output))
    return File.read(File.join(spool_name, self.output))
  end

  def read_json
    ret = ""
    spool_name = File.join(Dir.pwd, "tmp", self.uuid)
    return "Job is #{self.status}" unless self.status == :completed
    return "Missing output file" unless File.exist?(File.join(spool_name, self.output))
    f = File.read(File.join(spool_name, self.output))
    ret = JSON.parse(f)
    return ret
  end


  def kill
    Thread.kill(@thr)
    @thr.exit
    self.status = :stopped
    self.save
  end


  def create_tmp_spool
    FileUtils.mkdir_p(@spool_name)
  end
  def clear_tmp_spool
    FileUtils.rm_rf(@spool_name)
  end
end
