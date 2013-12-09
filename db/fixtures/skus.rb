
#load SKUs into DB

Sku.seed( :id, 
 #{id: integer, code: string, model: string, description: string, created_at: datetime, updated_at: datetime, base_price: decimal} 
 {id: 1, code: 'member1y', model: 'coupon', description: '1 Year Premium Membership' , base_price: 20.00, 
    power:{:premium => true, :duration_when_activated => 1.year } }, 
 {id: 2, code: 'member2y', model: 'coupon', description: '2 Years Premium Membership' , base_price: 30.00, 
    power:{:premium => true, :duration_when_activated => 2.year} },
 {id: 3, code: 'storage25gmonth', model: 'coupon', description: '25 GB for 1 month' , base_price: 4.00, 
    power:{:storage => 25, :duration_when_activated => 1.month } },
 {id: 4, code: 'storage50gbmonth', model: 'coupon', description: '50 GB for 1 month' , base_price: 8.00, 
    power:{:storage => 50, :duration_when_activated => 1.month } },
 {id: 5, code: 'storage100gbmonth', model: 'coupon', description: '100 GB for 1 month' , base_price: 15.00, 
    power:{:storage => 100, :duration_when_activated => 1.month } },
 {id: 6, code: 'storage200gbmonth', model: 'coupon', description: '200 GB for 1 month' , base_price: 30.00, 
    power:{:storage => 200, :duration_when_activated => 1.month } },
 {id: 7, code: 'storage400gbmonth', model: 'coupon', description: '400 GB for 1 month' , base_price: 60.00, 
    power:{:storage => 400, :duration_when_activated => 1.month } },
 {id: 8, code: 'storage800gbmonth', model: 'coupon', description: '800 GB for 1 month' , base_price: 120.00, 
    power:{:storage => 800, :duration_when_activated => 1.month } },
 {id: 9, code: 'storage25gbyear', model: 'coupon', description: '25 GB for 1 year' , base_price: 40.00, 
    power:{:storage => 50, :duration_when_activated => 1.year } },
 {id: 10, code: 'storage50gbyear', model: 'coupon', description: '50 GB for 1 year' , base_price: 80.00, 
    power:{:storage => 50, :duration_when_activated => 1.year } },
 {id: 11, code: 'storage100gbyear', model: 'coupon', description: '100 GB for 1 year' , base_price: 150.00, 
    power:{:storage => 100, :duration_when_activated => 1.year } },
 {id: 12, code: 'storage200gbyear', model: 'coupon', description: '200 GB for 1 year' , base_price: 300.00, 
    power:{:storage => 200, :duration_when_activated => 1.year } },
 {id: 13, code: 'storage400gbyear', model: 'coupon', description: '400 GB for 1 year' , base_price: 600.00, 
    power:{:storage => 400, :duration_when_activated => 1.year } },
 {id: 14, code: 'storage800gbyear', model: 'coupon', description: '800 GB for 1 year' , base_price: 1200.00, 
    power:{:storage => 800, :duration_when_activated => 1.year } }
)
