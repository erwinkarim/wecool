
#load SKUs into DB

Sku.seed( :id, 
 #{id: integer, code: string, model: string, description: string, created_at: datetime, updated_at: datetime, base_price: decimal} 
 {id: 1, code: 'member1y', model: 'coupon', description: '1 Year Premium Membership' , base_price: 20.00 }, 
 {id: 2, code: 'member2y', model: 'coupon', description: '2 Years Premium Membership' , base_price: 30.00 }
)
