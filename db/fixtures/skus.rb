
#load SKUs into DB

Sku.seed( :id, 
 #{id: integer, code: string, model: string, description: string, created_at: datetime, updated_at: datetime, base_price: decimal} 
 {id: 1, code: 'member1y', model: 'coupon', description: '1 Year Premium Membership' , base_price: 20.00, 
    power:{:premium => true, :duration_when_activated => 1.year } }, 
 {id: 2, code: 'member2y', model: 'coupon', description: '2 Years Premium Membership' , base_price: 30.00, 
    power:{:premium => true, :duration_when_activated => 2.year} },
 {id: 3, code: 'storage20gb', model: 'coupon', description: '20 GB for 1 year' , base_price: 10.00, 
    power:{:storage => 20, :duration_when_activated => 1.year } },
 {id: 4, code: 'storage50gb', model: 'coupon', description: '50 GB for 1 year' , base_price: 20.00, 
    power:{:storage => 50, :duration_when_activated => 1.year } },
 {id: 5, code: 'storage100gb', model: 'coupon', description: '100 GB for 1 year' , base_price: 30.00, 
    power:{:storage => 100, :duration_when_activated => 1.year } },
 {id: 6, code: 'storage500gb', model: 'coupon', description: '500 GB for 1 year' , base_price: 50.00, 
    power:{:storage => 500, :duration_when_activated => 1.year } }
)
