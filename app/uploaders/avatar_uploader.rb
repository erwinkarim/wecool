# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  # depends on enviroment
  if Rails.env.development? then
    storage :file
  elsif Rails.env.production? then
    storage :fog
  end

	#cache dir
	#def cache_dir
	#	'/tmp/wecool-cache'
	#end
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  process :store_dimension
  def store_dimension
    model.width, model.height = `identify -format "%wx%h" #{file.path}`.split(/x/) 
  end

	def height
    `identify -format "%h" #{file.path}`.split(/x/).first.to_i
	end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  version :xlarge do 
    process :resize_to_limit => [0, 1000]
    process :store_dimension
  end

  version :large, :from_version => :xlarge do 
    process :resize_to_limit => [0,800]
    process :store_dimension
  end

  version :medium, :from_version => :xlarge do 
    process :resize_to_limit => [0,600]
  end

  version :small, :from_version => :xlarge do 
    process :resize_to_limit => [0,400]
  end

  version :tiny, :from_version => :xlarge do 
    process :resize_to_limit => [0,200]
  end
  
  version :square200, :from_Version => :xlarge do
    process :resize_to_fill => [200,200]
  end
  
  version :square100, :from_Version => :xlarge do
    process :resize_to_fill => [100,100]
  end
  
  version :square50, :from_Version => :xlarge do
    process :resize_to_fill => [50,50]
  end

  version :thumb100, :from_version => :xlarge do
    process :resize_to_limit => [100,100]
  end

  version :thumb50, :from_version => :xlarge do
    process :resize_to_limit => [50,50]
  end

  def rotate(direction)
    manipulate! do |img|
      if direction == 'left' then
        img.rotate!(-90)
      else
        img.rotate!(90)
      end
    end
  end

  def get_dimensions
    width,height = `identify -format "%wx%h" #{file.path}`.split(/x/)
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
