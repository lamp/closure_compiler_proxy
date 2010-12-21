require "sha1"

EM.next_tick do
  
  EM.add_periodic_timer 20 do
    $jobs = Job.all
    timestamp = Time.now.to_i
    $complete = {}
    $jobs.each do |job|
      job.delete and next if job.completion_time.to_i < (timestamp - 120) and job.state == "completed"
      $complete[job.uuid] = "complete"
    end
  end
  
end

class Job < Ohm::Model
  
  attribute :uuid
  attribute :state
  attribute :completion_time
  
end


class Closure
  
  def self.compile path
    
    uri =  URI.parse("http://closure-compiler.appspot.com/compile")
    
    request = Net::HTTP::Post.new uri.path
    request.form_data = {:code_url => path,
                         :compilation_level => "SIMPLE_OPTIMIZATIONS",
                         :output_format => "text",
                         :output_info => 'compiled_code'
                        }
    Net::HTTP.new(uri.host, uri.port).start do |http| 
      response = http.request request
      yield response
    end
    
  end
  
end


class App < Sinatra::Base
  
  set :app_file, __FILE__
  
  ROOT = File.dirname(__FILE__)
  
  register Sinatra::Async
  
  def sha_file file
    SHA1.new(file).to_s
  end
  
  configure do
    Ohm.connect
  end

  get "/" do
    html =  <<-BO
!!! 5
%html
  %head
    %title
      Title     
  %body
    %p
      Shorten ur stuff
    %form{:action => "/compile", :enctype => "multipart/form-data", :method => "post"}
      %input{:type => :file, :name => :file}
      %input{:type => :submit}
    BO
    haml html
  end

  post "/compile" do
    contents = params[:file][:tempfile].read
    hash = sha_file(contents.dup)
    
    job = Job.create :uuid => hash, :state => "pending"
    
    localpath, remote_path = "#{ROOT}/public/tmp/#{hash}.js", "http://hoxtonites.com/tmp/#{hash}.js"
    File.open(localpath, 'w+') do |f|
      f.print contents
      f.close
      Closure.compile remote_path do |response|
        File.open(localpath, "w+") do |f|
          f.print response.body
          f.close
        end
        job.update_attributes :completion_time => Time.now.to_i.to_s, :state => "completed"
        job.save
        body JSON.generate({:content => response.body, :filename => remote_path})
      end
    end
  end
  
  def not_found
    "404"
  end
  
end