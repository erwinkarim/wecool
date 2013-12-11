
#load seed photos and sets here
#
base_dir = Rails.root + 'db/fixtures/photos_and_sets'
set_id = 0
file_id = 0
set_order = 1

Dir.foreach(base_dir) do |entry|
  next if !entry.index(/^\./).nil? 
  Mediaset.seed(:id,
    #  Mediaset(id: integer, title: string, description: text, persona_id: integer, created_at: datetime, 
    #   updated_at: datetime, up_votes: integer, down_votes: integer, featured: boolean, system_visible: boolean)
    { id:set_id, title:entry, description:'Seed data', persona_id:1, featured:(rand(1..100) > 50 ), system_visible:true}
  )
  Dir.foreach(base_dir + entry) do |file|
    next if !file.index(/^\./).nil?
        
    seed_file = File.open(base_dir+entry+file) 
    Photo.seed(:id,
      #Photo(id: integer, title: string, description: text, persona_id: integer, created_at: datetime, 
      # updated_at: datetime, avatar: string, featured: boolean, up_votes: integer, down_votes: integer, 
      # visible: boolean, system_visible: boolean, 
      # taken_at: datetime, md5: string, exif: text, width: integer, height: integer)
      { id:file_id, title:file.sub(/.jpg/, ''), description:'#seed photo of #' + entry, persona_id:1, avatar:seed_file,
        featured:(rand(1..100) > 70), system_visible:true }
    )
    MediasetPhoto.seed(:id,
      #MediasetPhoto(id: integer, photo_id: integer, mediaset_id: integer, order: integer, 
      # created_at: datetime, updated_at: datetime)
      { photo_id:file_id, mediaset_id:set_id, order:set_order }
    )
    file_id += 1
    set_order += 1
  end
  set_order = 1
  set_id += 1
end

#reset tags on the photos
Photo.where(:id => 0..file_id-1).each{ |x| x.reset_tags} 
