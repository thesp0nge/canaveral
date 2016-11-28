class NmapJob < Job

  def initialize(options={:hl=>"127.0.0.1", :vuln=>false})
    super(options)

    unless options[:vuln]
      self.output   = "nmap.txt"
      self.command  = "nmap #{options[:hl]} -oA #{File.join(@spool_name, "nmap")}"
    else
      self.output   = "va_nmap.txt"
      self.command  = "nmap -sV --script=vulscan/vulscan.nse #{options[:hl]} -oA #{File.join(@spool_name, "va_nmap")}"
    end
  end
end
