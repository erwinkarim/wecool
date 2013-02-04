class MediasetPhoto < ActiveRecord::Base
  belongs_to :Photo
  belongs_to :Mediaset
  attr_accessible :order
end
