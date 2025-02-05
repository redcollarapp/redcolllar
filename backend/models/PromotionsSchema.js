const mongoose=require('mongoose');

const promotionsSchema=new mongoose.Schema({
    title:{
      type:String,
      required:[true,"please provide title"]
    },
    Image:{
      type:String,
      required:[true,"please provide Image"]
    }
  })

  module.exports=mongoose.model('Promo',promotionsSchema)