require 'grape'
require 'data_mapper'
require 'fileutils'


FileUtils.rm_f(File.join(Dir.pwd, "tmp"))

require './models/job.rb'
Dir.glob('./{models}/*.rb').each { |file| require file }

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/canaveral_#{ENV["RACK_ENV"]}.db")
DataMapper.finalize
DataMapper.auto_upgrade!


require './canaveral.rb'
run Canaveral
