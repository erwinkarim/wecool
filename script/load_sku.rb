# script to load sku in the SKU Table
#
# to exec run from rails root:-
#   bundle exec rails runner "eval(File.read 'script/load_sku.rb')"
#

@sku = Sku.new
@sku.update_attributes({:code => '1ypm', :model => "coupon", :description => "1 year Premium Membership" })
@sku = Sku.new
@sku.update_attributes({:code => '2ypm', :model => "coupon", :description => "2 year Premium Membership" })
