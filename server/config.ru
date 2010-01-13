
require 'rubygems'
require 'sinatra'
require 'yaml'

SEEDS = File.dirname(__FILE__) + '/seeds'

helpers do
  def seed_paths
    Dir[SEEDS + '/*']
  end
  
  def seed_versions name
    Dir[SEEDS + "/#{name}/*.yml"].map do |version| 
      File.basename(version).sub('.yml', '')
    end
  end
  
  def seed_names
    seed_paths.map { |path| File.basename path }
  end
  
  def seed name, version
    YAML.load_file SEEDS + "/#{name}/#{version}.yml"
  end
  
  def transfer_seed name, version
    path = SEEDS + "/#{name}/#{version}.seed"
    File.exists?(path) || halt(404)
    content_type :tar
    send_file path
  end
end

##
# Search seeds, all are listed unless filtered by:
#
#  - :name
#

get '/search' do
  seed_names.map do |name|
    next if params[:name] && !name.include?(params[:name])
    '%15s : (%s)' % [name, seed_versions(name).join(', ')]
  end.compact.join("\n") + "\n"
end

##
# Transfer the latest version of the requested seed _name_.

get '/:name' do 
  versions = seed(params[:name]) || halt(404)
  version = versions.keys.first
  transfer_seed params[:name], version
end

##
# Output latest version for seed _name_.

get '/:name/latest' do
  versions = seed(params[:name]) || halt(404)
  versions.keys.first
end

##
# Transfer _version_ of the requested seed _name_.

get '/:name/:version' do
  transfer_seed params[:name], params[:version]
end

run Sinatra::Application