require 'json'

class Canaveral < Grape::API
  version 'v1', using: :path
  format :json

  desc 'The hello world message' do
    detail 'Canaveral is a Rack API to automate application security tasks'
    named 'Hello World route'
  end

  get :hello do
    {:title  =>"Hello world",
     :message=>"Canaveral is a Rack API to automate application security tasks. Please look at README.md file in order to know how to use Canaveral the right way."
    }.to_json
  end

  desc "Get the job list" do
    detail "Every security test runs in background. Canaveral handles this using job ids"
  end

  get :jobs do
    jobs = Array.new

    Job.all.each do |j|
      h={:uuid=>j.uuid, :status=>j.status, :command=>j.command}
      jobs.push h
    end

    {:jobs=>jobs}.to_json
  end

  desc "Get a single job" do
    detail ""
  end

  get :job do
    uuid=params["uuid"]
    oj = params["oj"]
    output = ""

    j=Job.first({:uuid=>uuid})
    output = j.read unless j.nil? and oj.nil?
    output = j.read_json unless j.nil? and ! oj.nil?

    a={:output=>output}.to_json if oj.nil?
    a=output unless oj.nil?

    a
  end

  desc "Run a portscan" do
    params String
    detail "Create a job to run a portscan"
  end

  post :portscan do
    hl = params[:hl]
    id = -1
    unless hl.nil? or hl.empty?
      j = NmapJob.new({:hl=>hl, :vuln=>false})
      j.save_and_run
      id = j.uuid
    end
    {:id=>id}.to_json
  end

  post :va do
    hl = params[:hl]
    id = -1
    unless hl.nil? or hl.empty?
      j = NmapJob.new({:hl=>hl, :vuln=>true})
      j.save_and_run
      id = j.uuid
    end
    {:id=>id}.to_json
  end

  post :zap do
    target = params[:target]
    id = -1

    j = OwaspzapJob.new({:target=>target})
    j.save_and_run
    id = j.uuid

    {:id=>id}.to_json
  end

  post :dawnscanner do
    path = params[:path]
    id = -1
    if Dir.exist?(path)
      j = DawnscannerJob.new({:path=>path, :save_output=>false})
      j.save_and_run
      id = j.uuid
    end
    {:id=>id}.to_json
  end

end
