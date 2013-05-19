class MediasetPhoto < ActiveRecord::Base
  belongs_to :photo
  belongs_to :mediaset
  attr_accessible :photo_id, :mediaset_id, :order
  has_paper_trail
end
